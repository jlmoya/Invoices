Option Explicit
Option VBASupport 1

Public Function ProbarDescuentos(Optional ByVal mostrar As Boolean = True) As String
    Dim d As Object, p As clsDescuentoPorcentaje, texto As String
    d = New clsSinDescuento
    texto = d.Descripcion() & ": " & d.Calcular(1000) & Chr(10)
    p = New clsDescuentoPorcentaje
    p.Inicializar 0.1
    d = p
    texto = texto & d.Descripcion() & ": " & d.Calcular(1000)
    ProbarDescuentos = texto
    If mostrar Then MsgBox texto, 64, "Polimorfismo"
End Function

Public Sub EjecutarDescuentos()
    Dim resultado As String
    resultado = ProbarDescuentos()
End Sub
