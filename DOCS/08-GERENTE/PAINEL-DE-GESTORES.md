# Painel de gestores — registro e estatística

> Dever do GERENTE (`Definições Oficiais Manuais/Dos GERENTES.md`, itens 2 e 15):
> medir o progresso **individual e geral** dos gestores e manter o registro de
> tarefas do próprio Gerente, para que outro Gerente continue daqui sem
> redescobrir nada. Última medição: **24/11/2026**. Toda linha tem o comando que a
> produziu; número sem comando não entra.

## Quem existe hoje

| Projeto | Gestor (quem decide) | Escritor (quem digita) | Estado medido |
|---|---|---|---|
| P-03 Jessica Haguiwara | este perfil (`manager-developer-hermes`) | OpenCode, sessão do P-03 | 🟢 ativo — 1.3.8 no ar, 4 páginas em rascunho |
| P-04 Portfólio | **sem dono** (`Q-024`) | — | 🟡 construído em 20/11, não publicado |
| P-02 Reconhecedor | **sem dono** (`Q-024`) | — | 🟡 serviço de pé, sem repo em `MarlonScripts/` |
| P-01 Hermes-Mobile | — | — | 🔵 arquivado (API parada em 23/11) |

Consequência prática: **o conjunto tem um gestor ativo e dois projetos órfãos.**
Abrir gestor novo é decisão do Marlon; o Gerente lembra, não abre por conta própria
(`07-GESTORES.md`, "Fim de projeto").

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

- 24/11: política de compactação medida e aplicada em parte (`Q-029`); `consumo.py`
  entregue; E-024 (pendência fantasma do `release.json` corrigida); este painel.
- Aberto comigo: `Q-029` (teto do compressor), `Q-030` (relatório semanal),
  `Q-031` (publicação das páginas — resposta do Marlon libera o gestor do P-03).
- Regra nova em vigor: **Gerente não escreve código de projeto de próprio punho**
  (item 3 do `Dos GERENTES.md`). Script que precisar existir vira brief para o
  OpenCode; o que já existe (`consumo.py`, `commit-agent.sh`, `oc-brief.ps1`) fica
  como está e é mantido por brief.
