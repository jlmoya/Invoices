Option Explicit
Option VBASupport 1

' CONTRATO DOCUMENTADO. No es una interfaz de VBA ni una clase instanciable.
' Un objeto descuento debe ofrecer estos dos métodos públicos:
'   Calcular(subtotal As Currency) As Currency
'   Descripcion() As String
' El consumidor usa una variable As Object y llama los mismos métodos.
' clsSinDescuento y clsDescuentoPorcentaje cumplen este contrato.
' Basic verifica que existen al ejecutarlos: no hay Implements ni control estático.
