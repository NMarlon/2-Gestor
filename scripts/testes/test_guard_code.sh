#!/usr/bin/env bash
# test_guard_code.sh - testes do scripts/guard-code.sh (E-044).
#
# Payloads sinteticos; nao toca em perfil do Hermes.
# Saida PASS/FAIL; exit 0 somente se todos passarem.
#
#   bash scripts/testes/test_guard_code.sh
set -uo pipefail

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GUARD="$(cd "$AQUI/.." && pwd)/guard-code.sh"

PASS=0
FAIL=0
pass() { PASS=$((PASS + 1)); echo "PASS  $*"; }
fail() { FAIL=$((FAIL + 1)); echo "FAIL  $*"; }

# rodar PAYLOAD -> stdout do guard; $? = exit do guard
rodar() {
  printf '%s' "$1" | bash "$GUARD"
}

teste_block() { # teste_block NOME PAYLOAD
  local nome="$1" payload="$2" saida rc
  saida="$(rodar "$payload")"
  rc=$?
  if [ "$rc" -eq 0 ] && printf '%s' "$saida" | grep -q '"decision":"block"'; then
    pass "$nome: bloqueou"
  else
    fail "$nome: esperado block (rc=$rc, saida=$saida)"
  fi
}

teste_passa() { # teste_passa NOME PAYLOAD
  local nome="$1" payload="$2" saida rc
  saida="$(rodar "$payload")"
  rc=$?
  if [ "$rc" -eq 0 ] && [ -z "$saida" ]; then
    pass "$nome: passou sem saida"
  else
    fail "$nome: esperado passar (rc=$rc, saida=$saida)"
  fi
}

P_WRITE_PY='{"hook_event_name":"pre_tool_call","tool_name":"write_file","tool_input":{"path":"x.py"}}'
P_WRITE_MD='{"hook_event_name":"pre_tool_call","tool_name":"write_file","tool_input":{"path":"DOCS/x.md"}}'
P_PATCH_PY='{"hook_event_name":"pre_tool_call","tool_name":"patch","tool_input":{"path":"scripts/medir-cdp.py"}}'
P_PATCH_MD='{"hook_event_name":"pre_tool_call","tool_name":"patch","tool_input":{"path":"briefs/x.md"}}'
P_SOUL='{"hook_event_name":"pre_tool_call","tool_name":"write_file","tool_input":{"path":"C:\\Users\\Marlon\\AppData\\Local\\hermes\\profiles\\ctm-p06\\SOUL.md"}}'
P_TERM_REDIR='{"hook_event_name":"pre_tool_call","tool_name":"terminal","tool_input":{"command":"echo x > x.py"}}'
P_TERM_RUN='{"hook_event_name":"pre_tool_call","tool_name":"terminal","tool_input":{"command":"python scripts/verificar.py"}}'
P_INVALIDO='{isto nao e json'
# Extras: variacoes de redirecionamento/tee e isencao.
P_TERM_APPEND='{"hook_event_name":"pre_tool_call","tool_name":"terminal","tool_input":{"command":"echo x >> y.js"}}'
P_TERM_TEE='{"hook_event_name":"pre_tool_call","tool_name":"terminal","tool_input":{"command":"echo x | tee z.sh"}}'
P_TERM_CAT='{"hook_event_name":"pre_tool_call","tool_name":"terminal","tool_input":{"command":"cat > w.cmd"}}'
P_TERM_DOCS='{"hook_event_name":"pre_tool_call","tool_name":"terminal","tool_input":{"command":"echo x > DOCS/x.py"}}'
P_TERM_NODE='{"hook_event_name":"pre_tool_call","tool_name":"terminal","tool_input":{"command":"node scripts/deploy-theme.mjs --dry-run"}}'
P_TERM_FD='{"hook_event_name":"pre_tool_call","tool_name":"terminal","tool_input":{"command":"python scripts/verificar.py 2>&1"}}'
P_WRITE_WIN='{"hook_event_name":"pre_tool_call","tool_name":"write_file","tool_input":{"file_path":"C:\\\\proj\\\\app\\\\main.ts"}}'

echo "== guard-code.sh =="
teste_block  "write_file x.py"              "$P_WRITE_PY"
teste_passa  "write_file DOCS/x.md"         "$P_WRITE_MD"
teste_block  "patch medir-cdp.py"           "$P_PATCH_PY"
teste_passa  "patch briefs/x.md"            "$P_PATCH_MD"
teste_passa  "write_file SOUL.md (perfil)"  "$P_SOUL"
teste_block  "terminal echo > x.py"         "$P_TERM_REDIR"
teste_passa  "terminal python verificar.py" "$P_TERM_RUN"
teste_passa  "JSON invalido"                "$P_INVALIDO"
teste_block  "terminal echo >> y.js"        "$P_TERM_APPEND"
teste_block  "terminal tee z.sh"            "$P_TERM_TEE"
teste_block  "terminal cat > w.cmd"         "$P_TERM_CAT"
teste_passa  "terminal > DOCS/x.py"         "$P_TERM_DOCS"
teste_passa  "terminal node --dry-run"      "$P_TERM_NODE"
teste_passa  "terminal 2>&1"                "$P_TERM_FD"
teste_block  "write_file main.ts (file_path)" "$P_WRITE_WIN"

echo
echo "PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] || exit 1
exit 0
