# 03 — Erros e aprendizados

> Memória de cicatriz. Cada entrada: o que aconteceu, por que doeu, qual a regra
> que passa a valer. A próxima IA não deve cair nas mesmas.

---

## E-001 · Documentação desatualizada mente com confiança (2026-11-20)

**O que aconteceu:** `Hermes-Mobile/DOCS/10-TAREFAS.md` marcava a Fase 2
(Tailscale `:8443`) como ⚪ não iniciada. O `tailscale serve status` mostrava a
rota `8443` ativa e funcionando.

**Por que dói:** quem confia na doc refaz trabalho pronto, ou pior, "conserta" o
que já funciona.

**Regra:** estado só vale com verificação do ambiente, não com a leitura do
último documento. Antes de retomar um projeto, checar o artefato real (serviço
no ar, `git log`, banco, URL).

---

## E-002 · Código sem dado real não é código pronto (2026-11-20)

**O que aconteceu:** o Reconhecedor de Rostos tem API completa, UI e 10 commits
— mas `data/faces.db` tem 0 imagens e a pasta de fotos está vazia. Nunca viu uma
foto real.

**Por que dói:** o requisito do Marlon é "dezenas de milhares de imagens". O
gargalo (clustering `O(n·k)` em Python puro) só aparece nessa escala. Sem acervo,
o app parece pronto e quebra na primeira execução de verdade.

**Regra:** antes de declarar qualquer coisa "pronta", responder: já rodou com
volume real? Se não, o status é "código pronto, não validado".

---

## E-003 · Repositório aninhado aparece como lixo no repo pai (2026-11-20)

**O que aconteceu:** `Reconhecedor de Rostos de  Imagens/` tem `.git` próprio
dentro de `1-Mini-Projetos`, que também é repo. Resultado: aparece como `??`
(untracked) no pai, e um `git add -A` no pai ou ignora ou cria um gitlink pela
metade.

**Por que dói:** commit acidental arrasta projeto inteiro para o repo errado.

**Regra:** `git add` sempre escopado no caminho do projeto. Antes de commitar,
`git status --short` no repo pai para ver se algo alheio entrou na fila.

---

## E-004 · Escrever AGENTS.md exige aprovação humana (2026-11-20)

**O que aconteceu:** a tentativa de criar `AGENTS.md` na raiz do workspace foi
bloqueada pela proteção de "arquivo de instrução de agente" — o prompt de
aprovação expirou sem resposta (Marlon estava fora).

**Por que dói:** sem `AGENTS.md` a raiz perde o contrato; a doc fica só em `DOCS/`.

**Regra:** `AGENTS.md` é arquivo sensível na origem. Não contornar por terminal
nem pedir ao OpenCode — isso é burlar a proteção. Registrar em `06-PERGUNTAS.md`
e pedir aprovação ao Marlon.

---

## E-005 · Sessão de agente não é o servidor do app (2026-11-20)

**O que aconteceu:** `opencode-cli.exe` rodando com 1,9 GB deu a impressão de
"outro agente escrevendo". A linha de comando era `serve --service` — é o
servidor do app desktop, não uma sessão de trabalho.

**Regra:** checar `CommandLine` do processo antes de concluir que há escritor
concorrente. `serve --service` não conta como sessão.

---

## E-006 · Canal do executor morre calado com `$ErrorActionPreference='Stop'` (2026-11-20)

**O que aconteceu:** o wrapper `scripts/oc-brief.ps1` usava
`& $exe @args 2>&1 | Tee-Object`. No PowerShell 5.1 cada linha de stderr de um
nativo vira `ErrorRecord`; com `Stop` o pipeline aborta antes do log ser escrito.

**Regra:** stderr do nativo vai para arquivo temporário (`GetTempFileName`),
`$ErrorActionPreference='Continue'` só durante a chamada, restaurado no
`finally`, e `Tee-Object -Encoding utf8` (sem isso o log sai em UTF-16 e o
`grep` vê bytes nulos).

---

## E-007 · Timeout de foreground mata o executor e deixa órfão (2026-11-20)

**O que aconteceu:** brief do Reconhecedor rodou 600 s, o `terminal` estourou, o
PowerShell pai morreu — e o `opencode-cli.exe` continuou vivo, parado, sem
escrever log. Os arquivos ficaram meio-editados e eu não sabia se ainda havia
escritor.

**Regra:** tarefa de executor que passa de ~2 min roda com `background=true` e
`notify=true`. Se estourar: antes de tocar em arquivo, checar CPU e **mtime**
dos arquivos por ~30 s para saber se o órfão ainda escreve; matar por
`Stop-Process -Id` (não `taskkill //PID`, que o MSYS reescreve).

---

## E-008 · O `git` do PATH é o MSIX do HermesAgent (2026-11-20)

**O que aconteceu:** dentro do shell do OpenCode, `git` resolvia para um binário
em `WindowsApps` e devolvia "Acesso negado" — os commits do subagente falhavam
em silêncio.

**Regra:** o wrapper prepend `C:\Program Files\Git\cmd` no `PATH` e filtra
entradas `*WindowsApps*HermesAgent*\git*`. Vale para qualquer subagente que
precise commitar.

---

## E-009 · Caminho POSIX quebra binário nativo (2026-11-20)

**O que aconteceu:** `--dir "$TMPDIR/sample30"` (que expande para `/tmp/...`)
chegou ao Python como `\tmp\sample30` → "não encontrado". Mesma origem do
`Failed to change directory to /c/...` do CLI (que lê `PWD`).

**Regra:** para `python`, `node`, `git` e `opencode-cli`, passar caminho nativo
`C:/...` (barra normal). Para o CLI, exportar também `PWD` no formato Windows.

---

## E-010 · Custo é por rosto, não por imagem (2026-11-20)

**O que aconteceu:** medi 27 s/imagem e quase concluí que o modelo era inviável.
O perfil (`cProfile`) mostrou: a pasta tinha colagens com 28 rostos por foto, e
cada rosto pagava ArcFace (1,02 s) + landmark 2d/3d (0,32 s) + gênero/idade —
dois modelos que o app **não usa**.

**Regra:** em pipeline de visão, medir por estágio (`cProfile` + contagem de
objetos detectados) antes de acusar o modelo ou a máquina. Modelos não usados
saem do `FaceAnalysis` (`allowed_modules` é **construtor**, não `prepare()` no
insightface 2.1). Ganho: 1,4 s → 0,29 s por rosto.

---

## E-011 · Medir com o job rodando contamina o número (2026-11-20)

**O que aconteceu:** rodei benchmarks de InsightFace enquanto a varredura cheia
usava os mesmos 10 núcleos. Todo número daquela janela (27 s/img, 2 img/min) é
lixo.

**Regra:** medição e carga não correm juntos. Antes de medir, checar CPU dos
processos concorrentes (`Get-Process` / `% Processor Performance`).

---

## E-012 · `Tee-Object` não aceita `-Encoding` no PowerShell 5.1 (2026-11-20)

**O que aconteceu:** para corrigir o log em UTF-16 eu troquei
`Tee-Object -FilePath $Log` por `Tee-Object -FilePath $Log -Encoding utf8`. No
PS 5.1 esse parâmetro **não existe** — o wrapper passou a morrer com
`ParameterBindingException` e o canal Hermes→OpenCode ficou mudo (exit=1, log
nunca criado).

**Regra:** para gravar log de processo nativo em UTF-8, usar
`System.IO.StreamWriter` com `UTF8Encoding($false)` e `AutoFlush`, encaminhando
o pipe com `ForEach-Object`. Validar o wrapper com um brief de teste depois de
qualquer mudança nele — erro de parâmetro só aparece em execução.

---

## E-013 · Varredura iniciada com a extração do acervo ainda rodando (2026-11-20)

**O que aconteceu:** disparei a varredura às 01:05 achando que o tar de 14,7 GB
já estava extraído. A extração só terminou às 01:24 (`exit=0`, com avisos
`Archive entry has empty or unreadable filename ... skipping`). Como
`scan_cli.py` usa `Path.rglob("*")` — gerador preguiçoso, não snapshot —, as
pastas visitadas entre 01:05 e 01:24 podem ter sido lidas pela metade. Também
descobri que a contagem "21.651 imagens" foi feita durante a extração; o total
real em disco é **21.482**.

**Regra:** só disparar varredura depois de confirmar o fim da extração
(`find | wc -l` estável entre duas medições com 1 min de intervalo). Mesmo
assim, toda varredura longa precisa de uma segunda passada com `--resume` antes
de ser declarada completa — o resume é barato e cobre adições tardias.

**Verificação:** `tar -tf` conta 30.656 entradas, das quais 30.530 são arquivos
(as outras 126 são diretórios). O disco tem exatamente **30.530 arquivos**, então
os avisos `empty or unreadable filename` são só entradas de diretório — nenhum
arquivo do acervo foi perdido.

---

## E-014 · Peso morto de plugin se mede no HTML, não no painel (2026-11-20)

**O que aconteceu:** a home da P-03 entrega 577.745 B de HTML. A maior parte não
é conteúdo: um `<style id="spectra-gs-utility-classes-inline-css">` de
**394.171 B**, byte-idêntico nas 4 páginas, com 2.755 seletores utilitários do
Spectra — e **nenhuma** das 4 páginas usa uma sequer dessas classes, nem tem
`wp-block-uagb`. O plugin está ativo, mas o bloco nunca foi usado.

**Por que dói:** 394 KB em 100% das visitas em celular, em troca de nada. Nenhum
painel mostra isso; só o HTML entregue mostra.

**Regra:** antes de acusar "WordPress é pesado", listar os `<style>` inline e os
`<link rel=stylesheet>` da própria página e medir cada um. Para decidir se um CSS
utilitário é morto, comparar **token exato** de `class="…"` com o seletor —
`includes(".block")` casa com `wp-block` e dá falso positivo.

**Corolário:** remoção tem que ser condicional (`has_block('uagb/...')`), não
dequeue cego — senão o próximo bloco Spectra nasce sem estilo.

---

## E-015 · O WPFC serve DUAS versões da mesma página (2026-11-20)

**O que aconteceu, em três atos:** medi as páginas logo após limpar o cache e
registrei 147.349 B. O OpenCode mediu 147.303 B e concluiu "o HTML varia por
requisição". Repeti 3× e os números vieram idênticos — então eu "corrigi" a
conclusão dele: não varia, é transiente. **Errei também.**

**O que é de verdade:** existem dois HTMLs para a mesma URL. O cópia servida
pelo cache do WPFC (a que o visitante recebe) e o render dinâmico, que aparece
com `Cache-Control: no-cache` ou com query string. Diferença medida:

| URL | servido (cache) | dinâmico |
|---|---|---|
| `/` | 183.203 B | 197.842 B |
| `/privacy-policy/` | 147.303 B | 147.349 B |
| `/obrigado/` | 139.419 B | 139.465 B |
| 404 | 139.919 B | 139.919 B (não é cacheado) |

**Regra:** o número que vale é o **servido**, medido **sem** `Cache-Control:
no-cache` e **sem** query string. E toda medição tem que dizer qual dos dois foi.
Nunca registrar um byte sem dizer como foi pedido — foi assim que nos
contradissemos duas vezes em uma hora.

**Corolário:** quando o executor e eu discordamos de um número, é mais provável
que estejamos medindo coisas diferentes do que um dos dois estar mentindo.

---

---

## E-016 · "A API não faz isso" costuma ser "a API 1 não faz" (2026-11-20)

**O que aconteceu:** a doc do projeto afirmava, com todas as letras, que "a UAPI
do cPanel não tem `delete_file`". Isso travou a limpeza de um arquivo órfão por
dias e manteve o deploy em `exit 1`. Na conta real: a UAPI (API 1) responde
`The system could not find the function` para `trash_file`, `restore_from_trash`
e `move_files` — mas a **API 2** faz o mesmo por `Fileman::fileop op=trash`.
Um comando, trinta segundos, resolvido.

**Regra:** quando uma doc interna afirma que uma plataforma "não suporta" algo,
checar em ordem: (1) a doc oficial, (2) a lista de funções da conta, (3) a
geração **anterior** da API. Ausência na API 1 não é ausência no produto.

**Corolário:** limitação registrada sem data e sem a chamada que falhou vira
dogma. Toda limitação na doc precisa do erro exato que a comprova.

---

## E-017 · Medição de performance contaminada por tarefa pesada paralela (2026-11-20)

**O que aconteceu:** disparei o brief T-012 (medir e otimizar `similar` e
`export/people` do Reconhecedor) e, no mesmo minuto, comecei a indexar hash
perceptual de 21.482 imagens para investigar duplicatas. As duas tarefas brigam
por disco e CPU. Qualquer número que o OpenCode medisse naquele intervalo sairia
inflado — e o brief inteiro é sobre número.

**Regra:** enquanto houver tarefa de **medição** em curso (perf, bench, contagem
de tempo), nada pesado de I/O ou CPU roda em paralelo. Medir e varrer são filas
separadas. Se já estiver rodando, mate a tarefa pesada — o dado de performance
vale mais e é mais barato repetir o hash depois.

---

## E-018 · Timeout do `execute_code` mata o kernel, não o processo filho (2026-11-20)

**O que aconteceu:** reenviei o T-015 em **foreground** por `execute_code` para ver
o log ao vivo. O kernel do `execute_code` morre aos **300 s** — mas o PowerShell e
o `opencode-cli` que ele disparou **continuam rodando**. Resultado: dois escritores
no mesmo repositório ao mesmo tempo. O executor detectou sozinho ("outro processo
está editando estes docs de forma concorrente") e reconciliou os números antes de
commitar, mas por sorte.

**Regra:** brief para o OpenCode **nunca** roda em foreground por `execute_code`.
Sempre `terminal(background=True, notify=True)`, com o log do `oc-brief.ps1` como
fonte. Se precisar acompanhar, leia o arquivo de log em `logs/oc-*.log` — não
segure a chamada.

**Sintoma a reconhecer:** executor relatando "outro processo está mexendo nos
arquivos". Quase sempre é um disparo anterior ainda vivo. Antes de investigar
fantasma, `Get-Process opencode-cli` e conferir `StartTime`.

## E-019 · O executor deixa processo torto na porta do usuário (2026-11-22)

Depois de fechar o T-019, a 8011 não respondia a nada: `/api/stats` e `/api/people`
devolviam `000` (timeout), enquanto o HTML estático continuava 200. Causa: às 17:00 o
harness de teste do executor subiu um `uvicorn` na 8011 com o **Python 3.11 do sistema**
(`C:\Users\Marlon\AppData\Local\Programs\Python\Python311\python.exe`), não com o
`.venv` do projeto, e o processo ficou pendurado. O servidor que eu havia subido às
16:45 não estava mais lá. O app do Marlon ficou ~18 min carregando lista vazia.

**Regra:** antes de verificar qualquer entrega, conferir **quem** está na porta e
**com qual interpretador**: `netstat -ano | grep :8011` e depois
`Get-CimInstance Win32_Process -Filter 'ProcessId=<pid>' | fl CommandLine`. Subir com
`env -u PYTHONPATH -u PYTHONHOME ./.venv/Scripts/python.exe -m uvicorn ...` e só
começar o teste quando `/api/stats` devolver 200.

**Por que ninguém vê:** o relatório diz "banco real inalterado" — verdade — mas não
diz que o processo do usuário foi derrubado e substituído. O sintoma que o usuário vê
é "o app abriu, mas não carrega nada".

---

## E-020 · A mesma armadilha do cache, três dias depois (2026-11-23)

**O que aconteceu:** afirmei ao Marlon, sobre o site da Jéssica, que o menu **não tinha
"Soluções"**, e propus criar o item. Ele respondeu que existia. Medi de novo, agora
furando o cache: **existe**, com submenu, apontando para `#solucoes`. Eu havia lido a
página em cache — exatamente o erro que o E-015 descreve, cometido por quem o escreveu.

No mesmo dia, errei duas vezes mais pelo mesmo motivo: contei CSS na página em cache e
chamei de "não minificado" (já estava minificado pelo WPFC); e comparei o rodapé servido
(3426 B, minificado pelo cache) com o dinâmico (3701 B) como se fossem o mesmo objeto,
concluindo "o arquivo não chegou no ar" — quando o que faltava era outra coisa.

**Regra nova, e ela é mecânica:** antes de afirmar que um recurso **não existe**, medir
as duas leituras — a servida (limpa) e a dinâmica (`?cb=1`) — e comparar. Se divergirem,
o que vale é a servida, mas a comparação é obrigatória. "Não achei no HTML" só vira
conclusão depois das duas leituras.

**Corolário 1 — 404 não é disco limpo:** 30 arquivos `jhw-*.php` de diagnóstico antigo
devolvem 404 para GET anônimo, mas continuam no docroot. Um deles (`jhw-purge.php`)
**executa** com chave estática na URL. Ausência de resposta não prova ausência de arquivo.

**Corolário 2 — travessão não é assinatura:** vi `–` onde o arquivo tinha `-` e chamei
de prova de edição no editor. É `wptexturize` do WordPress agindo na saída. A conclusão
estava certa por outro caminho (bytes do banco); a evidência que usei era inválida.

**Corolário 3 — arquivo de tema não é fonte de verdade por si:** `wp_template_part`
salvo no banco (ID 185) vence `parts/footer.html`. Deploy verde, verificação 11/11,
e o visitante continua vendo o rodapé antigo. Antes de editar tema, perguntar: **este
template part está salvo no banco?**

## E-021 · Medi o arquivo no disco, não o byte que o navegador baixa (2026-11-23)

Reportei ao Marlon que as sete fotos da home pesavam 1.312 KB e que o WebP daria
**−50%**. O número estava errado: o site tem o plugin **Converter for Media**, que
serve WebP em *passthru* — a URL `.jpg` responde `Content-Type: image/webp` quando o
navegador manda `Accept: image/webp`. O navegador já baixava **864 KB**, não 1.312.

Medido agora, com o cabeçalho real:

| | antes (URL .jpg, Accept webp) | depois (URL .webp) |
|---|---|---|
| 7 fotos | 864,4 KB | 661,7 KB |
| ganho | — | **−23,5%** |

O ganho é real e a troca valeu (as fotos dedicadas são menores que as do passthru),
mas o número que eu dei ao Marlon era do disco, não da rede.

**Regra:** medir peso de imagem **com o `Accept` do navegador** (`image/avif,image/webp,
image/*,*/*;q=0.8`) e ler `Content-Type` + `Content-Length` da resposta. Arquivo no
disco é inventário, não é o que o visitante paga. O mesmo vale para HTML: só contar
bytes de rede depois de mandar `Accept-Encoding: gzip`.

**Achados colaterais da mesma medição (home, 1ª visita, medido por asset):**
- `gtag/js?id=GT-TBVGGKRR` (GTM) = **178,8 KB** gzip — o maior asset isolado.
- Logo do banner de cookies (Complianz) baixa `logo-scaled.png` **2560×786 = 133,4 KB**
  com `fetchpriority="high"`, para exibir ~40px. O logo do cabeçalho, esse, usa
  `sizes="128px"` e pega a variante de 300w — está correto.
- Hero é `background-image` inline (`.jpg`, 206,7 KB no disco / 134,1 KB servido em webp).
- Pilha do Forminator + jQuery + Select2 + AOS ≈ 200 KB de JS na home, onde só o
  formulário do fim da página usa.
- Assets respondem `Cache-Control: private` sem `ETag` → sem 304, rebaixa tudo a cada visita.

## E-022 · O print mentiu sobre o layout, e eu quase briefei a correção errada (2026-11-23)

**O que aconteceu.** Precisava saber se as páginas internas do site da Jéssica herdavam o
desenho da home. Deleguei a avaliação visual de três capturas. O veredito voltou grave:
"texto cortado na borda direita no celular, container de 668 px numa tela de 390", "H1
ausente", "sem cabeçalho, sem rodapé", "parece tema WordPress genérico". Parecia que a
página precisava de uma passada de estilo inteira, e eu já tinha escrito o brief mandando
o executor extrair 136 blocos de CSS.

Antes de disparar, medi no navegador. **Tudo errado, exceto uma coisa:**

| afirmação do print | medido no CDP |
|---|---|
| overflow horizontal no celular | `innerWidth` 390, `scrollWidth` 390, **0 elementos** passando da borda |
| H1 ausente | `h1` = "Política de Cookies", Marcellus, 31,67 px |
| sem cabeçalho / rodapé / menu | os três existem no DOM |
| tipografia diferente da home | Marcellus e Inter, iguais; fundo `#EDE3D6` igual |
| botão do banner azul `#3B29FF` | **confirmado**, `rgb(59,41,255)`, texto "Aceito" |

**Por que mentiu.** Duas causas somadas:

1. `--window-size=390,844` no Edge headless **não** dá viewport de 390. O layout saiu em
   ~495 px e o print foi recortado para 390 — daí o "texto cortado na direita" e os
   "511 px de vazio no topo". Um recorte sempre fabrica um defeito.
2. A página escolhida como amostra, `/politica-de-cookies/`, é **gerada pelo Complianz** e
   estilizada pelo CSS do plugin (corpo a 14 px). Não é uma página comum do site. Medi
   `/obrigado/` depois: corpo 20 px/32 px. Julguei o site por uma página de plugin.

**O defeito que existia de verdade, e que o print não viu:** em página interna o `h1` é
**31,67 px** e o `h2` é **40,44 px** — a hierarquia está invertida. Isso é medível em uma
linha de JS e nenhuma captura de tela entrega.

**Regras.**
- Antes de aceitar "overflow horizontal", leia `documentElement.scrollWidth` contra
  `innerWidth`. Iguais = não há overflow, o print é que está errado.
- Antes de acusar "H1 ausente" ou "sem cabeçalho", conte os elementos no DOM. Um print de
  viewport não prova ausência — só prova ausência *no enquadramento*.
- Escolha a amostra certa: página gerada por plugin (Complianz, WooCommerce, formulário)
  carrega o CSS do plugin e não representa o tema. Use uma página comum.
- Relatório de subagente é hipótese, igual ao do executor. Números de navegador são fato.

## E-023 — Chutei o corpo do texto e o CSS não pegava; os dois viraram número

**Data:** 23/11/2026 · **Projeto:** P-03 · **Gravidade:** média (brief quase saiu com dois erros)

O brief T-022 mandava "confira a medida de leitura: 20 px numa coluna larga passa de
90 caracteres por linha". Eu não tinha medido. Medi depois: **66 caracteres por linha**
— confortável, nada a corrigir. Se tivesse saído assim, o OpenCode mexeria na coluna de
texto para resolver um problema que não existe.

Na mesma linha de trabalho, escrevi o CSS de correção do `h1` sem `!important` e medi:
o `font-size` **não mudava**, só o `line-height`. A causa: o título vem do template com
a classe `has-large-font-size`, e o core emite
`.has-large-font-size{font-size:var(--wp--preset--font-size--large)!important}`.
Regra sem `!important` perde, por mais específica que seja.

**Regras.**
- Número que entra em brief sai de medição, não de estimativa. Se não medi, escrevo
  "não medido" — o executor merece saber a diferença.
- Antes de briefar CSS contra tema WordPress, liste as regras que casam o elemento com
  `document.styleSheets` e confira `!important` em cada uma. Achar a regra que vence é
  metade do trabalho; a outra metade é medir o resultado com o CSS injetado.
- CSS candidato se valida no navegador **antes** de virar tarefa: injetar por CDP, medir
  `getComputedStyle`, e só então escrever o brief com os valores medidos.

**Adendo (mesmo dia, segunda ocorrência).** O "52–56 px" que usei como alvo do título de
página não era medição minha: era estimativa do relatório do analista, e eu a repeti como
se fosse número medido — inclusive dentro de um critério de aceite. Quando fui medir o
hero da home, ele tem **74,88 px**. O alvo estava 20 px abaixo do certo, e o CSS já
"validado" (56 px) ficava ainda mais longe. Medido de novo com `clamp(2.5rem,…,4rem)`:
**64 px**. Lição: número de terceiro entra no brief como "estimativa do relatório", nunca
como régua; a régua é o `getComputedStyle`.

---

## E-024 · Reportei defeito sem rodar o verificador do próprio repo

**O que fiz.** Vi `scripts/release.json` em 1.3.7 e `style.css` em 1.3.8, concluí
"gate de versão quebrado" e escrevi isso na `AUDITORIA`, no `M-001` e no `M-003` ao
gestor do P-03. Em 24/11 o Marlon pediu explicação, fui rodar o validador — e ele
**passa**: `PASS baseline 1.3.7 / versão subiu / 1.3.8 apos 1.3.7`. Baseline atrás da
versão corrente é o estado previsto entre releases; ela só é regravada com `--record`
depois do ZIP. O defeito não existia.

**Por que aconteceu.** Comparei dois arquivos e tratei a diferença como erro, sem ler
a regra que liga os dois — a regra estava no `validate-theme.mjs`, que eu não rodei.

**Lição.** Se o repositório tem um verificador para a afirmação, o verificador decide,
não o meu olho. Divergência entre dois artefatos só é defeito depois que a regra diz
que é. Ordem certa: rodar o check → colar a saída → se falhar, aí sim reportar.

**Custo.** Três documentos com pendência fantasma, um brief pedindo trabalho
desnecessário ao gestor do P-03 e uma correção pública. Barato desta vez; caro se
tivesse virado tarefa.

---

## E-025 · `curl.exe -o /dev/null` no Windows mente o tamanho

**O que aconteceu.** Medição de página no Windows com `curl.exe ... -o /dev/null`:
o comando saiu **23** (erro de escrita) e reportou `size_download 0`, enquanto o
código HTTP veio correto e a página existia. Quem lesse a saída concluiria "página
vazia". Encontrado pelo gestor do P-03 durante a verificação da T-P03-024, antes de
virar número no relatório.

**Por que aconteceu.** `/dev/null` é caminho POSIX; o `curl.exe` nativo não resolve.
Ele abre, falha a escrita e conta zero bytes baixados.

**Lição.** No Windows, com `curl.exe` nativo, o descarte é `-o nul`, não `/dev/null`.
E código HTTP correto não valida tamanho: se o número importa, ele precisa de um
segundo caminho de medida (aqui: `-o arquivo` + `wc -c`, ou `curl -s | wc -c`).

**Custo.** Nenhum — foi pego na hora. Virado regra para não virar 149 kB de página
"0 bytes".

---

## E-026 · Li três linhas de um arquivo de 51 e declarei dois perfis "idênticos" (2026-11-24)

**O que aconteceu.** O Marlon perguntou qual a diferença entre os perfis `p03-gestor`
e `p05-gestor`. Rodei `head -3` no `SOUL.md` dos dois, vi o mesmo preâmbulo genérico do
Hermes Agent em ambos e afirmei a ele: *"eles são clones — o mesmo texto de identidade"*.
Depois, ao abrir os arquivos inteiros para inserir um bloco de identidade que eu já ia
escrever, achei os blocos prontos: **51 linhas** num, **81 no outro**, com papéis,
proibições e procedimentos de medição diferentes. O bloco de identidade que ele acabou
de autorizar gravar **já existia** — eu ia duplicar.

**Por que aconteceu.** Usei a sonda mais barata e reportei com a confiança da leitura
completa. As três primeiras linhas de todo perfil Hermes são o mesmo preâmbulo
institucional — é a parte que **não pode** diferir. Amostrei exatamente o trecho onde a
diferença nunca estaria e generalizei para o arquivo todo.

**Lição.** O tamanho da sonda limita a conclusão, não o contrário. "A e B são iguais" é
a afirmação mais cara que existe: amostra nunca prova identidade — `diff` ou `md5sum`
provam. Se a pergunta é o que distingue duas coisas, leia o que as define, não o
cabeçalho que as iguala.

Complemento que o erro mostrou de bom: o bloqueio que eu ia aplicar (autorização para
escrever no `SOUL`) salvou o trabalho de um arquivo inteiro — mas só porque ele pediu
aprovação antes, não porque eu conferi.

**Custo.** Uma afirmação errada ao Marlon sobre a configuração dele, corrigida minutos
depois. Barato porque ele perguntou de novo; caro se ele tivesse agido — autorizado
reescrever dois `SOUL.md` que já estavam certos.

## E-027 · O commit levou arquivo de outro agente (2026-11-24)

**O que aconteceu.** Commitei a ordem `M-005` com `scripts/commit-agent.sh GERENTE -m "..."
-- DOCS/08-GERENTE/PARA-GESTORES.md` e o commit saiu com **6 arquivos**: além do meu,
o caderno do P-05, dois briefs do P-05 e os dois registros compartilhados. O `git add`
por caminho explícito estava certo; o problema é que **o stage já vinha carregado** do
trabalho de outro gestor, e `git commit` leva o stage inteiro, não só o que foi nomeado.
O commit `75da404` assinava como GERENTE cinco arquivos que não são meus.

**Como descobri.** Não confiei na mensagem de sucesso: `git show --stat` mostrou 6
arquivos onde eu esperava 1. Se eu tivesse lido só a primeira linha (`[master 75da404]`),
o erro passava — e o `git log` diria para sempre que o Gerente escreveu o caderno do P-05.

**O que fiz.** `git reset --soft HEAD~1`, devolvi os 5 arquivos ao estado anterior
(untracked/modified), recommitei só o meu (`e092d35`, 1 arquivo) e tranquei a porta:
`scripts/commit-agent.sh` agora **recusa** o commit quando o stage tem arquivo não
nomeado, e roda a checagem **antes** do `git add` — na primeira versão eu chequei depois,
e a recusa deixava lixo no stage; o commit seguinte falhava e eu não entendia por quê.
Testado com dois arquivos descartáveis: recusou e o HEAD não andou.

**Lição.** Num workspace com vários escritores, **o stage é memória compartilhada**. O
comando que você digita não define o que o commit leva — o índice define. Antes de
commitar, o único número que importa é `git diff --cached --name-only`. E a verificação
que salvou o caso foi `--stat` depois do commit, não a mensagem de sucesso.


## E-028 · O brief virou seis argumentos e o CLI do OpenCode imprimiu o help (2026-11-25)

**O que aconteceu.** Despachei a T-P05-002 pelo `scripts/oc-brief.ps1`. O writer
"terminou" com exit 0 e deixou um log de 2.031 B. Abri o log: era o **help do
`opencode run`**, não a execução. O repositório do projeto continuou limpo — o brief
nunca foi lido. O brief tinha 16 aspas retas (`"`), do tipo *"Acesso negado"*.

**Por que aconteceu.** O `oc-brief.ps1` monta `@args` e chama o `.exe` nativo com o
prompt inteiro como **um** argumento. O PowerShell 5.1 **não escapa** aspas retas
embutidas ao passar string para executável nativo: o parser do processo corta ali.
Medido com uma sonda (`Get-Content -Raw` do brief → `python argv.py $p`): o arquivo
virou **6 argumentos** (`'linha1\n- item com Acesso'`, `'negado e Modo'`, …) em vez
de 1. Com argv quebrado, o CLI não achou mensagem válida e cuspiu a ajuda.

**Lição.** Antes de acusar o executor, medir o que ele **recebeu**. Sonda barata:
passar o mesmo texto por um programa que imprime `sys.argv`. E, ao escrever brief para
esse dispatcher, **não usar aspas retas** — usar “aspas tipográficas” ou `'simples'`.
Depois da troca, a mesma sonda mostrou `argv_count=1 / chars=6184` e o writer rodou.

**Custo.** Um dispatch perdido (~40 s), um brief de 6 kB reescrito e a dúvida de "o
writer não funciona" — quando o defeito era meu, no texto do brief.

**Efeito colateral bom:** exit 0 do dispatcher **não** é prova de execução. Vale a
regra de sempre — conferir `git status` do repo e o `tail` do log antes de reportar.

## E-029 · Declarei perfil inexistente sem listar o diretório (2026-11-25)

**O que aconteceu.** Ao registrar a pendência da T-P05-002, escrevi em `04-TAREFAS.md`
que o perfil `conversa` “não existe mais”. A T-P05-003 mostrou o contrário:
`C:\Users\Marlon\AppData\Local\hermes\profiles\conversa` existe — só não tem
`state.db`. Se o brief tivesse mandado “remover perfil inexistente”, teria apagado da
documentação um perfil real.

**Por que aconteceu.** Confundi “não aparece na série” com “não existe”. O coletor conta
`perfis_com_state_db` (4) e `perfis_total` (5); o quinto é justamente o `conversa`. Não
rodei `ls` no diretório antes de afirmar.

**Lição.** Para dizer que arquivo ou perfil sumiu, **listar a fonte** primeiro.
`perfis_com_state_db < perfis_total` quer dizer “sem banco”, não “inexistente”; a
documentação lista todos os diretórios e marca a ausência de dado como “sem dado”.

**Custo.** Uma frase errada em `04-TAREFAS.md`, corrigida às 02:04, e uma linha a mais
no doc de arquitetura do projeto — que o executor já tinha feito certo.

## E-030 · O print "antes/depois" era o topo da página nas duas vezes (2026-11-25)

**O que aconteceu.** Na T-P03-027, gerei 16 PNGs (8 combinações × antes/depois) com
`Page.captureScreenshot` sem `clip`, achando que o scroll feito por `scrollIntoView`
apareceria na imagem. Os PNGs de "antes" e "depois" saíram **byte-idênticos** — e eu os
tinha como prova visual da mudança. Só descobri ao conferir os pixels: os dois mostravam
o **topo** da página, 100% acima do CTA.

**Por que aconteceu.** `Page.captureScreenshot` captura a partir da origem do documento
quando não recebe `clip`, independente do scroll. E eu tinha "olhado" o arquivo pelo
tamanho (>18 KB) em vez de olhar o conteúdo — tamanho não diz o que a imagem mostra.

**Lição.** Print de região específica é **recorte calculado**: `clip` com coordenada
absoluta (`rect.top + window.scrollY`) e `captureBeyondViewport: true`. E print só é
prova depois de **lido por pixel**: em 25/11 conferi a faixa oliva do botão e a faixa
marrom do rodapé e a distância entre elas em cada PNG (96 px @1440, 72 px @390), batendo
com a medição do DOM. Print não conferido é arquivo, não evidência.

**Custo.** Uma rodada de 16 PNGs descartada e o script de captura reescrito. Nada falso
foi publicado: o defeito foi pego antes do relatório.

## E-031 · Dois escritores no mesmo repo: o órfão fez `reset --hard` e reescreveu o commit (2026-11-25)

**O que aconteceu.** Na T-P05-004 o `dispatch` do OpenCode gerou **duas** sessões escritoras
no mesmo repo: a principal e uma “peer”. Enquanto eu media, uma delas escreveu no log que
ia “deixar a outra terminar” e, às 08:47, o `git reflog` mostra `94b87f7 HEAD@{0} commit` /
`3ce9186 HEAD@{1} reset: moving to HEAD~1` / `947db95 HEAD@{2} commit`: o commit `947db95`
(08:41) foi **desfeito por reset** e refeito como `94b87f7`. Árvore final limpa e diff entre
os dois de só 15/−3 linhas em `painel.py`, mas o reset podia ter levado junto o que já
estava commitado.

**Por que aconteceu.** O despacho anterior deixou uma sessão `opencode-cli` viva; ela não
morre quando o `dispatch.py` termina. Eu não conferi “quantos escritores existem” antes de
medir, e `taskkill //PID` falhou no Git Bash (`Argumento/opção inválido - '//PID'`), o que
atrasou o encerramento.

**Lição.** Um repo, **um** escritor: antes de medir, contar processos do executor
(`Get-CimInstance Win32_Process` filtrando `opencode-cli ... run`) e encerrar a árvore;
matar com `powershell Stop-Process -Id <pid,familia> -Force`, não com `taskkill //PID`.
Depois do commit, **ler o `git reflog`** — reset/amend aparecem lá e invalidam medição
feita antes. Se o commit foi reescrito, medir de novo no HEAD final.

**Custo.** Uma rodada de medição descartada (as medições de layout eram do `947db95`),
duas sessões encerradas à força e o commit final registrado como `94b87f7`.

## E-032 · A skill que eu escrevi encheu a máquina de Edge até travar o Windows (2026-11-25)

**O que aconteceu.** O Marlon reiniciou o PC e, ao voltar, encontrou *"uns cinquenta
janelas do Microsoft Edge"* e o computador travado. A causa não era o painel: era o
harness de medição que o gestor do P-05 usou dezenas de vezes — e a raiz é minha.

**A medição.** Na sessão do `painel-p05`: 123 chamadas mexendo em CDP/Edge, **21 comandos
que executam `cdp_*.py`**, e vários deles encadeando 3–4 scripts (`cdp_medir2.py` +
`cdp_pares.py` + `cdp_overflow.py` + `cdp_cards.py`) numa linha só. Cada script abre um
Edge. 21 comandos × até 4 navegadores = **~50 processos**, que é o número que ele viu. O
log do painel confirma o rastro: **26 aberturas de página** entre 09:21 e 09:41, uma a cada
30–60 s.

**Por que vazou.** Todos esses scripts — inclusive **os dois da minha própria skill
`visual-verification-windows`** — faziam:

```python
proc = subprocess.Popen([msedge, "--headless=new", ...])
...
finally:
    proc.terminate()   # mata o lançador
```

O `Popen` devolve o **stub** do launcher. O navegador real é outro processo, com outro PID;
`terminate()` e `kill()` matam o stub e deixam o navegador vivo. Um por chamada, sem teto,
sem reuso. Eu distribui esse padrão na skill e o gestor o copiou — o defeito é meu, não
dele.

**O que fiz.** Medi antes de consertar: rodei o script dele e contei `msedge.exe` antes e
depois (0 → 1 nas falhas, 0 nas execuções que terminavam "limpo" — a prova de que o
`finally` mentia). Quarentenei os 6 scripts (`*.quarentena-20261125`) com um `LEIA-ANTES`
na pasta; corrigi os **dois da minha skill** para matar por `--user-data-dir` + porta e
apagar o perfil; e escrevi **uma** ferramenta endurecida,
`scripts/medir-cdp.py`, com reuso de instância viva, trava de **30 lançamentos/hora**,
timeout de 40 s e `taskkill /T /F` no `finally`. Teste: 4 medições, 1 navegador, **0
processos sobrando** depois.

**Lição.** `Popen` não é o navegador. Quem garante teardown é o *recurso* (perfil e porta),
nunca o PID que você guardou. E ferramenta de medição usada em laço precisa de **teto**:
sem reuso e sem limite, cada verificação vira um processo — e a conta chega em dezenas.

**Regra que fica.** Medição com navegador: um por sessão, reutilizado, com limite de
lançamentos e teardown por perfil. Proibido `Start-Process <url>` / `start <url>` para
"abrir e conferir".

## E-033 · "Banner de consentimento no HTML" não é consentimento: 6 cookies antes do clique (2026-11-25)

**O que aconteceu.** Na auditoria do P-03 (M-011) eu ia fechar o eixo "consentimento"
como **aprovado**, porque o HTML servido trazia o Complianz completo:
`body data-cmplz=1`, `cmplz-cookiebanner-1-optin`, as 4 categorias
(`cmplz-desc-{functional,marketing,preferences,statistics}-1-optin`), `cmplz-js`. Um
banner configurado, no ar, com categorias de marketing — dá para assinar em cima disso.

**A medição que desmentiu.** Abri o site em perfil de navegador **limpo**, **sem clicar
em nada**, e li `document.cookie` + `Network.getAllCookies`: `_ga`,
`_ga_NGGYW0ZYHP`, `__hstc`, `hubspotutk`, `__hssc`, `__hssrc` — GA4 e HubSpot gravando
**antes** de qualquer aceite. E `gtag('consent','default',…)`: **0** ocorrências.
Banner presente, bloqueio inexistente.

**Por que quase passou.** O que se vê é o banner; o que se mede é o cookie. Eu estava
lendo a intenção do cliente (proteger o visitante) em vez do efeito no navegador.

**Regra que fica.** Consentimento só se mede em perfil limpo, **sem clique**: liste os
cookies e procure `gtag('consent'`. Banner configurado com categoria "marketing" não
prova bloqueio — e para Google Ads tráfego com falta de Consent Mode v2 é risco de
conta, não detalhe de LGPD.

## E-034 · Duas medições de INP inválidas antes de uma certa: o clique precisa ser de confiança (2026-11-25)

**O que aconteceu.** Medindo INP da home do P-03 pelo `medir-cdp.py`: a primeira rodada
clicou em `y=5376` com `scrollY=9367` (coordenada lida **antes** do `scrollIntoView`
assentar — o site tem *smooth scroll*) e saiu `INP 24 ms / 3 eventos`; a segunda, com o
alvo já centrado (`y=422`), deu **`INP None / 0 eventos`** porque
`Input.dispatchMouseEvent` mandava só *pressed/released*, sem `mouseMoved` e sem
`buttons`. As duas parecem resultado; nenhuma era.

**O que consertou.** (1) `scrollIntoView({block:'center', behavior:'instant'})` numa
chamada, `sleep 0.4`, e só então ler `getBoundingClientRect` — devolvendo também o `tag`
do alvo para provar **o que** foi clicado; (2) sequência
`mouseMoved(buttons:0) → mousePressed(buttons:1) → mouseReleased(buttons:0)` com
`clickCount` coerente. Resultado: `clique tag=BUTTON.forminator-button-next`, **INP 16 ms
com 5 eventos**, CLS 0,244 estável em 5 leituras.

**Regra que fica.** Medição de interação prova três coisas ou não vale: **qual elemento**
foi atingido (o `tag` no retorno), **que houve evento** (contagem > 0) e **que o número
repetiu**. `INP: None` com 0 eventos é falha do harness, nunca "não se aplica".

---

## E-035 · Repetição pendurada em gatilho AtLogOn nunca dispara sem logon (2026-11-25)

**O que aconteceu.** O autostart do P-05 (T-P05-009) foi entregue com a tarefa
`PainelHermes-Painel` tendo **um** gatilho `AtLogOn` com `Repetition.Interval = PT5M`.
O executor provou com `Start-ScheduledTask` e relatou `LastTaskResult: 0` — passou por
entregue. A medição do gestor matou o painel e esperou **6 minutos** em poll de 15 s:
`http=000` nas 24 leituras, nenhuma linha no log. `Get-ScheduledTaskInfo` entregava o
sintoma que ninguém tinha lido: **`NextRunTime` vazio** e `LastTaskResult 267011`
(0x41303, "nunca executou").

**Por que acontece.** A repetição de um gatilho de logon é ancorada no **evento de
logon**. Registrada a tarefa no meio da sessão, não há logon posterior — logo não há
"próxima execução" e o Agendador não repete nada. A tarefa fica `Ready`, sem erro, sem
log, e o `Start-ScheduledTask` funciona: tudo parece certo até alguém esperar o relógio.

**O que consertou.** Segundo gatilho `MSFT_TaskTimeTrigger` ancorado no relógio
(`-Once -At (agora+1min) -RepetitionInterval 5min`, duração `P3650D` porque o Agendador
recusa `TimeSpan.MaxValue`), mantendo o AtLogOn para o boot; e **portão no instalador**:
`exit 5` se `NextRunTime` vier vazio ou longe demais, para não declarar sucesso com
tarefa que nunca vai rodar.

**Regra que fica.** Prova de agendador é **esperar o relógio**, nunca `Start-ScheduledTask`
(disparo manual prova o script, não o gatilho). E `NextRunTime` vazio é reprovação, não
detalhe: tarefa `Ready` sem próxima execução é tarefa morta.

## E-036 · O brief não saiu porque o caminho era de bash, não do Windows (2026-11-25)

**O que aconteceu.** Despachei o primeiro brief do P-06 com
`powershell -File /c/MarlonScripts/2-Gestor/scripts/oc-brief.ps1`. O PowerShell respondeu
*"O argumento '/c/MarlonScripts/...' para o parâmetro -File não existe"* — em português, no
início da saída — e **saiu com código 0** porque o `| tail -25` fechou o pipe com sucesso.
Nenhum arquivo apareceu no projeto e por alguns minutos eu achei que o OpenCode estava
"pensando".

**A causa.** O bash/MSYS traduz caminhos para programas nativos **quando quer**; neste host
a conversão está desligada. `powershell`, `python`, `git`, `node` recebem `/c/...` como
texto literal e não acham nada. Só os builtins do bash (`cd`, `ls`) entendem.

**Como descobri.** Não descobri pela saída — descobri porque fui conferir o projeto e não
havia `scripts/`. Aí li a saída inteira do processo em background, em vez do `tail`.

**Lição.** Dois hábitos que teriam evitado:
1. **Caminho nativo (`C:\...`) em tudo que não é builtin do bash.** Em dúvida, `cygpath -w`.
2. **`| tail` esconde a primeira linha — que é justamente onde o erro aparece.** Quando o
   comando é um despacho, redirecione para arquivo e leia o começo **e** o fim.

**Regra que fica.** Despacho só é despacho quando existe sinal no destino (arquivo novo,
log, `git log`). Saída 0 do PowerShell não é sinal de nada.

## E-037 · Arquivo compartilhado + `git add` do arquivo inteiro = varrer o vizinho (2026-11-25)

**O que quase aconteceu.** O gestor do P-06 precisou commitar quatro linhas suas em
`DOCS/04-TAREFAS.md` — o mesmo arquivo em que o gestor do P-03 tinha acabado de registrar
T-031/T-032. `scripts/commit-agent.sh` fazia `git add --` no arquivo inteiro: as linhas do
P-03 teriam entrado no commit do P-06, com a assinatura errada. Ele percebeu, contornou com
`git apply --cached` e avisou.

**Por que a guarda de E-027 não pegou.** Ela compara *quais arquivos* estão no stage com os
nomeados — e o arquivo estava nomeado. O que ela não vê é que **pedaços de outro autor**
viajam dentro do mesmo arquivo.

**Como corrigi.** `commit-agent.sh` ganhou o modo `SEM_ADD=1`: o chamador encena o que quer
(`git apply --cached`), o script **não adiciona nada**, valida o stage e commita. Teste em
repo descartável: dois arquivos sujos, um encenado, `SEM_ADD=1` → commitou só o encenado e
deixou o outro `M` na árvore. Stage vazio → `erro: SEM_ADD=1 mas o stage esta vazio`.

**Lição.** Em workspace com vários escritores, **arquivo compartilhado é território
disputado**: a unidade de commit não é o arquivo, é o pedaço. Quem precisa de precisão usa
`git apply --cached` + `SEM_ADD=1`; quem usa `git add` de arquivo inteiro está apostando que
ninguém mexeu nele no mesmo minuto.
## E-038 · O critério de aceite que o próprio gate de versão tornava impossível (2026-11-25)

No brief da 404 (T-P03-032) escrevi, como critério de aceite, que o `--dry-run` deveria dar
**"11 iguais, 0 divergentes, 1 novo"**. É aritmeticamente impossível: o mesmo brief manda
subir a versão, e subir a versão faz `style.css` e `functions.php` divergirem do servidor.
O máximo honesto naquele momento era **9 iguais + 2 divergentes + 1 novo**.

O OpenCode **não forçou** o número: reportou que o dry-run dava 9 + 2 + 1, escreveu que o
critério estava errado, e seguiu. Se ele tivesse "consertado" a versão para bater o número,
teria entregado um tema com a versão velha — e eu teria aceitado com a minha própria régua.

**Por que aconteceu.** Escrevi o critério pensando só no arquivo novo e esqueci que o gate
de versão (`release.json` + `version` no cabeçalho) mexe em dois arquivos por definição. O
critério nasceu do que eu queria ver, não de simular o que a ferramenta faz.

**Como corrigi.** Registrei a tarefa com os números reais (9/2/1) no `04-TAREFAS.md`, e os
dois briefs seguintes levam o número já calculado com a regra do gate: o da rodapé (T-033)
diz **"4 divergentes, 0 novos"** e explica por quê.

**Lição.** Critério de aceite numérico tem de ser **simulado contra a ferramenta**, não
estimado: se o brief manda uma ação (bump, migração, rename), o número esperado muda por
consequência dela. Critério impossível é pior que critério nenhum — ele ensina o executor a
maquiar resultado ou a te devolver a bola. Quando o executor contesta um número, a primeira
hipótese é que ele está certo.

## E-038 · Um agente commitou com a identidade do Marlon (2026-11-25)

**O que aconteceu.** O commit `578b4b9` no repo da Jessica Haguiwara — a mudança do texto de
WhatsApp do rodapé — saiu com autor **"Marlon Rebello Viana <marlonrviana@gmail.com>"**. Não
foi o Marlon que fez. Foi um agente que rodou `git commit` sem `-c user.name` / `-c
user.email`, e o git pegou a identidade **global** da máquina.

**Por que importa.** O `git log` é a resposta para "quem fez isso e quando". Se agente assina
como o DEV, o histórico mente: daqui a três meses o Marlon vai olhar um commit, achar que
foi ele, e não vai lembrar. Pior: apaga o rastro de qual agente errou o quê — que é
justamente o que o `commit-agent.sh` existe para evitar.

**Como aconteceu sem ninguém notar.** `commit-agent.sh` sempre passou identidade própria
(`git -c user.name=... commit`). O buraco é o comando cru: qualquer `git commit` avulso
dentro de um agente cai na identidade global. E ninguém checa autor depois.

**O que fiz.** Hook `pre-commit` que **recusa** commit cujo `GIT_AUTHOR_EMAIL` seja o do
Marlon, instalado nos quatro repos (2-Gestor, Jessica, Painel, P-06) por
`scripts/instalar-hook-identidade.sh`. Teste em repo descartável: commit com a identidade
dele → `COMMIT RECUSADO`, e o commit não acontece; commit com `GESTOR-P03` → passa.

**Lição.** Regra que depende de disciplina não é regra, é intenção. A identidade do commit
tem que ser **imposta pelo repositório**, não lembrada pelo agente. O hook é a diferença
entre "a gente combinou" e "não é possível".

**Nota honesta.** O commit `578b4b9` já está na história e **não se reescreve** (regra do
Marlon). Ele fica; o que muda é que não acontece de novo.

## E-039 · Matar o wrapper não mata o executor (2026-11-26)

**O que aconteceu.** Matei o processo `oc-brief.ps1` no meio da T-P06-017 para liberar o repo
e despachar a correção do painel (T-P06-018). O `opencode-cli` **não morreu com o pai**: seguiu
trabalhando, terminou e commitou (`850d208`) **61 segundos depois** de o segundo executor
começar. Dois escritores no mesmo repo, na mesma janela.

**Por que importa.** A regra "um escritor por vez" não é etiqueta: dois agentes no mesmo
diretório podem commitar arquivo um do outro, ou `git checkout` em cima de trabalho alheio.
Nesta vez as áreas não se cruzaram por sorte, não por controle.

**Lição.** Para parar um executor: `taskkill /PID <pid do opencode-cli> /F`, não o wrapper.
E antes de despachar outro brief no mesmo repo, `git log -1` + `tasklist` para confirmar que
ninguém está escrevendo.

**Corolário.** O gestor do P-06 detectou a colisão sozinho, pelo horário dos commits. O
sistema funcionou na detecção — o erro foi do Gerente na origem.

## E-040 · A lista de processos do agente não é a verdade (2026-11-26)

**O que aconteceu.** Despachei o gestor do PDF TTS em background (sessão `proc_1f0f49acd7c9`).
Minutos depois, o `process_manage` respondeu `not_found` e a lista não trazia a sessão — concluí
que ela tinha morrido e despachei de novo. **A primeira continuava rodando**: árvore
`bash 22904 → hermes.exe 22896 → python 13884`, viva, com 224 mensagens gravadas. Duas sessões
de gestor trabalhando no mesmo projeto ao mesmo tempo, de novo.

**Por que importa.** "O executor disse" e "minha ferramenta disse" são as duas fontes que já me
traíram. O `not_found` do rastreador pode significar: processo morto, sessão expirada do
registro, ou troca de gateway. **Nenhuma delas prova morte.**

**Lição.** Antes de re-despachar: `Get-CimInstance Win32_Process | Where CommandLine -like '*<perfil>*'`.
Se aparecer árvore viva, **não é morte** — é sessão órfã do rastreador. Matar com
`taskkill /PID <raiz> /T /F` e só então re-despachar.

**Onde a sessão mora.** `profiles/<perfil>/state.db` (SQLite: `sessions`, `messages` + FTS).
A pasta `sessions/` fica vazia; `runtime/active_sessions.json` só registra sessão interativa —
one-shot (`hermes -z`) não aparece lá. O app de desktop lista as sessões do **perfil ativo**;
sessão de outro perfil só se vê com `hermes -p <perfil> --resume`.

## E-041 — Dois executores no mesmo brief porque o background parecia morto

**Data.** 2026-11-26, T-P03-038.

**O erro.** Despachei o brief em background; o log do wrapper ficou vazio e o `ps` não
mostrou o PID. Concluí "morreu" e re-despachei o mesmo brief em foreground. Os dois
rodaram: o primeiro aplicou a mudança e commitou `16e325f`; o segundo bateu no gate
`existe=false` e parou sem escrever, mas commitou `e11942c` (docs) e relatou BLOQUEADO.
Resultado: dois escritores no mesmo brief, dois commits, dois relatórios contraditórios.

**Por que importa.** O E-040 diz literalmente que `not_found`/log vazio não prova morte e
manda checar `Get-CimInstance Win32_Process` antes de re-despachar. Eu li a lição e não a
apliquei. Num brief com escrita, o segundo executor poderia ter sobrescrito o primeiro.

**Lição.** Antes de re-despachar: (1) `Get-CimInstance Win32_Process | Where CommandLine
-like '*opencode*'`; (2) olhar o log do OpenCode em `logs/oc-*.log` (o wrapper só escreve o
cabeçalho; o CLI escreve no arquivo dele); (3) se houver dúvida, **esperar** o
`notify_on_complete` em vez de abrir uma segunda sessão. Um brief, um escritor, um commit.

## E-042 — "A API mentiu" era GET com o arquivo na query (2026-11-26)

**Data.** 2026-11-26, T-P03-039.

**O erro.** Por semanas o `deploy-theme.mjs` carregou o comentário de que
`Fileman::upload_files` "mentia por omissão": devolvia `succeeded: 3, failed: 0` e não
gravava nada. A conclusão virou premissa no código, o script passou a mandar binário como
texto (`buf.toString('utf8')`) e o AVIF chegava corrompido — foi o que bloqueou o deploy
da T-035.

**A causa.** A primeira tentativa mandava **todos** os parâmetros por query string,
inclusive o arquivo, que virava um parâmetro chamado `content`. O cPanel descarta
parâmetro de query com prefixo `file-`: nunca houve arquivo no corpo. A API respondeu ao
que recebeu (uma requisição sem arquivo). Upload é POST `multipart/form-data` com
`file-0`/`file-1` + nome no corpo e `dir`/`overwrite` na query — medido na T-039 com
sha256 local = servidor.

**Lição.** Antes de concluir que uma API "mente", conferir o transporte: método,
`Content-Type` e onde cada parâmetro vai. Sucesso para operação que não aconteceu quase
sempre é o servidor respondendo a uma requisição vazia. E o teste que prova o conserto
tem de **importar a função do deploy**, não uma cópia: cópia passa e o deploy segue
quebrado.

## E-043 — Proatividade revogada por consumo excessivo de tokens (2026-11-26)

**Data.** 2026-11-26, decisão do Marlon.

**O erro.** A persona do Gerente (`SOUL.md`, seção "Postura") mandava "esgotar as opções
seguras e reversíveis", "esperar é um modo de falha" e "cuida do máximo que puder, sem
precisar ser mandado duas vezes". O item 22 do `Dos GERENTES.md` (à época) mandava "máximo
progresso na minha ausência". Juntos, transformaram um pedido pontual — resolver commits
multiparalelo — numa fila paralela de tarefas do P-03, briefs, perguntas e commits.
Consumo alto de tokens sem pedido.

**A causa.** Proatividade genérica virou mandato de expandir escopo. Faltava a âncora:
**o escopo é o pedido literal do Marlon**.

**Lição.** Trabalho autônomo e máximo progresso **somente quando o Marlon pedir**.
Planejar, registrar o plano e apresentar ao DEV **antes** de executar. Não puxar fila
antiga por conta própria. Vale para Gerente e Gestor; o Gerente mantém a autonomia de
mandar o gestor continuar tarefa já autorizada. Respostas curtas.
