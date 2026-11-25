#!/usr/bin/env bash
# commit-agent.sh - commit assinado por agente.
#
# Todo commit de agente sai com identidade propria, para o git log responder
# "quem fez" sem depender da identidade global do Marlon.
#
# uso:
#   scripts/commit-agent.sh GESTOR-P03 -m "P-03: ajuste de rodape"
#   scripts/commit-agent.sh GERENTE -m "GERENTE: metricas da semana" -- docs/
#
# Identidade: <nome> <nome-minusculo>@2gestor.local
# Nunca use --force, --amend de commit alheio ou push (ver AGENTS.md).
set -euo pipefail

if [ $# -lt 3 ]; then
  sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
  exit 2
fi

NOME="$1"; shift
MSG=(); PATHS=()
MODO=paths
while [ $# -gt 0 ]; do
  case "$1" in
    -m|--message) MSG+=("$2"); shift 2 ;;
    --) shift; MODO=rest; continue ;;
    *) if [ "$MODO" = rest ]; then PATHS+=("$1"); else MSG+=("$1"); fi; shift ;;
  esac
done

[ ${#MSG[@]} -eq 0 ] && { echo "erro: mensagem ausente (-m)"; exit 2; }
case "$NOME" in
  *[Aa][Mm][Ee][Nn][Dd]*|*[Ff][Oo][Rr][Cc][Ee]*) echo "erro: nada de amend/force"; exit 2 ;;
esac

case "$NOME" in
  GESTOR-*) EMAIL="$(echo "${NOME#GESTOR-}" | tr 'A-Z' 'a-z')@2gestor.local" ;;
  *)        EMAIL="$(echo "$NOME" | tr 'A-Z' 'a-z')@2gestor.local" ;;
esac

cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"

echo "== antes =="
git status --short | head -20
if [ ${#PATHS[@]} -eq 0 ]; then
  echo "erro: informe os caminhos depois de -- (nada de git add -A)"
  exit 2
fi
# guarda: um commit leva o que estiver no stage, nao so o que foi nomeado.
# Se outro agente deixou arquivo staged, ele entraria com a assinatura errada.
# Roda ANTES do git add para nao deixar residuo no stage quando recusa.
while IFS= read -r f; do
  [ -z "$f" ] && continue
  bateu=0
  for p in "${PATHS[@]}"; do
    case "$f" in "$p"|"$p"/*) bateu=1 ;; esac
  done
  if [ "$bateu" -eq 0 ]; then
    echo "erro: '$f' ja estava no stage e nao foi nomeado depois de --."
    echo "      commit cancelado para nao assinar trabalho de outro agente."
    echo "      resolve: git restore --staged -- '$f'  (e avise o dono do arquivo)"
    exit 3
  fi
done < <(git diff --cached --name-only)

git add -- "${PATHS[@]}"

git -c user.name="$NOME" -c user.email="$EMAIL" commit -m "${MSG[@]}"
echo "== depois =="
git log -1 --format="%h %an <%ae> %ad %s" --date=format:"%Y-%m-%d %H:%M"
