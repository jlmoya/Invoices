# Evaluación y rúbricas

La calificación combina tareas (50 %), proyecto integrador (35 %) y autoevaluación con participación (15 %).

## Rúbrica de las tareas

| Criterio | Peso | Excelente (100) | Bueno (80) | Suficiente (60) | Insuficiente (30) |
| --- | --- | --- | --- | --- | --- |
| Funcionamiento | 40 % | Todo funciona y pasa los puntos de control | Falla un detalle menor | Funciona lo principal con errores visibles | No funciona o no se entregó |
| Justificación | 30 % | Cada decisión tiene una razón explícita | Justifica la mayoría | Justificaciones genéricas | Sin justificación |
| Modelado | 20 % | Diagramas correctos y coherentes con lo construido | Errores menores de notación | Diagramas incompletos | Sin diagramas |
| Presentación | 10 % | Convenciones, claridad y entrega a tiempo | Una falla | Varias fallas | Entrega tardía sin aviso |

## Rúbrica del proyecto integrador

La misma que ve el estudiante en `guia_estudiante/proyecto_integrador.md`: modelo de datos 20 %, modelo de objetos 20 %, implementación 25 %, consultas, formularios e informes 15 %, documento y demostración 20 %.

### Preguntas para la defensa

1. ¿Qué regla nueva hace cumplir tu clase y qué pasa si alguien la intenta romper?
2. ¿Por qué esa responsabilidad es de esa clase y no de otra?
3. ¿Qué relación usa eliminación en cascada y por qué?
4. Muestra tu prueba de reglas fallando cuando quitas una validación.
5. ¿Qué cambiarías si el sistema tuviera varios usuarios a la vez?
6. ¿Qué estructura de datos del curso aparece en tu solución?

## Banco de preguntas

| Sesión | Pregunta | Respuesta |
| --- | --- | --- |
| 1 | ¿Por qué el total de una factura no se guarda? | Es derivado: guardarlo permite inconsistencias |
| 1 | ¿Qué es un registro? | Los valores de una sola ocurrencia de una entidad |
| 2 | ¿Qué tipo usar para dinero y por qué? | Moneda: es exacto con 4 decimales; Doble es binario |
| 2 | ¿Cuántas comparaciones hace la búsqueda binaria en 1 000 000 de registros? | Unas 20 |
| 3 | ¿Qué prohíbe la integridad referencial? | Claves foráneas que apuntan a registros inexistentes |
| 3 | ¿Qué es una dependencia funcional? | Que conocer un campo basta para saber otro, como `DocCliente → CiudadCliente` |
| 3 | ¿Qué exige la primera forma normal? | Un solo valor por celda, sin grupos repetidos, y una clave que identifique cada fila |
| 3 | ¿Qué resuelve la segunda forma normal? | Atributos que dependen solo de una parte de la clave |
| 3 | ¿Qué resuelve la tercera forma normal? | Atributos que dependen de otro atributo que no es clave: dependencias transitivas |
| 3, opcional | ¿Qué exige la forma normal de Boyce-Codd? | Que todo campo o grupo de campos que determina a otro sea clave candidata |
| 3, opcional | ¿Qué resuelve la cuarta forma normal? | Dos listas independientes guardadas en la misma tabla: dependencias multivaluadas |
| 3, opcional | ¿Qué resuelve la quinta forma normal? | Una tabla que guarda como un solo hecho varios hechos más pequeños: dependencias de unión |
| 4 | ¿Qué operación de colecciones es `GROUP BY` con `Sum`? | Agregar por clave (reduce) |
| 4 | ¿Por qué la tasa vive en `tblParametros`? | Para cambiarla sin editar consultas ni código |
| 5 | ¿Qué guarda un combo con ancho de columnas `0cm;6cm`? | La clave oculta de la primera columna |
| 5 | ¿Qué recorrido hace un informe agrupado? | Encabezado del grupo, detalle y pie |
| 6 | ¿Qué distingue a una cola de una pila? | El orden de salida: FIFO frente a LIFO |
| 6 | ¿Por qué el árbol se recorre en VBA y no en SQL? | El SQL de Access no admite consultas recursivas |
| 7 | ¿Qué es una tarjeta CRC? | Clase, responsabilidades y colaboradores |
| 7 | ¿Qué heurística asigna el total a la factura? | Experto en información |
| 8 | ¿Por qué el repositorio es una clase aparte? | Alta cohesión: la factura no sabe de almacenamiento |
| 8 | ¿Qué es el polimorfismo con `Implements`? | Usar clases distintas a través de la misma interfaz |
