Option Explicit
Option VBASupport 1

' SOLO INSTRUCTOR. Subir hasta la raíz con detección de nodos inexistentes y ciclos.
Public Function Profundidad(ByVal idCategoria As Long, Optional ByVal conexion As Variant) As Integer
    Dim ruta As String, niveles As Integer
    ruta = SubirCategorias(idCategoria,ConexionBase(conexion),niveles)
    Profundidad = niveles
End Function
Public Function RutaCategoria(ByVal idCategoria As Long, Optional ByVal conexion As Variant) As String
    Dim niveles As Integer
    RutaCategoria = SubirCategorias(idCategoria,ConexionBase(conexion),niveles)
End Function
Private Function SubirCategorias(ByVal idCategoria As Long, ByVal cn As Object, _
                                 ByRef niveles As Integer) As String
    Dim pila As Collection, visitados As Object, q As Object, rs As Object
    Dim actual As Long, padre As Long, raiz As Boolean, texto As String
    pila = New Collection
    GlobalScope.BasicLibraries.loadLibrary("ScriptForge")
    visitados = CreateScriptService("Dictionary",True)
    actual = idCategoria
    Do
        If visitados.Exists(CStr(actual)) Then Err.Raise 6003, "Curso", MensajeError(6003)
        visitados.Add CStr(actual),True
        q = cn.prepareStatement("SELECT ""Nombre"",""IdCategoriaPadre"" FROM ""tblCategorias"" WHERE ""IdCategoria""=?")
        q.setInt(1,actual)
        rs = q.executeQuery()
        If Not rs.next() Then Err.Raise 6004, "Curso", MensajeError(6004)
        pila.Add rs.getString(1)
        padre = rs.getInt(2)
        raiz = rs.wasNull()
        rs.close(): q.close()
        If raiz Then Exit Do
        actual = padre
    Loop
    niveles = pila.Count - 1
    Do While pila.Count > 0
        If Len(texto)>0 Then texto = texto & " > "
        texto = texto & pila.Item(pila.Count)
        pila.Remove pila.Count
    Loop
    visitados.Dispose()
    SubirCategorias = texto
End Function
Public Function ProbarTarea6(Optional ByVal conexion As Variant, _
                            Optional ByVal mostrar As Boolean = True) As String
    Dim texto As String
    texto = "1: " & Profundidad(1,conexion) & " | " & RutaCategoria(1,conexion) & Chr(10) & _
            "6: " & Profundidad(6,conexion) & " | " & RutaCategoria(6,conexion) & Chr(10) & _
            "8: " & Profundidad(8,conexion) & " | " & RutaCategoria(8,conexion)
    ProbarTarea6 = texto
    If mostrar Then MsgBox texto,64,"Tarea 6"
End Function
Public Sub EjecutarTarea6()
    Dim resultado As String
    resultado = ProbarTarea6()
End Sub
