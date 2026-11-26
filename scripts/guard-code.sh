#!/usr/bin/env bash
# guard-code.sh - barra escrita de codigo pelos perfis Hermes (E-044).
#
# Hook de pre_tool_call do Hermes. Le o payload JSON do stdin:
#   {"hook_event_name":"pre_tool_call","tool_name":"...","tool_input":{...},...}
# e responde:
#   {"decision":"block","message":"..."}  -> bloqueia
#   (nada, exit 0)                        -> deixa passar
#
# Regra (E-044): Hermes nao escreve codigo. `write_file`/`patch`/`apply_patch`
# em arquivo de codigo fora de DOCS/, briefs/, docs/, cache/, .scratch/, logs/,
# backups/, Definicoes Oficiais Manuais/ e bloqueado. `terminal` so e bloqueado
# quando grava arquivo de codigo por redirecionamento ou tee; executar script
# (python scripts/verificar.py) passa.
#
# JSON invalido ou campo ausente -> exit 0 (quem cobre falha do script e o
# fail_closed do Hermes; o guard nunca pode derrubar escrita de .md).
#
# Log: logs/guard-code.log (so decisoes de bloqueio; logs/ e ignorado pelo git).
set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$RAIZ/logs"
LOG="$LOG_DIR/guard-code.log"

# Interpretador: python e o parsers de JSON confiavel; sem ele, deixa passar.
PY=""
for candidato in python python3 py; do
  if command -v "$candidato" >/dev/null 2>&1; then
    PY="$candidato"
    break
  fi
done
[ -n "$PY" ] || exit 0

LEITOR="$(cat <<'PYEOF'
import json
import os
import re
import sys

CODIGO = {
    ".py", ".pyw", ".js", ".mjs", ".cjs", ".ts", ".tsx", ".jsx", ".php",
    ".css", ".scss", ".sass", ".sh", ".bash", ".ps1", ".bat", ".cmd",
    ".html", ".htm", ".json",
}
ISENTOS = {
    "docs", "briefs", "cache", ".scratch", "logs", "backups",
    "definições oficiais manuais", "definicoes oficiais manuais",
}
FERRAMENTAS_ESCRITA = {"write_file", "patch", "apply_patch"}


def segmentos(caminho):
    return [s for s in caminho.replace("\\", "/").split("/") if s not in ("", ".", "..")]


def isento(caminho):
    partes = segmentos(caminho)
    return any(p.lower() in ISENTOS for p in partes[:-1])


def eh_codigo(caminho):
    partes = segmentos(caminho)
    if not partes:
        return False
    nome = partes[-1].lower()
    if nome.endswith(".md"):
        return False
    return os.path.splitext(nome)[1] in CODIGO


def alvos_terminal(comando):
    # Redirecionamento: > arquivo, >> arquivo (aspas simples ou duplas).
    padrao_redir = re.compile(
        r"""(?:^|[^>])>{1,2}\s*(?:"([^"]+)"|'([^']+)'|([^\s;&|<>]+))"""
    )
    # tee [-a] arquivo
    padrao_tee = re.compile(
        r"""\btee\b(?:\s+-[A-Za-z]+)*\s+(?:"([^"]+)"|'([^']+)'|([^\s;&|<>]+))"""
    )
    alvos = []
    for padrao in (padrao_redir, padrao_tee):
        for m in padrao.finditer(comando):
            alvo = next((g for g in m.groups() if g), "")
            if alvo:
                alvos.append(alvo)
    return alvos


def main():
    bruto = sys.stdin.read()
    if not bruto.strip():
        return
    try:
        dados = json.loads(bruto)
    except Exception:
        return
    if not isinstance(dados, dict):
        return
    if dados.get("hook_event_name") not in (None, "pre_tool_call"):
        return
    ferramenta = dados.get("tool_name")
    entrada = dados.get("tool_input")
    if not isinstance(ferramenta, str) or not isinstance(entrada, dict):
        return

    alvo = None
    if ferramenta in FERRAMENTAS_ESCRITA:
        caminho = entrada.get("path") or entrada.get("file_path")
        if isinstance(caminho, str) and eh_codigo(caminho) and not isento(caminho):
            alvo = caminho
    elif ferramenta == "terminal":
        comando = entrada.get("command")
        if isinstance(comando, str):
            for candidato in alvos_terminal(comando):
                if eh_codigo(candidato) and not isento(candidato):
                    alvo = candidato
                    break

    if alvo is not None:
        print("BLOCK\t%s\t%s" % (ferramenta, alvo))


main()
PYEOF
)"

decisao="$("$PY" -c "$LEITOR" 2>/dev/null)" || exit 0
[ -n "$decisao" ] || exit 0

IFS=$'\t' read -r _tag ferramenta alvo <<< "$decisao"

if mkdir -p "$LOG_DIR" 2>/dev/null; then
  printf '%s\t%s\t%s\tblock\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$ferramenta" "$alvo" >> "$LOG" 2>/dev/null || true
fi

printf '%s\n' '{"decision":"block","message":"Hermes n\u00e3o escreve c\u00f3digo (E-044). Brief ao OpenCode."}'
exit 0
