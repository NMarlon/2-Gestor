# T-P03-037 — formulário da home termina em /obrigado/ e dispara `generate_lead` (GA4)

Repo: `C:\MarlonScripts\Jessica Haguiwara` (branch `main`, HEAD `2bcdbd6`)
Tarefa: **T-P03-037** · Dono: GESTOR-P03 · Executor: OpenCode · Data: 2026-11-26
Publica? **NÃO.** Tema termina em `--dry-run`. O deploy é decisão do gestor.

## Objetivo

1. Todo envio bem-sucedido do formulário da home (Forminator **id 168**) navega para
   `https://jessicahaguiwara.arq.br/obrigado/`.
2. A página `/obrigado/` dispara **um** evento `generate_lead` no GA4 (`GT-TBVGGKRR`)
   via `_googlesitekit.gtagEvent`, no máximo 1× por sessão.
3. `AW-`/Google Ads **fica de fora** (pendência Q-041): não criar ID, não inserir
   conversion linker.

## Contexto já verificado (não re-investigue)

- Home servida em 26/11: `<form id="forminator-module-168" class="forminator-custom-form
  forminator-custom-form-168 forminator_ajax" data-form-id="168" ...>`; envio por AJAX.
- Forminator 1.57.3 (`build/front/front.multi.min.js`): no sucesso dispara o evento
  jQuery `forminator:form:submit:success` no próprio form, com bubbling
  (`f.trigger("forminator:form:submit:success",[c,e])`). Handler delegado em `document`
  com jQuery recebe o evento.
- O HTML não tem redirect nativo configurado (a única ocorrência de `redirect` é PayPal).
- `/obrigado/`: HTTP 200, **147.712 B**, md5 `0e60bb76…`, canonical própria,
  `<title>Obrigado - Jessica Haguiwara - Arquitetura</title>`, sem link na home.
- Site Kit imprime no `<head>`: `google_gtagjs-js` (`gtag.js?id=GT-TBVGGKRR`) e
  `google_gtagjs-js-after`, que define
  `window._googlesitekit.gtagEvent = (name, data) => { ... gtag("event", name, {...data, event_source: "site-kit"}); }`.
- Não existe `AW-` nem outro `gtag("event")` no HTML servido.
- Tema: `JHW_CHILD_VERSION` em `functions.php:29` = **1.3.12**; `style.css:7` = 1.3.12;
  `scripts/release.json` = 1.3.12 com 12 arquivos. `php-parser` 3.7.0 instalado (o
  validador faz parse real de PHP). **Não existe PHP CLI nesta máquina** — não tente `php -l`.
- O tema não tem hoje JS de formulário nem de GA4; `assets/js/` só tem `header.js` e `footer.js` (ambos enfileirados no `functions.php`).

## Escopo (só estes arquivos)

1. **Novo** `jessica-haguiwara-child/assets/js/form-redirect.js`
   - IIFE com jQuery (`window.jQuery`), `'use strict'`.
   - `jQuery(document).on('forminator:form:submit:success', function (e) { ... })`.
   - Identificar o form com `jQuery(e.target).closest('form[data-form-id]')`; só agir se
     `String($form.data('form-id')) === '168'`.
   - Antes de navegar: `try { sessionStorage.setItem('jhw_form_sent','1'); } catch (err) {}`.
   - `window.setTimeout(function () { window.location.assign('/obrigado/'); }, 350);`
   - Sem redirect se o form não for 168. Sem dependência de texto/idioma.

2. **Novo** `jessica-haguiwara-child/assets/js/lead.js`
   - IIFE, sem dependências.
   - Só envia se: `sessionStorage.jhw_form_sent === '1'` **ou**
     `document.referrer.indexOf(window.location.origin) === 0`.
   - Dedupe: `sessionStorage.jhw_lead_sent` com timestamp; se < 60 min, não envia.
   - Consentimento: se `typeof window.cmplz_has_consent === 'function'`, exigir
     `cmplz_has_consent('statistics')`; sem a função, enviar (não há banner para gate).
   - Envio: `window._googlesitekit.gtagEvent('generate_lead', { form_id: '168',
     lead_source: 'contato_home' })`; fallback `window.gtag('event','generate_lead',{...})`;
     se nenhum existir, não marcar como enviado (permite retry).
   - Rodar no `DOMContentLoaded` (se `readyState === 'loading'`) ou imediatamente.
   - Ouvir `document.addEventListener('cmplz_status_change', ...)`: se
     `e.detail.category === 'statistics' && e.detail.value === 'allow'`, tentar enviar.
   - `try/catch` em todo acesso a `sessionStorage`.

3. `jessica-haguiwara-child/functions.php`
   - Enfileirar `jhw-form-redirect` **só na front page** (`is_front_page()`), dependência
     `jquery`, rodapé, `strategy => 'defer'`:
     `wp_enqueue_script('jhw-form-redirect', JHW_CHILD_URI . '/assets/js/form-redirect.js', array('jquery'), JHW_CHILD_VERSION, array('in_footer' => true, 'strategy' => 'defer'));`
   - Enfileirar `jhw-lead` **só em** `is_page('obrigado')`, sem dependências, rodapé, defer.
   - Não usar `wp_add_inline_script` para isso; não imprimir `<script>` na mão.
   - Manter o padrão de prefixo `jhw_` e comentário citando `T-P03-037`.

4. **Versão**: subir 1.3.12 → **1.3.13** em `style.css` (cabeçalho) **e** em
   `JHW_CHILD_VERSION` no `functions.php`. Rodar `node scripts/validate-theme.mjs --record`
   para regravar `scripts/release.json` com os hashes novos (inclui os 2 JS novos).

5. **Commit** com identidade do executor, só por caminho explícito:
   `git -c user.name="EXECUTOR-P03" -c user.email="p03-exec@2gestor.local" commit -m "conversao: form 168 leva a /obrigado/ e dispara generate_lead no GA4 (T-P03-037)" -- <caminhos>`

## Fora de escopo — proibido

- `AW-`, Google Ads, `gtag('config')` novo, ID hardcoded de GA4.
- Editar `post_content`, banco, plugin Forminator, Site Kit, Complianz, HubSpot.
- Deploy real: `node scripts/deploy-theme.mjs` **sem** `--dry-run`; `git push`;
  `git add -A`/`commit -a`.
- `noindex` do `/obrigado/` (é T-P03-036, bloqueada no Yoast).
- Mexer em `parts/footer.html`, `parts/header.html`, `style.css` além do número de versão.

## Critério de aceite (rodar e colar a saída)

1. `node --check jessica-haguiwara-child/assets/js/form-redirect.js` e
   `node --check jessica-haguiwara-child/assets/js/lead.js` → exit 0.
2. `node scripts/validate-theme.mjs` → **0 falhas**; colar a linha de resumo final.
3. `node scripts/deploy-theme.mjs --dry-run` → exit 0, imprime o plano e **não envia
   nada**; colar o bloco de arquivos. Esperado: `functions.php`, `style.css`,
   `scripts/release.json` (não é do tema), e os 2 JS novos.
4. `git diff --stat` e `git status --porcelain` → só os arquivos permitidos; depois do
   commit, árvore limpa exceto `planejamento/Obsidian Pages/DEPOIMENTO - PROXY.md`
   (já estava modificado antes; **não tocar**).
5. `grep -R "AW-" jessica-haguiwara-child` → **0** ocorrências.
6. `sha256sum` dos 2 JS novos e `git log -1 --format="%h %an %s"` no relatório.

## Contrato de retorno (8 campos)

`RESULTADO` (o que ficou pronto) · `status` (concluído/parcial/bloqueado) ·
`arquivos_alterados` · `comandos_executados` · `evidencia` (saídas dos itens 1–6) ·
`nao_testado` (o que só o deploy prova) · `riscos` · `proximo_passo`.
