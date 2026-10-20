# Sesión 6 · Cola, pila, árbol y diccionario

El momento clave es entender que la tabla no cambia: cola y pila son reglas de acceso sobre registros comunes, y esas reglas se pueden saltar. De ahí nace la pregunta de la sesión 7.

## Agenda (120 min)

| Minutos | Actividad | Notas |
| --- | --- | --- |
| 0–15 | TAD y tabla de estructuras | |
| 15–20 | Parte A: cargar el módulo | |
| 20–40 | Parte B: cola | Simula una fila de banco con voluntarios |
| 40–65 | Parte C: pila | Ctrl+Z como ejemplo cotidiano |
| 65–95 | Parte D: árbol | Dibuja la pila de llamadas de `ImprimirArbol` |
| 95–110 | Parte E: diccionario | Compáralo con `GROUP BY` |
| 110–120 | Cierre: «¿Qué impide un `UPDATE` directo?»; tarea 6 | |

## Guion

- La recursión se ejecuta sobre una pila de llamadas: la pila reaparece donde nadie la escribió.
- `LIMIT 1` limita a una fila; la columna única de orden define qué fila ocupa el frente o el tope. Sin `ORDER BY` no hay disciplina de acceso.
- Antes de cerrar, ejecuta en Herramientas → SQL `UPDATE "tblFacturas" SET "Estado" = 'Pagada' WHERE "NumeroFactura" = 1005` sobre una copia: la cola no lo impide.

## Preguntas para la discusión

| Pregunta | Respuesta esperada |
| --- | --- |
| ¿Qué estructura usa la computadora para ejecutar `ImprimirArbol`? | Una pila de llamadas |
| ¿Sería justa la cola ordenada por `Fecha`? | No: habría empates y un borrador viejo se colaría al frente al emitirse |
| ¿Qué garantiza el contrato de un diccionario? | Agregar, comprobar y obtener por clave. Una tabla hash es una implementación posible; no se infiere su complejidad solo por el nombre del servicio ScriptForge |

## Errores frecuentes

| Síntoma | Causa | Solución |
| --- | --- | --- |
| No se encuentra `ConexionBase` | Falta `modEstructuras` en Standard del documento | Crear el módulo y pegar el archivo completo |
| No se encuentra `CreateScriptService` | ScriptForge no se cargó o falta en la instalación | Revisar `GlobalScope.BasicLibraries.LoadLibrary("ScriptForge")` y reparar instalación |
| Tabla/columna desconocida | Nombres sin comillas o tabla no creada | Comprobar `"tblCategorias"` e `"IdCategoriaPadre"` |
| Recursión no termina o error 6003 | Las categorías contienen un ciclo | Restaurar los padres del diagrama; una FK sola no prohíbe ciclos |
| La relación reflexiva no se crea | Un padre que no existe | Revisar los valores del paso 2 |
| `ImprimirArbol` no imprime nada | La raíz tiene padre | Dejar vacío el padre de Catálogo |
| `DeshacerUltimoCambio` responde False de inmediato | Otro `IdProducto` o no hubo cambios | Usar el producto 11 |

## Solución de la tarea 6

El código completo está en `kit_instructor/basic/modSolucionesTareas.bas`. Cárgalo en Standard junto a `modEstructuras`, luego ejecuta `EjecutarTarea6` (llama a `ProbarTarea6`). Las funciones reciben opcionalmente la conexión para reutilizarla durante el recorrido.

El algoritmo de profundidad consulta un padre con parámetros y sube hasta SQL NULL:

```text
actual ← idCategoria; nivel ← 0
leer IdCategoriaPadre de actual
mientras el padre no sea NULL:
    comprobar que no se visitó antes (rechazar ciclo)
    nivel ← nivel + 1
    actual ← padre
    leer el padre de actual
devolver nivel
```

La ruta usa `Collection` como pila y mantiene el algoritmo de la guía:

```vb
Dim pila As New Collection, ruta As String
' Mientras se sube, agregar a pila el nombre leído de cada categoría.
' El código del kit consulta con prepareStatement y detecta ciclos.
Do While pila.Count > 0
    If Len(ruta) > 0 Then ruta = ruta & " > "
    ruta = ruta & pila.Item(pila.Count)
    pila.Remove pila.Count
Loop
```

En SDBC, después de `getInt` se consulta `wasNull()` para distinguir un padre ausente de un Id 0. Una categoría inexistente se rechaza (6004), y un ciclo (6003) se rechaza sin recorrer indefinidamente. Pide al alumnado justificar estas comprobaciones además del caso feliz.

Para una demostración sin argumentos, crea:

```vb
Sub MostrarRutaYProfundidad()
    MsgBox Profundidad(6) & Chr(10) & RutaCategoria(8)
End Sub
```

Resultados: `Profundidad(1)` = 0, `Profundidad(6)` = 3; `RutaCategoria(8)` = Catálogo > Tecnología > Accesorios > Periféricos.

Pregunta 3: `NumeroFactura` es único y se asigna en orden de emisión, así que marca el orden real de llegada sin empates. Pregunta 4, ejemplos válidos: una cola de pedidos a proveedores, una pila para deshacer cambios de clientes o un diccionario para consultar precios sin volver a la base.

## Respuestas de la autoevaluación

1. La regla de acceso: FIFO frente a LIFO.
2. Dos cambios pueden tener la misma fecha y hora; `IdCambio` es único y creciente.
3. Una tabla relacionada consigo misma; produce un árbol o una jerarquía.
4. En una implementación hash, una función calcula dónde buscar la clave; el tiempo esperado es casi constante, aunque hay colisiones y casos desfavorables.
