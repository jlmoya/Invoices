# Sesión 4 · Consultas

El momento clave es ver que `qryTotalesFactura` encadena transformar, agregar y unir: el razonamiento de un ciclo, sin escribir el ciclo.

## Agenda (120 min)

| Minutos | Actividad | Notas |
| --- | --- | --- |
| 0–10 | Tabla de operaciones sobre colecciones | Pide el equivalente en el lenguaje que conocen |
| 10–20 | Parte A: `tblParametros` | La regla `=1` crea un registro único |
| 20–35 | Parte B: importe | Compara cuadrícula y vista SQL |
| 35–50 | Parte C: subtotal | |
| 50–70 | Parte D: totales | Contrasta con la tabla de puntos de control |
| 70–85 | Parte E: ventas por cliente | |
| 85–100 | Parte F: parámetros | |
| 100–120 | Redondeo bancario; tarea 4 | |

## Guion

Escribe el ciclo equivalente junto al SQL:

```text
para cada línea: importe = cantidad × precio          (transformar)
para cada factura: subtotal = suma de sus importes     (agregar por clave)
para cada factura: unir cliente, impuesto y total      (unir)
```

## Preguntas para la discusión

| Pregunta | Respuesta esperada |
| --- | --- |
| ¿Por qué `CCur(Round(…))`? | `Round` devuelve Doble; `CCur` lo vuelve Moneda exacta |
| ¿Qué pasa si la tasa cambia mañana? | Cada factura guarda su tasa; solo cambian las nuevas |
| ¿Por qué el borrador aparece en totales y no en ventas? | Ventas filtra Emitida y Pagada |

## Errores frecuentes

| Síntoma | Causa | Solución |
| --- | --- | --- |
| «Error de sintaxis en la operación JOIN» | Faltan paréntesis con tres tablas | Copiar el `FROM` de la guía |
| Access pide un parámetro inesperado | Un nombre de campo mal escrito | Revisar el nombre que muestra el cuadro |
| Totales duplicados | Unir el detalle antes de agregar | Agregar primero, unir después |
| Tasa de 1600 % | Se escribió 16 sin el signo % | Escribir `16%` |
| El periodo no devuelve nada | Fechas en otro formato | Escribirlas como las muestra Windows |

## Solución de la tarea 4

```sql
SELECT l.Codigo, l.Descripcion, Sum(l.Cantidad) AS Unidades, Sum(l.Importe) AS Monto
FROM qryLineasConImporte AS l
     INNER JOIN tblFacturas AS f ON l.IdFactura = f.IdFactura
WHERE f.Estado IN ('Emitida', 'Pagada')
GROUP BY l.Codigo, l.Descripcion
ORDER BY Sum(l.Importe) DESC;
```

Resultado: 11 productos. Encabezan POR-001 (2 unidades, 31,998.00), PER-001 (8,697.00) y PER-004 (3,299.00); PAP-001 suma 19 unidades y 2,261.00. El total es 49,815.50, igual a la suma de los subtotales de las facturas 1001 a 1005.

```sql
SELECT Year(Fecha) AS Anio, Month(Fecha) AS Mes,
       Count(*) AS Facturas, Sum(Total) AS TotalFacturado
FROM qryTotalesFactura
WHERE Estado IN ('Emitida', 'Pagada')
GROUP BY Year(Fecha), Month(Fecha)
ORDER BY Year(Fecha), Month(Fecha);
```

Resultado: septiembre de 2026, 5 facturas, 57,785.98.

Reto, facturas sin líneas con total 0:

```sql
SELECT f.IdFactura, f.NumeroFactura, c.RazonSocial,
       Nz(s.Subtotal, 0) AS Subtotal,
       CCur(Round(Nz(s.Subtotal, 0) * f.TasaImpuesto, 2)) AS Impuesto,
       Nz(s.Subtotal, 0) + CCur(Round(Nz(s.Subtotal, 0) * f.TasaImpuesto, 2)) AS Total
FROM (tblClientes AS c
      INNER JOIN tblFacturas AS f ON c.IdCliente = f.IdCliente)
      LEFT JOIN qrySubtotalesFactura AS s ON f.IdFactura = s.IdFactura;
```

## Respuestas de la autoevaluación

1. Agregar por clave (reduce).
2. Cada paso se prueba por separado y se reutiliza en otras consultas e informes.
3. Habría que editar la consulta, y las facturas antiguas cambiarían de total.
4. La unión interna con los subtotales deja fuera a las facturas sin líneas.
