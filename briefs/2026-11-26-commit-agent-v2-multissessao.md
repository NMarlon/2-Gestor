# Brief — 2-Gestor · commit-agent v2 · várias sessões commitando em paralelo

**Data:** 2026-11-26 · **Executor:** OpenCode · **Repo:** `C:\MarlonScripts\2-Gestor`
**Autor:** GERENTE · **Origem:** incidente de 25/11 (M-025 foi para o commit `1fd7f28` de
outra sessão) + decisão do Marlon: multi-sessão fica, cada sessão commita só os seus arquivos.

## Contexto já verificado (não re-investigue)

- `DOCS/08-GERENTE/COMMITS-MULTISSESSAO.md` tem o diagnóstico, a pesquisa e os testes.
- Provado em repositório descartável, nesta máquina: (T1) `git add` compartilhado mistura
  arquivos no commit; (T2) `git commit -- path` separa arquivos distintos mas lê o working
  tree; (T3) índice temporário + `commit-tree` + `update-ref` separa e preserva o index da
  outra sessão; (T4) 2 sessões × 20 commits concorrentes = **40/40, 0 misturados**;
  (T6) lock `mkdir` serializa 4 concorrentes em <250 ms; (T7a) **o mesmo arquivo não é
  separável** — mistura é o comportamento esperado e aceito.
- O script atual `scripts/commit-agent.sh` (81 linhas) já tem: parsing `NOME -m MSG -- paths`,
  guarda contra stage alheio, `SEM_ADD=1`, identidade `<nome>@2gestor.local`.
- O hook `pre-commit` dos repos recusa commit com a identidade do Marlon.

## Escopo único

Reescrever o **miolo** de `scripts/commit-agent.sh` para o padrão provado (índice temporário
+ lock + CAS), **preservando a interface e o comportamento de fora**, e entregar os testes.

### Requisitos funcionais do v2

1. **Interface idêntica:** `scripts/commit-agent.sh NOME -m "msg" -- caminho [caminho...]`.
   `SEM_ADD=1` continua aceito (ver item 8).
2. **Lock de commit:** `.git/agent-commit.lock` criado com `mkdir` (atômico em NTFS),
   retry com espera crescente e jitter, teto de ~30 s; lock com mtime > 30 s é considerado
   órfão e pode ser removido (lease). `trap` remove o lock no exit. Sem deadlock.
3. **Índice temporário:** `GIT_INDEX_FILE=.git/index.agent.<pid>.<rnd>`, semeado com
   `git read-tree <HEAD>`. **Nunca** usar nem alterar o `.git/index` compartilhado.
4. **Stage só dos caminhos:** `git add -- "${PATHS[@]}"` no índice temporário.
5. **Commit atômico com CAS:**
   - `head=$(git rev-parse HEAD)`; `tree=$(GIT_INDEX_FILE=$idx git write-tree)`;
   - `commit=$(git -c user.name=... -c user.email=... commit-tree $tree -p $head -m "$MSG")`;
   - `git update-ref refs/heads/<branch> $commit $head` — se o `update-ref` falhar porque
     outra sessão commitou, **refazer** o ciclo (read-tree do novo HEAD, add, tree,
     commit-tree) até 20 tentativas com jitter. Nunca falhar por concorrência.
6. **Nada a commitar:** se o índice temporário não difere do HEAD, sair **0** com mensagem
   clara ("nada a commitar em: ..."), sem tocar em ref.
7. **Branch:** usar `git symbolic-ref --short HEAD`; HEAD destacado → erro claro (exit 2).
8. **`SEM_ADD=1`:** copiar o índice atual para o temporário (`cp .git/index $idx`) em vez de
   `read-tree`+`add`, e commitar exatamente esse conteúdo — mantém quem hoje prepara o stage
   à mão. A guarda de "arquivo alheio no stage" só vale nesse modo (no modo normal não há
   stage compartilhado).
9. **Hook pre-commit:** antes do `commit-tree`, rodar `git hook run pre-commit` (se existir
   e o git suportar); se falhar, abortar sem criar commit. O `commit-tree` não dispara hook
   sozinho.
10. **Identidade:** mesma regra atual (`GESTOR-PXX` → `pxx@2gestor.local`; demais →
    `nome@2gestor.local`). Nada de `--amend`, `--force`, `add -A`, `commit -a`, `stash`.
11. **Diagnóstico:** imprimir antes (`git status --short` limitado) e depois (`git log -1`
    com hash, autor, data, assunto). Em caso de CAS esgotado, exit 4 com instrução.

### Entregáveis

- `scripts/commit-agent.sh` — v2.
- `scripts/commit-agent-v1.sh` — cópia fiel do atual **antes** de alterar (rollback de um `mv`).
- `scripts/testes/test_commit_agent.sh` — testes em repositórios temporários (`mktemp -d`),
  **nunca** no repo real:
  - T2: sessão A deixa `a.md` staged; sessão B commita só `b.md`; o commit tem só `b.md` e
    `a.md` continua staged.
  - T3: índice temporário + CAS; idem T2, e o stage de A intacto.
  - T4: 2 processos × 20 commits concorrentes → **40 commits, 0 misturados, 0 falhas**.
  - T6: lock com 4 concorrentes → todos terminam < 5 s, sem deadlock.
  - T7a: mesmo arquivo com duas seções → commit de B leva as duas (comportamento esperado;
    imprimir aviso no teste, não falhar).
  - Saída PASS/FAIL e exit 0 só se tudo passar.

## Proibido tocar

`DOCS/`, `briefs/`, `AGENTS.md`, `Definições Oficiais Manuais/`, `scripts/oc-brief.ps1`,
`scripts/consumo.py`, hooks dos repos, qualquer arquivo de projeto. Não fazer `git add -A`.
Não commitar os repos de teste.

## Critério de aceite (o Gerente mede, não o relatório)

1. `bash scripts/testes/test_commit_agent.sh` → **todos PASS**, exit 0, T4 com 40/40.
2. `bash -n scripts/commit-agent.sh` → exit 0; `command -v shellcheck` → se existir,
   `shellcheck` sem erro novo.
3. `scripts/commit-agent-v1.sh` idêntico ao `commit-agent.sh` anterior (diff vazio).
4. O commit desta entrega é feito **pelo v2** e sai com autoria `OPENCODE-WORKSPACE
   <opencode-workspace@2gestor.local>`, contendo **só** os 3 caminhos acima.
5. `git log -1 --stat` mostra exatamente os 3 arquivos do escopo.

## Retorno (contrato)

`RESULTADO / status / arquivos_alterados / comandos_executados / evidencia / nao_testado /
riscos / proximo_passo` — evidência com a saída dos testes, não "funcionou".
