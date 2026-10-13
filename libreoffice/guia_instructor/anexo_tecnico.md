# Anexo técnico

Referencia de la base Firebird integrada que construye `modConstruirSolucion`: tablas, relaciones, consultas, módulos y errores. Los identificadores de tablas y campos se escriben entre comillas dobles; el archivo `.odb` contiene el motor integrado y los objetos de Base.

## Diccionario de datos

| Tabla | Campo | Tipo | Restricciones |
| --- | --- | --- | --- |
| tblClientes | IdCliente | INTEGER IDENTITY | Clave principal |
| tblClientes | DocumentoFiscal | VARCHAR(20) | Requerido, índice único |
| tblClientes | RazonSocial | VARCHAR(100) | Requerido |
| tblClientes | Direccion, Ciudad, Telefono | VARCHAR(150), VARCHAR(60), VARCHAR(20) | |
| tblClientes | Correo | VARCHAR(100) | CHECK con `LIKE '%@%.%' OR … IS NULL` (validación didáctica) |
| tblClientes | FechaAlta | DATE | Predeterminado `CURRENT_DATE` |
| tblCategorias | IdCategoria | INTEGER | Clave principal |
| tblCategorias | Nombre | VARCHAR(50) | Requerido, índice único |
| tblCategorias | IdCategoriaPadre | INTEGER | Vacío en la raíz; relación reflexiva |
| tblProductos | IdProducto | INTEGER IDENTITY | Clave principal |
| tblProductos | Codigo | VARCHAR(15) | Requerido, índice único |
| tblProductos | Descripcion | VARCHAR(100) | Requerido |
| tblProductos | IdCategoria | INTEGER | Requerido |
| tblProductos | Precio | DECIMAL(18,4) | Requerido, CHECK >= 0 |
| tblProductos | Existencia | INTEGER | Predeterminado 0, CHECK >= 0 |
| tblProductos | Activo | BOOLEAN | Predeterminado TRUE |
| tblFacturas | IdFactura | INTEGER IDENTITY | Clave principal |
| tblFacturas | NumeroFactura | INTEGER | Índice único; vacío en borrador |
| tblFacturas | Fecha | DATE | Requerido, predeterminado `CURRENT_DATE` |
| tblFacturas | IdCliente | INTEGER | Requerido |
| tblFacturas | TasaImpuesto | DECIMAL(9,4) | Formato porcentaje, CHECK entre 0 y 1 |
| tblFacturas | Estado | VARCHAR(10) | Requerido, predeterminado Borrador, cuatro valores |
| tblFacturas | Observaciones | BLOB SUB_TYPE TEXT | |
| tblDetalleFactura | IdFactura, IdProducto | INTEGER | Clave principal compuesta |
| tblDetalleFactura | Cantidad | INTEGER | Requerido, predeterminado 1, CHECK > 0 |
| tblDetalleFactura | PrecioUnitario | DECIMAL(18,4) | Requerido, CHECK >= 0 |
| tblHistorialPrecios | IdCambio | INTEGER IDENTITY | Clave principal |
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

Diez consultas de solución se implementan como vistas Firebird y aparecen junto a las tablas. `qryFacturasPorPeriodo` es una consulta parametrizada guardada de Base. En el recorrido manual el alumnado crea las vistas o consultas indicadas en cada laboratorio; el constructor del instructor reproduce sus resultados.

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
| modEstructuras.bas | Estudiante | Conexión aislada, parámetros nombrados, cola, pila, árbol y diccionario | 4–6 |
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

| Propiedad en `DataSource.Info` | Valor | Función |
| --- | --- | --- |
| `ParameterNameSubstitution` | `True` | Base sustituye `:FechaInicial` y otros parámetros nombrados por los marcadores `?` del controlador Firebird |

`ConfigurarParametrosBase(documento)` conserva las demás propiedades de `Info` al establecer esta opción. `ConexionBase()` la aplica antes de abrir su primera conexión aislada. Para prepararla desde la interfaz, ejecuta `EjecutarConfiguracionParametros`: guarda el documento y muestra la confirmación. Si ya existían conexiones, cierra el `.odb` y sus ventanas y vuelve a abrirlo antes de probar la consulta parametrizada; cambiar `Info` no reconfigura una conexión abierta. Una conexión explícita recibida por las pruebas se prepara antes por su llamador.

## Persistencia y límites de la API

Los módulos viven en `Standard` del documento. `ConexionBase(Optional conexion)` obtiene una conexión SDBC aislada del origen de datos de Base o acepta una conexión aislada ya abierta. La conexión compartida `ActiveConnection` del formulario pertenece a la interfaz y no permite cambiar auto commit. La conexión aislada permite que el repositorio controle su transacción. `clsRepositorioFacturas.Inicializar(conexion)` precede a `Obtener(id)`, `Guardar(factura)` o `SiguienteNumero()`.

Las consultas del repositorio son sentencias preparadas. Las operaciones relacionadas se confirman en una transacción SDBC; si fallan, se hace rollback. Los precios se enlazan con la conversión decimal exacta del kit. `CerrarConexionBase()` libera la conexión aislada que administra el kit; no cierre desde el repositorio la conexión que le prestó el llamador. `NumeroFactura` usa el máximo número comercial actual más uno; para usuarios concurrentes se requiere otro diseño de asignación. La restricción única sigue siendo necesaria.

La identidad técnica `IdFactura` se reserva de forma atómica con `GEN_ID` sobre el generador IDENTITY que el repositorio encuentra mediante `RDB$GENERATOR_NAME`. Se inserta ese Id de manera explícita y se asigna al objeto después del commit. No se calcula con `MAX(IdFactura)`: el controlador Firebird integrado no abre el cursor necesario para `INSERT … RETURNING`. Una reserva puede dejar huecos tras un rollback; la identidad técnica no es el número comercial `NumeroFactura`.

`Cargar` y `AsignarId` son públicos porque Basic no ofrece `Friend`; forman el protocolo técnico del repositorio. `Cargar` solo acepta una instancia nueva (Id 0, número 0, estado Borrador), valida su encabezado y no puede reabrir una factura emitida. `AsignarId` acepta una identidad positiva y rechaza cambiar una identidad ya asignada. Un uso inválido produce 3010. Estas guardas protegen la reconstrucción; el formulario utiliza las operaciones de negocio. La base didáctica local sigue permitiendo editar tablas y código directamente.

`CalcularPorcentajeMoneda(subtotal As Currency, tasa As Currency)` calcula el porcentaje; `RedondearMoneda(valor As Currency)` redondea un importe. Ambos redondean mitades hacia arriba para importes no negativos, igual que `ROUND(..., 2)` en las consultas monetarias del curso. La implementación mantiene la aritmética decimal exacta sin depender de conversiones decimales que no estén implementadas en todos los sistemas. `Currency` conserva cuatro decimales. Los formatos de pantalla a dos decimales no sustituyen tipos exactos ni redondeo explícito.

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
| 3011 | RepositorioFacturas | No se encontró el generador IDENTITY de `tblFacturas` |
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
