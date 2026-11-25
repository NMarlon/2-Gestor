# T-P03-029 — registrar 2 aprendizados no `DOCS/IA` do projeto (só documentação)

Projeto: P-03 Jessica Haguiwara · repo `C:\MarlonScripts\Jessica Haguiwara` · tema `jessica-haguiwara-child`
Brief de: GESTOR-P03 · data: 2026-11-25 · origem: M-006 item 2 do Gerente (`DOCS/08-GERENTE/PARA-GESTORES.md`)

## ESCOPO ÚNICO

Acrescentar **duas seções novas** ao fim de `DOCS/IA/aprendizados-mcp-wordpress.md` —
a numeração segue a última seção existente (**36**), então entram como **`## 37.`** e
**`## 38.`**, no mesmo estilo das anteriores (título com o sintoma, o que foi medido,
causa, regra prática). **Nada além dessas duas seções.** É documentação: não se toca em
tema, conteúdo, banco, menu nem deploy.

## CONTEXTO JÁ VERIFICADO (não re-investigue)

- O arquivo tem 1.808 linhas e termina na seção `## 36.` (submenu que existe no post e não
  aparece no HTML) com a subseção `36.1`. O formato das seções é: `## N. Título (data)` e,
  no corpo, parágrafos curtos. CRLF é o padrão do arquivo — preserve.
- Os dois aprendizados foram autorizados pelo Gerente (M-006 item 2) e são estes:

### 37. `wp_replace_in_post`: o molde tem que ser o HTML cru, com aspas duplas

Medido em 25/11 nas 4 páginas de serviço (T-P03-026): a lista no banco é
`<ul class="wp-block-list">` — **aspas duplas**, e cada item traz o comentário
`<!-- wp:list-item -->`. Buscar pelo que o navegador mostra (ou por variante com aspas
simples / sem o comentário) devolve **0 substituições sem erro**: a ferramenta responde
sucesso e nada muda. Regra: antes de `wp_replace_in_post`, leia o cru com
`wp_get_cpt_item` e copie o `search` **dali**, literal, `regex:false`,
`max_replacements:1`, `search` ≤ 500 chars. Depois, releia e prove a troca; resposta
"ok" da ferramenta não é prova.

### 38. O marcador de 46 B do WP Fastest Cache faz byte/md5 da página inteira oscilar

Medido em 25/11: o HTML servido às vezes termina com
`<!-- need to refresh to see cached version -->` — **46 bytes** (medido:
`len(...)` = 46). Com o marcador, a mesma página dá 149.290 B; sem, 149.244 B —
conteúdo idêntico. Comparar bytes/md5 da **página inteira** entre medições gera
diferença fantasma e já fez o gestor afirmar coisa falsa (E-020 do workspace).
Regra: comparar o bloco `entry-content` (ou normalizar o marcador antes do md5) e
registrar as duas leituras: a servida limpa e a dinâmica (`?cb=1`).

## O QUE FAZER

1. `git status` no repo — há um arquivo modificado por outro processo
   (`planejamento/Obsidian Pages/DEPOIMENTOS - PROXY.md`). **Não toque nele.**
2. Abra `DOCS/IA/aprendizados-mcp-wordpress.md`, confirme que a última seção é a `## 36.`
   e que **não** existem seções 37/38 (se existirem, pare e reporte).
3. Acrescente as duas seções ao fim, com as datas `(2026-11-25)`, preservando CRLF e o
   estilo do arquivo (sem emoji, sem tabela nova, sem reescrever nada acima).
4. `git add` **só** `DOCS/IA/aprendizados-mcp-wordpress.md` e commite no repo do projeto:
   `git -c user.name="EXECUTOR-P03" -c user.email="executor@jhw.local" commit -m "docs: 2 aprendizados de MCP (molde literal do wp_replace_in_post; marcador de 46 B do WPFC) (T-P03-029)"`
5. Sem push (push do repo do projeto não é autorizado).

## PROIBIDO TOCAR

Qualquer arquivo do tema, qualquer `post_content`, `wp_navigation`, Yoast, `.env`,
`planejamento/Obsidian Pages/DEPOIMENTOS - PROXY.md`, e qualquer seção acima da 36.
Não rodar `deploy-theme.mjs` (nem `--dry-run`), não rodar purge, não chamar MCP.

## CRITÉRIO DE ACEITE (verificável por mim)

1. `grep -c "^## 3[78]\."` no arquivo = **2**.
2. `git show --stat HEAD` mostra **1 arquivo**, `+` apenas (nenhuma linha removida do
   que já existia) e o autor `EXECUTOR-P03`.
3. `git status --short` continua mostrando o `DEPOIMENTOS - PROXY.md` como o único
   modificado (fora o commit acima).

## CONTRATO DE RETORNO

`RESULTADO / status / arquivos_alterados / comandos_executados / evidencia / nao_testado / riscos / proximo_passo`

Além disso: o hash do commit, o `--stat`, e o texto das duas seções como ficou no arquivo.
