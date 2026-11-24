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
- **Por que as páginas internas não herdam o desenho:** `style.css` tem 284 blocos.
  **136 estão escopados em `.jhw-home-v2`**, classe que só existe na home. Os outros
  **148 são globais** (link, botão, card) e já valem nas páginas internas.
  O que falta é só o topo da cadeia tipográfica, hoje escopado:
  `.jhw-home-v2 h1, .jhw-home-v2 h2, .jhw-home-v2 h3 { font-family: var(--jhw-v2-serif);
  font-weight: 400; line-height: 1.05; letter-spacing: -0.02em }`, mais o
  `color: var(--jhw-v2-ink)` e `font-family: var(--jhw-v2-sans)` do wrapper.
- `:root` já expõe os tokens globais de cor: `--jhw-ink`, `--jhw-ink-forte`,
  `--jhw-oliva`, `--jhw-oliva-escuro`, `--jhw-ocre`, `--jhw-base`, `--jhw-bege`,
  `--jhw-raio-card`, `--jhw-sombra-card`, `--jhw-transicao`.
- Página interna de referência hoje: `https://jessicahaguiwara.arq.br/politica-de-cookies/`
  — 140.474 bytes, Astra puro, sem o desenho do site. **É o "antes".**
- Home hoje: **178.621 bytes**, md5 `f5439f0a2a1d`, `<footer>` md5 `d0a615c449b2`,
  `style.css?ver=1.3.8`, 7 fotos `.webp`, gzip 46.246 bytes.
- Rodapé é `wp_template_part` **salvo no banco (ID 185)** — ele vence `parts/footer.html`.
  Não mexa nele (ver E-020, corolário 3).

## O QUE FAZER

1. **Backup primeiro.** `wp_history_list` nas quatro páginas e na home. Anotar os IDs
   de revisão — é o rollback.
2. **CSS do estilo interno**, em `jessica-haguiwara-child/style.css`:
   criar um escopo próprio para página interna — classe no wrapper do conteúdo ou
   `body.page` — aplicando os primitivos que faltam: fonte serifada nos h1–h3 com
   peso 400 e `line-height` ~1.05, cor `--jhw-ink`, base sans, largura de leitura
   confortável para parágrafo (~62–68ch), ritmo vertical entre seções e respiro no
   topo (o título não pode colar no cabeçalho).
   **Não** altere nada dentro de `.jhw-home-v2`. **Não** use `:has()` novo se der para
   resolver com classe. **Não** reescreva os 148 blocos globais.
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
- Home: **4 hrefs** corretos nos cartões; **nenhum** cartão apontando para `#contato`.
- Home: rodapé com md5 `d0a615c449b2` **inalterado**; tamanho dentro de ±400 bytes do
  esperado (só os 4 `href` mudam).
- `/politica-de-cookies/` **byte-idêntica** a 140.474.
- `style.css?ver=1.3.9` presente no HTML servido.
- Submenu SOLUÇÕES presente no HTML da home, com os 4 links.
- HTML de uma página interna comprimido (gzip) abaixo de **60 KB**.

## CONTRATO DE RETORNO

`RESULTADO / status / arquivos_alterados / comandos_executados / evidencia /
nao_testado / riscos / proximo_passo`

`evidencia` = número medido, não adjetivo: bytes, status HTTP, md5, saída do
`--dry-run`. Se algo não foi testado, diga. Não declare publicado sem a URL
respondendo 200 na sua própria medição.
