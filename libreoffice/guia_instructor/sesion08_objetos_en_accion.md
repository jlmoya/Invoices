# Sesión 8 · Objetos en acción

El momento clave es ver fallar `ProbarReglas` con la plantilla y pasar al completar los TODO: la regla deja de ser una instrucción para el usuario y se vuelve una garantía del objeto.

## Agenda (120 min)

| Minutos | Actividad | Notas |
| --- | --- | --- |
| 0–10 | Del diseño al código | Tarjetas de la sesión 7 junto a los módulos |
| 10–20 | Parte A: crear y pegar módulos | Verifica que el módulo de plantilla se llame `clsFactura` |
| 20–35 | Parte B: LineaFactura | Pregunta por el `Property Let` ausente: inmutabilidad |
| 35–70 | Parte C: completar Factura | Recorre el aula; `ProbarReglas` guía el avance |
| 70–85 | Parte D: pruebas | |
| 85–95 | Parte E: repositorio | Dos caminos, el mismo total |
| 95–115 | Parte F: formulario | |
| 115–120 | Cierre del curso y proyecto | Pide el dibujo del hilo evolutivo |

## Solución de los TODO

```vb
Public Property Get Subtotal() As Currency
    Dim acumulado As Currency, l As Variant
    For Each l In mLineas
        acumulado = acumulado + l.Importe
    Next l
    Subtotal = acumulado
End Property

Public Sub Emitir(ByVal numeroAsignado As Long)
    ExigirBorrador
    If mIdCliente = 0 Then Err.Raise 2004, "Curso", MensajeError(2004)
    If mLineas.Count = 0 Then Err.Raise 2005, "Curso", MensajeError(2005)
    If numeroAsignado <= 0 Then Err.Raise 2010, "Curso", MensajeError(2010)
    mNumero = numeroAsignado
    mFecha = Date
    mEstado = ESTADO_EMITIDA
End Sub

Public Sub Anular()
    If mEstado <> ESTADO_EMITIDA Then Err.Raise 2007, "Curso", MensajeError(2007)
    mEstado = ESTADO_ANULADA
End Sub
```

La plantilla conserva tres TODO: subtotal, precondiciones de emisión y anulación. `ProbarReglas` debe fallar antes de completarlos y pasar después. Las reglas ya implementadas, como impedir agregar líneas a una emitida, deben pasar desde el inicio. Compara el resumen con el código de `modPruebasObjetos`; no uses un número fijo de fallos como criterio de aprendizaje.

El kit del instructor incluye `clsFactura.bas` completa. Úsala en un documento de referencia para demostrar resultados; no reemplaces la plantilla del estudiante hasta que haya razonado cada validación. Recuerda que ambos archivos se pegan en el mismo módulo `clsFactura`.

## Comprobación de la conexión con el formulario

1. Verifica que el botón esté dentro del formulario principal en el Navegador de formularios. Su evento Ejecutar acción llama `EmitirDesdeFormulario` de `modPruebasObjetos`.
2. El manejador guarda las filas pendientes del principal y de `sfDetalle` antes de consultar; si falla una validación, aborta la emisión. Así el repositorio recupera los últimos datos y líneas. Después de guardar la factura recarga y reaplica explícitamente el bloqueo.
3. Repositorio recibe la conexión aislada de `ConexionBase()`. La conexión compartida `ActiveConnection` del formulario no permite cambiar auto commit; solo se usa para la interfaz. Guarda las filas pendientes del principal y del detalle antes de leer desde la conexión aislada, y recarga el formulario después de confirmar.
4. Sobre una copia que conserva el borrador de los datos iniciales, emite: número 1007, total 16643.68. Repite y comprueba error 2009 con el mensaje «La operación exige una factura en borrador».
5. Asigna `AplicarBloqueoFactura` al evento Después del cambio de registro de `fFactura`. Verifica el bloqueo del principal y de `sfDetalle` al cambiar de registro. El objeto protege las llamadas de su API; no afirme que impedir editar un formulario bloquea también edición directa de tablas.
6. Ensaya un fallo de almacenamiento en una copia (por ejemplo, un número duplicado) y comprueba que el rollback conserva encabezado y detalle. El error debe mostrarse, no dejar una factura parcialmente escrita.

## Preguntas para la discusión

| Pregunta | Respuesta esperada |
| --- | --- |
| ¿Por qué `Obtener` agrega las líneas antes de llamar a `Cargar`? | `AgregarLinea` exige borrador: el objeto se reconstruye respetando sus reglas y al final se restaura el estado guardado |
| ¿Qué pasa si dos usuarios emiten a la vez? | `MAX + 1` puede dar el mismo número; la restricción única rechaza el segundo. La base integrada del curso es local. Un servidor con varios usuarios necesita asignación de números dentro de una transacción con bloqueo o un generador, según los requisitos de continuidad |
| ¿Qué defensa falta todavía? | Las escrituras directas a las tablas. Firebird ofrece restricciones y triggers; una interfaz bloqueada no sustituye una regla de almacenamiento |

## Errores frecuentes

| Síntoma | Causa | Solución |
| --- | --- | --- |
| No se reconoce `clsFactura` | El módulo se llama `clsFactura_plantilla` o está en «Mis macros» | Crear `clsFactura` en Standard del `.odb` y pegar la plantilla completa |
| Fallo al usar `New` o propiedades | Faltan opciones iniciales de clase | Conservar `Option VBASupport 1` y `Option ClassModule` |
| Variable de objeto sin inicializar | Falta crear clase o llamar Inicializar del repositorio | `Set repo = New clsRepositorioFacturas`, luego `repo.Inicializar conexion` |
| Error 2003 | Producto repetido | Quitar/recrear la línea en borrador o elegir otro producto |
| Error 2009 | Operación fuera de borrador | Es el rechazo esperado; conservar el estado y mostrar `MensajeError(Err.Number)` |
| Error SQL al guardar número | Número duplicado | Revisar datos y siguiente número; verificar rollback antes de reintentar |
| `Parent` no es el formulario esperado | Botón colocado fuera del principal | Reubicarlo en el Navegador de formularios |
| Se puede editar el detalle de una emitida | Falta aplicar bloqueo al subformulario | Revisar los dos modelos y su evento de cambio de registro |
| Código 3002 | Conexión ya dentro de otra transacción | Terminar la edición pendiente; no anidar transacciones en la conexión compartida |

## Cierre del curso

Pide a cada estudiante dibujar el hilo evolutivo con un ejemplo por etapa: 119.00 (dato), `TProducto` (registro), `tblProductos` (colección), `IdCategoria` (referencia), `qryTotalesFactura` (operación), la cola de cobranza (estructura con reglas) y `clsFactura` (objeto).

## Respuestas de la autoevaluación

1. Si fuera pública, cualquiera podría agregar líneas a una factura emitida sin pasar por las reglas.
2. Una línea es inmutable: para cambiar la cantidad se quita la línea y se agrega otra.
3. La factura no depende de la base: se prueba en memoria y el almacenamiento puede cambiar sin tocarla.
4. El objeto; el formulario solo transmite la orden y muestra el resultado.
5. Ver el cierre del curso.
