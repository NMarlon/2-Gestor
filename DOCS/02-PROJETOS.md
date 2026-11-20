# 02 — Registro de projetos

> Estado **verificado** em 2026-11-20 pelo gestor. Cada linha carrega evidência.
> Fonte de escopo: `../PROJETOS_APROVADOS.md`.

---

## P-01 · Hermes-Mobile

| Campo | Valor |
|---|---|
| Caminho | `C:\MarlonScripts\1-Mini-Projetos\Hermes-Mobile` |
| Repo | `C:\MarlonScripts\1-Mini-Projetos` (pasta filha; não tem `.git` próprio) |
| Objetivo do Marlon | Usar o Hermes do PC no celular (Pomelu / Mono Hermes) via Tailscale |
| Estado | 🟢 **Funcional** (confirmado pelo Marlon em 2026-11-20) |
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

| Campo | Valor |
|---|---|
| Caminho | `C:\MarlonScripts\Jessica Haguiwara` |
| Repo | Próprio (git), último commit `fc38a81` — árvore limpa em 2026-11-20 |
| Objetivo do Marlon | Site institucional no ar, editorial, sem dado inventado; base técnica que aguente cliente real |
| Estado | 🟢 **No ar e aprovado pela cliente**; faltam dados que dependem dela |
| Site | `https://jessicahaguiwara.arq.br` |
| Stack | WordPress + tema pai `extendable` + child `jessica-haguiwara-child` (1.3.4), Spectra, Forminator, Complianz, WP Fastest Cache |
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
- **Achado novo (394 KB mortos):** `<style id="spectra-gs-utility-classes-inline-css">`
  = 394.171 B, **idêntico nas 4 páginas**, com 2.755 seletores utilitários e
  **zero classes usadas** no `<body>` de qualquer página (match exato de token);
  nenhuma página tem `wp-block-uagb`. Tarefa `G3-b` aberta com o OpenCode.
- `deploy-theme.mjs` sai **exit 1** por 1 órfão no servidor
  (`assets/css/save-probe.css`, não referenciado em lugar nenhum do repo). T5.

**Riscos/armadilhas registradas:**

- O canal com o OpenCode é `scripts/oc-brief.ps1`; para deploy real exigir
  revisão do diff antes (`-NoAuto` disponível desde 2026-11-20).
- Não confiar no MCP de WordPress para dizer o que está no ar: medir a URL pública.
- Cache do WP Fastest Cache mascara medição — limpar antes de medir.
- Nunca inventar CAU, preço, prazo, obra ou área.

**Próximo passo:** ver `04-TAREFAS.md` (T-004 em diante).
