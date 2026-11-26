#!/usr/bin/env bash
# test_commit_agent.sh - testes do scripts/commit-agent.sh v2.
#
# Roda SEMPRE em repositorios temporarios (mktemp -d); nunca no repo real.
# Saida PASS/FAIL; exit 0 somente se todos passarem.
#
#   bash scripts/testes/test_commit_agent.sh
set -uo pipefail

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTE="$(cd "$AQUI/.." && pwd)/commit-agent.sh"
RAIZ="$(mktemp -d)"
# pwd -W devolve caminho Windows (C:/...), que o git.exe entende; /tmp/... nao.
RAIZ="$(cd "$RAIZ" && { pwd -W 2>/dev/null || pwd; })"
trap 'rm -rf "$RAIZ"' EXIT

PASS=0
FAIL=0
pass() { PASS=$((PASS + 1)); echo "PASS  $*"; }
fail() { FAIL=$((FAIL + 1)); echo "FAIL  $*"; }

novo_repo() {
  local d="$1"
  mkdir -p "$d"
  git -C "$d" init -q -b main
  git -C "$d" config user.name "Teste"
  git -C "$d" config user.email "teste@exemplo.local"
  git -C "$d" config commit.gpgsign false
  git -C "$d" config core.autocrlf false
  printf 'base-a\n' > "$d/a.md"
  printf 'base-b\n' > "$d/b.md"
  printf 'base-c\n' > "$d/comp.md"
  git -C "$d" add a.md b.md comp.md
  git -C "$d" commit -qm base
}

agente() { # agente DIR args...
  local d="$1"; shift
  ( cd "$d" && bash "$AGENTE" "$@" )
}

nomes_do_commit() { # nomes_do_commit DIR COMMIT
  git -C "$1" show --pretty=format: --name-only "$2" | sed '/^$/d'
}

# --- T2: baseline `git commit -- path` ---------------------------------------
teste_t2() {
  local d="$RAIZ/t2" nomes
  novo_repo "$d"
  printf 'A2\n' >> "$d/a.md"
  git -C "$d" add a.md
  printf 'B2\n' >> "$d/b.md"
  ( cd "$d" && git commit -qm "B" -- b.md )

  nomes="$(nomes_do_commit "$d" HEAD)"
  if [ "$nomes" = "b.md" ]; then
    pass "T2: baseline git commit -- path levou so b.md"
  else
    fail "T2: commit levou [$nomes] (esperado b.md)"
  fi
  if git -C "$d" show :a.md | grep -qx 'A2'; then
    pass "T2: a.md continua staged com o conteudo de A"
  else
    fail "T2: a.md nao esta staged com A2"
  fi
}

# --- T3: v2 (indice temporario + CAS) ---------------------------------------
teste_t3() {
  local d="$RAIZ/t3" nomes staged rc
  novo_repo "$d"
  printf 'A2\n' >> "$d/a.md"
  git -C "$d" add a.md
  printf 'B2\n' >> "$d/b.md"

  agente "$d" AGENTE-B -m "B" -- b.md >"$RAIZ/t3.out" 2>&1
  rc=$?
  if [ "$rc" -ne 0 ]; then
    fail "T3: commit-agent saiu $rc"
    sed 's/^/      /' "$RAIZ/t3.out"
    return
  fi

  nomes="$(nomes_do_commit "$d" HEAD)"
  staged="$(git -C "$d" diff --cached --name-only | sed '/^$/d')"
  if [ "$nomes" = "b.md" ]; then
    pass "T3: commit de B levou so b.md (indice temporario + CAS)"
  else
    fail "T3: commit levou [$nomes] (esperado b.md)"
  fi
  if [ "$staged" = "a.md" ]; then
    pass "T3: stage de A intacto (so a.md staged no indice compartilhado)"
  else
    fail "T3: stage compartilhado ficou [$staged] (esperado so a.md)"
  fi
  if git -C "$d" show :a.md | grep -qx 'A2'; then
    pass "T3: conteudo de A continua no stage"
  else
    fail "T3: conteudo de A se perdeu no stage"
  fi
}

# --- T4: 2 processos x 20 commits concorrentes ------------------------------
teste_t4() {
  local d="$RAIZ/t4" falhas="$RAIZ/t4.falhas"
  local total extra misturados=0 n_falhas=0 c s nome esperado
  local i pa pb
  novo_repo "$d"
  : > "$falhas"

  (
    i=1
    while [ "$i" -le 20 ]; do
      printf 'A %s\n' "$i" > "$d/a-$i.md"
      if ! ( cd "$d" && bash "$AGENTE" AGENTE-A -m "A $i" -- "a-$i.md" ) >>"$RAIZ/t4-a.log" 2>&1; then
        printf 'A %s\n' "$i" >> "$falhas"
      fi
      i=$((i + 1))
    done
  ) &
  pa=$!

  (
    i=1
    while [ "$i" -le 20 ]; do
      printf 'B %s\n' "$i" > "$d/b-$i.md"
      if ! ( cd "$d" && bash "$AGENTE" AGENTE-B -m "B $i" -- "b-$i.md" ) >>"$RAIZ/t4-b.log" 2>&1; then
        printf 'B %s\n' "$i" >> "$falhas"
      fi
      i=$((i + 1))
    done
  ) &
  pb=$!

  wait "$pa"
  wait "$pb"

  total="$(git -C "$d" rev-list --count HEAD)"
  extra=$((total - 1))

  for c in $(git -C "$d" rev-list HEAD | sed '$d'); do
    s="$(git -C "$d" show -s --format=%s "$c")"
    case "$s" in
      A\ *) esperado="a-${s#A }.md" ;;
      B\ *) esperado="b-${s#B }.md" ;;
      *) misturados=$((misturados + 1)); continue ;;
    esac
    nome="$(nomes_do_commit "$d" "$c")"
    [ "$nome" = "$esperado" ] || misturados=$((misturados + 1))
  done

  n_falhas="$(grep -c . "$falhas" 2>/dev/null || true)"
  [ -n "$n_falhas" ] || n_falhas=0

  if [ "$extra" -eq 40 ] && [ "$misturados" -eq 0 ] && [ "$n_falhas" -eq 0 ]; then
    pass "T4: 2 sessoes x 20 commits concorrentes -> 40/40, 0 misturados, 0 falhas"
  else
    fail "T4: commits_extra=$extra misturados=$misturados falhas=$n_falhas (esperado 40/0/0)"
    sed 's/^/      /' "$RAIZ/t4-a.log" "$RAIZ/t4-b.log" 2>/dev/null | tail -40
  fi
}

# --- T5: SEM_ADD=1 commita so o stage preparado, sem varrer o resto ---------
teste_t5() {
  local d="$RAIZ/t5" nomes rc
  novo_repo "$d"
  printf 'A2\n' >> "$d/a.md"
  git -C "$d" add a.md
  printf 'B2\n' >> "$d/b.md"   # modificado, NAO encenado

  SEM_ADD=1 agente "$d" AGENTE-A -m "A" -- a.md >"$RAIZ/t5.out" 2>&1
  rc=$?
  if [ "$rc" -ne 0 ]; then
    fail "T5: SEM_ADD=1 saiu $rc"
    sed 's/^/      /' "$RAIZ/t5.out"
    return
  fi

  nomes="$(nomes_do_commit "$d" HEAD)"
  if [ "$nomes" = "a.md" ]; then
    pass "T5: SEM_ADD=1 commitou so o stage (a.md)"
  else
    fail "T5: SEM_ADD=1 levou [$nomes] (esperado a.md)"
  fi
  if git -C "$d" diff --quiet -- b.md; then
    fail "T5: b.md nao deveria ter entrado (working tree dele sumiu?)"
  else
    pass "T5: b.md continua modificado fora do commit"
  fi
}

# --- T6: lock com 4 concorrentes --------------------------------------------
# Teto de 15 s: o requisito e serializar sem deadlock. Com a maquina carregada
# (dois executores rodando), 4 commits ja levaram ~7 s so de custo de processo
# git no Windows; 5 s mediria a carga da maquina, nao o lock.
teste_t6() {
  local d="$RAIZ/t6" i t0 t1 ms total
  novo_repo "$d"

  t0="$(date +%s%N)"
  for i in 1 2 3 4; do
    printf 'C %s\n' "$i" > "$d/c-$i.md"
    ( cd "$d" && bash "$AGENTE" "AGENTE-C$i" -m "C $i" -- "c-$i.md" ) \
      >"$RAIZ/t6-$i.log" 2>&1 &
  done
  wait
  t1="$(date +%s%N)"

  ms=$(( (t1 - t0) / 1000000 ))
  total="$(git -C "$d" rev-list --count HEAD)"
  echo "T6: tempo medido: ${ms} ms (teto 15000 ms)"

  if [ "$total" -eq 5 ] && [ "$ms" -lt 15000 ]; then
    pass "T6: lock com 4 concorrentes -> 4 commits em ${ms} ms, sem deadlock"
  else
    fail "T6: total_commits=$total (esperado 5) tempo=${ms}ms (esperado <15000)"
    for i in 1 2 3 4; do sed 's/^/      /' "$RAIZ/t6-$i.log" 2>/dev/null; done | tail -40
  fi
}

# --- T7a: mesmo arquivo, duas secoes (limite conhecido) ---------------------
teste_t7a() {
  local d="$RAIZ/t7a" conteudo rc
  novo_repo "$d"
  printf 'secao A\n' >> "$d/comp.md"
  printf 'secao B\n' >> "$d/comp.md"

  agente "$d" AGENTE-B -m "B" -- comp.md >"$RAIZ/t7a.out" 2>&1
  rc=$?
  if [ "$rc" -ne 0 ]; then
    fail "T7a: commit-agent saiu $rc"
    sed 's/^/      /' "$RAIZ/t7a.out"
    return
  fi

  conteudo="$(git -C "$d" show HEAD:comp.md)"
  if printf '%s\n' "$conteudo" | grep -qx 'secao B'; then
    pass "T7a: commit de B levou a secao B (mesmo arquivo)"
  else
    fail "T7a: commit de B nao levou a secao B"
    return
  fi
  if printf '%s\n' "$conteudo" | grep -qx 'secao A'; then
    echo "AVISO T7a: mesmo arquivo nao e separavel; o commit levou as DUAS secoes (limite conhecido, aceito)."
  else
    echo "NOTA  T7a: neste ambiente o commit levou so a secao de B."
  fi
}

# --- T8 (extra): nada a commitar -> exit 0, ref intocada --------------------
teste_t8() {
  local d="$RAIZ/t8" antes depois saida rc
  novo_repo "$d"
  antes="$(git -C "$d" rev-parse HEAD)"
  saida="$(agente "$d" AGENTE-A -m "nada" -- a.md 2>&1)"
  rc=$?
  depois="$(git -C "$d" rev-parse HEAD)"
  if [ "$rc" -eq 0 ] && [ "$antes" = "$depois" ] && printf '%s' "$saida" | grep -q 'nada a commitar'; then
    pass "T8: nada a commitar -> exit 0, ref intocada"
  else
    fail "T8: rc=$rc ref_mudou=$([ "$antes" = "$depois" ] && echo nao || echo sim) saida=[$saida]"
  fi
}

# --- T9 (extra): HEAD destacado -> exit 2 -----------------------------------
teste_t9() {
  local d="$RAIZ/t9" saida rc
  novo_repo "$d"
  git -C "$d" checkout -q --detach
  saida="$(agente "$d" AGENTE-A -m "x" -- a.md 2>&1)"
  rc=$?
  if [ "$rc" -eq 2 ] && printf '%s' "$saida" | grep -qi 'detached'; then
    pass "T9: HEAD destacado -> exit 2 com mensagem clara"
  else
    fail "T9: rc=$rc (esperado 2) saida=[$saida]"
  fi
}

echo "== commit-agent v2: testes em repositorios temporarios =="
echo "script: $AGENTE"
echo "temp:   $RAIZ"
echo

teste_t2
teste_t3
teste_t4
teste_t5
teste_t6
teste_t7a
teste_t8
teste_t9

echo
echo "== resultado: $PASS PASS, $FAIL FAIL =="
[ "$FAIL" -eq 0 ]
