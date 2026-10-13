#!/usr/bin/env python3
"""Comprueba paridad, codificación, datos, imágenes y enlaces de los cursos."""
import argparse
import csv
import io
from pathlib import Path
import re
import subprocess
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]


def comprobar(baseline=None):
    original = {p.relative_to(ROOT / "access") for p in (ROOT / "access").rglob("*") if p.is_file()}
    nuevo = {p.relative_to(ROOT / "libreoffice") for p in (ROOT / "libreoffice").rglob("*") if p.is_file()}
    esperados = set()
    for p in original:
        nombre = str(p).replace("/vba/", "/basic/")
        if nombre.endswith(".cls"):
            nombre = nombre[:-4] + ".bas"
        nombre = nombre.replace("ventana_access.svg", "ventana_base.svg")
        esperados.add(Path(nombre))
    assert nuevo == esperados, f"Paridad: faltan {esperados - nuevo}; sobran {nuevo - esperados}"
    for p in (ROOT / "libreoffice").rglob("*"):
        if p.is_file():
            contenido = p.read_bytes()
            contenido.decode("utf-8")
            assert b"\r" not in contenido, f"CRLF inesperado: {p}"
            assert b"\xef\xbb\xbf" != contenido[:3], f"BOM inesperado: {p}"
    for p in (ROOT / "access/kit_estudiante/datos").glob("*.csv"):
        antes = list(csv.reader(io.StringIO(p.read_bytes().decode("cp1252"))))
        despues = list(csv.reader(io.StringIO((ROOT / "libreoffice/kit_estudiante/datos" / p.name).read_text())))
        assert antes == despues, f"Datos distintos: {p.name}"
    for p in ROOT.glob("*/guia_estudiante/img/*.svg"):
        ET.parse(p)
    enlaces = 0
    for p in ROOT.rglob("*.md"):
        if any(parte.startswith(".") for parte in p.relative_to(ROOT).parts):
            continue
        for destino in re.findall(r"\]\(([^)\s]+)(?:\s+[^)]*)?\)", p.read_text()):
            if destino.startswith(("https://", "http://", "mailto:", "#")):
                continue
            ruta = destino.split("#", 1)[0]
            assert (p.parent / ruta).exists(), f"Enlace roto en {p.relative_to(ROOT)}: {destino}"
            enlaces += 1
    if baseline:
        archivos = subprocess.check_output(["git", "ls-tree", "-r", "--name-only", baseline], cwd=ROOT, text=True).splitlines()
        conservados = 0
        for nombre in archivos:
            if nombre == "README.md" or nombre.startswith(("guia_", "kit_")):
                antes = subprocess.check_output(["git", "show", f"{baseline}:{nombre}"], cwd=ROOT)
                assert antes == (ROOT / "access" / nombre).read_bytes(), f"Original modificado: {nombre}"
                conservados += 1
        print(f"Access: {conservados} archivos conservados byte por byte frente a {baseline}.")
    print(f"Correcto: {len(original)} archivos por curso; seis CSV equivalentes; SVG válidos; {enlaces} enlaces locales.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--access-baseline", help="Commit anterior al traslado para verificar conservación byte por byte")
    args = parser.parse_args()
    comprobar(args.access_baseline)
