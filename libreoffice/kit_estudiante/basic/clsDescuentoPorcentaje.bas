Option Explicit
Option VBASupport 1
Option ClassModule

Private mPorcentaje As Currency
Public Sub Inicializar(ByVal porcentaje As Double)
    If porcentaje < 0 Or porcentaje > 1 Then Err.Raise 4001, "Curso", MensajeError(4001)
    mPorcentaje = CCur(porcentaje)
End Sub
Public Function Calcular(ByVal subtotal As Currency) As Currency
    Calcular = CalcularPorcentajeMoneda(subtotal,mPorcentaje)
End Function
Public Function Descripcion() As String
    Descripcion = "Descuento del " & Format(mPorcentaje, "0%")
End Function
