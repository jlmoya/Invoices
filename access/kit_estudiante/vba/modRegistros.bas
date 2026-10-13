Attribute VB_Name = "modRegistros"
Option Compare Database
Option Explicit

' Laboratorio 2: registros (Type), arreglos de registros y dos formas de buscar.

' Un registro agrupa los datos de un producto, como un struct en C.
Public Type TProducto
    Codigo As String
    Descripcion As String
    Precio As Currency
End Type

' Crea un registro, lo llena y lo muestra en la ventana Inmediato.
Public Sub DemoRegistro()
    Dim p As TProducto
    p.Codigo = "PAP-001"
    p.Descripcion = "Resma de papel carta 500 hojas"
    p.Precio = 119
    Debug.Print p.Codigo, p.Descripcion, p.Precio
End Sub

' Búsqueda lineal: revisa los elementos uno por uno.
' Devuelve la posición encontrada o -1; "pasos" cuenta las comparaciones.
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

' Búsqueda binaria: exige que el arreglo esté ORDENADO por código.
' En cada paso descarta la mitad de los candidatos.
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

' Genera n productos con códigos ordenados y compara las dos búsquedas
' buscando el último código, el peor caso para la búsqueda lineal.
Public Sub CompararBusquedas(Optional ByVal n As Long = 100000)
    Dim catalogo() As TProducto
    Dim i As Long, pos As Long, pasos As Long
    Dim buscado As String
    If n < 1 Then Exit Sub
    ReDim catalogo(1 To n)
    For i = 1 To n
        catalogo(i).Codigo = "P" & Format(i, "0000000")
        catalogo(i).Descripcion = "Producto"
        catalogo(i).Precio = 10 + (i Mod 500)
    Next i
    buscado = catalogo(n).Codigo
    Debug.Print "n = "; n
    pos = BuscarLineal(catalogo, buscado, pasos)
    Debug.Print "  Lineal:  posición "; pos; " en "; pasos; " pasos"
    pos = BuscarBinaria(catalogo, buscado, pasos)
    Debug.Print "  Binaria: posición "; pos; " en "; pasos; " pasos"
End Sub
