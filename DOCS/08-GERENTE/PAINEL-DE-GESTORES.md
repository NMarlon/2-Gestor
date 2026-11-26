# Painel de gestores — registro e estatística

> Dever do GERENTE (`Definições Oficiais Manuais/Dos GERENTES.md`, itens 2 e 15):
> medir o progresso **individual e geral** dos gestores e manter o registro de
> tarefas do próprio Gerente, para que outro Gerente continue daqui sem
> redescobrir nada. Fila de pedidos do Marlon: `LISTA-DE-PEDIDOS.md` (ao lado).
> Última medição: **25/11/2026, 23:50**. Toda linha tem o comando que a
> produziu; número sem comando não entra.

## Quem existe hoje

| Projeto | Gestor (quem decide) | Escritor (quem digita) | Estado medido (25/11 23:50) |
|---|---|---|---|
| P-03 Jessica Haguiwara | **perfil `jessica-p03`** | OpenCode, sessão do P-03 | 🟢 ativo — **1.3.12** no ar (style.css servido, `Version: 1.3.12`), 404 personalizada e WhatsApp por página medidos; parado em M-018/M-022 desde 15h |
| P-05 Painel Hermes | **perfil `painel-p05`** | OpenCode, sessão do P-05 | 🟢 ativo — painel `http://127.0.0.1:8787` **200**, autostart com repetição por relógio, cota oficial ao vivo |
| P-06 CTM | **perfil `ctm-p06`** | OpenCode, sessão do P-06 | 🟢 ativo — repo `7622ebe` limpo; painel do vigia (`127.0.0.1:8788`) fechado ponta a ponta |
| P-04 Portfólio | **sem dono** (`Q-024`) | — | ⛔ congelado por decisão do Marlon (24/11); repo parado em `047be25`, sem remote |
| P-02 Reconhecedor | **sem dono** (`Q-024`) | — | ⛔ congelado por decisão do Marlon (24/11) |
| P-01 Hermes-Mobile | — | — | 🔵 arquivado |

Consequência prática: **três projetos com gestor próprio e dois órfãos congelados.** Abrir
gestor novo é decisão do Marlon; o Gerente lembra, não abre por conta própria
(`07-GESTORES.md`, "Fim de projeto").

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
| P-03 Jessica | **45** | `19c84d3` 25/11 — release 1.3.12 | ritmo alto; entrega publicada e medida |
| P-05 Painel Hermes | **13** | `9dcdbe8` 25/11 — repetição do autostart | painel no ar com autostart provado |
| P-06 CTM | **18** | `7622ebe` 25/11 — T-P06-019 | painel do vigia ponta a ponta |
| P-04 Portfólio | **4** | `047be25` 20/11 | parado (congelado por decisão do Marlon) |
| 2-Gestor (workspace) | **143** | ver `git log` | documentação em movimento |

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

**Atualizado: 2026-11-25, 23:55** (medição: `date`; `git log -1` nos quatro repos;
`curl` no site e no painel).

- **Estado medido hoje 23:45–23:50:** P-03 no ar em **1.3.12** (`style.css` servido,
  `Version: 1.3.12`; home `200`); P-05 `127.0.0.1:8787` **200**, tarefas
  `PainelHermes-Coletor` e `PainelHermes-Painel` *Pronto*; P-06 `7622ebe`, árvore limpa;
  P-04 parado em `047be25`; workspace com 3 arquivos do Marlon pendentes
  (`Dos GERENTES.md`, `Principais Regras`, `Específicos/` — não são meus, não comito).
- **Aberto comigo:** M-025 despachada ao `jessica-p03` (T-P03-034…038); o deploy das de
  tema (1.3.13) é meu ato depois de medir o dry-run.
- **Corrigido nesta sessão:** fila `04-TAREFAS.md` ganhou o registro retroativo
  T-P06-009…019 (estava só no caderno do gestor) e os blocos T-P03-034…038; as ordens
  M-023/M-024, que só existiam no caderno do P-06, foram registradas no canal
  (`PARA-GESTORES.md`) — com a regra de que ordem passa pelo arquivo antes do despacho.
- **Não começou:** nada aberto no P-05; relatório semanal segue no backlog, não autorizado.
  `T-P06-004` (agendador semanal) parece absorvida pelo painel vigia — confirmar.
- Regra em vigor: **Gerente não escreve código de projeto de próprio punho** (item 3 do
  `Dos GERENTES.md`). Script que precisar existir vira brief para o OpenCode.
- Regras novas do Marlon (itens 17-22 do `Dos GERENTES.md`, 24/11): entregar resumo do que
  foi feito, manter a doc própria atualizada, registrar todo erro, **plano antes de
  executar**, e **delegar a execução ao gestor** em vez de executar com as próprias mãos.

## Roteamento — perfil, repositório e como abrir sessão

Migrado da memória do Gerente em 26/11 (regra do Marlon: nada de projeto específico na memória).

| Projeto | Perfil Hermes | Repositório |
|---|---|---|
| P-03 Jessica Haguiwara | `jessica-p03` | `C:\MarlonScripts\Jessica Haguiwara` |
| P-04 Portfólio | — (sem gestor) | `C:\MarlonScripts\4-Portfolio` |
| P-05 Painel Hermes | `painel-p05` | `C:\MarlonScripts\5-Painel-Hermes` |
| P-06 Alerta CTM | `ctm-p06` | `C:\MarlonScripts\81 - Alerta Planejamento Missionario CTM` |
| PDF TTS (Pathway) | `pdf-tts` | `C:\MarlonScripts\1-Mini-Projetos\PDF TTS` |

- Abrir sessão de gestor: `hermes -p <perfil> -z "<ordem>"`. Wrappers em
  `C:\Users\Marlon\.local\bin`.
- Briefs antigos citam `p03-gestor` / `p05-gestor` de propósito: são os nomes velhos.
- Nome do perfil começa pelo projeto porque o ícone do Hermes usa a primeira letra.

## Estado macro por projeto (26/11)

| Projeto | Estado |
|---|---|
| P-03 | no ar, tema **1.3.12**; pendências: mensagem do plugin qlwapp e `AW-` do Google Ads (Marlon) |
| P-04 | congelado por decisão do Marlon; repo sem remote |
| P-05 | painel local em uso; cota oficial ao vivo |
| P-06 | funcional ponta a ponta (leitura sem baixar, grade, bordas, diff, painel, agendador) |
| PDF TTS | auditado e liberado para alunos; avisos: precisa internet, ~27 s até a primeira tela, só PDF com texto |
