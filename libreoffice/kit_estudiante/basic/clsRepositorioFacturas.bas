Option Explicit
Option VBASupport 1
Option ClassModule

' SDBC/UNO. La factura conserva sus precios pactados; nunca se sustituyen por el catálogo.
Private mConexion As Object
Private mInicializado As Boolean

Public Sub Inicializar(ByVal conexion As Object)
    mConexion = conexion
    mInicializado = True
End Sub
Private Function Conexion() As Object
    If Not mInicializado Then Inicializar ConexionBase()
    Conexion = mConexion
End Function

Public Function Obtener(ByVal idFactura As Long) As clsFactura
    Dim cn As Object, q As Object, rs As Object, ql As Object, rl As Object
    Dim f As clsFactura, numero As Long, fecha As Date, cliente As Long, tasa As Double, estado As String
    cn = Conexion()
    q = cn.prepareStatement("SELECT ""NumeroFactura"",""Fecha"",""IdCliente"",""TasaImpuesto"",""Estado"" FROM ""tblFacturas"" WHERE ""IdFactura""=?")
    q.setInt(1, idFactura)
    rs = q.executeQuery()
    If Not rs.next() Then
        rs.close(): q.close()
        Err.Raise 3001, "Curso", MensajeError(3001)
    End If
    numero = rs.getInt(1)
    fecha = CDateFromUnoDate(rs.getDate(2))
    cliente = rs.getInt(3)
    tasa = rs.getDouble(4)
    estado = rs.getString(5)
    rs.close(): q.close()
    f = New clsFactura
    ql = cn.prepareStatement("SELECT d.""IdProducto"",p.""Descripcion"",d.""Cantidad"",d.""PrecioUnitario"" FROM ""tblDetalleFactura"" d INNER JOIN ""tblProductos"" p ON d.""IdProducto""=p.""IdProducto"" WHERE d.""IdFactura""=? ORDER BY d.""IdProducto""")
    ql.setInt(1, idFactura)
    rl = ql.executeQuery()
    Do While rl.next()
        f.AgregarLinea rl.getInt(1), rl.getString(2), rl.getInt(3), MonedaDesdeSQL(rl.getString(4))
    Loop
    rl.close(): ql.close()
    f.Cargar idFactura, numero, fecha, cliente, tasa, estado
    Obtener = f
End Function

Public Sub Guardar(ByVal f As clsFactura)
    Dim cn As Object, q As Object, rs As Object, linea As Object, anterior As clsFactura
    Dim id As Long, i As Long, transaccion As Boolean, codigo As Long, descripcionError As String
    cn = Conexion()
    If Not cn.getAutoCommit() Then Err.Raise 3002, "Curso", MensajeError(3002)
    On Error GoTo Falla
    cn.setAutoCommit(False)
    transaccion = True
    id = f.IdFactura
    If id = 0 Then
        ' HSQLDB asigna IdFactura al insertar; UltimaIdentidad lo lee después.
        q = cn.prepareStatement("INSERT INTO ""tblFacturas"" (""NumeroFactura"",""Fecha"",""IdCliente"",""TasaImpuesto"",""Estado"") VALUES (?,?,?,?,?)")
    Else
        ' Comprobar dentro de la misma transacción que la factura existe.
        ' HSQLDB 1.8 no bloquea filas: la base incorporada del curso es de un solo usuario.
        q = cn.prepareStatement("SELECT ""IdFactura"" FROM ""tblFacturas"" WHERE ""IdFactura""=?")
        q.setInt(1,id)
        rs = q.executeQuery()
        If Not rs.next() Then Err.Raise 3001, "Curso", MensajeError(3001)
        rs.close(): q.close()
        anterior = Obtener(id)
        ValidarActualizacion anterior, f
        q = cn.prepareStatement("UPDATE ""tblFacturas"" SET ""NumeroFactura""=?,""Fecha""=?,""IdCliente""=?,""TasaImpuesto""=?,""Estado""=? WHERE ""IdFactura""=?")
        q.setInt(6,id)
    End If
    If f.Numero = 0 Then
        q.setNull(1,4) ' INTEGER
    Else
        q.setInt(1,f.Numero)
    End If
    q.setDate(2,CDateToUnoDate(f.Fecha))
    q.setInt(3,f.IdCliente)
    FijarMoneda q,4,CCur(f.TasaImpuesto)
    q.setString(5,f.Estado)
    q.executeUpdate()
    q.close()
    If id = 0 Then id = UltimaIdentidad(cn)
    q = cn.prepareStatement("DELETE FROM ""tblDetalleFactura"" WHERE ""IdFactura""=?")
    q.setInt(1,id)
    q.executeUpdate(): q.close()
    q = cn.prepareStatement("INSERT INTO ""tblDetalleFactura"" (""IdFactura"",""IdProducto"",""Cantidad"",""PrecioUnitario"") VALUES (?,?,?,?)")
    For i = 1 To f.CantidadLineas
        linea = f.Linea(i)
        q.setInt(1,id)
        q.setInt(2,linea.IdProducto)
        q.setInt(3,linea.Cantidad)
        FijarMoneda q,4,linea.PrecioUnitario
        q.executeUpdate()
    Next i
    q.close()
    cn.commit()
    transaccion = False
    cn.setAutoCommit(True)
    ' Asignar solo después de confirmar: una reversión deja IdFactura = 0.
    f.AsignarId id
    Exit Sub
Falla:
    codigo = Err.Number
    descripcionError = Err.Description
    On Error Resume Next
    If transaccion Then cn.rollback()
    q.close()
    cn.setAutoCommit(True)
    On Error GoTo 0
    Err.Raise codigo, "Curso", descripcionError
End Sub

Private Sub ValidarActualizacion(ByVal anterior As clsFactura, ByVal nueva As clsFactura)
    Dim i As Long, j As Long, a As Object, b As Object, encontrada As Boolean
    If anterior.Estado = ESTADO_BORRADOR Then Exit Sub
    If nueva.Numero <> anterior.Numero Or nueva.IdCliente <> anterior.IdCliente Or _
       nueva.Fecha <> anterior.Fecha Or nueva.TasaImpuesto <> anterior.TasaImpuesto Or _
       nueva.CantidadLineas <> anterior.CantidadLineas Then Err.Raise 3003, "Curso", MensajeError(3003)
    For i = 1 To anterior.CantidadLineas
        a = anterior.Linea(i)
        encontrada = False
        For j = 1 To nueva.CantidadLineas
            b = nueva.Linea(j)
            If a.IdProducto = b.IdProducto Then
                encontrada = True
                Exit For
            End If
        Next j
        If Not encontrada Then Err.Raise 3003, "Curso", MensajeError(3003)
        If a.Cantidad <> b.Cantidad Or a.PrecioUnitario <> b.PrecioUnitario Then Err.Raise 3003, "Curso", MensajeError(3003)
    Next i
    If anterior.Estado = ESTADO_EMITIDA Then
        If nueva.Estado <> ESTADO_EMITIDA And nueva.Estado <> ESTADO_PAGADA And _
           nueva.Estado <> ESTADO_ANULADA Then Err.Raise 3003, "Curso", MensajeError(3003)
    Else
        If nueva.Estado <> anterior.Estado Then Err.Raise 3003, "Curso", MensajeError(3003)
    End If
End Sub

' Ejercicio monousuario: consulta MAX, no reserva una secuencia concurrente.
' La restricción UNIQUE impide números repetidos; un conflicto exige volver a cargar.
Public Function SiguienteNumero() As Long
    Dim cn As Object, q As Object, rs As Object
    cn = Conexion()
    q = cn.createStatement()
    rs = q.executeQuery("SELECT COALESCE(MAX(""NumeroFactura""),1000)+1 FROM ""tblFacturas""")
    rs.next()
    SiguienteNumero = rs.getInt(1)
    rs.close(): q.close()
End Function

' Identidad técnica de HSQLDB, distinta del número comercial de factura.
' No usa MAX(IdFactura): CALL IDENTITY() devuelve el último valor generado por esta
' misma conexión, aunque otra conexión inserte facturas. Una reversión puede dejar un hueco.
Private Function UltimaIdentidad(ByVal cn As Object) As Long
    Dim q As Object, rs As Object
    q = cn.createStatement()
    rs = q.executeQuery("CALL IDENTITY()")
    If Not rs.next() Then Err.Raise 3011, "Curso", MensajeError(3011)
    UltimaIdentidad = rs.getInt(1)
    rs.close(): q.close()
    If UltimaIdentidad <= 0 Then Err.Raise 3011, "Curso", MensajeError(3011)
End Function
