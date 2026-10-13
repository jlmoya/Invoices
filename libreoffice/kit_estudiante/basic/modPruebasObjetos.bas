Option Explicit
Option VBASupport 1

' Las funciones devuelven un informe y mostrar=False permite ejecución sin interfaz.
' Los Sub Ejecutar... aparecen en Herramientas > Macros > Ejecutar macro.
Public Function ProbarFactura(Optional ByVal conexion As Variant, _
                             Optional ByVal mostrar As Boolean = True) As String
    Dim f As clsFactura, texto As String
    f = NuevaFactura()
    f.AgregarLinea 4,"Monitor 24 pulgadas Full HD",3,2899
    f.AgregarLinea 8,"Cable HDMI 2 m",3,149.9
    texto = "Subtotal: " & Format(f.Subtotal,"0.00") & Chr(10) & _
            "Impuesto: " & Format(f.Impuesto,"0.00") & Chr(10) & _
            "Total: " & Format(f.Total,"0.00") & Chr(10)
    Informar texto,"Totales 9146.70 / 1463.47 / 10610.17", _
             f.Subtotal=CCur(9146.7) And f.Impuesto=CCur(1463.47) And f.Total=CCur(10610.17)
    f.Emitir 9999
    Informar texto,"Rechaza agregar líneas después de emitir",Capturar(f,4)=2009
    ProbarFactura = texto
    If mostrar Then MsgBox texto,64,"Factura en memoria"
End Function

Public Function ProbarReglas(Optional ByVal conexion As Variant, _
                            Optional ByVal mostrar As Boolean = True) As String
    Dim f As clsFactura, texto As String, linea As clsLineaFactura
    f = NuevaFactura()
    Informar texto,"Rechaza emitir sin líneas",Capturar(f,1)=2005
    f = New clsFactura
    f.AgregarLinea 11,"Papel",1,119
    Informar texto,"Rechaza emitir sin cliente",Capturar(f,1)=2004
    f = New clsFactura
    Informar texto,"Rechaza anular un borrador",Capturar(f,2)=2007
    f = NuevaFactura()
    f.AgregarLinea 11,"Papel",1,119
    Informar texto,"Rechaza producto duplicado",Capturar(f,3)=2003
    Informar texto,"Rechaza cantidad cero",Capturar(f,6)=2101
    Informar texto,"Rechaza precio negativo",Capturar(f,7)=2102
    Informar texto,"Rechaza número cero",Capturar(f,8)=2010
    f.Emitir 9003
    Informar texto,"Rechaza agregar después de emitir",Capturar(f,4)=2009
    Informar texto,"Rechaza cambiar cliente emitido",Capturar(f,5)=2009
    Informar texto,"Rechaza reabrir emitida mediante Cargar",Capturar(f,10)=3010
    Informar texto,"Permite anular una emitida",Capturar(f,2)=0 And f.Estado=ESTADO_ANULADA
    Informar texto,"Rechaza pagar una anulada",Capturar(f,9)=2006
    f = NuevaFactura()
    f.AgregarLinea 11,"Papel",1,119
    f.Emitir 9004
    f.RegistrarPago
    Informar texto,"Permite pagar emitida",f.Estado=ESTADO_PAGADA
    Informar texto,"Rechaza anular pagada",Capturar(f,2)=2007
    Informar texto,"Rechaza cambiar identidad persistida",Capturar(f,11)=3010
    linea = f.Linea(1)
    Informar texto,"Línea inmutable",CapturarLinea(linea)=2103
    Informar texto,"Mitad hacia arriba",RedondearMoneda(CCur(1.005))=CCur(1.01)
    Informar texto,"DECIMAL(18,4) conserva todos sus dígitos", _
             DecimalSQL(MonedaDesdeSQL("99999999999999.9999"))="99999999999999.9999"
    Informar texto,"Porcentaje exacto en todo el rango decimal", _
             DecimalSQL(CalcularPorcentajeMoneda(MonedaDesdeSQL("99999999999999.9999"),CCur(0.16)))="16000000000000.0000"
    Informar texto,"Redondeo exacto inmediatamente debajo de mitad", _
             CalcularPorcentajeMoneda(MonedaDesdeSQL("0.0499"),CCur(0.1))=0
    Informar texto,"Redondeo exacto en mitad", _
             CalcularPorcentajeMoneda(MonedaDesdeSQL("0.0500"),CCur(0.1))=CCur(0.01)
    ProbarReglas = texto
    If mostrar Then MsgBox texto,64,"Pruebas de reglas"
End Function

Private Function NuevaFactura() As clsFactura
    Dim f As clsFactura
    f = New clsFactura
    f.IdCliente = 2
    f.TasaImpuesto = 0.16
    NuevaFactura = f
End Function
Private Sub Informar(ByRef texto As String, ByVal regla As String, ByVal cumple As Boolean)
    If cumple Then
        texto = texto & "Correcto: " & regla & Chr(10)
    Else
        texto = texto & "FALLA: " & regla & Chr(10)
    End If
End Sub
Private Function Capturar(ByVal f As clsFactura, ByVal accion As Integer) As Long
    On Error GoTo Rechazo
    Select Case accion
    Case 1: f.Emitir 9001
    Case 2: f.Anular
    Case 3: f.AgregarLinea 11,"Duplicado",1,119
    Case 4: f.AgregarLinea 13,"Bolígrafo",1,72
    Case 5: f.IdCliente = 5
    Case 6: f.AgregarLinea 13,"Bolígrafo",0,72
    Case 7: f.AgregarLinea 13,"Bolígrafo",1,-1
    Case 8: f.Emitir 0
    Case 9: f.RegistrarPago
    Case 10: f.Cargar 1,0,Date,2,0.16,ESTADO_BORRADOR
    Case 11:
        f.AsignarId 123
        f.AsignarId 124
    End Select
    Exit Function
Rechazo:
    Capturar = Err.Number
    Resume Fin
Fin:
End Function
Private Function CapturarLinea(ByVal linea As clsLineaFactura) As Long
    On Error GoTo Rechazo
    linea.Inicializar 11,"Papel",9,999
    Exit Function
Rechazo:
    CapturarLinea = Err.Number
    Resume Fin
Fin:
End Function

Public Function ProbarRepositorio(Optional ByVal conexion As Variant, _
                                 Optional ByVal mostrar As Boolean = True) As String
    Dim cn As Object, repo As clsRepositorioFacturas, f As clsFactura, g As clsFactura
    Dim q As Object, rs As Object, id As Long, texto As String, numero As Long, fallo As Long, descripcionError As String
    cn = ConexionBase(conexion)
    repo = New clsRepositorioFacturas
    repo.Inicializar cn
    f = repo.Obtener(3)
    texto = "Factura " & f.Numero & " (" & f.Estado & ")" & Chr(10)
    Informar texto,"Carga precios históricos y totales", _
             f.Numero=1003 And f.Subtotal=CCur(9146.7) And f.Total=CCur(10610.17)
    Informar texto,"Rechaza factura inexistente",CapturarObtener(repo,-1)=3001
    numero = repo.SiguienteNumero()
    On Error GoTo Falla
    f = NuevaFactura()
    f.AgregarLinea 11,"Papel",2,CCur(1.005)
    repo.Guardar f
    id = f.IdFactura
    g = repo.Obtener(id)
    Informar texto,"Guarda y recarga borrador con identidad nueva",id>7 And g.IdFactura=id And g.Numero=0 And g.CantidadLineas=1 And g.Subtotal=CCur(2.01)
    f.QuitarLinea 11
    f.AgregarLinea 13,"Bolígrafo",3,CCur(0.3333)
    repo.Guardar f
    g = repo.Obtener(id)
    Informar texto,"Actualiza detalle y conserva identidad",g.IdFactura=id And g.Linea(1).IdProducto=13 And g.Subtotal=CCur(0.9999)
    ' Orden de creación 13 -> 11; Obtener reconstruye 11 -> 13 por su ORDER BY.
    ' El agregado se compara por identidad de producto, sin depender de ese orden.
    f.AgregarLinea 11,"Papel",2,MonedaDesdeSQL("0.1250")
    repo.Guardar f
    g = repo.Obtener(id)
    Informar texto,"Recarga dos líneas con orden distinto y precios pactados", _
             g.CantidadLineas=2 And g.Linea(1).IdProducto=11 And _
             g.Linea(1).PrecioUnitario=MonedaDesdeSQL("0.1250") And g.Subtotal=CCur(1.2499)
    ' Una FK inválida después de borrar el detalle debe revertir cabecera Y líneas.
    f.AgregarLinea 999999,"No existe",1,10
    fallo = CapturarGuardar(repo,f)
    g = repo.Obtener(id)
    Informar texto,"Revierte actualización completa por FK inválida",fallo<>0 And g.CantidadLineas=2 And g.Subtotal=CCur(1.2499) And g.Numero=0
    f.QuitarLinea 999999
    f.Emitir numero
    repo.Guardar f
    g = repo.Obtener(id)
    Informar texto,"Número emitido único y siguiente sin colisión",g.Numero=numero And repo.SiguienteNumero()=numero+1
    f.RegistrarPago
    repo.Guardar f
    g = repo.Obtener(id)
    Informar texto,"Guarda pago con líneas reordenadas e identidad estable",g.Estado=ESTADO_PAGADA And g.IdFactura=id And g.Numero=numero
    f = NuevaFactura()
    f.AgregarLinea 999999,"No existe",1,10
    fallo = CapturarGuardar(repo,f)
    Informar texto,"Revierte alta y no asigna identidad al objeto",fallo<>0 And f.IdFactura=0 And cn.getAutoCommit()
    f = NuevaFactura()
    f.AgregarLinea 11,"Papel",1,119
    f.Emitir numero
    fallo = CapturarGuardar(repo,f)
    Informar texto,"UNIQUE rechaza número repetido y revierte alta",fallo<>0 And f.IdFactura=0 And cn.getAutoCommit()
    LimpiarPrueba cn,id
    id = 0
    ProbarRepositorio = texto
    If mostrar Then MsgBox texto,64,"Pruebas de repositorio"
    Exit Function
Falla:
    fallo = Err.Number
    descripcionError = Err.Description
    On Error Resume Next
    If id <> 0 Then LimpiarPrueba cn,id
    On Error GoTo 0
    Err.Raise fallo, "PruebasRepositorio", descripcionError
End Function
Private Function CapturarGuardar(ByVal repo As clsRepositorioFacturas, ByVal f As clsFactura) As Long
    On Error GoTo Rechazo
    repo.Guardar f
    Exit Function
Rechazo:
    CapturarGuardar = Err.Number
    Resume Fin
Fin:
End Function
Private Function CapturarObtener(ByVal repo As clsRepositorioFacturas, ByVal id As Long) As Long
    Dim f As clsFactura
    On Error GoTo Rechazo
    f = repo.Obtener(id)
    Exit Function
Rechazo:
    CapturarObtener = Err.Number
    Resume Fin
Fin:
End Function
Private Sub LimpiarPrueba(ByVal cn As Object, ByVal id As Long)
    Dim q As Object
    q = cn.prepareStatement("DELETE FROM ""tblFacturas"" WHERE ""IdFactura""=?")
    q.setInt(1,id): q.executeUpdate(): q.close()
End Sub

Public Sub EmitirDesdeFormulario(ByVal oEvento As Object)
    Dim oForm As Object, detalle As Object, repo As clsRepositorioFacturas, f As clsFactura, id As Long, codigo As Long, descripcionError As String
    On Error GoTo Falla
    oForm = oEvento.Source.Model.Parent
    If oForm.IsModified Then
        If oForm.IsNew Then
            oForm.insertRow()
        Else
            oForm.updateRow()
        End If
    End If
    ' La línea activa puede tener cambios todavía no escritos en el subformulario.
    ' Guardarla antes de leer el agregado; cualquier rechazo aborta la emisión.
    detalle = oForm.getByName("sfDetalle")
    If detalle.IsModified Then
        If detalle.IsNew Then
            detalle.insertRow()
        Else
            detalle.updateRow()
        End If
    End If
    id = oForm.getInt(oForm.findColumn("IdFactura"))
    repo = New clsRepositorioFacturas
    repo.Inicializar ConexionBase()
    f = repo.Obtener(id)
    f.Emitir repo.SiguienteNumero()
    repo.Guardar f
    oForm.reload()
    BloquearFormulario oForm
    MsgBox "Factura " & f.Numero & " emitida.",64,"Emisión"
    Exit Sub
Falla:
    codigo = Err.Number
    descripcionError = Err.Description
    If descripcionError="" Then descripcionError=MensajeError(codigo)
    MsgBox descripcionError,48,"Emisión rechazada"
End Sub

Public Sub EjecutarFactura()
    Dim resultado As String
    resultado = ProbarFactura()
End Sub
Public Sub EjecutarPruebas()
    Dim resultado As String
    resultado = ProbarReglas()
End Sub
Public Sub EjecutarRepositorio()
    Dim resultado As String
    resultado = ProbarRepositorio()
End Sub

' Asociar al evento Después del cambio de registro del formulario principal fFactura.
' Source del evento es el formulario (no un control de texto ni el botón).
Public Sub AplicarBloqueoFactura(ByVal oEvento As Object)
    BloquearFormulario oEvento.Source
End Sub
Private Sub BloquearFormulario(ByVal oForm As Object)
    Dim detalle As Object, borrador As Boolean
    If oForm.IsNew Then
        borrador = True
    Else
        borrador = (oForm.getString(oForm.findColumn("Estado"))=ESTADO_BORRADOR)
    End If
    oForm.AllowUpdates = borrador
    oForm.AllowDeletes = borrador
    oForm.AllowInserts = True
    detalle = oForm.getByName("sfDetalle")
    detalle.AllowUpdates = borrador
    detalle.AllowInserts = borrador
    detalle.AllowDeletes = borrador
End Sub
