#!/usr/bin/env python3
"""Ejecuta las macros del kit en LibreOffice con HSQLDB incorporado y un perfil temporal."""
import argparse
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
from xml.sax.saxutils import escape

ROOT = Path(__file__).resolve().parents[1]


def ejecutar(soffice, plantilla=False):
    trabajo = Path(tempfile.mkdtemp(prefix="curso-libreoffice-"))
    perfil = trabajo / "perfil"
    base = [soffice, "-env:UserInstallation=" + perfil.as_uri(), "--headless", "--norestore", "--nodefault"]
    subprocess.run(base + ["--terminate_after_init"], check=True, capture_output=True, timeout=30)
    biblioteca = perfil / "user/basic/Standard"
    biblioteca.mkdir(parents=True, exist_ok=True)
    modulos = {}
    for carpeta in [ROOT / "libreoffice/kit_estudiante/basic", ROOT / "libreoffice/kit_instructor/basic"]:
        for archivo in carpeta.glob("*.bas"):
            if archivo.stem == "clsFactura_plantilla":
                if plantilla:
                    modulos["clsFactura"] = archivo.read_text()
            elif archivo.stem != "clsFactura" or not plantilla:
                modulos[archivo.stem] = archivo.read_text()
    guia_formularios = (ROOT / "libreoffice/guia_estudiante/lab05_maestro_detalle_e_informe.md").read_text()
    modulos["modInterfaz"] = "\n".join(re.findall(r"```vb\n(.*?)```", guia_formularios, re.S))
    modulos["modInterfaz"] += "\nPublic Function CompilarGuiaFormulario() As Boolean\nCompilarGuiaFormulario=True\nEnd Function\n"
    salida = trabajo / "resultado.txt"
    odb = trabajo / "Facturacion_Solucion.odb"
    modulos["Verificar"] = f'''Option Explicit
Option VBASupport 1
Sub Ejecutar
    On Error GoTo Falla
    Dim n As Integer, d As Object, c As Object, s As Object, r As Object, texto As String
    Dim filas As Long, registros As Object, biblioteca As Object, nombres As Variant, nombre As Variant
    Dim proveedor As Object, macro As Object, indices As Variant, valores As Variant
    Dim compositor As Object
    n = FreeFile
    Open "{salida}" For Output As #n
    Print #n, "INICIO"
    d = StarDesktop.loadComponentFromURL("private:factory/sdatabase", "_blank", 0, Array())
    d.DataSource.URL = "sdbc:embedded:hsqldb"
    d.storeAsURL(ConvertToURL("{odb}"), Array())
    c = d.DataSource.getIsolatedConnection("", "")
    Print #n, ConstruirSolucion(c, d, False)
    If Not CompilarGuiaFormulario() Then Err.Raise 5014
    Print #n, "CÓDIGO DE LA GUÍA DE FORMULARIOS: compilado"
    Print #n, "MOTOR " & c.getMetaData().getDatabaseProductName() & " " & c.getMetaData().getDatabaseProductVersion()
    ' Tras los Id explícitos de la carga, HSQLDB continúa en el máximo más uno.
    c.setAutoCommit(False)
    s = c.createStatement()
    s.executeUpdate("INSERT INTO ""tblClientes"" (""DocumentoFiscal"",""RazonSocial"") VALUES ('PRUEBA-ID','Prueba')")
    r = s.executeQuery("CALL IDENTITY()")
    r.next()
    If r.getInt(1) <> 9 Then Err.Raise 5015
    r.close()
    s.executeUpdate("INSERT INTO ""tblProductos"" (""Codigo"",""Descripcion"",""IdCategoria"",""Precio"") VALUES ('PRUEBA-ID','Prueba',1,1)")
    r = s.executeQuery("CALL IDENTITY()")
    r.next()
    If r.getInt(1) <> 16 Then Err.Raise 5016
    r.close()
    c.rollback()
    c.setAutoCommit(True)
    s.close()
    Print #n, "IDENTIDADES: la siguiente alta recibe 9 en clientes y 16 en productos"
    Print #n, ProbarFactura(c, False)
    Print #n, ProbarReglas(c, False)
    Print #n, ProbarRepositorio(c, False)
    texto = CompararBusquedas(1000, False)
    Print #n, texto
    If InStr(texto, "en 1000 pasos") = 0 Or InStr(texto, "en 10 pasos") = 0 Then Err.Raise 5003
    Print #n, DemoPrecision(False)
    Print #n, ProbarDescuentos(False)
    Print #n, ProbarTarea6(c, False)
    If Profundidad(1,c) <> 0 Or Profundidad(6,c) <> 3 Then Err.Raise 5004
    If RutaCategoria(8,c) <> "Catálogo > Tecnología > Accesorios > Periféricos" Then Err.Raise 5005
    texto = ImprimirArbol(0,0,c,False)
    Print #n, texto
    If InStr(texto,"Portátiles") = 0 Then Err.Raise 5006
    texto = UnidadesPorProducto(c,False)
    Print #n, texto
    If InStr(texto,"PAP-001 -> 19") = 0 Then Err.Raise 5007
    CambiarPrecio 11,125,c
    CambiarPrecio 11,129,c
    If Not DeshacerUltimoCambio(11,c) Then Err.Raise 5008
    If Not DeshacerUltimoCambio(11,c) Then Err.Raise 5009
    If DeshacerUltimoCambio(11,c) Then Err.Raise 5010
    Print #n, "PILA: dos cambios y dos deshacer correctos"
    Print #n, VerColaCobranza(c,False)
    If AtenderSiguienteCobro(c) <> 1002 Then Err.Raise 5011
    Print #n, "COLA: se atendió primero 1002"
    s = c.createStatement()
    r = s.executeQuery("SELECT COUNT(*) FROM ""tblClientes""")
    r.next()
    If r.getLong(1) <> 8 Then Err.Raise 5000
    r.close()
    r = s.executeQuery("SELECT COUNT(*) FROM ""tblProductos""")
    r.next()
    If r.getLong(1) <> 15 Then Err.Raise 5001
    r.close()
    r = s.executeQuery("SELECT SUM(""Total"") FROM ""qryTotalesFactura"" WHERE ""Estado"" IN ('Emitida','Pagada')")
    r.next()
    If Abs(r.getDouble(1) - 57785.98) > 0.001 Then Err.Raise 5002
    r.close()
    Print #n, "DATOS Y TOTALES CORRECTOS"
    compositor = c.createInstance("com.sun.star.sdb.SingleSelectQueryComposer")
    compositor.setQuery(d.DataSource.QueryDefinitions.getByName("qryFacturasPorPeriodo").Command)
    texto = compositor.getQueryWithSubstitution()
    Print #n, "SQL DE BASE: " & texto
    registros = c.prepareStatement(texto)
    registros.setDate(1,CDateToUnoDate(DateSerial(2026,9,1)))
    registros.setDate(2,CDateToUnoDate(DateSerial(2026,9,30)))
    r = registros.executeQuery()
    filas = 0
    Do While r.next()
        filas = filas + 1
    Loop
    r.close(): registros.close()
    If filas <> 7 Then Err.Raise 5012
    Print #n, "CONSULTA PARAMETRIZADA: siete facturas en septiembre"
    If Not d.BasicLibraries.hasByName("Standard") Then d.BasicLibraries.createLibrary("Standard")
    d.BasicLibraries.loadLibrary("Standard")
    biblioteca = d.BasicLibraries.getByName("Standard")
    nombres = GlobalScope.BasicLibraries.getByName("Standard").getElementNames()
    For Each nombre In nombres
        If nombre <> "Verificar" Then
            If biblioteca.hasByName(nombre) Then biblioteca.removeByName(nombre)
            biblioteca.insertByName(nombre,GlobalScope.BasicLibraries.getByName("Standard").getByName(nombre))
        End If
    Next nombre
    biblioteca.insertByName("ValidarContexto", "Option Explicit" & Chr(10) & "Option VBASupport 1" & Chr(10) & _
        "Public Function ProbarPredeterminado() As String" & Chr(10) & _
        "ProbarPredeterminado = ProbarRepositorio(mostrar:=False)" & Chr(10) & _
        "CerrarConexionBase" & Chr(10) & "End Function")
    s.close()
    c.close()
    d.store()
    d.close(True)
    d = StarDesktop.loadComponentFromURL(ConvertToURL("{odb}"), "_blank", 0, Array())
    c = d.DataSource.getIsolatedConnection("", "")
    s = c.createStatement()
    r = s.executeQuery("SELECT COUNT(*) FROM ""tblFacturas""")
    r.next()
    If r.getLong(1) <> 7 Then Err.Raise 5013
    r.close(): s.close()
    Print #n, "REAPERTURA: siete facturas conservadas"
    proveedor = CreateUnoService("com.sun.star.script.provider.MasterScriptProviderFactory").createScriptProvider(d)
    macro = proveedor.getScript("vnd.sun.star.script:Standard.modPruebasObjetos.ProbarRepositorio?language=Basic&location=document")
    indices = Array(): valores = Array()
    texto = macro.invoke(Array(c,False),indices,valores)
    Print #n, "MACROS DEL DOCUMENTO: " & texto
    macro = proveedor.getScript("vnd.sun.star.script:Standard.ValidarContexto.ProbarPredeterminado?language=Basic&location=document")
    texto = macro.invoke(Array(),indices,valores)
    Print #n, "CONEXIÓN DEL DOCUMENTO: " & texto
    c.close()
    d.store()
    d.close(True)
    Print #n, "FIN"
    Close #n
    StarDesktop.terminate()
    Exit Sub
Falla:
    Print #n, "ERROR " & Err.Number & " " & Err.Description
    Close #n
    On Error Resume Next
    c.rollback()
    c.close()
    d.close(True)
    StarDesktop.terminate()
End Sub
'''
    for nombre, contenido in modulos.items():
        (biblioteca / (nombre + ".xba")).write_text(
            '<?xml version="1.0" encoding="UTF-8"?>\n'
            '<!DOCTYPE script:module PUBLIC "-//OpenOffice.org//DTD OfficeDocument 1.0//EN" "module.dtd">\n'
            '<script:module xmlns:script="http://openoffice.org/2000/script" '
            f'script:name="{nombre}" script:language="StarBasic">{escape(contenido)}</script:module>', encoding="utf-8")
    (biblioteca / "script.xlb").write_text(
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<!DOCTYPE library:library PUBLIC "-//OpenOffice.org//DTD OfficeDocument 1.0//EN" "library.dtd">\n'
        '<library:library xmlns:library="http://openoffice.org/2000/library" library:name="Standard" '
        'library:readonly="false" library:passwordprotected="false">'
        + ''.join(f'<library:element library:name="{nombre}"/>' for nombre in modulos)
        + '</library:library>', encoding="utf-8")
    print(f"Perfil, base y resultados: {trabajo}", flush=True)
    proceso = subprocess.Popen(base + ["macro:///Standard.Verificar.Ejecutar()"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    try:
        _, errores = proceso.communicate(timeout=120)
    except subprocess.TimeoutExpired:
        proceso.terminate()
        proceso.communicate(timeout=10)
        raise RuntimeError(f"LibreOffice no terminó; revise {salida}")
    resultado = salida.read_text() if salida.exists() else "SIN RESULTADO: la macro no se ejecutó o no compiló."
    print(resultado)
    if proceso.returncode or "ERROR " in resultado or "FIN" not in resultado:
        raise RuntimeError(errores.decode(errors="replace")[-1500:] + "\n" + resultado)
    if plantilla:
        for pendiente in ["Totales 9146.70 / 1463.47 / 10610.17", "Rechaza emitir sin líneas", "Rechaza emitir sin cliente", "Rechaza anular un borrador", "Permite anular una emitida"]:
            assert "FALLA: " + pendiente in resultado, f"La plantilla no detectó el ejercicio pendiente: {pendiente}"
        assert "Correcto: Línea inmutable" in resultado, "La plantilla alteró una regla ajena a los ejercicios."
        print("Plantilla: se detectaron las reglas pendientes como se esperaba.")
    else:
        assert "FALLA" not in resultado, "La solución incumple una regla."
    return trabajo


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--soffice", default=shutil.which("soffice") or "/Applications/LibreOffice.app/Contents/MacOS/soffice")
    parser.add_argument("--plantilla", action="store_true", help="Comprueba que los ejercicios incompletos se detectan")
    args = parser.parse_args()
    ejecutar(args.soffice, args.plantilla)
