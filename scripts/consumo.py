#!/usr/bin/env python3
"""Consumo de tokens dos agentes. Somente leitura: abre os bancos em modo ro.

Fontes:
  Hermes  (gestores)  ~/AppData/Local/hermes/profiles/*/state.db   -> sessions
  OpenCode (executor) ~/.local/share/opencode/opencode.db          -> session_v2

Uso:
  python scripts/consumo.py                 # ultimos 7 dias, resumo
  python scripts/consumo.py --dias 30
  python scripts/consumo.py --projeto "Jessica Haguiwara"
  python scripts/consumo.py --json

O console do provedor (opencode.ai/console) e a fonte de faturamento; este
script mede o que o agente gastou localmente. Se divergir, vale o console.
"""

import argparse
import datetime as dt
import glob
import json
import os
import sqlite3
import sys

HERMES_PROFILES = os.path.expanduser("~/AppData/Local/hermes/profiles")
OPENCODE_DB = os.path.expanduser("~/.local/share/opencode/opencode.db")


def abrir(caminho):
    if not os.path.exists(caminho):
        return None
    return sqlite3.connect(f"file:{caminho}?mode=ro", uri=True)


def fmt(n):
    if n is None:
        return "-"
    if n >= 1_000_000:
        return f"{n/1_000_000:.2f}M"
    if n >= 1_000:
        return f"{n/1_000:.1f}k"
    return str(int(n))


def dia_hermes(iso):
    try:
        return dt.datetime.fromisoformat(iso).strftime("%Y-%m-%d")
    except Exception:
        return "?"


def dia_de(valor):
    """Aceita epoch (Hermes) ou ISO (OpenCode legado)."""
    try:
        if isinstance(valor, (int, float)):
            return dt.datetime.fromtimestamp(valor).strftime("%Y-%m-%d")
        if isinstance(valor, str) and valor.replace(".", "", 1).isdigit():
            return dt.datetime.fromtimestamp(float(valor)).strftime("%Y-%m-%d")
        return dt.datetime.fromisoformat(str(valor)).strftime("%Y-%m-%d")
    except Exception:
        return "?"


def modelo_id(m):
    if isinstance(m, str):
        try:
            return json.loads(m).get("id") or m[:40]
        except Exception:
            return m[:40]
    return str(m)


def hermes(corte, projeto):
    linhas = []
    for db in glob.glob(os.path.join(HERMES_PROFILES, "*", "state.db")):
        con = abrir(db)
        if not con:
            continue
        perfil = os.path.basename(os.path.dirname(db))
        q = ("select id, cwd, started_at, input_tokens, output_tokens, cache_read_tokens, "
             "tool_call_count, estimated_cost_usd, title, model from sessions")
        for r in con.execute(q):
            (sid, cwd, ini, tin, tout, cache, tc, custo, titulo, modelo) = r
            d = dia_de(ini) if ini else "?"
            if d < corte:
                continue
            if projeto and projeto.lower() not in (cwd or "").lower():
                continue
            # compactacao no Hermes: mensagens absorvidas por um sumario
            compact = con.execute(
                "select count(*) from messages where session_id=? "
                "and absorbed_message_uids is not null and absorbed_message_uids not in ('','[]')",
                (sid,),
            ).fetchone()[0]
            linhas.append(dict(fonte="hermes", perfil=perfil, sid=sid, dia=d, cwd=cwd or "?",
                               tin=tin or 0, tout=tout or 0, cache=cache or 0, tc=tc or 0,
                               custo=custo or 0, compact=compact, titulo=(titulo or "")[:60],
                               modelo=modelo_id(modelo)))
        con.close()
    return linhas


def opencode(corte, projeto):
    con = abrir(OPENCODE_DB)
    if not con:
        return []
    cols = {r[1] for r in con.execute("PRAGMA table_info(session_v2)")}
    if "tokens_cache_read" not in cols:
        return []
    q = ("select id, directory, time_created, tokens_input, tokens_output, tokens_cache_read, "
         "cost, title, model from session_v2")
    out = []
    for r in con.execute(q):
        (sid, pasta, ms, tin, tout, cache, custo, titulo, modelo) = r
        if not ms:
            continue
        d = dt.datetime.fromtimestamp(ms / 1000).strftime("%Y-%m-%d")
        if d < corte:
            continue
        if projeto and projeto.lower() not in (pasta or "").lower():
            continue
        compact = con.execute(
            "select count(*) from session_message where session_id=? and type='compaction'", (sid,)
        ).fetchone()[0]
        out.append(dict(fonte="opencode", perfil="opencode", sid=sid, dia=d, cwd=pasta or "?",
                        tin=tin or 0, tout=tout or 0, cache=cache or 0, tc=0,
                        custo=custo or 0, compact=compact, titulo=(titulo or "")[:60],
                        modelo=modelo_id(modelo)))
    con.close()
    return out


def resumo(linhas):
    t = dict(sessoes=len(linhas), tin=0, tout=0, cache=0, custo=0.0, compact=0)
    for l in linhas:
        for k in ("tin", "tout", "cache", "compact"):
            t[k] += l[k]
        t["custo"] += l["custo"]
    return t


def tabela(titulo, linhas, chave):
    if not linhas:
        return
    grupos = {}
    for l in linhas:
        k = chave(l)
        g = grupos.setdefault(k, dict(sessoes=0, tin=0, tout=0, cache=0, custo=0.0, compact=0))
        g["sessoes"] += 1
        for campo in ("tin", "tout", "cache", "compact"):
            g[campo] += l[campo]
        g["custo"] += l["custo"]
    print(f"\n### {titulo}")
    print(f"{'':38} {'sess':>5} {'in':>8} {'out':>7} {'cache':>9} {'compact':>7} {'US$':>8}")
    for k, g in sorted(grupos.items(), key=lambda x: -x[1]["tin"]):
        print(f"{k[:38]:38} {g['sessoes']:5} {fmt(g['tin']):>8} {fmt(g['tout']):>7} "
              f"{fmt(g['cache']):>9} {g['compact']:7} {g['custo']:8.3f}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dias", type=int, default=7)
    ap.add_argument("--projeto", default="")
    ap.add_argument("--json", action="store_true")
    a = ap.parse_args()
    corte = (dt.date.today() - dt.timedelta(days=a.dias)).strftime("%Y-%m-%d")

    hl = hermes(corte, a.projeto)
    ol = opencode(corte, a.projeto)
    tudo = hl + ol
    if a.json:
        print(json.dumps(dict(desde=corte, total=resumo(tudo), linhas=tudo),
                         ensure_ascii=False, indent=1))
        return
    if not tudo:
        print(f"nada de {corte} ate hoje")
        return
    print(f"[dias {a.dias}] desde {corte} | fuso local")
    s = resumo(tudo)
    print(f"total: {s['sessoes']} sessoes | in {fmt(s['tin'])} | out {fmt(s['tout'])} | "
          f"cache {fmt(s['cache'])} | compactacoes {s['compact']} | US$ {s['custo']:.3f}")
    tabela("por fonte", tudo, lambda l: l["fonte"])
    tabela("por projeto", tudo, lambda l: os.path.basename((l["cwd"] or "").replace("\\", "/")))
    tabela("por dia", tudo, lambda l: l["dia"])
    tabela("por modelo", tudo, lambda l: str(l["modelo"]))
    caras = sorted(tudo, key=lambda l: -l["tin"])[:5]
    print("\n### 5 sessoes mais caras (in)")
    for l in caras:
        print(f"  {l['dia']} {l['fonte']:9} {fmt(l['tin']):>8} in {l['compact']:2} compact "
              f"| {l['titulo'][:48]}")


if __name__ == "__main__":
    sys.exit(main())
