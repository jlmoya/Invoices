# Introducción a las Estructuras de Datos: guía del instructor

Laboratorio: un sistema de facturación en LibreOffice Base · Versión del 13 de octubre de 2026

Esta guía contiene soluciones: no la compartas con los estudiantes.

## Contenido

| Parte | Archivo |
| --- | --- |
| Enfoque, planificación, preparación y evaluación | Este archivo |
| Planes de sesión 1 a 8 | `sesion01_...md` a `sesion08_...md` |
| Rúbricas y banco de preguntas | [evaluacion_y_rubricas.md](evaluacion_y_rubricas.md) |
| Diccionario de datos, consultas, módulos y errores | [anexo_tecnico.md](anexo_tecnico.md) |

## Propósito y enfoque

El curso enseña estructuras de datos construyendo, en 8 sesiones de 2 horas, un sistema de facturación en Base. Termina en la orientación a objetos como última etapa de una misma evolución: dato, registro, colección, referencia, operación, estructura con reglas y objeto.

Cada concepto aparece primero como un problema visible en el sistema y solo después recibe su nombre. El `0.1 + 0.2` de la sesión 2 justifica el tipo monetario exacto, la fila 1004 de la tabla plana justifica la normalización y las reglas rotas de la sesión 5 justifican los objetos.

| Sesión | Etapa del hilo | Pregunta que mueve la sesión |
| --- | --- | --- |
| 1 | Dato y registro | ¿Qué datos tiene una factura y cuáles se calculan? |
| 2 | Tipo y colección | ¿Por qué 0.1 + 0.2 no es 0.3 y cómo encuentro rápido un producto? |
| 3 | Referencia | ¿Por qué no guardar todo en una sola tabla? |
| 4 | Operación | ¿Cómo calculo totales sin escribir un ciclo? |
| 5 | Jerarquía | ¿Cómo capturo e imprimo un padre con sus hijos? |
| 6 | Estructura con reglas | ¿Qué factura se cobra primero y cómo deshago un cambio? |
| 7 | Objeto (diseño) | ¿Quién debe hacer cumplir las reglas? |
| 8 | Objeto (código) | ¿Cómo protejo una regla en las operaciones del objeto? |

Supuesto de público: estudiantes de los primeros semestres de Informática que ya programan en algún lenguaje, sin experiencia con bases de datos.

### Cómo se enseña el pensamiento orientado a objetos

Las sesiones 7 y 8 siguen la secuencia clásica de la enseñanza de objetos: primero el lenguaje del problema, después las responsabilidades y al final el código.

1. **Motivar por necesidad.** Los estudiantes ven romperse reglas en la sesión 5 y saltarse una estructura con un `UPDATE` en la sesión 6 antes de oír la palabra encapsulamiento.
2. **Empezar por el enunciado, no por la sintaxis.** El análisis de sustantivos y verbos (Abbott, 1983) da candidatos a clases, atributos y responsabilidades.
3. **Pensar en responsabilidades antes que en datos.** Las tarjetas CRC y el juego de roles (Beck y Cunningham, 1989) obligan a decir quién hace qué y a quién pide ayuda.
4. **Usar heurísticas con nombre.** Experto en información, encapsulamiento y alta cohesión, tomadas de los patrones GRASP (Larman).
5. **Diseñar en papel antes de programar.** La sesión 7 casi no abre Base; la sesión 8 implementa lo diseñado.
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
| 8 | Objetos en acción | Clases Basic, pruebas, repositorio y botón Emitir | Proyecto integrador |

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

- [ ] LibreOffice con Base, Firebird integrado, Calc, Writer y ScriptForge en cada equipo. Registra la versión y el sistema operativo; prueba con la cuenta de un estudiante.
- [ ] Carpeta personal local `CursoED`, fuera de sincronización, con `datos/` y `basic/` del kit del estudiante. Windows, Linux y macOS usan rutas propias; no exijas `C:\CursoED` a todos.
- [ ] Carpeta del curso configurada como ubicación de confianza para macros. Si TI administra esta opción, solicita únicamente esa carpeta.
- [ ] Generador de informes probado; instala/configura un JRE compatible cuando lo requiera. Verifica arquitectura y permisos, no solo que aparezca «Java instalado».
- [ ] Ensayo completo del recorrido manual de los laboratorios, además de construir la solución y ejecutar las pruebas.
- [ ] Parámetros nombrados habilitados: carga `modConstantes` y `modEstructuras`, ejecuta `EjecutarConfiguracionParametros` y guarda/cierra/reabre el `.odb` antes de abrir `qryFacturasPorPeriodo`. Comprueba que la interfaz solicita los valores y la consulta devuelve el periodo esperado. La opción es Editar → Base de datos → Configuración avanzada → Configuración especial → Reemplazar parámetros con nombre por «?».
- [ ] Diccionario ScriptForge probado con una `Sub` sin argumentos que llame a `UnidadesPorProducto` sobre los datos de solución; debe mostrar 14 códigos y PAP-001 = 19.
- [ ] Hojas o tarjetas para la sesión 7: cinco por equipo, más una para el repositorio.
- [ ] Copias cerradas de `.odb` al final de cada sesión y restauración ensayada.
- [ ] Opcional: capturas de la versión de Base del laboratorio.

### Construir la base de solución

1. Crea una base nueva Firebird integrado y guarda `CursoED/Facturacion_Solucion.odb`. Esta es una base del instructor; el alumnado construye la propia paso a paso.
2. En Standard del documento crea y pega `modConstantes` y `modEstructuras` del kit del estudiante y `modConstruirSolucion` del kit del instructor (archivos `.bas` UTF-8). Ejecuta `EjecutarConstructor` (llama a `ConstruirSolucion`). Debe usarse sobre una base nueva y vacía: el constructor rechaza una base con tablas existentes.
3. Resultado: siete tablas con restricciones, seis relaciones, datos de ejemplo, diez vistas del motor y una consulta parametrizada guardada de Base. El historial empieza vacío; las categorías incluyen la relación reflexiva. Es el estado previo a cobrar en el laboratorio 6.
4. Carga los módulos de sesión 8; crea **`clsFactura`** con la solución `kit_instructor/basic/clsFactura.bas`. Ejecuta `EjecutarFactura`, `EjecutarPruebas` y `EjecutarRepositorio` (llaman a las funciones `ProbarFactura`, `ProbarReglas` y `ProbarRepositorio`). Comprueba total 10610.17 en factura 1003.
5. Ejecuta las operaciones de cola, pila y árbol sobre una copia: atender 1002 modifica el estado; dos cambios y dos deshacer dejan PAP-001 en 119.00.
6. Construye formularios e informe con el laboratorio 5. El constructor no sustituye esta parte ni genera una base binaria de entrega.
7. Para distribuir, comparte el kit de estudiante con su plantilla `clsFactura_plantilla.bas`, nunca la solución completa. Para probar la experiencia de alumno, reemplaza el contenido del módulo `clsFactura` por la plantilla y observa el fallo esperado de sus TODO.

Consulta [la introducción del estudiante](../guia_estudiante/00_inicio.md) para crear Standard, pegar módulos y ejecutar procedimientos. No uses importación VBA de `.cls`: todas las fuentes de este curso son `.bas` y las clases se identifican por sus opciones iniciales.

## LibreOffice y configuración regional

| Situación | Qué pasa | Qué hacer |
| --- | --- | --- |
| Importación CSV en Calc | El idioma afecta fechas y decimales | UTF-8, separador coma, comillas dobles; verificar idioma y fechas ISO antes de copiar |
| Dinero en SQL | Firebird distingue tipos exactos de coma flotante | `DECIMAL(18,4)`; Basic `Currency`; tasa `DECIMAL(9,4)` |
| Comillas SQL | Firebird convierte nombres no entrecomillados a mayúsculas | Usar siempre `"tblFacturas"`, `"IdFactura"` y texto `'Emitida'` |
| Parámetros `:FechaInicial`, `:FechaFinal` | Firebird recibe `?` mediante la sustitución de Base | Habilitar `ParameterNameSubstitution` antes de abrir la conexión; si ya estaba abierta, cerrar y reabrir |
| Consulta sobre otra consulta | El modo SQL directo llega al motor sin resolver consultas de Base | Usar vistas del motor o el analizador de Base según el laboratorio |
| Valores SQL desde Basic | `CStr` depende del separador regional | Sentencias preparadas SDBC y parámetros; dinero exacto con conversión decimal del kit |
| Macros desde Writer | `ThisComponent` puede ser el documento de formulario | `ConexionBase()` usa el documento Base y devuelve una conexión aislada para transacciones; guardar la fila antes y recargar después |
| Nombres de controles | El asistente propone nombres propios | Inspeccionar en el Navegador de formularios; confirmar campo maestro/subordinado |
| Errores de negocio | `Option VBASupport 1` habilita `Err.Raise` con código y descripción personalizados | Mostrar `Err.Number` y `Err.Description`; el texto nace de `MensajeError` de `modConstantes` |

## Evaluación

Tareas 50 %, proyecto integrador 35 %, autoevaluación y participación 15 %. Las rúbricas, las preguntas para la defensa del proyecto y el banco de preguntas están en [evaluacion_y_rubricas.md](evaluacion_y_rubricas.md).

Devuelve cada tarea antes de la sesión siguiente, con un comentario por criterio. Revisa los modelos del proyecto en la semana de la sesión 8, antes de que empiecen a programar.
