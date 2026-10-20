# Verificación de la adaptación a LibreOffice

Fecha: 20 de octubre de 2026. Entorno nativo: macOS sobre Apple Silicon, LibreOffice 26.8.0.3 con HSQLDB incorporado 1.8.0 y Java SE 25.0.4.1 (arm64), que un perfil nuevo selecciona solo. No se instaló software ni se cambió el perfil personal de LibreOffice: cada ejecución empleó un perfil y una base temporales.

## Cambio de motor

La verificación del 13 de octubre usó Firebird incorporado 3.0.13, pero creó la base mediante la API (`sdbc:embedded:firebird`), sin pasar por el asistente. En una instalación normal, el asistente de base nueva solo ofrece «Firebird incorporado» con las funcionalidades experimentales activadas. El código de LibreOffice lo filtra en `dbaccess/source/ui/dlg/generalpage.cxx` mientras `ExperimentalMode` esté desactivado. La base de datos incorporada predeterminada es «HSQLDB incorporado». El curso no debe depender de opciones experimentales, así que se migró a HSQLDB y esta verificación reemplaza a la anterior.

## Materiales

- 50 archivos del curso Access conservados byte por byte frente al commit `eeb582de08160fbbfc9798a1ef4b0e3a843e0e3a`.
- 50 archivos equivalentes en el curso LibreOffice: mismas guías y sesiones, cinco SVG, seis CSV y catorce módulos Basic (once para estudiante y tres para instructor).
- Datos CSV equivalentes al original tras convertir Windows-1252/CRLF a UTF-8/LF.
- SVG válidos y 52 enlaces locales existentes.

## Ejecución nativa del kit

La [salida de la solución](evidencias/libreoffice-solucion.txt) registra 33 comprobaciones correctas de factura, reglas y repositorio. Las diez del repositorio se repitieron desde macros guardadas en el documento y con su conexión predeterminada, para un total de 53 mensajes Correcto y cero FALLA.

Se comprobó:

- Constructor: siete tablas, seis relaciones, diez vistas del motor y una consulta parametrizada de Base.
- Identidades: tras los IDs explícitos de la carga, la siguiente alta recibe 9 en clientes y 16 en productos.
- Factura 1003: subtotal 9146.70, impuesto 1463.47 y total 10610.17.
- Rechazo de estados inválidos, duplicación de productos, cantidades y precios inválidos, cambios posteriores a emitir y reinicialización de líneas.
- Precisión del helper monetario hasta el límite de `DECIMAL(18,4)` y redondeo en la mitad y justo por debajo.
- Alta, recarga, modificación de detalle, identidad estable con `CALL IDENTITY()` y líneas reconstruidas en distinto orden.
- Rollback de cabecera y detalle por una clave foránea inválida y rechazo de un número duplicado.
- Búsqueda lineal de 1000 pasos frente a binaria de 10, polimorfismo de descuentos, rutas y profundidades del árbol.
- Diccionario de 14 códigos, PAP-001 con 19 unidades, dos cambios de precio y dos deshacer, cola con 1002 al frente.
- Ventas emitidas y pagadas: 57785.98. Consulta por septiembre: siete facturas con `:FechaInicial` y `:FechaFinal`, sin ninguna configuración especial del origen de datos.
- Guardado, cierre y reapertura del `.odb`: siete facturas conservadas; ejecución de las macros almacenadas dentro del documento y de la conexión aislada predeterminada.
- Compilación del código completo de eventos y generación de informe incluido en la guía del laboratorio 5.

La [salida de la plantilla](evidencias/libreoffice-plantilla.txt) confirma que se detectan los tres ejercicios incompletos: subtotal, validaciones de emisión y anulación. El verificador exige esos fallos concretos y comprueba que la regla de línea inmutable siga funcionando.

## Recorrido SQL de las guías

El constructor no es lo que ejecutan los estudiantes. `scripts/verificar_sql_guias.py` recorre, en el orden del curso, todos los bloques SQL de los laboratorios 2 a 6 y las soluciones de las sesiones 2 a 4 del instructor. Carga los CSV donde las guías piden importarlos con Calc y prueba los rechazos que las guías anuncian. Después compara `qryTotalesFactura` con la tabla de puntos de control del laboratorio 4, y vuelve a comprobar todo tras guardar, cerrar y reabrir el `.odb`.

La [salida del recorrido](evidencias/libreoffice-sql-guias.txt) registra 124 pasos correctos:

- Restricciones: precio y existencia negativos, nulo obligatorio, documento repetido, referencia huérfana, producto inexistente, borrado de un cliente con facturas, cantidad cero, estado `Revisada` y segundo registro de `tblParametros`. Todos se rechazan con la restricción esperada.
- Identidades: 9 en clientes y 16 en productos después de importar, y 8 en facturas; borrar el encabezado de prueba elimina su línea por la cascada.
- `qryFacturasPorPeriodo` del 1 al 10 de septiembre devuelve 1001 a 1004.
- `qryTotalesFactura` coincide con los puntos de control, y `qryFacturaImpresion` trae 16 líneas con el emisor, antes y después de reabrir la base.

## Repetir las comprobaciones

Desde la raíz del repositorio, con Python 3, LibreOffice y Java instalados:

```bash
python3 scripts/verificar_materiales.py --access-baseline eeb582d
python3 scripts/verificar_libreoffice.py
python3 scripts/verificar_libreoffice.py --plantilla
python3 scripts/verificar_sql_guias.py
```

Si `soffice` no está en PATH ni en la ubicación habitual de macOS, añade `--soffice` con su ruta. Los scripts imprimen la ubicación del perfil, la base y los resultados temporales, y conservan los artefactos para inspección. La opción `--plantilla` considera correctos los fallos esperados de los ejercicios.

## Alcance de la validación

Las ejecuciones anteriores verifican código, datos, consultas y persistencia sobre el motor real instalado, sin interfaz. Quedan para el ensayo previo del instructor que exige su guía:

- El asistente para bases de datos y la elección de «HSQLDB incorporado». Los textos de las guías se tomaron de la traducción oficial al español de LibreOffice, pero no se recorrió la interfaz.
- El pegado desde Calc con «Copiar tabla». El script inserta las mismas filas con SQL.
- El diálogo de parámetros de la interfaz. Se probó el mismo SQL con parámetros; un `RowSet` sin interfaz no aplica los parámetros con ningún motor, así que no sirve como prueba.
- Formularios, eventos visuales, diseño de páginas y generación de informes con Java.

Tampoco se afirma haber ejecutado el curso en Windows o Linux: sus instrucciones y rutas están adaptadas, pero la prueba nativa registrada corresponde a macOS.

## Decisiones respaldadas por las pruebas

HSQLDB 1.8 impuso estas decisiones, cada una comprobada en el motor que trae LibreOffice:

- `CHECK`, `UNIQUE` y `FOREIGN KEY` solo se aceptan como restricciones de tabla.
- Dentro de un `CHECK`, `LIKE` rechaza cualquier valor. Con `POSITION` la base no puede reabrirse, porque el motor guarda una definición que luego no lee, y `LOCATE` o `SUBSTRING` ni siquiera se pueden crear. Por eso `tblClientes` y `tblProveedores` no validan el formato del correo en el motor.
- Una identidad sin `START WITH 1` empieza en 0, y el código usa 0 para «sin valor»: todas declaran `(START WITH 1)`. Tras insertar IDs explícitos, la identidad continúa en el máximo más uno, así que desaparecen los `RESTART` de Firebird.
- Cada `CREATE` o `ALTER` confirma la transacción en curso. El constructor crea las tablas, carga los datos en una transacción y crea las vistas después.
- No hay literales `DATE '…'`: las fechas se escriben como texto ISO.
- `ROUND` calcula en coma flotante y falló en 1600 de unos dos millones de impuestos de prueba, con cinco tasas distintas. `FLOOR(x * 100 + 0.5) / 100`, convertido a `DECIMAL(18,4)`, no falló en ninguno y coincide con `RedondearMoneda`.
- No hay `SELECT … FOR UPDATE`. Los `UPDATE` comprueban el estado esperado en su `WHERE`, y la identidad nueva se lee con `CALL IDENTITY()` en la misma conexión.
- No hay consultas recursivas: el árbol se recorre con Basic.
- Base reconoce los parámetros con nombre de una consulta guardada sin la sustitución especial que exigía Firebird, que además no se ofrece para HSQLDB incorporado.

Siguen vigentes las decisiones previas: `CDec` no se implementa en macOS/Linux, así que el kit usa dígitos decimales y `Currency`. Los errores propios usan `Option VBASupport 1` y `Err.Raise`. Las transacciones necesitan una conexión aislada, y el constructor renueva el objeto de sentencia después de cada DDL.
