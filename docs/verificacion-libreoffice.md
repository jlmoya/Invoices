# Verificación de la adaptación a LibreOffice

Fecha: 13 de octubre de 2026. Entorno nativo: macOS sobre Apple Silicon, LibreOffice 26.8.0.3 y Firebird integrado 3.0.13. No se instaló software ni se cambió el perfil personal de LibreOffice: cada ejecución empleó un perfil y una base temporales.

## Materiales

- 50 archivos del curso Access conservados byte por byte frente al commit `eeb582de08160fbbfc9798a1ef4b0e3a843e0e3a`.
- 50 archivos equivalentes en el curso LibreOffice: mismas guías y sesiones, cinco SVG, seis CSV y catorce módulos Basic (once para estudiante y tres para instructor).
- Datos CSV equivalentes al original tras convertir Windows-1252/CRLF a UTF-8/LF.
- SVG válidos, enlaces locales existentes y exactamente tres TODO en la plantilla del estudiante.
- Guías revisadas frente a los nombres de módulos, opciones, errores, esquema, consultas y APIs finales.

## Ejecución nativa

La [salida de la solución](evidencias/libreoffice-solucion.txt) registra 33 comprobaciones correctas de factura, reglas y repositorio. Las diez del repositorio se repitieron desde macros guardadas en el documento y con su conexión predeterminada, para un total de 53 mensajes Correcto y cero FALLA.

Se comprobó:

- Constructor: siete tablas, seis relaciones, diez vistas del motor y una consulta parametrizada de Base.
- Factura 1003: subtotal 9146.70, impuesto 1463.47 y total 10610.17.
- Rechazo de estados inválidos, duplicación de productos, cantidades/precios inválidos, cambios posteriores a emitir y reinicialización de líneas.
- Precisión del helper monetario hasta el límite de `DECIMAL(18,4)` y redondeo en la mitad y justo por debajo.
- Alta, recarga, modificación de detalle, identidad estable y líneas reconstruidas en distinto orden.
- Rollback de cabecera y detalle por una clave foránea inválida y rechazo de un número duplicado.
- Búsqueda lineal de 1000 pasos frente a binaria de 10, polimorfismo de descuentos, rutas y profundidades del árbol.
- Diccionario de 14 códigos, PAP-001 con 19 unidades, dos cambios de precio y dos deshacer, cola con 1002 al frente.
- Ventas emitidas/pagadas: 57785.98. Consulta por septiembre: siete facturas, tras sustituir parámetros con el compositor SQL de Base y enlazar fechas.
- Guardado, cierre y reapertura del `.odb`: siete facturas conservadas; ejecución de las macros almacenadas dentro del documento y conexión aislada predeterminada.
- Compilación del código completo de eventos y generación de informe incluido en la guía del laboratorio 5.

La [salida de la plantilla](evidencias/libreoffice-plantilla.txt) confirma que los tres ejercicios incompletos se detectan: subtotal, validaciones de emisión y anulación. El verificador exige esos fallos concretos y comprueba que la regla de línea inmutable siga funcionando.

## Repetir las comprobaciones

Desde la raíz del repositorio, con Python 3 y LibreOffice instalados:

```bash
python3 scripts/verificar_materiales.py --access-baseline eeb582d
python3 scripts/verificar_libreoffice.py
python3 scripts/verificar_libreoffice.py --plantilla
```

Si `soffice` no está en PATH ni en la ubicación habitual de macOS, añade `--soffice` con su ruta. Los scripts imprimen la ubicación del perfil, la base y los resultados temporales; conservan los artefactos para inspección. La opción `--plantilla` considera correctos los fallos esperados de los ejercicios.

## Alcance de la validación

La ejecución anterior verifica código, datos, consultas y persistencia sobre el motor real instalado. Se revisaron las instrucciones y APIs de formularios e informes y se compiló su código. El recorrido interactivo completo de asistentes, eventos visuales, diseño de páginas y generación de informes con Java queda en el ensayo previo del instructor que exige su guía. Tampoco se afirma haber ejecutado el curso en Windows o Linux: sus instrucciones y rutas están adaptadas, pero la prueba nativa registrada corresponde a macOS.

## Decisiones respaldadas por las pruebas

`CDec` no se implementa en macOS/Linux; el kit usa dígitos decimales y `Currency`. Los errores propios usan el modo `Option VBASupport 1` y `Err.Raise`. Las transacciones necesitan una conexión aislada. El constructor renueva el objeto de sentencia después de cada DDL. El repositorio reserva el generador IDENTITY y asigna la identidad al objeto después del commit, porque el controlador probado no permite obtener `INSERT ... RETURNING` mediante un cursor. Los parámetros con nombre se sustituyen por `?` en Base antes de llegar a Firebird.
