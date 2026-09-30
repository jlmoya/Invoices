VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "clsSinDescuento"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Compare Database
Option Explicit
Implements IDescuento

Private Function IDescuento_Calcular(ByVal subtotal As Currency) As Currency
    IDescuento_Calcular = 0
End Function

Private Function IDescuento_Descripcion() As String
    IDescuento_Descripcion = "Sin descuento"
End Function
