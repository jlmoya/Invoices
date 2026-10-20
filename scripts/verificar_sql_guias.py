#!/usr/bin/env python3
"""Recorre el SQL de las guías de LibreOffice como lo haría un estudiante, en HSQLDB incorporado.

Ejecuta en orden los bloques ```sql de los laboratorios 2 a 6 y las soluciones del instructor,
carga los CSV del kit donde las guías piden importarlos con Calc, prueba los rechazos que las
guías anuncian, compara los totales con los puntos de control del laboratorio 4 y comprueba que
la base se conserva después de guardar, cerrar y reabrir el .odb.
"""
import argparse
import csv
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
from xml.sax.saxutils import escape

ROOT = Path(__file__).resolve().parents[1]
LO = ROOT / "libreoffice"
GUIAS = [
    "guia_estudiante/lab02_tipos_registros_y_colecciones.md",
    "guia_estudiante/lab03_normalizacion_y_relaciones.md",
    "guia_estudiante/lab04_consultas.md",
    "guia_estudiante/lab05_maestro_detalle_e_informe.md",
    "guia_estudiante/lab06_cola_pila_arbol_diccionario.md",
    "guia_instructor/sesion02_tipos_registros_y_colecciones.md",
    "guia_instructor/sesion03_normalizacion_y_relaciones.md",
    "guia_instructor/sesion04_consultas.md",
]
NUMERICOS = {"IdCliente", "IdProducto", "IdCategoria", "Precio", "Existencia", "IdFactura",
             "NumeroFactura", "TasaImpuesto", "Cantidad", "PrecioUnitario"}
PADRES = {2: 1, 3: 1, 4: 2, 5: 2, 6: 4, 7: 4, 8: 5, 9: 5, 10: 3, 11: 3}


def literal(columna, valor):
    if valor == "":
        return "NULL"
    if columna in NUMERICOS:
        return valor
    return "'" + valor.replace("'", "''") + "'"


def carga(archivo, tabla):
    filas = list(csv.DictReader((LO / "kit_estudiante/datos" / archivo).open(encoding="utf-8")))
    sentencias = []
    for fila in filas:
        columnas = ", ".join(f'"{c}"' for c in fila)
        valores = ", ".join(literal(c, v) for c, v in fila.items())
        sentencias.append(("ok", f'INSERT INTO "{tabla}" ({columnas}) VALUES ({valores})'))
    return sentencias


def bloques_sql():
    pasos = []
    for guia in GUIAS:
        texto = (LO / guia).read_text(encoding="utf-8")
        for bloque in re.findall(r"```sql\n(.*?)```", texto, re.S):
            sql = " ".join(linea.strip() for linea in bloque.strip().splitlines()).rstrip(";").strip()
            if not re.match(r"(SELECT|CREATE|ALTER|INSERT|UPDATE|DELETE)\b", sql):
                continue  # fragmentos de explicación, no sentencias completas
            esperado = "ok"
            if guia.startswith("guia_estudiante/lab03") and sql.startswith('INSERT INTO "tblDetalleFactura"'):
                esperado = "error"  # la guía anuncia el rechazo de la referencia huérfana
            pasos.append((esperado, sql))
            if sql.startswith('CREATE TABLE "tblProductos"'):
                pasos += pruebas_laboratorio2()
                pasos += carga("clientes.csv", "tblClientes") + carga("productos.csv", "tblProductos")
                pasos += identidades_laboratorio2()
            elif sql.startswith('CREATE TABLE "tblCategorias"'):
                pasos += carga("categorias.csv", "tblCategorias")
            elif esperado == "error":
                pasos += carga("facturas.csv", "tblFacturas") + carga("detalle_factura.csv", "tblDetalleFactura")
                pasos += pruebas_laboratorio3()
            elif sql.startswith('INSERT INTO "tblParametros"'):
                pasos.append(("error", 'INSERT INTO "tblParametros" ("Id", "TasaImpuesto") VALUES (2, 0.16)'))
            elif sql.startswith('ALTER TABLE "tblCategorias" ADD "IdCategoriaPadre"'):
                pasos += [("ok", f'UPDATE "tblCategorias" SET "IdCategoriaPadre" = {p} WHERE "IdCategoria" = {h}')
                          for h, p in PADRES.items()]
    return pasos


def pruebas_laboratorio2():
    """Parte D: los rechazos se prueban antes de importar, y se borra la fila válida de prueba."""
    return [
        ("error", "INSERT INTO \"tblProductos\" (\"Codigo\", \"Descripcion\", \"IdCategoria\", \"Precio\") VALUES ('PRUEBA', 'Prueba', 1, -5)"),
        ("error", "INSERT INTO \"tblProductos\" (\"Codigo\", \"Descripcion\", \"IdCategoria\", \"Precio\", \"Existencia\") VALUES ('PRUEBA', 'Prueba', 1, 10, -1)"),
        ("error", "INSERT INTO \"tblClientes\" (\"DocumentoFiscal\") VALUES ('0099999999')"),
        ("ok", "INSERT INTO \"tblClientes\" (\"DocumentoFiscal\", \"RazonSocial\") VALUES ('0099999999', 'Prueba')"),
        ("error", "INSERT INTO \"tblClientes\" (\"DocumentoFiscal\", \"RazonSocial\") VALUES ('0099999999', 'Duplicado')"),
        ("ok", "DELETE FROM \"tblClientes\" WHERE \"DocumentoFiscal\" = '0099999999'"),
    ]


def identidades_laboratorio2():
    """Paso 6 de la parte E: tras los IDs importados, la siguiente alta continúa en 9 y 16."""
    return [
        ("identidad", 'INSERT INTO "tblClientes" ("DocumentoFiscal", "RazonSocial") VALUES (\'PRUEBA-ID\', \'Prueba\')|9'),
        ("ok", "DELETE FROM \"tblClientes\" WHERE \"DocumentoFiscal\" = 'PRUEBA-ID'"),
        ("identidad", 'INSERT INTO "tblProductos" ("Codigo", "Descripcion", "IdCategoria", "Precio") VALUES (\'PRUEBA-ID\', \'Prueba\', 1, 1)|16'),
        ("ok", "DELETE FROM \"tblProductos\" WHERE \"Codigo\" = 'PRUEBA-ID'"),
    ]


def pruebas_laboratorio3():
    return [
        ("error", 'INSERT INTO "tblDetalleFactura" ("IdFactura", "IdProducto", "Cantidad", "PrecioUnitario") VALUES (1, 99, 1, 1)'),
        ("error", 'DELETE FROM "tblClientes" WHERE "IdCliente" = 1'),
        ("identidad", "INSERT INTO \"tblFacturas\" (\"IdCliente\", \"Estado\") VALUES (5, 'Borrador')|8"),
        ("ok", 'INSERT INTO "tblDetalleFactura" ("IdFactura", "IdProducto", "Cantidad", "PrecioUnitario") VALUES (8, 1, 1, 1)'),
        ("ok", 'DELETE FROM "tblFacturas" WHERE "IdFactura" = 8'),
        ("cuenta", 'SELECT COUNT(*) FROM "tblDetalleFactura" WHERE "IdFactura" = 8|0'),
        ("error", 'INSERT INTO "tblDetalleFactura" ("IdFactura", "IdProducto", "Cantidad", "PrecioUnitario") VALUES (1, 1, 0, 1)'),
        ("error", "INSERT INTO \"tblFacturas\" (\"IdCliente\", \"Estado\") VALUES (5, 'Revisada')"),
    ]


def puntos_de_control():
    """Lee la tabla de qryTotalesFactura de los puntos de control del laboratorio 4."""
    texto = (LO / "guia_estudiante/lab04_consultas.md").read_text(encoding="utf-8")
    tabla = texto.split("`qryTotalesFactura` debe mostrar estos valores:")[1].split("\n\n")[1]
    esperado = {}
    for fila in tabla.splitlines()[2:]:
        celdas = [c.strip() for c in fila.strip("|").split("|")]
        numero = "" if celdas[0] == "Sin número" else celdas[0]
        esperado[numero] = tuple(c.replace(",", "") for c in celdas[3:6])
    return esperado


def basic(texto):
    return '"' + texto.replace('"', '""') + '"'


def macro(pasos, salida, odb):
    lineas = [f"    p({i}) = {basic(t)} : s({i}) = {basic(q)}" for i, (t, q) in enumerate(pasos)]
    # Con VBASupport, como en el kit, los errores del motor llegan al manejador; sin él, la macro se detuvo en el primer rechazo.
    return f'''Option Explicit
Option VBASupport 1
Dim n As Integer

' Cada línea se escribe y se cierra al instante: si algo se detiene, el archivo muestra dónde.
Sub Escribir(ByVal texto As String)
    n = FreeFile
    Open "{salida}" For Append As #n
    Print #n, texto
    Close #n
End Sub

Function Cuenta(ByVal c As Object, ByVal sql As String) As Long
    Dim r As Object
    r = c.createStatement().executeQuery(sql)
    r.next()
    Cuenta = r.getLong(1)
    r.close()
End Function

Sub Comprobar(ByVal c As Object, ByVal etapa As String)
    Dim r As Object, linea As String
    Escribir etapa & " CUENTAS " & Cuenta(c, "SELECT COUNT(*) FROM ""tblClientes""") & " " & _
        Cuenta(c, "SELECT COUNT(*) FROM ""tblProductos""") & " " & Cuenta(c, "SELECT COUNT(*) FROM ""tblCategorias""") & " " & _
        Cuenta(c, "SELECT COUNT(*) FROM ""tblFacturas""") & " " & Cuenta(c, "SELECT COUNT(*) FROM ""tblDetalleFactura""")
    r = c.createStatement().executeQuery("SELECT ""NumeroFactura"",""Subtotal"",""Impuesto"",""Total"" FROM ""qryTotalesFactura"" ORDER BY ""IdFactura""")
    Do While r.next()
        linea = r.getString(1) & "|" & r.getString(2) & "|" & r.getString(3) & "|" & r.getString(4)
        Escribir etapa & " TOTAL " & linea
    Loop
    r.close()
    Escribir etapa & " IMPRESION " & Cuenta(c, "SELECT COUNT(*) FROM ""qryFacturaImpresion"" WHERE ""NombreEmpresa"" = 'Distribuidora Aula'")
End Sub

' Un paso por función: el manejador de errores devuelve el mensaje y sale sin Resume.
Function EjecutarPaso(ByVal c As Object, ByVal tipo As String, ByVal sql As String, ByVal i As Integer) As String
    Dim st As Object, r As Object, q As Object, partes As Variant, filas As Long, numeros As String
    On Error GoTo Falla
    If InStr(sql, ":FechaInicial") > 0 Or InStr(sql, "= ?") > 0 Then
        q = c.prepareStatement(Replace(Replace(sql, ":FechaInicial", "?"), ":FechaFinal", "?"))
        If InStr(sql, ":FechaInicial") > 0 Then
            q.setDate(1, CDateToUnoDate(DateSerial(2026, 9, 1)))
            q.setDate(2, CDateToUnoDate(DateSerial(2026, 9, 10)))
        Else
            q.setInt(1, 11)
        End If
        r = q.executeQuery()
        Do While r.next()
            filas = filas + 1
            If InStr(sql, ":FechaInicial") > 0 Then numeros = numeros & r.getString(1) & " "
        Loop
        r.close()
        q.close()
        EjecutarPaso = "OK " & i & " PARAMETROS " & filas & " " & Trim(numeros)
    ElseIf tipo = "identidad" Or tipo = "cuenta" Then
        partes = Split(sql, "|")
        st = c.createStatement()
        If tipo = "identidad" Then
            st.executeUpdate(partes(0))
            r = st.executeQuery("CALL IDENTITY()")
        Else
            r = st.executeQuery(partes(0))
        End If
        r.next()
        EjecutarPaso = IIf(CStr(r.getLong(1)) = partes(1), "OK ", "MAL ") & i & " " & tipo & " " & r.getLong(1) & " (esperado " & partes(1) & ")"
        r.close()
    Else
        st = c.createStatement()
        st.execute(sql)
        EjecutarPaso = IIf(tipo = "ok", "OK ", "MAL ") & i & " " & IIf(tipo = "ok", "", "se esperaba un rechazo: ") & Left(sql, 90)
    End If
    Exit Function
Falla:
    EjecutarPaso = IIf(tipo = "error", "OK ", "MAL ") & i & " " & IIf(tipo = "error", "rechazo esperado: ", "error: ") & _
        Replace(Replace(Err.Description, Chr(10), " "), Chr(13), " ") & " | " & Left(sql, 90)
End Function

Sub Ejecutar
    Dim d As Object, c As Object, i As Integer
    Dim p({len(pasos) - 1}) As String, s({len(pasos) - 1}) As String
{chr(10).join(lineas)}
    d = StarDesktop.loadComponentFromURL("private:factory/sdatabase", "_blank", 0, Array())
    d.DataSource.URL = "sdbc:embedded:hsqldb"
    d.storeAsURL(ConvertToURL("{odb}"), Array())
    c = d.DataSource.getIsolatedConnection("", "")
    For i = 0 To UBound(s)
        Escribir EjecutarPaso(c, p(i), s(i), i)
    Next i
    On Error GoTo Final
    Comprobar c, "ANTES"
    c.close()
    d.store()
    d.close(True)
    d = StarDesktop.loadComponentFromURL(ConvertToURL("{odb}"), "_blank", 0, Array())
    c = d.DataSource.getIsolatedConnection("", "")
    Comprobar c, "DESPUES"
    c.close()
    d.close(True)
    Escribir "FIN"
Final:
    If Err.Number <> 0 Then Escribir "ERROR " & Err.Number & " " & Replace(Err.Description, Chr(10), " ")
    StarDesktop.terminate()
End Sub
'''


def ejecutar(soffice):
    pasos = bloques_sql()
    trabajo = Path(tempfile.mkdtemp(prefix="sql-guias-"))
    perfil, salida, odb = trabajo / "perfil", trabajo / "resultado.txt", trabajo / "Facturacion.odb"
    base = [soffice, "-env:UserInstallation=" + perfil.as_uri(), "--headless", "--norestore", "--nodefault"]
    subprocess.run(base + ["--terminate_after_init"], check=True, capture_output=True, timeout=60)
    biblioteca = perfil / "user/basic/Standard"
    biblioteca.mkdir(parents=True, exist_ok=True)
    (biblioteca / "Guias.xba").write_text(
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<!DOCTYPE script:module PUBLIC "-//OpenOffice.org//DTD OfficeDocument 1.0//EN" "module.dtd">\n'
        '<script:module xmlns:script="http://openoffice.org/2000/script" script:name="Guias" '
        f'script:language="StarBasic">{escape(macro(pasos, salida, odb))}</script:module>', encoding="utf-8")
    (biblioteca / "script.xlb").write_text(
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<!DOCTYPE library:library PUBLIC "-//OpenOffice.org//DTD OfficeDocument 1.0//EN" "library.dtd">\n'
        '<library:library xmlns:library="http://openoffice.org/2000/library" library:name="Standard" '
        'library:readonly="false" library:passwordprotected="false"><library:element library:name="Guias"/>'
        '</library:library>', encoding="utf-8")
    print(f"Perfil, base y resultados: {trabajo}", flush=True)
    subprocess.run(base + ["macro:///Standard.Guias.Ejecutar()"], capture_output=True, timeout=300)
    resultado = salida.read_text(encoding="utf-8") if salida.exists() else "SIN RESULTADO"
    print(resultado)
    problemas = [l for l in resultado.splitlines() if l.startswith(("MAL ", "ERROR "))]
    esperado = puntos_de_control()
    for etapa in ("ANTES", "DESPUES"):
        cuentas = re.search(rf"^{etapa} CUENTAS (.*)$", resultado, re.M)
        if not cuentas or cuentas.group(1) != "8 15 11 7 16":
            problemas.append(f"{etapa}: cuentas {cuentas.group(1) if cuentas else 'ausentes'}, se esperaba 8 15 11 7 16")
        totales = {}
        for linea in re.findall(rf"^{etapa} TOTAL (.*)$", resultado, re.M):
            numero, *montos = linea.split("|")
            totales[numero] = tuple(f"{float(m):.2f}" for m in montos)
        if totales != esperado:
            problemas.append(f"{etapa}: qryTotalesFactura {totales} no coincide con los puntos de control {esperado}")
        if f"{etapa} IMPRESION 16" not in resultado:
            problemas.append(f"{etapa}: qryFacturaImpresion no tiene 16 líneas con el emisor")
    if "PARAMETROS 4 1001 1002 1003 1004" not in resultado:
        problemas.append("qryFacturasPorPeriodo del 1 al 10 de septiembre no devolvió 1001 a 1004")
    if "FIN" not in resultado:
        problemas.append("La macro no terminó")
    if problemas:
        raise SystemExit("PROBLEMAS:\n" + "\n".join(problemas))
    print(f"Correcto: {len(pasos)} pasos de las guías, puntos de control del laboratorio 4 y reapertura del .odb.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--soffice", default=shutil.which("soffice") or "/Applications/LibreOffice.app/Contents/MacOS/soffice")
    ejecutar(parser.parse_args().soffice)
