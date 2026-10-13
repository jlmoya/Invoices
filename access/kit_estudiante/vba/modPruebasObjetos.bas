Attribute VB_Name = "modPruebasObjetos"
Option Compare Database
Option Explicit

' Pruebas del laboratorio 8. Ejecútalas desde la ventana Inmediato (Ctrl+G).

' Arma en memoria una factura igual a la 1003, la emite e intenta modificarla.
Public Sub ProbarFactura()
    Dim f As clsFactura
    Set f = New clsFactura
    f.IdCliente = 2
    f.TasaImpuesto = 0.16
    f.AgregarLinea 4, "Monitor 24 pulgadas Full HD", 3, 2899
    f.AgregarLinea 8, "Cable HDMI 2 m", 3, 149.9
    Debug.Print "Subtotal:", f.Subtotal
    Debug.Print "Impuesto:", f.Impuesto
    Debug.Print "Total:", f.Total
    f.Emitir 9999
    On Error Resume Next
    f.AgregarLinea 6, "Ratón óptico USB", 1, 189.5
    Debug.Print "Rechazo:", Err.Description
    On Error GoTo 0
End Sub

' Prueba cinco reglas del ciclo de vida. Todas deben decir Correcto.
Public Sub ProbarReglas()
    Dim f As clsFactura
    Dim fallo As Boolean

    ' Regla 1: una factura sin líneas no puede emitirse
    Set f = New clsFactura
    f.IdCliente = 5
    f.TasaImpuesto = 0.16
    On Error Resume Next
    f.Emitir 9001
    fallo = (Err.Number <> 0)
    On Error GoTo 0
    Informar "Rechaza emitir sin líneas", fallo

    ' Regla 2: una factura sin cliente no puede emitirse
    Set f = New clsFactura
    f.TasaImpuesto = 0.16
    f.AgregarLinea 11, "Resma de papel carta 500 hojas", 1, 119
    On Error Resume Next
    f.Emitir 9002
    fallo = (Err.Number <> 0)
    On Error GoTo 0
    Informar "Rechaza emitir sin cliente", fallo

    ' Regla 3: un borrador no puede anularse
    Set f = New clsFactura
    On Error Resume Next
    f.Anular
    fallo = (Err.Number <> 0)
    On Error GoTo 0
    Informar "Rechaza anular un borrador", fallo

    ' Regla 4: una factura emitida no acepta líneas nuevas
    Set f = New clsFactura
    f.IdCliente = 5
    f.AgregarLinea 11, "Resma de papel carta 500 hojas", 1, 119
    f.Emitir 9003
    On Error Resume Next
    f.AgregarLinea 13, "Bolígrafo azul (caja 12)", 1, 72
    fallo = (Err.Number <> 0)
    On Error GoTo 0
    Informar "Rechaza agregar líneas a una factura emitida", fallo

    ' Regla 5: una factura emitida sí puede anularse
    On Error Resume Next
    f.Anular
    fallo = (Err.Number <> 0)
    On Error GoTo 0
    Informar "Permite anular una factura emitida", (Not fallo) And (f.Estado = ESTADO_ANULADA)
End Sub

Private Sub Informar(ByVal regla As String, ByVal cumple As Boolean)
    Debug.Print IIf(cumple, "Correcto   ", "FALLA      ") & regla
End Sub

' Carga desde la base la factura con IdFactura = 3 (número 1003) y muestra sus totales.
Public Sub ProbarRepositorio()
    Dim repo As clsRepositorioFacturas, f As clsFactura, i As Long
    Set repo = New clsRepositorioFacturas
    Set f = repo.Obtener(3)
    Debug.Print "Factura"; f.Numero; "("; f.Estado; ")"
    For i = 1 To f.CantidadLineas
        Debug.Print "  "; f.Linea(i).Descripcion; " x"; f.Linea(i).Cantidad; " ="; f.Linea(i).Importe
    Next i
    Debug.Print "Subtotal:", f.Subtotal
    Debug.Print "Impuesto:", f.Impuesto
    Debug.Print "Total:", f.Total
End Sub
