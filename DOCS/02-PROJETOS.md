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

> **Medição do GERENTE · 2026-11-23:** publicação **1.3.8** no ar. Home
> `https://jessicahaguiwara.arq.br/` → `200`, **178.614 bytes** de HTML (UA Chrome,
> sem query string, duas leituras), `style.css?ver=1.3.8`, link de cookies no
> rodapé. Repo em `cbdf3d0` (`T-P03-018`), árvore limpa; tarefas `T-P03-016`…`020`
> executadas mas **fora** da fila `04` (corrigido em `T-020`). Aberto: `T-011` (dados
> da cliente). Depoimentos fictícios: mantidos como `EXEMPLO` por decisão do Marlon
> (`Q-025`). `release.json` em 1.3.7 é baseline normal — o validador passa
> (`PASS` nos três testes de release, 24/11). Detalhe:
> `08-GERENTE/AUDITORIA-2026-11-23.md`.


| Campo | Valor |
|---|---|
| Caminho | `C:\MarlonScripts\Jessica Haguiwara` |
| Repo | Próprio (git), último commit `f7ffce7` — árvore limpa em 2026-11-20 |
| Objetivo do Marlon | Site institucional no ar, editorial, sem dado inventado; base técnica que aguente cliente real |
| Estado | 🟢 **No ar e aprovado pela cliente**; faltam dados que dependem dela |
| Site | `https://jessicahaguiwara.arq.br` |
| Peso servido (2026-11-20, 22h) | HTML 178.559 B · CSS 5 folhas 420.591 B · JS 21 scripts 1.275.704 B → **481 KB gzip/visita** em 27 requisições (HTML + CSS + JS) |
| Stack | WordPress + tema pai `extendable` + child `jessica-haguiwara-child` (1.3.7), Spectra, Forminator, Complianz, WP Fastest Cache |
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

