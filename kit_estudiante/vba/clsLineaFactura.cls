VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "clsLineaFactura"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

' Una línea de factura: un producto, su cantidad y el precio pactado.
' Es inmutable: sus datos se fijan en Inicializar y después solo se leen.

Private mIdProducto As Long
Private mDescripcion As String
Private mCantidad As Long
Private mPrecioUnitario As Currency

' VBA no admite constructores con parámetros: este método cumple ese papel.
Public Sub Inicializar(ByVal idProducto As Long, ByVal descripcion As String, _
                       ByVal cantidad As Long, ByVal precioUnitario As Currency)
    If cantidad <= 0 Then Err.Raise vbObjectError + 1001, "LineaFactura", _
        "La cantidad debe ser mayor que cero."
    If precioUnitario < 0 Then Err.Raise vbObjectError + 1002, "LineaFactura", _
        "El precio no puede ser negativo."
    mIdProducto = idProducto
    mDescripcion = descripcion
    mCantidad = cantidad
    mPrecioUnitario = precioUnitario
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

' Experto en información: la línea calcula su propio importe.
Public Property Get Importe() As Currency
    Importe = mCantidad * mPrecioUnitario
End Property
