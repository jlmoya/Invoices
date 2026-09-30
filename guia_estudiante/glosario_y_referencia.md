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
| Clave foránea | Campo que guarda la clave de otro registro: una referencia | 3 |
| Clave principal | Campo o campos que identifican cada registro sin repetirse | 2 |
| Clave sustituta | Clave generada por el sistema, sin significado para el negocio | 2 |
| Cola (FIFO) | Estructura donde el primero en entrar es el primero en salir | 6 |
| Composición | Relación en la que las partes no existen sin el todo | 3 y 7 |
| Consulta | Pregunta sobre los datos que filtra, transforma, agrega o une | 4 |
| Diccionario | Estructura de pares clave → valor con acceso casi constante; usa una tabla hash | 6 |
| Encapsulamiento | Ocultar el estado de un objeto y permitir cambiarlo solo con sus métodos | 7 |
| Entidad | Algo del problema sobre lo que se guardan datos | 1 |
| Estructura de datos | Forma de organizar datos para usarlos con eficiencia | 1 |
| Forma normal | Regla de diseño que elimina un tipo de redundancia (1FN, 2FN, 3FN) | 3 |
| Índice | Estructura ordenada auxiliar que acelera las búsquedas | 2 |
| Integridad referencial | Garantía de que ninguna clave foránea apunte a un registro inexistente | 3 |
| Interfaz | Conjunto de métodos que varias clases se comprometen a implementar | 8 |
| Invariante | Regla que un objeto mantiene siempre verdadera | 8 |
| Método | Procedimiento que pertenece a una clase | 7 |
| Objeto | Instancia de una clase, con identidad, estado y comportamiento | 7 |
| Pila (LIFO) | Estructura donde el último en entrar es el primero en salir | 6 |
| Polimorfismo | Usar objetos de clases distintas a través de la misma interfaz | 8 |
| Recursión | Procedimiento que se llama a sí mismo sobre un problema más pequeño | 6 |
| Registro | Conjunto de valores de una sola ocurrencia de una entidad | 1 |
| Relación reflexiva | Relación de una tabla consigo misma | 6 |
| Repositorio | Clase que guarda y recupera objetos en la base de datos | 8 |
| Responsabilidad | Algo que una clase sabe o sabe hacer | 7 |
| TAD (tipo abstracto de datos) | Datos más las operaciones permitidas sobre ellos | 6 |
| Tarjeta CRC | Tarjeta con clase, responsabilidades y colaboradores | 7 |
| Tipo de dato | Conjunto de valores posibles, su tamaño y sus operaciones | 2 |
| Transacción | Grupo de cambios que se aplica completo o no se aplica | 8 |

## Access en español y en inglés

| En español | En inglés |
| --- | --- |
| Archivo → Opciones → Centro de confianza | File → Options → Trust Center |
| Crear → Diseño de tabla | Create → Table Design |
| Crear → Diseño de consulta | Create → Query Design |
| Crear → Asistente para formularios | Create → Form Wizard |
| Crear → Asistente para informes | Create → Report Wizard |
| Datos externos → Nuevo origen de datos → Desde archivo → Archivo de texto | External Data → New Data Source → From File → Text File |
| Herramientas de base de datos → Relaciones | Database Tools → Relationships |
| Herramientas de base de datos → Compactar y reparar base de datos | Database Tools → Compact and Repair Database |
| Vista Diseño, Hoja de datos y SQL | Design, Datasheet and SQL View |
| Clave principal | Primary Key |
| Regla de validación y Texto de validación | Validation Rule and Validation Text |
| Valor predeterminado | Default Value |
| Indexado: Sí (Sin duplicados) | Indexed: Yes (No Duplicates) |
| Origen de la fila y Origen del control | Row Source and Control Source |
| Columna dependiente y Ancho de columnas | Bound Column and Column Widths |
| Exigir integridad referencial | Enforce Referential Integrity |
| Eliminar en cascada los registros relacionados | Cascade Delete Related Records |
| Ventana Inmediato (Ctrl+G) | Immediate Window |

## Expresiones que Access puede mostrar traducidas

En SQL y en VBA siempre se usa la forma en inglés. En las propiedades y en la cuadrícula de consultas, Access puede mostrar la forma en español.

| En SQL y VBA | En la interfaz en español |
| --- | --- |
| `Sum`, `Count`, `Avg` | Suma, Cuenta, Promedio |
| `IIf` | SiInm |
| `DLookup`, `DSum` | DBúsq, DSuma |
| `Date()`, `Now()` | Fecha(), Ahora() |
| `And`, `Or`, `Not` | Y, O, No |
| `Between … And` | Entre … Y |
| `Like` | Como |
| `Is Null` | Es Nulo |
| Separador de argumentos `,` | `;` cuando tu separador decimal es la coma |

## SQL de Access en una mirada

| Cláusula | Operación | Ejemplo |
| --- | --- | --- |
| `SELECT … AS` | Proyectar y transformar | `SELECT Cantidad * PrecioUnitario AS Importe` |
| `INNER JOIN … ON` | Unir registros relacionados | `tblFacturas AS f INNER JOIN tblClientes AS c ON f.IdCliente = c.IdCliente` |
| `LEFT JOIN` | Unir conservando todo el lado izquierdo | Categorías sin hijos |
| `WHERE` | Filtrar filas | `WHERE Estado = 'Emitida'` |
| `GROUP BY` | Agrupar | `GROUP BY IdFactura` |
| `HAVING` | Filtrar grupos | `HAVING Sum(Importe) > 10000` |
| `ORDER BY` | Ordenar | `ORDER BY NumeroFactura DESC` |
| `TOP n` | Primeras n filas, con empates | `SELECT TOP 1 …` |
| `PARAMETERS` | Declarar parámetros | `PARAMETERS [Fecha inicial] DateTime;` |

El SQL de Access no admite comentarios. Con más de dos tablas en el `FROM`, usa paréntesis.

## VBA en una mirada

```vb
Dim total As Currency                    ' variable con tipo
Dim f As clsFactura                      ' referencia a un objeto
Set f = New clsFactura                   ' crear el objeto
If f.Total > 1000 Then
    Debug.Print "Factura grande"         ' escribir en la ventana Inmediato
End If
For i = 1 To f.CantidadLineas            ' recorrer con contador
    total = total + f.Linea(i).Importe
Next i
Do Until rs.EOF                          ' recorrer un Recordset
    rs.MoveNext
Loop
Err.Raise vbObjectError + 1, "Origen", "Mensaje del error"
```

## Mermaid en una mirada

- Flujo: `flowchart LR`, y cada línea como `A["Inicio"] --> B["Fin"]`.
- Entidad-relación: `erDiagram`. Extremos: `||` exactamente uno, `o|` cero o uno, `o{` cero o muchos, `|{` uno o muchos.
- Clases: `classDiagram`. Relaciones: `-->` asociación, `*--` composición, `o--` agregación, `<|--` herencia, `..|>` implementa una interfaz.
- Estados: `stateDiagram-v2`, con líneas como `Borrador --> Emitida : emitir`.
- Secuencia: `sequenceDiagram`, con mensajes como `F->>R: Obtener(IdFactura)` y respuestas como `R-->>F: factura`.
