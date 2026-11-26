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
| **P-03** | Logar no wp-admin (perfil Edge `wp-admin-profile`) e habilitar **Yoast SEO** em `Easy MCP AI → Tools → Plugins` | Sem isso o MCP recusa as 8 metas (`ignored_keys`); o gestor não pode fazer login | brief `2026-11-26-p03-t036b-yoast.md` |
| **P-03** | Aprovar o deploy do tema **1.3.13** (hero + consentimento + conversão) depois da T-P03-039 | É mudança visível: imagem do hero, banner de cookies e redirect do formulário | `Q-044`, prints às 06:30 |
| **P-06** | Nada — o bloqueio de download foi contornado e o painel está fechado ponta a ponta | — | — |
<!-- DIGEST:FIM -->

## Em execução agora

| # | Tarefa | Onde | O que se espera |
|---|---|---|---|
| 1 | **P-03 · tema 1.3.13** — pacote pronto (11 arquivos), `--dry-run` limpo, sha256 dos AVIF igual local × servidor | fila | **aguardando `Q-044`** (aprovação do Marlon) para o deploy medido |
| 2 | **P-03 · T-P03-036b** — Yoast | `wp-admin` | **aguardando o Marlon logar** no perfil Edge e habilitar a integração |

## Pacote de deploy — P-03 tema 1.3.13 (pronto, aguardando `Q-044`)

**Estado:** implementado e medido, não publicado. Commits do site: `eec91a3` (037),
`0b6bb24` (034), `cb90b6c` (035), `8683b4b` (039, ferramenta). `release.json` já em 1.3.13.

**Antes:** backup do tema no ar (1.3.12) — `functions.php` 10.114 B e `style.css` 54.419 B
servidos; guardar os 2 arquivos e a lista dos 9 novos.

**Deploy (só com o "pode"):**
1. `node scripts/deploy-theme.mjs` (sem `--dry-run`) — esperar **`11 iguais, 0 divergente,
   0 novo, 0 orfao`**.
2. Purge do WPFC; medir o HTML servido em duas leituras: home (`<picture class="jhw-hero__bg">`,
   AVIF 200, `fetchpriority="high"`, preload), 404, `/obrigado/`, banner de consentimento.
3. Prova de comportamento: cookies `_ga`/`__hstc` **ausentes** antes do aceite; depois do
   aceite, `generate_lead` no GA4 e redirect do form 168. Só existe pós-deploy.
4. **Rollback:** reenviar `functions.php` e `style.css` 1.3.12 (backup acima), remover os 9
   novos e purgar o cache; aí medir de novo e registrar.

**Riscos aceitos:** `functions.php` dobra de tamanho (10.114 → 19.525 B) no HTML? Não — é
arquivo; o impacto é o preload condicional na home. O preload é incondicional: num deploy
parcial (PHP sem as imagens) geraria 404; por isso o deploy é dos 11 de uma vez.

## Fechado (medido por mim)

- ✅ **P-03 · T-P03-039** (`8683b4b`): deploy binário por multipart; teste reexecutado por mim —
  AVIF 22.595 B, sha256 local = servidor `105454c1…`, limpeza OK, 404. `BINARIOS` com `.avif`.
  Causa raiz do E-042: não era a API mentindo, era GET com o arquivo na query.
- ✅ **commit-agent v2.1** (`6f93b6b`): suíte **12/12**, T4 40/40 sem mistura, T6 6.881 ms
  (teto 15 s), `integer expected` zero. Uso real comprovado em `9e31611` e no commit do
  aceite. Documento: `08-GERENTE/COMMITS-MULTISSESSAO.md`. `v1` preservado para rollback.

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
