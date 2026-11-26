# Pendentes do Gerente

> Tarefas em voo, para não se perderem quando a sessão quebrar. Atualizado em
> **2026-11-25 23:55**. Marcar ✅ ao fechar, com hash/medição ao lado.

<!-- DIGEST:INICIO -->
| Projeto | Ação manual (só você pode) | Por quê | Onde |
|---|---|---|---|
| **2-Gestor** | Criar PAT fine-grained (Contents: read/write) e colar `GITHUB_PAT=...` no `.env` | commits só no disco; sem isso nada sobe ao GitHub | `C:\MarlonScripts\2-Gestor\.env` |
| **P-03** | Colar a `og:description` da `/chave-na-mao/` no Yoast | O preview do link no WhatsApp/Instagram mostra o texto antigo | wp-admin → página 229 → Yoast |
| **P-03** | Liberar a conta de Google Ads e me passar o `AW-...` | Sem o ID não existe tag de conversão; campanha sem conversão é dinheiro no lixo | conta Ads |
| **P-03** | Levar à cliente as perguntas 21/22 e os dados da T-011 | É conteúdo que só ela sabe; sem isso as páginas ficam sem entrega/prazo/CAU | `QUESTIONARIO-CLIENTE.md` |
| **P-06** | Nada — o bloqueio de download foi contornado e o painel está fechado ponta a ponta | — | — |
<!-- DIGEST:FIM -->

## Em execução agora

| # | Tarefa | Onde | O que se espera |
|---|---|---|---|
| 1 | **M-025** — P-03: T-P03-034…038 (consentimento, hero, SEO, conversão, qlwapp) | `jessica-p03` | por tarefa: execução + medição; as de tema param no `--dry-run` |

## Fechado (medido por mim)

- ✅ **P-06 · M-023/M-024** (`7622ebe`): painel do vigia ponta a ponta — 7 itens medidos,
  390 px sem estouro, alvos ≥44 px, repo limpo. T-P06-009…019 registradas na fila (bloco
  retroativo em `04-TAREFAS.md`).
- ✅ **P-03 · T-P03-033** (`19c84d3`): 1.3.12 no ar; 0 texto antigo nos links das 4 páginas e
  da 404; 2 universais no rodapé + 1 próprio por página.
- ✅ **P-05 · T-P05-009/010/011** (`9dcdbe8`): autostart com repetição por relógio
  (`NextRunTime` preenchido), cota oficial ao vivo (10/21/37%), painel 200 em `127.0.0.1:8787`.
- ✅ **PDF TTS**: auditado e liberado para alunos (avisos: precisa internet, ~27 s até a
  primeira tela, só PDF com texto).
- ✅ **P-06 · T-P06-007** (`79117cc`): histórico real em **0 entradas**, teste em
  `historico-local.json` (1); HTML medido por mim — **390 → 1902 px**, **1280 → 900 px**,
  0 navegadores sobrando.

## Esperando o Marlon

- **PAT** — criar token fine-grained (Contents: read/write em `NMarlon/2-Gestor`) e colar
  `GITHUB_PAT=...` no `.env` do 2-Gestor. O script está pronto: `bash scripts/push.sh`.
- **Q-037** — colar a `og:description` da `/chave-na-mao/` no Yoast (texto em `06-PERGUNTAS.md`).
- **Q-041 / AW-** — localizar o ID da conta de Google Ads.
- **T-011 / Q-036** — dados e respostas da cliente Jéssica (CAU, formato e entrega da
  consultoria, prazos, faixas de orçamento).
- **Q-039** — decidir S4U do coletor do P-05 (só se quiser série sem buraco).
- **Edições dele uncommitted**: `Dos GERENTES.md`, `Principais Regras`, `Específicos/`.

## Fila técnica

- **P-03**: M-025 despachada; o deploy das de tema (1.3.13) é meu ato, depois de medir o dry-run.
- **P-05**: relatório semanal (`T-P05-004` original) no backlog, **não autorizado**; limpar o
  perfil fantasma `p05-painel`; investigar o buraco da série `21:29 → 01:17` (suspeita:
  suspensão da máquina).
- **P-06**: `T-P06-004` (agendador semanal) — a função já é coberta pelo painel vigia
  (`VigiaP06`, frequência no `links.json`); confirmar e marcar como absorvida.
- **Registro**: caderno P-06 com datas `26/11 00:15/00:45` escritas antes da meia-noite
  (relógio real 25/11 23:46) — cosmético, apontado ao gestor.
- **Processo (25/11 23:52):** há uma **segunda sessão do mesmo perfil Gerente** viva
  (commits `9634f2e`/`1fd7f28`, M-026). O commit dela às 23:50 levou junto a minha M-025 —
  nada se perdeu, o rastro ficou misturado. Regra prática enquanto houver duas: `git log -1`
  no arquivo antes de escrever, `commit-agent.sh` por caminho, e não usar `write_file` em
  arquivo compartilhado. Se o Marlon quiser, fechar a sessão antiga resolve na raiz.

## Credencial de push — por que o device flow não serve (registro de 26/11)

Migrado da memória macro para cá. **Sem segredo nesta nota.**

- O `gh auth login` por **device flow** falhou **3 vezes**: o fluxo exige abrir
  `https://github.com/login/device` e digitar um código de 8 caracteres em poucos minutos, e o
  Marlon não recebe o código no app — ele espera notificação que nunca chega. O código expira
  antes.
- **Fallback combinado:** PAT *fine-grained*, escopo só neste repositório, permissão
  `Contents: read and write`, colado em `GITHUB_PAT=` no `.env` do `2-Gestor`. O token em si
  nunca aparece em markdown, commit, print ou chat.
- **Consequência prática:** com `credential.helper=helper-selector` e sem o PAT no `.env`,
  `GIT_TERMINAL_PROMPT=0 git push` falha. Push só sai interativo (Marlon digitando) ou via
  `scripts/push.sh` lendo o PAT.
- Repositórios privados de terceiros (`FileFuse`, `Bot Creator`) seguem ilegíveis a este agente.
