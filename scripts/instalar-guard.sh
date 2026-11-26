#!/usr/bin/env bash
# instalar-guard.sh - instala o guard-code.sh nos perfis Hermes (E-044).
#
# Para cada perfil:
#   1. backup config.yaml.bak-guard-<AAAAMMDD-HHMMSS>;
#   2. insere/atualiza o bloco `hooks:` preservando o resto do YAML;
#   3. registra o consentimento no shell-hooks-allowlist.json do perfil
#      (sem allowlist o Hermes nao roda o hook; `hooks doctor` acusa erro);
#   4. valida com `hermes -p <perfil> hooks list` e `hooks doctor`.
#      Se a validacao falhar, restaura os backups.
#
# NAO reinicia o Hermes: o hook vale na proxima sessao do perfil.
#
#   bash scripts/instalar-guard.sh
set -uo pipefail

BASE_PERFIS="${HERMES_PROFILES_DIR:-C:/Users/Marlon/AppData/Local/hermes/profiles}"
PERFIS=(ctm-p06 jessica-p03 painel-p05 manager-developer-hermes)
STAMP="$(date +%Y%m%d-%H%M%S)"

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RAIZ_W="$(cd "$RAIZ" && { pwd -W 2>/dev/null || pwd; })"
HOOK="$RAIZ_W/scripts/guard-code.sh"

FALHAS=0

ok()   { echo "  OK    $*"; }
erro() { echo "  ERRO  $*"; FALHAS=$((FALHAS + 1)); }

backup_unico() { # backup_unico ARQUIVO -> echo caminho do backup
  local origem="$1" destino="$1.bak-guard-$STAMP" n=1
  while [ -e "$destino" ]; do
    destino="$1.bak-guard-$STAMP-$n"
    n=$((n + 1))
  done
  cp -p "$origem" "$destino" && printf '%s' "$destino"
}

if [ ! -f "$HOOK" ]; then
  echo "ERRO: guard nao encontrado em $HOOK" >&2
  exit 1
fi
chmod +x "$HOOK" 2>/dev/null || true

echo "guard: $HOOK"
echo "perfis: ${PERFIS[*]}"
echo

for perfil in "${PERFIS[@]}"; do
  echo "[$perfil]"
  cfg="$BASE_PERFIS/$perfil/config.yaml"

  if [ ! -f "$cfg" ]; then
    erro "config.yaml nao existe: $cfg"
    echo
    continue
  fi

  bkp_cfg="$(backup_unico "$cfg")" || { erro "falha no backup de $cfg"; echo; continue; }
  ok "backup: $bkp_cfg"

  allow="$BASE_PERFIS/$perfil/shell-hooks-allowlist.json"
  bkp_allow=""
  if [ -f "$allow" ]; then
    bkp_allow="$(backup_unico "$allow")" || { erro "falha no backup de $allow"; cp -p "$bkp_cfg" "$cfg"; echo; continue; }
    ok "backup allowlist: $bkp_allow"
  fi

  # 2. YAML: remove bloco `hooks:` de topo (se existir) e acrescenta o nosso no fim.
  if ! python - "$cfg" "$HOOK" <<'PYEOF'
import os
import sys

cfg, hook = sys.argv[1], sys.argv[2]

with open(cfg, "rb") as f:
    bruto = f.read()
bom = bruto.startswith(b"\xef\xbb\xbf")
texto = bruto.decode("utf-8-sig")
nl = "\r\n" if "\r\n" in texto else "\n"

linhas = texto.splitlines(keepends=True)
saida = []
i = 0
while i < len(linhas):
    sem_eol = linhas[i].rstrip("\r\n")
    if sem_eol == "hooks:":
        # Bloco de topo: consome linhas vazias e indentadas ate o proximo topo.
        i += 1
        while i < len(linhas):
            s = linhas[i].rstrip("\r\n")
            if s.strip() == "" or s.startswith((" ", "\t")):
                i += 1
                continue
            break
        continue
    saida.append(linhas[i])
    i += 1

novo = "".join(saida)
if novo and not novo.endswith("\n"):
    novo += nl
if novo and not novo.endswith(nl):
    novo += nl

bloco = [
    "hooks:",
    "  pre_tool_call:",
    '    - command: "%s"' % hook,
    '      matcher: "write_file|patch|apply_patch"',
    "      timeout: 10",
    "      fail_closed: true",
    '    - command: "%s"' % hook,
    '      matcher: "terminal"',
    "      timeout: 10",
    "      fail_closed: true",
]
novo += nl.join(bloco) + nl

dados = novo.encode("utf-8")
if bom:
    dados = b"\xef\xbb\xbf" + dados

tmp = cfg + ".tmp-guard"
with open(tmp, "wb") as f:
    f.write(dados)
try:
    os.replace(tmp, cfg)
except OSError:
    with open(cfg, "wb") as f:
        f.write(dados)
    try:
        os.unlink(tmp)
    except OSError:
        pass
PYEOF
  then
    erro "falha ao editar YAML; restaurando $bkp_cfg"
    cp -p "$bkp_cfg" "$cfg"
    [ -n "$bkp_allow" ] && cp -p "$bkp_allow" "$allow"
    echo
    continue
  fi
  ok "hooks: gravado em config.yaml"

  # 3. Consentimento: sem allowlist o hook nao dispara e o doctor acusa erro.
  if ! python - "$BASE_PERFIS/$perfil" "$HOOK" <<'PYEOF'
import datetime
import json
import os
import sys

home, cmd = sys.argv[1], sys.argv[2]
caminho = os.path.join(home, "shell-hooks-allowlist.json")

if os.path.exists(caminho):
    try:
        with open(caminho, encoding="utf-8-sig") as f:
            dados = json.load(f)
        if not isinstance(dados, dict):
            raise ValueError("allowlist nao e um objeto JSON")
    except Exception as exc:
        print("allowlist ilegivel: %s" % exc, file=sys.stderr)
        sys.exit(3)
else:
    dados = {"approvals": []}

aprovacoes = dados.get("approvals")
if not isinstance(aprovacoes, list):
    aprovacoes = []

evento = "pre_tool_call"
aprovacoes = [
    e for e in aprovacoes
    if not (isinstance(e, dict) and e.get("event") == evento and e.get("command") == cmd)
]

agora = datetime.datetime.now(datetime.timezone.utc).isoformat().replace("+00:00", "Z")
mtime = datetime.datetime.fromtimestamp(
    os.path.getmtime(cmd), datetime.timezone.utc
).isoformat().replace("+00:00", "Z")
aprovacoes.append({
    "event": evento,
    "command": cmd,
    "approved_at": agora,
    "script_mtime_at_approval": mtime,
})
dados["approvals"] = aprovacoes

tmp = caminho + ".tmp-guard"
with open(tmp, "w", encoding="utf-8") as f:
    json.dump(dados, f, sort_keys=True, indent=2)
    f.write("\n")
os.replace(tmp, caminho)
PYEOF
  then
    erro "falha ao gravar allowlist; restaurando $bkp_cfg"
    cp -p "$bkp_cfg" "$cfg"
    if [ -n "$bkp_allow" ]; then
      cp -p "$bkp_allow" "$allow"
    else
      rm -f "$allow"
    fi
    echo
    continue
  fi
  ok "allowlist: pre_tool_call aprovado"

  # 4. Validacao pelo proprio Hermes.
  listagem="$(hermes -p "$perfil" hooks list 2>&1)"
  if printf '%s' "$listagem" | grep -Fq "pre_tool_call" && printf '%s' "$listagem" | grep -Fq "$HOOK"; then
    ok "hooks list: hook listado"
  else
    erro "hooks list nao mostrou o hook; restaurando backups"
    cp -p "$bkp_cfg" "$cfg"
    if [ -n "$bkp_allow" ]; then cp -p "$bkp_allow" "$allow"; else rm -f "$allow"; fi
    printf '%s\n' "$listagem" | sed 's/^/        /'
    echo
    continue
  fi

  doutor="$(hermes -p "$perfil" hooks doctor 2>&1)"
  if printf '%s' "$doutor" | grep -Fq "All shell hooks look healthy."; then
    ok "hooks doctor: saudavel"
  else
    erro "hooks doctor com problema; restaurando backups"
    cp -p "$bkp_cfg" "$cfg"
    if [ -n "$bkp_allow" ]; then cp -p "$bkp_allow" "$allow"; else rm -f "$allow"; fi
    printf '%s\n' "$doutor" | sed 's/^/        /'
    echo
    continue
  fi

  echo "  (sem reiniciar o Hermes; vale na proxima sessao do perfil)"
  echo
done

echo "falhas: $FALHAS"
[ "$FALHAS" -eq 0 ] || exit 1
echo "guard instalado nos ${#PERFIS[@]} perfis."
exit 0
