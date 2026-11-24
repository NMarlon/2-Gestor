# Brief T-P03-022 — publicar as 4 páginas de serviço

Projeto: P-03 (site Jéssica Haguiwara) · Emitido: 2026-11-23 · Gestor: Hermes

**BLOQUEADO POR APROVAÇÃO.** Este brief só é disparado com o "pode" do Marlon.
Não publique nada antes disso. Se receber este arquivo sem a marca `APROVADO` no
topo, pare e devolva "aguardando aprovação".

## ESCOPO ÚNICO

Tornar as quatro páginas de serviço acessíveis ao visitante: **publicar** as quatro,
**ligar** os quatro cartões da home a elas, **pôr** as quatro no submenu SOLUÇÕES, e
dar a elas o **estilo editorial** do site. Nada mais.

## CONTEXTO JÁ VERIFICADO (não re-investigue)

- As quatro páginas existem como `draft`, IDs **226–229**, slugs exatos:
  `consultoria`, `projetos`, `gestao-de-obra`, `chave-na-mao`. Conteúdo conferido
  contra o arquivo aprovado pelo Marlon. Cada uma tem 2 H2 e **um único link**, o CTA
  de WhatsApp (`5511983236422`). Não reescreva texto.
- **O buraco que isto resolve:** na home, os quatro cartões da seção Serviços apontam
  **todos** para `#contato`. Medi: a seção inteira tem 3 links e os 3 são `#contato`.
  O visitante não tem como ler o que é "Gestão de Obra".
- **As páginas internas JÁ herdam o desenho do site** — isto foi medido em navegador
  real, não deduzido: `h1` em **Marcellus** (a serifada do site), corpo em **Inter**,
  fundo `#EDE3D6` (`--jhw-base`), cabeçalho, rodapé e menu presentes.
  **Não** existe CSS preso que precise ser "desescopado". A hipótese anterior de que as
  páginas internas eram "Astra puro" está **errada** — ela veio de olhar
  `/politica-de-cookies/`, que é uma página gerada pelo Complianz e estilizada pelo CSS
  do plugin (corpo a 14px), não uma página comum do site.
- **O defeito real, medido em `/obrigado/` (página comum, mesma família das quatro):**

  | elemento | tamanho |
  |---|---|
  | `h1` ("Obrigado") | **31,67 px** |
  | `h2` | **40,44 px** |
  | parágrafo | 20 px / entrelinha 32 px — **66 caracteres por linha** |

  O `h1` é **menor que o `h2`**: a hierarquia está invertida em toda página interna.
  Na home o display do hero mede **74,88 px** (`h1`, 1440 px). O título de página
  deve ficar um degrau abaixo disso: **64 px**. É esse o buraco a fechar.
  A medida de leitura do parágrafo está **boa** (66 caracteres): não mexa no corpo.

- **A causa do `h1` pequeno, já isolada (não gaste tempo nela):** o título vem do
  template `page-with-title` com a classe `has-large-font-size`, e o WordPress emite
  `.has-large-font-size{font-size:var(--wp--preset--font-size--large)!important}`.
  Um seletor sem `!important` **perde** — testei: só o `line-height` mudava.
  O override precisa de `!important` e de escopo apertado.

- `:root` já expõe os tokens globais de cor: `--jhw-ink`, `--jhw-ink-forte`,
  `--jhw-oliva`, `--jhw-oliva-escuro`, `--jhw-ocre`, `--jhw-base`, `--jhw-bege`,
  `--jhw-raio-card`, `--jhw-sombra-card`, `--jhw-transicao`.
- **Não use `/politica-de-cookies/` como amostra de página interna.** Ela é gerada pelo
  Complianz e estilizada pelo CSS do plugin (corpo a 14 px, sem `page-with-title`).
  A amostra correta é `/obrigado/` — página comum, mesmo template das quatro.
- Home hoje: **178.621 bytes**, md5 `f5439f0a2a1d`, `<footer>` md5 `d0a615c449b2`,
  `style.css?ver=1.3.8`, 7 fotos `.webp`, gzip 46.246 bytes.
- Rodapé é `wp_template_part` **salvo no banco (ID 185)** — ele vence `parts/footer.html`.
  Não mexa nele (ver E-020, corolário 3).
- **O menu não é menu clássico.** Ele vive no post `wp_navigation/6`. Mexer em
  `nav_menu` clássico não muda nada na tela — é a armadilha já registrada em
  `DOCS/IA/aprendizados-paginas-jessica.md`. Edite a navegação `6`.
- **Existem três rascunhos legados e vazios**: IDs **164** (`CONSULTORIA`),
  **165** (`GESTÃO DE OBRA`), **166** (`PROJETOS`), anteriores a este trabalho.
  Não são as páginas boas — as boas são 226–229. Deixá-los publicados ou visíveis
  faz a cliente editar a página errada.


## O QUE FAZER

1. **Backup primeiro.** `wp_history_list` nas quatro páginas e na home. Anotar os IDs
   de revisão — é o rollback.
2. **CSS: consertar a escala do título nas páginas internas**, em
   `jessica-haguiwara-child/style.css`.
   Hoje: `h1` 31,67 px e `h2` 40,44 px. Alvo: `h1` na faixa display, acima do `h2`.
   **Este bloco foi testado por mim em navegador real** (HTML servido + CSS injetado +
   medição por CDP), não é chute:

   ```css
   body.page .wp-block-post-title.has-large-font-size {
     font-family: Marcellus, "Times New Roman", Times, serif !important;
     font-weight: 400 !important;
     font-size: clamp(2.5rem, 1.6rem + 2.8vw, 4rem) !important;
     line-height: 1.06 !important;
     letter-spacing: -0.015em !important;
     margin-block: 0 1.5rem !important;
   }
   ```

   Medido com esse bloco: `h1` **64 px / 67,84 px** em 1440, **40 px** em 390;
   `h2` segue **40,8 px** (1440) e **25,05 px** (390); corpo intacto (20 px / 32 px
   e 14,4 px / 23,1 px); `scrollWidth == innerWidth`; **zero** elemento passando da
   borda, nos dois tamanhos. A escala fica 74,88 (hero) → 64 (título de página) →
   40,8 (`h2`) → 20 (corpo). Use estes valores; se mudar, meça e relate o número.
   **Não** toque em `.jhw-home-v2` nem no corpo do texto. **Não** reescreva os 148 blocos
   globais.

3. **Subir a versão**: `style.css` 1.3.8 → **1.3.9** (cabeçalho do arquivo e
   `functions.php`, os dois lugares). `node scripts/validate-theme.mjs` verde.
4. **Deploy**: `node scripts/deploy-theme.mjs --dry-run` e **pare**. Devolva o output.
   Eu confiro e libero o deploy real.
5. **Publicar as quatro páginas** (`draft` → `publish`) mantendo IDs e slugs.
6. **Ligar os quatro cartões da home** aos slugs. Os cartões são "Consultoria",
   "Projetos", "Gestão de Obra", "Chave na Mão" — cada um vai para a sua página.
   Troque **só os quatro `href`**. Nenhuma outra mudança na home.
7. **Submenu SOLUÇÕES** no menu principal, com as quatro páginas, nesta ordem:
   Consultoria, Projetos, Gestão de Obra, Chave na Mão.
8. **Yoast**: título e meta description por página. **Não invente** dado de cliente —
   nada de CAU, área, prazo, preço, número de obras. Só o que está no texto aprovado.
9. **Mover os três rascunhos legados vazios para a lixeira** — IDs 164, 165, 166.
   Antes, confirme que estão vazios (sem conteúdo, sem revisão publicada). É lixeira,
   não exclusão: reversível. Se algum tiver conteúdo, **não apague** e me avise.


## PROIBIDO TOCAR

- O texto das quatro páginas.
- O rodapé (template part no banco, ID 185).
- As fotos, o logo, o hero, qualquer asset.
- Qualquer regra dentro de `.jhw-home-v2`.
- A página `/politica-de-cookies/` e `/obrigado/`.
- `opencode.json`, `.env`, credenciais.

## CRITÉRIO DE ACEITE (eu verifico na fonte, não no seu relatório)

- As quatro URLs respondem **200**: `/consultoria/`, `/projetos/`, `/gestao-de-obra/`,
  `/chave-na-mao/`.
- Cada URL resolve para o **ID certo** (226, 227, 228, 229), não para um legado.
- IDs 164, 165, 166 na lixeira (ou intactos, com aviso, se tinham conteúdo).
- Home: **4 hrefs** corretos nos cartões; **nenhum** cartão apontando para `#contato`.
- Home: rodapé com md5 `d0a615c449b2` **inalterado**; tamanho dentro de ±400 bytes do
  esperado (só os 4 `href` mudam).
- `/politica-de-cookies/` **byte-idêntica** a 140.474.
- `style.css?ver=1.3.9` presente no HTML servido.
- Título de página interna **medido no HTML servido**, a 1440 px: `font-size` do `h1`
  entre **60 e 68 px**, e **maior** que o `h2`. No celular (390 px): entre **38 e 42 px**
  e ainda maior que o `h2`. `scrollWidth == innerWidth` nos dois.
- Home: o título do hero **não** mudou de tamanho (o override não pode vazar para
  `.jhw-home-v2`).
- Submenu SOLUÇÕES presente no HTML da home, com os 4 links.
- HTML de uma página interna comprimido (gzip) abaixo de **60 KB**.

## CONTRATO DE RETORNO

`RESULTADO / status / arquivos_alterados / comandos_executados / evidencia /
nao_testado / riscos / proximo_passo`

`evidencia` = número medido, não adjetivo: bytes, status HTTP, md5, saída do
`--dry-run`. Se algo não foi testado, diga. Não declare publicado sem a URL
respondendo 200 na sua própria medição.
