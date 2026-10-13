# Curso: Introducción a las Estructuras de Datos con Microsoft Access

Materiales del curso-laboratorio de 8 sesiones de 2 horas · Versión del 30 de septiembre de 2026

| Carpeta | Contenido | Para quién |
| --- | --- | --- |
| `guia_estudiante/` | Presentación, precondiciones, 8 laboratorios, proyecto integrador y glosario, con diagramas Mermaid e ilustraciones SVG | Estudiantes |
| `guia_instructor/` | Enfoque, planificación, planes de sesión con soluciones, rúbricas, banco de preguntas y anexo técnico | Solo instructor |
| `kit_estudiante/` | Datos CSV y módulos VBA que cada estudiante copia en `C:\CursoED` | Estudiantes |
| `kit_instructor/` | Solución de la clase Factura, constructor de la base de solución y soluciones de la tarea 6 | Solo instructor |

Empieza por `guia_instructor/00_inicio.md` y después por `guia_estudiante/00_inicio.md`.

## Cómo ver las guías

Las guías son archivos Markdown. Los bloques `mermaid` se dibujan en la vista previa de Markdown de JetBrains y de VS Code (con una extensión de Mermaid), y también en GitHub. Para PDF o Word puedes usar pandoc con un filtro de Mermaid.

## Codificación de los archivos del kit

Los archivos `.csv`, `.bas`, `.cls` y `LEEME.txt` están en Windows-1252 con fin de línea CRLF. Así los importan Access y el editor de VBA en Windows sin perder acentos. No los vuelvas a guardar como UTF-8.

## Qué distribuir a los estudiantes

- La carpeta `guia_estudiante/` completa, o exportada a PDF.
- La carpeta `kit_estudiante/`.
- Nunca `guia_instructor/` ni `kit_instructor/`: contienen las soluciones.
