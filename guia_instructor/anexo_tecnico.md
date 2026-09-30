# Anexo técnico

Referencia de la base de solución que construye `modConstruirSolucion`: tablas, relaciones, consultas, módulos y errores.

## Diccionario de datos

| Tabla | Campo | Tipo | Restricciones |
| --- | --- | --- | --- |
| tblClientes | IdCliente | Autonumeración | Clave principal |
| tblClientes | DocumentoFiscal | Texto 20 | Requerido, índice único |
| tblClientes | RazonSocial | Texto 100 | Requerido |
| tblClientes | Direccion, Ciudad, Telefono | Texto 150, 60 y 20 | |
| tblClientes | Correo | Texto 100 | `Like '*@*.*' Or Is Null` |
| tblClientes | FechaAlta | Fecha/Hora | Predeterminado `Date()` |
| tblCategorias | IdCategoria | Entero largo | Clave principal |
| tblCategorias | Nombre | Texto 50 | Requerido, índice único |
| tblCategorias | IdCategoriaPadre | Entero largo | Vacío en la raíz; relación reflexiva |
| tblProductos | IdProducto | Autonumeración | Clave principal |
| tblProductos | Codigo | Texto 15 | Requerido, índice único |
| tblProductos | Descripcion | Texto 100 | Requerido |
| tblProductos | IdCategoria | Entero largo | Requerido |
| tblProductos | Precio | Moneda | Requerido, `>=0` |
| tblProductos | Existencia | Entero largo | Predeterminado 0, `>=0` |
| tblProductos | Activo | Sí/No | Predeterminado verdadero |
| tblFacturas | IdFactura | Autonumeración | Clave principal |
| tblFacturas | NumeroFactura | Entero largo | Índice único; vacío en borrador |
| tblFacturas | Fecha | Fecha/Hora | Requerido, predeterminado `Date()` |
| tblFacturas | IdCliente | Entero largo | Requerido |
| tblFacturas | TasaImpuesto | Doble | Formato porcentaje, `Between 0 And 1` |
| tblFacturas | Estado | Texto 10 | Requerido, predeterminado Borrador, cuatro valores |
| tblFacturas | Observaciones | Texto largo | |
| tblDetalleFactura | IdFactura, IdProducto | Entero largo | Clave principal compuesta |
| tblDetalleFactura | Cantidad | Entero largo | Requerido, predeterminado 1, `>0` |
| tblDetalleFactura | PrecioUnitario | Moneda | Requerido, `>=0` |
| tblHistorialPrecios | IdCambio | Autonumeración | Clave principal |
| tblHistorialPrecios | IdProducto | Entero largo | Requerido |
| tblHistorialPrecios | PrecioAnterior | Moneda | Requerido |
| tblHistorialPrecios | FechaCambio | Fecha/Hora | Predeterminado `Now()` |
| tblParametros | Id | Entero largo | Clave principal, `=1` |
| tblParametros | NombreEmpresa, DocumentoFiscalEmpresa | Texto 100 y 20 | |
| tblParametros | TasaImpuesto | Doble | Formato porcentaje, `Between 0 And 1` |

## Relaciones

| Padre | Hija | Campos | Cascada |
| --- | --- | --- | --- |
| tblClientes | tblFacturas | IdCliente | No |
| tblFacturas | tblDetalleFactura | IdFactura | Eliminación en cascada |
| tblProductos | tblDetalleFactura | IdProducto | No |
| tblCategorias | tblProductos | IdCategoria | No |
| tblCategorias | tblCategorias | IdCategoria → IdCategoriaPadre | No |
| tblProductos | tblHistorialPrecios | IdProducto | No |

## Consultas

| Consulta | Qué hace | Sesión |
| --- | --- | --- |
| qryLineasConImporte | Importe de cada línea | 4 |
| qrySubtotalesFactura | Subtotal por factura | 4 |
| qryTotalesFactura | Subtotal, impuesto y total por factura | 4 |
| qryVentasPorCliente | Ventas emitidas y pagadas por cliente | 4 |
| qryFacturasPorPeriodo | Facturas entre dos fechas | 4 |
| qryFacturaImpresion | Origen del informe `rptFactura` | 5 |
| qryColaCobranza | Cola de facturas emitidas | 6 |
| qryCategoriasHoja | Categorías sin hijos | 6 |
| qryProductosConPadre | Producto con su categoría padre | 6 |
| qryVentasPorProducto | Solución de la tarea 4 | 4 |
| qryVentasPorMes | Solución de la tarea 4 | 4 |

## Módulos y clases

| Archivo | Kit | Contenido | Sesión |
| --- | --- | --- | --- |
| modRegistros.bas | Estudiante | Registro `TProducto`, búsqueda lineal y binaria | 2 |
| modEstructuras.bas | Estudiante | Cola, pila, árbol y diccionario | 6 |
| modConstantes.bas | Estudiante | Estados de la factura | 8 |
| clsLineaFactura.cls | Estudiante | Línea de factura inmutable | 8 |
| clsFactura_plantilla.cls | Estudiante | Factura con tres TODO | 8 |
| clsRepositorioFacturas.cls | Estudiante | Obtener, guardar y siguiente número | 8 |
| modPruebasObjetos.bas | Estudiante | `ProbarFactura`, `ProbarReglas`, `ProbarRepositorio` | 8 |
| IDescuento.cls, clsSinDescuento.cls, clsDescuentoPorcentaje.cls, modPolimorfismo.bas | Estudiante | Polimorfismo con `Implements` | 8, opcional |
| clsFactura.cls | Instructor | Factura completa | 8 |
| modConstruirSolucion.bas | Instructor | Construye la base de solución | Preparación |
| modSolucionesTareas.bas | Instructor | Soluciones de la tarea 6 | 6 |

## Errores de negocio de las clases

| Número | Clase | Significado |
| --- | --- | --- |
| vbObjectError + 1001 | LineaFactura | Cantidad menor o igual a cero |
| vbObjectError + 1002 | LineaFactura | Precio negativo |
| vbObjectError + 2000 | Factura | Operación no permitida fuera de borrador |
| vbObjectError + 2001 | Factura | Cliente no válido |
| vbObjectError + 2002 | Factura | Tasa fuera de 0 a 1 |
| vbObjectError + 2003 | Factura | Producto repetido en la factura |
| vbObjectError + 2004 | Factura | Emitir sin cliente |
| vbObjectError + 2005 | Factura | Emitir sin líneas |
| vbObjectError + 2006 | Factura | Pagar una factura no emitida |
| vbObjectError + 2007 | Factura | Anular una factura no emitida |
| vbObjectError + 2008 | Factura | Quitar un producto que no está |
| vbObjectError + 3001 | RepositorioFacturas | La factura no existe |

## Datos de ejemplo

8 clientes, 15 productos, 11 categorías y 7 facturas con 16 líneas. Los totales esperados por factura están en los puntos de control del laboratorio 4; la venta emitida y pagada suma 57,785.98 y el siguiente número de factura es 1007.
