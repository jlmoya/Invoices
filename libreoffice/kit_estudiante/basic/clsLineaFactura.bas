Option Explicit
Option VBASupport 1
Option ClassModule

Private mIdProducto As Long
Private mDescripcion As String
Private mCantidad As Long
Private mPrecioUnitario As Currency
Private mInicializada As Boolean

' Inmutable: la inicialización se permite una sola vez.
Public Sub Inicializar(ByVal idProducto As Long, ByVal descripcion As String, _
                       ByVal cantidad As Long, ByVal precioUnitario As Currency)
    If mInicializada Then Err.Raise 2103, "Curso", MensajeError(2103)
    If idProducto <= 0 Then Err.Raise 2100, "Curso", MensajeError(2100)
    If cantidad <= 0 Then Err.Raise 2101, "Curso", MensajeError(2101)
    If precioUnitario < 0 Then Err.Raise 2102, "Curso", MensajeError(2102)
    mIdProducto = idProducto
    mDescripcion = descripcion
    mCantidad = cantidad
    mPrecioUnitario = precioUnitario
    mInicializada = True
End Sub

Public Property Get IdProducto() As Long
    IdProducto = mIdProducto
End Property
Public Property Get Descripcion() As String
    Descripcion = mDescripcion
End Property
Public Property Get Cantidad() As Long
    Cantidad = mCantidad
End Property
Public Property Get PrecioUnitario() As Currency
    PrecioUnitario = mPrecioUnitario
End Property
Public Property Get Importe() As Currency
    Importe = mCantidad * mPrecioUnitario
End Property
