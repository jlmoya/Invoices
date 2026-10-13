# Diseño: cursos de Access y LibreOffice

## Encargo

Conservar el curso de Microsoft Access y preparar su conjunto equivalente de materiales en español para LibreOffice, dentro del mismo repositorio. El encargo incluye commit y push a origin cuando los materiales estén listos.

## Organización

- `access/`: materiales existentes conservados byte por byte.
- `libreoffice/`: ocho laboratorios, ocho planes del instructor, introducciones, proyecto, glosario, evaluación, anexo, cinco ilustraciones, seis CSV y catorce módulos de código equivalentes.
- `README.md`: entrada común y reglas de distribución.

## Decisiones

LibreOffice Base con Firebird integrado; Calc para importar CSV y Writer para formularios e informes. Macros en LibreOffice Basic, con `Option VBASupport 1` para clases y errores personalizados mediante `Err.Raise`, y `Option ClassModule` para las clases. Persistencia SDBC/UNO y parámetros SQL. Datos monetarios `DECIMAL(18,4)` y `Currency`; impuesto redondeado a dos decimales con la misma regla en SQL y código. Los ejemplos de polimorfismo usan un contrato de métodos y despacho a través de `Object`; Basic no tiene `Implements` de VBA.

La prueba nativa mostró que `CDec` está implementado solo en Windows y que `Error n` no conserva códigos propios como 2009. El cálculo monetario usa dígitos decimales y `Currency`; el modo de compatibilidad oficialmente soportado permite errores propios con `Err.Raise`. Las transacciones usan conexiones aisladas, porque las compartidas de formularios rechazan `setAutoCommit`. Cada sentencia DDL usa un objeto nuevo: Base invalida el anterior al cambiar el catálogo.

Los nombres de tablas y campos conservan mayúsculas mediante comillas dobles. Los CSV y módulos nuevos usan UTF-8/LF; los kits Access mantienen Windows-1252/CRLF. La base final `.odb`, formularios e informes se construyen en clase, igual que la base `.accdb` del curso original. No se agrega una base binaria preparada como sustituto del aprendizaje.

## Aceptación

Paridad de archivos y conceptos; enlaces locales correctos; ausencia de instrucciones Access residuales en el curso nuevo salvo comparaciones explícitas; construcción del esquema, datos y consultas en Firebird de LibreOffice; ejecución de clases, pruebas, persistencia y estructuras; pruebas de rechazo y reversión. Registrar versión y límites de la validación de interfaz. Verificar que Access se conserva, revisar el diff, hacer commit y push normal a `origin/main` sin sobrescribir trabajo remoto.
