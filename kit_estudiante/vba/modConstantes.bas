Attribute VB_Name = "modConstantes"
Option Compare Database
Option Explicit

' Estados de una factura. Deben coincidir con la regla de validación de tblFacturas.Estado.
Public Const ESTADO_BORRADOR As String = "Borrador"
Public Const ESTADO_EMITIDA As String = "Emitida"
Public Const ESTADO_PAGADA As String = "Pagada"
Public Const ESTADO_ANULADA As String = "Anulada"
