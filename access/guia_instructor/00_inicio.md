# Introducción a las Estructuras de Datos: guía del instructor

Laboratorio: un sistema de facturación en Microsoft Access · Versión del 30 de septiembre de 2026

Esta guía contiene soluciones: no la compartas con los estudiantes.

## Contenido

| Parte | Archivo |
| --- | --- |
| Enfoque, planificación, preparación y evaluación | Este archivo |
| Planes de sesión 1 a 8 | `sesion01_...md` a `sesion08_...md` |
| Rúbricas y banco de preguntas | [evaluacion_y_rubricas.md](evaluacion_y_rubricas.md) |
| Diccionario de datos, consultas, módulos y errores | [anexo_tecnico.md](anexo_tecnico.md) |

## Propósito y enfoque

El curso enseña estructuras de datos construyendo, en 8 sesiones de 2 horas, un sistema de facturación en Access. Termina en la orientación a objetos como última etapa de una misma evolución: dato, registro, colección, referencia, operación, estructura con reglas y objeto.

Cada concepto aparece primero como un problema visible en el sistema y solo después recibe su nombre. El `0.1 + 0.2` de la sesión 2 justifica el tipo Moneda, la fila 1004 de la tabla plana justifica la normalización y las reglas rotas de la sesión 5 justifican los objetos.

| Sesión | Etapa del hilo | Pregunta que mueve la sesión |
| --- | --- | --- |
| 1 | Dato y registro | ¿Qué datos tiene una factura y cuáles se calculan? |
| 2 | Tipo y colección | ¿Por qué 0.1 + 0.2 no es 0.3 y cómo encuentro rápido un producto? |
| 3 | Referencia | ¿Por qué no guardar todo en una sola tabla? |
| 4 | Operación | ¿Cómo calculo totales sin escribir un ciclo? |
| 5 | Jerarquía | ¿Cómo capturo e imprimo un padre con sus hijos? |
| 6 | Estructura con reglas | ¿Qué factura se cobra primero y cómo deshago un cambio? |
| 7 | Objeto (diseño) | ¿Quién debe hacer cumplir las reglas? |
| 8 | Objeto (código) | ¿Cómo hago que una regla sea imposible de saltar? |

Supuesto de público: estudiantes de los primeros semestres de Informática que ya programan en algún lenguaje, sin experiencia con bases de datos.

### Cómo se enseña el pensamiento orientado a objetos

Las sesiones 7 y 8 siguen la secuencia clásica de la enseñanza de objetos: primero el lenguaje del problema, después las responsabilidades y al final el código.

1. **Motivar por necesidad.** Los estudiantes ven romperse reglas en la sesión 5 y saltarse una estructura con un `UPDATE` en la sesión 6 antes de oír la palabra encapsulamiento.
2. **Empezar por el enunciado, no por la sintaxis.** El análisis de sustantivos y verbos (Abbott, 1983) da candidatos a clases, atributos y responsabilidades.
3. **Pensar en responsabilidades antes que en datos.** Las tarjetas CRC y el juego de roles (Beck y Cunningham, 1989) obligan a decir quién hace qué y a quién pide ayuda.
4. **Usar heurísticas con nombre.** Experto en información, encapsulamiento y alta cohesión, tomadas de los patrones GRASP (Larman).
5. **Diseñar en papel antes de programar.** La sesión 7 casi no abre Access; la sesión 8 implementa lo diseñado.
6. **Convertir las reglas en pruebas.** `ProbarReglas` falla con la plantilla y pasa cuando la clase hace cumplir el ciclo de vida.

Referencias:

- Abbott, R. J. (1983). Program design by informal English descriptions. *Communications of the ACM*, 26(11), 882–894.
- Beck, K. y Cunningham, W. (1989). A laboratory for teaching object-oriented thinking. *OOPSLA '89*.
- Larman, C. (2004). *Applying UML and Patterns*, 3.ª edición. Prentice Hall.

## Planificación

| Sesión | Foco | Se construye en clase | Tarea |
| --- | --- | --- | --- |
| 1 | Del papel a los datos | Base en ubicación de confianza, análisis de la factura, primer modelo ER | Recibo de pago |
| 2 | Tipos, registros y colecciones | `tblClientes`, `tblProductos`, importación, búsqueda lineal y binaria | Proveedores y experimento de búsqueda |
| 3 | Normalización y relaciones | Categorías, facturas, detalle y relaciones con integridad | Normalizar pedidos |
| 4 | Consultas | Parámetros, importes, subtotales, totales, ventas y periodo | Ventas por producto y por mes |
| 5 | Maestro-detalle e informe | Formulario con subformulario, eventos, factura imprimible | Estado de cuenta |
| 6 | Cola, pila, árbol y diccionario | Cola de cobranza, pila de precios, árbol de categorías | Profundidad y ruta |
| 7 | Pensar en objetos | Sustantivos y verbos, tarjetas CRC, juego de roles, diagramas | Pagos parciales |
| 8 | Objetos en acción | Clases VBA, pruebas, repositorio y botón Emitir | Proyecto integrador |

### Variante de 6 sesiones

Las sesiones 7 y 8 no se comprimen en ninguna variante: son el objetivo del arco.

| Sesión | Contenido | Pasa a tarea |
| --- | --- | --- |
| 1 | Laboratorio 1, partes A a C, y laboratorio 2, partes A a C | Laboratorio 1 parte D y laboratorio 2 partes D a F |
| 2 | Laboratorio 3 | Nada |
| 3 | Laboratorio 4, partes A a E, y laboratorio 5, partes A a C | Laboratorio 4 parte F y laboratorio 5 partes D y E |
| 4 | Laboratorio 6, partes A a D | Laboratorio 6 parte E |
| 5 | Laboratorio 7 | Nada |
| 6 | Laboratorio 8 | La parte opcional de polimorfismo |

No omitas la parte F del laboratorio 5 en ninguna variante: es el puente hacia los objetos.

## Preparación del laboratorio

- [ ] Access de escritorio instalado y activado en cada equipo; ábrelo una vez con la cuenta de un estudiante.
- [ ] Carpeta `C:\CursoED` con `datos` y `vba` del `kit_estudiante`, en cada equipo o en la imagen del laboratorio.
- [ ] Permiso para agregar ubicaciones de confianza. Si las directivas de TI lo impiden, pide que agreguen `C:\CursoED`.
- [ ] Prueba completa en un equipo del laboratorio: construye la base de solución y ejecuta `ProbarReglas`.
- [ ] Comprueba el diccionario de la sesión 6: en la ventana Inmediato, `? TypeName(CreateObject("Scripting.Dictionary"))` debe responder `Dictionary`.
- [ ] Hojas o tarjetas para la sesión 7: cinco por equipo.
- [ ] Opcional: capturas de tu versión de Access para los recuadros «Captura sugerida».

### Construir la base de solución

1. Crea una base en blanco, por ejemplo `C:\CursoED\Facturacion_Solucion.accdb`.
2. Importa `kit_instructor\vba\modConstruirSolucion.bas` y ejecuta `ConstruirSolucion` en la ventana Inmediato.
3. Resultado: 7 tablas con reglas, 6 relaciones, los datos de ejemplo y 11 consultas, en el estado previo a la parte B del laboratorio 6.
4. Importa los módulos de la sesión 8 con la `clsFactura.cls` completa del kit del instructor y ejecuta `ProbarReglas` y `ProbarRepositorio`.
5. Los formularios y el informe se construyen a mano con el laboratorio 5.

## Access en español

| Situación | Qué pasa | Qué hacer |
| --- | --- | --- |
| Expresiones en propiedades y en la cuadrícula | Access muestra funciones y operadores traducidos (Suma, SiInm, Y, O, Entre, Como, Es Nulo) y puede usar `;` como separador | La guía da la forma en inglés y su alternativa; en SQL y VBA, siempre inglés |
| Importación de CSV | Fechas y decimales dependen de la configuración regional | Ajustes avanzados del asistente: orden AMD, delimitador `-`, símbolo decimal `.` |
| Booleanos en la ventana Inmediato | Se muestran como Verdadero y Falso | Es normal |
| SQL armado con números en VBA | `CStr` usa la coma decimal regional y rompe el SQL | Consultas con parámetros, como en `modEstructuras` |
| Nombres de controles | El asistente puede nombrar el subformulario distinto | Verifica el nombre en la Hoja de propiedades |

## Evaluación

Tareas 50 %, proyecto integrador 35 %, autoevaluación y participación 15 %. Las rúbricas, las preguntas para la defensa del proyecto y el banco de preguntas están en [evaluacion_y_rubricas.md](evaluacion_y_rubricas.md).

Devuelve cada tarea antes de la sesión siguiente, con un comentario por criterio. Revisa los modelos del proyecto en la semana de la sesión 8, antes de que empiecen a programar.
