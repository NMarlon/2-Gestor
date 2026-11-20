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
