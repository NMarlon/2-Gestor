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

## E-015 · Número medido logo depois do purge não vale (2026-11-20)

**O que aconteceu:** medi a home e as 3 subpáginas assim que limpei WPFC + proxy.
A home deu o valor final e correto; as 3 subpáginas deram **+46 B** cada. Passei
esse número para o registro e o OpenCode, ao conferir, achou outro valor — e
concluiu que "o HTML varia por requisição". Nós dois estávamos errados: repeti 3×
por página e os bytes são **idênticos**. O estado pós-purge ainda estava mudando
(tags de preload/minify do plugin se reorganizando).

**Regra:** depois de limpar cache, a primeira leitura serve para saber *se*
mudou, não *quanto*. Medir, esperar, medir de novo e registrar o valor estável —
com duas leituras iguais. Se as leituras divergirem, a causa é o cache, não o
site, até prova em contrário.

**Corolário:** quando o executor contradiz um número meu, o contradito pode ser
eu. Reprovar a premissa dele sem refazer a medição é a mesma falta de rigor.

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
