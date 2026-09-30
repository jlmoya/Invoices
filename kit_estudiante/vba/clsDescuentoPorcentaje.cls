VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "clsDescuentoPorcentaje"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Compare Database
Option Explicit
Implements IDescuento

Private mPorcentaje As Double

Public Sub Inicializar(ByVal porcentaje As Double)
    If porcentaje < 0 Or porcentaje > 1 Then Err.Raise vbObjectError + 4001, _
        "DescuentoPorcentaje", "El porcentaje debe estar entre 0 y 1."
    mPorcentaje = porcentaje
End Sub

Private Function IDescuento_Calcular(ByVal subtotal As Currency) As Currency
    IDescuento_Calcular = CCur(Round(subtotal * mPorcentaje, 2))
End Function

Private Function IDescuento_Descripcion() As String
    IDescuento_Descripcion = "Descuento del " & Format(mPorcentaje, "0%")
End Function
