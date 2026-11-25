#!/usr/bin/env bash
# push.sh — empurra o master deste repo usando o PAT guardado em .env.
# O token nunca aparece na linha de comando nem no log: vai por GIT_ASKPASS.
#
# Uso:  bash scripts/push.sh            # push de master
#       bash scripts/push.sh --dry-run  # mostra o que seria enviado, sem enviar
set -euo pipefail
cd "$(dirname "$0")/.."

if [ -f .env ]; then
  # exporta só linhas KEY=valor, ignorando comentários
  while IFS= read -r linha; do
    case "$linha" in
      \#*|"") continue ;;
      *=*) export "${linha%%=*}=${linha#*=}" ;;
    esac
  done < .env
fi

if [ -z "${GITHUB_PAT:-}" ]; then
  echo "erro: GITHUB_PAT nao definido." >&2
  echo "Crie/edite C:\\MarlonScripts\\2-Gestor\\.env com a linha:" >&2
  echo "  GITHUB_PAT=github_pat_xxxxxxxx" >&2
  echo "(fine-grained, escopo Contents: read/write no repo NMarlon/2-Gestor)" >&2
  exit 1
fi

if [ "${1:-}" = "--dry-run" ]; then
  git fetch origin master --quiet || true
  git diff --stat origin/master..master
  echo "--- dry-run: nada foi enviado ---"
  exit 0
fi

export GITHUB_PAT
export GIT_ASKPASS="$PWD/scripts/git-askpass.sh"
export GIT_TERMINAL_PROMPT=0
git push origin master
