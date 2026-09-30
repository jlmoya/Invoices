# Sesión 6 · Cola, pila, árbol y diccionario

El momento clave es entender que la tabla no cambia: cola y pila son reglas de acceso sobre registros comunes, y esas reglas se pueden saltar. De ahí nace la pregunta de la sesión 7.

## Agenda (120 min)

| Minutos | Actividad | Notas |
| --- | --- | --- |
| 0–15 | TAD y tabla de estructuras | |
| 15–20 | Parte A: importar el módulo | |
| 20–40 | Parte B: cola | Simula una fila de banco con voluntarios |
| 40–65 | Parte C: pila | Ctrl+Z como ejemplo cotidiano |
| 65–95 | Parte D: árbol | Dibuja la pila de llamadas de `ImprimirArbol` |
| 95–110 | Parte E: diccionario | Compáralo con `GROUP BY` |
| 110–120 | Cierre: «¿Qué impide un `UPDATE` directo?»; tarea 6 | |

## Guion

- La recursión se ejecuta sobre una pila de llamadas: la pila reaparece donde nadie la escribió.
- `TOP 1` en Access devuelve empates; por eso cola y pila ordenan por campos únicos.
- Antes de cerrar, ejecuta en la vista SQL un `UPDATE tblFacturas SET Estado = 'Pagada'` sobre una factura que no está al frente: la cola no lo impide.

## Preguntas para la discusión

| Pregunta | Respuesta esperada |
| --- | --- |
| ¿Qué estructura usa la computadora para ejecutar `ImprimirArbol`? | Una pila de llamadas |
| ¿Sería justa la cola ordenada por `Fecha`? | No: habría empates y un borrador viejo se colaría al frente al emitirse |
| ¿Dónde está la tabla hash? | Dentro de `Scripting.Dictionary`; el motor también usa índices o hash para agrupar |

## Errores frecuentes

| Síntoma | Causa | Solución |
| --- | --- | --- |
| «No se ha definido el tipo definido por el usuario» en `DAO` | Falta la referencia a DAO | Herramientas → Referencias: Microsoft Office Access database engine Object Library |
| Error 429 al crear el diccionario | Scripting bloqueado por la institución | Pedirlo a TI o resolver con `Collection` |
| La relación reflexiva no se crea | Un padre que no existe | Revisar los valores del paso 2 |
| `ImprimirArbol` no imprime nada | La raíz tiene padre | Dejar vacío el padre de Catálogo |
| `DeshacerUltimoCambio` responde Falso de inmediato | Otro `IdProducto` o no hubo cambios | Usar el producto 11 |

## Solución de la tarea 6

El código completo está en `kit_instructor\vba\modSolucionesTareas.bas`.

```vb
Public Function Profundidad(ByVal idCategoria As Long) As Integer
    Dim nivel As Integer, padre As Variant
    padre = DLookup("IdCategoriaPadre", "tblCategorias", "IdCategoria = " & idCategoria)
    Do While Not IsNull(padre)                      ' subir hasta la raíz
        nivel = nivel + 1
        padre = DLookup("IdCategoriaPadre", "tblCategorias", "IdCategoria = " & padre)
    Loop
    Profundidad = nivel
End Function

Public Function RutaCategoria(ByVal idCategoria As Long) As String
    Dim pila As New Collection, actual As Variant, ruta As String
    actual = idCategoria
    Do While Not IsNull(actual)                     ' apilar mientras se sube
        pila.Add DLookup("Nombre", "tblCategorias", "IdCategoria = " & actual)
        actual = DLookup("IdCategoriaPadre", "tblCategorias", "IdCategoria = " & actual)
    Loop
    Do While pila.Count > 0                         ' desapilar: de la raíz a la hoja
        If Len(ruta) > 0 Then ruta = ruta & " > "
        ruta = ruta & pila(pila.Count)
        pila.Remove pila.Count
    Loop
    RutaCategoria = ruta
End Function
```

Resultados: `Profundidad(1)` = 0, `Profundidad(6)` = 3; `RutaCategoria(8)` = Catálogo > Tecnología > Accesorios > Periféricos.

Pregunta 3: `NumeroFactura` es único y se asigna en orden de emisión, así que marca el orden real de llegada sin empates. Pregunta 4, ejemplos válidos: una cola de pedidos a proveedores, una pila para deshacer cambios de clientes o un diccionario para consultar precios sin volver a la base.

## Respuestas de la autoevaluación

1. La regla de acceso: FIFO frente a LIFO.
2. Dos cambios pueden tener la misma fecha y hora; `IdCambio` es único y creciente.
3. Una tabla relacionada consigo misma; produce un árbol o una jerarquía.
4. Una función hash calcula dónde está la clave sin recorrer los elementos.
