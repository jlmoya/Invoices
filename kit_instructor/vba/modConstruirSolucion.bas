Attribute VB_Name = "modConstruirSolucion"
Option Compare Database
Option Explicit

' SOLO INSTRUCTOR. Construye la base de solución: tablas, índices, reglas, relaciones,
' datos de ejemplo y consultas, en el estado previo a la parte B del laboratorio 6.
' Úsalo en una base NUEVA y vacía. En la ventana Inmediato escribe:  ConstruirSolucion
' Los formularios y el informe se construyen a mano con el laboratorio 5.
' Todo el SQL de este módulo usa la sintaxis del motor (inglés), así que funciona
' igual con Access en español o en inglés.

Public Sub ConstruirSolucion()
    Dim db As DAO.Database
    Set db = CurrentDb
    BorrarObjetos db
    CrearTablas db
    ConfigurarCampos db
    CrearRelaciones db
    CargarDatos db
    CrearConsultas db
    Application.RefreshDatabaseWindow
    MsgBox "Base de solución construida: 7 tablas, 6 relaciones, datos de ejemplo " & _
           "y 11 consultas.", vbInformation, "ConstruirSolucion"
End Sub

' ---------- Limpieza (permite volver a ejecutar el constructor) ----------

Private Sub BorrarObjetos(ByVal db As DAO.Database)
    Dim n As Variant
    On Error Resume Next
    For Each n In Array("qryVentasPorMes", "qryVentasPorProducto", "qryProductosConPadre", _
                        "qryCategoriasHoja", "qryColaCobranza", "qryFacturaImpresion", _
                        "qryFacturasPorPeriodo", "qryVentasPorCliente", "qryTotalesFactura", _
                        "qrySubtotalesFactura", "qryLineasConImporte")
        db.QueryDefs.Delete n
    Next n
    For Each n In Array("relHistorialProducto", "relCategoriaPadre", "relProductoCategoria", _
                        "relDetalleProducto", "relDetalleFactura", "relFacturaCliente")
        db.Relations.Delete n
    Next n
    For Each n In Array("tblHistorialPrecios", "tblDetalleFactura", "tblFacturas", _
                        "tblProductos", "tblCategorias", "tblClientes", "tblParametros")
        db.TableDefs.Delete n
    Next n
    Err.Clear
    On Error GoTo 0
End Sub

' ---------- Tablas e índices ----------

Private Sub CrearTablas(ByVal db As DAO.Database)
    db.Execute "CREATE TABLE tblClientes (" & _
        "IdCliente COUNTER CONSTRAINT pkClientes PRIMARY KEY, " & _
        "DocumentoFiscal TEXT(20) NOT NULL, RazonSocial TEXT(100) NOT NULL, " & _
        "Direccion TEXT(150), Ciudad TEXT(60), Telefono TEXT(20), Correo TEXT(100), " & _
        "FechaAlta DATETIME)", dbFailOnError
    db.Execute "CREATE UNIQUE INDEX uxClientesDocumento ON tblClientes (DocumentoFiscal)", dbFailOnError

    db.Execute "CREATE TABLE tblCategorias (" & _
        "IdCategoria LONG CONSTRAINT pkCategorias PRIMARY KEY, " & _
        "Nombre TEXT(50) NOT NULL, IdCategoriaPadre LONG)", dbFailOnError
    db.Execute "CREATE UNIQUE INDEX uxCategoriasNombre ON tblCategorias (Nombre)", dbFailOnError

    db.Execute "CREATE TABLE tblProductos (" & _
        "IdProducto COUNTER CONSTRAINT pkProductos PRIMARY KEY, " & _
        "Codigo TEXT(15) NOT NULL, Descripcion TEXT(100) NOT NULL, " & _
        "IdCategoria LONG NOT NULL, Precio CURRENCY NOT NULL, " & _
        "Existencia LONG, Activo YESNO)", dbFailOnError
    db.Execute "CREATE UNIQUE INDEX uxProductosCodigo ON tblProductos (Codigo)", dbFailOnError

    db.Execute "CREATE TABLE tblFacturas (" & _
        "IdFactura COUNTER CONSTRAINT pkFacturas PRIMARY KEY, " & _
        "NumeroFactura LONG, Fecha DATETIME NOT NULL, IdCliente LONG NOT NULL, " & _
        "TasaImpuesto DOUBLE, Estado TEXT(10) NOT NULL, Observaciones LONGTEXT)", dbFailOnError
    db.Execute "CREATE UNIQUE INDEX uxFacturasNumero ON tblFacturas (NumeroFactura) " & _
        "WITH IGNORE NULL", dbFailOnError

    db.Execute "CREATE TABLE tblDetalleFactura (" & _
        "IdFactura LONG NOT NULL, IdProducto LONG NOT NULL, " & _
        "Cantidad LONG NOT NULL, PrecioUnitario CURRENCY NOT NULL, " & _
        "CONSTRAINT pkDetalleFactura PRIMARY KEY (IdFactura, IdProducto))", dbFailOnError

    db.Execute "CREATE TABLE tblHistorialPrecios (" & _
        "IdCambio COUNTER CONSTRAINT pkHistorialPrecios PRIMARY KEY, " & _
        "IdProducto LONG NOT NULL, PrecioAnterior CURRENCY NOT NULL, " & _
        "FechaCambio DATETIME)", dbFailOnError

    db.Execute "CREATE TABLE tblParametros (" & _
        "Id LONG CONSTRAINT pkParametros PRIMARY KEY, NombreEmpresa TEXT(100), " & _
        "DocumentoFiscalEmpresa TEXT(20), TasaImpuesto DOUBLE)", dbFailOnError

    db.TableDefs.Refresh
End Sub

' ---------- Reglas de validación, valores predeterminados y formatos ----------

Private Sub ConfigurarCampos(ByVal db As DAO.Database)
    Regla db, "tblClientes", "Correo", "Like '*@*.*' Or Is Null", _
        "El correo no tiene un formato válido."
    Predeterminado db, "tblClientes", "FechaAlta", "Date()"
    Regla db, "tblProductos", "Precio", ">=0", "El precio no puede ser negativo."
    Regla db, "tblProductos", "Existencia", ">=0", "La existencia no puede ser negativa."
    Predeterminado db, "tblProductos", "Existencia", "0"
    Predeterminado db, "tblProductos", "Activo", "True"
    Predeterminado db, "tblFacturas", "Fecha", "Date()"
    Predeterminado db, "tblFacturas", "Estado", """Borrador"""
    Regla db, "tblFacturas", "Estado", "'Borrador' Or 'Emitida' Or 'Pagada' Or 'Anulada'", _
        "Estado no válido: Borrador, Emitida, Pagada o Anulada."
    Regla db, "tblFacturas", "TasaImpuesto", "Between 0 And 1", "La tasa debe estar entre 0 y 1."
    Regla db, "tblDetalleFactura", "Cantidad", ">0", "La cantidad debe ser mayor que cero."
    Predeterminado db, "tblDetalleFactura", "Cantidad", "1"
    Regla db, "tblDetalleFactura", "PrecioUnitario", ">=0", "El precio no puede ser negativo."
    Predeterminado db, "tblHistorialPrecios", "FechaCambio", "Now()"
    Regla db, "tblParametros", "Id", "=1", "Solo se admite un registro de parámetros."
    Regla db, "tblParametros", "TasaImpuesto", "Between 0 And 1", "La tasa debe estar entre 0 y 1."
    Formato db, "tblFacturas", "TasaImpuesto", "Percent"
    Formato db, "tblParametros", "TasaImpuesto", "Percent"
End Sub

Private Sub Regla(ByVal db As DAO.Database, ByVal tabla As String, ByVal campo As String, _
                  ByVal expresion As String, ByVal texto As String)
    With db.TableDefs(tabla).Fields(campo)
        .ValidationRule = expresion
        .ValidationText = texto
    End With
End Sub

Private Sub Predeterminado(ByVal db As DAO.Database, ByVal tabla As String, _
                           ByVal campo As String, ByVal valor As String)
    db.TableDefs(tabla).Fields(campo).DefaultValue = valor
End Sub

Private Sub Formato(ByVal db As DAO.Database, ByVal tabla As String, _
                    ByVal campo As String, ByVal valor As String)
    Dim fld As DAO.Field
    Set fld = db.TableDefs(tabla).Fields(campo)
    On Error Resume Next
    fld.Properties("Format") = valor
    If Err.Number = 3270 Then                    ' la propiedad todavía no existe: se crea
        Err.Clear
        fld.Properties.Append fld.CreateProperty("Format", dbText, valor)
    End If
    On Error GoTo 0
End Sub

' ---------- Relaciones con integridad referencial ----------

Private Sub CrearRelaciones(ByVal db As DAO.Database)
    Relacionar db, "relFacturaCliente", "tblClientes", "IdCliente", "tblFacturas", "IdCliente", 0
    Relacionar db, "relDetalleFactura", "tblFacturas", "IdFactura", "tblDetalleFactura", _
        "IdFactura", dbRelationDeleteCascade      ' composición: las líneas se borran con su factura
    Relacionar db, "relDetalleProducto", "tblProductos", "IdProducto", "tblDetalleFactura", "IdProducto", 0
    Relacionar db, "relProductoCategoria", "tblCategorias", "IdCategoria", "tblProductos", "IdCategoria", 0
    Relacionar db, "relHistorialProducto", "tblProductos", "IdProducto", "tblHistorialPrecios", "IdProducto", 0
    On Error Resume Next
    Relacionar db, "relCategoriaPadre", "tblCategorias", "IdCategoria", "tblCategorias", "IdCategoriaPadre", 0
    If Err.Number <> 0 Then
        Debug.Print "Crea a mano la relación reflexiva de tblCategorias: "; Err.Description
    End If
    On Error GoTo 0
End Sub

Private Sub Relacionar(ByVal db As DAO.Database, ByVal nombre As String, _
                       ByVal tablaPadre As String, ByVal campoPadre As String, _
                       ByVal tablaHija As String, ByVal campoHijo As String, _
                       ByVal atributos As Long)
    Dim rel As DAO.Relation
    Set rel = db.CreateRelation(nombre, tablaPadre, tablaHija, atributos)
    rel.Fields.Append rel.CreateField(campoPadre)
    rel.Fields(campoPadre).ForeignName = campoHijo
    db.Relations.Append rel
End Sub

' ---------- Datos de ejemplo (padres primero: orden topológico) ----------

Private Sub CargarDatos(ByVal db As DAO.Database)
    Insertar db, "tblParametros (Id, NombreEmpresa, DocumentoFiscalEmpresa, TasaImpuesto)", _
        Array("1, 'Distribuidora Aula', '0011223344', 0.16")

    Insertar db, "tblCategorias (IdCategoria, Nombre, IdCategoriaPadre)", Array( _
        "1, 'Catálogo', Null", "2, 'Tecnología', 1", "3, 'Papelería', 1", _
        "4, 'Computadoras', 2", "5, 'Accesorios', 2", "6, 'Portátiles', 4", _
        "7, 'Escritorio', 4", "8, 'Periféricos', 5", "9, 'Cables y adaptadores', 5", _
        "10, 'Papel', 3", "11, 'Escritura', 3")

    Insertar db, "tblClientes (IdCliente, DocumentoFiscal, RazonSocial, Direccion, Ciudad, " & _
        "Telefono, Correo, FechaAlta)", Array( _
        "1, '0012345678', 'Papelería El Estudiante, S.A.', 'Av. Universidad 120', 'Ciudad Central', '555-0101', 'compras@elestudiante.example', #2024-01-15#", _
        "2, '0098765432', 'Consultores Andinos, S.R.L.', 'Calle Los Pinos 45', 'Villa Norte', '555-0102', 'admin@andinos.example', #2024-02-03#", _
        "3, '0045678912', 'Escuela Técnica Horizonte', 'Carrera 8 No. 12-30', 'Puerto Azul', '555-0103', 'direccion@horizonte.example', #2024-03-20#", _
        "4, '0034567891', 'María Fernanda Ruiz', 'Pasaje Las Flores 7', 'Ciudad Central', '555-0104', 'mfruiz@correo.example', #2024-05-11#", _
        "5, '0023456789', 'Talleres Mecánicos Rodríguez', 'Km 5 Carretera Sur', 'Villa Norte', '555-0105', Null, #2024-06-02#", _
        "6, '0056789123', 'Clínica Dental Sonrisas', 'Av. Central 300', 'Puerto Azul', '555-0106', 'citas@sonrisas.example', #2024-08-19#", _
        "7, '0067891234', 'Juan Carlos Méndez', 'Calle 5 No. 18', 'Ciudad Central', '555-0107', 'jcmendez@correo.example', #2025-01-09#", _
        "8, '0078912345', 'Cooperativa Agrícola El Valle', 'Camino Real s/n', 'Valle Verde', '555-0108', 'ventas@elvalle.example', #2025-02-27#")

    Insertar db, "tblProductos (IdProducto, Codigo, Descripcion, IdCategoria, Precio, " & _
        "Existencia, Activo)", Array( _
        "1, 'POR-001', 'Laptop 14 pulgadas 16 GB', 6, 15999, 8, True", _
        "2, 'POR-002', 'Laptop 15.6 pulgadas 8 GB', 6, 11499, 5, True", _
        "3, 'PCE-001', 'Computadora de escritorio i5 16 GB', 7, 13999, 4, True", _
        "4, 'PER-001', 'Monitor 24 pulgadas Full HD', 8, 2899, 12, True", _
        "5, 'PER-002', 'Teclado inalámbrico', 8, 499, 30, True", _
        "6, 'PER-003', 'Ratón óptico USB', 8, 189.5, 45, True", _
        "7, 'PER-004', 'Impresora láser monocromática', 8, 3299, 6, True", _
        "8, 'CAB-001', 'Cable HDMI 2 m', 9, 149.9, 60, True", _
        "9, 'CAB-002', 'Adaptador USB-C a HDMI', 9, 349, 25, True", _
        "10, 'CAB-003', 'Cable de red Cat 6 3 m', 9, 89.9, 80, True", _
        "11, 'PAP-001', 'Resma de papel carta 500 hojas', 10, 119, 100, True", _
        "12, 'PAP-002', 'Resma de papel oficio 500 hojas', 10, 139, 70, True", _
        "13, 'ESC-001', 'Bolígrafo azul (caja 12)', 11, 72, 50, True", _
        "14, 'ESC-002', 'Marcador permanente negro', 11, 24.5, 120, True", _
        "15, 'ESC-003', 'Cuaderno profesional 100 hojas', 11, 45, 90, True")

    Insertar db, "tblFacturas (IdFactura, NumeroFactura, Fecha, IdCliente, TasaImpuesto, Estado)", Array( _
        "1, 1001, #2026-09-01#, 1, 0.16, 'Pagada'", _
        "2, 1002, #2026-09-03#, 3, 0.16, 'Emitida'", _
        "3, 1003, #2026-09-08#, 2, 0.16, 'Emitida'", _
        "4, 1004, #2026-09-10#, 1, 0.16, 'Pagada'", _
        "5, 1005, #2026-09-15#, 6, 0.16, 'Emitida'", _
        "6, Null, #2026-09-18#, 5, 0.16, 'Borrador'", _
        "7, 1006, #2026-09-21#, 7, 0.16, 'Anulada'")

    Insertar db, "tblDetalleFactura (IdFactura, IdProducto, Cantidad, PrecioUnitario)", Array( _
        "1, 11, 10, 119", "1, 13, 5, 72", "1, 14, 12, 24.5", _
        "2, 1, 2, 15999", "2, 6, 2, 189.5", "2, 5, 2, 499", _
        "3, 4, 3, 2899", "3, 8, 3, 149.9", _
        "4, 15, 20, 45", "4, 11, 5, 119", _
        "5, 7, 1, 3299", "5, 11, 4, 119", "5, 10, 2, 89.9", _
        "6, 3, 1, 13999", "6, 9, 1, 349", _
        "7, 2, 1, 11499")
End Sub

Private Sub Insertar(ByVal db As DAO.Database, ByVal destino As String, ByVal filas As Variant)
    Dim fila As Variant
    For Each fila In filas
        db.Execute "INSERT INTO " & destino & " VALUES (" & fila & ")", dbFailOnError
    Next fila
End Sub

' ---------- Consultas (en orden de dependencia) ----------

Private Sub CrearConsultas(ByVal db As DAO.Database)
    db.CreateQueryDef "qryLineasConImporte", _
        "SELECT d.IdFactura, d.IdProducto, p.Codigo, p.Descripcion, d.Cantidad, " & _
        "d.PrecioUnitario, d.Cantidad * d.PrecioUnitario AS Importe " & _
        "FROM tblDetalleFactura AS d INNER JOIN tblProductos AS p " & _
        "ON d.IdProducto = p.IdProducto;"

    db.CreateQueryDef "qrySubtotalesFactura", _
        "SELECT IdFactura, Sum(Importe) AS Subtotal FROM qryLineasConImporte GROUP BY IdFactura;"

    db.CreateQueryDef "qryTotalesFactura", _
        "SELECT f.IdFactura, f.NumeroFactura, f.Fecha, f.Estado, c.RazonSocial, " & _
        "s.Subtotal, f.TasaImpuesto, " & _
        "CCur(Round(s.Subtotal * f.TasaImpuesto, 2)) AS Impuesto, " & _
        "s.Subtotal + CCur(Round(s.Subtotal * f.TasaImpuesto, 2)) AS Total " & _
        "FROM (tblClientes AS c INNER JOIN tblFacturas AS f ON c.IdCliente = f.IdCliente) " & _
        "INNER JOIN qrySubtotalesFactura AS s ON f.IdFactura = s.IdFactura;"

    db.CreateQueryDef "qryVentasPorCliente", _
        "SELECT RazonSocial, Count(*) AS Facturas, Sum(Total) AS TotalVendido " & _
        "FROM qryTotalesFactura WHERE Estado IN ('Emitida', 'Pagada') " & _
        "GROUP BY RazonSocial ORDER BY Sum(Total) DESC;"

    db.CreateQueryDef "qryFacturasPorPeriodo", _
        "PARAMETERS [Fecha inicial] DateTime, [Fecha final] DateTime; " & _
        "SELECT NumeroFactura, Fecha, RazonSocial, Total FROM qryTotalesFactura " & _
        "WHERE Fecha BETWEEN [Fecha inicial] AND [Fecha final] ORDER BY Fecha;"

    db.CreateQueryDef "qryFacturaImpresion", _
        "SELECT t.IdFactura, t.NumeroFactura, t.Fecha, t.Estado, t.RazonSocial, " & _
        "c.DocumentoFiscal, c.Direccion, c.Ciudad, l.Codigo, l.Descripcion, l.Cantidad, " & _
        "l.PrecioUnitario, l.Importe, t.Subtotal, t.TasaImpuesto, t.Impuesto, t.Total " & _
        "FROM ((qryTotalesFactura AS t INNER JOIN tblFacturas AS f ON t.IdFactura = f.IdFactura) " & _
        "INNER JOIN tblClientes AS c ON f.IdCliente = c.IdCliente) " & _
        "INNER JOIN qryLineasConImporte AS l ON t.IdFactura = l.IdFactura;"

    db.CreateQueryDef "qryColaCobranza", _
        "SELECT NumeroFactura, Fecha, RazonSocial, Total FROM qryTotalesFactura " & _
        "WHERE Estado = 'Emitida' ORDER BY NumeroFactura;"

    db.CreateQueryDef "qryCategoriasHoja", _
        "SELECT c.IdCategoria, c.Nombre FROM tblCategorias AS c " & _
        "LEFT JOIN tblCategorias AS h ON c.IdCategoria = h.IdCategoriaPadre " & _
        "WHERE h.IdCategoria IS NULL;"

    db.CreateQueryDef "qryProductosConPadre", _
        "SELECT p.Codigo, p.Descripcion, m.Nombre & ' > ' & c.Nombre AS Ruta " & _
        "FROM (tblProductos AS p INNER JOIN tblCategorias AS c ON p.IdCategoria = c.IdCategoria) " & _
        "LEFT JOIN tblCategorias AS m ON c.IdCategoriaPadre = m.IdCategoria;"

    db.CreateQueryDef "qryVentasPorProducto", _
        "SELECT l.Codigo, l.Descripcion, Sum(l.Cantidad) AS Unidades, Sum(l.Importe) AS Monto " & _
        "FROM qryLineasConImporte AS l INNER JOIN tblFacturas AS f ON l.IdFactura = f.IdFactura " & _
        "WHERE f.Estado IN ('Emitida', 'Pagada') GROUP BY l.Codigo, l.Descripcion " & _
        "ORDER BY Sum(l.Importe) DESC;"

    db.CreateQueryDef "qryVentasPorMes", _
        "SELECT Year(Fecha) AS Anio, Month(Fecha) AS Mes, Count(*) AS Facturas, " & _
        "Sum(Total) AS TotalFacturado FROM qryTotalesFactura " & _
        "WHERE Estado IN ('Emitida', 'Pagada') GROUP BY Year(Fecha), Month(Fecha) " & _
        "ORDER BY Year(Fecha), Month(Fecha);"
End Sub
