# T-P03-027 — o CTA final das 4 páginas vira botão, com ≥32px de ar embaixo

Projeto: P-03 Jessica Haguiwara · site `https://jessicahaguiwara.arq.br` · tema `jessica-haguiwara-child`
Brief de: GESTOR-P03 · data: 2026-11-25 · origem: M-008 do Gerente (`DOCS/08-GERENTE/PARA-GESTORES.md`)

## ESCOPO ÚNICO

Nas **4 páginas de serviço** (IDs 226, 227, 228, 229), trocar o **último bloco** do `post_content`
— hoje um `wp:paragraph` com um link de WhatsApp — por um **botão nativo** (`wp:buttons` >
`wp:button`) seguido de um **espaçador de 32px**. Texto visível e `href` **byte a byte iguais**.
**Nada além disso.** Não é tarefa de CSS, de tema, de deploy, de SEO além do item Q-037 abaixo,
de menu, de home nem de qualquer outra página.

## CONTEXTO JÁ VERIFICADO (não re-investigue)

Medido por mim em 2026-11-25 08:10, duas leituras idênticas por URL (UA `Mozilla/5.0 (Windows NT
10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0 Safari/537.36`, `curl` sem
query string, sem `no-cache`):

| Página | URL | ID | Bytes servidos | md5 |
|---|---|---|---|---|
| consultoria | `/consultoria/` | 226 | 149.392 | `6bbd90dfd1c266e32bc1aa94c8ba1ffc` |
| projetos | `/projetos/` | 227 | 149.300 | `e8532940679e0cfcd2a0d54a383aba0e` |
| gestão de obra | `/gestao-de-obra/` | 228 | 149.244 | `6dfc674cce34d1218b06f88c97462eae` |
| chave na mão | `/chave-na-mao/` | 229 | 149.178 | `e7a75bf37c1a54d715973f93b9b9a6dc` |

Leitura de layout com Edge headless (CDP), viewports **1440×900** e **390×844**, dpr 1, 8 combinações:

- o último filho do `.entry-content` é `<p class="wp-block-paragraph">` (altura 32px @1440, 23,09px @390),
  `margin-bottom: 0px`;
- o `<footer class="jhw-footer jhw-footer--v2">` começa **exatamente na base desse parágrafo**:
  **vão = 0px nas 8 combinações** — é por isso que o link encosta na faixa marrom `#4a3428`;
- **nenhuma** das 4 páginas tem `.wp-block-button__link` dentro do `entry-content`;
- o tema **já estiliza** o botão nativo: `theme.json → styles.elements.button` usa
  `--wp--custom--color--button-primary-bg` (oliva) / `--wp--custom--color--button-primary-text`,
  raio pill, padding 12px/28px, Inter 500; hover/focus/active já estão em `style.css` L122–199.
  **Logo: nenhum CSS novo é necessário — e CSS novo é proibido nesta tarefa.**

Textos atuais (conferidos 1× em cada página, no HTML servido):

| Página | Texto do link |
|---|---|
| 226 consultoria | `Fale sobre o seu caso →` |
| 227 projetos | `Fale sobre o seu projeto →` |
| 228 gestao-de-obra | `Fale sobre o seu projeto →` |
| 229 chave-na-mao | `Fale sobre o seu projeto →` |

`href` idêntico nas 4 (nenhuma tem `target`):
`https://api.whatsapp.com/send?phone=5511983236422&text=Ol%C3%A1!%20Quero%20saber%20mais%20sobre%20os%20servi%C3%A7os%20de%20Arquitetura%20de%20Jessica%20Haguiwara`

**Armadilha medida neste site:** o HTML servido passa por `wptexturize()`/escaping — **não monte o
`search` a partir dele**. Leia o cru com `wp_get_cpt_item` e trabalhe sobre esse texto. O `&` do
`href` pode estar como `&amp;` no banco: **preserve os bytes do `<a>` como vierem**, só injetando a
classe.

## O QUE FAZER (uma página por vez, na ordem 226 → 227 → 228 → 229)

1. `wp_get_cpt_item @{rest_base='pages'; item_id=<ID>}` → guarde `content` (cru) e `status`.
2. Confirme que o **último bloco** do cru é um `wp:paragraph` cujo `<a>` tem o href do WhatsApp.
   Se não for, **pare e reporte** — não improvise.
3. Monte o novo conteúdo com **uma única** troca: o bloco `wp:paragraph` final inteiro
   (de `<!-- wp:paragraph` até `<!-- /wp:paragraph -->`) sai; entra exatamente isto (um
   separador de bloco = uma linha em branco entre o fim dos botões e o espaçador):

```
<!-- wp:buttons -->
<div class="wp-block-buttons"><!-- wp:button -->
<div class="wp-block-button"><a class="wp-block-button__link wp-element-button" href="<HREF BYTE A BYTE COMO ESTAVA>"><TEXTO BYTE A BYTE COMO ESTAVA, INCLUINDO O <span aria-hidden="true">→</span></a></div>
<!-- /wp:button --></div>
<!-- /wp:buttons -->

<!-- wp:spacer {"height":"32px"} -->
<div style="height:32px" aria-hidden="true" class="wp-block-spacer"></div>
<!-- /wp:spacer -->
```

Regras do markup:

- `wp-block-button__link wp-element-button` entra como **primeiro atributo** do `<a>`;
- o `<a>` **não** ganha `target`, `rel`, `style` nem classe extra;
- o texto interno não muda — inclusive o `→` dentro do `<span aria-hidden="true">` e o espaço antes dele;
- o wrapper de botões **não** leva `style`, `aligncenter`, `alignwide` nem `is-style-outline`;
- nenhuma outra parte do `content` muda (nem um byte fora do último bloco).

4. `wp_update_cpt_item @{rest_base='pages'; item_id=<ID>; content=<novo>}`.
5. Releia com `wp_get_cpt_item` e confira: `status` continua `publish`; `wp:buttons` 1×;
   `wp:spacer` 1×; o `wp:paragraph` final não existe mais; `href` e texto idênticos.
6. **Só depois das 4**: `node scripts/diagnostics/purge-wpfc-once.mjs` na raiz do repo
   (o script lê o `.env` sozinho — **não imprima token**). Exija `cache_all_html_restantes: 0`.

## Q-037 — tentativa única (M-008, item 6)

**Uma** chamada `wp_update_post_meta`:

- `item_id: 229`
- `meta_key: "_yoast_wpseo_metadesc"`
- `meta_value: "Do projeto à entrega, com cada etapa conduzida pelo escritório: projeto, fornecedores, obra e acabamento sob um responsável só, do começo ao fim."`

Histórico previsto: volta `ignored_keys` + notice do Easy MCP AI. Se voltar isso: **registre a
resposta literal e pare** — não tente SQL, `wp_update_post`, REST direto, plugin nem segunda
chamada. Se gravar, releia e prove.

## PROIBIDO TOCAR

`jessica-haguiwara-child/style.css`, `theme.json`, `functions.php`, `parts/*`, `scripts/release.json`,
`wp_navigation`, a home, `/politica-de-cookies/`, qualquer página fora das 4, `deploy-theme.mjs`
(nem `--dry-run`), qualquer outro meta, `.env` (só leitura pelo script de purge). Não commite no
repo do projeto: esta tarefa não altera arquivo dele.

## CRITÉRIO DE ACEITE (verificável por mim, na fonte pública)

1. As 4 releituras cruas com o markup acima e `status=publish`.
2. HTML público das 4 URLs com **1** `.wp-block-button__link` no `entry-content`, texto e href
   idênticos aos de hoje (o `<a>` só pode diferir pela classe).
3. Sem parágrafo órfão, sem botão duplicado, sem espaçador duplicado.
4. Medição minha: distância da base do botão ao topo do `footer` **≥ 32px** em 1440 e em 390;
   `scrollWidth == 390` (sem overflow horizontal).
5. HTTP 200 nas 4 após o purge.

## CONTRATO DE RETORNO

`RESULTADO / status / arquivos_alterados / comandos_executados / evidencia / nao_testado / riscos / proximo_passo`

Além disso, por página: ID, bytes do cru antes/depois, o **bloco final novo verbatim**, a resposta
do `wp_update_cpt_item` e a resposta **literal** do Yoast (item Q-037).
