' Crear este módulo con el nombre clsFactura, NO clsFactura_plantilla.
Option Explicit
Option VBASupport 1
Option ClassModule

Private mIdFactura As Long
Private mNumero As Long
Private mFecha As Date
Private mIdCliente As Long
Private mTasaImpuesto As Currency
Private mEstado As String
Private mLineas As Collection

Private Sub Class_Initialize()
    mLineas = New Collection
    mEstado = ESTADO_BORRADOR
    mFecha = Date
End Sub

Public Property Get IdFactura() As Long
    IdFactura = mIdFactura
End Property
Public Property Get Numero() As Long
    Numero = mNumero
End Property
Public Property Get Fecha() As Date
    Fecha = mFecha
End Property
Public Property Get Estado() As String
    Estado = mEstado
End Property
Public Property Get IdCliente() As Long
    IdCliente = mIdCliente
End Property
Public Property Let IdCliente(ByVal valor As Long)
    ExigirBorrador
    If valor <= 0 Then Err.Raise 2001, "Curso", MensajeError(2001)
    mIdCliente = valor
End Property
Public Property Get TasaImpuesto() As Double
    TasaImpuesto = mTasaImpuesto
End Property
Public Property Let TasaImpuesto(ByVal valor As Double)
    ExigirBorrador
    If valor < 0 Or valor > 1 Then Err.Raise 2002, "Curso", MensajeError(2002)
    mTasaImpuesto = CCur(valor)
End Property
Public Property Get CantidadLineas() As Long
    CantidadLineas = mLineas.Count
End Property
Public Function Linea(ByVal indice As Long) As clsLineaFactura
    Linea = mLineas.Item(indice)
End Function

Public Sub AgregarLinea(ByVal idProducto As Long, ByVal descripcion As String, _
                        ByVal cantidad As Long, ByVal precioUnitario As Currency)
    Dim nueva As clsLineaFactura
    ExigirBorrador
    If ExisteLinea(idProducto) Then Err.Raise 2003, "Curso", MensajeError(2003)
    nueva = New clsLineaFactura
    nueva.Inicializar idProducto, descripcion, cantidad, precioUnitario
    mLineas.Add nueva, CStr(idProducto)
End Sub
Public Sub QuitarLinea(ByVal idProducto As Long)
    ExigirBorrador
    If Not ExisteLinea(idProducto) Then Err.Raise 2008, "Curso", MensajeError(2008)
    mLineas.Remove CStr(idProducto)
End Sub

Public Property Get Subtotal() As Currency
    ' TODO 1: recorrer mLineas con For Each y sumar el Importe (Currency).
    Subtotal = 0
End Property
Public Property Get Impuesto() As Currency
    Impuesto = CalcularPorcentajeMoneda(Subtotal,mTasaImpuesto)
End Property
Public Property Get Total() As Currency
    Total = Subtotal + Impuesto
End Property

Public Sub Emitir(ByVal numeroAsignado As Long)
    ExigirBorrador
    ' TODO 2: rechazar cliente ausente (2004) y cero líneas (2005) con Err.Raise.
    If numeroAsignado <= 0 Then Err.Raise 2010, "Curso", MensajeError(2010)
    mNumero = numeroAsignado
    mFecha = Date
    mEstado = ESTADO_EMITIDA
End Sub
Public Sub RegistrarPago()
    If mEstado <> ESTADO_EMITIDA Then Err.Raise 2006, "Curso", MensajeError(2006)
    mEstado = ESTADO_PAGADA
End Sub
Public Sub Anular()
    ' TODO 3: exigir ESTADO_EMITIDA (Err.Raise 2007) y cambiar a ESTADO_ANULADA.
End Sub

Private Sub ExigirBorrador()
    If mEstado <> ESTADO_BORRADOR Then Err.Raise 2009, "Curso", MensajeError(2009)
End Sub
Private Function ExisteLinea(ByVal idProducto As Long) As Boolean
    Dim l As Variant
    For Each l In mLineas
        If l.IdProducto = idProducto Then
            ExisteLinea = True
            Exit Function
        End If
    Next l
End Function

' Basic no dispone de Friend. Estos métodos son públicos por necesidad técnica;
' pertenecen al protocolo de reconstrucción del repositorio, no a la interfaz de negocio.
Public Sub Cargar(ByVal idFactura As Long, ByVal numero As Long, ByVal fecha As Date, _
                  ByVal idCliente As Long, ByVal tasa As Double, ByVal estado As String)
    If mIdFactura <> 0 Or mEstado <> ESTADO_BORRADOR Or mNumero <> 0 Then Err.Raise 3010, "Curso", MensajeError(3010)
    If idFactura <= 0 Or idCliente <= 0 Or tasa < 0 Or tasa > 1 Then Err.Raise 3010, "Curso", MensajeError(3010)
    If estado <> ESTADO_BORRADOR And estado <> ESTADO_EMITIDA And _
       estado <> ESTADO_PAGADA And estado <> ESTADO_ANULADA Then Err.Raise 3010, "Curso", MensajeError(3010)
    If estado = ESTADO_BORRADOR Then
        If numero <> 0 Then Err.Raise 3010, "Curso", MensajeError(3010)
    Else
        If numero <= 0 Or mLineas.Count = 0 Then Err.Raise 3010, "Curso", MensajeError(3010)
    End If
    mIdFactura = idFactura
    mNumero = numero
    mFecha = fecha
    mIdCliente = idCliente
    mTasaImpuesto = CCur(tasa)
    mEstado = estado
End Sub
Public Sub AsignarId(ByVal idFactura As Long)
    If idFactura <= 0 Then Err.Raise 3010, "Curso", MensajeError(3010)
    If mIdFactura <> 0 And mIdFactura <> idFactura Then Err.Raise 3010, "Curso", MensajeError(3010)
    mIdFactura = idFactura
End Sub
