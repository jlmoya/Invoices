Option Explicit
Option VBASupport 1
Option ClassModule

Public Function Calcular(ByVal subtotal As Currency) As Currency
    If subtotal < 0 Then Err.Raise 4101, "Curso", MensajeError(4101)
    Calcular = 0
End Function
Public Function Descripcion() As String
    Descripcion = "Sin descuento"
End Function
