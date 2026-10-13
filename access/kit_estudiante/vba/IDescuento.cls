VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "IDescuento"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

' Interfaz: solo declara los métodos. Cada clase que la implementa decide cómo calcular.

' Devuelve el monto a descontar para un subtotal dado.
Public Function Calcular(ByVal subtotal As Currency) As Currency
End Function

' Describe el descuento en palabras.
Public Function Descripcion() As String
End Function
