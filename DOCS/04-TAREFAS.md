# 04 — Tarefas

> Para a próxima IA: pegue a primeira 🟡, siga o "como proceder", ao terminar
> atualize o status, registre a evidência e commite.

Legenda: 🟢 feito e verificado · 🟡 em andamento · 🔴 bloqueado · ⚪ não iniciado

---

## T-001 · Estruturar workspace do gestor 🟢

**Feito:** `DOCS/00` a `06`, `.gitignore`, repo git, commit inicial.
**Falta:** `AGENTS.md` na raiz — bloqueado por aprovação (ver `06-PERGUNTAS.md` Q-02).

---

## T-002 · Verificar e fechar P-01 (Hermes-Mobile) 🟢

**Feito:** doc sincronizada com a realidade pelo OpenCode (14 arquivos `.md`,
versão 0.23.1 → 0.23.2, Fase 2 concluída, Fase 5 parkeada).

**Evidência:** commit `79013d5` no repo `1-Mini-Projetos`, escopo `Hermes-Mobile/`.
Verificação independente: `https://<tailnet>:8443/api/status` → `200`, `0.23.2`.

**Pendências:** nenhuma bloqueante. Só backlog (aviso de versão do Mono Hermes,
plugin de push).

---

## T-003 · P-02: acervo real + varredura completa 🟡 EM ANDAMENTO

**Feito:**
1. Acervo identificado e extraído: `transfer_fotos_videos.tar` (14,7 GB) →
   `C:\AREA DE POUSO\Fotos da Missão`. **21.651 imagens** (~21,6k jpg/jpeg) +
   vídeos e `.json` do Takeout (ignorados pelo scanner).
2. Banco zerado: o `data/faces.db` anterior só tinha 30 imagens de teste.
   Backup em `data/faces.db.probe.bak`.
3. Varredura completa rodando em background:
   `logs/scan-full-20261120b.log` —
   `python scripts/scan_cli.py --dir "C:/AREA DE POUSO/Fotos da Missão" --resume`.
4. Medição real: **0,29 s por rosto**. O custo é por rosto, não por imagem — há
   pastas com 28 rostos por foto (colagens do WhatsApp).
5. Vazão medida com a máquina livre: **0,97 img/s** → ETA ~6 h para as 21.651.
   Contenção de CPU (outro processo pesado) derruba para 0,13 img/s — por isso
   nada pesado roda em paralelo enquanto a varredura estiver de pé.
6. **Ressalva de cobertura:** a extração do tar terminou às 01:24, *depois* de a
   varredura começar (01:05). O `rglob` do `scan_cli` é preguiçoso, então pastas
   visitadas antes disso podem ter ficado incompletas. Por isso a varredura terá
   **duas passadas** com `--resume`: a segunda só completa o que faltou (pula o
   já processado por caminho+tamanho+mtime). O cron `reconhecedor-pos-varredura`
   controla isso pelo marcador `.scan_pass2_done`.
   Total real em disco: **21.482 imagens** (o 21.651 anterior foi contado com a
   extração ainda em curso).
7. API no ar em `127.0.0.1:8011` lendo o banco parcial durante a varredura (só
   leitura — o clustering fica para o fim, para não disputar o SQLite com o
   scanner).

**Falta:**
1. Acompanhar o log até o fim e confirmar que fecha sem erro.
2. Com o banco povoado: rodar `/api/cluster`, revisar pessoas e medir
   `/api/faces/{id}/similar`.
3. Anotar aqui o total de rostos e o tempo real da varredura.

**Se a varredura morrer:** reexecutar o mesmo comando com `--resume` — ele pula
o que já está no banco por caminho + tamanho + mtime.

---

## T-004 · P-02: escalar clustering e busca 🟢 (código) · 🟡 (validar com dado real)

**Feito pelo OpenCode:** greedy vetorizado em blocos (`numpy` matmul),
`similar`/`propagate` com produto matricial + `argpartition`, `app/embeddings.py`
novo, orientação EXIF corrigida (`app/image_io.py`), `scripts/scan_cli.py`
(headless, `--limit`, `--resume`, `--dry-run`), `scripts/bench_cluster.py`.

**Evidência:** 20k embeddings 512-d clusterizados em **4,8 s** (meta < 120 s),
no caso patológico (todos singleton). Scan de 30 fotos: 40 rostos, 0 erros.

**Falta:** medir `/api/faces/{id}/similar` com o banco cheio (meta < 300 ms).

---

## T-005 · Revisar e commitar as mudanças do OpenCode no Reconhecedor 🟡

**Contexto:** a sessão do OpenCode foi interrompida pelo meu timeout de 600 s e
deixou ~10 arquivos alterados (`app/main.py`, `embeddings.py`, `image_io.py`,
`processor.py`, `services.py`, `models.py`, `db.py`, `config.py`,
`scripts/scan_cli.py`, `scripts/bench_cluster.py`, mais `DOCS/`).

**Falta:**
1. Revisar o `git diff` (atenção em `services.py` e em mudança de schema).
2. Commitar no repo do projeto, escopo próprio.
3. Registrar no `DOCS/ERRORS_LEARNINGS.md` do projeto o que mudou.

---

## T-006 · P-02: documentação no padrão do Marlon ⚪ (rebaixada)

**Reavaliação:** o `DOCS/` do projeto já tem os quatro documentos exigidos
(`TASKS`, `ERRORS_LEARNINGS`, `BACKLOG` e `AGENTS.md` como índice). Renomear para
o padrão numerado quebraria os links do `AGENTS.md` dele sem ganho real.

**Decisão:** não renomear; só manter o conteúdo atualizado. Vai para o backlog.

---

## T-007 · P-02: validar o fluxo completo com dado real ⚪

**Objetivo:** provar os três requisitos do Marlon com o acervo real.
1. Clusterizar e conferir, por amostra visual, se os grupos fazem sentido.
2. Exportar QUEM ↔ CADA foto (`/api/export/people`) e conferir o formato.
3. Clicar num rosto na UI e ver todas as fotos daquela pessoa.

---

## T-008 · P-03: auditoria da doc do projeto — 4 contradições verificadas 🟡

**Feito (gestor, 2026-11-20):** li `AGENTS.md`, `DOCS/12-PLANO-EXECUCAO.md` e
`DOCS/04-TAREFAS.md` do projeto e comparei com o site no ar. A doc tem afirmações
que já não são verdade:

1. `04-TAREFAS.md` (§ "Como retomar" item 3) diz **"hoje 2 FAILs (T8/T17)"**.
   Falso: `node scripts/validate-theme.mjs` → **TUDO OK** nesta data.
2. `04-TAREFAS.md` § "Estado atual (2026-11-09)" — 11 dias velho, e o site mudou
   (1.3.2 → 1.3.4).
3. **T10 se contradiz:** `12-PLANO-EXECUCAO.md` linha 177 diz "concluído: CSS no
   style.css (1.2.4), custom_css zerado"; linha 179 diz "custom_css não pôde ser
   gravado — CSS segue no Customizer". Medição: o `style.css` do child está no ar
   com 53.041 B e tem `jhw-home-v2`/`jhw-hero`/`forminator-module-168`. A linha
   179 é a errada.
4. **T12** diz "falta regenerar o documento de cookies". O `/politica-de-cookies/`
   existe, está no sitemap e é linkado de `/privacy-policy/`. O que a doc diz não
   bate com o site.

**Falta:** o OpenCode corrigir as 4 afirmações (uma passada só, sem tocar em
código) e o gestor reconferir contra a URL pública.

---

## T-009 · P-03: G3-b — eliminar 394 KB de CSS morto em toda página 🟡

**Achado do gestor (2026-11-20):** `<style id="spectra-gs-utility-classes-inline-css">`
= **394.171 B**, byte-idêntico nas 4 páginas, com 2.755 seletores utilitários do
Spectra. As 4 páginas têm **zero** classes dessas no `<body>` (match exato de
token) e **nenhum** `wp-block-uagb`. É peso morto em 100% das visitas.

**Brief enviado:** `%TEMP%\opencode\brief-2026-11-20-spectra-css.md` (G3-b).
Exige remoção **condicional** (só em página sem bloco Spectra) via filtro oficial,
bump 1.3.4 → 1.3.5, sem deploy — publicação é decisão do gestor.

**Meta:** HTML da home de 577.745 B para < 200.000 B, visual idêntico.

---

## T-010 · P-03: T5 — órfão `save-probe.css` derruba o deploy (exit 1) ⚪

**Contexto:** `deploy-theme.mjs` compara repo × servidor e sai **exit 1** por 1
órfão: `assets/css/save-probe.css` (não é referenciado por nada no repo). A doc do
projeto afirma que a UAPI do cPanel "não tem `delete_file`" — a doc oficial da
cPanel lista `Fileman::delete_file` (param `path`) e `Fileman::trash_file`
(reversível). Ou seja: a premissa pode estar errada e o T5 pode ser fechável.

**Falta:** o OpenCode provar na conta (dry-run primeiro, `trash_file` antes de
`delete_file`) e, se funcionar, o deploy passa a sair 0 sem esconder divergência.
`trash_file` é a opção preferida por ser reversível.

---

## T-011 · P-03: dados que só a cliente pode dar 🔴

Bloqueado até a cliente responder. Não inventar em hipótese alguma:
CAU/registro, áreas de obra, prazos, faixas de preço, texto da seção "Prova".

**Falta:** o Marlon levar a lista consolidada para a cliente. Enquanto isso, o
site fica com o que está — sem placeholder inventado.
