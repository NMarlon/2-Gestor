# T-P03-028 — submenu: `Projeto` vira `Projetos` (e mais nada)

Projeto: P-03 Jessica Haguiwara · site `https://jessicahaguiwara.arq.br` · tema `jessica-haguiwara-child`
Brief de: GESTOR-P03 · data: 2026-11-25 · origem: M-011-A do Gerente (`DOCS/08-GERENTE/PARA-GESTORES.md`), decisão Q-035 do Marlon

## ESCOPO ÚNICO

No post de navegação (`wp_navigation`), trocar **o rótulo de um único item de submenu**:
`Projeto` → `Projetos`, no link que aponta para `/projetos/`.

**É a única mudança.** Não é tarefa de tema, de CSS, de página, de SEO, de deploy.
Não se toca no `h1` "Projeto de arquitetura e interiores" (decisão Q-035: ali o singular
nomeia o serviço e está certo), nem no cartão da home (já está no plural), nem em
`SOLUÇÕES`, `Consultoria`, `Gestão de Obra`, `Chave na Mão`, `QUEM SOMOS`, `CONTATO`.

## CONTEXTO JÁ VERIFICADO (não re-investigue)

Medido por mim em 2026-11-25, `curl` sem query string, UA Chrome/131, duas leituras idênticas:

- HTML servido da home: `<nav>` com 6 `<li>`; o submenu de `SOLUÇÕES` tem 4 filhos, nesta
  ordem — `/consultoria/` **Consultoria**, `/projetos/` **Projeto**, `/gestao-de-obra/`
  **Gestão de Obra**, `/chave-na-mao/` **Chave na Mão**.
- O rótulo sai no HTML como
  `<span class="wp-block-navigation-item__label">Projeto</span>` (aspas duplas, sem espaço
  interno). As maiúsculas na tela vêm de `text-transform` do CSS do header: **a caixa no
  banco é livre**, mas o texto deve ser gravado como `Projetos` (só a inicial maiúscula),
  igual aos irmãos.
- O menu é `wp_navigation` **no banco** (não está em `parts/header.html`). Já foi lido antes
  com `wp_get_cpt_item @{rest_base='navigation'; item_id=6}`; **confirme o ID lendo**, não
  presuma: o post certo é o que tem os 6 itens e os 4 filhos acima.
- `h1` de `/projetos/` hoje (HTML servido): `Projeto de arquitetura e interiores` — não muda.
- Cache: o site usa WP Fastest Cache; sem purge, o HTML velho continua no ar e a mudança
  parece não ter pegado.

## O QUE FAZER

1. `wp_get_cpt_item @{rest_base='navigation'; item_id=<ID confirmado>}` → guarde o
   `content` cru inteiro (é o "antes" do relatório).
2. Confirme que o cru contém exatamente **um** `navigation-link` cujo `href` termina em
   `/projetos/`, e que o texto do label desse link é exatamente `Projeto`. Se houver mais de
   um, ou se o texto for outro, **pare e reporte** — não improvise.
3. Troque **apenas** esse texto: `>Projeto<` → `>Projetos<` dentro do label daquele link.
   Nenhum byte fora do rótulo pode mudar (nem atributos, nem classes, nem comentários de
   bloco, nem ordem dos itens).
4. `wp_update_cpt_item @{rest_base='navigation'; item_id=<ID>; content=<novo>}`.
5. Releia com `wp_get_cpt_item` e prove: o label do link `/projetos/` agora é `Projetos`;
   os outros 3 rótulos e os 6 itens do topo seguem iguais; a diferença de bytes do cru é
   **+1 byte** (a letra `s`).
6. Purge: `node scripts/diagnostics/purge-wpfc-once.mjs` na raiz do repo (o script lê o
   `.env` sozinho — **não imprima token**). Exija `cache_all_html_restantes: 0`.

## PROIBIDO TOCAR

`jessica-haguiwara-child/*` (style.css, theme.json, functions.php, parts/, scripts/release.json),
qualquer `post_content` de página, títulos/metas do Yoast, `wp_options`, `deploy-theme.mjs`
(nem `--dry-run`), `.env` (só leitura pelo script de purge). **Não commite**: esta tarefa não
altera arquivo do repo — é mudança de banco.

## CRITÉRIO DE ACEITE (verificável por mim, na fonte pública)

1. HTML servido de `/` (duas leituras iguais, sem query string): submenu com 4 filhos,
   `Consultoria`, **`Projetos`**, `Gestão de Obra`, `Chave na Mão`, `href` de cada um igual
   ao de hoje.
2. `/projetos/` continua 200 e o `h1` continua **`Projeto de arquitetura e interiores`**
   (byte a byte).
3. Cartão da home e link "Projetos" continuam levando a `/projetos/`.
4. `cache_all_html_restantes: 0` no purge.

## CONTRATO DE RETORNO

`RESULTADO / status / arquivos_alterados / comandos_executados / evidencia / nao_testado / riscos / proximo_passo`

Além disso: ID do `wp_navigation`, o bloco do item `/projetos/` **antes e depois** verbatim,
a resposta do `wp_update_cpt_item`, a releitura crua e a saída do purge.
