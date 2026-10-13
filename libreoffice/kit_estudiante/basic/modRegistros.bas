Option Explicit
Option VBASupport 1

Public Type TProducto
    Codigo As String
    Descripcion As String
    Precio As Currency
End Type

Public Function DemoRegistro(Optional ByVal mostrar As Boolean = True) As String
    Dim p As TProducto
    p.Codigo = "PAP-001"
    p.Descripcion = "Resma de papel carta 500 hojas"
    p.Precio = 119
    DemoRegistro = p.Codigo & " | " & p.Descripcion & " | " & p.Precio
    If mostrar Then MsgBox DemoRegistro, 64, "Registro"
End Function

Public Function BuscarLineal(catalogo() As TProducto, ByVal codigo As String, _
                             ByRef pasos As Long) As Long
    Dim i As Long
    pasos = 0
    For i = LBound(catalogo) To UBound(catalogo)
        pasos = pasos + 1
        If catalogo(i).Codigo = codigo Then
            BuscarLineal = i
            Exit Function
        End If
    Next i
    BuscarLineal = -1
End Function

' Precondición: catálogo ordenado de menor a mayor por Codigo.
Public Function BuscarBinaria(catalogo() As TProducto, ByVal codigo As String, _
                              ByRef pasos As Long) As Long
    Dim bajo As Long, alto As Long, medio As Long
    pasos = 0
    bajo = LBound(catalogo)
    alto = UBound(catalogo)
    Do While bajo <= alto
        medio = (bajo + alto) \ 2
        pasos = pasos + 1
        If catalogo(medio).Codigo = codigo Then
            BuscarBinaria = medio
            Exit Function
        ElseIf catalogo(medio).Codigo < codigo Then
            bajo = medio + 1
        Else
            alto = medio - 1
        End If
    Loop
    BuscarBinaria = -1
End Function

Public Function CompararBusquedas(Optional ByVal n As Long = 100000, _
                                  Optional ByVal mostrar As Boolean = True) As String
    Dim catalogo() As TProducto
    Dim i As Long, pos As Long, pasos As Long, buscado As String, texto As String
    If n < 1 Then Err.Raise 4201, "Curso", MensajeError(4201)
    ReDim catalogo(1 To n)
    For i = 1 To n
        catalogo(i).Codigo = "P" & Format(i, "0000000")
        catalogo(i).Descripcion = "Producto"
        catalogo(i).Precio = 10 + (i Mod 500)
    Next i
    buscado = catalogo(n).Codigo
    texto = "n = " & n & Chr(10)
    pos = BuscarLineal(catalogo(), buscado, pasos)
    texto = texto & "Lineal: posición " & pos & " en " & pasos & " pasos" & Chr(10)
    pos = BuscarBinaria(catalogo(), buscado, pasos)
    texto = texto & "Binaria: posición " & pos & " en " & pasos & " pasos"
    CompararBusquedas = texto
    If mostrar Then MsgBox texto, 64, "Búsquedas"
End Function

Public Function DemoPrecision(Optional ByVal mostrar As Boolean = True) As String
    Dim exacto As Currency
    exacto = CCur(0.1) + CCur(0.2)
    DemoPrecision = "Currency 0.1 + 0.2 = " & Format(exacto, "0.0000") & Chr(10) & _
                    "HALF_UP 1.005 = " & Format(RedondearMoneda(CCur(1.005)), "0.00")
    If mostrar Then MsgBox DemoPrecision, 64, "Precisión monetaria"
End Function

Public Sub EjecutarRegistro()
    Dim resultado As String
    resultado = DemoRegistro()
End Sub
Public Sub EjecutarBusquedas()
    Dim resultado As String
    resultado = CompararBusquedas()
End Sub
Public Sub EjecutarPrecision()
    Dim resultado As String
    resultado = DemoPrecision()
End Sub
