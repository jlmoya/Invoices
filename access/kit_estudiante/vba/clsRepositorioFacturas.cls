VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "clsRepositorioFacturas"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

' Traduce entre objetos clsFactura y las tablas tblFacturas y tblDetalleFactura.
' La factura no sabe SQL: esta clase se encarga de guardarla (alta cohesión).

' Arma un objeto factura a partir de la base de datos.
Public Function Obtener(ByVal idFactura As Long) As clsFactura
    Dim db As DAO.Database, rsF As DAO.Recordset, rsL As DAO.Recordset
    Dim f As clsFactura
    Set db = CurrentDb
    Set rsF = db.OpenRecordset("SELECT * FROM tblFacturas WHERE IdFactura = " & idFactura, _
                               dbOpenSnapshot)
    If rsF.EOF Then
        rsF.Close
        Err.Raise vbObjectError + 3001, "RepositorioFacturas", _
            "No existe la factura " & idFactura & "."
    End If
    Set f = New clsFactura
    ' 1) Reconstruye las líneas mientras el objeto todavía es un borrador...
    Set rsL = db.OpenRecordset( _
        "SELECT d.IdProducto, p.Descripcion, d.Cantidad, d.PrecioUnitario " & _
        "FROM tblDetalleFactura AS d INNER JOIN tblProductos AS p " & _
        "ON d.IdProducto = p.IdProducto WHERE d.IdFactura = " & idFactura & _
        " ORDER BY p.Descripcion", dbOpenSnapshot)
    Do Until rsL.EOF
        f.AgregarLinea rsL!IdProducto, rsL!Descripcion, rsL!Cantidad, rsL!PrecioUnitario
        rsL.MoveNext
    Loop
    rsL.Close
    ' 2) ...y al final restaura el estado guardado.
    f.Cargar rsF!IdFactura, Nz(rsF!NumeroFactura, 0), rsF!Fecha, rsF!IdCliente, _
             Nz(rsF!TasaImpuesto, 0), rsF!Estado
    rsF.Close
    Set Obtener = f
End Function

' Escribe la factura y sus líneas en una transacción: todo o nada.
Public Sub Guardar(ByVal f As clsFactura)
    Dim ws As DAO.Workspace, db As DAO.Database, rs As DAO.Recordset
    Dim id As Long, i As Long, enTransaccion As Boolean
    Dim numError As Long, descError As String
    On Error GoTo Falla
    Set ws = DBEngine.Workspaces(0)
    Set db = CurrentDb
    ws.BeginTrans
    enTransaccion = True
    If f.IdFactura = 0 Then
        Set rs = db.OpenRecordset("tblFacturas", dbOpenDynaset)
        rs.AddNew
    Else
        Set rs = db.OpenRecordset("SELECT * FROM tblFacturas WHERE IdFactura = " & _
                                  f.IdFactura, dbOpenDynaset)
        If rs.EOF Then Err.Raise vbObjectError + 3001, "RepositorioFacturas", _
            "No existe la factura " & f.IdFactura & "."
        rs.Edit
    End If
    rs!Fecha = f.Fecha
    rs!IdCliente = f.IdCliente
    rs!TasaImpuesto = f.TasaImpuesto
    rs!Estado = f.Estado
    If f.Numero = 0 Then
        rs!NumeroFactura = Null
    Else
        rs!NumeroFactura = f.Numero
    End If
    rs.Update
    rs.Bookmark = rs.LastModified
    id = rs!IdFactura
    rs.Close
    ' Las líneas se reescriben completas: la factura es dueña de ellas (composición).
    db.Execute "DELETE FROM tblDetalleFactura WHERE IdFactura = " & id, dbFailOnError
    Set rs = db.OpenRecordset("tblDetalleFactura", dbOpenDynaset)
    For i = 1 To f.CantidadLineas
        rs.AddNew
        rs!IdFactura = id
        rs!IdProducto = f.Linea(i).IdProducto
        rs!Cantidad = f.Linea(i).Cantidad
        rs!PrecioUnitario = f.Linea(i).PrecioUnitario
        rs.Update
    Next i
    rs.Close
    ws.CommitTrans
    enTransaccion = False
    f.AsignarId id
    Exit Sub
Falla:
    numError = Err.Number
    descError = Err.Description
    If enTransaccion Then ws.Rollback
    Err.Raise numError, "RepositorioFacturas", descError
End Sub

' El siguiente número consecutivo. Parte de 1000 si todavía no hay facturas emitidas.
Public Function SiguienteNumero() As Long
    SiguienteNumero = Nz(DMax("NumeroFactura", "tblFacturas"), 1000) + 1
End Function
