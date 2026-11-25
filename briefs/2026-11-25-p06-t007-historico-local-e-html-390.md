# T-P06-007 · histórico local separado + HTML do relatório legível no celular

**Projeto:** P-06 — Alerta de Planejamento Missionário (CTM)
**Repo:** `C:\MarlonScripts\81 - Alerta Planejamento Missionario CTM`
**Data:** 2026-11-25
**Origem:** M-017 do Gerente, itens 1 e 3
**Executor:** OpenCode (`OPENCODE-P06`)

## Escopo único

Fechar as **duas** correções que o Gerente pediu na M-017 para encerrar a T-P06-001:

- **A.** `--fonte local` deixa de gravar no histórico real.
- **B.** O HTML do relatório deixa de estourar a tela do celular.

Nada além disso. Não é para reescrever o motor, não é para "melhorar" o diff.

## CONTEXTO JÁ VERIFICADO (não re-investigue)

Leia isto e comece pelo código; não repita essas medições.

1. O motor foi entregue em `de5be3c` e o Gerente **mediu e aprovou** os três critérios de
   aceite (diff local com 3 tipos de mudança, `--dry-run` sem gravar, execução real saindo 1
   com a recusa do Google). **Não reabra esse aceite.**
2. `historico.json` está hoje exatamente com o conteúdo `[]` (2 bytes): o Gerente apagou à mão
   a entrada `[local]` que o teste tinha gravado. Ele **não pode mudar** nesta tarefa.
3. Onde o histórico local suja o real, em `scripts/verificar.py`:
   - `executar_local()` lê `raiz / "historico.json"` (linhas 731-733);
   - grava nas linhas 769-781 (caso texto idêntico) e 798-810 (caso com mudança);
   - `main()` imprime sempre `RAIZ / "historico.json"` no `--historico` (linhas 877-878).
4. Política de commit **já aplicada** e conferida pelo gestor com `git check-ignore -v`:
   `dados/snapshots/`, `dados/*.pdf`, `testes/` e `__pycache__/` são ignorados;
   `historico.json` e `relatorios/` são versionados; `git ls-files -i -c --exclude-standard`
   devolve vazio (nenhum arquivo rastreado está ignorado). **Não mexa nessa política** além
   do item A.5 abaixo.
5. Medição do HTML de hoje, feita pelo gestor com
   `python C:\MarlonScripts\2-Gestor\scripts\medir-cdp.py` (Edge headless, `file://`):
   - **390×844:** `documentElement.clientWidth` = 390, mas `innerWidth` = **544** — o
     navegador encolheu a página para caber — e `scrollWidth` = **544**, ou seja **154 px de
     estouro horizontal**. Culpado principal: o `<code>` do sha256 completo, com **515 px**
     de largura e borda direita em 540. A tabela tem 379 px e termina em 399 (9 px além da
     borda de 390). Altura do documento: 1179 px.
   - **1280×900:** `innerWidth` 1280, conteúdo 1080, tabela 1040, **sem estouro**; altura do
     documento 900. Colunas: Página 85, Tipo 238, Antes 333, Depois 383.
6. Só existe um HTML para medir: `relatorios/teste-local.html` (o real está bloqueado pela
   `Q-040`). Os PDFs de teste existem em `testes/v1.pdf` e `testes/v2.pdf`.
7. Python do projeto: `C:\Users\Marlon\AppData\Local\Programs\Python\Python311\python.exe`
   (o `python` do PATH já resolve para ele). `pymupdf` 2.1 instalado.

## A. Histórico local separado do real

Decisão do gestor: arquivo separado, não `--registrar` obrigatório.

1. `executar_local()` passa a ler, gravar e checar idempotência em
   `raiz / "historico-local.json"` — mesmo formato de lista, mesmas entradas com
   `"origem": "local"`. O fluxo do Drive continua usando `historico.json` e nada mais.
2. `--historico` sem argumento continua imprimindo o **real** (`historico.json`).
   `--historico local` passa a imprimir o local. Sugestão de assinatura:
   `parser.add_argument("--historico", nargs="?", const="real", choices=("real","local"))`
   e `imprimir_historico` recebe o caminho escolhido.
3. Se `historico-local.json` não existir, o primeiro teste local cria; não há migração a
   fazer (o real está vazio).
4. Mensagens: quando a idempotência do teste local for acionada, a frase deve dizer que é o
   **teste local** (já diz), sem mencionar o histórico do planejamento.
5. `.gitignore`: acrescentar `historico-local.json` e `historico-local.json.tmp`.

## B. HTML do relatório legível em 390

Regra de negócio: quem recebe o relatório abre no celular. Quatro colunas espremidas em
390 px não se lê. O gerador é `gerar_html()` em `scripts/verificar.py` (CSS embutido).

1. **Zero estouro horizontal em 390.** Nenhum elemento pode ter `scrollWidth` maior que o
   próprio `clientWidth` (+1 px de tolerância) nem borda direita além de 390 — inclusive o
   `<code>` do sha256 e os caminhos longos. `overflow-wrap: anywhere` em `code` e nas células
   resolve a parte do texto.
2. **Celular vira cartão, não tabela apertada.** Até 600 px de largura, cada mudança é um
   bloco empilhado com os rótulos **Página / Tipo / Antes / Depois** visíveis junto ao
   conteúdo (via CSS `@media` e `td::before`, sem JavaScript e sem mudar o HTML gerado além
   do necessário). A partir de 601 px a tabela de 4 colunas volta como está hoje em 1280.
3. **Não use rolagem horizontal como solução** (nem em `body`, nem em `div` em volta da
   tabela): a célula com `overflow-x: auto` reprova no critério 1 do aceite.
4. `@media print` continua funcionando (a folha impressa não pode herdar o cartão).
5. Regenere `relatorios/teste-local.html` e `relatorios/teste-local.md` rodando o fluxo
   local — o `.md` não muda de conteúdo, mas os dois arquivos são o produto versionado.

## Proibições

- **Não** toque em `C:\MarlonScripts\2-Gestor\scripts\medir-cdp.py` — é ferramenta
  compartilhada, fora deste repo, e mudança nela passa pelo Gerente antes.
- **Não** altere `historico.json` (hoje `[]`), nem apague registros, nem invente entrada.
- **Não** mexa na lógica de download/recusa do Drive, no diff, no limiar, nos snapshots.
- **Não** tente contornar a `Q-040` (nada de OCR, `gdown`, cookie ou preview PNG como se
  fosse PDF). A execução real tem de continuar saindo **1** com o motivo.
- **Não** escreva em `C:\MarlonScripts\2-Gestor\` (briefs, DOCS do workspace). Isso é meu.
- **Não** crie arquivo fora do repo, exceto os prints de evidência em
  `testes\evidencia-20261125\` (já ignorado pelo git).

## Critério de aceite (eu meço depois; você mede antes e cola os números)

### A — histórico

```bash
cd "C:/MarlonScripts/81 - Alerta Planejamento Missionario CTM"
md5sum historico.json                      # anote
python scripts/verificar.py --fonte local --antes testes/v1.pdf --depois testes/v2.pdf
echo "exit=$?"                             # esperado 10
md5sum historico.json                      # TEM de ser igual ao anotado
cat historico-local.json                   # 1 entrada, origem local
python scripts/verificar.py --fonte local --antes testes/v1.pdf --depois testes/v2.pdf
echo "exit=$?"                             # esperado 0, "sem mudanças"
python scripts/verificar.py --historico            # "histórico vazio"
python scripts/verificar.py --historico local      # 1 leitura
rm historico-local.json
python scripts/verificar.py --dry-run --fonte local --antes testes/v1.pdf --depois testes/v2.pdf
test -e historico-local.json && echo FALHOU || echo "dry-run não gravou"
python scripts/verificar.py --fonte local --antes testes/v1.pdf --depois testes/v2.pdf   # recria p/ o relatório
git status --short                          # historico-local.json NÃO pode aparecer
```

### B — HTML

Você mede e cola os números; eu repito a medição. Gravar os prints em
`testes/evidencia-20261125/`.

```bash
JS='JSON.stringify((()=>{const W=document.documentElement.clientWidth;const off=[...document.querySelectorAll("body *")].filter(e=>{const r=e.getBoundingClientRect();const s=e.scrollWidth>e.clientWidth+1;return r.right>W+1||s}).map(e=>e.tagName+"."+String(e.className||"")+" right="+Math.round(e.getBoundingClientRect().right)+" scroll="+e.scrollWidth+"/"+e.clientWidth);return {innerWidth:innerWidth,clientWidth:W,scrollDoc:document.documentElement.scrollWidth,alturaDoc:document.documentElement.scrollHeight,th:document.querySelectorAll("table.mudancas th").length,off:off.slice(0,10)}})())'
python "C:/MarlonScripts/2-Gestor/scripts/medir-cdp.py" "file:///C:/MarlonScripts/81%20-%20Alerta%20Planejamento%20Missionario%20CTM/relatorios/teste-local.html" 390 844 testes/evidencia-20261125/html-390.png --js "$JS"
python "C:/MarlonScripts/2-Gestor/scripts/medir-cdp.py" "file:///C:/MarlonScripts/81%20-%20Alerta%20Planejamento%20Missionario%20CTM/relatorios/teste-local.html" 1280 900 testes/evidencia-20261125/html-1280.png --js "$JS"
```

Esperado em **390**: `innerWidth` 390, `scrollDoc` 390, `off` vazio (`[]`). Em **1280**:
`innerWidth` 1280, `scrollDoc` 1280, `th` 4, `off` vazio. O `alturaDoc` você reporta, não
precisa bater valor.

A ferramenta lança no máximo 30 navegadores por hora e derruba o processo no fim; não rode
mais de 4 medições.

## Docs do repo (parte da entrega)

- `DOCS\03-TAREFAS.md`: acrescentar a linha da **T-P06-007** como concluída, com data e o
  resultado medido.
- `DOCS\02-ARQUITETURA.md`: onde lista os arquivos do projeto, incluir `historico-local.json`
  como estado de teste local (ignorado pelo git).

## Commit

Um commit no repo do projeto, assinatura própria de executor, caminhos explícitos:

```bash
git add scripts/verificar.py .gitignore relatorios/teste-local.html relatorios/teste-local.md DOCS/03-TAREFAS.md DOCS/02-ARQUITETURA.md
git -c user.name="OPENCODE-P06" -c user.email="p06@2gestor.local" commit -m "P-06: T-P06-007 historico local separado e HTML legivel em 390"
```

Sem `git add -A`, sem `--amend`, sem push (o repo não tem remote).

## Contrato de retorno

Responda exatamente com:

```
RESULTADO: (uma linha)
status: concluido | parcial | bloqueado
arquivos_alterados: (caminho + o que mudou, um por linha)
comandos_executados: (os que importam, com a saída relevante colada)
evidencia: os números medidos em 390 e em 1280 (innerWidth, scrollDoc, alturaDoc, th, off)
nao_testado: (o que você NÃO rodou)
riscos: (o que pode quebrar)
proximo_passo: (se houver)
```

Número colado ou não vale. Se algo do brief contradisser o código, pare e reporte em vez de
improvisar.
