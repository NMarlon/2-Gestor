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

**Deriva de documentação encontrada:** `DOCS/10-TAREFAS.md` marca a Fase 2
(Tailscale `:8443`) como ⚪ não iniciada, mas o `tailscale serve status` mostra
`8443` ativo. A doc está atrasada em relação à realidade.

---

## P-02 · Reconhecedor de Rostos de Imagens

| Campo | Valor |
|---|---|
| Caminho | `C:\MarlonScripts\1-Mini-Projetos\Reconhecedor de Rostos de  Imagens` (dois espaços antes de "Imagens") |
| Repo | Próprio (`git` aninhado; aparece como `??` no repo pai) |
| Objetivo do Marlon | (1) reconhecer/distinguir rostos em dezenas de milhares de imagens; (2) lista QUEM ↔ CADA foto; (3) visual para clicar num rosto e ver todas as fotos daquela pessoa |
| Estado | 🟡 **Código pronto, nunca rodou com foto real** |
| Stack | Python 3.11, FastAPI, InsightFace `buffalo_l` (CPU), SQLAlchemy 2.1.8, SQLite |

**Evidência coletada (2026-11-20):**

- API sobe em `127.0.0.1:8011`; `/api/stats`, `/api/people`, `/api/cluster`,
  `/api/export/people`, `/api/scan/status` respondem `200`.
- Banco `data/faces.db`: **0 imagens, 0 rostos, 0 pessoas**. O app nunca processou
  um acervo real.
- `C:\AREA DE POUSO\Fotos da Missão` existe e está **vazia** (0 arquivos).
- Há um arquivo `C:\Users\Marlon\Downloads\Fotos\transfer_fotos_videos.tar` de
  **14,7 GB** — candidato ao acervo real (inspeção em andamento).
- Modelo `buffalo_l` já está em cache (`~/.insightface/models`, 289 MB).

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
