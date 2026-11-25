# 02 — Registro de projetos

> Estado **verificado** em 2026-11-20 pelo gestor. Cada linha carrega evidência.
> Fonte de escopo: `../PROJETOS_APROVADOS.md`.

---

## P-01 · Hermes-Mobile

> **Medição do GERENTE · 2026-11-23:** `curl http://127.0.0.1/api/status` **não
> respondeu**. O bloco abaixo é o registro de 2026-11-20, quando a API respondia
> `200`. Estado real: arquivado, API parada. Reabrir só a pedido do Marlon.


| Campo | Valor |
|---|---|
| Caminho | `C:\MarlonScripts\1-Mini-Projetos\Hermes-Mobile` |
| Repo | `C:\MarlonScripts\1-Mini-Projetos` (pasta filha; não tem `.git` próprio) |
| Objetivo do Marlon | Usar o Hermes do PC no celular (Pomelu / Mono Hermes) via Tailscale |
| Estado | 🔵 **Encerrado, em manutenção** (arquivado por decisão do Marlon em 2026-11-20) |
| Foco | Fora da fila ativa. Só volta se quebrar ou se o Marlon pedir. Backlog: aviso de versão do Mono Hermes e plugin de push. |
| Documentação | Completa: `DOCS/00` a `DOCS/13` |

**Evidência coletada (2026-11-20):**

- `curl http://127.0.0.1/api/status` → `200`, `version: 0.23.2`,
  `gateway_running: true`, `auth_required` presente.
- `tailscale serve status` → `443 → 127.0.0.1:28894` (OpenCode),
  `8443 → 127.0.0.1:80` (Hermes), `8444 → 127.0.0.1:9120` (Webapp). Os três ativos.
- `git status` em `Hermes-Mobile/` → limpo.

**Pendências reais:** só backlog e upstream — aviso de versão do Mono Hermes
(0.22 × 0.23.x) e plugin de push. Nada bloqueante.

**Doc sincronizada (2026-11-20):** o OpenCode corrigiu a deriva em 14 arquivos
`.md` (versão 0.23.1 → 0.23.2, Fase 2 concluída com evidência, Fase 5 parkeada).
Commit `79013d5`. Verificação independente depois do commit:
`https://<tailnet>:8443/api/status` → `200`, `version: 0.23.2`.

---

## P-02 · Reconhecedor de Rostos de Imagens

> **Medição do GERENTE · 2026-11-23:** o serviço está **de pé** em `:8011`
> (`openapi.json` responde, título "Reconhecedor de Rostos", versão 0.1.0); commits
> novos até `1681d3b` (22/11); `.scan_pass2_done` não rastreado na árvore. **Não
> medido:** jobs em execução e fila. O `07-GESTORES.md` dizia "pausado"; este bloco
> diz "varredura em andamento". Sem dono definido (`Q-024`), vale o mais
> conservador: **nenhuma tarefa nova** aqui.


| Campo | Valor |
|---|---|
| Caminho | `C:\MarlonScripts\1-Mini-Projetos\Reconhecedor de Rostos de  Imagens` (dois espaços antes de "Imagens") |
| Repo | Próprio (`git` aninhado; aparece como `??` no repo pai) |
| Objetivo do Marlon | (1) reconhecer/distinguir rostos em dezenas de milhares de imagens; (2) lista QUEM ↔ CADA foto; (3) visual para clicar num rosto e ver todas as fotos daquela pessoa |
| Estado | 🟡 **Rodando com acervo real** — varredura completa em andamento |
| Stack | Python 3.11, FastAPI, InsightFace `buffalo_l` (CPU), SQLAlchemy 2.1.8, SQLite |

**Evidência coletada (2026-11-20):**

- API sobe em `127.0.0.1:8011`; `/api/stats`, `/api/people`, `/api/cluster`,
  `/api/export/people`, `/api/scan/status` respondem `200`.
- Acervo real extraído do tar (14,7 GB) para `C:\AREA DE POUSO\Fotos da Missão`:
  **21.651 imagens**. Varredura completa rodando em background.
- `scripts/scan_cli.py --limit 30` (acervo real): **40 rostos, 0 erros**.
- Custo medido: **0,29 s por rosto** (era 1,4 s antes de remover os modelos de
  landmark e gênero/idade, que o app não usa).
- Banco `data/faces.db` povoado pela varredura em andamento.
- Modelo `buffalo_l` em cache (`~/.insightface/models`, 289 MB).

**Riscos técnicos identificados (leitura de código):**

1. `app/services.py::cluster_embeddings` — greedy é laço Python `O(n·k)` com
   `np.dot` por cluster; com ~50k rostos vira horas de CPU. DBSCAN com
   `metric="cosine"` é `O(n²)` de memória/distância — inviável nessa escala.
2. `app/main.py::similar_faces` e `propagate` carregam **todos** os rostos em
   memória e fazem cosine em Python puro por requisição.
3. `Query.get()` (legado) em `main.py` — funciona hoje, é dívida com SQLAlchemy 2.x.
4. `list_faces` devolve `total` com `q.count()` e depois pagina — ok, mas sem
   índice composto o `count` custa caro em base grande.
5. Nada de teste automatizado; nenhuma medição de tempo/imagem.

**Próximo passo:** ver `04-TAREFAS.md` (T-003 em diante).

---

## P-03 · Site Jessica Haguiwara Arquitetura

> **Medição do GESTOR-P03 · 2026-11-25 (2ª rodada):** **M-011 fechada.** Parte A:
> submenu `Projeto` → **`Projetos`** (`wp_navigation` 6, +1 byte), `h1` intacto; duas
> leituras, md5 `105a167c…` dos 7 rótulos; purge 204. Parte B: auditoria de prontidão
> em `P-03-Jessica-Haguiwara/AUDITORIA-PRONTIDAO-2026-11-25.md` — **deploy oficial
> liberado**; **Google Ads bloqueado** por 4 itens medidos: (1) 0 tag `AW-` e 0 evento
> de conversão, `/obrigado/` sem link; (2) `_ga`/`__hstc`/`hubspotutk` gravados **sem
> consentimento** e 0 `gtag('consent')`; (3) `[INSERIR REGISTRO]` na `/privacy-policy/`;
> (4) LCP mobile home **7,5–8,2 s** (`DIV.jhw-hero__bg`, JPEG 131,3 KB de background).
> Também medido: `/contato/` **404**; meta description em **1 de 8** páginas;
> `/obrigado/` indexável; `/privacy-policy/` sem `h1`; CLS home **0,244**; INP **16 ms**.
> `T-P03-029` (§37/§38 no `DOCS/IA` do projeto) commitado em **`b8cc298`**.

> **Medição do GERENTE · 2026-11-25, 01:25:** publicação **1.3.10** no ar. As 4 páginas
> de serviço respondem `200` com duas leituras iguais cada (UA Chrome, URL limpa):
> `/consultoria/` **149.392 B** (md5 `6bbd90df`), `/projetos/` **149.300 B** (`e8532940`),
> `/gestao-de-obra/` **149.244 B** (`6dfc674c`), `/chave-na-mao/` **149.178 B**
> (`e7a75bf3`). `style.css` servido: `Version: 1.3.10`.
> **Fechado nesta rodada:** `T-P03-025` — o título das páginas internas deixou de ficar
> atrás do header fixo (`padding-top: calc(var(--jhw-header-altura) + 1.5rem)` na seção
> 11 do CSS; repo do projeto em `df38099`). `T-P03-026` — **9 das 10 trocas editoriais
> aprovadas** estão no ar (C1-C4, P1, G1, G2, M1-M3), a **P2 foi vetada** e segue
> intacta; C3 virou `<ul class="wp-block-list">` com 3 `<li>` (markup conferido).
> **Aberto:** `Q-037` (a `og:description` da `/chave-na-mao/` ficou presa no Yoast com o
> texto antigo do M1), `Q-038` (texto pré-preenchido do WhatsApp desalinhado do CTA novo),
> ~~`Q-035`~~ (fechada em 25/11: o rótulo do submenu virou **"Projetos"**, T-P03-028),
> `Q-036` (duas lacunas do questionário da cliente),
> `T-P03-023` (cor do botão do banner de cookies, em `Q-032`) e `T-011` (dados da
> cliente). Detalhe: `08-GERENTE/AUDITORIA-2026-11-23.md`,
> `P-03-Jessica-Haguiwara/REVISAO-EDITORIAL-2026-11-24.md` e `08-GERENTE/PARA-GESTORES.md`
> (`M-004`/`M-006`). Depoimentos fictícios: mantidos como `EXEMPLO` por decisão do
> Marlon (`Q-025`).


| Campo | Valor |
|---|---|
| Caminho | `C:\MarlonScripts\Jessica Haguiwara` |
| Repo | Próprio (git), último commit `df38099` — 2026-11-25 (1.3.10, título das páginas internas abaixo do header fixo) |
| Objetivo do Marlon | Site institucional no ar, editorial, sem dado inventado; base técnica que aguente cliente real |
| Estado | 🟢 **No ar e aprovado pela cliente**; faltam dados que dependem dela |
| Site | `https://jessicahaguiwara.arq.br` |
| Peso servido (2026-11-20, 22h) | HTML 178.559 B · CSS 5 folhas 420.591 B · JS 21 scripts 1.275.704 B → **481 KB gzip/visita** em 27 requisições (HTML + CSS + JS) |
| Stack | WordPress + tema pai `extendable` + child `jessica-haguiwara-child` (**1.3.10 no ar**), Spectra, Forminator, Complianz, WP Fastest Cache |
| Papel do gestor | Decide prioridade, aprova publicação, verifica no ar. **Não escreve no repo** — o OpenCode escreve |
| Doc do projeto | `DOCS/00-INDICE.md` → `AGENTS.md` é o contrato; `DOCS/12-PLANO-EXECUCAO.md` é o plano vigente |

**Evidência coletada (2026-11-20, medição própria):**

- 4 páginas do sitemap respondem `200`: `/`, `/privacy-policy/`, `/obrigado/`,
  `/politica-de-cookies/`.
- Home: **577.745 B** de HTML, 39 `<script src>`, 31 `<link rel=stylesheet>`.
- `validate-theme.mjs` → **TUDO OK**; `check-live-footer.mjs` → **rodapé do ar OK**.
- `jessica-haguiwara-child/style.css` = 53.041 B no ar (`?ver=1.3.4`), enfileirado,
  com `jhw-home-v2`, `jhw-hero`, `forminator-module-168`, `jhw-pendente`.
  Ou seja: o T10 está **concluído** — a doc que diz "CSS segue no Customizer" está velha.
- `/politica-de-cookies/` existe, está no sitemap e é linkada de `/privacy-policy/`.
  O banner de cookies oferece "Política de Privacidade" → `/privacy-policy/`;
  os links de gerenciamento usam `#`. O T12 como descrito na doc está **resolvido**,
  mas a doc ainda pede "regenerar o documento de cookies".
- **394 KB mortos removidos (1.3.5, 2026-11-20):** o Spectra injetava
  `<style id="spectra-gs-utility-classes-inline-css">` = 394.171 B, idêntico nas
  4 páginas, com 2.755 seletores utilitários e **zero classes usadas** em
  qualquer página. Removido por handle, condicional a página sem bloco Spectra.
  Home: **577.433 → 183.203 B (−68%)**; as outras 3 páginas caíram ~394 KB cada.
  O bloco tinha 0 seletores globais (`html`/`body`/`:root` puro) e 0 `@font-face`
  — por isso a remoção não custa pixel. Rollback: commit `723548c`.
- `deploy-theme.mjs` **sai 0** desde 2026-11-20: o órfão `assets/css/save-probe.css`
  foi para `~/.trash/` via `fileop op=trash`. Estado atual: 11 iguais, 0
  divergentes, 0 órfãos.

**Riscos/armadilhas registradas:**

- O canal com o OpenCode é `scripts/oc-brief.ps1`; para deploy real exigir
  revisão do diff antes (`-NoAuto` disponível desde 2026-11-20).
- Não confiar no MCP de WordPress para dizer o que está no ar: medir a URL pública.
- Cache do WP Fastest Cache mascara medição — limpar antes de medir.
- Nunca inventar CAU, preço, prazo, obra ou área.

**Próximo passo:** ver `04-TAREFAS.md` (T-004 em diante).

---

## P-04 · Portfólio Profissional Marlon Viana

> **Medição do GERENTE · 2026-11-23:** o site **existe e está construído**, ao
> contrário do que diz a linha "executor ainda não acionado" abaixo. Repo
> `C:\MarlonScripts\4-Portfolio`, árvore limpa em `047be25`; home + 6 cases; quatro
> briefs (`v1`…`v4`); 4 commits no repo; `grep PENDENTE` = **0**. **Não publicado:**
> o repositório não tem `git remote` — o "GitHub Pages" do brief v1 não tem destino. Pendências:
> `Q-016` (decidir publicação), `Q-018` (foto), `Q-020` (autorização dos clientes),
> `Q-021` (GitHub privado).


| Campo | Valor |
|---|---|
| Caminho | `C:\MarlonScripts\4-Portfolio` (a criar) |
| Repo | Próprio (git), sem remote ainda — **não publicar sem aprovação** |
| Objetivo do Marlon | Site próprio para divulgar trabalho e atrair contratação: software, jogos, sites |
| Estado | 🟡 Em construção — conteúdo levantado, brief v1 escrito, executor ainda não acionado |
| Stack | HTML + CSS + JS estáticos, sem build; alvo de publicação GitHub Pages |
| Papel do gestor | Inventário, copy, direção de arte, verificação. **Não escreve o código** — o OpenCode escreve |
| Caderno do gestor | `DOCS/P-04-Portfolio/GESTOR.md` (inventário verificado e decisões) |
| Brief | `briefs/2026-11-20-p04-portfolio-v1.md` |

**Levantamento (2026-11-20, verificado):**

- GitHub público `NMarlon`: 42 repos, **31 próprios** e 11 forks. Forks excluídos.
- Projetos locais mapeados em `1-Mini-Projetos` (7 com README próprio) e no
  currículo canônico em `Currículos/INFO/`.
- Seis cases escolhidos para o site: FileFuse, Reconhecedor de Rostos,
  Jessica Haguiwara, PDF TTS, Terabox Auto-Backuper, Face The Fake.
- Números reais que sustentam o site: 21.651 fotos / 0,29 s por rosto / −68% de
  HTML na home da Jessica / desde 2019 no GitHub.

**Bloqueio:** `FileFuse` e `Bot-Creator` (e os demais privados) não foram lidos —
o device flow do `gh` expirou sem autorização do Marlon. O case do FileFuse está
descrito por evidência indireta (`filefuse-estado.json`); o de Bot-Creator não
existe ainda e **não deve ser escrito** até o repo ser lido.

---

## P-05 · Painel Hermes

| Campo | Valor |
|---|---|
| Caminho | `C:\MarlonScripts\5-Painel-Hermes` |
| Repo | próprio, git local — **sem remote** (`Q-034` bloqueia credencial) |
| Objetivo do Marlon | Painel local, ao vivo, do ambiente de trabalho: Hermes vivo, uso do OpenCode Go, desempenho dos gestores |
| Estado | 🟢 T-P05-001 (coletor) medida 24/11 21:27 · 🟢 T-P05-002 (agendador) medida 25/11 01:26, coleta a cada 15 min · 🟢 T-P05-003 (UI local + export diário) medida 25/11 02:12, `http://127.0.0.1:8787` responde 200 e só no loopback · 🟢 T-P05-008 medida 25/11 10:36 (grade 1440) · 🟢 T-P05-010 medida 25/11 10:31 (**cota oficial ao vivo**: 10% / 21% / 37%) · 🟢 T-P05-009 medida 25/11 10:55 (autostart por Agendador, volta sozinho em ≤5 min) |
| Stack | Python stdlib (ou Node sem `node_modules`); série em arquivo append-only |
| Papel do gestor | Decide, briefa, mede. **Não escreve** — o OpenCode escreve |
| Caderno do gestor | `DOCS/P-05-Painel-Hermes/GESTOR.md` |
| Brief | `briefs/2026-11-25-p05-t003-ui-local.md` (T-003) · `briefs/2026-11-25-p05-t002-agendador-serie.md` (T-002) |

**Aprovação:** Marlon, 2026-11-24 21:15 — *"Então pode fazer P05 Painel Hermes."*

**Regra de cadência:** sem cron de IA. Agendador do Windows roda o script (não gasta
token de LLM) e só se instala quando o Marlon pedir — pedido feito na M-005 do Gerente.

**Agendador instalado em 2026-11-25 01:26:** tarefa `\PainelHermes-Coletor`, a cada
15 min, modo **interativo** (S4U exige elevação; não coleta com o usuário deslogado).
Prova: `schtasks` com `Último resultado: 0`, 11 → 12 linhas em `dados/stats.jsonl`
(a 12ª gravada 3 s depois do disparo, sem execução manual) e a 13ª entrando sozinha
15 min depois, às 01:40:50.

**UI medida em 2026-11-25 02:12:** commit `3ce9186` (`P05-EXECUTOR`); `scripts/painel.py`
serve `http://127.0.0.1:8787` e responde **200**, só no loopback — `192.168.0.17:8787` e
`[::1]:8787` recusam (exit 7). `amostras` da API bate com `wc -l`, última coleta com
`tail -1`; a amostra 17 veio da tarefa agendada (02:10:47, resultado 0) e a tela a exibiu
sem reiniciar. Cota continua `indisponivel` com motivo, sem percentual inventado.

**Export diário:** `scripts/backup_serie.py`, chamado pelo coletor, grava
`backups/stats-AAAA-MM-DD.jsonl` uma vez por dia (15 linhas hoje; sha256 idêntico ao
prefixo da série). `--forcar` reescreve. `backups/` está no `.gitignore`.

**Próxima tarefa:** `T-P05-004` (relatório semanal em `.md`, manual) está no backlog e
**não** foi autorizada. Antes dela, o backlog do projeto pede rotação/compactação da
série e revisão do crescimento de `backups/` (~0,5 MB/dia, sem expurgo). Autostart da UI
e `push` (Q-034) só com ordem escrita do Marlon.


**Autostart entregue em 2026-11-25 (M-015, item 3):** tarefa `\PainelHermes-Painel`
com **dois** gatilhos — AtLogOn +30 s (boot) e relógio a cada 5 min, duração `P3650D`
(queda do processo). Ação: `pythonw.exe scripts\garantir_painel.py`, que só sobe o painel
se `GET http://127.0.0.1:8787/` não responder 200 (idempotente, trava em
`logs/painel-auto.lock`). Medido pelo gestor: PID 8016 morto às 10:52:27, painel de volta
às 10:55:19 (PID 23716), `LastTaskResult 0`, `NextRunTime 11:00:14`, nenhum navegador
aberto. **Limite:** tarefa `InteractiveToken` — não roda com o usuário deslogado.
Remover: `powershell -File scripts\instalar-painel-auto.ps1 -Remover`.

**Cota oficial ao vivo (M-013) medida em 2026-11-25 10:31:** o cartão deixou de ser
`INDISPONIVEL`. Fonte: `GET https://opencode.ai/zen/go/v1/usage` (HTTP 200 em 0,48 s),
lida a cada rodada do coletor com a chave do `.env` do Hermes; grava `cota_oficial` em
`stats.jsonl` e o bloco `oficial` do `grafico.json` deriva dela. Duas coletas seguidas
deram **5 h 10% · semanal 21% · mensal 37%**; falha vira motivo legível (testado com
chave inválida → `HTTP 401`), nunca zero. O cartão mantém a última leitura válida com a
hora visível se a mais nova falhar. Percentual é **do plano**, não consumo de tokens.
