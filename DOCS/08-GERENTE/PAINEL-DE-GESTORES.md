# Painel de gestores — registro e estatística

> Dever do GERENTE (`Definições Oficiais Manuais/Dos GERENTES.md`, itens 2 e 15):
> medir o progresso **individual e geral** dos gestores e manter o registro de
> tarefas do próprio Gerente, para que outro Gerente continue daqui sem
> redescobrir nada. Fila de pedidos do Marlon: `LISTA-DE-PEDIDOS.md` (ao lado).
> Última medição: **24/11/2026**. Toda linha tem o comando que a
> produziu; número sem comando não entra.

## Quem existe hoje

| Projeto | Gestor (quem decide) | Escritor (quem digita) | Estado medido |
|---|---|---|---|
| P-03 Jessica Haguiwara | **perfil `p03-gestor`** | OpenCode, sessão do P-03 | 🟢 ativo — 1.3.9 no ar, 4 páginas publicadas e verificadas |
| P-05 Painel Hermes | **perfil `p05-gestor`** (criado 24/11; papel aguardando aprovação do Marlon) | — (nada iniciado) | ⚪ aprovado, pasta `5-Painel-Hermes` ainda não existe |
| P-04 Portfólio | **sem dono** (`Q-024`) | — | 🟡 construído em 20/11, não publicado |
| P-02 Reconhecedor | **sem dono** (`Q-024`) | — | 🟡 serviço de pé, sem repo em `MarlonScripts/` |
| P-01 Hermes-Mobile | — | — | 🔵 arquivado (API parada em 23/11) |

Consequência prática: **dois projetos com gestor próprio (P-03 ativo, P-05 parado),
dois órfãos (P-02, P-04).** Abrir gestor novo é decisão do Marlon; o Gerente lembra,
não abre por conta própria (`07-GESTORES.md`, "Fim de projeto").

## Primeira tarefa do gestor de P-03 — o que ele entregou

Comando de leitura: `git log --oneline -3` no 2-Gestor; commits `ef2e0b6` e
`73a2b29`, ambos de `GESTOR-P03`, 24/11.

| O que medi no gestor | Resultado |
|---|---|
| Mediu na fonte pública ou repetiu o relatório do executor? | Na fonte: UA Chrome/131, URL sem query, **duas leituras por URL**, md5 por página |
| Números com rastro | `/` 181.139 B md5 `8f73a2c0…`; 4 páginas 149.338 / 149.167 / 149.132 / 149.054 B; `page-id` 226–229; 157–177 palavras no `<main>` |
| Distinguiu falha de ressalva | Sim — separou "023 não entrou" (falha) de "rótulo no singular" (copy) |
| Achou o que não sabia e disse | Sim — um **commit de correção próprio** (`73a2b29`) ao perceber que não provou onde o submenu vive; rollback do tema pode **não** desfazer o menu |
| Escreveu fora do escopo? | Não — `AGENTS.md` intocado, nenhum caderno de P-02/P-04, nada no repo do projeto, nenhum deploy |
| Respeitou o gate de aprovação? | Sim — parou a 023 (botão do banner de cookies) esperando `Q-032` |

Nota de leitura: o valor desse gestor não foi achar que estava tudo bem, foi
**entregar o próprio erro no segundo commit**. É o comportamento que o painel mede.

## Progresso por projeto

Comando: `git -C "C:/MarlonScripts/<repo>" log --since=7.days --oneline | wc -l`
e `git -C <repo> log -1 --format="%h %ad %s" --date=short`.

| Projeto | Commits 7 dias | Último commit | O que prova |
|---|---|---|---|
| P-03 Jessica | **45** | `ed5990a` 23/11 — WebP na home | ritmo alto; entrega publicada 1.3.8 |
| P-04 Portfólio | **4** | `047be25` 20/11 — idiomas do autor | parado há 4 dias, sem publicação |
| 2-Gestor (workspace) | ver `git log` | `14d9d77` 24/11 — brief T-P03-023 | documentação em movimento |

## Consumo por projeto — 30 dias

Comando: `python scripts/consumo.py --dias 30` (somente leitura, `ro` em
`state.db` e `opencode.db`; US$ só existe onde o provedor cobra).

| Projeto | Sessões | Entrada | Saída | Cache lido | Compactações | US$ |
|---|---|---|---|---|---|---|
| 2-Gestor (sala de gerência) | 293 | 15,31 M | 952,0 k | 67,50 M | **84** | 0 |
| Jessica Haguiwara | 21 | 7,17 M | 825,4 k | 688,10 M | 4 | 0,551 |
| 4-Portfolio | 4 | 273,2 k | 68,8 k | 8,15 M | 0 | 0 |
| Reconhecedor | 7 | 1,15 M | 193,4 k | 43,38 M | 0 | 0 |
| Mini-Projetos (fora do escopo) | 5 | 14,20 M | 690,7 k | 472,15 M | 1 | 0 |
| Terabox (fora do escopo) | 1 | 5,08 M | 620,4 k | 276,79 M | **14** | 1,227 |

Leitura: a sala de gerência consome **4× mais tokens que o projeto que ela
administra** e compacta a cada 3,5 sessões. É o custo de coordenação — mas é o
lugar onde a política de `COMPACTACAO.md` tem que pegar primeiro.

## Métricas que importam (e as que enganam)

| Métrica | Como se mede | Por que |
|---|---|---|
| Entrega aceita / tarefa aberta | `grep -c "^## T-" DOCS/04-TAREFAS.md` contra entregas medidas | É o que o cliente paga |
| Compactações por sessão | `consumo.py` → coluna `compact` ÷ `sess` | Acima de ~0,3 é sintoma de sessão longa demais |
| Commits por dia útil | `git log --since` | Ritmo real, não relatório |
| Tokens por entrega | `in` do projeto ÷ entregas aceitas | Custo unitário; amostra pequena, use tendência |

Não usar como nota: número de mensagens, tamanho de documento, "esforço".
Nenhum deles sobrevive à pergunta "o que foi publicado".

## Fila de ordens do Gerente aos gestores

| Ordem | Para | Estado |
|---|---|---|
| Publicar as 4 páginas de serviço + submenu (T-P03-022) | gestor P-03 | **parada**: espera `Q-031` (aprovação do Marlon) |
| Paleta do banner de cookies (T-P03-023) | gestor P-03 | brief emitido 24/11 |
| Medir peso da home depois do WebP | gestor P-03 | pendente |
| Assumir P-04 e publicar | gestor a designar | **parada**: `Q-024` |

## Canal Gerente ↔ gestor — o que está medido (24/11)

- Perfis Hermes instalados: **dois** — `manager-developer-hermes` (este, ativo) e
  `matematico` (último uso 23/11 16:36). **Não existe perfil por projeto.**
- `PARA-GESTORES.md`: **3 mensagens** (M-001, M-002, M-003) e **0 acks** registrados.
- Leitura honesta: o canal é **caixa de saída**. Funciona como continuidade
  documental entre sessões do mesmo agente, não como diálogo entre dois agentes
  vivos. Isso basta enquanto houver um gestor ativo e é frágil no dia em que houver
  três — porque nada obriga um gestor a abrir o canal, além da regra escrita.
- Corrigido hoje: ack explícito saiu (custa token e não informa), escalonamento é a
  única mensagem de volta, contrato de retorno fixo, limite de 3 turnos, e o canal
  entrou na ordem de leitura obrigatória do `AGENTS.md`.
- Base da revisão: handoff como **contrato de dados** (AWS Agentic AI Lens,
  AGENTOPS01-BP02); arquivos em vez de chat, com custo O(brief) e não O(histórico)
  (protocolo `TASK.md`/`SESSION.md`); "silence = success", escalonamento separado de
  decisão e limite de 3 turnos (OpenSpawn); subagente devolve referência ao artefato,
  não o artefato dentro do contexto, para evitar "telefone sem fio" (Anthropic,
  multi-agent research system).

## Registro do próprio Gerente — onde parei

**Atualizado: 2026-11-24, 21:10.**

- **P-03 entregue e medido no ar** — 1.3.9, 4 páginas de serviço `200`, submenu
  SOLUÇÕES com 4 filhos, 4 cartões da home ligados. `T-P03-024` fechada pelo
  `p03-gestor`, com bloco de verificação em `04-TAREFAS.md`.
- **Fechado hoje:** `Q-031` (publicação das páginas), `Q-030` (relatório vira
  script, sem cron), `T-P03-022` (marcada como feita na prática), `backups/` no
  `.gitignore`. Item 17 da lista do Marlon respondido: era minha proposta de
  enxugar o `AGENTS.md`; hoje se contradiz — recomendo riscar.
- **Aberto comigo:** `Q-032` (cor do botão do banner — espera "pode"), `Q-034`
  (credencial do GitHub: commits locais sem push), `Q-035` (rótulo
  "Projeto"/"Projetos" — default: não mexer), e a prova de onde vivem os 4 itens
  do submenu (tema × `wp_navigation`), que decide se o rollback de tema basta.
- **Não começou:** **P-05 Painel Hermes** — pasta `C:\MarlonScripts\5-Painel-Hermes`
  inexistente, sem repo, sem doc pelo padrão de projeto novo, sem coletor de cota,
  sem UI. O papel do `p05-gestor` está escrito (81 linhas) e aguarda aprovação.
- **Também pendente:** revisão editorial das 4 páginas com antes/depois (`Q-033`).
- Regra em vigor: **Gerente não escreve código de projeto de próprio punho**
  (item 3 do `Dos GERENTES.md`). Script que precisar existir vira brief para o
  OpenCode; `consumo.py`, `commit-agent.sh` e `oc-brief.ps1` ficam como estão e
  são mantidos por brief.
- Regras novas do Marlon (itens 17-22 do `Dos GERENTES.md`, 24/11): entregar
  resumo do que foi feito, manter a doc própria atualizada, registrar todo erro,
  **plano antes de executar**, e **delegar a execução ao gestor** em vez de
  executar com as próprias mãos.
