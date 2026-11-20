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
