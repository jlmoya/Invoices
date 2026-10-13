Attribute VB_Name = "modPolimorfismo"
Option Compare Database
Option Explicit

' Polimorfismo: la misma variable de tipo IDescuento se comporta distinto
' según el objeto concreto que contiene.
Public Sub ProbarDescuentos()
    Dim d As IDescuento, p As clsDescuentoPorcentaje
    Set d = New clsSinDescuento
    Debug.Print d.Descripcion, d.Calcular(1000)          ' Sin descuento   0
    Set p = New clsDescuentoPorcentaje
    p.Inicializar 0.1
    Set d = p                                            ' la misma variable, otro comportamiento
    Debug.Print d.Descripcion, d.Calcular(1000)          ' Descuento del 10%   100
End Sub
