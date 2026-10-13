VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "clsFactura"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

' SOLUCIÓN COMPLETA. Una factura con sus líneas que hace cumplir su propio ciclo de vida:
'   Borrador -> Emitida -> Pagada o Anulada
' Errores de negocio: vbObjectError + 2000 a 2008 (ver el anexo técnico).

Private mIdFactura As Long            ' 0 = todavía no está guardada
Private mNumero As Long               ' 0 = sin número (borrador)
Private mFecha As Date
Private mIdCliente As Long
Private mTasaImpuesto As Double
Private mEstado As String
Private mLineas As Collection         ' composición: la factura es dueña de sus líneas

Private Sub Class_Initialize()
    Set mLineas = New Collection
    mEstado = ESTADO_BORRADOR
    mFecha = Date
End Sub

' ---------- Propiedades ----------

Public Property Get IdFactura() As Long
    IdFactura = mIdFactura
End Property

Public Property Get Numero() As Long
    Numero = mNumero
End Property

Public Property Get Fecha() As Date
    Fecha = mFecha
End Property

Public Property Get Estado() As String
    Estado = mEstado
End Property

Public Property Get IdCliente() As Long
    IdCliente = mIdCliente
End Property

Public Property Let IdCliente(ByVal valor As Long)
    ExigirBorrador "cambiar el cliente"
    If valor <= 0 Then Err.Raise vbObjectError + 2001, "Factura", "Indica un cliente válido."
    mIdCliente = valor
End Property

Public Property Get TasaImpuesto() As Double
    TasaImpuesto = mTasaImpuesto
End Property

Public Property Let TasaImpuesto(ByVal valor As Double)
    ExigirBorrador "cambiar la tasa de impuesto"
    If valor < 0 Or valor > 1 Then Err.Raise vbObjectError + 2002, "Factura", _
        "La tasa debe estar entre 0 y 1."
    mTasaImpuesto = valor
End Property

Public Property Get CantidadLineas() As Long
    CantidadLineas = mLineas.Count
End Property

' Devuelve la línea en la posición indicada, de 1 a CantidadLineas.
Public Function Linea(ByVal indice As Long) As clsLineaFactura
    Set Linea = mLineas(indice)
End Function

' ---------- Comportamiento ----------

Public Sub AgregarLinea(ByVal idProducto As Long, ByVal descripcion As String, _
                        ByVal cantidad As Long, ByVal precioUnitario As Currency)
    Dim nueva As clsLineaFactura
    ExigirBorrador "agregar líneas"
    If ExisteLinea(idProducto) Then Err.Raise vbObjectError + 2003, "Factura", _
        "El producto ya está en la factura: cambia la cantidad de su línea."
    Set nueva = New clsLineaFactura
    nueva.Inicializar idProducto, descripcion, cantidad, precioUnitario
    mLineas.Add nueva, CStr(idProducto)
End Sub

Public Sub QuitarLinea(ByVal idProducto As Long)
    ExigirBorrador "quitar líneas"
    If Not ExisteLinea(idProducto) Then Err.Raise vbObjectError + 2008, "Factura", _
        "El producto no está en la factura."
    mLineas.Remove CStr(idProducto)
End Sub

Public Property Get Subtotal() As Currency
    Dim acumulado As Currency, l As clsLineaFactura
    For Each l In mLineas
        acumulado = acumulado + l.Importe
    Next l
    Subtotal = acumulado
End Property

Public Property Get Impuesto() As Currency
    Impuesto = CCur(Round(Subtotal * mTasaImpuesto, 2))
End Property

Public Property Get Total() As Currency
    Total = Subtotal + Impuesto
End Property

Public Sub Emitir(ByVal numeroAsignado As Long)
    ExigirBorrador "emitir"
    If mIdCliente = 0 Then Err.Raise vbObjectError + 2004, "Factura", _
        "No se puede emitir una factura sin cliente."
    If mLineas.Count = 0 Then Err.Raise vbObjectError + 2005, "Factura", _
        "No se puede emitir una factura sin líneas."
    mNumero = numeroAsignado
    mFecha = Date
    mEstado = ESTADO_EMITIDA
End Sub

Public Sub RegistrarPago()
    If mEstado <> ESTADO_EMITIDA Then Err.Raise vbObjectError + 2006, "Factura", _
        "Solo se puede pagar una factura emitida."
    mEstado = ESTADO_PAGADA
End Sub

Public Sub Anular()
    If mEstado <> ESTADO_EMITIDA Then Err.Raise vbObjectError + 2007, "Factura", _
        "Solo se puede anular una factura emitida."
    mEstado = ESTADO_ANULADA
End Sub

' ---------- Uso interno ----------

Private Sub ExigirBorrador(ByVal accion As String)
    If mEstado <> ESTADO_BORRADOR Then Err.Raise vbObjectError + 2000, "Factura", _
        "Operación no permitida (" & accion & "): la factura está " & LCase(mEstado) & "."
End Sub

Private Function ExisteLinea(ByVal idProducto As Long) As Boolean
    Dim l As clsLineaFactura
    For Each l In mLineas
        If l.IdProducto = idProducto Then
            ExisteLinea = True
            Exit Function
        End If
    Next l
End Function

' ---------- Solo para el repositorio ----------
' Friend: visible dentro de este proyecto, pero fuera de la interfaz pública de la clase.

Friend Sub Cargar(ByVal idFactura As Long, ByVal numero As Long, ByVal fecha As Date, _
                  ByVal idCliente As Long, ByVal tasa As Double, ByVal estado As String)
    mIdFactura = idFactura
    mNumero = numero
    mFecha = fecha
    mIdCliente = idCliente
    mTasaImpuesto = tasa
    mEstado = estado
End Sub

Friend Sub AsignarId(ByVal idFactura As Long)
    mIdFactura = idFactura
End Sub
