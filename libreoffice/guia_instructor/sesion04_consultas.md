# Sesión 4 · Consultas

El momento clave es ver que `qryTotalesFactura` encadena transformar, agregar y unir: el razonamiento de un ciclo sin escribirlo.

## Agenda (120 min)

| Minutos | Actividad | Notas |
| --- | --- | --- |
| 0–10 | Operaciones sobre colecciones | Pedir equivalentes en el lenguaje que conocen |
| 10–20 | Parte A: parámetros | Clave + CHECK permiten como máximo una fila |
| 20–35 | Parte B: importe | Probar SELECT antes de CREATE VIEW |
| 35–50 | Parte C: subtotal | Una fila por factura con líneas |
| 50–70 | Parte D: totales | Contrastar los siete resultados esperados |
| 70–85 | Parte E: ventas | El orden se pide en el SELECT de presentación |
| 85–100 | Parte F: parámetros de Base | Activar sustitución de nombres, reconectar y desactivar SQL directo para esta consulta |
| 100–120 | Redondeo y tarea 4 | Regla explícita y coincidencia Basic–SQL |

## Guion

Escribe el ciclo junto al SQL:

```text
para cada línea: importe = cantidad × precio           (transformar)
para cada factura: subtotal = suma de sus importes      (agregar por clave)
para cada factura: unir cliente, impuesto y total       (unir)
```

Las vistas del motor aparecen en Tablas; una consulta guardada de Base aparece en Consultas. Esta diferencia permite que los módulos Basic consulten `"qryTotalesFactura"` mediante SDBC sin el analizador de Base. `qryFacturasPorPeriodo` pertenece a Base porque requiere la entrada de parámetros. Con HSQLDB incorporado no hace falta ninguna configuración: Base reconoce `:FechaInicial` y `:FechaFinal` siempre que la consulta no use SQL directo.

No presentes el 16 % como tasa oficial. El curso redondea el impuesto sobre el subtotal a dos cifras, con las mitades hacia arriba. `ROUND` de HSQLDB trabaja en coma flotante y falla en empates como 2.405; por eso las vistas usan `FLOOR(x * 100 + 0.5) / 100`, convertido a `DECIMAL`. Con 16 % y subtotales en centavos no hay empates, así que la diferencia aparece solo con otras tasas. El kit implementa la misma política en `RedondearMoneda`; el formato visual moneda no decide el redondeo.

## Preguntas para la discusión

| Pregunta | Respuesta esperada |
| --- | --- |
| ¿Por qué CAST a DECIMAL? | Fija el tipo exacto del resultado; el formato visual no lo hace |
| ¿Qué ocurre si cambia la tasa mañana? | La factura vieja conserva su tasa, la nueva copia la vigente |
| ¿Por qué el borrador está en totales pero no en ventas? | Ventas solo admite Emitida y Pagada |
| ¿Por qué el orden de una vista no está garantizado? | El resultado es un conjunto; el SELECT de presentación pide ORDER BY |
| ¿CHECK Id=1 garantiza que siempre exista una fila? | No: admite como máximo una; se puede borrar la única |

## Errores frecuentes

| Síntoma | Causa | Solución |
| --- | --- | --- |
| Base rechaza CREATE VIEW en el diseñador de consultas | Se usó una ventana para SELECT | Herramientas → SQL; una sentencia de definición por vez |
| Vista no visible en Consultas | Es una vista del motor | Actualizar Tablas y abrirla allí |
| Columna desconocida | Identificador sin comillas o nombre incorrecto | Revisar nombres sensibles a mayúsculas |
| Total duplicado | Se unió el detalle antes de agregar | Calcular subtotal antes de unir al encabezado |
| Tasa 16 falla o parece 1600 % | Confusión entre porcentaje y fracción | Almacenar 0.16; mostrar porcentaje como formato |
| No pide fechas o HSQLDB rechaza ':' | SQL directo activado en consulta parametrizada | Desactivarlo en qryFacturasPorPeriodo |
| Periodo vacío | Formato de entrada de fechas o límites incorrectos | Probar las fechas como texto ISO, `'2026-09-01'` (HSQLDB 1.8 no acepta `DATE '…'`), y comprobar la configuración regional |
| Impuesto con un centavo de diferencia | Se usó `ROUND` en la vista | Usar `CAST(FLOOR(x * 100 + 0.5) / 100 AS DECIMAL(18,4))` |
| Reporte posterior vacío | Parámetros sin registro | Restablecer Id=1 antes de la sesión 5 |

## Solución de la tarea 4

Crear las vistas con una sentencia por vez en Herramientas → SQL. El orden se aplica al abrir un SELECT en Base.

```sql
CREATE VIEW "qryVentasPorProducto" AS
SELECT l."Codigo", l."Descripcion", SUM(l."Cantidad") AS "Unidades",
       SUM(l."Importe") AS "Monto"
FROM "qryLineasConImporte" l
JOIN "tblFacturas" f ON f."IdFactura" = l."IdFactura"
WHERE f."Estado" IN ('Emitida', 'Pagada')
GROUP BY l."Codigo", l."Descripcion";
```

```sql
SELECT * FROM "qryVentasPorProducto" ORDER BY "Monto" DESC;
```

Resultado: 11 productos. Encabezan POR-001 (2 unidades, 31,998.00), PER-001 (8,697.00) y PER-004 (3,299.00); PAP-001 suma 19 unidades y 2,261.00. El monto sin impuesto suma 49,815.50, igual a los subtotales de 1001–1005. Operaciones: unir, filtrar, agrupar/agregar y ordenar.

```sql
CREATE VIEW "qryVentasPorMes" AS
SELECT EXTRACT(YEAR FROM "Fecha") AS "Anio", EXTRACT(MONTH FROM "Fecha") AS "Mes",
       COUNT(*) AS "Facturas", SUM("Total") AS "TotalFacturado"
FROM "qryTotalesFactura"
WHERE "Estado" IN ('Emitida', 'Pagada')
GROUP BY EXTRACT(YEAR FROM "Fecha"), EXTRACT(MONTH FROM "Fecha");
```

```sql
SELECT * FROM "qryVentasPorMes" ORDER BY "Anio", "Mes";
```

Resultado: septiembre 2026, 5 facturas, 57,785.98. Operaciones: filtrar, transformar fecha, agrupar/agregar, ordenar.

Reto: copia del cálculo que incluye encabezados sin líneas; no reemplaza la vista original:

```sql
CREATE VIEW "qryTotalesConVacias" AS
SELECT f."IdFactura", f."NumeroFactura", f."Fecha", f."Estado", c."RazonSocial",
       CAST(COALESCE(s."Subtotal", 0) AS DECIMAL(18,4)) AS "Subtotal",
       f."TasaImpuesto",
       CAST(FLOOR(COALESCE(s."Subtotal", 0) * f."TasaImpuesto" * 100 + 0.5) / 100
            AS DECIMAL(18,4)) AS "Impuesto",
       CAST(COALESCE(s."Subtotal", 0) AS DECIMAL(18,4)) +
       CAST(FLOOR(COALESCE(s."Subtotal", 0) * f."TasaImpuesto" * 100 + 0.5) / 100
            AS DECIMAL(18,4)) AS "Total"
FROM "tblFacturas" f
JOIN "tblClientes" c ON c."IdCliente" = f."IdCliente"
LEFT JOIN "qrySubtotalesFactura" s ON s."IdFactura" = f."IdFactura";
```

Comprueba el reto con un borrador temporal sin líneas: solo la nueva vista debe mostrarlo, con cero en los tres montos. Elimina la prueba y restablece los siete encabezados originales.

## Respuestas de la autoevaluación

1. Agregar por clave (reduce).
2. Cada paso se prueba y reutiliza de forma independiente.
3. Habría que editar la consulta y las facturas antiguas cambiarían indebidamente.
4. La unión interna con subtotales excluye encabezados sin líneas.

Referencia: [Parámetros y SQL directo en Base](https://help.libreoffice.org/latest/es/text/sdatabase/02010100.html) y [funciones de HSQLDB 1.8](https://hsqldb.org/doc/1.8/guide/ch09.html).
