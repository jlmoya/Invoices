Attribute VB_Name = "modSolucionesTareas"
Option Compare Database
Option Explicit

' SOLO INSTRUCTOR. Soluciones de referencia de la tarea 6.

' Profundidad de una categoría: sube por los padres hasta la raíz (Catálogo = 0).
Public Function Profundidad(ByVal idCategoria As Long) As Integer
    Dim nivel As Integer, padre As Variant
    padre = DLookup("IdCategoriaPadre", "tblCategorias", "IdCategoria = " & idCategoria)
    Do While Not IsNull(padre)
        nivel = nivel + 1
        padre = DLookup("IdCategoriaPadre", "tblCategorias", "IdCategoria = " & padre)
    Loop
    Profundidad = nivel
End Function

' Ruta completa desde la raíz, usando una Collection como pila.
Public Function RutaCategoria(ByVal idCategoria As Long) As String
    Dim pila As New Collection, actual As Variant, ruta As String
    actual = idCategoria
    Do While Not IsNull(actual)                                     ' apilar al subir
        pila.Add DLookup("Nombre", "tblCategorias", "IdCategoria = " & actual)
        actual = DLookup("IdCategoriaPadre", "tblCategorias", "IdCategoria = " & actual)
    Loop
    Do While pila.Count > 0                                         ' desapilar: raíz a hoja
        If Len(ruta) > 0 Then ruta = ruta & " > "
        ruta = ruta & pila(pila.Count)
        pila.Remove pila.Count
    Loop
    RutaCategoria = ruta
End Function

' Prueba rápida: Catálogo tiene profundidad 0 y Portátiles, 3.
Public Sub ProbarTarea6()
    Debug.Print Profundidad(1), RutaCategoria(1)
    Debug.Print Profundidad(6), RutaCategoria(6)
    Debug.Print Profundidad(8), RutaCategoria(8)
End Sub
