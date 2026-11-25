# 07 — Vários gestores

> Decisão do Marlon em 2026-11-20: o workspace passa a rodar **vários gestores
> Hermes ao mesmo tempo** — um por projeto, todos dentro do `2-Gestor`, todos
> seguindo estas DOCS, cada um briefando o OpenCode para programar.
> Gestores têm a mesma autoridade. O que os separa é o projeto.
>
> **Quem responde pelo conjunto é o GERENTE** — `08-GERENTE/REGRAS.md`. Ele audita,
> prioriza entre projetos, presta contas ao Marlon; não escreve em projeto nem
> publica. Autoridade igual entre gestores; dono do conjunto é um só.

## O modelo em uma frase

**Um projeto, um gestor, um escritor.** O gestor decide e mede; o OpenCode escreve.
Nunca dois gestores no mesmo projeto; nunca dois OpenCode no mesmo repositório.

## Quem é de quem

| Projeto | Gestor | Estado |
|---|---|---|
| P-01 Hermes-Mobile | — (arquivado) | 🔵 em manutenção — API parada em 23/11 |
| P-02 Reconhecedor | a designar | 🟡 serviço de pé, sem dono definido (Q-024) |
| P-03 Jessica Haguiwara | **perfil `p03-jessica`** (criado 24/11 como `p03-gestor`, renomeado 25/11) | 🟢 ativo, prioridade — 1.3.10 no ar, 4 páginas publicadas |
| P-04 Portfólio | a designar | 🟡 construído, não publicado, sem dono (Q-024) |
| P-05 Painel Hermes | **perfil `p05-painel`** (criado 24/11 como `p05-gestor`, renomeado 25/11) | 🟢 ativo — T-P05-001 entregue (coletor), repo `5-Painel-Hermes` existe |

*Estados medidos em **2026-11-24**. Detalhe em `02-PROJETOS.md`; medição em
`08-GERENTE/AUDITORIA-2026-11-23.md`.*

## Gestor é perfil Hermes, não subagente

Cada gestor é um **perfil isolado** (`hermes profile create <nome> --clone`), com
`SOUL.md` próprio definindo o papel, `.env` e `config.yaml` herdados. Roda headless
com `hermes -p <perfil> -z "<ordem>"` a partir do diretório do workspace. Vantagem
sobre subagente: tem sessão, memória e caderno próprios, e continua existindo entre
tarefas. Perfis em uso: `manager-developer-hermes` (Gerente), `p03-jessica` (P-03),
`p05-painel` (P-05).

**Renomeação de 25/11.** `p03-gestor` → `p03-jessica` e `p05-gestor` → `p05-painel`,
feita com `hermes profile rename` (preserva histórico de sessão) e apelidos de linha de
comando criados com `hermes profile alias --name jessica|painel`
(`C:\Users\Marlon\.local\bin\jessica.bat` e `painel.bat`). Briefs e erros anteriores a
essa data citam o nome antigo **de propósito**: são registro do que foi enviado, não se
reescrevem.

Um gestor novo começa lendo a lista do **seu papel** em `../AGENTS.md`, seção
"Mapa por papel". Depois cria o caderno `DOCS/P-<n>-<nome>/GESTOR.md` do projeto dele.

Índice detalhado da documentação, quando precisar: `00-INDICE.md`,
`01-PROTOCOLO.md`, a seção do **seu** projeto em `02-PROJETOS.md`, e
`03-ERROS-E-APRENDIZADOS.md`.

## Regra de ouro contra colisão

O risco real não é git — é **dois gestores reescrevendo o mesmo arquivo ao mesmo
tempo**, e o último apagar o trabalho do primeiro. Então:

1. **Nunca reescrever um arquivo compartilhado inteiro.** Editar por trecho
   (`patch`) ou acrescentar no fim. `write_file` só em arquivo que é seu.
2. **Reabrir antes de gravar.** Arquivo compartilhado pode ter mudado desde a
   última leitura. Se mudou, releia o trecho e reaplique.
3. **Commit pequeno e imediato**, com prefixo do projeto: `P-03: ...`.
4. **Só a própria seção.** Em `02-PROJETOS.md`, cada gestor edita a seção do seu
   projeto e mais nada. Em `06-PERGUNTAS.md`, responde a própria pergunta e
   acrescenta as suas no fim — não reformata o arquivo.
5. **Conflito de interesse vira pergunta.** Se dois projetos precisam da mesma
   mudança em arquivo compartilhado, quem chegou primeiro faz; o segundo registra
   em `06-PERGUNTAS.md` e segue.

## Numeração

- **Tarefa:** `T-P03-016` — prefixo do projeto. O histórico `T-001`…`T-015` fica
  como está, sem renumerar. Isso elimina a colisão que já aconteceu uma vez
  (dois `T-012`, P-02 e P-03).
- **Pergunta:** `Q-0NN` global, ordem de chegada, acrescentada no fim. Se duas
  pessoas usarem o mesmo número, o segundo vira `Q-0NN-b`.
- **Brief:** `briefs/AAAA-MM-DD-pNN-assunto.md`. O nome já separa por projeto.

## O que é de todos e o que é de um

| Recurso | Regra |
|---|---|
| `.env` do `2-Gestor` | único e compartilhado. Nunca duplicar, nunca imprimir, nunca commitar. |
| `scripts/oc-brief.ps1` | canal único gestor → OpenCode. Sempre com `-Dir` do projeto. |
| `briefs/` | histórico comum. Um brief por arquivo, nome com projeto. |
| `Definições Oficiais Manuais/` | somente leitura. Regra permanente só o Marlon muda. |
| Repo do projeto | **um escritor por vez**: o OpenCode do gestor daquele projeto. |
| Medição | cada gestor mede o que publica. Número de outro só se citar a fonte. |

## Deploy

Não muda: deploy é decisão do gestor daquele projeto, com medição antes/depois e
reversão à mão. Brief sempre pede `--dry-run` e para. Nenhum gestor publica no
projeto de outro.

## Fim de projeto

Quando o gestor esgota o que o projeto permite, ele registra o estado em
`02-PROJETOS.md`, fecha as tarefas abertas e avisa o Marlon. Quem abre o próximo
projeto é o Marlon — não o gestor anterior, e não por conta própria.

## Git num workspace compartilhado

**Nunca `git add -A` neste repo.** Outro gestor pode estar com edição em voo no mesmo
diretório, e o `-A` leva o trabalho dele para dentro do seu commit — foi o que
aconteceu no commit `d363607` (varreu `Definições Oficiais Manuais/Dos GERENTES.md`,
que não era meu). Adicione só os caminhos que você escreveu:

```sh
git add DOCS/04-TAREFAS.md DOCS/03-ERROS-E-APRENDIZADOS.md briefs/2026-11-23-p03-*.md
```

Antes de commitar, `git status --short` e conferir se algum arquivo listado não é seu.
Se for de outro gestor, deixe como está: ele commita.

## A camada acima: Gerente

O Marlon definiu em `Definições Oficiais Manuais/Dos GERENTES.md` uma camada **acima**
do gestor. A hierarquia é:

**Gerente** → **Gestor** (Hermes, um por projeto) → **Executor** (OpenCode).

O que muda para o gestor, na prática:

- O Gerente pode **dar ordem direta de execução e de interrupção** ao gestor. Ordem de
  Gerente não se discute com o Marlon; executa-se, e se houver risco, o gestor diz o
  risco ao Gerente antes.
- O Gerente pode pedir ao gestor que um projeto fique mais otimizado, mais seguro, mais
  correto. Isso é prioridade de trabalho, não sugestão.
- Decisão de projeto continua com o gestor — mas **sempre** com prós e contras
  investigados, e pesquisando o método conhecido antes de inventar. "Achei melhor
  assim" não é justificativa.
- Todo mundo — Gerente, Gestor, Executor — é responsável por manter a própria
  documentação atualizada e organizada. O motivo é explícito na regra: o próximo a
  continuar o projeto não pode queimar tokens redescobrindo o que já se sabia.

### O que o Gerente deve ao conjunto (itens 2, 3, 6, 8, 15, 16)

- **Estatística, não impressão.** O Gerente publica progresso medido — por gestor e
  no total — em `08-GERENTE/PAINEL-DE-GESTORES.md`. Commits, entregas aceitas,
  compactações por sessão, tokens por entrega. Sem comando registrado, não entra.
- **Gerente não digita código de projeto.** Ele administra e manda o OpenCode
  executar. Ferramenta que faltar vira brief, não script escrito à mão pelo Gerente.
- **GitHub do workspace atualizado.** Commits frequentes e `push` para
  `origin/master` deste repo (só deste), depois de conferir o diff.
- **Opinião é parte do trabalho.** O Gerente diz onde o projeto pode ficar mais
  otimizado, mais seguro, mais correto, com menos bug — e sustenta com pesquisa
  antes de executar (item 9 e 13).
- **Registro de tarefas do Gerente.** Se o Gerente parar no meio, o próximo lê o
  painel e continua. É o mesmo dever de documentação viva, aplicado à gerência.
- **Sessão por tarefa.** Gestor guarda contexto da tarefa que estava fazendo; tarefa
  nova pede sessão nova (e leitura do repo antes de agir). Terminada a tarefa
  inteira, o mesmo gestor pode seguir no projeto. Decisão de abrir ou não sessão é
  do Gerente, olhando custo e continuidade — não é automática.

