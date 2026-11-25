# 04 — Tarefas

> Para a próxima IA: pegue a primeira 🟡, siga o "como proceder", ao terminar
> atualize o status, registre a evidência e commite.

Legenda: 🟢 feito e verificado · 🟡 em andamento · 🔴 bloqueado · ⚪ não iniciado

---

## T-050 · P-04: construir o site de portfólio 🟢

**Brief:** `briefs/2026-11-20-p04-portfolio-v1.md`
**Dir:** `C:\MarlonScripts\4-Portfolio` (criado 2026-11-20)
**Executor:** OpenCode via `scripts/oc-brief.ps1`

**Feito até aqui (gestor):** inventário verificado em
`DOCS/P-04-Portfolio/GESTOR.md`; seis cases escolhidos com números reais; copy
completa e direção de arte no brief; P-04 registrado em `02-PROJETOS.md`.

**Critério de aceite:** sete páginas respondendo `200` em servidor local, nenhum
link interno quebrado, nenhuma imagem inexistente, sem dependência além de Google
Fonts.

**Não autorizado:** publicar, criar repo no GitHub, inventar dado.

**Pendente de terceiro:** leitura do GitHub privado (Q-021), foto (Q-018),
autorização dos clientes (Q-020).

**Histórico:** v1 `84e5a59` (13 arquivos). v2 `dd561fb` — seis correções da
revisão visual (bloco vazio do case, réguas, ficha de números, hero, campo Ano,
fallback do reveal). Ver `DOCS/P-04-Portfolio/GESTOR.md` §7.

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

## T-012 · P-02: otimizar `similar` e `export/people` 🟢 CONCLUÍDA (2026-11-20)

Medido com o acervo cheio (21.482 imagens / 52.726 rostos):

| endpoint | antes | depois (verificado pelo gestor) | meta |
|---|---|---|---|
| `GET /api/faces/{id}/similar` | 1,40 s | **0,028–0,040 s** | < 300 ms ✅ |
| `GET /api/export/people` | 103,7 s | **1,68 s** (8.366.924 B) | < 10 s ✅ |

**Causa real, medida no profiling** (não é hipótese):
- `similar`: `load_embedding_matrix` relia os 52.726 blobs (0,604 s) e normalizava
  a matriz inteira a cada request (0,129 s).
- `export/people`: **45.238 statements SQL**, dos quais 45.237 lazy loads
  (`Person.faces`, `Person.tags`, `Face.image`).

**Correção pelo OpenCode (commit `644331c` do repo do P-02):** cache da matriz já
normalizada (~108 MB) validado por `(COUNT, MAX(id))` e invalidado em
`POST /api/cluster`; export com 4 consultas em lote.

**Verificação do gestor:** API da 8011 reiniciada no código novo; 3 medições de
`similar` e 1 de export; comparação do JSON antes/depois → **17.470 pessoas,
0 divergências** em `name`/`face_count`/`tags`, mesmos `image_paths`, mesmo
tamanho de resposta.

**Ressalva:** a linha de base registrada pelo OpenCode foi menor (0,74 s / 22,0 s)
porque o banco já estava em cache de página do SO. Os números da tabela "antes"
são os medidos antes de qualquer otimização; a proporção se mantém.

---

## T-016 · P-02: fluxo de pessoas por foto (lista distinta → fotos → rostos) ✅ CONCLUÍDA (2026-11-22)

**Entrega:** commit `190cb4c` no repo do P-02 ("feat: fluxo pessoas -> fotos -> foto").

**Medição do gestor** (2026-11-22 16:0x, API reiniciada em `:8011` no código novo,
script `verif_t016.py`, contra o banco real):

| Critério | Medido | Esperado |
|---|---|---|
| `GET /api/people?page_size=100` | **62 ms**, total 10.416, 100 itens, com `thumb` | < 500 ms |
| total com `min_face_px=48` / `0` | 10.416 / 17.470 | igual ao banco |
| `GET /api/people/116/photos` | 596 fotos, **0 repetidas** (47 ms) | 596 distintas |
| `GET /api/images/14764` | 739 rostos, 0 sem bbox | 739 no banco |
| `GET /api/photo/14764` | 1ª 79 ms · 2ª 16 ms · `mtime` igual · 70.435 B | < 1 s / < 100 ms |
| renomear pessoa 33 | gravou e restaurou | persiste |
| 404 em id inexistente | 404 nos 3 endpoints | 404 |

Miniatura representativa confere: pessoa 116 → `face_4479`, que é de fato o rosto
de maior área do grupo (2.280.380 px²).

Brief: `briefs/2026-11-22-p02-fluxo-pessoas-por-foto.md` · disparado 2026-11-22.

Pedido do Marlon: a aba "Todos" hoje repete a mesma pessoa milhares de vezes —
inservível para procurar e nomear. O fluxo passa a ser:

1. lista de **pessoas distintas**, com miniatura do rosto, busca e renomear inline;
2. clicar numa pessoa → grade de **fotos inteiras** onde ela aparece;
3. clicar numa foto → lightbox com a foto inteira e **todas** as caixas dos rostos
   detectados, cada uma indo para a pessoa correspondente.

Contexto medido antes do brief: 52.726 rostos, 17.470 grupos; **10.416** grupos têm
ao menos um rosto ≥ 48 px e 2.915 têm ≥ 2 rostos com um ≥ 48 px. Daí o filtro
`só rostos ≥ 48 px` ligado por padrão — os outros ~7 mil são fundo de foto
(rosto de 20–30 px não gera assinatura confiável; foi o caso dos rostos 11 e 115,
mesma pessoa com similaridade medida de 0,072 por um dos lados ter 20×24 px).

O que muda no repo do P-02: `person_stats` (tabela derivada), `GET /api/people`
reescrito sem N+1 com miniatura, `GET /api/people/{pid}/photos`,
`GET /api/images/{iid}`, `GET /api/photo/{iid}` (miniatura de foto, cache em
`data/photos/`), `GET /api/image/{iid}/file`, e a UI em três níveis.

Proibido no brief: mexer em detecção/embeddings/clustering, rodar `/api/cluster`,
alterar schema existente ou escrever no acervo.

---

## T-019 · P-02: editar o nome do rosto direto na foto ✅ concluída (2026-11-22)

Brief: `briefs/2026-11-22-p02-renomear-rosto-na-foto.md` · commit `1681d3b`.

No lightbox, o nome dentro da caixa virou `span.lb-name` editável. Clique no nome →
input com o nome atual; `Enter`/blur salva por `PUT /api/people/{pid}`; `Esc` cancela
sem fechar a foto; `409` abre o diálogo de mesclar por cima da imagem; clique na caixa
fora do nome continua abrindo o conjunto. Rosto sem grupo: `pointer-events:none`.

**Medido por mim** no Edge headless via CDP (`cdp_run.py` + `teste_nome.js`) contra o
app real na 8011 — não é screenshot do executor:

| passo | resultado |
|---|---|
| clique no nome | input abre com `Pessoa 10`, foco no campo |
| `Enter` com `Teste Gestor` | rótulo vira `Teste Gestor`, **lightbox segue aberto**, input removido |
| banco | `people.name` = `Teste Gestor` → persistiu; restaurado para `Pessoa 10` (PUT 200) |
| `Esc` com `Nao Deve Salvar` | rótulo intacto, nada gravado |
| nome que já existe (`Elder Viana`) | diálogo "Já existe" com 8 miniaturas e botões Cancelar/Mesclar |
| **Cancelar** | nome, banco e lightbox como estavam |
| clique na caixa de outro rosto (pessoa 116) | lightbox fecha, abre o conjunto (60 fotos na 1ª página) |

0 erro de JS no console. Toast (`#toast`) não exercitado no meu teste — o texto
`Renomeado: X → Y` está no código (linha 874) e aparece nas capturas do executor.

## T-018 · P-02: atrito nas flags e no diálogo de mesclar ✅ concluída (2026-11-22)

Brief: `briefs/2026-11-22-p02-correcoes-flags.md` · commit `3f29393`.

Criar flag com nome já existente passou a **reaproveitar** a existente em vez de
estourar `400 tag exists`; o erro `detail not found` virou mensagem em português
explicando servidor desatualizado; contagem por pessoa no diálogo de mesclar não
devolve mais `0 rostos`; nomes no toast de merge em vez de IDs.

**Verificado por mim:** `/api/people?page_size=100` 50 ms, banco íntegro
(`people=17467`, `faces=52726`, 0 órfão, `tags=1`). **Não testei** o reaproveitamento
da flag pela UI nem o texto novo do erro — só o relatório do executor cobre isso.

## T-017 · P-02: mesclar pessoas + flags coloridas por pessoa ✅ concluída (2026-11-22)

Brief: `briefs/2026-11-22-p02-mesclar-e-flags.md` · disparado 2026-11-22 16:1x.

Dois pedidos do Marlon:

1. **Mesclar**: quando ele renomeia uma pessoa para um nome que já existe, a API
   devolve 409 e a UI oferece juntar as duas, mostrando 6 miniaturas de cada lado.
   `POST /api/people/{pid}/merge {into}` move os rostos, apaga a origem e refaz
   `person_stats`. Teste obrigatório em **cópia** do banco (`data/test_merge.db`,
   porta 8014) — o banco real não é tocado.
2. **Flags**: `tags(id,name,color)` e `person_tag(person_id,tag_id)` já existem no
   banco, vazias e sem uso. Viram flags por pessoa: nome e cor editáveis, fundo da
   linha tingido com a cor, filtro "esconder marcadas". Uso real: marcar os grupos
   que a detecção juntou errado para não gastar tempo com eles.

Sem schema novo, sem cluster, sem tocar no acervo.

---

## T-013 · P-03: G3-c — dashicons fora do front (release 1.3.7) 🟡 publicado, efeito ainda não medido

**Medido antes:** a home tinha 31 `<link>` de CSS no HTML, mas só **6** são
baixados — os outros 25 estão dentro de comentários (sobra do minify do WPFC).
Total real: **494.284 B raw / 94.357 B gzip**. O maior bundle
(`wpfc-minified/lywa7anf/27xaf.css`, 87.052 B) era **76% dashicons**: 350 regras
`.dashicons-*:before` e 42.793 B de fonte em base64. Na página entregue: 0
classes `.dashicons-*`, 0 `#wpadminbar`.

**Feito:** gate `jhw_should_keep_dashicons()` (admin e logado mantêm, filtro
`jhw_keep_dashicons` como escape), dequeue em `wp_enqueue_scripts` 9999 e
`wp_print_styles` 9999. Release **1.3.7**, deploy exit 0, 11 arquivos conferidos,
purge aplicado.

**Não funcionou como esperado — e o motivo importa:** a home carrega o **editor
do WordPress no front** (textarea do Forminator com editor visual), que
enfileira `dashicons` **depois** do tema e imprime em `print_late_styles`. O
dequeue não alcança enfileiramento tardio. As subpáginas, que não têm editor,
ficaram com 0 dashicons. O bundle continua com os 59 KB porque o cache de
minificação do WPFC não foi regenerado — o `jhw-purge.php` publicado limpa só o
HTML.

**Próximo:** T-014.

---

## T-014 · P-03: o editor do WordPress no front custa ~136 KB gzip 🟡 (diagnóstico em curso)

**Medido na home (servida, 1.3.7):** **1.759.286 B de JS / 560.361 B gzip** em 35
scripts únicos — seis vezes o CSS (94 KB gzip). O que se destaca:

| item | raw | gzip | observação |
|---|---|---|---|
| GTM (`js?id=GT-TBVGGKRR`) | 545.320 | 181.289 | container grande; decisão da cliente |
| `tinymce.min.js` | 365.570 | 124.604 | **só para a caixa de mensagem do formulário** |
| editor.min + quicktags + wplink + core.min | 55.658 | 16.639 | idem |
| `editor.min.css` + `dashicons.min.css` | — | ~35.000 | idem |

O editor está no HTML por causa do campo `textarea-1` do formulário `168`
(`class="wp-core-ui wp-editor-wrap tmce-active"`). Só o editor responde por
**~136 KB gzip** por visita.

**Brief T-014 (duas partes):** (1) publicar o `jhw-purge.php` que limpa HTML **e**
minificado — o publicado só limpa HTML; (2) diagnóstico com arquivo e linha de
quem liga o editor, onde a opção é gravada, se há filtro oficial e quanto sai.
**Proibido mexer em configuração de formulário/conteúdo** — desligar o editor
muda o que o visitante vê e depende de aprovação (Q-11).

---

**Resultado (verificado por mim):** o purge melhorado passou a regenerar os bundles
(`27xaf` → `2o3dz`/`2o3dx`/`2o7ec`) — funciona. Mas o dashicons **continua** no
bundle: o editor imprime `editor-buttons`/`dashicons` dentro do próprio markup
(`class-wp-editor.php:213`) e enfileira o resto no footer (`:330`); nenhum dequeue
alcança. E a regeneração **engordou** o site: HTML de 183.203 → **189.427 B** na
home (+6,2 KB de CSS inline em todas as páginas) e CSS externo 94.357 → 95.429 gz.
Diagnóstico do executor correto; a estimativa dele de "201 KB gzip" vale só para a
variante que carrega TinyMCE (render dinâmico). Na página **servida** (html-active,
sem TinyMCE) o pacote do editor é ~22 KB gz de JS + 35,6 KB do dashicons ≈ **58 KB
gzip**. Ordem de grandeza: a decisão da Q-11 vale ~58 KB, não 201.

---

---

## T-015 · P-03: desligar o editor visual do formulário + `.gitignore` ✅ concluída (2026-11-20)

**Brief:** `briefs/2026-11-20-p03-t015-editor-off.md` · **Origem:**
`%TEMP%/opencode/brief-2026-11-20-t015-editor-off.md` · **Agente:** build ·
**Disparo:** 2026-11-20 21:56, exit 0.

Aprovado pelo Marlon na rodada de respostas ("ok, detalhe pequeno, mas pode fazer"
e "Q-08, sim!"). Escopo duplo, mas ambos no mesmo repo e sem código de tema:

1. desmarcar **Rich-Text editor** no campo `textarea-1` do form **168**;
2. `.gitignore` com `logs/`.

**Linha de base a bater:** home 189.427 B; 6 folhas de CSS / 95.429 B gzip;
`dashicons` presente no bundle; `quicktags`, `wplink`, `editor.min.css` carregados;
`wp-editor-wrap` no markup.

**Critério de aceite:** HTML sem `wp-editor-wrap`/`quicktags-toolbar`; nenhum dos
quatro recursos do editor; contador de 120 palavras funcionando; sem entrada de
teste; `.gitignore` aplicado; reversão em uma frase.

**Não delegado ao executor:** desligar o Brand Agent da Clarity (é painel da
cliente) e podar GTM (não há o que podar — um destino GA4 só).

### Medição do gestor (2026-11-20, URL pública, UA Chrome/122, sem cache-bust)

Método: `gzip` local nível 9; HTML servido, 2 leituras idênticas (178.559 B duas
vezes). "Antes" = HTML servido às **10:33** (snapshot `home-now.html`), não às 21h:
entre os dois pontos houve o purge do T-014 e o desligamento do editor, então o
delta **não é atribuível só ao editor**.

| | antes (10:33) | agora | delta |
|---|---|---|---|
| HTML | 189.427 B / 36.965 gz | 178.559 B / 33.987 gz | −10.868 B |
| CSS | 6 folhas · 420.611 / 53.189 gz | 5 folhas · 420.591 / 53.161 gz | −20 B |
| JS | 32 scripts · 1.375.362 / 428.160 gz | 21 scripts · 1.275.704 / 393.832 gz | −99.658 B / **−34.328 gz** |
| **página** | **518.314 gz** | **480.980 gz** | **−37.334 gz (−7,2%)** |

Prova no markup: `wp-editor-wrap`, `quicktags-toolbar`, `dashicons`, `wplink`,
`editor.min.css` → **0 ocorrências** (antes: 1 cada). O textarea passou de
`forminator-wp-editor-required wp-editor-area` para `forminator-textarea` puro.
Saíram 12 scripts do core (`quicktags`, `wplink`, `core.min`, `common.min`,
`dom-ready`, `autocomplete`, `a11y`, `i18n`, `hoverIntent`, `menu`, `utils` e o
bundle `2o3dz.js`).

**Correção de número meu:** eu havia estimado ~58 KB gzip de ganho e citado
1.759.286 B de JS no "antes". As duas coisas estavam erradas: aquele total era da
variante `tmce-active` servida a outro UA, não da página que o visitante recebe.
O ganho real, medido no mesmo método dos dois lados, é **~37 KB gzip/visita e 12
requisições a menos**.

**Achado do executor (premissa desatualizada):** às 22:11 o campo 168 **já estava**
com `editor-type:false`. Quem desligou não ficou documentado — o disparo das 21:55
morreu com `exit=1` e 75 B de log. O executor não editou às cegas: detectou,
purgou e comprovou no HTML público. **Atribuição honesta: o crédito do desligamento
é indeterminado; o crédito da prova é dele.**

**Regressão observada (não bloqueante):** o textarea perdeu `required="true"`,
`do-validate` e `aria-required`. O `*` do rótulo continua. Validação server-side do
Forminator **não testada** pelo executor (admitido no relatório) nem por mim.

**Commits no repo do site:** `3a4cbad` (form + `.gitignore`), `30e6efd` (§26),
`f7ffce7` (§32). Árvore limpa.

---

## T-020 · Governança do conjunto — fechar a deriva de estado

| Campo | Valor |
|---|---|
| Status | 🟡 em andamento — aberta pelo GERENTE em 2026-11-23 |
| Dono | GERENTE (`DOCS/08-GERENTE/`) |
| Origem | `08-GERENTE/AUDITORIA-2026-11-23.md` §7 |
| Escopo | registro, gate e dono. **Nenhuma linha de código de projeto.** |
| Pendente de | `Q-023` (gate), `Q-024` (donos), `Q-025` (depoimentos) |

**Critério de aceite:** (1) os quatro blocos de `02-PROJETOS.md` com data de 23/11 e
sem "a criar"; (2) `T-P03-016`…`T-P03-020` registradas na fila, ordem por projeto;
(3) `scripts/release.json` do P-03 gravado depois da publicação 1.3.8; (4) a próxima
tarefa do P-03 termina sem compactação intermediária.

**Por que existe:** medido em 23/11 — cinco briefs do P-03 executados fora da fila,
três documentos com estados incompatíveis, API do P-01 parada com o painel dizendo
`200`. Nada disso é código; tudo isso é registro.

### Registro retroativo · T-P03-016 … T-P03-024

Entram na fila pelo que foi medido, não pelo que foi narrado:

| Tarefa | Brief | Estado em 23/11 | Prova |
|---|---|---|---|
| T-P03-016 | `p03-t016-footer-cookies` | 🔵 absorvida pela 018 | link de cookies só apareceu com `cbdf3d0` |
| T-P03-017 | `p03-t017-rodape-origem-e-cache` | 🟢 feita | commit `e59874a`; purge do WPFC via PHP medido |
| T-P03-018 | `p03-t018-resolver-override-rodape` | 🟢 feita e publicada | commit `cbdf3d0`; HTML servido 1.3.8 com o link |
| T-P03-019 | `p03-t019-limpar-php-diagnostico` | 🟢 feita | `GET /jhw-purge.php` e `/jhw-check.php` → **404** |
| T-P03-020 | `p03-t020-paginas-servico-rascunho` | 🟢 feita e verificada pelo gestor | 4 páginas `draft` no WP (IDs 226–229, slugs exatos); as 4 URLs → **404**; home intacta (178.614 B, rodapé `d0a615c449b2`, 1.3.8) |
| T-P03-021 | `p03-t021-webp-home` | 🟢 feita e verificada | 7 fotos trocadas por WebP dedicado; home serve **7/7 `.webp`**, 0 referências a `.jpg`; peso real baixado **864,4 KB → 661,7 KB (−23,5%)**; home 178.621 B, 3 leituras idênticas (md5 `f5439f0a2a1d`) |
| T-P03-022 | `p03-t022-publicar-servicos` | 🟢 **concluída na prática pela T-P03-024** (24/11): as 4 páginas, o submenu e os 4 cartões estão no ar e medidos na URL pública; a escala do H1 entrou na versão 1.3.9 · **CSS candidato validado em navegador** | publicar as 4 páginas, ligar os 4 cartões da home, submenu, Yoast, escala do H1. **Medido:** páginas internas já herdam Marcellus/Inter/`#EDE3D6`; o defeito real é `h1` 31,67 px **menor que** `h2` 40,44 px. **Causa:** `.has-large-font-size{font-size:…!important}` do core vence regra sem `!important`. **Escala da home medida:** display do hero **74,88 px** @1440. **Candidato validado** (`body.page .wp-block-post-title.has-large-font-size`, 6 propriedades com `!important`, `clamp(2.5rem,1.6rem+2.8vw,4rem)`, injetado por CDP em `/obrigado/`): `h1` **64 px/67,84** @1440 e **40 px** @390; `h2` segue 40,8/25,05; corpo intacto 20/32 e **66 chars/linha** (leitura boa — não mexer); `scrollWidth == innerWidth`, **overflow 0** nos dois. Escala resultante 74,88 → 64 → 40,8 → 20. Ver E-022 e E-023 |
| T-P03-023 | `p03-t023-banner-cookies-paleta` | 🟡 brief emitido, bloqueado por aprovação | botão "Aceito" do Complianz em `#3B29FF` (azul elétrico, medido `rgb(59,41,255)`), fora da paleta bege/preto. **Banner medido na home** (@1440): `500×313`, `position:fixed`, canto inferior esquerdo, fundo `rgb(220,216,200)`, `z-index 99999` — **não** cobre o conteúdo (o `h1` do hero fica em `top 316`, livre). O defeito é só a cor. Cor proposta **validada em navegador** (`probe11`, @1440): override de 4 vars em `:root` → botão `rgb(26,26,26)` com texto `rgb(237,227,214)`, geometria intacta `149×45` / banner `500×313` / `fixed` / `scrollWidth 1440 = innerWidth 1440`. Contraste **13,72:1** (era 7,13:1). `--cmplz_hyperlink_color` fica fora: o link do banner já é oliva `rgb(79,91,67)` por regra mais específica. Brief: `briefs/2026-11-23-p03-t023-paleta-banner-cookies.md`. Mudança visível em todo o site → exige "pode" do Marlon (Q-032) |
| T-P03-024 | `p03-t024-publicar-deploy-real` | 🟢 **concluída e verificada pelo gestor** (24/11) | tema **1.3.9** no ar; 5 URLs **200**; 4 páginas com conteúdo real; submenu SOLUÇÕES com **4 filhos**; 4 cartões ligados. Medição no fim desta seção. A 023 **não** entrou neste deploy |

**Verificação do T-P03-020 (feita por mim, via MCP e HTTP, não pelo relatório):**
`wp_get_page` 226–229 → `status: draft`, slugs `consultoria`, `projetos`,
`gestao-de-obra`, `chave-na-mao`, títulos corretos. `GET` das quatro URLs públicas →
404. Home → 200, 178.614 bytes, duas leituras idênticas, rodapé 3.478 caracteres com
`d0a615c449b2`, `style.css?ver=1.3.8`. Nada ligado ao menu.

**Achados que condicionam a publicação (não são do escopo do 020):**
1. O CSS `.jhw-*` é escopado em `.jhw-home-v2`. As páginas internas **não herdam**
   o desenho da home — publicar antes de uma passada de estilo entrega página
   genérica. Tarefa de estilo é pré-requisito da publicação.
2. O submenu SOLUÇÕES é o `wp_navigation` **6**; ligar os 4 itens é passo de
   publicação, não de criação.
3. Rascunhos legados com slug vazio: 164 `CONSULTORIA`, 165 `GESTÃO DE OBRA`,
   166 `PROJETOS` (0 byte) e 96 `Quem Somos`. Invisíveis, não colidem. O "154" que o
   executor descreveu como página inteira **não** é página: `wp_get_page(154)` → null
   e `wp_get_post(154)` → ID inválido. Tratar como não confirmado.

**Verificação do T-P03-024 (feita por mim na URL pública em 24/11, UA Chrome/131,
sem query string, duas leituras por URL — não pelo relatório do executor):**

`/` **200**, **181.139 B**, md5 `8f73a2c0da296d23f9d7cee9eb34a416` nas duas leituras;
`style.css?ver=1.3.9` = `themes/jessica-haguiwara-child/style.css`, arquivo de
**52.632 B** com `Version: 1.3.9`, `Template: extendable` e a seção `PAGINAS INTERNAS`
(14 regras `.jhw-service`). O `themes/extendable/style.css?ver=1.3.9` é o tema **pai**
enfileirado com a versão do filho — não é release errado.
`/consultoria/` **200** 149.338 B · `/projetos/` **200** 149.167 B ·
`/gestao-de-obra/` **200** 149.132 B · `/chave-na-mao/` **200** 149.054 B —
md5 idêntico em duas leituras **por página**, `page-id` 226–229 (os mesmos rascunhos
de 23/11), `h1` com `has-large-font-size` (alvo do CSS do 022) e **157–177 palavras**
dentro do `<main>`.
Submenu SOLUÇÕES: **1** bloco `wp-block-navigation-submenu` dentro do `<nav>`,
**2.448 B** de markup, com **4 links de página** — o 5º `<a>` do bloco é o próprio
SOLUÇÕES em `#solucoes`, e a âncora existe no HTML.
Cartões: **4** `<article class="jhw-service">`, **4** links de título apontando para
as páginas certas, nenhum cartão órfão. Rodapé segue **3.478 caracteres**, com
`/privacy-policy/` e `/politica-de-cookies/` em caminho relativo.
Home **178.621 → 181.139 B** (+2.518), coerente com os 2.448 B de submenu novo.
**A 023 não entrou:** o override `rgb(26,26,26)` do botão do banner não está no CSS
servido — o botão segue azul, como estava.

Ressalva de copy (não é falha técnica): o rótulo do submenu é "Projeto" (singular),
o cartão diz "Projetos" e o `h1` é "Projeto de arquitetura e interiores".

---

## T-P05-001 · P-05: coletor do Painel Hermes — kickoff do projeto 🟡

**Brief:** `briefs/2026-11-24-p05-t001-kickoff-coletor.md`
**Dir:** `C:\MarlonScripts\5-Painel-Hermes` (criado 2026-11-24, vazio, antes do despacho)
**Executor:** OpenCode via `scripts/oc-brief.ps1`
**Gestor:** perfil `p05-gestor` — caderno em `DOCS/P-05-Painel-Hermes/GESTOR.md`

**Escopo:** repo do zero (`git init`, `AGENTS.md` + `DOCS/00`…`05`, `README.md`) e
**só o coletor**. Sem UI, sem agendador instalado, sem remote (GitHub bloqueado por
`Q-034`).

**O coletor entrega:** Hermes vivo/funcional (processo + heartbeat do `state.db`),
tokens/dia por perfil e por sessão do OpenCode lidos em modo somente leitura, cota do
OpenCode Go por três caminhos (CLI → endpoint com UA de navegador → `indisponivel`
com motivo), série append-only em `stats.jsonl`, saída 0 mesmo com cota indisponível.

**Critério de aceite (medido pelo gestor, não pelo relatório):** duas execuções
consecutivas saem 0; a segunda acrescenta **exatamente 1** linha na série; ≥2
registros reais; cota `indisponivel` ou número com fonte provada; `git grep -iE
"sk-|token|secret|password"` limpo; primeiro commit com autoria `P05-EXECUTOR`.

**Não autorizado:** cron do Hermes, serviço do Windows, porta pública, `git push`,
mexer em outro projeto, inventar cota.

**Resolução de escopo desta entrega:** `relatorio-semanal.py` e a UI são tarefas
posteriores (backlog do repo). O brief lista os dois na seção "Cadência" mas fecha o
escopo em "o coletor e nada além dele" — vale o escopo.

**Estado:** 🟢 **concluída em 2026-11-24 21:27**, medida pelo gestor na fonte.
Três commits `P05-EXECUTOR`, árvore limpa, 0 remotes. `python scripts/coletor.py`
duas vezes: exit 0 nas duas, série 5→6→7 (+1 por execução); de outro cwd também
(+1, exit 0). Contagem independente em `mode=ro` bate com o JSON: 336/31/7/2 sessões
por perfil, `conversa` sem `state.db` sai como `null`, `opencode.session_v2=193`.
Cota `indisponivel` com motivo técnico e sem percentual. `git grep` de segredo sem
valor real. Nenhuma tarefa agendada no Windows.

**Descoberta registrada em `DOCS/03` do projeto:** `opencode stats` mede token, não
cota; a cota vem de `opencode api GET /api/experimental/usage/limits`, hoje com
`data:null` porque nenhum workspace do OpenCode Console está conectado. A chave
`oc_…` do banco dá 401 — `indisponivel` é o dado correto, não falha do coletor.

**Próxima:** `T-P05-002` (UI `127.0.0.1:8787`) — brief próprio.

---

## T-P03-025 · título das páginas internas atrás do header fixo 🟡

**Origem:** print do Marlon em 24/11 21:05 (**/gestao-de-obra/**) + brief do Gerente
`briefs/2026-11-24-p03-t025-titulo-atras-do-header.md`.
**Dono:** GESTOR-P03 decide e mede; OpenCode escreve.
**Escopo único:** espaçamento vertical do topo das páginas internas — **uma** regra na
seção 11 de `jessica-haguiwara-child/style.css`. Nada de copy, home, menu, plugins.

**Critério de aceite:** (1) `node scripts/validate-theme.mjs` limpo;
(2) `node scripts/deploy-theme.mjs --dry-run` exit 0, divergentes explicados;
(3) publicado com `style.css?ver=1.3.10` e a regra nova presente no CSS **servido**;
(4) prova visual headless de `/gestao-de-obra/` em 1440×900 e 390×844 com
`deviceScaleFactor` **1**, `<h1>` inteiro abaixo do header com ≥16 px de folga;
(5) as 5 URLs em 200 com bytes registrados antes/depois;
(6) home inalterada (rodapé 3.498 B UTF-8, md5 `d0a615c449b20f2f3fb403056b5a1884`);
(7) rollback escrito: versão 1.3.9 + commit `a2394e0`.

**Medição de abertura (gestor, 24/11 22:xx, Chrome/131, sem query string, 2 leituras):**
`/` 200 **181.138 B**; `/consultoria/` 149.338; `/projetos/` 149.167;
`/gestao-de-obra/` 149.132; `/chave-na-mao/` 149.054 — duas leituras idênticas.
Header `position: fixed`, **80 px** @1440 e **64 px** @390. Primeiro grupo do `<main>`
com `padding-top` **32 px** @1440 e **24 px** @390 (o brief dizia 32 no mobile: é 24).
`<h1>` em `top 32` @1440 → **48 px cobertos**; `top 24` @390 → **40 px cobertos**.
Fonte do `h1`: 64 px @1440 / 40 px @390 (Marcellus).

**Achado que condiciona o ajuste:** a home **também** é `body.page` (classe
`page-template-no-title`, `page-id-38`); as internas usam `page-template-page-with-title`.
Regra em `body.page` + `<main>` sem escopo acerta a home — o escopo tem de ser
`page-template-page-with-title` ou `:has(.wp-block-post-title)`.

**Nota de medição:** a home carrega `<!-- WP Fastest Cache file was created in … -->`
no fim do HTML; esse comentário muda a cada geração de cache e sozinho explica a
diferença de md5/tamanho entre medições (181.138 B agora × 181.139 B na T-P03-024).
O md5 normalizado (comentário removido) é a base de comparação: `/` =
`94cec06703284bafe92293375f640b53`.


