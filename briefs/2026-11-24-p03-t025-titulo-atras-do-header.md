# T-P03-025 — título das páginas internas engolido pelo menu fixo

Data: 2026-11-24 21:10 · Projeto: P-03 Site Jessica Haguiwara · Autor: GERENTE
Destino: GESTOR-P03 → briefa o OpenCode.

## Contexto já verificado (não re-investigue)

O Marlon abriu `https://jessicahaguiwara.arq.br/gestao-de-obra/` em 24/11, 21:05, e
mandou print: o `<h1>` da página aparece **atrás do menu superior**. O menu não
recolhe e a página começa no topo absoluto da viewport. Mesmo defeito deve existir
nas outras três páginas de serviço (`/consultoria/`, `/projetos/`, `/chave-na-mao/`)
porque usam o mesmo template.

Medido agora, contra o HTML servido e o CSS do repositório (não é hipótese):

1. O header é fixo: `jessica-haguiwara-child/style.css` ~l.335 —
   `.jhw-header { position: fixed; top: 0; ... }`, `min-height: 80px` no desktop
   (~l.359) e `64px` no mobile (~l.398).
2. Estrutura da página interna, no HTML servido (149.132 bytes):
   `<header>` → `<main id="wp--skip-link--target">` → **primeiro** filho é um grupo
   `alignfull has-tertiary-background-color` com
   `padding-top: var(--wp--preset--spacing--30)` (≈32 px) → dentro dele o
   `<h1 class="alignwide ext-animate--on wp-block-post-title has-large-font-size">`.
3. Ou seja: 32 px de respiro contra 80 px de header fixo → **48 px do título ficam
   embaixo do menu**. No mobile, 32 px contra 64 px.
4. O `h1` foi escalado para 64 px na seção 11 do child CSS (`PAGINAS INTERNAS`), o
   que piorou a aparência do corte.
5. A home **não** é afetada e não pode ser tocada: ela não tem
   `wp-block-post-title` (0 ocorrências no HTML servido) e tem hero próprio.
6. `scroll-margin-top: 104px` existe (l.816; 80 px na media query ~l.1552), mas é
   para âncoras — não corrige o começo da página.

## Objetivo

O `<h1>` das páginas internas precisa começar **abaixo** do header fixo, sem
escondê-lo e sem mexer na home.

## Escopo único

Só o espaçamento vertical do topo das páginas internas. **Um** ajuste no
`jessica-haguiwara-child/style.css`, na seção 11 (`PAGINAS INTERNAS`), curto e
comentado no padrão do arquivo (o arquivo explica antes/depois no comentário).

Preferência de solução, na ordem: (a) `padding-top` no primeiro grupo da página
calculado a partir da altura do header, com o valor do header em custom property
para não duplicar o número em dois lugares; (b) se (a) não pegar por
especificidade do inline style do WordPress, `margin-top` no `<main>` interno. Não
use `!important` novo sem dizer por quê. Se o inline `padding-top` do bloco
(gerado pelo editor) impedir a solução, **pare e reporte** — significa que o
ajuste precisa ir no template do site, não no CSS.

Mínimo aceitável: título inteiro visível com pelo menos 16 px de folga abaixo do
header, no desktop **e** no mobile.

## Proibido tocar

- Texto, links ou estrutura das páginas (copy é `Q-033`, outra tarefa).
- Home, hero, rodapé, formulário, menu, `wp_navigation`, plugins.
- `functions.php` — exceto o bump de versão do release, se o script exigir.
- Qualquer arquivo fora de `jessica-haguiwara-child/`.

## Critério de aceite (verificável)

1. `node scripts/validate-theme.mjs` limpo.
2. `node scripts/deploy-theme.mjs --dry-run` → exit 0, e os divergentes esperados
   explicados (pré-deploy diverge por definição).
3. Publicado: `style.css?ver=` sobe de `1.3.9` para `1.3.10`, e o CSS servido
   contém a regra nova (grep no corpo baixado, não no arquivo local).
4. **Prova visual, não opinião**: captura renderizada (headless, `deviceScaleFactor`
   correto — ver `E-024`: Windows a 110% já nos enganou) de `/gestao-de-obra/` em
   1440×900 e 390×844, com o `<h1>` inteiro abaixo do header. Guarde os PNGs em
   `backups/` ou `.scratch/` do repo do projeto e cite o caminho.
5. Cinco URLs em 200, com tamanho registrado antes/depois: `/`, `/consultoria/`,
   `/projetos/`, `/gestao-de-obra/`, `/chave-na-mao/`.
6. Home inalterada: `page-id` e md5 do bloco de rodapé iguais aos de antes
   (rodapé: 3.498 B, md5 `d0a615c449b20f2f3fb403056b5a1884`).
7. Rollback escrito no relatório: versão anterior `1.3.9`, arquivo e commit.

## Contrato de retorno

`RESULTADO / status / arquivos_alterados / comandos_executados / evidencia /
`nao_testado / riscos / proximo_passo`, com números medidos. Se algo do diagnóstico
acima estiver errado, diga — o brief é hipótese, a medição é o fato.

---

## Adendo do GESTOR-P03 (24/11, medição de abertura — vale como parte do contrato)

Medi antes de despachar, no HTML servido + CDP headless (Edge/Chromium, `dSF=1`):

- `@1440×900`: header `0 → 80`; primeiro grupo com `padding-top: 32px`;
  `h1.top = 32` → **48 px cobertos**.
- `@390×844`: header `0 → 64`; `padding-top` real **24 px** (o brief dizia 32 — é 24,
  spacing--30 no clamp inferior); `h1.top = 24` → **40 px cobertos**.
- Estrutura igual nas 4 internas (`page-id` 226–229), `h1` Marcellus 64 px @1440 /
  40 px @390.

**Correção 1 — escopo.** `body.page` **também** vale na home (`page-template-no-title`,
`page-id-38`). Regra presa só a `body.page`/`<main>` atinge a home. Escopo correto:
`body.page-template-page-with-title` (as 4 internas têm essa classe) **ou**
`main:has(> .wp-block-group .wp-block-post-title)`.

**Correção 2 — inline style.** O `padding-top: var(--wp--preset--spacing--30)` do grupo
é inline (editor). Portanto: (a) só pega com `!important` — permitido, **diga no
comentário o motivo**; (b) no `<main>` funciona sem `!important` porque `<main>` só tem
`margin` inline. Se escolher (b), atenção: o `<main>` não tem fundo e a faixa
`rgb(237,227,214)` do grupo começaria abaixo do padding — confira que não sobra tarja
de outra cor sob o header. Escolha uma, e escreva o porquê no comentário.

**Ordem de execução (não pule etapa, não publique):**

1. Ajuste na seção 11 (`PAGINAS INTERNAS`) do `jessica-haguiwara-child/style.css`,
   comentado no padrão do arquivo (antes/depois).
2. Bump **1.3.10** em `jessica-haguiwara-child/style.css` (`Version:`) e
   `jessica-haguiwara-child/functions.php` (`JHW_CHILD_VERSION`).
   **Não toque em `scripts/release.json`** — o baseline só é regravado com `--record`
   na publicação; mexer nele torna o gate tautológico.
3. `node scripts/validate-theme.mjs` — limpo (o bump é o que mantém o gate verde).
4. `node scripts/deploy-theme.mjs --dry-run` — exit 0; liste os divergentes.
5. **Prova visual pré-publicação**, já que a regra ainda não está no ar: injete o CSS
   candidato por CDP na página viva (`Runtime.evaluate` criando um `<style>` — mesmo
   caminho do probe 11 da T-P03-022), meça
   `h1.top − header.bottom` (exige ≥16) e capture PNG a `dSF=1` em **1440×900** e
   **390×844** de `/gestao-de-obra/` → `backups/t025-1440.png` e `backups/t025-390.png`.
   Reporte os caminhos e os dois números.
6. **Pare.** Deploy real é do gestor. Sem `deploy-theme.mjs` de verdade, sem purge.
7. Commit no repo do projeto com assinatura própria:
   `git -c user.name="EXECUTOR-P03" -c user.email="executor@jhw.local" commit`, com
   caminhos explícitos. Não inclua
   `planejamento/Obsidian Pages/DEPOIMENTOS - PROXY.md` (é de outro trabalho) nem
   arquivos de `DOCS/` do projeto — o registro documental é meu.

Se o inline style impedir a correção de um jeito que só template resolveria, **pare e
reporte** com a medição; não invente gambiarra de JS.

