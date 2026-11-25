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
