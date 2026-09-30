# Proyecto integrador

El proyecto integra todo el curso: extiendes el sistema de facturación con una funcionalidad nueva, la modelas como datos y como objetos, y demuestras que sus reglas se cumplen. Vale 35 % de la calificación y se entrega una semana después de la sesión 8.

## Elige una opción

| Opción | Qué agrega al sistema | Lo que ejercita |
| --- | --- | --- |
| A · Pagos parciales | Abonos por factura, saldo pendiente y paso automático a Pagada | Relación uno a muchos, reglas de saldo dentro de la factura, cola de cobranza por saldo |
| B · Inventario | Existencias que se descuentan al emitir, entradas por pedidos y alertas de reposición | Bitácora de movimientos, reglas de existencia, un producto con comportamiento |
| C · Notas de crédito | Documentos que revierten total o parcialmente una factura emitida | Referencia a la factura original, interfaz común con `Implements`, polimorfismo |

## Requisitos comunes

- [ ] Modelo entidad-relación en Mermaid de las tablas nuevas, con claves y cardinalidades.
- [ ] Tablas y relaciones creadas en Access, con integridad referencial y reglas de validación.
- [ ] Al menos dos consultas nuevas, una de ellas con agregación.
- [ ] Un formulario o un informe nuevo.
- [ ] Tarjetas CRC, diagrama de clases y diagrama de estados de la parte nueva.
- [ ] Al menos una clase VBA nueva o modificada que haga cumplir las reglas, con repositorio si guarda datos.
- [ ] Un procedimiento de prueba al estilo de `ProbarReglas` que verifique al menos cuatro reglas.
- [ ] Un documento de 3 a 5 páginas y una demostración de 5 minutos.

## Detalle por opción

### Opción A · Pagos parciales

Parte de tu tarea 7. Reglas mínimas:

1. Solo se registran abonos en facturas emitidas.
2. Un abono es mayor que cero y no supera el saldo pendiente.
3. Cuando el saldo llega a cero, la factura pasa a Pagada por sí misma.
4. Una factura con abonos no puede anularse.

Pista: una tabla `tblAbonos` y, en la clase Factura, un método `RegistrarAbono` y una propiedad `Saldo`.

### Opción B · Inventario

Reglas mínimas:

1. Una factura no puede emitirse si algún producto no tiene existencia suficiente.
2. Al emitir, la existencia de cada producto se descuenta.
3. Toda entrada o salida queda registrada en una bitácora de movimientos que no se modifica.
4. Un informe lista los productos por debajo de su existencia mínima.

Pista: reutiliza los pedidos a proveedores de la tarea 3 como entradas de inventario.

### Opción C · Notas de crédito

Reglas mínimas:

1. Una nota de crédito se refiere a una factura emitida o pagada.
2. La suma de las notas de una factura no supera su total.
3. Cada nota tiene su propio número consecutivo.
4. Una factura anulada no admite notas de crédito.

Pista: una interfaz `IDocumento` con número, fecha, total y emitir, implementada por la factura y por la nota de crédito. Un informe puede recorrer documentos de ambos tipos a través de la interfaz.

## Entregables y fechas

| Momento | Entregable |
| --- | --- |
| Semana de la sesión 8 | Opción elegida y modelos (entidad-relación y clases) para revisión del instructor |
| Una semana después de la sesión 8 | `Proyecto_Apellido.accdb`, documento en PDF y demostración de 5 minutos |

## Rúbrica

| Criterio | Peso | Excelente | Suficiente | Insuficiente |
| --- | --- | --- | --- | --- |
| Modelo de datos | 20 % | 3FN, claves, integridad y validaciones completas | Funciona, con redundancias menores | Sin integridad o con errores de modelo |
| Modelo de objetos | 20 % | Tarjetas CRC, clases y estados coherentes entre sí y con el código | Inconsistencias menores entre diagramas y código | Diagramas ausentes o que no corresponden al código |
| Implementación | 25 % | Todas las reglas viven en las clases y las pruebas pasan | La mayoría de las reglas en clases; alguna solo en el formulario | Reglas solo en formularios o sin pruebas |
| Consultas, formularios e informes | 15 % | Resultados correctos y útiles | Correctos, con detalles menores | Incorrectos o incompletos |
| Documento y demostración | 20 % | Explica sus decisiones y responde preguntas con precisión | Explica lo principal | No justifica sus decisiones |
