# Introducción a las Estructuras de Datos: dos cursos de facturación

Materiales en español para un curso de ocho sesiones de dos horas. Cada versión construye un sistema didáctico de facturación y recorre datos, registros, colecciones, relaciones, consultas, colas, pilas, árboles, diccionarios y objetos.

| Curso | Plataforma | Entrada |
| --- | --- | --- |
| Microsoft Access | Windows, Access de escritorio y VBA | [Curso Access](access/README.md) |
| LibreOffice | Base con HSQLDB incorporado, Calc, Writer y LibreOffice Basic | [Curso LibreOffice](libreoffice/README.md) |

Cada curso contiene `guia_estudiante/`, `guia_instructor/`, `kit_estudiante/` y `kit_instructor/`. Distribuye a los estudiantes únicamente su guía y su kit: las carpetas del instructor contienen soluciones.

Los cursos conservan el mismo recorrido y los mismos datos de ejemplo. La versión LibreOffice adapta el SQL, los controles de formulario, los informes y las macros a sus herramientas.

## Codificación

Las guías y las imágenes SVG usan UTF-8. Los CSV, VBA y `LEEME.txt` del curso Access conservan Windows-1252 y CRLF. Todos los archivos del curso LibreOffice usan UTF-8 y LF. Las reglas del repositorio distinguen ambas carpetas.

## Construcción y verificación

La base `.accdb` o `.odb` se construye durante el curso; los formularios y los informes son ejercicios de laboratorio. Consulta la introducción del instructor de cada versión para construir la solución de referencia.

El [diseño de la adaptación](docs/diseno-libreoffice.md) y su [plan](docs/plan-libreoffice.md) registran la organización y las decisiones técnicas.

Consulta la [verificación de LibreOffice](docs/verificacion-libreoffice.md) para los comandos reproducibles, resultados nativos y alcance del ensayo de aula.
