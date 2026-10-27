# Repository Guidelines

## Project Structure & Module Organization

This repository contains two parallel, eight-session invoicing courses in Spanish.

- `access/`: Microsoft Access guides and VBA kits for Windows.
- `libreoffice/`: LibreOffice Base guides and Basic kits targeting embedded HSQLDB 1.8.
- Each course has `guia_estudiante/`, `guia_instructor/`, `kit_estudiante/`, and `kit_instructor/`. Kits contain `datos/` CSV fixtures and `vba/` or `basic/` modules; student illustrations live in `guia_estudiante/img/`.
- `scripts/` contains verification tools; `docs/` records design, plans, verification scope, and evidence.

Keep course coverage and example data aligned. Distribute only student guides and kits to students; instructor folders contain solutions.

## Build, Test, and Development Commands

Run from the repository root:

- `python3 scripts/verificar_materiales.py`: check course parity, encodings, CSV equivalence, SVG validity, and local Markdown links.
- `python3 scripts/verificar_materiales.py --access-baseline eeb582d`: additionally confirm original Access materials remain byte-for-byte unchanged.
- `python3 scripts/verificar_libreoffice.py`: execute the complete Basic solution against LibreOffice.
- `python3 scripts/verificar_libreoffice.py --plantilla`: verify expected failures in unfinished student exercises.
- `python3 scripts/verificar_sql_guias.py`: execute guide SQL and check persistence after reopening the database.

Native checks require LibreOffice and Java; use `--soffice /path/to/soffice` when needed. There is no application build command: databases, forms, and reports are constructed through the course instructions.

## Coding Style & Naming Conventions

Follow `.editorconfig` and `.gitattributes`. Access kit CSV, VBA, and `LEEME.txt` files use Windows-1252/CRLF; LibreOffice files, Markdown, SVG, and Python use UTF-8/LF. Preserve accents and avoid bulk encoding conversions.

Use four-space indentation in Python and Basic. Retain Spanish explanations and established names: `labNN_*.md`, `sesionNN_*.md`, `mod*.bas`, and `cls*`. Preserve `Option Explicit` and platform-specific APIs. No formatter or linter is configured.

## Testing Guidelines

Verification uses Python scripts and Basic checks, including `modPruebasObjetos.bas`; no percentage coverage gate is configured. Run material checks for documentation changes and native checks for Basic or SQL changes. Keep student TODOs intentional. Record relevant evidence and manual UI checks in [the verification document](docs/verificacion-libreoffice.md); headless checks do not certify form/report layout or classroom workflows.

## Commit & Pull Request Guidelines

Use concise, imperative English subjects, following history: `Add`, `Clarify`, or `Move`. Keep changes focused. PR descriptions should identify affected courses, explain teaching or compatibility changes, list verification commands and results, and include screenshots when changing visual teaching materials or UI instructions.
