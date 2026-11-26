#!/usr/bin/env python3
"""Ficha de uma sessao de perfil Hermes - sem IA.

Sessao de gestor nasce como `oneshot` e nao aparece na lista do app. O banco do perfil guarda a
MISSAO e os COMANDOS; o texto do gestor quase nao existe ali (ele fala no stdout do `-z`).

Uso:
    python scripts/exportar-sessao.py --perfil ctm-p06 --ultimas 3
Saida: DOCS/08-GERENTE/sessoes/<perfil>-<sessao>.md + INDICE.md
"""
import argparse
import datetime
import glob
import os
import re
import sqlite3
import sys

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PERFIS = os.path.expanduser(os.path.join("~", "AppData", "Local", "hermes", "profiles"))
SAIDA = os.path.join(BASE, "DOCS", "08-GERENTE", "sessoes")

SEGREDO = re.compile(
    r"(ghp_[A-Za-z0-9]{8,}|sk-[A-Za-z0-9]{8,}|Bearer\s+[A-Za-z0-9._-]{8,}"
    r"|(?:API_)?KEY\s*[=:]\s*\S+|token\s*[=:]\s*\S+)", re.I)
COMPACTACAO = "[CONTEXT COMPACTION"


def limpar(texto, limite):
    if not texto:
        return ""
    texto = SEGREDO.sub("[OCULTO]", str(texto)).replace("\r", "")
    if len(texto) > limite:
        texto = texto[:limite].rstrip() + " ... (+%d chars)" % (len(texto) - limite)
    return texto


def listar(db, n):
    con = sqlite3.connect("file:%s?mode=ro" % db, uri=True)
    rows = list(con.execute("select id from sessions order by last_activity_at desc limit ?", (n,)))
    con.close()
    return [r[0] for r in rows]


def sessao(db, sid):
    con = sqlite3.connect("file:%s?mode=ro" % db, uri=True)
    rows = list(con.execute(
        "select role, tool_name, content, tool_calls from messages where session_id=? order by rowid",
        (sid,)))
    con.close()
    return rows


def escrever(perfil, sid, linhas):
    os.makedirs(SAIDA, exist_ok=True)
    destino = os.path.join(SAIDA, "%s-%s.md" % (perfil, sid))
    missao, comandos, falas, n_tool = "", [], [], 0
    for role, tool, content, calls in linhas:
        c = str(content or "")
        if role == "user" and c.lstrip().startswith(COMPACTACAO):
            continue
        if role == "user" and not missao:
            missao = c
        elif role == "assistant":
            if c.strip():
                falas.append(c.strip())
            if calls:
                comandos.extend(re.findall(r'"name":\s*"([^"]+)"', str(calls)))
        elif role == "tool":
            n_tool += 1

    md = ["# Sessao `%s` - `%s`" % (perfil, sid), "",
          "> Exportado em %s por `scripts/exportar-sessao.py`." % datetime.date.today().isoformat(),
          "> %d mensagens, %d saidas de ferramenta, %d comandos." % (len(linhas), n_tool, len(comandos)),
          "> O banco guarda missao e comandos; o relatorio final esta no caderno do projeto",
          "> ou no arquivo que o gestor escreveu. Segredo aparece como [OCULTO].", "",
          "## Missao recebida (%d chars)" % len(missao), "", "```",
          limpar(missao, 1500), "```", ""]
    if comandos:
        resumo = {}
        for c in comandos:
            resumo[c] = resumo.get(c, 0) + 1
        md += ["## Comandos usados", ""]
        md += ["- `%s` x %d" % (n, q) for n, q in sorted(resumo.items(), key=lambda x: -x[1])]
        md.append("")
    md += ["## O que o gestor disse", ""]
    if falas:
        md += ["- " + limpar(f, 700) for f in falas]
    else:
        md.append("_Nada gravado no banco: o relatorio foi para o stdout._")
    md.append("")

    with open(destino, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(md))
    return destino


def indice():
    os.makedirs(SAIDA, exist_ok=True)
    destino = os.path.join(SAIDA, "INDICE.md")
    itens = ["# Sessoes de gestor exportadas", "",
             "> Sessao de gestor nasce como `oneshot` e nao aparece no app; este indice e a porta.",
             "", "| Arquivo |", "|---|"]
    for caminho in sorted(glob.glob(os.path.join(SAIDA, "*.md"))):
        nome = os.path.basename(caminho)
        if nome != "INDICE.md":
            itens.append("| [`%s`](%s) |" % (nome, nome))
    with open(destino, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(itens) + "\n")
    return destino


def main() -> int:
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    ap = argparse.ArgumentParser()
    ap.add_argument("--perfil", required=True)
    ap.add_argument("--sessao")
    ap.add_argument("--ultimas", type=int, default=1)
    a = ap.parse_args()

    db = os.path.join(PERFIS, a.perfil, "state.db")
    if not os.path.exists(db):
        print("perfil sem state.db: %s" % db)
        return 1
    alvos = [a.sessao] if a.sessao else listar(db, a.ultimas)
    for sid in alvos:
        linhas = sessao(db, sid)
        if not linhas:
            print("  %s: sem mensagens" % sid)
            continue
        print("  %s/%s -> %s" % (a.perfil, sid, os.path.relpath(escrever(a.perfil, sid, linhas), BASE)))
    print("  indice:", os.path.relpath(indice(), BASE))
    return 0


if __name__ == "__main__":
    sys.exit(main())
