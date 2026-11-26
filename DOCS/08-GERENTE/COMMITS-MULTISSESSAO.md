# Commits com múltiplas sessões — diagnóstico, prova e solução

> Decisão do Marlon (26/11 00:00): **multi-sessão fica**. Duas ou mais sessões do mesmo
> perfil devem poder commitar em paralelo, cada uma levando **somente os seus arquivos**.
> Nenhuma sessão para por causa de commit. Este documento registra a causa medida, as
> opções pesquisadas e a recomendação. Autor: GERENTE.

## 1. O que aconteceu (fato medido)

Em 25/11, duas sessões do perfil `manager-developer-hermes` estavam vivas no mesmo
checkout `C:\MarlonScripts\2-Gestor`:

- 23:48 — sessão B (esta) escreveu a seção **M-025** em `DOCS/08-GERENTE/PARA-GESTORES.md`.
- 23:50 — sessão A commitou o mesmo arquivo com a **M-026** (`1fd7f28`). O commit levou
  junto a M-025 — não por `git add -A`, mas porque **o arquivo físico já continha as duas
  seções**.
- 23:52 — a sessão B tentou commitar o mesmo arquivo e não havia o que commitar: o texto
  dela já estava no commit de A.

Nada se perdeu; o rastro ficou errado. É o caso "mesmo arquivo, duas sessões" — o mais
difícil. O caso "arquivos diferentes, duas sessões" é mais comum e também foi reproduzido.

## 2. A causa, em três camadas

| Camada | O que é compartilhado | Efeito |
|---|---|---|
| **Índice** (`.git/index`) | O stage é um só para o repositório | `git add` de uma sessão fica visível para a outra; um `git commit` sem pathspec leva o stage inteiro |
| **HEAD e refs** | Um HEAD por checkout | dois `git commit` simultâneos disputam `index.lock`; o perdedor falha, não espera |
| **Working tree** | Os mesmos arquivos em disco | duas sessões escrevendo no mesmo arquivo: o último sobrescreve; o commit leva o arquivo como está, com os trechos de ambas |

A documentação do git confirma: `git commit -- <path>` **não** commita o que está staged
para aquele path — commita o **conteúdo atual do working tree**. Em checkout
compartilhado, isso pode levar WIP de outra sessão (ver §4).

## 3. O que a pesquisa encontrou

| Fonte | Mecanismo | Leitura |
|---|---|---|
| `safegit` (stricttools) | índice temporário por invocação + lock por ref + **CAS retry** (re-parenta se o topo andou) | é exatamente o padrão que os testes §4 validam |
| `git-commit-lock` (bentoner) | mutex de estágio+commit com `O_CREAT\|O_EXCL` (funciona em NTFS), lease roubável, hunk curado para arquivo compartilhado | lock + paths nomeados; **não** isola edição |
| SwarmOps / Offrun / Traycer / Claude Code | **um worktree + uma branch por agente**, merge depois | isola working tree, index e HEAD; conflito aparece no merge |
| "Single-committer" | agentes só escrevem; um processo único commita | à prova de corrida, mas exige um daemon |
| Git docs / achado de campo | `git commit -- path` usa o working tree, não o index | é a pegadinha que faz "commit por arquivo" levar WIP alheio |

Links principais: `github.com/stricttools/safegit`, `github.com/bentoner/git-commit-lock`,
`swarmops.cc/docs/guides/parallel-agents`, `code.claude.com/docs/en/worktrees`,
`git-scm.com/docs/git-commit`.

## 4. O que foi provado nesta máquina (25/11 23:58–00:02)

Repositórios descartáveis em `%TEMP%`, git 2.x Windows, mesmos comandos que o workspace usa.

| Teste | Cenário | Resultado medido |
|---|---|---|
| **T1** | duas sessões, `git add` de arquivos diferentes, commit sem pathspec | commit de B levou **`a.md` + `b.md`** — o multicommit clássico |
| **T2** | `git commit -m ... -- b.md` com `a.md` staged por outra sessão | commitou **só `b.md`**; `a.md` continuou staged, intacto |
| **T3** | **índice temporário** (`GIT_INDEX_FILE`) + `read-tree HEAD` + `add -- b.md` + `commit-tree` + `update-ref` | commit com **só `b.md`**; índice da sessão A **intacto** com `a.md` staged |
| **T4** | **2 sessões × 20 commits cada, concorrentes**, com CAS+retry | **40/40 commits**, **0 misturados**, **0 falhas** |
| **T5** | worktree por sessão (branch `sessao-A`, `sessao-B`) | commits independentes; master intacto; merges limpos (fast-forward + ort) |
| **T6** | lock `mkdir` (O_EXCL) com 4 concorrentes | serializou em **53–230 ms**, sem deadlock |
| **T7a** | duas sessões escrevendo no **mesmo arquivo**, índice temporário | **não separa**: o commit de B levou as duas seções |
| **T7b** | separar hunks do mesmo arquivo com patch curado | **frágil**: o patch falhou por contexto/CRLF; não é caminho de produção |
| **T7c** | **um arquivo por sessão** | commits limpos, zero conflito — cada um com o seu arquivo |

Conclusão da prova: **arquivos diferentes são 100% separáveis com índice temporário + CAS**;
**o mesmo arquivo não é separável** — só um arquivo por sessão (ou patch curado, que não
recomendo).

## 5. Solução recomendada — em três camadas

### A. `commit-agent.sh` v2 — o que faz (obrigatório)

Mantém a interface atual (`scripts/commit-agent.sh NOME -m "msg" -- caminhos`) e troca o
miolo:

1. **Lock de commit** `.git/agent-commit.lock` criado com `mkdir` (atômico em NTFS), retry
   com jitter, lease de ~30 s (lock órfão é roubado; nada trava para sempre).
2. **Índice temporário** `GIT_INDEX_FILE=.git/index.agent-<token>`, semeado com
   `git read-tree HEAD` — **nunca toca o index compartilhado**.
3. `git add -- <caminhos>` somente no índice temporário.
4. `git write-tree` → `git commit-tree -p <HEAD lido>` → `git update-ref refs/heads/<branch>
   <novo> <HEAD lido>` — **CAS**: se outra sessão commitou no meio, o update falha e a
   operação **refaz** em cima do novo topo (até N tentativas). Nenhuma sessão para.
5. Confere que cada caminho nomeado realmente mudou (avisa e sai 0 se não há nada).
6. Identidade do agente, como hoje. `SEM_ADD` continua funcionando.
7. **Nunca** `git add -A`, `git commit -a`, `git stash` — a guarda atual vira redundância.

Isso elimina de uma vez: multicommit de **arquivos** alheios, falha por `index.lock`, e
commit perdido quando duas sessões commitam no mesmo segundo.

### B. Partição de arquivos — a regra que resolve o mesmo arquivo (obrigatório)

O v2 garante "só os meus arquivos", **mas não separa duas seções no mesmo arquivo** (T7a).
Então:

- **Escrita livre por sessão** vai para `DOCS/08-GERENTE/sessoes/<AAAA-MM-DD-HHMM>-<token>.md`
  (ou diretório do projeto), nunca para arquivo que outra sessão também escreve.
- **Arquivos canônicos** (canal `PARA-GESTORES.md`, fila `04-TAREFAS.md`, `PENDENTES.md`,
  `PAINEL-DE-GESTORES.md`): cada sessão **só faz append do seu bloco** e commita em seguida.
  Se duas escreverem no mesmo arquivo na mesma janela, **a mistura é aceita** (decisão do
  Marlon: melhor misturar que perder a sessão) — o que o v2 impede é levar arquivo que a
  sessão não nomeou.
- Fase 2, se o Marlon quiser zero mistura: o canal passa a ser um diretório com **um arquivo
  por mensagem** (`DOCS/08-GERENTE/canal/M-025-<token>.md`) e um índice gerado. A leitura
  continua sendo "o canal", mas cada sessão cria o seu arquivo — e o v2 commita só ele.

### C. Worktree por sessão — opcional, para sessões longas (recomendado se doer de novo)

`git worktree add ../2-Gestor-<sessao> -b sessao/<token>` dá à sessão um diretório, um
índice e um HEAD próprios. Zero corrida por construção. O custo: abrir a sessão **naquele
diretório** e fazer merge das branches no fim (`scripts/merge-sessao.sh`). Para o volume de
docs do Gerente, A+B bastam; worktree é o seguro para sessões de projeto que ficam horas.

## 6. O que **não** resolve (para não vender ilusão)

- `git commit -- path` sozinho: resolve arquivos distintos, mas lê o **working tree** — se o
  arquivo tem WIP de outra sessão, leva junto (T2 + documentação).
- `git add` por sessão sem índice temporário: a outra sessão ainda pode commitar o stage
  compartilhado.
- Patch curado por hunk no mesmo arquivo: funciona em teoria, falhou na prática no teste
  (contexto/CRLF) e transforma cada commit em cirurgia. Não recomendo.
- Proibir `git add -A`: necessário, mas insuficiente — o incidente de hoje passou com
  caminho explícito, porque o arquivo era o mesmo.

## 7. Decisão e próximos passos

**Recomendação: A + B.** O v2 é implementado por brief ao OpenCode (o Gerente não escreve
script de próprio punho), testado em repositório descartável com os casos T2–T7, e só então
vira o padrão. A regra B entra em `AGENTS.md` e `REGRAS.md` — e **só com o "pode" do
Marlon**, porque é edição de arquivo de instrução.

- Brief: `briefs/2026-11-26-commit-agent-v2-multissessao.md`.
- Aceite: T4 (40/40), T3 (índice da outra sessão intacto), T6 (lock), T7a documentado como
  limite, e o script antigo preservado como `commit-agent-v1.sh` (rollback de um `mv`).
- Worktree (C) fica como ferramenta disponível, não como obrigação.

### Aceite final — 26/11 00:50 (medido pelo Gerente)

**v2.1 aceito.** Suíte inteira rodada de novo na fonte: **12 PASS, 0 FAIL**, exit 0.

| Prova | Resultado |
|---|---|
| T4 concorrência | **40/40 commits, 0 misturados, 0 falhas** |
| T6 lock | 4 commits concorrentes em **6.881 ms** (teto 15 s; carga de dois executores) |
| T3 stage alheio | intacto depois do commit da outra sessão |
| T7a mesmo arquivo | mistura avisada — limite conhecido, aceito pelo Marlon |
| `integer expected` | **0 ocorrências** (bug de portabilidade do `stat` corrigido com `date -r` + validação numérica) |
| Commit da entrega | `6f93b6b`, `OPENCODE-WORKSPACE`, 2 arquivos |
| Uso real | `9e31611` (GERENTE, 2 docs) e este registro, ambos pelo v2 |

**Duas decisões de implementação, registradas:**
1. O v2 **atualiza o índice compartilhado** depois do `update-ref`, só para os caminhos que
   ele mesmo commitou — `read-tree` quando o índice está limpo; com stage alheio, mexe apenas
   nos caminhos nomeados. Sem isso, o stage de outra sessão ficaria apontando para o HEAD
   antigo (arquivo commitado apareceria "staged ao contrário"). Nenhum arquivo de outra sessão
   entra no commit.
2. O T6 passou a medir **serialização, não carga da máquina**: teto de 15 s, com o tempo
   impresso em cada execução.

**O que continua valendo:** partição de arquivos (B) é a única coisa que resolve duas sessões
no mesmo arquivo. A regra em `AGENTS.md` depende do "pode" do Marlon (`Q-042`); até lá, vale
como recomendação e prática do Gerente. Worktree (C) segue documentado (`Q-043`).
