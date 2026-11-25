#!/usr/bin/env bash
# git-askpass.sh — responde ao git sem nunca imprimir o segredo.
# Chamado pelo git através de GIT_ASKPASS (definido em push.sh).
case "$1" in
  *sername*) printf '%s\n' "x-access-token" ;;
  *assword*) printf '%s\n' "${GITHUB_PAT:-}" ;;
  *) printf '\n' ;;
esac
