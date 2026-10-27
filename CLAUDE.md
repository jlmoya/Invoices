# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

`AGENTS.md` holds the general repository guidelines (layout, encodings, naming, commit style). This file adds what you only learn by reading the verification scripts and `docs/` together.

## What this repository is

Two parallel Spanish-language, eight-session courses that build a teaching invoicing system: `access/` (Microsoft Access and VBA, Windows) and `libreoffice/` (Base with embedded HSQLDB 1.8 and LibreOffice Basic). There is no application to build. Students create the `.accdb`/`.odb`, forms and reports in class, and the repository deliberately ships no prebuilt database. The "code" is guide Markdown, CSV fixtures, VBA/Basic modules and three Python verifiers.

## Commands

From the repository root:

```bash
python3 scripts/verificar_materiales.py                          # no dependencies: parity, encodings, CSVs, SVGs, links
python3 scripts/verificar_materiales.py --access-baseline eeb582d # plus byte-for-byte Access preservation
python3 scripts/verificar_libreoffice.py                         # full Basic solution in headless LibreOffice
python3 scripts/verificar_libreoffice.py --plantilla             # student template must fail exactly its three TODOs
python3 scripts/verificar_sql_guias.py                           # replays the guides' SQL in course order
```

There is no per-test selector: each script is one end-to-end run. The native scripts need LibreOffice with Java. `soffice` is taken from PATH, then `/Applications/LibreOffice.app/Contents/MacOS/soffice`; override it with `--soffice`. Each run creates a throwaway profile (`-env:UserInstallation`) and `.odb` in a temporary directory, prints that directory and leaves it for inspection. It never touches the personal LibreOffice profile.

No script executes the Access course. Its VBA and SQL are covered only by the parity, CSV and byte-preservation checks.

## How the checks couple files

Most edits ripple into other files. Know what reads a file before changing it:

- **Course parity** (`verificar_materiales.py`): the file set under `libreoffice/` must equal the one under `access/` after mapping `vba/`→`basic/`, `.cls`→`.bas` and `ventana_access.svg`→`ventana_base.svg`. Adding, renaming or removing a file in one course requires its counterpart in the other.
- **CSV equivalence**: each `access/kit_estudiante/datos/*.csv`, decoded as cp1252, must parse to the same rows as its `libreoffice/` twin. Change data in both.
- **Access freeze**: `--access-baseline eeb582d` compares `README.md`, `guia_*` and `kit_*` at that commit, from before the move into `access/`, against `access/`. Any edit to Access materials makes it fail by design. Tell the user instead of working around it.
- **Link check**: every `.md` outside dot-directories, including this file and `docs/`, must have resolvable local links.
- **Guides are test input** (`verificar_sql_guias.py`): it runs every `sql` code block that starts with SELECT, CREATE, ALTER, INSERT, UPDATE or DELETE, from LibreOffice student labs 2–6 and then instructor sessions 2–4. Some statements are hooks. `CREATE TABLE "tblProductos"` triggers the lab 2 rejection tests and loads clients and products. `CREATE TABLE "tblCategorias"` loads categories. Lab 3's `INSERT INTO "tblDetalleFactura"` must fail and then loads invoices and details. The script also parses the lab 4 checkpoint table that follows the literal sentence ``` `qryTotalesFactura` debe mostrar estos valores: ```. Rewording any of these changes or breaks the run.
- **Lab 5 code is compiled** (`verificar_libreoffice.py`): all `vb` code blocks in `libreoffice/guia_estudiante/lab05_maestro_detalle_e_informe.md` are concatenated into one module that must compile with the kit.
- **Template mode**: `--plantilla` loads `clsFactura_plantilla.bas` as `clsFactura`. It asserts the exact `FALLA: <rule>` lines that `modPruebasObjetos.bas` prints for the three TODOs, plus `Correcto: Línea inmutable`. Changing the TODOs or those rule names requires updating the script.
- **Hard-coded expectations**: the scripts assert facts derived from the fixtures:
  - row counts: 8 clients, 15 products, 11 categories, 7 invoices, 16 detail lines;
  - next identities: 9 for clients, 16 for products, 8 for invoices;
  - invoice 1003 totals: 9146.70 / 1463.47 / 10610.17;
  - issued plus paid sales: 57785.98;
  - date filter: seven invoices in September, and 1001–1004 between 1 and 10 September;
  - lab 6 structures: PAP-001 has 19 units, the collection queue starts with 1002, and the category path is `Catálogo > Tecnología > Accesorios > Periféricos`.

  A fixture change cascades into both courses' guides, the lab 4 checkpoint table, the scripts and `docs/verificacion-libreoffice.md`.

`docs/evidencias/` stores the recorded output of the three native runs. `docs/verificacion-libreoffice.md` quotes counts from those runs (53 `Correcto` messages, 124 SQL steps). Keep both consistent when behavior changes.

## Student and instructor code

- Guide pairs share a slug: student `labNN_<slug>.md` matches instructor `sesionNN_<slug>.md`.
- The student kit's `clsFactura_plantilla` keeps three intentional TODOs: subtotal, issue validation and cancellation. The instructor kit's `clsFactura` is the solution. Either one is pasted into a module named `clsFactura`, never both.
- The instructor modules reuse helpers from the student kit:
  - `modConstantes`: `MensajeError` and `RedondearMoneda`;
  - `modEstructuras`: `ConexionBase` and `CerrarConexionBase`.
- `modConstruirSolucion` builds the reference schema, data, views and the parameterized Base query `qryFacturasPorPeriodo`. It refuses to run on a non-empty database.

## LibreOffice platform constraints

The course uses embedded HSQLDB because the wizard offers embedded Firebird only in experimental mode. Do not reintroduce Firebird or anything that needs experimental options. These rules were verified on the bundled HSQLDB 1.8 and Basic. The rationale is in `docs/verificacion-libreoffice.md` and `libreoffice/guia_instructor/anexo_tecnico.md`.

- Quote every table and column name, such as `"tblFacturas"`, to preserve case.
- Declare `CHECK`, `UNIQUE` and `FOREIGN KEY` only as table constraints.
- Use no `LIKE`, `POSITION`, `LOCATE` or `SUBSTRING` inside `CHECK`. A `POSITION` check produces a database that cannot be reopened.
- Give every identity `(START WITH 1)`, because the code uses 0 for "no value". Read a new ID with `CALL IDENTITY()` on the same connection.
- Every `CREATE` or `ALTER` commits the open transaction. Use a fresh statement object after each DDL statement.
- HSQLDB 1.8 has no `DATE '…'` literals (write ISO strings), no `SELECT … FOR UPDATE` and no recursive queries (Basic walks the category tree).
- Store money as `DECIMAL(18,4)` in SQL and `Currency` in Basic. Round tax with `FLOOR(x * 100 + 0.5) / 100` cast to `DECIMAL(18,4)`, which matches `RedondearMoneda`. Do not use `ROUND`.
- `CDec` works only on Windows.
- Custom errors need `Option VBASupport 1` and `Err.Raise`.
- Classes use `Option ClassModule`. Basic has no `Implements`, so polymorphism is a method contract dispatched through `Object`.
- Transactions need an isolated connection (`getIsolatedConnection`) because form connections reject `setAutoCommit`.

Headless runs do not verify the database wizard, pasting from Calc with «Copiar tabla», the parameter dialog, forms or reports. Do not report those as verified.

## Encoding-sensitive files

Access kit `.csv`, `.bas`, `.cls` and `LEEME.txt` files are Windows-1252 with CRLF and marked `-text` in Git. Editing tools that assume UTF-8 can silently re-encode them. Read and write them as cp1252 with newlines preserved (for example, Python with `encoding="cp1252", newline=""`). Then check the bytes with `git diff` and the materials check. Everything under `libreoffice/` must stay UTF-8 with LF and no BOM; the materials check enforces this.
