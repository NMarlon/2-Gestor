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
| P-03 Jessica Haguiwara | este gestor | 🟢 ativo, prioridade — 1.3.8 no ar |
| P-04 Portfólio | a designar | 🟡 construído, não publicado, sem dono (Q-024) |

*Estados medidos em **2026-11-23**. Detalhe em `02-PROJETOS.md`; medição em
`08-GERENTE/AUDITORIA-2026-11-23.md`.*

Um gestor novo começa lendo, nesta ordem: `../AGENTS.md`, `00-INDICE.md`,
`01-PROTOCOLO.md`, a seção do **seu** projeto em `02-PROJETOS.md`,
`03-ERROS-E-APRENDIZADOS.md`, `04-TAREFAS.md` e `06-PERGUNTAS.md`. Depois cria o
caderno `DOCS/P-<n>-<nome>/GESTOR.md` do projeto dele.

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
