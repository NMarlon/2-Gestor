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
**Gestor:** perfil `p05-painel` (era `p05-gestor`; renomeado em 24/11, commit `587f8f8`) — caderno em `DOCS/P-05-Painel-Hermes/GESTOR.md`

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

**Próxima:** `T-P05-002` (agendador do Windows) — a UI virou `T-P05-003`.

---

## T-P05-002 · P-05: agendador do Windows — a série se preenche sozinha 🟢

**Brief:** `briefs/2026-11-25-p05-t002-agendador-serie.md`
**Dir:** `C:\MarlonScripts\5-Painel-Hermes`
**Executor:** OpenCode via `scripts/oc-brief.ps1`
**Gestor:** perfil `painel-p05` (M-010, 25/11) — caderno em `DOCS/P-05-Painel-Hermes/GESTOR.md`
**Ordem:** M-005 do Gerente (`DOCS/08-GERENTE/PARA-GESTORES.md`), em nome do Marlon —
é o pedido escrito que o `AGENTS.md` do projeto exigia para instalar o agendador.

**Escopo:** só o agendador. `scripts/instalar-agendador.ps1` registra de verdade a
coleta: python **absoluto** + `-WorkingDirectory` na raiz do repo, intervalo validado
em **5 a 15 min**, guarda `-IUnderstand`, `-Remover` e o desfazer escrito nos docs do
projeto. A UI saiu deste escopo e virou `T-P05-003`.

**Não autorizado:** serviço do Windows, cron do Hermes, porta pública, `git push`,
tocar em `scripts/coletor.py` ou em `dados/`, inventar cota, segredo em log ou commit.

**Critério de aceite (medido pelo gestor):** sem `-IUnderstand` sai 1 e não registra;
`-IntervaloMinutos 3` sai 2; `-IUnderstand` sai 0 e a tarefa aparece no `schtasks`;
`-Remover` desregistra; e **uma amostra nova** entra em `dados/stats.jsonl` sem o
gestor rodar o coletor à mão.

**Estado:** 🟢 **concluída em 2026-11-25 01:26**, medida na fonte.
Commit `e5046f4` (`P05-EXECUTOR <p05@2gestor.local>`, 8 arquivos, +397/−73), árvore
limpa, 0 remotes; `scripts/coletor.py` não foi tocado.
Tarefa **`\PainelHermes-Coletor`**: `Status: Pronto`, `Modo de Logon: Interativo
apenas`, `Executar como Usuário: Marlon`, ação
`…\Python311\python.exe "…\scripts\coletor.py"`, `Iniciar em:
C:\MarlonScripts\5-Painel-Hermes`, repetição **15 min**, `Último resultado: 0`,
última execução `01:25:46`, próxima `01:40:46`.
**Prova da série:** 11 → **12 linhas**; a 12ª (`2026-11-25T01:25:49-03:00`,
`dur_ms=1562`, `coletor 1.0.0 (python 3.11.9)`) foi gravada **3 s** depois do disparo
da tarefa, sem execução manual. E a **repetição** foi medida: às 01:40:50 entrou a
amostra 13, no horário previsto `01:40:46` — 15 min depois, sozinha.
Sequência medida pelo gestor: exit 1 (sem `-IUnderstand`), exit 2 (intervalo 3),
exit 0 (instalar, `MODO=INTERATIVO`), exit 0 (remover a sonda
`PainelHermes-SONDA-GESTOR` → `schtasks` passa a não achar); tarefa real intacta
depois do teste de remoção.

**Limitação registrada (não é falha):** S4U foi recusado com “Acesso negado” — a sessão
não é elevada. Em modo interativo a coleta **não roda com o usuário deslogado**; para
isso é preciso registrar elevado com `-LogonType S4U`. Efeito na UI: última coleta com
mais de ~20 min significa tarefa parada ou máquina deslogada, não ausência de uso.

**Pendência menor (resolvida na T-P05-003):** `DOCS/02-ARQUITETURA.md` do projeto ainda
listava os perfis com os nomes velhos (`p03-gestor`, `p05-gestor`, `conversa`) — hoje são
`p03-jessica` e `p05-painel`, e `conversa` existe no diretório de perfis, mas sem
`state.db` e sem papel neste workspace (corrigido em 25/11 02:04; ver `E-029`).

**Próxima:** `T-P05-003` (UI local `http://127.0.0.1:8787`, só lê a série) — entregue em
25/11 02:04; ver bloco abaixo.

---

## T-P05-003 · P-05: UI local + perfis da arquitetura + export diário da série 🟢

**Brief:** `briefs/2026-11-25-p05-t003-ui-local.md`
**Dir:** `C:\MarlonScripts\5-Painel-Hermes`
**Executor:** OpenCode via `scripts/oc-brief.ps1`
**Gestor:** perfil `painel-p05` (M-010, 25/11) — caderno em `DOCS/P-05-Painel-Hermes/GESTOR.md`
**Ordem:** M-007 do Gerente (`DOCS/08-GERENTE/PARA-GESTORES.md`) — autoriza a UI em
`127.0.0.1:8787`, a correção da lista de perfis em `DOCS/02-ARQUITETURA.md` do projeto
e o export diário de `dados/stats.jsonl` para `backups/` com a data no nome.

**Escopo:** `scripts/painel.py` (Python stdlib, escuta **só** em `127.0.0.1:8787`, lê
**só** `dados/stats.jsonl`, dashboard escuro com polling); correção dos nomes de perfil
no doc de arquitetura; export diário da série para `backups/` executado pelo coletor já
agendado (sem agendador novo, sem cron do Hermes).

**Não autorizado:** S4U, serviço do Windows, agendador novo, porta pública, `git push`,
`pip install`, UI lendo banco alheio, número de cota inventado, segredo em log/print/commit.

**Critério de aceite (medido pelo gestor):** `curl` em `http://127.0.0.1:8787/` devolve
**HTTP 200** e o número de amostras/última coleta bate com `wc -l`/`tail -1` de
`dados/stats.jsonl`; `netstat` mostra **127.0.0.1:8787**, nunca `0.0.0.0:8787`; backup do
dia existe em `backups/stats-AAAA-MM-DD.jsonl` e é prefixo exato da série; doc de perfis
corrigido; commit `P05-EXECUTOR` por caminho explícito.

**Estado:** 🟢 entregue em 2026-11-25 02:04 — commit `3ce9186` (`P05-EXECUTOR`), medido
pelo gestor às 02:12: `curl` em `/` e `/api/stats` **200**, `/nao-existe` 404, `POST` 405;
API `amostras=17` = `wc -l` e última `02:10:50` = `tail -1`; `netstat` só
`127.0.0.1:8787` (LAN `192.168.0.17:8787` e `[::1]:8787` recusam, exit 7); backup
`backups/stats-2026-11-25.jsonl` com 15 linhas, sha256 idêntico ao `head -15` da série;
tarefa agendada `PainelHermes-Coletor` rodou 02:10:47 com `LastTaskResult=0` e a UI
refletiu a 17ª amostra sem reiniciar. Detalhe e limites no caderno do gestor.

---

## T-P05-004 · P-05: gráficos das três janelas + cota oficial `INDISPONIVEL` ✅

**Brief:** `briefs/2026-11-25-p05-t004-graficos-tres-janelas.md`
**Dir:** `C:\MarlonScripts\5-Painel-Hermes`
**Executor:** OpenCode via `scripts/oc-brief.ps1`
**Gestor:** perfil `painel-p05` (M-010, 25/11) — caderno em `DOCS/P-05-Painel-Hermes/GESTOR.md`
**Ordem:** M-009 do Gerente (`DOCS/08-GERENTE/PARA-GESTORES.md`), em nome do Marlon,
prazo 25/11 — gráficos das janelas **5 h, 7 d e 30 d** com tokens **medidos localmente**;
cartão oficial do provedor **`INDISPONIVEL`** com motivo e ação; cartão do plano
US$ 10/mês sem inventar preço nem percentual.

**Escopo:** `scripts/coletor.py` (grava `dados/grafico.json` derivado + campos
`total`/`total_por_perfil` na amostra), `scripts/painel.py` (três SVG inline, dois
cartões novos, responsivo 1440/390), `.gitignore` (`dados/*.json`), docs do projeto
(`02-ARQUITETURA`, `04-TAREFAS` — backlog `T-P05-004` renumerado para `T-P05-005` — e
`05-BACKLOG`).

**Não autorizado:** API externa/credencial do Marlon, preço ou câmbio inventado,
percentual de cota estimado, dependência nova, CDN, porta/serviço/agendador novo,
`git push`, segredo em log/print/commit.

**Critério de aceite (medido pelo gestor):** `curl /` **200** com 3 SVGs
(`grafico-5h`, `grafico-7d`, `grafico-30d`), `INDISPONIVEL` e `US$ 10` presentes;
`POST` 405; `/scripts/painel.py` 404; totais de 30 d do `grafico.json` batem com
consulta independente nos bancos; print headless em **1440×900** e **390×844** sem
corte; commit `P05-EXECUTOR` por caminho explícito.

**Estado:** ✅ medida em 2026-11-25. Entrega `94b87f7` (`P05-EXECUTOR`, 08:47:47),
árvore limpa. Medição: `curl /` **200** (27.940 B) com 1× cada `grafico-5h`/`grafico-7d`/
`grafico-30d`, 1× `INDISPONIVEL`, 1× `US$ 10/mês`; `POST` **405**; `/scripts/painel.py`
**404**; `/api/stats` 200 (46 amostras); 0 recurso externo, 0 `fetch(`. CDP Edge:
1440×900 → 3 SVGs 1318×458, 31 textos de 27 px, overflow 0; 390×844 → 3 SVGs 340×118,
textos de 13 px, overflow 0. Números de 5 h batem com o delta das amostras (tolerância 0);
7 d/30 d diferem −0,87 % por duas sessões abertas no instante da amostra (fato medido,
mecanismo não confirmado). Sobraram **3 defeitos de rótulo em 390** → `T-P05-006`.

---

## T-P05-006 · P-05: rótulos de eixo sem colisão e sem corte em 390 px ✅

**Origem:** medição do gestor em 2026-11-25 sobre `94b87f7` (T-P05-004).
**Brief:** `briefs/2026-11-25-p05-t006-rotulos-eixo-390.md`, despachado 08:58.
**Escopo único:** (1) `grafico-5h` — "0" do eixo Y cruza "04:55" em 390 (5×6 px);
(2) `grafico-30d` — "25/11" 2 px além da borda direita do SVG em 390; (3)
`janelas.5h.inicio` deve ser o instante da amostra base (`03:55:49`, não `03:49:17`).
Nada mais muda; 1440 fica idêntico.

**Critério de aceite (medido pelo gestor):** em 390, CDP com **0** sobreposições de texto
e **0** textos fora do SVG; em 1440 os três SVGs continuam 1318×458 com 0 overflow;
`janelas.5h.inicio` = `coletado_em` da amostra base e soma dos buckets = totais da janela;
`py_compile` exit 0; `curl /` 200; commit `P05-EXECUTOR` por caminho explícito.

**Estado:** ✅ medida em 2026-11-25 09:07 sobre `b286467` (árvore limpa). CDP: em
**390×844** os três SVGs com **0 sobreposições de texto** (antes: 1 par de 5×6 px em
`grafico-5h`) e **0 textos fora do SVG** (antes: "25/11" 2 px além da borda em
`grafico-30d`); 28 textos de 13 px, `overflow` vazio. Em **1440×900** idêntico ao
aprovado: 3 SVGs 1318×458, 27 px, 0 overflow, 0 fora. `janelas.5h.inicio` passou a ser
a amostra-base (`05:10:49`) — mas essa correção **expôs** que a janela "5 h" cobre
3 h 50 (bug de corte por contagem) → `T-P05-007`.
Dois commits: `2b1b632` (escopo do brief) e `b286467`, este rotulado pelo executor como
`T-P05-005` para o ajuste do rótulo do topo — número já reservado no backlog ao
`relatorio-semanal.py`; o conteúdo está dentro do escopo da 006, a etiqueta é que saiu
trocada (registrado, não vale reescrever histórico).

---

## T-P05-007 · P-05: janela 5 h real, zero no eixo Y e fim dos cortes ✅

**Origem:** medição do gestor em 2026-11-25 sobre `b286467` (quatro defeitos, todos com
comando).
1. Eixo Y sem o rótulo `0` em todas as larguras (`painel.py:355-356` apagou o zero para
   resolver a colisão em 390 — workaround, não conserto).
2. Janela "5 h" com **3 h 50**: `coletor.py:833-836` corta para os últimos 20 *pares*
   de amostra; com coletas extras o span encolhe e um par descartado com token > 0
   sumiria do total (latente hoje, zero por sorte).
3. Em 1440 a `.rolagem` da tabela por perfil estoura **117 px** (409 contra 292) — único
   elemento cortado da página.
4. Cartão da cota com dump cru (`HTTP 401 … data=null`).

**Brief:** `briefs/2026-11-25-p05-t007-janela-5h-eixo-zero-e-cortes.md`, despachado
09:16.

**Critério de aceite (medido pelo gestor):** `len(fluxo_5h)==20`, span ≥ 4 h 45,
soma dos buckets = janela; 1440 com **0** elementos cortados; 390 com 0 sobreposições e
o `0` presente; `curl /` 200; `py_compile` exit 0; servidor reiniciado com pid novo;
commit `P05-EXECUTOR`.

**Estado:** ✅ medida em 2026-11-25 09:33 sobre `67c4bb2` (`P05-EXECUTOR`, árvore
limpa, servidor pid 53564). Dados (`dados/grafico.json`, amostra 09:26:01): **20
buckets**, `04:30 → 09:15`, `inicio=04:25:49` (12 s antes do corte de 5 h) e
`fim=09:26:01` → **span 5,00 h** (antes: 3,84 h); soma dos buckets = janela em
input/output/cache (`2.276.832 / 212.022 / 22.226.048`); 14 fatias zeradas (madrugada
sem uso). Eixo Y: `<text>0</text>` presente nos três SVGs (1 cada) — antes não existia.
Em 1440: **0 elementos cortados** (antes: `.rolagem` +117 px), 3 SVGs 1318×458, 0
sobreposições, 0 textos fora. Em 390: 31 textos de 13 px, 0 sobreposições, 0 fora,
0 cortados. `curl /` 200 (28.653 B); `py_compile` exit 0. Cota: selo
`OFICIAL · INDISPONIVEL`, motivo em frase e detalhe técnico em `<details>` fechado —
sem chamada ao provedor (0 `src`/`href` externo, 1 `fetch('/api/stats')` de polling
local). Revisão visual independente: **aceitável com ressalva** — sobra a grade de 1440
(linha 2 com `c-opencode` sozinho, 1.026 px vazios) → `T-P05-008`.

---

## T-P05-008 · P-05: equilíbrio da grade em 1440 ✅

**Origem:** medição CDP do gestor em 2026-11-25 (1440×900, container 1.352 px, 4
colunas): `c-opencode` sozinho na segunda linha (1.026 px vazios) e `c-plano` +
`c-oficial` com 700 px vazios na linha seguinte.

**Brief:** `briefs/2026-11-25-p05-t008-grade-1440.md`, despachado 09:36. Escopo de uma
regra: `#c-opencode { grid-column: span 2 }` no `@media (min-width: 1200px)`; mobile
intocado.

**Critério de aceite:** em 1440 `c-opencode` ≥ 650 px e `c-plano`/`c-oficial` na mesma
`y`; em 390 geometria preservada (0 sobreposições, 0 fora, 0 cortados); `curl` 200;
`py_compile` 0; servidor reiniciado; commit `T-P05-008`.

**Estado:** ✅ medido pelo gestor em 2026-11-25 10:36, com
`python scripts/medir-cdp.py http://127.0.0.1:8787/ 1440 900` (1 navegador):
`main.grade` = `326px 326px 326px 326px`, gap 16 px; `#c-opencode` **668 px** de largura
= 2 colunas + gap (antes: 326 px sozinho na linha); `#c-plano` e `#c-oficial` na **mesma
`y` = 491**, ambos 326×352; `scrollWidth` 1.425 ≤ 1.440 (sem overflow horizontal);
0 filhos fora do cartão oficial. Print:
`C:\Users\Marlon\AppData\Local\hermes\profiles\painel-p05\cache\scratch\p05-1440-t008-t010.png`.

---

## T-P05-009 · P-05: autostart do painel ✅ (com correção em T-P05-011)

**Origem:** item 3 da M-015 do Gerente — o painel tem de voltar sozinho no boot e
depois de uma queda, sem navegador e sem console.

**Brief:** `briefs/2026-11-25-p05-t009-autostart-painel.md`, despachado 10:33.
Escopo: supervisor `scripts/garantir_painel.py` (idempotente: se `GET /` responde 200,
sai 0 sem subir segundo processo; senão trava, sobe `pythonw.exe scripts/painel.py`
destacado e confirma em até 20 s) + instalador `scripts/instalar-painel-auto.ps1`
(tarefa `PainelHermes-Painel`, `-IUnderstand`, `-IntervaloMinutos 5`, `-Remover`).

**Primeira medição do gestor (10:39–10:45) reprovou:** matei o PID 13348 e esperei
6 min em poll de 15 s — `http=000` nas 24 leituras, nenhuma linha nova no
`logs/painel-auto.log`. `Get-ScheduledTaskInfo` mostrava `NextRunTime` **vazio** e
`LastTaskResult 267011` (0x41303, "nunca executou"). Causa: a repetição de 5 min estava
pendurada num gatilho **AtLogOn**, que fica ancorado no evento de logon — sem logon
desde o registro, não existe próxima execução. O que o executor provou foi
`Start-ScheduledTask`, que é disparo manual.

**Correção:** T-P05-011 (abaixo). **Aceite final medido pelo gestor (10:52–10:55):**
matei o PID 8016 às 10:52:27 → `http=000` até 10:55:16 → **200 às 10:55:31**, PID novo
**23716**, `netstat` `127.0.0.1:8787 LISTENING 23716`, log
`2026-11-25T10:55:19 inicio pid=23716 ok=sim`, Agendador `LastRunTime 10:55:15`,
`LastTaskResult 0`, `NextRunTime 11:00:14`. Nenhum navegador aberto pela tarefa
(`Get-Process msedge,chrome,firefox` vazio).

**Limite declarado:** a tarefa é `InteractiveToken` — com o Marlon deslogado ela não
roda (nem logon, nem relógio). O gatilho de relógio tem duração `P3650D` (~10 anos)
porque o Agendador recusa `TimeSpan.MaxValue`; o AtLogOn continua valendo depois disso.

---

## T-P05-010 · P-05: cota oficial ao vivo do OpenCode Go (M-013) ✅

**Origem:** M-013 do Gerente (`DOCS/08-GERENTE/API-USAGE-OPENCODE-GO.md`). O cartão
oficial mostrava `INDISPONIVEL` desde a T-P05-004 porque o coletor batia em rotas mortas
(`/api/experimental/usage/limits` → 401/404) e a rota do CLI devolvia `data=null`.

**Brief:** `briefs/2026-11-25-p05-t010-cota-oficial-ao-vivo.md`, despachado 10:29.
Escopo: `medir_cota_oficial()` lendo `GET https://opencode.ai/zen/go/v1/usage` com
`OPENCODE_GO_API_KEY` do `.env` do Hermes (lida sem imprimir), chave nova `cota_oficial`
em `stats.jsonl`, bloco `oficial` do `grafico.json` derivado dela, e o cartão mostrando
as três janelas. Legado (`medir_cota`, chave `cota`) intocado.

**Medição do gestor (independente do relatório):**
- `python scripts/coletor.py` **duas vezes** → `cota oficial: 5h 10% | semanal 21% |
  mensal 37% (lida 10:30)` nas duas; as duas últimas amostras de `stats.jsonl` com
  `cota_oficial.status = "disponivel"` e os três percentuais.
- Falha testada por mim: `OPENCODE_GO_API_KEY=chave_invalida_de_teste python
  scripts/coletor.py` → `cota oficial: indisponivel | motivo: chave inválida ou revogada
  (HTTP 401)`, gravado como motivo, **sem zero**. Rodada seguinte volta a `disponivel`.
- Cartão servido (`curl 127.0.0.1:8787/`, 200): `OFICIAL · AO VIVO`, `5 horas 10% renova
  25/11 13:03`, `Semanal 21% renova 29/11 21:00`, `Mensal 37% renova 12/12 21:45`,
  nota `percentual do plano oficial, lido às 10:30 — não é o consumo de tokens medido
  aqui`, e o endpoint em `<details>`.
- CDP 1440 e 390 (2 lançamentos): cartão 326×352 em 1440 e 366×219 em 390, sem overflow
  horizontal nem vertical, 0 filhos fora; valores `10% / 21% / 37%`.
- `git grep -nE "oc_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9]{20,}"` → nada; `git ls-files` sem
  `.env`, `auth.json`, `*.db`, `dados/`.

**Commit:** `555d175 T-P05-010: cota oficial ao vivo do OpenCode Go (3 janelas, erro como motivo)`.

**Comportamento conhecido:** se a leitura mais nova falhar, o cartão mantém a **última
leitura válida** e mostra a hora dela (`lido às HH:MM`) — não vira `INDISPONIVEL` por
uma falha isolada. O motivo da falha fica na amostra do `stats.jsonl`.

---

## T-P05-011 · P-05: repetição por relógio no autostart ✅

**Origem:** reprovação da T-P05-009 na medição do gestor.

**Brief:** `briefs/2026-11-25-p05-t011-repeticao-autostart.md`, despachado 10:47.
Escopo: segundo gatilho ancorado no relógio (`MSFT_TaskTimeTrigger`, início no registro,
`Repetition.Interval = PT5M`, duração `P3650D`), mantendo o AtLogOn; e **portão no
instalador** — `exit 5` se `NextRunTime` ficar vazio ou longe demais, para não terminar
"sucesso" com tarefa que nunca roda.

**Medição do gestor:** `Get-ScheduledTask` com **2 gatilhos** — `MSFT_TaskLogonTrigger`
(delay `PT30S`, rep `PT5M`) e `MSFT_TaskTimeTrigger` (start `2026-11-25T10:50:14-03:00`,
rep `PT5M`, dur `P3650D`); `NextRunTime 10:55:14` preenchido; teste do relógio passou
(ver T-P05-009). Instalador idempotente (2ª instalação exit 0, sem duplicar) e
`-Remover` remove de fato.

**Commit:** `9dcdbe8 T-P05-011: repetição por relógio no autostart (portão de NextRunTime + prova real)`.

---

## T-P03-025 · título das páginas internas atrás do header fixo ✅

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

**Fechamento (Gerente, 25/11):** 1.3.10 no ar. Confirmado por mim na fonte pública:
`https://jessicahaguiwara.arq.br/wp-content/themes/jessica-haguiwara-child/style.css`
serve `Version: 1.3.10`. A prova de layout (h1 abaixo do header, folga ≥16 px @1440 e @390)
está no relatório da tarefa.

---

## T-P03-026 · revisão editorial das 4 páginas de serviço (Q-033) ✅

**Origem:** M-004 do Gerente (`DOCS/08-GERENTE/PARA-GESTORES.md`) — aplicar **10 das 11** propostas
da revisão de Q-033 (`DOCS/P-03-Jessica-Haguiwara/REVISAO-EDITORIAL-2026-11-24.md`). P2 vetada pelo
dono do projeto.

**Brief:** `briefs/2026-11-25-p03-t026-revisao-editorial-4-paginas.md`.

**O que é:** 10 trocas de texto no `post_content` de 4 páginas — 226 `/consultoria/` (C1, C2, C3, C4),
227 `/projetos/` (P1), 228 `/gestao-de-obra/` (G1, G2), 229 `/chave-na-mao/` (M1, M2, M3) — via MCP
`wp_replace_in_post` (`field: post_content`, `regex: false`, `max_replacements: 1`). C3 é a única
estrutural: parágrafo → `wp:list` de 3 itens. Nada de tema, nada de SEO, nada de deploy: a copy vive
no banco.

**Baseline do gestor (25/11, Chrome/131, sem query string, 2 leituras idênticas por URL):**
`/consultoria/` 200 **149.346 B** · `/projetos/` 149.175 · `/gestao-de-obra/` 149.140 ·
`/chave-na-mao/` 149.062. As 11 citações ANTES conferem **1× cada** dentro do `entry-content`.
`style.css?ver=1.3.10` no ar (T-P03-025 fechada).

**Armadilha medida que muda o aceite:** a frase ANTES do M1 é também o `og:description` da
`/chave-na-mao/`. Depois da troca, ela continua **1× na meta** (Yoast, fora de escopo) e tem de zerar
no corpo — contar ocorrência no HTML inteiro daria falso negativo.

**CA:** 10 chamadas com `replacements_count: 1` e delta compatível; releitura do cru com 10 DEPOIS
1× e 10 ANTES 0×; P2 intacta; C3 como `<ul class="wp-block-list">` de 3 `<li>` irmã do H2 (não dentro
de `<p>`); purge do WPFC; 4 URLs 200 com contagem certa no HTML público; `git status` do repo do
projeto igual antes/depois.

**Execução (25/11, OpenCode):** 10 chamadas `wp_replace_in_post`, todas com
`replacements_count: 1`; deltas medidos batem com os previstos (C1 +26, C2 −3, C3 +176
— molde real com aspas, C4 −3, P1 +4, G1 −48, G2 +31, M1 −2, M2 −4, M3 +1, em bytes).
Purge do WPFC: `cache_all_html_restantes: 0`. Nenhum arquivo do repo do projeto alterado.

**Medição do gestor (25/11, Chrome/131, sem query string, 2 leituras idênticas/URL):**

| página | status | bytes | md5 | entry-content |
|---|---|---|---|---|
| `/consultoria/` | 200 | 149.392 | `6bbd90dfd1c266e32bc1aa94c8ba1ffc` | C1/C2/C4 novos 1×, velhos 0×; C3 `<ul>` 3 `<li>` |
| `/projetos/` | 200 | 149.300 | `e8532940679e0cfcd2a0d54a383aba0e` | P1 novo 1×; **P2 intacta 1×** |
| `/gestao-de-obra/` | 200 | 149.244 | `6dfc674cce34d1218b06f88c97462eae` | G1/G2 novos 1×, velhos 0× |
| `/chave-na-mao/` | 200 | 149.178 | `e7a75bf37c1a54d715973f93b9b9a6dc` | M1/M2/M3 novos 1×; M1 velho **0× no corpo, 1× na meta** |

Diff do texto do `<body>` inteiro antes × depois: exatamente as 10 linhas trocadas, nada
mais (`<title>`, canonical, `og:title`, `og:description` idênticos). CTA: 226 = "Fale
sobre o seu caso"; 227/228/229 seguem "Fale sobre o seu projeto". `style.css` = 1.3.10.

**Não testado:** renderização visual/mobile (mesma classe da lista que já existia) e
validade do bloco no editor Gutenberg. **Risco aberto:** `og:description` da
`/chave-na-mao/` ainda com a frase antiga do M1 (Yoast não grava por MCP).

---

## T-P03-027 · o CTA final das 4 páginas vira botão, com ≥32px de ar embaixo 🟢

**Origem:** M-008 do Gerente (`DOCS/08-GERENTE/PARA-GESTORES.md`) — pedido do Marlon: o link de
WhatsApp no fim das 4 páginas de serviço "não tem margem nenhuma embaixo, está colado com a caixa
de baixo". **Brief:** `briefs/2026-11-25-p03-t027-cta-final-botao.md`, despachado em 25/11.

**O que é:** troca de markup no `post_content` das 4 páginas (226, 227, 228, 229): o `wp:paragraph`
final com o link do WhatsApp sai e entram `wp:buttons` > `wp:button` (botão nativo do tema, oliva,
raio pill — o `theme.json` já estiliza) + `wp:spacer` de 32px. Texto e `href` byte a byte. **Sem
tema, sem CSS, sem deploy** — a copy e a estrutura vivem no banco.

**Medição de abertura (gestor, 25/11 08:10–08:13, Edge headless/CDP, dpr 1, 1440×900 e 390×844,
8 combinações):** o último filho do `.entry-content` é `<p class="wp-block-paragraph">` com
`margin-bottom: 0px`; o topo do `<footer class="jhw-footer--v2">` coincide com a base do parágrafo —
**vão = 0 px nas 8 combinações**. Nenhuma das 4 tem `.wp-block-button__link` no `entry-content`.
Baseline HTML (Chrome/131, sem query string, 2 leituras): `/consultoria/` 149.392 B
(`6bbd90dfd1c266e32bc1aa94c8ba1ffc`), `/projetos/` 149.300 (`e8532940679e0cfcd2a0d54a383aba0e`),
`/gestao-de-obra/` 149.244 (`6dfc674cce34d1218b06f88c97462eae`), `/chave-na-mao/` 149.178
(`e7a75bf37c1a54d715973f93b9b9a6dc`). Prints ANTES: `cache/scratch/t027/antes-*-{1440,390}.png`.

**CA:** 4 releituras cruas com `status=publish`; 1 `.wp-block-button__link` no `entry-content` de
cada URL pública, texto e href idênticos (o `<a>` só muda pela classe); vão base-do-botão → topo do
footer **≥32 px** em 1440 e 390; `scrollWidth == 390`; 4 URLs 200; purge WPFC com
`cache_all_html_restantes: 0`. Item Q-037: **uma** tentativa de `wp_update_post_meta`
(`_yoast_wpseo_metadesc` na 229) — se voltar `ignored_keys`, registrar e parar.

**Estado:** 🟢 **entregue e medido pelo gestor em 25/11** — feito pelo OpenCode por MCP
(`wp_get_cpt_item` → `wp_update_cpt_item`, 4 páginas), purge WPFC com
`cache_all_html_restantes: 0`.

**Medição (gestor, 25/11 08:26–08:36).** HTML: UA Chrome/131, sem query string, **duas
leituras idênticas** por URL; layout: Edge headless/CDP, dpr 1, 1440×900 e 390×844,
8 combinações.

| Página | HTTP | Bytes (antes → depois) | botão/spacer no `entry-content` | vão botão → rodapé |
|---|---|---|---|---|
| `/consultoria/` | 200 | 149.392 → **149.768** (+376) | 1 / 1 · 0 parágrafo antigo | **96 px** @1440 · **72 px** @390 |
| `/projetos/` | 200 | 149.300 → **149.676** (+376) | 1 / 1 · 0 | **96** · **72** |
| `/gestao-de-obra/` | 200 | 149.244 → **149.620** (+376) | 1 / 1 · 0 | **96** · **72** |
| `/chave-na-mao/` | 200 | 149.178 → **149.554** (+376) | 1 / 1 · 0 | **96** · **72** |

Antes o vão era **0 px** nas 8 combinações. Os +376 B são os mesmos nas 4 páginas: é a
mesma troca de bloco. Texto e `href` **byte a byte** iguais (o `<a>` só ganhou
`class="wp-block-button__link wp-element-button"`). Botão: oliva `#4F5B43`, texto branco,
pill, padding 12/28, **58 px** de altura @1440 e **49,09 px** @390; largura 272,17 / 297,88
@1440 e 212,52 / 231,08 @390 — **não** fica pesado no mobile. Sem overflow horizontal
(`scrollWidth` 1440 / 390).

**Print:** `DOCS/P-03-Jessica-Haguiwara/evidencias/t027/print-<slug>-{1440,390}.png`
(8 PNGs recortados), conferidos **pixel a pixel** — a faixa oliva do botão termina
exatamente 96/72 px acima da faixa marrom do rodapé nos 8. JSON da medição:
`evidencias/t027/verify-cta.json` e `print-shots.json`.

**Q-037:** `wp_update_post_meta` (`_yoast_wpseo_metadesc`, 229) → `ignored_keys`, uma
tentativa, parei. No ar, `og:description` da /chave-na-mao/ segue com a frase antiga
(limite da ferramenta, não regressão).

**Não testado:** validade do bloco no editor Gutenberg (não abri o wp-admin) e leitor de
tela; a classe do botão é a nativa do tema, já usada em outras páginas.

## T-P03-028 · M-011 A: rótulo do submenu `Projeto` → `Projetos`, sem tocar no `h1` ✅

**Origem:** M-011 parte A (`DOCS/08-GERENTE/PARA-GESTORES.md`), que fecha a **Q-035**
com a alternativa **(a)**. **Brief:** `briefs/2026-11-25-p03-t028-submenu-projetos.md`,
despachado em 25/11 via `scripts/oc-brief.ps1`.

**O que é:** o menu não vive no tema: é `wp_navigation` **ID 6** no banco. Troca de
**1 byte** no rótulo do item; `href` e `h1` da página não mudam. Sem deploy, sem CSS.

**CA:** pré-contagem `1 /projetos/`, `1 "label":"Projeto"`, `0 "Projetos"`; depois da
edição, `relido_igual_ao_enviado: true` e delta **+1 byte**; purge WPFC; 2 leituras
públicas iguais.

**Estado:** 🟢 **entregue e medido pelo gestor em 25/11.** Executor: `wp_navigation` 6,
`Projeto` → `Projetos`, +1 byte, `cache_all_html_restantes: 0`, purge **204**. Repo do
projeto **sem commit novo** por esta tarefa (o menu é banco; `git status` igual).

**Medição (gestor, `curl` UA Chrome/131, URL limpa, 2 leituras):** md5 dos 7 rótulos
**`105a167c248f7ffc1782000bf261e848`** nas duas; submenu com `Consultoria`, **`Projetos`**,
`Gestão de Obra`, `Chave na Mão`; `h1` de `/projetos/` = `Projeto de arquitetura e
interiores` (**intocado**, como a M-011 exigia).

## T-P03-030 · M-011 B: auditoria de prontidão para deploy oficial + Google Ads ✅

**Origem:** M-011 parte B. **Entrega:** `DOCS/P-03-Jessica-Haguiwara/AUDITORIA-PRONTIDAO-2026-11-25.md`.

**Como foi medido:** HTML servido (UA Chrome/131, sem query string, sem `no-cache`) e
navegador **só** por `scripts/medir-cdp.py` (M-014), uma página por vez (E-032),
`--throttle 4g --wait 15`. Home medida **5×** no dia: CLS 0,244 em todas.

**Veredito:** **deploy oficial liberado**; **Google Ads BLOQUEIA** por 4 itens:
1. **conversão inexistente** — 0 tag `AW-`, 0 `gtag("event")`, `/obrigado/` 200 mas
   **0 link** na home;
2. **consentimento não bloqueia** — `_ga`, `_ga_NGGYW0ZYHP`, `__hstc`, `hubspotutk`,
   `__hssc`, `__hssrc` gravados em navegador limpo **sem clique**; 0 `gtag('consent'`;
3. **placeholder legal no ar** — `/privacy-policy/`: `Registro profissional: CAU/A nº
   [INSERIR REGISTRO]`;
4. **LCP mobile** — home @390/4G **7.496–8.172 ms** (`DIV.jhw-hero__bg`, JPEG 131,3 KB
   como `background-image`), limite bom ≤2.500.

**Outros números medidos:** `/contato/` **404** (corpo 148.270 B, noindex); meta
description em **1 de 8** páginas; `/obrigado/` `index, follow`; `/privacy-policy/`
**0 `h1`**; CLS home **0,244** (0,099 hero + 0,145 QLWAP); TBT 112–396 ms; INP **16 ms**;
home **846,5–850,0 KB**; `/consultoria/` 298,1 KB, LCP 2.316 ms; `/projetos/` LCP
7.672 ms (`DIV.cmplz-message`).

**nao_testado:** envio real do formulário (não criei lead na base da cliente); resposta
humana no WhatsApp; conversão em campo (só laboratório).

**Estado:** 🟢 entregue. Próximas tarefas propostas: T-031 consentimento, T-032
conversão, T-033 hero, T-034 lote de SEO, T-035 CAU.

## T-P03-029 · M-006 item 2: dois aprendizados de MCP no `DOCS/IA` do projeto ✅

**Origem:** M-006 item 2 (`08-GERENTE/PARA-GESTORES.md`) — autoriza o OpenCode a
registrar 2 aprendizados no `DOCS/IA` do **projeto**. **Brief:**
`briefs/2026-11-25-p03-t029-docs-ia-aprendizados.md`.

**O que é:** duas seções de documentação, sem código: **§37** `wp_replace_in_post` exige
o molde HTML **cru com aspas duplas** (`<ul class="wp-block-list">`; variante com aspas
simples devolve `replacements_count: 0` sem erro) e **§38** o marcador de **46 bytes**
do WP Fastest Cache faz byte/md5 da **página inteira** oscilar (comparar bloco
`entry-content` ou normalizar).

**Estado:** 🟢 **entregue e verificado pelo gestor em 25/11.** Commit do executor
**`b8cc298`**, `DOCS/IA/aprendizados-mcp-wordpress.md` **+50 linhas**, nenhum outro
arquivo (`git show --stat`). Cabeçalhos no arquivo: `## 37.` e `## 38.`, arquivo com
1.858 linhas. Sem MCP, sem deploy, sem purge.

---

## T-P03-031 · M-016 B: texto de WhatsApp próprio em cada página de serviço ✅

**Origem:** M-016 parte B. **Brief:** `briefs/2026-11-25-p03-t031-whatsapp-por-pagina.md`.
**Escopo:** só o `text=` do link de WhatsApp dentro do `post_content` das 4 páginas
(226 `/consultoria/`, 227 `/projetos/`, 228 `/gestao-de-obra/`, 229 `/chave-na-mao/`),
via MCP `wp_replace_in_post`. Header/rodapé mantêm o texto genérico antigo — fora do
escopo por instrução.

**Medido antes (25/11, leitura MCP):** exatamente **1** ocorrência do encoded antigo
em cada `post_content` (2.761 / 2.596 / 2.529 / 2.460 caracteres), e **nenhum** outro
valor de `text=` nas 4 páginas. Serve de prova de que a busca do brief é exata.

**Medido depois (25/11, por mim):** `wp_get_cpt_item` (226–229): **0** antigo, **1**
novo próprio e **0** de outra página em cada `post_content`. HTML servido, UA
Chrome/131, sem query string, 2 leituras idênticas por URL: `/consultoria/` **200**
149.741 B `8637a765…` · `/projetos/` **200** 149.709 B `0bc4ac42…` ·
`/gestao-de-obra/` **200** 149.632 B `12153f7a…` · `/chave-na-mao/` **200**
149.598 B `6072af38…`. Na fatia `entry-content` → `</main>`: **0 antigo, 1 novo
próprio, 0 de outra página**; href segue `api.whatsapp.com` com
`phone=5511983236422` e o rótulo do botão inalterado. O **+45 B** de `/projetos/`
sobre a tabela é o marcador do WPFC (§38, **46 B**) que a página ganhou desde o
baseline: 149.709 − 46 = 149.663, **−1 B** do esperado. `/consultoria/` também deu
**−1 B**; as outras duas bateram exatos. Rodapé continua com o texto genérico
antigo (2× por página) — fora de escopo por instrução. Repo do projeto **sem
commit desta tarefa** (nenhum arquivo tocado; `git status` limpo fora do
`DEPOIMENTOS - PROXY.md` pré-existente).

**Estado:** ✅ feita e medida (25/11).

## T-P03-032 · M-016 A: 404 personalizada no child theme (arquivo, termina no dry-run) 🟢

**Origem:** M-016 parte A. **Brief:** `briefs/2026-11-25-p03-t032-404-personalizada.md`.
**Escopo:** criar `jessica-haguiwara-child/templates/404.html` (template de bloco:
header + faixa de título tertiary + h1 + copy + 4 links de serviço + botão WhatsApp +
footer), bump 1.3.10 → 1.3.11 em `style.css`/`functions.php`. **Sem CSS novo** e sem
deploy real — a publicação é do gestor.

**Verificado antes:** `404.php` não resolve neste tema (block template do pai vence);
a pasta `templates/` do child **não existia** em produção e foi criada pelo gestor em
25/11 pela API 2 (`Fileman::mkdir`) — UAPI não tem mkdir/rmdir/unlink. Pasta já no ar,
vazia. `parts/header.html` e `parts/footer.html` presentes no child.

**Executor:** OpenCode, commit `1713758` (3 arquivos, +57/−2: `templates/404.html` novo,
`style.css` e `functions.php` com a versão).

**Medido antes (por mim, antes do deploy):** sonda
`/uma-url-que-nao-existe-p03-m016/` → HTTP **404** real, **148.270 B**, md5
`6f9a53726b8c7bad799d59a325379e87`, h1 **`Page Not Found`** (inglês, tema pai), parágrafo
em inglês + **formulário de busca**, **0 links** dentro do `main`, 2 links de WhatsApp na
página (rodapé), `noindex` presente, `lang="pt-BR"`.

**Backup antes do deploy (obrigatório):** `backups/theme-1.3.10-before-1.3.11/` com os 11
arquivos do commit `1713758^` (`git archive`), `BACKUP.md` com sha256 de cada um e o passo a
passo do rollback. Conferência contra o servidor por UAPI `Fileman/get_file_content`:
`style.css` e `functions.php` line-a-line **0 linhas diferentes** do backup — o backup é
fiel ao que estava no ar.

**Deploy (25/11):** `node scripts/deploy-theme.mjs` → 3 arquivos enviados
(`functions.php`, `style.css`, `templates/404.html`), verificação SHA256 pela URL pública
**12/12 PASS**; purge por `scripts/diagnostics/purge-wpfc-once.mjs` (arquivo de uso único
apagado, 404 confirmado); `validate-theme.mjs --record` → release.json **1.3.11**, 12
arquivos, `templates/404.html` incluído; dry-run final **12 iguais, 0 divergentes,
0 novos, 0 órfãos**.

**Medido depois (por mim, HTML servido, UA Chrome/131, sem query string, 2 leituras
idênticas):** sonda → HTTP **404** real, **146.096 B**, md5 `0d8e5df7c2f4707fe9d2581eeaad9f12`,
`text/html; charset=UTF-8`; h1 **`Página não encontrada`**; **4** links de serviço no `main`
(`/consultoria/`, `/projetos/`, `/gestao-de-obra/`, `/chave-na-mao/`); **1** CTA de WhatsApp no
`main` (texto genérico, `phone=5511983236422`); **0** `<form>` e **0** `type="search"`;
`noindex`; header de bloco e `<footer>` presentes; **3** links de WhatsApp na página inteira
(CTA + rodapé ×2); `lang="pt-BR"`. Segunda URL de sonda `/?p=999999` → **404** também.
Geometria por CDP (`medir-cdp.py`, 2 lançamentos): **1440×900** h1 em 104–141 px, faixa
tertiary `rgb(237,227,214)` até 173 px, `scrollW` = `innerW` = 1425, botão "Fale sobre o seu
projeto →"; **390×844** h1 em 104–130 px, barra do header 64 px, `scrollW` = `innerW` = 390,
botão 231 px, altura do documento 1372 px. Prints em
`AppData/Local/hermes/profiles/jessica-p03/cache/scratch/p03-m016/cdp/404-1440.png` e
`404-390.png`.

**Não testado:** 404 em navegador com JS desligado; leitor de tela.

**Estado:** ✅ feita, publicada e medida (25/11).

---

## T-P03-033 · M-020: texto único do WhatsApp no rodapé e na 404 ✅

**Origem:** M-020 do Gerente (25/11 17:10, depois de aceitar a T-P03-031). **Brief:**
`briefs/2026-11-25-p03-t033-whatsapp-rodape-global.md`. **Executor:** OpenCode, commit
`578b4b9` (4 arquivos, +5/−5).

**Escopo:** só o `text=` de 3 links — `parts/footer.html` **linha 16** (botão
`jhw-footer-button`) e **linha 57** (link do título da coluna de contato), mais
`templates/404.html` linha 46 (botão da 404, incluído por mim para o site não se
contradizer na página de erro). Texto: `Olá! Quero conversar sobre o meu projeto.`
(`Ol%C3%A1!%20Quero%20conversar%20sobre%20o%20meu%20projeto`), `phone=5511983236422`
intacto. Bump 1.3.11 → **1.3.12**.

**Medido antes (por mim, 2 leituras idênticas por URL, HTML inteiro):**

| URL | status | bytes | antigo | universal | próprio |
|---|---|---|---|---|---|
| `/consultoria/` | 200 | 149.602 | **2** | 0 | 1 |
| `/projetos/` | 200 | 149.526 | **2** | 0 | 1 |
| `/gestao-de-obra/` | 200 | 149.444 | **2** | 0 | 1 |
| `/chave-na-mao/` | 200 | 149.417 | **2** | 0 | 1 |
| sonda de 404 | 404 | 145.983 | **3** | 0 | — |

**Backup antes do deploy:** `backups/theme-1.3.11-antes-1.3.12/` (12 arquivos de
`578b4b9^` + `BACKUP.md` com sha256 e rollback).

**Deploy (25/11):** `deploy-theme.mjs` → 4 arquivos, `todos os arquivos conferem`;
purge de uso único (arquivo apagado, 404 confirmado); `validate-theme.mjs --record` →
release.json **1.3.12**; dry-run final **12 iguais, 0 divergentes, 0 novos, 0 órfãos**.

**Medido depois (por mim, mesmas 5 URLs, 2 leituras idênticas):**

| URL | status | bytes | antigo | universal | próprio | links wa |
|---|---|---|---|---|---|---|
| `/consultoria/` | 200 | 149.544 | **0** | **2** | 1 | 3 |
| `/projetos/` | 200 | 149.468 | **0** | **2** | 1 | 3 |
| `/gestao-de-obra/` | 200 | 149.386 | **0** | **2** | 1 | 3 |
| `/chave-na-mao/` | 200 | 149.359 | **0** | **2** | 1 | 3 |
| sonda de 404 | 404 | 145.830 | **0** | **3** | — | 3 |

Zero ocorrências do texto antigo nos **links** (`href`/`text=`) das 5 URLs, inclusive rodapé.
O `%0A` que os dois links do rodapé traziam no fim saiu junto com o texto antigo (o brief
especificava o link sem ele); efeito visível: nenhum. O **−58 B** por página é o rodapé
**−104 B** (2 links de 165 → 113 B) **+46 B** do marcador do WPFC (`need to refresh…`).
`release.json` no repo do site: commit `19c84d3`, assinatura `GESTOR-P03`.

**Re-medido por mim às 15:07** (cache do WPFC regravado, 2 leituras idênticas por URL,
md5 igual par a par): **0 antigo / 2 universal / 1 próprio / 3 links** nas 4 páginas;
bytes 149.683 / 149.605 / 149.528 / 149.494. Fora do rodapé, o diff antigo→novo do HTML
é só `?ver=1.3.11 → 1.3.12`. A home, fora do escopo, mantém **1 texto antigo no CTA do
corpo** (`post_content`, intocado).

**Resta 1 fonte do texto antigo, fora do escopo:** o plugin **qlwapp** (botão flutuante)
embute no HTML um JSON com `message` antigo **2× por página** (variantes desktop/mobile) —
não é `text=` de link, é configuração do plugin no banco. Não tocado (CTA/plugin fora do
brief). Se o Gerente quiser o texto único também no botão flutuante, é tarefa própria:
mexer na opção do plugin, não no tema.

**Não testado:** a mensagem pré-preenchida aberta no app do WhatsApp (só o `href`
codificado); rodapé nas 14 páginas do site (medi as 5 do escopo + a 404).

**Estado:** ✅ feita, publicada e medida (25/11).

---

## T-P06-007 · P-06: histórico local separado do real + HTML legível em 390 ✅

**Origem:** M-017 do Gerente, itens 1 e 3. **Brief:**
`briefs/2026-11-25-p06-t007-historico-local-e-html-390.md`. **Executor:** OpenCode, commit
`79117cc` (6 arquivos, +110/−11).

**Escopo único:** (1) `--fonte local` deixa de gravar no `historico.json` e passa a usar
`historico-local.json` (ignorado pelo git), com `--historico local`; (2) o HTML do relatório
para de estourar a tela do celular — cartões com rótulos até 600 px, tabela de 4 colunas
acima disso. Nada mais.

**Critério de aceite (medido por mim, não pelo executor):** `historico.json` = `[]` com md5
`d751713988987e9331980363e24189ce` antes e depois de todos os testes; `--historico` vazio e
`--historico local` com 1 leitura; `--dry-run` local não cria arquivo; idempotência 1 → 1;
CDP em 390×844 com `innerWidth` e `scrollDoc` **390** e **0** elementos fora da borda; em
1280×900 com **4** cabeçalhos e sem estouro; execução real exit **1** com a frase do Google.

**Estado:** ✅ fechada em 25/11. Medição: 390 → `scrollDoc` **390**, `off` **[]**, tabela
366 px (antes: 544, estouro de 154 px com `<code>` de 515 px); 1280 → tabela 1040 px, 4 `th`,
altura 900. Cartões com rótulos conferidos no print (`@media max-width:600px`). Prints em
`testes/evidencia-20261125/` (ignorado pelo git). Política de commit conferida com
`git check-ignore` — já estava aplicada, nenhum commit extra. Risco anotado: duas execuções
reais caíram em timeout de **listagem** (rede fria, `TIMEOUT = 30`) antes de a terceira
reproduzir a recusa do Google; detalhe no caderno do projeto.

---

## T-P06-008 · P-06: listagem com 60 s e 1 retentativa (código 2) + `agendar.ps1` sem instalar ✅

**Origem:** M-019 do Gerente, itens 1 e 2. **Brief:**
`briefs/2026-11-25-p06-t008-timeout-listagem-e-agendador.md`. **Executor:** OpenCode, commit
`a60414e` (5 arquivos, +227/−14).

**Escopo único:** (1) listagem com `TIMEOUT = 60`, `LISTAGEM_TENTATIVAS = 2` e
`LISTAGEM_ESPERA = 3`, exceção `FalhaListagem` saindo **2** — inclusive listagem vazia e
"nenhum PDF no padrão"; (2) `scripts/agendar.ps1` cria/atualiza a tarefa semanal, provado
com `-WhatIf`, **sem instalar** (Q-040 aberta). Nada mais.

**Medido por mim (não pelo executor), em 25/11:**

| comando | esperado | medido |
|---|---|---|
| `verificar.py --config <pasta inexistente>` | 2, com retentativa | **2** em **3,9 s** (2 tentativas, 1 linha de aviso na stderr, mensagem "não consegui listar a pasta (2 tentativas, 60 s cada, 3 s entre elas)") |
| `verificar.py` (Drive real) | 1 | **1**, recusa do Google por extenso, listagem achou `POR6.4.pdf` |
| `--dry-run --fonte local` | 10 e nada gravado | **10**, sem `historico-local.json`, md5 dos relatórios igual ao HEAD |
| `--fonte local` 1ª / 2ª | 10 / 0 | **10** / **0** |
| `agendar.ps1 -WhatIf` | 0, PLANO, nada instalado | **0**; `What if: … registrar tarefa semanal`; `schtasks /Query` → "O sistema não pode encontrar o arquivo", exit 1 |
| `agendar.ps1 -WhatIf -Dia Friday -Hora 19:30` | PLANO com Friday 19:30 | **0**, PLANO correto |
| `agendar.ps1 -Executar` | roda e loga | exit **1** (recusa real), linha anexada em `logs/agendador-202611.txt` |
| `agendar.ps1 -Remover -WhatIf` | não remove | **0**, só o "What if" |
| `-Hora 25:99` | rejeitado | rejeitado pelo `ValidatePattern` |

`historico.json` md5 `d751713988987e9331980363e24189ce` antes e depois; PowerShell
**5.1.26100.9818**; `agendar.ps1` em UTF-8 **com BOM** (EF BB BF). Os acentos quebrados em
`a��o` na captura são do console cp850, não do arquivo.

**Não testado:** o `Register-ScheduledTask` de verdade e o `-Remover` sem `-WhatIf` (proibido
pelo brief, Q-040 aberta); o estouro real dos 60 s (o caminho de retentativa foi provado por
HTTP 404, que também espera 3 s); execução pelo Agendador.

**Estado:** ✅ fechada em 25/11 (código). T-P06-004 continua aberta só na instalação:
rodar o script sem `-WhatIf` quando a Q-040 liberar.

---

## Registro retroativo · P-06 · T-P06-009 … T-P06-019 (25/11, Gerente)

> Trabalho executado e medido no repo do projeto entre 13:40 e 22:30, com brief em `briefs/`,
> mas sem bloco na fila deste workspace — falha de registro que este bloco corrige em uma
> linha por tarefa (regra §2.1 do `REGRAS.md`). Estado do repo: `7622ebe` (25/11 22:30),
> árvore limpa; caderno `DOCS/P-06-Planejamento-Missionario/GESTOR.md`.

| Tarefa | Entrega | Estado |
|---|---|---|
| T-P06-009 | ler o planejamento **sem baixar** (camada de texto do `viewer/presspage` + sessão em navegador headless) | 🟢 |
| T-P06-010 | linha do tempo legível no relatório | 🟢 |
| T-P06-011 | grade de horários por dia/faixa | 🟢 |
| T-P06-012 | caixas de célula (posição e tamanho) | 🟢 |
| T-P06-013 | buracos de leitura explícitos (não inventar horário) | 🟢 |
| T-P06-014 | teto de 60 min por célula para não inventar horário grande | 🟢 |
| T-P06-015 | vários links, com histórico/snapshots/relatórios separados | 🟢 |
| T-P06-016 | painel local do vigia (`127.0.0.1:8788`, tarefa `VigiaP06`) + migração do legado | 🟢 |
| T-P06-017 | fim de célula lido na borda da tabela (38 células; 2 estimadas com ressalva) | 🟢 |
| T-P06-018 | `Referrer-Policy: same-origin`, CSRF em todo POST, motivo no 403 | 🟢 |
| T-P06-019 | alvo de toque ≥44 px e aviso de remoção condicional | 🟢 |

**Aceite do Gerente:** M-023 e M-024 aceitas por medição independente (ver nota em
`08-GERENTE/PARA-GESTORES.md`); painel do vigia fechado ponta a ponta — 7 itens medidos,
390 px sem estouro, repo limpo. **Sobra conhecida e aceita:** o log do motor ainda escreve
"dados preservados" na remoção sem a condicional da tela (cosmético).

## T-P03-034 … T-P03-038 · P-03: as tarefas da M-018 e da M-022 (abertas 25/11 23:55)

**Ordem:** M-025 (`08-GERENTE/PARA-GESTORES.md`). **Dono:** gestor `jessica-p03`; executor
OpenCode. **Autorização:** M-018 (25/11 15:00) e M-022 item 1 (19:00). **Nenhuma publica:**
deploy é ato do Gerente depois de medir.

| Tarefa | Escopo | Onde | Limite |
|---|---|---|---|
| **T-P03-034** | consentimento: opt-in bloqueia `_ga`/HubSpot antes do clique + Consent Mode v2 | tema | implementar + `--dry-run` + medição local |
| **T-P03-035** | hero com `srcset` WebP/AVIF + `fetchpriority="high"`; alvo LCP mobile < 2,5 s | tema | implementar + medir antes/depois |
| **T-P03-036** | lote SEO: 7 meta descriptions, `noindex` no `/obrigado/`, `h1` na política | banco | aplicar + medir no HTML servido |
| **T-P03-037** | `/obrigado/` + `generate_lead` no GA4 | tema/medição | `AW-` fica pendência (`Q-041`) |
| **T-P03-038** | qlwapp: mensagem do botão flutuante → `Olá! Quero conversar sobre o meu projeto.` | banco | valor antigo salvo, rollback escrito; se não for editável, parar e reportar |

**Critério de aceite:** por tarefa, relatório com os 8 campos do contrato, medição no HTML
servido (duas leituras iguais) e, nas de tema, `--dry-run` limpo + print por
`scripts/medir-cdp.py`. O Gerente mede de novo na fonte antes de qualquer deploy.

**Estado medido (26/11, GESTOR-P03):**

- **T-P03-038 🟢** — `qlwapp_contacts[0].message` passou a `Olá! Quero conversar sobre o
  meu projeto.` (a option `qlwapp` do brief não existe no plugin 8.6.5; o contato mora em
  `qlwapp_contacts`). Medido por mim na URL servida: home **200 / 180.963 B / md5
  `814a2f12…`** e 404 **404 / 145.861 B**, cada uma com **2× texto novo, 0× antigo**,
  `Escreva sua mensagem` 1× e telefone `5511983236422` intacto; 2 leituras iguais por URL.
  O tamanho da home varia ±46 B porque o `data-uid` do Forminator nasce por render.
  Rollback: `backups/qlwapp-option-2026-11-26.json` (serializado md5 `be0f49ad…`, commit
  `16e325f`). **Erro de processo meu:** dois executores despachados para o mesmo brief
  (E-041) — o segundo parou sem escrever; o primeiro aplicou.

- **T-P03-036 🟡 parcial** — o **`h1` da política está feito**: `wp_update_page
  { template: "page-with-title" }` no post 3 (o conserto era template, não bloco de
  conteúdo). Medido por mim, 2 leituras na URL servida: body `page-template-page-with-title`
  e **1 `<h1>`** `wp-block-post-title` = `Política de Privacidade`; script
  `scripts/diagnostics/measure-seo-t-p03-036.mjs`, commit `2bcdbd6`. **As 7 descriptions e o
  `noindex` da 219 não foram gravados:** `wp_update_post_meta` devolve
  `ignored_keys: ["_yoast_wpseo_metadesc"]` enquanto a integração Yoast não é ligada em
  `Easy MCP AI → Tools → Plugins`, e ligar exige wp-admin logado — o perfil Edge
  `wp-admin-profile` está **sem sessão** (`reauth=1`, 3 provas, 00:48). Retomada pronta em
  `briefs/2026-11-26-p03-t036b-yoast.md`; **o bloqueio é humano** (Marlon logar no perfil).
- **T-P03-034, T-P03-035, T-P03-037 ⚪** — não iniciadas; próximas sessões.
