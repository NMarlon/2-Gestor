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

## T-003 · P-02: acervo real + varredura completa 🟢 CONCLUÍDA (2026-11-20 09:0x)

**Resultado medido:**
- **21.482 imagens varridas** — exatamente o total de arquivos de imagem em disco.
- **51.688 rostos** detectados na passada final; **52.726** no total do banco
  (inclui as 277 imagens já processadas antes, puladas por `--resume`).
- **0 erros**. Tempo da passada: **31.658 s** (8h48), média **0,68 img/s**.
- Banco final: `images=21.482`, `images_processed=21.482`, `faces=52.726`,
  `people=17.470`, `unassigned_faces=0`.
- Clustering: `POST /api/cluster` → 52.726 rostos em **17.470 grupos**, **42,7 s**.

**Feito:**
1. Acervo extraído de `transfer_fotos_videos.tar` (14,7 GB) para
   `C:\AREA DE POUSO\Fotos da Missão`: 30.530 arquivos, sendo **21.482 imagens**;
   conferido contra `tar -tf` (30.530 arquivos) — nada perdido.
2. Banco de teste zerado antes da varredura (backup `data/faces.db.probe.bak`).
3. Duas decisões de performance: remoção dos módulos de landmark/gênero-idade
   (**1,4 s → 0,29 s por rosto**) e clustering vetorizado em blocos.
4. A varredura fechou com cobertura completa, então a segunda passada não foi
   necessária: o total do banco bateu com o disco. Marcador `.scan_pass2_done`
   criado para o cron não repetir.
5. API no ar em `127.0.0.1:8011` durante e depois da varredura (só leitura
   enquanto varria, para não disputar o SQLite com o scanner).

### Qualidade do agrupamento (medido em 2026-11-20)
- Maior grupo: **597 rostos em 596 fotos distintas** (a mesma pessoa em ~600
  fotos, de fontes diferentes: WhatsApp, digitalização, transferências CTM).
- 5 maiores: 597, 385, 365, 355, 340 rostos.
- **687 pessoas com 10+ rostos** e **158 com 50+** — esse é o universo de
  pessoas "reais" do acervo.
- **13.125 grupos têm 1 único rosto (75% do total)** — rostos de passagem, fundo,
  foto ruim. Não são pessoas identificáveis; nomear cada um seria desperdício.
- Nomes são genéricos (`Pessoa 0`, `Pessoa 1`, ...). Nomear é trabalho manual —
  candidato a tela de nomeação (ver T-005).

### Pendencias de performance medidas
- `GET /api/export/people`: **103,7 s** para 17.470 pessoas / 8,3 MB — quase
  certamente N+1 (busca as imagens pessoa por pessoa). Precisa de brief.
- `GET /api/faces/{id}/similar`: **1,4 s** com 52,7k rostos — funcional, mas
  candidato a cache da matriz de embeddings.

**Se precisar reprocessar:** o mesmo comando com `--resume` pula o que já está no
banco por caminho + tamanho + mtime.

---

## T-004 · P-02: escalar clustering e busca 🟢 (código) · 🟢 (validado com dado real)

**Feito pelo OpenCode:** greedy vetorizado em blocos (`numpy` matmul),
`similar`/`propagate` com produto matricial + `argpartition`, `app/embeddings.py`
novo, orientação EXIF corrigida (`app/image_io.py`), `scripts/scan_cli.py`
(headless, `--limit`, `--resume`, `--dry-run`), `scripts/bench_cluster.py`.

**Evidência com dado real (21.482 imagens / 52.726 rostos):**
- Clustering completo via `POST /api/cluster`: **42,7 s** (meta < 120 s). ✅
- Agrupamento coerente: maior grupo com 597 rostos em 596 fotos distintas. ✅
- `GET /api/faces/{id}/similar`: **1,40 s** — **fora da meta de 300 ms**. ❌
- `GET /api/export/people`: **103,7 s** para 17.470 pessoas (8,3 MB) — fora. ❌

**Conclusão:** escala aprovada para clustering; busca unitária e export precisam
de otimização (cache da matriz de embeddings e eliminação de N+1 no export).
Ambos viram brief ao OpenCode (ver T-012).

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

## T-009 · P-03: G3-b — eliminar 394 KB de CSS morto em toda página ✅

**Concluído em 2026-11-20, no ar e medido.** O OpenCode removeu o bloco por handle
(`spectra-gs-utility-classes`), condicionado a página sem bloco Spectra, com
filtro de escape `jhw_keep_spectra_utility_css`. Tema em **1.3.5**, 11 arquivos
conferindo por SHA256, cache do WPFC e do proxy limpos.

| Página | Antes | Depois | Δ |
|---|---|---|---|
| `/` | 577.433 B | **183.203 B** | −68% |
| `/privacy-policy/` | 541.533 | 147.303 | −394.230 |
| `/obrigado/` | 533.649 | 139.419 | −394.230 |
| `/politica-de-cookies/` | 528.522 | 134.287 | −394.235 |

Medido **servido** (cache do WPFC, sem query string), 3× por página, idêntico.
Existe também um render dinâmico que é 46 B maior — ver E-015.

**Sobra corrigida no 1.3.6:** a 404 entregava 534.150 B porque a condição
preservava CSS em qualquer página não singular. Com `is_404()`: **139.919 B**
(−394.231, −74%), 3× estável. Verificado no `body` da 404 antes do brief: 0
classes utilitárias, 0 `wp-block-uagb`, 0 `gs-*`.

**Perda zero:** home segue 183.203 B (idêntica antes e depois do 1.3.6), as 3
subpáginas idem, 31 folhas de estilo, mesmo rodapé, validador OK.

Verificação própria antes de publicar: o bloco removido tem **0** seletores
globais (`html`, `body`, `*`, `:root` puro), **0** `@font-face`, 18 `@keyframes`
usados só por utilitários mortos; o preflight é escopado em
`.spectra-is-root-container`. Os 31 `<link rel=stylesheet>` continuam os mesmos e
o `style.css` do child está intacto no ar. Commit de rollback: `723548c`.

**Ressalva:** não fiz diff de pixels — não há navegador headless configurado. A
prova é a análise do CSS removido, não comparação visual.

**Achado do gestor (2026-11-20):** `<style id="spectra-gs-utility-classes-inline-css">`
= **394.171 B**, byte-idêntico nas 4 páginas, com 2.755 seletores utilitários do
Spectra. As 4 páginas têm **zero** classes dessas no `<body>` (match exato de
token) e **nenhum** `wp-block-uagb`. É peso morto em 100% das visitas.

**Brief enviado:** `%TEMP%\opencode\brief-2026-11-20-spectra-css.md` (G3-b).
Exige remoção **condicional** (só em página sem bloco Spectra) via filtro oficial,
bump 1.3.4 → 1.3.5, sem deploy — publicação é decisão do gestor.

**Meta:** HTML da home de 577.745 B para < 200.000 B, visual idêntico.

---

## T-010 · P-03: T5 — órfão `save-probe.css` → deploy sai 0 ✅

**Concluído em 2026-11-20.** Removido de forma reversível (`Fileman::fileop
op=trash`, API 2 — a UAPI não tem `trash_file` nem o módulo `Trash` neste
cPanel; o arquivo foi para `~/.trash/`). Commit `a66557c`, só doc.

**Verificado por mim, independente do relatório:** `node scripts/deploy-theme.mjs
--dry-run` → `11 igual(is), 0 divergente(s), 0 novo(s), 0 orfao(s)`,
`enviaria 0 arquivo(s)`, **EXIT=0**. Validador: TUDO OK, 11 arquivos, 119.647 B.

**No ar, 3 leituras por página (servido):** `/` **183.204** · `/privacy-policy/`
**147.303** · `/obrigado/` **139.419** · `/politica-de-cookies/` **134.292** ·
404 **139.919**. As subpáginas e o 404 estão idênticos ao 1.3.6; a home variou
**+1 B** entre janelas (183.203 → 183.204) — dentro da página é constante, então
é ruído de 1 byte, não conteúdo.

**Ressalva registrada:** a lixeira `~/.trash/` não tem UI nem expurgo neste
cPanel. O arquivo está lá até alguém apagar no File Manager — reversível, mas
não some sozinho.

---

## T-011 · P-03: dados que só a cliente pode dar 🔴

Bloqueado até a cliente responder. Não inventar em hipótese alguma:
CAU/registro, áreas de obra, prazos, faixas de preço, texto da seção "Prova".

**Falta:** o Marlon levar a lista consolidada para a cliente. Enquanto isso, o
site fica com o que está — sem placeholder inventado.

---

## T-012 · P-02: otimizar `similar` e `export/people` ⚪ (brief pendente)

Medido com o acervo cheio (21.482 imagens / 52.726 rostos):

| endpoint | medido | meta |
|---|---|---|
| `GET /api/faces/{id}/similar` | **1,40 s** | < 300 ms |
| `GET /api/export/people` | **103,7 s** (8,3 MB) | < 10 s |

**Hipóteses (a confirmar no brief, não afirmar como causa):**
- `similar` recarrega a matriz inteira de embeddings a cada chamada → cache em
  memória invalidado por `POST /api/cluster`.
- `export` faz N+1: uma consulta por pessoa para buscar as imagens.

**Brief:** OpenCode mede antes/depois, mostra o perfil com `cProfile` e só então
otimiza. Aceite: os dois tempos acima batidos, com o mesmo resultado numérico
(mesmos vizinhos, mesmo JSON).
