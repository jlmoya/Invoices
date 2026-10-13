Option Explicit
Option VBASupport 1

Public Const ESTADO_BORRADOR As String = "Borrador"
Public Const ESTADO_EMITIDA As String = "Emitida"
Public Const ESTADO_PAGADA As String = "Pagada"
Public Const ESTADO_ANULADA As String = "Anulada"

' Currency usa un entero escalado por 10 000. CStr conserva sus cuatro decimales.
' Evitar CCur(texto) y Format para datos persistidos: internamente pueden usar Double.
Public Function DecimalSQL(ByVal valor As Currency) As String
    DecimalSQL = Replace(CStr(valor), ",", ".")
End Function

' Lee un decimal SQL exacto, sin pasar el número completo por Double.
Public Function MonedaDesdeSQL(ByVal texto As String) As Currency
    Dim entero As String, fraccion As String, signo As Integer, punto As Long
    Dim i As Long, cifra As Long, acumulado As Currency
    texto = Trim(texto)
    signo = 1
    If Left(texto,1)="-" Then
        signo = -1
        texto = Mid(texto,2)
    ElseIf Left(texto,1)="+" Then
        texto = Mid(texto,2)
    End If
    punto = InStr(texto,".")
    If punto = 0 Then
        entero = texto
        fraccion = "0000"
    Else
        entero = Left(texto,punto-1)
        fraccion = Mid(texto,punto+1)
        If Len(fraccion)>4 Then Err.Raise 4102, "Curso", MensajeError(4102)
        fraccion = fraccion & String(4-Len(fraccion),"0")
    End If
    If entero="" Then entero="0"
    For i = 1 To Len(entero)
        cifra = Asc(Mid(entero,i,1))-Asc("0")
        If cifra<0 Or cifra>9 Then Err.Raise 4102, "Curso", MensajeError(4102)
        acumulado = acumulado*CCur(10)+CCur(cifra)
    Next i
    cifra = 0
    For i = 1 To 4
        If Mid(fraccion,i,1)<"0" Or Mid(fraccion,i,1)>"9" Then Err.Raise 4102, "Curso", MensajeError(4102)
        cifra = cifra*10+Asc(Mid(fraccion,i,1))-Asc("0")
    Next i
    acumulado = acumulado+CCur(cifra)/CCur(10000)
    MonedaDesdeSQL = acumulado*CCur(signo)
End Function

' HALF_UP para importes no negativos, igual a ROUND de Firebird.
Public Function RedondearMoneda(ByVal valor As Currency) As Currency
    If valor<0 Then Err.Raise 4101, "Curso", MensajeError(4101)
    RedondearMoneda = RedondearDigitos(Replace(DecimalSQL(valor),".",""),4)
End Function

' Multiplica enteros decimales como texto: el mayor intermedio es 99 999.
' Conserva todos los dígitos del producto hasta redondear a centavos.
' Tasas con cuatro decimales, como DECIMAL(9,4) de la base.
Public Function CalcularPorcentajeMoneda(ByVal subtotal As Currency, ByVal tasa As Currency) As Currency
    Dim digitos As String, resultado As String, i As Long, factor As Long
    Dim cifra As Long, acarreo As Long
    If subtotal<0 Then Err.Raise 4101, "Curso", MensajeError(4101)
    If tasa<0 Or tasa>1 Then Err.Raise 4001, "Curso", MensajeError(4001)
    digitos = Replace(DecimalSQL(subtotal),".","")
    factor = CLng(tasa*CCur(10000))
    For i = Len(digitos) To 1 Step -1
        cifra = (Asc(Mid(digitos,i,1))-Asc("0"))*factor+acarreo
        resultado = CStr(cifra Mod 10) & resultado
        acarreo = cifra \ 10
    Next i
    Do While acarreo>0
        resultado = CStr(acarreo Mod 10) & resultado
        acarreo = acarreo \ 10
    Loop
    CalcularPorcentajeMoneda = RedondearDigitos(resultado,8)
End Function

Private Function RedondearDigitos(ByVal digitos As String, ByVal escala As Integer) As Currency
    Dim descartados As Integer, centavos As String, resto As String
    Dim i As Long, cifra As Long, acarreo As Long, resultado As String
    descartados = escala-2
    If Len(digitos)<=descartados Then digitos = String(descartados+1-Len(digitos),"0") & digitos
    centavos = Left(digitos,Len(digitos)-descartados)
    resto = Right(digitos,descartados)
    If Left(resto,1)>="5" Then
        acarreo = 1
        For i = Len(centavos) To 1 Step -1
            cifra = Asc(Mid(centavos,i,1))-Asc("0")+acarreo
            resultado = CStr(cifra Mod 10) & resultado
            acarreo = cifra \ 10
        Next i
        If acarreo>0 Then resultado = "1" & resultado
        centavos = resultado
    End If
    If Len(centavos)<3 Then centavos = String(3-Len(centavos),"0") & centavos
    RedondearDigitos = MonedaDesdeSQL(Left(centavos,Len(centavos)-2) & "." & Right(centavos,2))
End Function

Public Function MensajeError(ByVal codigo As Long) As String
    Select Case codigo
    Case 2009: MensajeError = "La operación exige una factura en borrador."
    Case 2001: MensajeError = "Indica un cliente válido."
    Case 2002: MensajeError = "La tasa debe estar entre 0 y 1."
    Case 2003: MensajeError = "El producto ya está en la factura."
    Case 2004: MensajeError = "No se puede emitir sin cliente."
    Case 2005: MensajeError = "No se puede emitir sin líneas."
    Case 2006: MensajeError = "Solo se puede pagar una factura emitida."
    Case 2007: MensajeError = "Solo se puede anular una factura emitida."
    Case 2008: MensajeError = "El producto no está en la factura."
    Case 2010: MensajeError = "El número de emisión debe ser positivo."
    Case 2100: MensajeError = "Indica un producto válido."
    Case 2101: MensajeError = "La cantidad debe ser mayor que cero."
    Case 2102: MensajeError = "El precio no puede ser negativo."
    Case 2103: MensajeError = "La línea ya está inicializada."
    Case 3001: MensajeError = "La factura no existe en la base."
    Case 3002: MensajeError = "No se permite guardar dentro de otra transacción."
    Case 3003: MensajeError = "La factura cambió de número, cliente o precio después de emitirse."
    Case 4101: MensajeError = "El importe debe ser no negativo."
    Case 4102: MensajeError = "Decimal SQL inválido: se admiten hasta cuatro decimales."
    Case 4201: MensajeError = "El tamaño del catálogo debe ser positivo."
    Case 3011: MensajeError = "No se encontró el generador IDENTITY de tblFacturas."
    Case 3010: MensajeError = "El protocolo de reconstrucción se usó fuera de una instancia nueva."
    Case 4001: MensajeError = "El porcentaje debe estar entre 0 y 1."
    Case 6001: MensajeError = "El precio no puede ser negativo."
    Case 6002: MensajeError = "El producto no existe."
    Case 6003: MensajeError = "Hay un ciclo en las categorías."
    Case 6004: MensajeError = "La categoría no existe."
    Case 7001: MensajeError = "El constructor requiere una base nueva y vacía."
    Case Else: MensajeError = "Error " & codigo & ": " & Error(codigo)
    End Select
End Function
