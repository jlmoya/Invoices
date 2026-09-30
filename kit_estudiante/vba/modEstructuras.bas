Attribute VB_Name = "modEstructuras"
Option Compare Database
Option Explicit

' Laboratorio 6: cola, pila, árbol y diccionario sobre las tablas del sistema.

' ===================== COLA (FIFO): cobranza =====================
' La cola son las facturas emitidas pendientes de pago. El número de factura
' se asigna en orden de emisión: el menor número pendiente es el frente.

' Muestra la cola en la ventana Inmediato, del frente al final.
Public Sub VerColaCobranza()
    Dim db As DAO.Database, rs As DAO.Recordset
    Set db = CurrentDb
    Set rs = db.OpenRecordset( _
        "SELECT NumeroFactura, Fecha FROM tblFacturas " & _
        "WHERE Estado = 'Emitida' ORDER BY NumeroFactura", dbOpenSnapshot)
    If rs.EOF Then Debug.Print "(la cola está vacía)"
    Do Until rs.EOF
        Debug.Print rs!NumeroFactura, rs!Fecha
        rs.MoveNext
    Loop
    rs.Close
End Sub

' Desencolar: atiende la factura del frente y la marca como pagada.
' Devuelve el número atendido, o 0 si la cola está vacía.
Public Function AtenderSiguienteCobro() As Long
    Dim db As DAO.Database, rs As DAO.Recordset
    Set db = CurrentDb
    Set rs = db.OpenRecordset( _
        "SELECT TOP 1 IdFactura, NumeroFactura FROM tblFacturas " & _
        "WHERE Estado = 'Emitida' ORDER BY NumeroFactura", dbOpenSnapshot)
    If Not rs.EOF Then
        db.Execute "UPDATE tblFacturas SET Estado = 'Pagada' " & _
                   "WHERE IdFactura = " & rs!IdFactura, dbFailOnError
        AtenderSiguienteCobro = rs!NumeroFactura
    End If
    rs.Close
End Function

' ===================== PILA (LIFO): cambios de precio =====================

' Apilar: guarda el precio actual en la pila y aplica el nuevo precio.
Public Sub CambiarPrecio(ByVal idProducto As Long, ByVal nuevoPrecio As Currency)
    Dim db As DAO.Database, qd As DAO.QueryDef
    If nuevoPrecio < 0 Then Err.Raise vbObjectError + 600, "CambiarPrecio", _
        "El precio no puede ser negativo."
    Set db = CurrentDb
    Set qd = db.CreateQueryDef("", _
        "PARAMETERS pId Long; " & _
        "INSERT INTO tblHistorialPrecios (IdProducto, PrecioAnterior, FechaCambio) " & _
        "SELECT IdProducto, Precio, Now() FROM tblProductos WHERE IdProducto = pId")
    qd.Parameters("pId") = idProducto
    qd.Execute dbFailOnError
    If qd.RecordsAffected = 0 Then Err.Raise vbObjectError + 601, "CambiarPrecio", _
        "No existe el producto " & idProducto & "."
    ActualizarPrecio idProducto, nuevoPrecio
End Sub

' Desapilar: deshace el cambio más reciente del producto.
' Devuelve False si la pila de ese producto está vacía.
Public Function DeshacerUltimoCambio(ByVal idProducto As Long) As Boolean
    Dim db As DAO.Database, rs As DAO.Recordset
    Set db = CurrentDb
    Set rs = db.OpenRecordset( _
        "SELECT TOP 1 IdCambio, PrecioAnterior FROM tblHistorialPrecios " & _
        "WHERE IdProducto = " & idProducto & " ORDER BY IdCambio DESC", dbOpenSnapshot)
    If rs.EOF Then
        rs.Close
        Exit Function
    End If
    ActualizarPrecio idProducto, rs!PrecioAnterior
    db.Execute "DELETE FROM tblHistorialPrecios WHERE IdCambio = " & rs!IdCambio, dbFailOnError
    rs.Close
    DeshacerUltimoCambio = True
End Function

' Cambia el precio con una consulta con parámetros, sin pegar números en el texto SQL:
' así no importa si la configuración regional usa coma decimal.
Private Sub ActualizarPrecio(ByVal idProducto As Long, ByVal precio As Currency)
    Dim db As DAO.Database, qd As DAO.QueryDef
    Set db = CurrentDb
    Set qd = db.CreateQueryDef("", _
        "PARAMETERS pId Long, pPrecio Currency; " & _
        "UPDATE tblProductos SET Precio = pPrecio WHERE IdProducto = pId")
    qd.Parameters("pId") = idProducto
    qd.Parameters("pPrecio") = precio
    qd.Execute dbFailOnError
End Sub

' ===================== ÁRBOL: categorías =====================

' Recorrido en preorden: primero el nodo y después, recursivamente, sus hijos.
Public Sub ImprimirArbol(Optional ByVal idPadre As Long = 0, _
                         Optional ByVal nivel As Integer = 0)
    Dim rs As DAO.Recordset, filtro As String
    If idPadre = 0 Then
        filtro = "IdCategoriaPadre Is Null"           ' la raíz no tiene padre
    Else
        filtro = "IdCategoriaPadre = " & idPadre
    End If
    Set rs = CurrentDb.OpenRecordset("SELECT IdCategoria, Nombre FROM tblCategorias " & _
                                     "WHERE " & filtro & " ORDER BY Nombre", dbOpenSnapshot)
    Do Until rs.EOF
        Debug.Print String(nivel * 4, " ") & "- " & rs!Nombre   ' visita el nodo...
        ImprimirArbol rs!IdCategoria, nivel + 1                 ' ...y luego a sus hijos
        rs.MoveNext
    Loop
    rs.Close
End Sub

' ===================== DICCIONARIO: unidades por producto =====================
' Scripting.Dictionary es una tabla hash: pares clave -> valor con acceso casi constante.
Public Sub UnidadesPorProducto()
    Dim dic As Object, rs As DAO.Recordset, clave As Variant
    Set dic = CreateObject("Scripting.Dictionary")
    Set rs = CurrentDb.OpenRecordset( _
        "SELECT p.Codigo, d.Cantidad FROM tblDetalleFactura AS d " & _
        "INNER JOIN tblProductos AS p ON d.IdProducto = p.IdProducto", dbOpenSnapshot)
    Do Until rs.EOF
        clave = rs!Codigo.Value                  ' .Value: la clave es el texto, no el campo
        If dic.Exists(clave) Then
            dic(clave) = dic(clave) + rs!Cantidad.Value
        Else
            dic.Add clave, rs!Cantidad.Value
        End If
        rs.MoveNext
    Loop
    rs.Close
    For Each clave In dic.Keys
        Debug.Print clave, dic(clave)
    Next clave
End Sub
