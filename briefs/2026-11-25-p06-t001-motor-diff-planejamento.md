# Brief — P-06 · T-P06-001 · motor de detecção de mudanças no planejamento (CTM)

**Data:** 2026-11-25 · **Executor:** OpenCode · **Dir:** `C:\MarlonScripts\81 - Alerta Planejamento Missionario CTM`

## Resultado esperado

Um script que baixa o PDF de planejamento do Google Drive, extrai o texto, **compara com
a versão anterior** e escreve um relatório legível dizendo o que mudou — pronto para o
Marlon mostrar aos missionários.

## CONTEXTO JÁ VERIFICADO (não re-investigue)

- Pasta pública: id `1-7w0EpMvo8mIWlFcLSjVJEgwaWR5bYdJ`.
  Listagem funciona por
  `https://drive.google.com/embeddedfolderview?id=<ID>#list` → devolve 1 arquivo: `POR6.4.pdf`.
- O id do arquivo hoje é `1M_xdtXz-rkScXMg-i3rS57Kq7HmXrY5O`
  (`https://drive.google.com/file/d/1M_xdtXz-rkScXMg-i3rS57Kq7HmXrY5O/view` abre, título
  `POR6.4.pdf - Google Drive`).
- **Download bloqueado pelo dono.** `https://drive.google.com/uc?export=download&id=<ID>`
  devolve HTML de 1820 bytes com a frase exata:
  *"Sorry, the owner hasn't given you permission to download this file. Only the owner and
  editors can download this file."* Testado também com cookie de sessão e com `gdown`:
  mesmo resultado. A página de preview (`/file/d/<ID>/preview`) responde 200 e o
  `drive-viewer/...` devolve **PNG** (imagem renderizada), não PDF.
- Python do painel: `C:\Users\Marlon\AppData\Local\Programs\Python\Python311\python.exe`,
  com **pymupdf 2.1** instalado (`import fitz` funciona, com FutureWarning).
- Não existe `config.json`, `scripts/`, `historico.json` ainda. `dados/POR6.4.pdf` existe
  mas está **corrompido de propósito** (é o HTML de recusa) — apague ou sobrescreva.

## Escopo (o que construir)

1. **`config.json`** — `pasta_id`, `padrao_nome` (regex, default `POR(\d+(?:\.\d+)*)\.pdf`),
   `pasta_dados`, `pasta_relatorios`. Sem segredo nenhum.
2. **`scripts/extrair.py`** — `extrair(caminho_pdf) -> {"paginas": [texto, ...], "n": N, "sha256": ...}`
   usando pymupdf. Normalizar: `\r\n`→`\n`, colapsar espaços, juntar palavra hifenizada no
   fim da linha (`plane-\njamento` → `planejamento`), tirar linha em branco repetida.
3. **`scripts/diff.py`** — compara dois textos por página e devolve:
   - `paginas_adicionadas`, `paginas_removidas`;
   - por página: `linhas_adicionadas` / `linhas_removidas`;
   - para linhas parecidas (≥ 0,6 de similaridade via `difflib.SequenceMatcher`), um par
     `antes`/`depois` com o diff **por palavra** (destaque só nas palavras que mudaram).
4. **`scripts/verificar.py`** — orquestra:
   1. lista a pasta (`embeddedfolderview`), acha o arquivo mais novo pelo padrão;
   2. baixa com UA de navegador; se vier HTML, **detecta a recusa** e sai com código 1
      imprimindo a frase do Google (nunca "sem alterações");
   3. sha256; se igual ao último registro → `sem mudanças`, código **0**;
   4. extrai texto, compara com o snapshot anterior, grava
      `dados/snapshots/<AAAAMMDD-HHMM>-<sha8>.pdf` + `.txt`, atualiza `historico.json`
      (lista de `{quando, arquivo, sha256, paginas, resumo}`) e escreve
      `relatorios/ultima-alteracao.md` e `.html` → código **10**;
   5. `--dry-run`: faz tudo menos gravar snapshot/histórico/relatório;
   6. `--fonte local --antes A.pdf --depois B.pdf`: exercita o motor **sem rede**;
   7. `--historico`: imprime a lista do `historico.json`.
5. **Relatório `.md`**: cabeçalho com arquivo, sha256 (8 primeiros), data/hora e nº de
   páginas; depois tabela `Página | Tipo | Antes | Depois`. Sem opinião, sem enfeite.
   **`.html`**: mesma tabela, CSS inline, legível ao imprimir.

## Proibido

- Tocar em qualquer coisa fora da pasta do projeto.
- Escrever credencial, cookie ou token em arquivo, log ou commit.
- Criar tarefa no Agendador, publicar na internet, abrir navegador.
- `pip install` de qualquer coisa além do que já está (pymupdf 2.1 está).
- Inventar conteúdo do planejamento: o relatório só mostra o que veio do PDF.

## Critério de aceite (verificável por mim)

1. `python scripts/verificar.py --fonte local --antes testes/v1.pdf --depois testes/v2.pdf`
   gera relatório com **pelo menos** uma linha alterada, uma adicionada e uma removida.
   Você cria os dois PDFs de teste com pymupdf (texto simples, 2–3 páginas).
2. `python scripts/verificar.py --dry-run` **não** cria nem altera arquivo em
   `dados/snapshots/`, `historico.json` ou `relatorios/` (prove com `git status` ou
   listagem de mtime antes/depois).
3. `python scripts/verificar.py` (Drive real) sai com **código 1** e imprime a frase do
   Google sobre permissão de download — porque é o estado real hoje.
4. Duas execuções seguidas com `--fonte local` sobre os mesmos PDFs: a segunda não duplica
   entrada no histórico.

## Contrato de retorno

`RESULTADO / status / arquivos_alterados / comandos_executados / evidencia (saída real dos
3 testes) / nao_testado / riscos / proximo_passo`. Commit no repo do projeto com
`git -c user.name="OPENCODE-P06" -c user.email="p06@2gestor.local" commit`, só caminhos
explícitos.
