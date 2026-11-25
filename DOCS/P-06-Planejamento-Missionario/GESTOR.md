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

## Aberto

- **Q-040** — dono do arquivo precisa permitir download (ou Marlon escolhe alternativa).
- T-P06-004 (agendar semanal) — só depois da Q-040.
- T-P06-005 (HTML bonito para os missionários) — o defeito de 390 está corrigido; falta o
  acabamento visual que o Marlon quiser.
