# Anexo técnico

Referencia de la base con HSQLDB incorporado que construye `modConstruirSolucion`: tablas, relaciones, consultas, módulos y errores. Los identificadores de tablas y campos se escriben entre comillas dobles; el archivo `.odb` contiene la base incorporada y los objetos de Base. El motor es el HSQLDB 1.8 que trae LibreOffice y necesita Java.

## Diccionario de datos

| Tabla | Campo | Tipo | Restricciones |
| --- | --- | --- | --- |
| tblClientes | IdCliente | INTEGER IDENTITY (START WITH 1) | Clave principal |
| tblClientes | DocumentoFiscal | VARCHAR(20) | Requerido, índice único |
| tblClientes | RazonSocial | VARCHAR(100) | Requerido |
| tblClientes | Direccion, Ciudad, Telefono | VARCHAR(150), VARCHAR(60), VARCHAR(20) | |
| tblClientes | Correo | VARCHAR(100) | Sin CHECK: HSQLDB 1.8 no puede validar el formato en el motor (ver límites) |
| tblClientes | FechaAlta | DATE | Predeterminado `CURRENT_DATE` |
| tblCategorias | IdCategoria | INTEGER | Clave principal |
| tblCategorias | Nombre | VARCHAR(50) | Requerido, índice único |
| tblCategorias | IdCategoriaPadre | INTEGER | Vacío en la raíz; relación reflexiva |
| tblProductos | IdProducto | INTEGER IDENTITY (START WITH 1) | Clave principal |
| tblProductos | Codigo | VARCHAR(15) | Requerido, índice único |
| tblProductos | Descripcion | VARCHAR(100) | Requerido |
| tblProductos | IdCategoria | INTEGER | Requerido |
| tblProductos | Precio | DECIMAL(18,4) | Requerido, CHECK >= 0 |
| tblProductos | Existencia | INTEGER | Predeterminado 0, CHECK >= 0 |
| tblProductos | Activo | BOOLEAN | Predeterminado TRUE |
| tblFacturas | IdFactura | INTEGER IDENTITY (START WITH 1) | Clave principal |
| tblFacturas | NumeroFactura | INTEGER | Índice único; vacío en borrador |
| tblFacturas | Fecha | DATE | Requerido, predeterminado `CURRENT_DATE` |
| tblFacturas | IdCliente | INTEGER | Requerido |
| tblFacturas | TasaImpuesto | DECIMAL(9,4) | Formato porcentaje, CHECK entre 0 y 1 |
| tblFacturas | Estado | VARCHAR(10) | Requerido, predeterminado Borrador, cuatro valores |
| tblFacturas | Observaciones | LONGVARCHAR | |
| tblDetalleFactura | IdFactura, IdProducto | INTEGER | Clave principal compuesta |
| tblDetalleFactura | Cantidad | INTEGER | Requerido, predeterminado 1, CHECK > 0 |
| tblDetalleFactura | PrecioUnitario | DECIMAL(18,4) | Requerido, CHECK >= 0 |
| tblHistorialPrecios | IdCambio | INTEGER IDENTITY (START WITH 1) | Clave principal; 0 significa «pila vacía» en el código |
| tblHistorialPrecios | IdProducto | INTEGER | Requerido |
| tblHistorialPrecios | PrecioAnterior | DECIMAL(18,4) | Requerido |
| tblHistorialPrecios | FechaCambio | TIMESTAMP | Requerido, predeterminado `CURRENT_TIMESTAMP` |
| tblParametros | Id | INTEGER | Clave principal, CHECK = 1 |
| tblParametros | NombreEmpresa, DocumentoFiscalEmpresa | VARCHAR(100), VARCHAR(20) | |
| tblParametros | TasaImpuesto | DECIMAL(9,4) | Formato porcentaje, CHECK entre 0 y 1 |

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

Diez consultas de solución se implementan como vistas de HSQLDB y aparecen junto a las tablas. `qryFacturasPorPeriodo` es una consulta parametrizada guardada de Base. En el recorrido manual el alumnado crea las vistas o consultas indicadas en cada laboratorio; el constructor del instructor reproduce sus resultados.

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
| modEstructuras.bas | Estudiante | Conexión aislada, cola, pila, árbol y diccionario | 5–6 |
| modConstantes.bas | Estudiante | Estados, dinero exacto y mensajes de error | 4, 6 y 8 |
| clsLineaFactura.bas | Estudiante | Línea inmutable, inicializable una sola vez | 8 |
| clsFactura_plantilla.bas | Estudiante | Pegar en módulo **clsFactura**; tres TODO | 8 |
| clsRepositorioFacturas.bas | Estudiante | Obtener, guardar y siguiente número | 8 |
| modPruebasObjetos.bas | Estudiante | Funciones de prueba, Subs `EjecutarFactura`, `EjecutarPruebas`, `EjecutarRepositorio` y evento Emitir | 8 |
| IDescuento.bas, clsSinDescuento.bas, clsDescuentoPorcentaje.bas, modPolimorfismo.bas | Estudiante | Contrato de `Descripcion`/`Calcular`; despacho con `Object` | 8, opcional |
| clsFactura.bas | Instructor | Factura completa | 8 |
| modConstruirSolucion.bas | Instructor | Construye la base de solución | Preparación |
| modSolucionesTareas.bas | Instructor | Soluciones de la tarea 6 | 6 |

## Configuración del origen de datos

El origen de datos no necesita propiedades especiales. Con HSQLDB incorporado, Base reconoce los parámetros con nombre de `qryFacturasPorPeriodo` (`:FechaInicial`, `:FechaFinal`) siempre que la consulta no use SQL directo. Lo que sí hace falta es Java: sin un entorno de ejecución seleccionado en Herramientas → Opciones → LibreOffice → Avanzadas, la base no abre.

## Límites de HSQLDB 1.8

| Límite | Consecuencia en el curso |
| --- | --- |
| `CHECK`, `UNIQUE` y `FOREIGN KEY` solo se aceptan como restricciones de tabla | Todas las restricciones se escriben después de los campos, con nombre |
| Dentro de un `CHECK`, `LIKE` rechaza cualquier valor; `POSITION` funciona, pero la base ya no se puede reabrir, y `LOCATE` o `SUBSTRING` ni siquiera se pueden crear | El correo no lleva `CHECK`; su formato se validaría en el formulario o en Basic |
| Una identidad sin `START WITH 1` empieza en 0 | Todas las identidades declaran `(START WITH 1)` |
| Tras insertar IDs explícitos, la identidad continúa en el máximo más uno | No hace falta `RESTART` después de importar; `RESTART WITH n` haría que el siguiente valor fuera `n` |
| Cada `CREATE` o `ALTER` confirma la transacción en curso | El constructor crea las tablas, carga los datos en una transacción y crea las vistas después; si falla, se usa otro `.odb` vacío |
| No acepta literales `DATE '2026-09-01'` | Las fechas se escriben como texto ISO, `'2026-09-01'` |
| `ROUND` calcula en coma flotante binaria | El impuesto se redondea con `CAST(FLOOR(x * 100 + 0.5) / 100 AS DECIMAL(18,4))` |
| No hay `SELECT … FOR UPDATE` ni bloqueo de filas | El curso es de un solo usuario; los `UPDATE` comprueban el estado esperado en su `WHERE` |
| No hay consultas recursivas ni triggers en SQL | El árbol se recorre con Basic; las reglas de negocio viven en las clases |
| Limitar filas | `… ORDER BY … LIMIT 1` |

## Persistencia y límites de la API

Los módulos viven en `Standard` del documento. `ConexionBase(Optional conexion)` obtiene una conexión SDBC aislada del origen de datos de Base o acepta una conexión aislada ya abierta. La conexión compartida `ActiveConnection` del formulario pertenece a la interfaz y no permite cambiar auto commit. La conexión aislada permite que el repositorio controle su transacción. `clsRepositorioFacturas.Inicializar(conexion)` precede a `Obtener(id)`, `Guardar(factura)` o `SiguienteNumero()`.

Las consultas del repositorio son sentencias preparadas. Las operaciones relacionadas se confirman en una transacción SDBC; si fallan, se hace rollback. Los precios se enlazan con la conversión decimal exacta del kit. `CerrarConexionBase()` libera la conexión aislada que administra el kit; no cierre desde el repositorio la conexión que le prestó el llamador. `NumeroFactura` usa el máximo número comercial actual más uno; para usuarios concurrentes se requiere otro diseño de asignación. La restricción única sigue siendo necesaria.

La identidad técnica `IdFactura` la asigna HSQLDB al insertar la factura sin ese campo. El repositorio la lee con `CALL IDENTITY()` en la misma conexión y la asigna al objeto después del commit. No se calcula con `MAX(IdFactura)`: `CALL IDENTITY()` devuelve el valor que generó esa conexión, aunque otra inserte facturas al mismo tiempo. Un rollback puede dejar huecos; la identidad técnica no es el número comercial `NumeroFactura`.

`Cargar` y `AsignarId` son públicos porque Basic no ofrece `Friend`; forman el protocolo técnico del repositorio. `Cargar` solo acepta una instancia nueva (Id 0, número 0, estado Borrador), valida su encabezado y no puede reabrir una factura emitida. `AsignarId` acepta una identidad positiva y rechaza cambiar una identidad ya asignada. Un uso inválido produce 3010. Estas guardas protegen la reconstrucción; el formulario utiliza las operaciones de negocio. La base didáctica local sigue permitiendo editar tablas y código directamente.

`CalcularPorcentajeMoneda(subtotal As Currency, tasa As Currency)` calcula el porcentaje; `RedondearMoneda(valor As Currency)` redondea un importe. Ambos redondean mitades hacia arriba para importes no negativos, igual que `FLOOR(x * 100 + 0.5) / 100` en las vistas monetarias del curso. La implementación mantiene la aritmética decimal exacta sin depender de conversiones decimales que no estén implementadas en todos los sistemas. `Currency` conserva cuatro decimales. Los formatos de pantalla a dos decimales no sustituyen tipos exactos ni redondeo explícito.

## Errores de negocio

Todos los módulos del kit activan `Option VBASupport 1`. Este modo permite el objeto `Err` de LibreOffice Basic: `Err.Raise numero, "Curso", MensajeError(numero)` genera un error personalizado con el número y mensaje del curso. El manejador captura `Err.Number` y `Err.Description`. Para los códigos propios se usa `Err.Raise`; la instrucción `Error n` se reserva a errores predefinidos. Consulta la [documentación oficial](https://help.libreoffice.org/latest/es/text/sbasic/shared/ErrVBA.html). Las clases siguen siendo Basic y la persistencia usa UNO/SDBC; el modo de compatibilidad no proporciona DAO ni `Implements`.

| Número | Clase o módulo | Significado |
| --- | --- | --- |
| 2001 | Factura | Cliente no válido |
| 2002 | Factura | Tasa fuera de 0 a 1 |
| 2003 | Factura | Producto repetido |
| 2004 | Factura | Emitir sin cliente |
| 2005 | Factura | Emitir sin líneas |
| 2006 | Factura | Pagar una factura no emitida |
| 2007 | Factura | Anular una factura no emitida |
| 2008 | Factura | Quitar un producto ausente |
| 2009 | Factura | Operación que exige borrador |
| 2010 | Factura | Número de emisión no positivo |
| 2100 | LineaFactura | Producto no válido |
| 2101 | LineaFactura | Cantidad no positiva |
| 2102 | LineaFactura | Precio negativo |
| 2103 | LineaFactura | Intento de reinicializar una línea |
| 3001 | RepositorioFacturas | Factura inexistente |
| 3002 | RepositorioFacturas | Intento de guardar dentro de otra transacción |
| 3003 | RepositorioFacturas | Cambio de datos protegidos de una factura emitida |
| 3010 | Factura | Reconstrucción fuera de una instancia nueva, encabezado inválido o intento de cambiar identidad |
| 3011 | RepositorioFacturas | HSQLDB no devolvió la identidad de la factura nueva |
| 4001 | DescuentoPorcentaje | Porcentaje fuera de 0 a 1 |
| 4101 | Helpers monetarios | Importe negativo fuera del dominio del cálculo |
| 4102 | MonedaDesdeSQL | Texto decimal SQL inválido o con más de cuatro decimales |
| 4201 | modRegistros | Tamaño de catálogo menor que 1 |
| 6001 | Estructuras | Precio negativo |
| 6002 | Estructuras | Producto inexistente |
| 6003 | Árbol | Ciclo en categorías |
| 6004 | Árbol | Categoría inexistente |
| 7001 | Constructor | La base de solución no está vacía |

Los fallos de UNO/SDBC, como una clave duplicada o una FK violada, pueden traer además un texto del motor. El manejador los informa y la transacción revierte sus cambios; no asigne un código de regla a un fallo sin identificarlo.

## Datos de ejemplo

8 clientes, 15 productos, 11 categorías y 7 facturas con 16 líneas. Los totales esperados por factura están en los puntos de control del laboratorio 4; la venta emitida y pagada suma 57,785.98 y el siguiente número de factura es 1007.
