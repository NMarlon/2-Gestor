#!/usr/bin/env python3
"""Audita os cadernos dos gestores — sem IA.

Convenção (`REGRAS.md` §14): todo caderno `DOCS/P-*/GESTOR.md` começa com

    **Estado:** AAAA-MM-DD · uma frase

O texto é do gestor; a **data** é o gatilho: caderno sem data, ou com data velha, significa
gestor trabalhando sem registrar. Roda no digest das 6h30.

Uso:  python scripts/check-cadernos.py [--dias 7]
Código: 0 tudo em dia · 2 achou caderno atrasado/ausente · 1 erro.
"""
import datetime
import glob
import os
import re
import sys

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PADRAO = os.path.join(BASE, "DOCS", "P-*", "GESTOR.md")
LINHA = re.compile(r"^\*\*Estado:\*\*\s*(\d{4}-\d{2}-\d{2})\s*·\s*(.+)$", re.M)


def auditar(dias):
    hoje = datetime.date.today()
    achados, ok = [], []
    for caminho in sorted(glob.glob(PADRAO)):
        projeto = os.path.basename(os.path.dirname(caminho))
        if not os.path.exists(caminho):
            continue
        texto = open(caminho, encoding="utf-8", errors="replace").read()
        m = LINHA.search(texto)
        if not m:
            achados.append((projeto, "sem linha `**Estado:**` — caderno não segue a convenção", None))
            continue
        try:
            data = datetime.date.fromisoformat(m.group(1))
        except ValueError:
            achados.append((projeto, f"data inválida: {m.group(1)}", None))
            continue
        idade = (hoje - data).days
        if idade > dias:
            achados.append((projeto, f"estado de {m.group(1)} — {idade} dias sem atualizar", idade))
        else:
            ok.append((projeto, m.group(1), idade))
    return ok, achados


def main() -> int:
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass

    dias = 7
    if "--dias" in sys.argv:
        try:
            dias = int(sys.argv[sys.argv.index("--dias") + 1])
        except (IndexError, ValueError):
            print("uso: check-cadernos.py [--dias N]")
            return 1

    ok, achados = auditar(dias)
    print(f"**Cadernos:** {len(ok) + len(achados)} encontrados · limite {dias} dias")
    for projeto, data, idade in ok:
        print(f"- {projeto}: {data} ({idade}d)")
    if not achados:
        print("Todos em dia.")
        return 0
    for projeto, motivo, _ in achados[:8]:
        print(f"- **{projeto}**: {motivo}")
    if len(achados) > 8:
        print(f"- … e mais {len(achados) - 8}.")
    print("Cobrar do gestor o `**Estado:**` com data de hoje (REGRAS §14).")
    return 2


if __name__ == "__main__":
    sys.exit(main())
