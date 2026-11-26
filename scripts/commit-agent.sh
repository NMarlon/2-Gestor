#!/usr/bin/env bash
# commit-agent.sh - commit assinado por agente (v2: indice temporario + lock + CAS).
#
# Todo commit de agente sai com identidade propria, para o git log responder
# "quem fez" sem depender da identidade global do Marlon.
#
# v2: cada sessao commita somente os caminhos que nomeia, mesmo com varias
# sessoes no mesmo checkout. O stage compartilhado (.git/index) nao e usado
# para montar o commit: usa-se um indice temporario semeado com HEAD + `git add`
# dos caminhos + `commit-tree` + `update-ref` com compare-and-swap. Um lock em
# .git/agent-commit.lock serializa a montagem e a publicacao (lease de 30 s para
# lock orfao); se outra sessao commitar no meio, o CAS refaz o ciclo.
#
# uso:
#   scripts/commit-agent.sh GESTOR-P03 -m "P-03: ajuste de rodape" -- caminho
#   scripts/commit-agent.sh GERENTE -m "GERENTE: metricas da semana" -- docs/
#   SEM_ADD=1 scripts/commit-agent.sh GESTOR-P03 -m "..." -- caminho
#
# Identidade: <nome> <nome-minusculo>@2gestor.local
# Nunca use --force, --amend de commit alheio ou push (ver AGENTS.md).
set -euo pipefail

uso() {
  cat <<'EOF'
uso:
  scripts/commit-agent.sh NOME -m "mensagem" -- caminho [caminho...]
  SEM_ADD=1 scripts/commit-agent.sh NOME -m "mensagem" -- caminho

Identidade: <nome> <nome-minusculo>@2gestor.local
Nunca use --force, --amend de commit alheio ou push (ver AGENTS.md).
EOF
}

if [ $# -lt 3 ]; then
  uso
  exit 2
fi

NOME="$1"; shift
MSG=(); PATHS=()
MODO=paths
while [ $# -gt 0 ]; do
  case "$1" in
    -m|--message)
      if [ $# -lt 2 ]; then
        echo "erro: -m sem mensagem"
        exit 2
      fi
      MSG+=("$2"); shift 2 ;;
    --) shift; MODO=rest; continue ;;
    *)
      if [ "$MODO" = rest ]; then PATHS+=("$1"); else MSG+=("$1"); fi
      shift ;;
  esac
done

[ ${#MSG[@]} -eq 0 ] && { echo "erro: mensagem ausente (-m)"; exit 2; }
case "$NOME" in
  *[Aa][Mm][Ee][Nn][Dd]*|*[Ff][Oo][Rr][Cc][Ee]*) echo "erro: nada de amend/force"; exit 2 ;;
esac

case "$NOME" in
  GESTOR-*) EMAIL="$(printf '%s' "${NOME#GESTOR-}" | tr 'A-Z' 'a-z')@2gestor.local" ;;
  *)        EMAIL="$(printf '%s' "$NOME" | tr 'A-Z' 'a-z')@2gestor.local" ;;
esac

if [ ${#PATHS[@]} -eq 0 ]; then
  echo "erro: informe os caminhos depois de -- (nada de git add -A)"
  exit 2
fi

# toplevel + gitdir numa chamada so (cada processo git custa ~90 ms no Windows)
info="$(git rev-parse --show-toplevel --absolute-git-dir 2>/dev/null || true)"
if [ -z "$info" ]; then
  echo "erro: nao estou dentro de um repositorio git."
  exit 2
fi
topo="${info%%$'\n'*}"
gitdir="${info#*$'\n'}"
if [ -z "$gitdir" ] || [ "$gitdir" = "$topo" ]; then
  echo "erro: nao consegui localizar o diretorio .git."
  exit 2
fi
cd "$topo"

# base para calcular "agora" sem chamar date em cada volta do lock
epoch_base=$(date +%s)
secs_base=$SECONDS

# sleep fracionario sem gastar um processo awk por espera
dormir_ms() {
  local s
  printf -v s '%d.%03d' $(( $1 / 1000 )) $(( $1 % 1000 ))
  sleep "$s"
}

branch="$(git symbolic-ref --short HEAD 2>/dev/null || true)"
if [ -z "$branch" ]; then
  echo "erro: HEAD destacado (detached); faca checkout de uma branch antes de commitar."
  exit 2
fi

lock="$gitdir/agent-commit.lock"
idx="$gitdir/index.agent.$$.$RANDOM$RANDOM"
hook_detectado=0
hook_path=""

liberar_lock() {
  if [ -n "${lock_pid:-}" ] && [ -f "$lock/pid" ] && [ "$(cat "$lock/pid" 2>/dev/null)" = "$lock_pid" ]; then
    rm -rf -- "$lock"
  fi
  lock_pid=""
}
limpar() {
  liberar_lock
  rm -f -- "$idx"
}
trap limpar EXIT

# Diagnostico antes: read-only, roda fora do lock para nao alongar a fila.
echo "== antes =="
git status --short | sed -n '1,20p'

# ---- lock de commit (mkdir e atomico no NTFS) --------------------------------
adquirir_lock() {
  local seg_inicio=$SECONDS espera_ms agora mtime mtime2 jitter
  espera_ms=20
  while :; do
    if mkdir -- "$lock" 2>/dev/null; then
      lock_pid="$$"
      printf '%s\n' "$$" > "$lock/pid"
      return 0
    fi
    agora=$(( epoch_base + SECONDS - secs_base ))
    if [ -d "$lock" ]; then
      # lease: lock com mtime > 30 s e considerado orfao e pode ser removido.
      mtime=$(stat -c %Y -- "$lock" 2>/dev/null || stat -f %m -- "$lock" 2>/dev/null || echo 0)
      if [ "$mtime" -gt 0 ] && [ $((agora - mtime)) -gt 30 ]; then
        # recheca imediatamente antes de remover, para nao roubar lock recem-criado
        mtime2=$(stat -c %Y -- "$lock" 2>/dev/null || stat -f %m -- "$lock" 2>/dev/null || echo 0)
        if [ "$mtime2" -gt 0 ] && [ $((agora - mtime2)) -gt 30 ]; then
          rm -rf -- "$lock" 2>/dev/null || true
          continue
        fi
      fi
    fi
    if [ $((SECONDS - seg_inicio)) -ge 30 ]; then
      echo "erro: nao consegui o lock de commit ($lock) em ~30 s."
      echo "      outra sessao pode estar commitando; tente de novo em instantes."
      exit 5
    fi
    jitter=$(( RANDOM % 20 ))
    dormir_ms $((espera_ms + jitter))
    if [ "$espera_ms" -lt 150 ]; then
      espera_ms=$(( espera_ms * 3 / 2 ))
    fi
  done
}

# Guarda so vale no modo SEM_ADD: ali o conteudo vem do stage compartilhado.
# Um commit nao pode assinar arquivo encenado por outro agente.
guardar_stage_alheio() {
  local f p bateu
  while IFS= read -r -d '' f; do
    [ -z "$f" ] && continue
    bateu=0
    for p in "${PATHS[@]}"; do
      case "$f" in "$p"|"$p"/*) bateu=1 ;; esac
    done
    if [ "$bateu" -eq 0 ]; then
      echo "erro: '$f' ja estava no stage e nao foi nomeado depois de --."
      echo "      commit cancelado para nao assinar trabalho de outro agente."
      echo "      resolve: git restore --staged -- '$f'  (e avise o dono do arquivo)"
      return 3
    fi
  done < <(git diff --cached --name-only -z)
}

# commit-tree nao dispara hook: roda o pre-commit com a identidade do agente
# (o hook deste workspace recusa a identidade do Marlon).
rodar_pre_commit() {
  local saida rc=0
  if [ "${hook_detectado:-0}" -eq 0 ]; then
    hook_path="$(git rev-parse --git-path hooks/pre-commit)"
    hook_detectado=1
  fi
  [ -e "$hook_path" ] || return 0
  saida="$(GIT_AUTHOR_NAME="$NOME" GIT_AUTHOR_EMAIL="$EMAIL" \
           GIT_COMMITTER_NAME="$NOME" GIT_COMMITTER_EMAIL="$EMAIL" \
           GIT_INDEX_FILE="$idx" \
           git hook run --ignore-missing pre-commit 2>&1)" || rc=$?
  if [ "$rc" -eq 0 ]; then
    [ -n "$saida" ] && printf '%s\n' "$saida"
    return 0
  fi
  case "$saida" in
    *"not a git command"*|*"unknown subcommand"*)
      # git antigo (sem 'git hook run'): executa o hook direto, no topo do worktree.
      GIT_AUTHOR_NAME="$NOME" GIT_AUTHOR_EMAIL="$EMAIL" \
      GIT_COMMITTER_NAME="$NOME" GIT_COMMITTER_EMAIL="$EMAIL" \
      GIT_INDEX_FILE="$idx" \
        "$hook_path"
      ;;
    *)
      [ -n "$saida" ] && printf '%s\n' "$saida" >&2
      return "$rc"
      ;;
  esac
}

# Depois do update-ref, atualiza no indice compartilhado APENAS os caminhos que
# este commit levou. Sem isso, o stage das outras sessoes fica apontando para o
# HEAD antigo (arquivos commitados apareceriam como "staged" ao contrario) e o
# modo SEM_ADD copiaria um indice velho. Nenhum caminho nao nomeado e tocado.
# Roda fora do lock: o index.lock do proprio git serializa a escrita; se perder
# a corrida, tenta de novo relendo o indice.
atualizar_entrada() {
  local i=1
  while [ "$i" -le 5 ]; do
    "$@" >/dev/null 2>&1 && return 0
    dormir_ms $(( 20 + RANDOM % 40 ))
    i=$((i + 1))
  done
  return 1
}

atualizar_indice_compartilhado() {
  local antigo="$1" novo="$2" status caminho meta modo blob aviso=0
  if git diff-index --cached --quiet "$antigo" -- 2>/dev/null; then
    # Indice compartilhado igual ao HEAD antigo (ninguem tem stage): espelha o
    # novo commit de uma vez, sem varrer caminho por caminho.
    atualizar_entrada git read-tree "$novo" || aviso=1
  else
    while IFS=$'\t' read -r status caminho; do
      [ -z "${caminho:-}" ] && continue
      case "$status" in
        D*)
          atualizar_entrada git update-index --force-remove -- "$caminho" || aviso=1
          ;;
        *)
          meta="$(git ls-tree --full-tree "$novo" -- "$caminho" 2>/dev/null | sed -n '1p')"
          [ -z "$meta" ] && continue
          modo="${meta%% *}"
          meta="${meta#* }"; meta="${meta#* }"   # tira modo e tipo ("blob")
          blob="${meta%%$'\t'*}"
          atualizar_entrada git update-index --add --cacheinfo "$modo,$blob,$caminho" || aviso=1
          ;;
      esac
    done < <(git diff-tree --no-commit-id --name-status -r --no-renames \
               "$antigo" "$novo" -- "${PATHS[@]}" 2>/dev/null || true)
  fi
  if [ "$aviso" = "1" ]; then
    echo "aviso: nao atualizei todo o indice compartilhado (index.lock?). O commit saiu; rode 'git status'." >&2
  fi
}

# Monta o commit (indice temporario + tree + hook + commit-tree) para um HEAD.
# Nao toca em ref: quem publica e o update-ref com CAS, sob o lock.
# Retorna 10 quando nao ha nada a commitar e 11 quando o pre-commit recusa.
preparar_commit() {
  local alvo="$1" head_tree="${2:-}"
  rm -f -- "$idx"
  if [ "${SEM_ADD:-0}" = "1" ]; then
    guardar_stage_alheio || return $?
    if [ -z "$(git diff --cached --name-only)" ]; then
      echo "erro: SEM_ADD=1 mas o stage esta vazio"
      return 2
    fi
    if [ ! -f "$gitdir/index" ]; then
      echo "erro: SEM_ADD=1 mas $gitdir/index nao existe"
      return 2
    fi
    cp -- "$gitdir/index" "$idx"
    echo "-- SEM_ADD: commitando so o que ja estava no stage"
  else
    GIT_INDEX_FILE="$idx" git read-tree "$alvo"
    GIT_INDEX_FILE="$idx" git add -- "${PATHS[@]}"
  fi

  tree="$(GIT_INDEX_FILE="$idx" git write-tree)"
  if [ -z "$head_tree" ]; then
    head_tree="$(git rev-parse "$alvo^{tree}")"
  fi
  if [ "$tree" = "$head_tree" ]; then
    echo "nada a commitar em: ${PATHS[*]}"
    return 10
  fi

  if ! rodar_pre_commit; then
    echo "erro: pre-commit recusou o commit; nada foi commitado."
    return 11
  fi

  commit="$(git -c user.name="$NOME" -c user.email="$EMAIL" \
            commit-tree "$tree" -p "$alvo" "${msg_args[@]}")"
  return 0
}

msg_args=()
for m in "${MSG[@]}"; do
  msg_args+=(-m "$m")
done

tentativas=0
head=""
commit=""
ultimo_erro=""
while :; do
  tentativas=$((tentativas + 1))
  if [ "$tentativas" -gt 20 ]; then
    echo "erro: 20 tentativas de CAS esgotadas; outra sessao commitou durante este commit."
    echo "      nada foi perdido: os arquivos continuam no disco. Rode o comando de novo."
    [ -n "$ultimo_erro" ] && echo "      ultimo erro do git: $ultimo_erro"
    exit 4
  fi

  # Configura e publica sob o lock: o read-tree ja enxerga o topo que o
  # update-ref vai usar como pai, entao nao existe preparacao desperdicada.
  adquirir_lock

  # head + tree numa chamada so (rev-parse aceita varios pedidos)
  if ! info_head="$(git rev-parse HEAD 'HEAD^{tree}' 2>/dev/null)"; then
    echo "erro: este repositorio ainda nao tem commit (HEAD inexistente)."
    liberar_lock
    exit 2
  fi
  head="${info_head%%$'\n'*}"
  head_tree="${info_head#*$'\n'}"

  rc=0
  preparar_commit "$head" "$head_tree" || rc=$?
  case "$rc" in
    0) ;;
    10) liberar_lock; exit 0 ;;
    2|3) liberar_lock; exit "$rc" ;;
    *) liberar_lock; exit 1 ;;
  esac

  ultimo_erro=""
  if ultimo_erro="$(git update-ref -m "commit-agent: $NOME" \
                      "refs/heads/$branch" "$commit" "$head" 2>&1)"; then
    ultimo_erro=""
    liberar_lock
    break
  fi
  # CAS falhou (outra sessao commitou no meio): refaz sobre o novo topo.
  liberar_lock
  dormir_ms $(( 20 + RANDOM % 100 ))
done

atualizar_indice_compartilhado "$head" "$commit"

echo "== depois =="
git --no-pager log -1 --format="%h %an <%ae> %ad %s" --date=format:"%Y-%m-%d %H:%M"
