# Sesión 8 · Objetos en acción

El momento clave es ver fallar `ProbarReglas` con la plantilla y pasar al completar los TODO: la regla deja de ser una instrucción para el usuario y se vuelve una garantía del objeto.

## Agenda (120 min)

| Minutos | Actividad | Notas |
| --- | --- | --- |
| 0–10 | Del diseño al código | Tarjetas de la sesión 7 junto a los módulos |
| 10–20 | Parte A: importar | Verifica que la plantilla aparezca como `clsFactura` |
| 20–35 | Parte B: LineaFactura | Pregunta por el `Property Let` ausente: inmutabilidad |
| 35–70 | Parte C: completar Factura | Recorre el aula; `ProbarReglas` guía el avance |
| 70–85 | Parte D: pruebas | |
| 85–95 | Parte E: repositorio | Dos caminos, el mismo total |
| 95–115 | Parte F: formulario | |
| 115–120 | Cierre del curso y proyecto | Pide el dibujo del hilo evolutivo |

## Solución de los TODO

```vb
Public Property Get Subtotal() As Currency
    Dim acumulado As Currency, l As clsLineaFactura
    For Each l In mLineas
        acumulado = acumulado + l.Importe
    Next l
    Subtotal = acumulado
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

Public Sub Anular()
    If mEstado <> ESTADO_EMITIDA Then Err.Raise vbObjectError + 2007, "Factura", _
        "Solo se puede anular una factura emitida."
    mEstado = ESTADO_ANULADA
End Sub
```

Con la plantilla sin completar, `ProbarReglas` muestra FALLA en cuatro reglas y Correcto solo en la regla 4 (agregar líneas a una factura emitida), porque `AgregarLinea` ya viene resuelta.

## Preguntas para la discusión

| Pregunta | Respuesta esperada |
| --- | --- |
| ¿Por qué `Obtener` agrega las líneas antes de llamar a `Cargar`? | `AgregarLinea` exige borrador: el objeto se reconstruye respetando sus reglas y al final se restaura el estado guardado |
| ¿Qué pasa si dos usuarios emiten a la vez? | `DMax + 1` puede dar el mismo número; el índice único rechaza el segundo. En varios usuarios se usa una tabla de folios con bloqueo |
| ¿Qué defensa falta todavía? | Las escrituras directas a las tablas; en Access se cubren con macros de datos Antes del cambio |

## Errores frecuentes

| Síntoma | Causa | Solución |
| --- | --- | --- |
| «No se ha definido el tipo definido por el usuario» con `clsFactura` | La plantilla no se importó o tiene otro nombre | Verificar el nombre en la ventana Proyecto |
| Error 91, variable de objeto no establecida | Falta `Set` o `New` | `Set f = New clsFactura` |
| Error 457 al agregar una línea | Clave repetida en la `Collection` | El producto ya está en la factura |
| Error 3022 al guardar | Número de factura repetido | Revisar `SiguienteNumero` |
| No existe `Me.sfrmDetalleFactura` | El control de subformulario tiene otro nombre | Usar el nombre real del control |
| El formulario no se bloquea | Quedó el `Form_Current` del laboratorio 5 | Reemplazarlo por la versión del laboratorio 8 |

## Cierre del curso

Pide a cada estudiante dibujar el hilo evolutivo con un ejemplo por etapa: 119.00 (dato), `TProducto` (registro), `tblProductos` (colección), `IdCategoria` (referencia), `qryTotalesFactura` (operación), la cola de cobranza (estructura con reglas) y `clsFactura` (objeto).

## Respuestas de la autoevaluación

1. Si fuera pública, cualquiera podría agregar líneas a una factura emitida sin pasar por las reglas.
2. Una línea es inmutable: para cambiar la cantidad se quita la línea y se agrega otra.
3. La factura no depende de la base: se prueba en memoria y el almacenamiento puede cambiar sin tocarla.
4. El objeto; el formulario solo transmite la orden y muestra el resultado.
5. Ver el cierre del curso.
