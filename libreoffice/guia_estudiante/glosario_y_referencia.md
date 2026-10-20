# Glosario y referencia rápida

Consulta este archivo cuando olvides un término, un menú o una sintaxis. Los términos van en orden alfabético y la columna Sesión indica dónde aparecen.

## Glosario

| Término | Definición | Sesión |
| --- | --- | --- |
| Agregación | Operación que resume muchos valores en uno: suma, cuenta o promedio | 4 |
| Anomalía | Inconsistencia que aparece al insertar, actualizar o borrar datos repetidos | 3 |
| Árbol | Estructura jerárquica: cada nodo tiene un padre, salvo la raíz | 6 |
| Atributo | Característica de una entidad que se guarda como campo | 1 |
| Clase | Plantilla que define el estado y el comportamiento de un tipo de objeto | 7 |
| Clave candidata | Campo o grupo mínimo de campos que podría servir de clave principal | 3 |
| Clave foránea | Campo que guarda la clave de otro registro: una referencia | 3 |
| Clave principal | Campo o campos que identifican cada registro sin repetirse | 2 |
| Clave sustituta | Clave generada por el sistema, sin significado para el negocio | 2 |
| Cola (FIFO) | Estructura donde el primero en entrar es el primero en salir | 6 |
| Composición | Relación en la que las partes no existen sin el todo | 3 y 7 |
| Consulta | Pregunta sobre los datos que filtra, transforma, agrega o une | 4 |
| Dependencia funcional | Relación en la que conocer un campo basta para saber otro: DocCliente → Ciudad | 3 |
| Diccionario | Estructura de pares clave → valor; una implementación hash ofrece acceso casi constante en promedio | 6 |
| Encapsulamiento | Ocultar el estado de un objeto y permitir cambiarlo solo con sus métodos | 7 |
| Entidad | Algo del problema sobre lo que se guardan datos | 1 |
| Estructura de datos | Forma de organizar datos para usarlos con eficiencia | 1 |
| Forma normal | Regla de diseño que elimina un tipo de redundancia (1FN, 2FN, 3FN, FNBC, 4FN y 5FN) | 3 |
| Índice | Estructura ordenada auxiliar que acelera las búsquedas | 2 |
| Integridad referencial | Garantía de que ninguna clave foránea apunte a un registro inexistente | 3 |
| Contrato común | Nombres y significado de métodos que varias clases ofrecen; en Basic se comprueba mediante pruebas | 8 |
| Invariante | Regla que un objeto mantiene siempre verdadera | 8 |
| Método | Procedimiento que pertenece a una clase | 7 |
| Objeto | Instancia de una clase, con identidad, estado y comportamiento | 7 |
| Pila (LIFO) | Estructura donde el último en entrar es el primero en salir | 6 |
| Polimorfismo | Llamar al mismo método sobre objetos de distintas clases y obtener su comportamiento particular | 8 |
| Recursión | Procedimiento que se llama a sí mismo sobre un problema más pequeño | 6 |
| Registro | Conjunto de valores de una sola ocurrencia de una entidad | 1 |
| Relación reflexiva | Relación de una tabla consigo misma | 6 |
| Repositorio | Clase que guarda y recupera objetos en la base de datos | 8 |
| Responsabilidad | Algo que una clase sabe o sabe hacer | 7 |
| TAD (tipo abstracto de datos) | Datos más las operaciones permitidas sobre ellos | 6 |
| Tarjeta CRC | Tarjeta con clase, responsabilidades y colaboradores | 7 |
| Tipo de dato | Conjunto de valores posibles, su tamaño y sus operaciones | 2 |
| Transacción | Grupo de cambios que se aplica completo o no se aplica | 8 |

## LibreOffice en español y en inglés

| En español | En inglés |
| --- | --- |
| Archivo → Nuevo → Base de datos | File → New → Database |
| Tablas → Crear tabla en vista de diseño | Tables → Create Table in Design View |
| Consultas → Crear consulta en vista SQL | Queries → Create Query in SQL View |
| Formularios → Usar asistente para crear formulario | Forms → Use Wizard to Create Form |
| Informes → Usar asistente para crear informe | Reports → Use Wizard to Create Report |
| Herramientas → Relaciones | Tools → Relationships |
| Herramientas → SQL | Tools → SQL |
| Herramientas → Macros → Organizar macros → Basic | Tools → Macros → Organize Macros → Basic |
| Herramientas → Opciones → LibreOffice → Seguridad → Seguridad de macros | Tools → Options → LibreOffice → Security → Macro Security |
| Navegador de formularios | Form Navigator |
| Campo de datos; Tipo de contenido de lista | Data field; Type of list contents |
| Campo ligado; Campos maestros; Campos subordinados | Bound field; Link master fields; Link slave fields |
| Entrada requerida; Valor automático | Entry required; AutoValue |
| Clave principal; Clave foránea | Primary key; Foreign key |

En macOS las opciones generales están en LibreOffice → Preferencias. Los formularios se editan dentro de Writer; «Diseño de formulario» y «Controles de formulario» aparecen en Ver → Barras de herramientas.

## Tipos y expresiones

| Necesidad | HSQLDB / SQL | Basic |
| --- | --- | --- |
| Entero de 32 bits | `INTEGER` | `Long` |
| Dinero exacto con 4 decimales | `DECIMAL(18,4)` | `Currency` |
| Tasa del curso | `DECIMAL(9,4)` | `Double` en la API; `Currency` de cuatro decimales en el estado interno |
| Texto | `VARCHAR(n)`; texto extenso `LONGVARCHAR` | `String` |
| Fecha | `DATE`, `CURRENT_DATE` | `Date`, `Date()` |
| Fecha y hora | `TIMESTAMP`, `CURRENT_TIMESTAMP` | `Now()` |
| Booleano | `BOOLEAN`, `TRUE`, `FALSE` | `Boolean`, `True`, `False` |
| Ausencia de valor | `NULL`, `IS NULL`, `COALESCE` | `IsNull(valor)` o `rs.wasNull()` tras leer |
| Concatenar texto | `||` | `&` |
| Impuesto | `FLOOR(subtotal * tasa * 100 + 0.5) / 100` | `CalcularPorcentajeMoneda(subtotal, tasa)` |

HSQLDB y Basic usan sintaxis SQL y de programación en inglés, aunque la interfaz esté en español. En SQL los decimales literales usan punto y las fechas se escriben como texto ISO, `'2026-09-01'`: HSQLDB 1.8 no acepta la forma `DATE '2026-09-01'`. En Calc, verifica idioma, separador de CSV y columnas de fecha antes de copiar los datos. Un parámetro SDBC enlaza un dato sin depender del separador decimal de la interfaz.

## SQL de HSQLDB en una mirada

| Cláusula | Operación | Ejemplo |
| --- | --- | --- |
| `SELECT … AS` | Proyectar y transformar | `SELECT "Cantidad" * "PrecioUnitario" AS "Importe" FROM "tblDetalleFactura"` |
| `INNER JOIN … ON` | Unir registros relacionados | `"tblFacturas" f INNER JOIN "tblClientes" c ON f."IdCliente" = c."IdCliente"` |
| `LEFT JOIN` | Conservar todo el lado izquierdo | Categorías sin hijos |
| `WHERE` | Filtrar filas | `WHERE "Estado" = 'Emitida'` |
| `GROUP BY` | Agrupar | `GROUP BY "IdFactura"` |
| `HAVING` | Filtrar grupos | `HAVING SUM("Importe") > 10000` |
| `ORDER BY` | Ordenar | `ORDER BY "NumeroFactura" DESC` |
| `LIMIT n` | Limitar filas | `… ORDER BY "IdCambio" DESC LIMIT 1` |
| `?` | Parámetro SDBC por posición | `WHERE "IdFactura" = ?`, luego `setInt(1, id)` |
| `:FechaInicial` | Parámetro de una consulta guardada de Base | `WHERE "Fecha" >= :FechaInicial` |
| `CALL IDENTITY()` | Leer la identidad que acaba de generar la conexión | Después de un `INSERT` sin `IdFactura` |

Los identificadores mixtos se entrecomillan con `"…"`; los textos, con `'…'`. El analizador de Base permite que una consulta use otra consulta guardada. El modo «Ejecutar orden SQL directamente» envía el SQL a HSQLDB, que conoce tablas y vistas, no los nombres de consultas almacenadas en Base. No mezcles ambos modos sin revisar el origen de los datos.

## Basic y SDBC en una mirada

```vb
Option Explicit
Option VBASupport 1

Sub EjecutarEjemploLectura()
    Dim total As Currency, i As Long
    Dim f As Object, cn As Object, st As Object, rs As Object
    Set f = New clsFactura
    If f.Total > 1000 Then MsgBox "Factura grande"
    For i = 1 To f.CantidadLineas
        total = total + f.Linea(i).Importe
    Next i

    cn = ConexionBase()
    st = cn.prepareStatement("SELECT ""Estado"" FROM ""tblFacturas"" WHERE ""IdFactura"" = ?")
    st.setInt(1, 3)
    rs = st.executeQuery()
    If rs.next() Then MsgBox rs.getString(1)
    rs.close()
    st.close()
End Sub
```

Para ejecutar este ejemplo, crea un módulo Standard y carga previamente las clases y `modEstructuras` del curso. En una clase agrega `Option ClassModule` al principio. `Collection` conserva objetos y permite `Add`, `Item`, `Count` y `Remove`. Un diccionario ScriptForge se crea después de cargar su biblioteca con `CreateScriptService("Dictionary")`; lee con `Item` y cambia con `ReplaceItem`.

Con `Option VBASupport 1`, `Err.Raise 2005, "Curso", MensajeError(2005)` señala una regla con su código y texto. Un manejador `On Error GoTo Falla` recibe `Err.Number` y `Err.Description`. La instrucción `Error n` se reserva a errores predefinidos. El repositorio escribe con `setAutoCommit(False)`, `commit()` y `rollback()`, y restaura el modo previo. No escribas SQL de dinero concatenando `CStr`. El modo de compatibilidad no agrega DAO ni `Implements`; las conexiones y formularios se manejan con UNO/SDBC.

Referencias oficiales: [clases Basic](https://help.libreoffice.org/latest/es/text/sbasic/shared/classmodule.html), [objeto Err](https://help.libreoffice.org/latest/es/text/sbasic/shared/ErrVBA.html), [Dictionary](https://help.libreoffice.org/latest/es/text/sbasic/shared/03/sf_dictionary.html), [API de conexiones SDBC](https://api.libreoffice.org/docs/idl/ref/interfacecom_1_1sun_1_1star_1_1sdbc_1_1XConnection.html).

## Mermaid en una mirada

- Flujo: `flowchart LR`, y cada línea como `A["Inicio"] --> B["Fin"]`.
- Entidad-relación: `erDiagram`. Extremos: `||` exactamente uno, `o|` cero o uno, `o{` cero o muchos, `|{` uno o muchos.
- Clases: `classDiagram`. Relaciones: `-->` asociación, `*--` composición, `o--` agregación, `<|--` herencia, `..|>` denota implementación de interfaz en UML; en este curso Basic el contrato común no tiene comprobación de interfaz por el compilador.
- Estados: `stateDiagram-v2`, con líneas como `Borrador --> Emitida : emitir`.
- Secuencia: `sequenceDiagram`, con mensajes como `F->>R: Obtener(IdFactura)` y respuestas como `R-->>F: factura`.
