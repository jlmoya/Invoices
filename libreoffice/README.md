# Curso: Introducción a las Estructuras de Datos con LibreOffice

Curso-laboratorio en español de ocho sesiones de dos horas. Se construye un sistema didáctico de facturación en LibreOffice Base, con Firebird integrado, formularios e informes y clases en LibreOffice Basic.

| Carpeta | Contenido | Destinatario |
| --- | --- | --- |
| `guia_estudiante/` | Introducción, ocho laboratorios, proyecto integrador, glosario y cinco ilustraciones SVG | Estudiantes |
| `guia_instructor/` | Preparación, ocho planes con soluciones, evaluación y anexo técnico | Instructor |
| `kit_estudiante/` | Seis CSV UTF-8 y once módulos Basic, incluida la plantilla de Factura | Estudiantes |
| `kit_instructor/` | Clase Factura completa, constructor de solución y soluciones de la tarea 6 | Instructor |

Empieza por la [introducción del instructor](guia_instructor/00_inicio.md) y la [introducción del estudiante](guia_estudiante/00_inicio.md). La versión de [Microsoft Access](../access/README.md) sigue disponible en su propia carpeta.

## Herramientas

LibreOffice de escritorio con Base, Calc y Writer. El curso usa Firebird integrado; no se deben ejecutar sus ejemplos SQL en HSQLDB. Las macros son LibreOffice Basic, usan SDBC/UNO, clases `Option ClassModule` y `Option VBASupport 1` para los errores personalizados que admite LibreOffice. El generador de informes y ciertos asistentes pueden necesitar Java: compruébalo antes del curso según las instrucciones del instructor.

Las guías se leen como Markdown. Los bloques Mermaid se visualizan con un visor compatible, por ejemplo GitHub o una extensión del editor. Los SVG se abren en un navegador. Para PDF o documentos de Writer, convierte las guías con una herramienta que renderice Mermaid.

## Archivos y distribución

Todos los archivos de esta versión usan UTF-8 y LF. Copia las carpetas `datos` y `basic` del kit del estudiante a una carpeta local `CursoED`. Los módulos `.bas` se abren como texto UTF-8 y se pegan en módulos de la biblioteca `Standard` del documento Base; las guías explican los nombres exactos. La plantilla `clsFactura_plantilla.bas` se pega en el módulo `clsFactura`.

Entrega únicamente `guia_estudiante/` y `kit_estudiante/`. Las carpetas del instructor contienen soluciones. Los formularios, el informe y el archivo `Facturacion.odb` se construyen durante el laboratorio.

## Referencias de la adaptación

- [Documentación oficial de Base en español](https://documentation.libreoffice.org/es/documentacion-en-espanol/base/).
- [Clases en LibreOffice Basic](https://help.libreoffice.org/latest/es/text/sbasic/shared/classmodule.html).
- [Colecciones de Basic](https://help.libreoffice.org/latest/es/text/sbasic/shared/collection.html).
- [API SDBC de conexión y transacciones](https://api.libreoffice.org/docs/idl/ref/interfacecom_1_1sun_1_1star_1_1sdbc_1_1XConnection.html).
- [Referencia SQL Firebird 3](https://www.firebirdsql.org/file/documentation/chunk/en/refdocs/fblangref30/firebird-30-language-reference.html).
