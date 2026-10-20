Option Explicit
Option VBASupport 1

Private mConexionMacro As Object
Private mTieneConexion As Boolean

' Base puede compartir la conexión del controlador con formularios abiertos.
' Una conexión aislada admite transacciones propias sin afectar ese trabajo.
' El argumento explícito permite pruebas; el llamador es dueño de esa conexión.
Public Function ConexionBase(Optional ByVal conexion As Variant) As Object
    If Not IsMissing(conexion) Then
        If IsObject(conexion) Then
            ConexionBase = conexion
            Exit Function
        End If
    End If
    If Not mTieneConexion Then
        mConexionMacro = ThisDatabaseDocument.DataSource.getIsolatedConnection("", "")
        mTieneConexion = True
    End If
    ConexionBase = mConexionMacro
End Function

' Cierra solamente la conexión aislada abierta por este módulo.
Public Sub CerrarConexionBase()
    If mTieneConexion Then mConexionMacro.close()
    mTieneConexion = False
End Sub

' DECIMAL se vincula con tipo SQL 3 y escala 4, usando texto canónico exacto.
Public Sub FijarMoneda(ByVal consulta As Object, ByVal indice As Long, ByVal importe As Currency)
    consulta.setObjectWithInfo(indice,DecimalSQL(importe),3,4)
End Sub
Public Function VerColaCobranza(Optional ByVal conexion As Variant, _
                               Optional ByVal mostrar As Boolean = True) As String
    Dim cn As Object, q As Object, rs As Object, texto As String
    cn = ConexionBase(conexion)
    q = cn.createStatement()
    rs = q.executeQuery("SELECT ""NumeroFactura"",""Fecha"" FROM ""tblFacturas"" WHERE ""Estado""='Emitida' ORDER BY ""NumeroFactura""")
    Do While rs.next()
        texto = texto & rs.getInt(1) & " | " & rs.getString(2) & Chr(10)
    Loop
    rs.close(): q.close()
    If texto = "" Then texto = "(la cola está vacía)"
    VerColaCobranza = texto
    If mostrar Then MsgBox texto,64,"Cola FIFO"
End Function

Public Function AtenderSiguienteCobro(Optional ByVal conexion As Variant) As Long
    Dim cn As Object, q As Object, rs As Object, id As Long, numero As Long, codigo As Long, descripcionError As String
    cn = ConexionBase(conexion)
    If Not cn.getAutoCommit() Then Err.Raise 3002, "Curso", MensajeError(3002)
    On Error GoTo Falla
    cn.setAutoCommit(False)
    q = cn.createStatement()
    ' HSQLDB 1.8 no bloquea filas; el UPDATE solo cambia la factura si sigue emitida.
    rs = q.executeQuery("SELECT ""IdFactura"",""NumeroFactura"" FROM ""tblFacturas"" WHERE ""Estado""='Emitida' ORDER BY ""NumeroFactura"" LIMIT 1")
    If rs.next() Then
        id = rs.getInt(1): numero = rs.getInt(2)
    End If
    rs.close(): q.close()
    If id <> 0 Then
        q = cn.prepareStatement("UPDATE ""tblFacturas"" SET ""Estado""='Pagada' WHERE ""IdFactura""=? AND ""Estado""='Emitida'")
        q.setInt(1,id)
        If q.executeUpdate() <> 1 Then Err.Raise 3003, "Curso", MensajeError(3003)
        q.close()
    End If
    cn.commit(): cn.setAutoCommit(True)
    AtenderSiguienteCobro = numero
    Exit Function
Falla:
    codigo = Err.Number
    descripcionError = Err.Description
    On Error Resume Next
    cn.rollback(): cn.setAutoCommit(True): q.close()
    On Error GoTo 0
    Err.Raise codigo, "Curso", descripcionError
End Function

Public Sub CambiarPrecio(ByVal idProducto As Long, ByVal nuevoPrecio As Currency, _
                        Optional ByVal conexion As Variant)
    Dim cn As Object, q As Object, codigo As Long, descripcionError As String
    If nuevoPrecio < 0 Then Err.Raise 6001, "Curso", MensajeError(6001)
    cn = ConexionBase(conexion)
    If Not cn.getAutoCommit() Then Err.Raise 3002, "Curso", MensajeError(3002)
    On Error GoTo Falla
    cn.setAutoCommit(False)
    q = cn.prepareStatement("INSERT INTO ""tblHistorialPrecios"" (""IdProducto"",""PrecioAnterior"",""FechaCambio"") SELECT ""IdProducto"",""Precio"",CURRENT_TIMESTAMP FROM ""tblProductos"" WHERE ""IdProducto""=?")
    q.setInt(1,idProducto)
    If q.executeUpdate() <> 1 Then Err.Raise 6002, "Curso", MensajeError(6002)
    q.close()
    ActualizarPrecio cn,idProducto,nuevoPrecio
    cn.commit(): cn.setAutoCommit(True)
    Exit Sub
Falla:
    codigo = Err.Number
    descripcionError = Err.Description
    On Error Resume Next
    cn.rollback(): cn.setAutoCommit(True): q.close()
    On Error GoTo 0
    Err.Raise codigo, "Curso", descripcionError
End Sub

Public Function DeshacerUltimoCambio(ByVal idProducto As Long, _
                                    Optional ByVal conexion As Variant) As Boolean
    Dim cn As Object, q As Object, rs As Object, id As Long, precio As Currency, codigo As Long, descripcionError As String
    cn = ConexionBase(conexion)
    If Not cn.getAutoCommit() Then Err.Raise 3002, "Curso", MensajeError(3002)
    On Error GoTo Falla
    cn.setAutoCommit(False)
    q = cn.prepareStatement("SELECT ""IdCambio"",""PrecioAnterior"" FROM ""tblHistorialPrecios"" WHERE ""IdProducto""=? ORDER BY ""IdCambio"" DESC LIMIT 1")
    q.setInt(1,idProducto)
    rs = q.executeQuery()
    If rs.next() Then
        id = rs.getInt(1): precio = MonedaDesdeSQL(rs.getString(2))
    End If
    rs.close(): q.close()
    If id <> 0 Then
        ActualizarPrecio cn,idProducto,precio
        q = cn.prepareStatement("DELETE FROM ""tblHistorialPrecios"" WHERE ""IdCambio""=?")
        q.setInt(1,id)
        q.executeUpdate(): q.close()
    End If
    cn.commit(): cn.setAutoCommit(True)
    DeshacerUltimoCambio = (id <> 0)
    Exit Function
Falla:
    codigo = Err.Number
    descripcionError = Err.Description
    On Error Resume Next
    cn.rollback(): cn.setAutoCommit(True): q.close()
    On Error GoTo 0
    Err.Raise codigo, "Curso", descripcionError
End Function

Private Sub ActualizarPrecio(ByVal cn As Object, ByVal id As Long, ByVal precio As Currency)
    Dim q As Object
    q = cn.prepareStatement("UPDATE ""tblProductos"" SET ""Precio""=? WHERE ""IdProducto""=?")
    FijarMoneda q,1,precio
    q.setInt(2,id)
    If q.executeUpdate() <> 1 Then Err.Raise 6002, "Curso", MensajeError(6002)
    q.close()
End Sub

Public Function ImprimirArbol(Optional ByVal idPadre As Long = 0, _
                              Optional ByVal nivel As Integer = 0, _
                              Optional ByVal conexion As Variant, _
                              Optional ByVal mostrar As Boolean = True) As String
    Dim cn As Object, visitados As Object, texto As String
    cn = ConexionBase(conexion)
    GlobalScope.BasicLibraries.loadLibrary("ScriptForge")
    visitados = CreateScriptService("Dictionary",True)
    texto = RecorrerArbol(cn,idPadre,nivel,visitados)
    visitados.Dispose()
    ImprimirArbol = texto
    If mostrar Then MsgBox texto,64,"Árbol de categorías"
End Function

Private Function RecorrerArbol(ByVal cn As Object, ByVal padre As Long, ByVal nivel As Integer, _
                              ByVal visitados As Object) As String
    Dim q As Object, rs As Object, filtro As String, id As Long, texto As String
    If padre = 0 Then
        filtro = """IdCategoriaPadre"" IS NULL"
    Else
        filtro = """IdCategoriaPadre""=?"
    End If
    q = cn.prepareStatement("SELECT ""IdCategoria"",""Nombre"" FROM ""tblCategorias"" WHERE " & filtro & " ORDER BY ""Nombre""")
    If padre <> 0 Then q.setInt(1,padre)
    rs = q.executeQuery()
    Do While rs.next()
        id = rs.getInt(1)
        If visitados.Exists(CStr(id)) Then Err.Raise 6003, "Curso", MensajeError(6003)
        visitados.Add CStr(id),True
        texto = texto & Space(nivel*4) & "- " & rs.getString(2) & Chr(10)
        texto = texto & RecorrerArbol(cn,id,nivel+1,visitados)
    Loop
    rs.close(): q.close()
    RecorrerArbol = texto
End Function

Public Function UnidadesPorProducto(Optional ByVal conexion As Variant, _
                                    Optional ByVal mostrar As Boolean = True) As String
    Dim cn As Object, q As Object, rs As Object, dic As Object, clave As Variant, claves As Variant, texto As String
    cn = ConexionBase(conexion)
    GlobalScope.BasicLibraries.loadLibrary("ScriptForge")
    dic = CreateScriptService("Dictionary",True)
    q = cn.createStatement()
    rs = q.executeQuery("SELECT p.""Codigo"",d.""Cantidad"" FROM ""tblDetalleFactura"" d INNER JOIN ""tblProductos"" p ON d.""IdProducto""=p.""IdProducto"" ORDER BY p.""Codigo""")
    Do While rs.next()
        clave = rs.getString(1)
        If dic.Exists(clave) Then
            dic.ReplaceItem clave,CLng(dic.Item(clave))+rs.getInt(2)
        Else
            dic.Add clave,rs.getInt(2)
        End If
    Loop
    rs.close(): q.close()
    claves = dic.Keys
    For Each clave In claves
        texto = texto & clave & " -> " & dic.Item(clave) & Chr(10)
    Next clave
    dic.Dispose()
    UnidadesPorProducto = texto
    If mostrar Then MsgBox texto,64,"Diccionario de unidades"
End Function

Public Sub EjecutarCola()
    Dim resultado As String
    resultado = VerColaCobranza()
End Sub
Public Sub EjecutarArbol()
    Dim resultado As String
    resultado = ImprimirArbol()
End Sub
Public Sub EjecutarUnidades()
    Dim resultado As String
    resultado = UnidadesPorProducto()
End Sub
