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
