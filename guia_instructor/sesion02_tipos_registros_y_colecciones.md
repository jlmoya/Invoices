# Sesión 2 · Tipos, registros y colecciones

El momento clave es la demostración de `0.1 + 0.2`: convierte la elección de tipos en una decisión técnica, no en un trámite.

## Agenda (120 min)

| Minutos | Actividad | Notas |
| --- | --- | --- |
| 0–10 | Parte A: decimales en la ventana Inmediato | Hazlo tú primero en el proyector |
| 10–35 | Parte B: `tblClientes` | Pide justificar cada tipo en voz alta |
| 35–50 | Parte C: `tblProductos` | |
| 50–60 | Parte D: probar restricciones | |
| 60–85 | Parte E: importación | El paso con más errores: ver la tabla de abajo |
| 85–100 | Parte F: registros y búsqueda en VBA | Si falta tiempo, pásala a la tarea |
| 100–120 | Índices y claves; tarea 2 | |

## Guion

- Relaciona `Type` con `struct` y la tabla con un arreglo de estructuras que vive en disco.
- Para el logaritmo, juega a adivinar un número del 1 al 1 000 con preguntas de mayor o menor: bastan 10.
- Muestra la ventana Índices: la clave principal también es un índice.

## Preguntas para la discusión

| Pregunta | Respuesta esperada |
| --- | --- |
| ¿Por qué no usar Doble para el precio? | En base 2, 0.1 no es exacto; Moneda es un entero escalado |
| ¿Por qué el teléfono es texto? | No se opera con él; puede llevar ceros a la izquierda y símbolos |
| ¿Qué pasa si indexo todo? | Más espacio y altas y cambios más lentos |

## Errores frecuentes

| Síntoma | Causa | Solución |
| --- | --- | --- |
| «No se pudieron anexar todos los registros» | Quedaron registros de prueba con el mismo documento o código | Borrar las pruebas y repetir |
| Fechas vacías o erróneas al importar | Orden de fecha DMA | Avanzado: AMD, `-`, años en cuatro dígitos |
| Precios vacíos o multiplicados | Símbolo decimal coma | Avanzado: símbolo decimal `.` |
| Acentos extraños | Código de página distinto | Europeo occidental (Windows) |
| Regla de validación rechazada | Sintaxis en inglés en Access en español | Usar la forma en español |
| `CompararBusquedas` tarda mucho | n demasiado grande | Usar 100 000 o menos |

## Solución de la tarea 2

1. Un diseño válido de `tblProveedores`: `IdProveedor` Autonumeración (clave); `DocumentoFiscal` Texto 20, requerido, índice único; `RazonSocial` Texto 100, requerido; `Contacto` Texto 100; `Telefono` Texto 20; `Correo` Texto 100 con la regla de `tblClientes`; `DiasCredito` Entero largo, predeterminado 0, regla `Between 0 And 120`; `Activo` Sí/No.
2. Pasos esperados buscando el último código: lineal 1 000, 10 000 y 100 000; binaria 10, 14 y 17. La lineal crece por 10; la binaria suma unos 3 o 4 pasos por cada factor de 10.
3. Cada índice ocupa espacio y se actualiza en cada alta y cambio.

## Respuestas de la autoevaluación

1. Texto: puede empezar con cero y no se hacen cuentas con él.
2. Moneda es exacta para los centavos; Doble no.
3. Natural: `Codigo` o `DocumentoFiscal`. Sustituta: `IdProducto` o `IdCliente`.
4. 21 pasos: duplicar n agrega uno.
