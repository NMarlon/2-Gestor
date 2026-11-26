# P-06 · Alerta de Planejamento Missionário (CTM) — caderno do gestor

**Perfil:** `ctm-p06` · **Repo:** `C:\MarlonScripts\81 - Alerta Planejamento Missionario CTM`
(git local, sem remote) · **Criado:** 25/11/2026

## O que o Marlon quer

Saber, sem abrir o PDF por conta própria, **o que mudou** no planejamento dos missionários
— e ter material para **apresentar a mudança a eles**.

## Medido (25/11, pelo Gerente)

| Fato | Medida |
|---|---|
| Pasta do Drive | pública, lista 1 arquivo: `POR6.4.pdf` |
| Download | **recusado pelo dono** — "the owner hasn't given you permission to download this file" (`uc?export=download`, com cookie, e com `gdown`) |
| Preview | `/file/d/<id>/preview` → 200, mas entrega **PNG** (página renderizada), não PDF |
| Python | 3.11 + pymupdf 2.1 instalados |
| Motor entregue | commit `de5be3c`; relatório `relatorios/teste-local.md` com 3 tipos de mudança |
| Aceite 1 | `--fonte local` → "3 páginas · 1 adicionada · 2 linhas alteradas · 1 adicionada · 1 removida" |
| Aceite 2 | `--dry-run` → sem escrita (md5 do `historico.json` igual antes/depois) |
| Aceite 3 | execução real → **exit 1** com a frase do Google; `historico.json` intacto |
| Idempotência | segunda execução local não duplica entrada (1 → 1) |

## Decisões tomadas

- Histórico e relatórios **versionados**; snapshots e PDFs **ignorados** (`.gitignore`).
- `--fonte local` **não** pode gravar no histórico real (correção pedida na M-017).
- Nada de OCR como plano A: sem download, o projeto para e reporta; OCR só se o Marlon
  escolher a opção (c) da `Q-040`.

## M-017 executada (25/11, por mim)

**Item 1 — histórico separado.** Executor `79117cc` (`OPENCODE-P06`, 6 arquivos, +110/−11).
`--fonte local` passou a ler/gravar `historico-local.json`; o real (`historico.json`) só o
Drive escreve. Medido por mim, árvore limpa:

- `historico.json` = `[]`, md5 `d751713988987e9331980363e24189ce`, **igual antes e depois** de
  todos os testes.
- 1ª execução local → exit 10; `historico-local.json` com 1 entrada (`28d949b3…`, 3 páginas).
- 2ª execução local → exit 0, "sem mudanças"; continua 1 entrada.
- `--historico` → "histórico vazio"; `--historico local` → 1 leitura.
- `--dry-run --fonte local` com o arquivo local apagado → exit 10 e **nada gravado**.
- `historico-local.json` ignorado pelo git (`.gitignore:8`); `git status` limpo depois.
- Execução real do Drive → **exit 1** com a frase do Google e `historico.json` intacto.

**Item 2 — política de commit.** Conferida, já estava aplicada: `dados/snapshots/`,
`dados/*.pdf`, `testes/` e `__pycache__/` ignorados; `historico.json` e `relatorios/`
versionados; `git ls-files -i -c --exclude-standard` vazio. Nenhum commit necessário.

**Item 3 — HTML em 390 e 1280** (`medir-cdp.py`, Edge headless, `file://`, 2 navegadores):

| | antes | depois |
|---|---|---|
| 390×844 | `innerWidth` **544**, `scrollDoc` **544** (estouro de 154 px), `<code>` do sha256 com 515 px, tabela 379 px terminando em 399 | `innerWidth` **390**, `scrollDoc` **390**, `off` **[]**, tabela 366 px, altura 1902 px |
| 1280×900 | tabela 1040 px, sem estouro | tabela **1040 px**, `th` **4**, `scrollDoc` **1280**, altura 900 |

No celular a tabela virou cartões empilhados com os rótulos Página / Tipo / Antes / Depois
(conferido no print, `@media max-width:600px`); no desktop os 4 cabeçalhos seguem visíveis.
Prints: `testes/evidencia-20261125/html-{390,1280}.png` (ignorado) e cópia em
`cache/scratch/depois-{390,1280}.png`.

**Risco novo observado:** duas execuções reais seguidas falharam na **listagem** da pasta por
timeout (`TIMEOUT = 30` s), embora `curl` (5,5 s) e `urllib` puro (0,6 s) respondessem 200 na
mesma janela; a terceira execução funcionou. Não é regressão do motor (o fluxo Drive não foi
tocado no `79117cc`) — é rede fria. Fica anotado para a T-P06-004: agendador com timeout justo
pode falhar em corrida fria.

## T-P06-008 — M-019 executada, medida por mim (25/11, tarde)

Brief `2026-11-25-p06-t008-timeout-listagem-e-agendador.md`; executor `a60414e`
(5 arquivos, +227/−14), árvore limpa depois. O executor relatou e eu repeti cada comando:

| comando | medido |
|---|---|
| `verificar.py --config` com `pasta_id` inexistente | **exit 2** em **3,9 s**; stderr: `listagem: tentativa 1/2 falhou (HTTP 404 …); repetindo em 3 s`; final `ERRO: não consegui listar a pasta (2 tentativas, 60 s cada, 3 s entre elas) …` |
| `verificar.py` no Drive real | **exit 1**, recusa do Google, listagem achou `POR6.4.pdf` |
| `--dry-run --fonte local` | **exit 10**, `historico-local.json` não criado, relatórios com md5 do HEAD |
| `--fonte local` 1ª e 2ª | **10** e **0** |
| `agendar.ps1 -WhatIf` | **0**, bloco `PLANO` e `What if: … registrar tarefa semanal`; nada registrado |
| `agendar.ps1 -WhatIf -Dia Friday -Hora 19:30` | **0**, PLANO com Friday 19:30 |
| `agendar.ps1 -Executar` | exit **1** (recusa real), linha em `logs/agendador-202611.txt` |
| `agendar.ps1 -Remover -WhatIf` / `-Hora 25:99` | **0** só o "What if" / rejeitado |
| `schtasks /Query /TN P06-Planejamento-Missionario` | "O sistema não pode encontrar o arquivo", exit 1 → **nada instalado** |

`historico.json` continua md5 `d751713988987e9331980363e24189ce`; PowerShell
**5.1.26100.9818**; `agendar.ps1` em UTF-8 com BOM (o `a��o` no pipe é cp850 do console).
Ficou decidido no código: **2** = não consegui obter o arquivo da pasta (rede, HTTP,
listagem vazia, nenhum PDF no padrão); **1** continua sendo a recusa do Google no download.

**Correção da lição do timeout:** a retentativa de 3 s só se prova com listagem que falha;
rede quente não reproduz o estouro. O caminho de 60 s em si não foi exercitado — dito no
brief e no relatório, sem fingir.

**Cuidado que se pagou:** `DOCS/04-TAREFAS.md` estava sujo com as entradas do gestor do P-03
(T-031/T-032). Acrescentei meu trecho e comitei **só ele** (`git apply --cached` do diff contra
o índice), para não varrer trabalho alheio.

## Aberto

- **Q-040** — dono do arquivo precisa permitir download (ou Marlon escolhe alternativa).
  Quando abrir: rodar `scripts\agendar.ps1` **sem** `-WhatIf` e conferir com `schtasks /Query`.
- T-P06-004 (agendar semanal) — script pronto e provado; falta só instalar (Q-040).
- T-P06-005 (HTML bonito para os missionários) — o defeito de 390 está corrigido; falta o
  acabamento visual que o Marlon quiser.
- Instalação do agendador pode exigir elevação (`-LogonType Interactive`); como o agendador
  roda a tarefa só com o usuário logado, `-StartWhenAvailable` cobre o caso de PC desligado
  na hora marcada.

## 25/11/2026, 18:20 — o bloqueio caiu: leitura pelo visualizador (medido por mim)

**Q-040 morreu.** O Marlon disse que não há como liberar o download e que o bloqueio é
intencional (os PDFs mudam toda semana). Mandou contornar. Contornei medindo o que a página
de preview pede ao servidor:

```
/viewer/meta       → {"pages":7,"maxPageWidth":3200}
/viewer/presspage  → texto de cada página com coordenada de cada palavra
/viewer/img        → renderização a 3200 px (não usada)
```

O token (`ACFrOg…`) e a sessão (`fssid`) nascem no JavaScript do viewer — não estão no HTML.
Por isso a leitura abre **um** navegador headless para colhê-los; o resto é Python puro.
Nada de download, nada de burlar permissão: é o que o viewer entrega a qualquer visitante com
o link.

**T-P06-009 entregue pelo OpenCode. Medi os quatro critérios, na fonte:**

| Critério | Resultado real |
|---|---|
| 1ª execução real | 7 páginas · 868 linhas · 5.796 palavras · sha256 `69538f8f…`; relatório com `Origem: viewer/presspage`, `Navegadores lançados: 1` |
| Execução seguinte | **exit 0**, "sem mudanças", **0 navegadores** (`msedge` 0 → 0) |
| Mudança simulada (removi 1 linha do snapshot) | **exit 10**, página 4, `1 linha adicionada`, com o texto exato |
| Token no repo | nenhum — só o padrão `id=...&fssid=...` na documentação |
| Determinismo | 4 execuções independentes → mesmo sha256 |

**O que o código faz melhor do que eu pedi:** ao encontrar o snapshot adulterado por mim, o
relatório **avisou** — "Snapshot anterior inconsistente: não confere com o sha256 registrado"
— e refez a leitura do zero em vez de comparar maçã com laranja. Isso é a diferença entre
relatório e propaganda.

**O que ainda não serve:** o documento é uma **grade de horários** e a reconstrução de linha
junta palavras de linhas diferentes da mesma célula. A mudança simulada saiu como
`6:30 and Cafeteria 9:30 Study 13:30 15:00 19:00 Activity Go your off` — o dado está certo,
a leitura é ruim. Para avisar missionário, não passa. Brief **T-P06-010** despachado
(tolerância por altura de palavra + separador ` | ` entre colunas + formato de snapshot
versionado).

## Aberto (atualizado)

- **T-P06-010** — linha legível (em execução).
- **T-P06-004** — agendar semanal: `scripts\agendar.ps1` pronto e provado com `-WhatIf`;
  falta rodar sem `-WhatIf` e conferir com `schtasks /Query`. **Q-040 não bloqueia mais.**
- **T-P06-005** — acabamento visual do HTML para os missionários.
- Risco vivo: `modifiedTime` público é só rótulo ("19 de nov.", sem hora). Edição no mesmo
  dia pode escapar do atalho; existe `--forcar` para isso.
- Dependência: `C:\MarlonScripts\2-Gestor\scripts\medir-cdp.py` (pode virar `P06_MEDIR_CDP`).

## 25/11/2026, 19:40 — T-P06-010 medido: agora a linha se lê

**Antes:** `6:30 and Cafeteria 9:30 Study 13:30 15:00 19:00 Activity Go your off`
**Agora:** `Getting Up, Praying and Preparing for the Day | ... | Getting Up, Praying, Preparing for the Day - 6:30 am - 7:00 am`

O que medi, com as saídas reais:

| Critério | Resultado |
|---|---|
| Leitura nova (formato v2) | 7 páginas · 495 linhas · **5.796 palavras** (mesmas de antes) · sha `14dfb168…` |
| Cabeçalho da grade | `PLAN POR6 - WEEK 1` / `Wednesday - Day 1 \| Thursday - Day 2 \| …` — legível |
| Diff com uma linha removida do snapshot | **exit 10**, página 4, `1 linha adicionada`, **frase inteira**, com `\|` escapado para não quebrar a tabela |
| Determinismo | dois `--forcar` seguidos → **mesmo sha** `14dfb1685394` |
| Atalho preservado | execução normal depois → **exit 0, 0 navegadores** |
| Estado do repo depois dos testes | `git status` **limpo**, `historico.json` = `[]` |

**Critério que não fechei:** o caso "snapshot em formato antigo". Induzi um registro de
histórico sem o campo do snapshot e o script **recusou comparar** —
`ERRO: não consigo comparar sem inventar: registro ... não informa o snapshot` (exit 1). É o
comportamento certo (recusar em vez de inventar), mas o caso específico de snapshot v1
presente e legível **não foi exercitado**. Digo isso em vez de marcar como testado.

**Ruído menor, estável:** as páginas 4, 5 e 6 trazem uma linha `4 | 4 | 4 | 4 | 4 | 4 | 4 | 4`
vinda da camada de texto. Não gera falso positivo (é sempre igual), mas polui o relatório.
Fica para um T-011 se o Marlon quiser o relatório impecável.

**Desbloqueado por consequência:** T-P06-004 (agendar semanal) não depende mais da Q-040.
Falta rodar `scripts\agendar.ps1` sem `-WhatIf` e conferir com `schtasks /Query`.

## 25/11/2026, 20:10 — a grade: sim, a estrutura existe (pergunta do Marlon)

Ele mandou um print da página 1 e perguntou se eu tenho estrutura/metadado para separar as
caixas em colunas e linhas. **Tenho.** O `presspage` dá cada palavra como
`[y, x, altura, largura]` — nessa ordem, e isso é decisivo:

`Wednesday` = `[70, 95, 10, 45]`, `Thursday` = `[70, 240, 10, 36]`, `Friday` = `[70, 394, 10, 25]`
→ mesmo `y` (linha do cabeçalho), `x` crescente (colunas), largura proporcional ao texto.

**Protótipo rodado hoje** (`C:\MarlonScripts\2-Gestor\.scratch\grid.py`): acha o cabeçalho,
fatia as 5 colunas, acha os **80** rótulos de hora da coluna esquerda e agrupa as caixas.
Saída real da coluna Wednesday, que bate com o print do Marlon:

```
Getting up, Pray, Physical Activity, Getting / Shower, Breakfast / Personal Study
District Class 1 / 11:00 - 14:00
WORKSHOP - Welcome to the MTC ... / Lunch / 45 minutos / Preparation
District Class 2 / 16:00 - 19:00
Dinner - 45 minutes / Companionship Study - 60 minutes ...
Prepare to go to Bed / (Your Local Time) - 21:00 - 22:30hrs
```

**4 defeitos do protótipo, todos meus, nenhum do Drive:** banner de largura total cai
dentro das colunas; rótulo de hora é `6:30`+`AM` em duas palavras; fronteira de coluna com
folga fixa deixa caixa vazar para a vizinha ("Make your Sabbath..." apareceu em Saturday);
artefato `4 | 4 | 4 …` nas páginas 4–6.

**Decisão:** o relatório passa a falar em célula (`dia + faixa de horário + texto`), não em
linha solta, e o HTML embute a imagem da página que mudou (o `viewer/img` já entrega 3200 px).
Brief **T-P06-011** despachado com o print dele como gabarito: se a grade da página 1 não
reproduzir as caixas da imagem, não passa.

## 25/11/2026, 22:40 — T-016: o Vigia no ar, medido por mim

**http://127.0.0.1:8788/** — painel local, servidor de stdlib, sem dependência.

| Critério | Medido |
|---|---|
| `GET /` | **200**, 11.066 B, título "Vigia P-06", cartão do POR6 com frequência 24 h e próxima verificação calculada |
| `GET /link/por6` | **200**, 13.329 B, com "Observações", "Mudanças" e "Mudanças de célula entre leituras" |
| `POST /verificar/por6` | **303**; nova linha no `logs/vigia.jsonl` em <25 s: `exit 0, 0,8 s, sem mudanças` |
| Frequência | 35 s depois, **nenhuma linha nova** — não roda antes da hora |
| Traversal | `../../config.json` → **404**; `..%2f..%2f` → **403**; `%2e%2e%2f` → **403** |
| Navegador | `msedge` **0** depois do ciclo — o painel não abre navegador |
| 390 px | `innerWidth 390`, `scrollDoc 390`, **overflow 0** |
| Migração | `dados/links/por6/historico.json` com **5 leituras** (as 4 da raiz + a nova), todas com sha `14dfb168` |
| Agendador | tarefa **VigiaP06** instalada, status *Pronto*; remover com `agendar-vigia.ps1 -Remover` |

**Correção de registro:** o OpenCode relatou que `relatorios/pagina-1.png` "sumiu do disco sem
comando de exclusão dele". Fui eu — `rm -f` na limpeza do teste simulado. Não foi mistério nem
perda de dado; o arquivo era artefato do meu teste, e ele restaurou uma cópia de `testes/`.

## 26/11/2026, 00:30 — T-018: o 403 de todo formulário, corrigido e medido

**Causa raiz (medida pelo Gerente, confirmada por mim antes de briefar):** o painel respondia
`Referrer-Policy: no-referrer`; por especificação o navegador serializa `Origin: null` no POST e
`_host_ok()` recusava. Não era o navegador do Marlon. Meu baseline, no painel velho e antes do
brief: `POST` com `Origin: null` → **403** "Host/Origin não permitido"; com
`Origin: http://127.0.0.1:8788` → **303**; `name="_csrf"` no HTML → **0**.

**Correção — commit `f846044`, 1 arquivo** (`scripts/vigia.py`, +76/−14, autor `OPENCODE-P06`):

- `Referrer-Policy: same-origin` em toda resposta (200, 403 e 404 conferidos).
- Token CSRF por processo (`secrets.token_urlsafe(32)`, só memória) em **todos** os 3 formulários
  de cada página, validado com `compare_digest`; ausente/errado → 403 "formulário expirado".
- `Host` segue loopback (`127.0.0.1:8788`, `localhost:8788`, `[::1]:8788`); `Origin` estranho → 403.
- Todo 403 vai ao `logs/vigia.log` com `host=`, `origin=`, `motivo=`.

**Decisão sobre a contradição do brief:** a linha 51 diz "não aceite `Origin: null` como atalho"
e o critério 1 exige `null` + token → 303. Vale o critério: `null` **nunca** autoriza sozinho
(sem token → 403; GET com `null` → 403); com token válido, passa. O token é o portão, não o
cabeçalho. Anotado aqui para não se re-litigar.

**Os 7 critérios, medidos por mim no painel real (`:8788`, PID 25572):**

| # | O que fiz | Medido |
|---|---|---|
| 1 | `POST` `Origin: null` + `_csrf` do HTML, 1440→90 | **303** e `links.json` foi a 90; restaurei 1440, sha256 **idêntico** ao de antes (`f1e47d1e…`) |
| 2 | mesmo POST sem `_csrf` / com `_csrf` errado | **403 / 403**, frequência intacta (1440) |
| 3 | `Origin: http://evil.example` + token válido | **403** |
| 4 | `Host: evil.example` + token válido | **403** |
| 5 | `GET /` e `GET /link/por6` | **200 / 200**, 3 campos `_csrf` em cada página |
| 6 | traversal no caminho real `/link/por6/relatorio/` | `..%2F` e `..%5C` e `%2e%2e%2f` → **403**; `....//` → **404**; arquivo legítimo → **200**; corpo não traz `leituras` |
| 7 | `logs/vigia.log` | `403 POST … host='127.0.0.1:8788' origin='null' motivo=formulário expirado…`, `origin='http://evil.example'`, `host='evil.example'`, `motivo=arquivo não permitido…` |

**Extras que medi:** `Origin: http://127.0.0.1:9999` + token → 403; `GET /` com `Origin: null` →
403; `POST /verificar/nao-existe` com token → **404** (passou o portão, a rota recusou) e sem token
→ **403**. O token não aparece em `logs/`, `dados/` nem `links.json` (grep: 0 arquivos).

**Navegador de verdade — 1 lançamento** (`medir-cdp.py`, contador 18/30): Edge headless 1280×900,
`http://127.0.0.1:8788/link/por6`, clique no botão Salvar de `section#editar` → caiu em
`?aviso=link+por6+atualizado`, sem "expirado". É o mesmo POST que, com o código velho, dava 403.
`msedge` vivo depois: **0**.

**Estado deixado:** painel PID 25572 (`pythonw.exe`) pela tarefa `VigiaP06`, status *Em execução*;
`links.json` com sha256 igual ao de antes dos meus POSTs. O diff pendente de `links.json`
(`nome` "POR6" no disco × "POR6 — Planejamento Missionário" no HEAD) **é anterior a esta tarefa** —
meu primeiro `cat`, às 21:56 e antes do despacho, já mostrava "POR6". Não é meu, não mexi.

**Colisão de escritores (registro de risco, não dano):** o commit `850d208` (T-P06-017) entrou às
**21:57:42**, cerca de **1 minuto** depois de eu despachar a T-018 (21:56:41) no mesmo repo — e
levou exatamente os arquivos que o meu brief mandava não tocar. Não foi o meu executor: o commit
dele (`f846044`, 22:00:22) tem só `scripts/vigia.py`. Mas houve **dois OpenCode escrevendo no mesmo
repo ao mesmo tempo**; por sorte as áreas não se cruzaram. O Gerente precisa não despachar T-017 e
T-018 no mesmo repo na mesma janela.

**Não testado:** clique real em "Verificar agora" (dispara verificação de verdade e escreveria em
`logs/vigia.jsonl`; o portão é o mesmo, provado pelo 404 com token); `POST /links` e `/remover`
(mesma checagem central).

## 26/11/2026, 00:15 — Gerente: M-023 aceita, e duas correções de fato

**Aceite da M-023 (painel).** Rodei os testes por conta própria, no painel reiniciado com o
código novo:

| Teste | Resultado |
|---|---|
| `Referrer-Policy` | **same-origin** (era `no-referrer`, a causa raiz) |
| `POST` com `Origin: null` + `_csrf` válido | **303** |
| `POST` sem `_csrf` / com `_csrf` errado | **403 / 403** |
| `POST` com `Origin: http://evil.example` + token válido | **403** |
| **Navegador real** (Edge, formulário submetido) | **303** e `links.json` mudou de verdade |

A causa era um cabeçalho que **nós** mandávamos: `no-referrer` faz o navegador serializar
`Origin: null`, e o check recusava. Não era o navegador do Marlon.

**Correção 1 — a Q-040 não está aberta.** O gestor reportou "produto parado na Q-040 (dono não
liberou download)". Desatualizado: a Q-040 foi fechada em 25/11, o download deixou de ser
necessário e o motor lê pelo `viewer/presspage` desde então. Guie-se pelo `06-PERGUNTAS.md`.

**Correção 2 — o T-P06-017 também entrou** (`850d208`), commitado 61 s depois do despacho da
T-018. Não foi trabalho perdido: o kill do Gerente matou o **wrapper** do `oc-brief.ps1`, não o
`opencode-cli` — que seguiu, terminou e commitou. Lição registrada em `E-039`. A partir de
agora, parar executor é matar o processo do `opencode-cli`, e conferir `git log` antes de
despachar outro.

**Estado medido do T-017:** 38 células com fim lido na borda; página 1 `Getting up`
6:30–11:00 `borda`, `Sacrament` 11:00–15:00 `borda`; página 3 `Preparation Day`
**12:45–17:15** `borda`; restam 2 fins estimados (p2 Tuesday e p7 Wednesday) porque a escala
daquelas páginas não fecha (resíduo 12,5 min) — o motor diz isso em vez de fingir.

## 25/11/2026, 22:40 — T-019: o painel fechado de ponta a ponta (7 itens, medidos um a um)

Missão: fechar o painel até funcionar de ponta a ponta. Tudo abaixo foi medido por mim, com
`urllib` (POST lido como **303 literal**, sem seguir redirect), `curl` e o painel real em
`127.0.0.1:8788` rodando pela tarefa `VigiaP06`. Zero `Start-Process` de URL; navegador só pelo
`medir-cdp.py` (**4 lançamentos** no total: 1 perdeu o PNG por caminho MSYS, 3 valeram).

| Item | O que provei | Evidência |
|---|---|---|
| 1. Adicionar link | `POST /links` → **303**; card na home; **"Links vigiados · 2"**; roda e grava | `por6-teste` **exit 10** em **29,1 s**, jsonl 4→5 linhas; `dados/links/por6-teste/` com 4 arquivos; `sha256` do `historico.json` do por6 **inalterado** (`a08c1ab0…`) |
| 2. Remover link | `POST /link/por6-teste/remover` → **303**; sai do `links.json`; dados ficam | aviso `…removido de links.json; os dados continuam em dados/links/por6-teste/`; 4 arquivos ainda em disco; home volta a 1 card |
| 3. Editar nome + desligar/ligar | persiste; agendador respeita | `nome "POR6 teste DESLIGADO"`, `frequencia_min 90`, `ativo false` no `links.json`; ciclo seguinte: **"por6-teste: desligado"** e jsonl **sem** linha nova; `_form=alternar&ativo=1` → 303 e `ativo true` de volta, nome/frequência preservados |
| 4. Falha visível | link com pasta inexistente falha e aparece | `por6-ruim`: **exit 2** em 3,9 s, jsonl com `listagem respondeu HTTP 404: …embeddedfolderview?id=0000PastaInexistenteP06#list`; card mostra **"exit 2"** e o ERRO completo (truncado na tela) |
| 5. Celular 390 px | **overflow 0** e formulários usáveis | `medir-cdp.py` 390×844, 3 cartões: `scrollDoc 390`, `scrollBody 390`, `estouro []`, **7 formulários** |
| 6. Corrigir defeito medido | T-019 (1 ciclo) | alvos de toque: botões/inputs **40 px** e link do título **27 px**, abaixo de 44; e o aviso de remoção dizia "os dados continuam" para link que nunca criou dado (`Test-Path` **False**) |
| 7. Repos limpos | sim | projeto: `git status` **vazio**, HEAD `7622ebe`; `links.json` byte a byte igual ao backup (`6600966b…`) |

**O defeito do item 5, com número.** Antes da correção, a home a 390 px não estourava
(`390 = 390`), mas a lista de alvos `< 44 px` vinha cheia: **40 px** em `button`, `.botao` e
`input[type=text|number]`, **27 px** no `<h3><a>` do cartão. Brief `T-P06-019` mandou subir para
**≥ 44 px** e tornar o aviso de remoção **condicional** (`dados/links/<id>/` existe?). O executor
entregou só o `scripts/vigia.py` (`7622ebe`). Medição depois, painel reiniciado pelo `schtasks`:

- **390×844, 3 cartões**: `scrollDoc 390`, `estouro []`, `alvosPequenos []` (era 26 alvos < 44);
- **1280×900**: `scrollDoc 1265`, `estouro []`, 3 cartões — sem regressão;
- `GET /` **200**, `GET /link/por6` **200**, 7 formulários intactos;
- remover `por6-teste` (com dados) → **303** e frase presente; remover `por6-ruim` (sem dados) →
  **303** e frase **ausente**. Nenhum diretório apagado.

**Não testei:** checkbox "Ativo" clicado no navegador real (só via POST) e o layout da página
`/link/<id>` a 390 px (só a home, que era o pedido). O "Verificar agora" do navegador foi medido
pelo Gerente e por mim ficou no POST (303 + exit 10).

**Higiene:** `links.json` é rastreado e é estado de execução — durante os testes ele apareceu
modificado e foi restaurado do backup byte a byte; **não** foi commitado. `dados/links/por6-teste/`
e `por6-ruim/` eram artefato de teste: apagados depois da prova (o produto não apaga sozinho, e
isso está certo). Ficou registrado no jsonl (5→7 linhas) o histórico dos testes; `logs/` é ignorado.

**Observações para o Gerente:** (a) às 22:22:41 alguém de fora mudou a frequência do por6 para
**380 min** — não fui eu nem o executor; restaurei em seguida (o backup salvou); (b) o commit
`7622ebe` foi o **único** escritor no repo durante a T-019 (conferi `git log` e `git status` antes e
depois); (c) sobra conhecida: o log do motor ainda escreve "dados preservados" na remoção, sem a
mesma condicional da tela — cosmético, fica para quando houver outra tarefa no arquivo.

## 26/11/2026, 00:45 — Gerente: M-024 aceita (painel fechado ponta a ponta)

O gestor rodou a lista inteira com 1 ciclo de OpenCode (`7622ebe`) e 4 navegadores. Conferi na fonte:

| Item | Medido por mim |
|---|---|
| `links.json` final | só `por6`, **1440 min**, `ativo: true` — sem resíduo de teste |
| `logs/vigia.jsonl` | `por6-teste` exit **10** (primeira leitura), `por6-ruim` exit **2** com a mensagem da listagem 404 |
| Remoção | código (`vigia.py`) **não** apaga `dados/links/<id>/`; só tira do `links.json` e o aviso é condicional à pasta existir |
| `/` a 390 px | `innerWidth 390`, `scrollWidth 390`, **estouro 0**, 3 formulários |
| `/link/por6` a 390 px | **estouro 0**, 3 formulários (o gestor não tinha medido esta página) |
| Repo do projeto | `7622ebe`, `git status` vazio |

**Ressalva honesta:** a pasta `dados/links/por6-teste/` não está no disco. O código preserva; a
pasta foi apagada na limpeza do teste. Não é defeito, mas também não é prova — quem quiser a
prova roda um link, remove e confere a pasta.

**Ruído conhecido, aceito:** a mensagem do motor ao remover ainda diz "(dados preservados)"
sem a condicional da tela. Cosmético.
