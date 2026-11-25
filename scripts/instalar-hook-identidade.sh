#!/usr/bin/env bash
# instalar-hook-identidade.sh — barra commit feito com a identidade do Marlon.
#
# Uso:  bash scripts/instalar-hook-identidade.sh [caminho-do-repo]
#       (sem argumento, instala no repo do próprio script)
#
# Por quê: em 25/11 o commit 578b4b9 do P-03 saiu como "Marlon Rebello Viana
# <marlonrviana@gmail.com>" — um agente usou a identidade global do git. Commit de
# agente tem que ter assinatura de agente (AGENTS.md). Este hook recusa antes de gravar.
set -euo pipefail

REPO="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
HOOK="$REPO/.git/hooks/pre-commit"
EMAIL_PROIBIDO="marlonrviana@gmail.com"

mkdir -p "$(dirname "$HOOK")"
cat > "$HOOK" <<'HOOKEOF'
#!/usr/bin/env bash
# Instalado por scripts/instalar-hook-identidade.sh — não editar à mão.
email="${GIT_AUTHOR_EMAIL:-$(git config user.email || true)}"
if [ "$email" = "marlonrviana@gmail.com" ]; then
  echo "" >&2
  echo "COMMIT RECUSADO: a identidade é a do Marlon ($email)." >&2
  echo "Agente não assina como o DEV. Use:" >&2
  echo "  bash scripts/commit-agent.sh <NOME-DO-AGENTE> -m \"...\" -- <caminhos>" >&2
  echo "ou git -c user.name=\"GESTOR-PXX\" -c user.email=\"pxx@2gestor.local\" commit ..." >&2
  exit 1
fi
exit 0
HOOKEOF

chmod +x "$HOOK"
echo "hook instalado: $HOOK"
echo "proibido: $EMAIL_PROIBIDO"
