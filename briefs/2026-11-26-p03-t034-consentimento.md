# T-P03-034 — consentimento opt-in de verdade: `_ga`/HubSpot só depois do clique + Consent Mode v2

Repo: `C:\MarlonScripts\Jessica Haguiwara` (branch `main`)
Tarefa: **T-P03-034** · Dono: GESTOR-P03 · Executor: OpenCode · Data: 2026-11-26
Publica? **NÃO.** Termina em `--dry-run`. Deploy é decisão do gestor.
Pré-requisito: T-P03-037 já commitada (a versão do tema deve ser a que ela deixou;
**não suba a versão de novo nesta tarefa**).

## Objetivo

1. Nenhum cookie de analytics/marketing (`_ga`, `_ga_*`, `__hstc`, `hubspotutk`,
   `__hssc`, `__hssrc`) pode nascer **antes** do opt-in no banner Complianz.
2. Consent Mode v2 declarado **antes** do `gtag('config')` do Site Kit:
   `ad_storage`, `ad_user_data`, `ad_personalization`, `analytics_storage` = `denied`
   por padrão; `update` para `granted` conforme as categorias do Complianz.
3. O script do HubSpot (`leadin-script-loader-js` → `hs-script-loader`) deixa de ser
   impresso pelo PHP e passa a ser injetado pelo tema **somente** com consentimento de
   marketing.

## Contexto já verificado (não re-investigue)

- Banner Complianz presente no HTML (`body data-cmplz="1"`, `cmplz-cookiebanner-1-optin`),
  script `complianz.min.js?ver=1790818892` com `defer`, impresso no rodapé.
- **O Complianz NÃO emite Consent Mode:** 0 ocorrências de `ad_storage`,
  `analytics_storage`, `ad_user_data`, `ad_personalization` no `complianz.min.js` e no
  HTML servido. O HTML só tem `consent', false` (bloco do Site Kit) — não é default.
- APIs disponíveis no Complianz: `window.cmplz_has_consent(categoria)`, evento
  `cmplz_status_change` com `detail = {category, value, region, categories}`.
- HubSpot: portal **52118817**; o plugin enfileira o handle **`leadin-script-loader-js`**
  (prova: `<script id="leadin-script-loader-js-js-extra">var leadin_wordpress = {...}</script>`)
  e imprime a tag com id próprio `hs-script-loader`, `async defer`, antes do
  `jhw-footer-js`. O `src` registrado é
  `https://js.hs-scripts.com/52118817.js?integration=WordPress&ver=11.3.75`.
- Site Kit imprime `google_gtagjs-js` (gtag.js?id=GT-TBVGGKRR) e o inline
  `google_gtagjs-js-after` no `<head>`.
- Cookies medidos em 25/11 **sem clique**: `_ga`, `_ga_NGGYW0ZYHP`, `__hstc`,
  `hubspotutk`, `__hssc`, `__hssrc`.
- `functions.php` (292 linhas) hoje não tem nada de `gtag`, `consent`, `cmplz` ou
  `hubspot`. Não existe PHP CLI; `php-parser` 3.7.0 faz o parse no validador.
- Enfileiramento atual usa `JHW_CHILD_URI` e `JHW_CHILD_VERSION` (functions.php:29).

## Escopo (só estes arquivos)

1. **Novo** `jessica-haguiwara-child/assets/js/consent.js`
   - IIFE `'use strict'`, sem dependências.
   - `has(cat)`: se `window.cmplz_has_consent` for função, devolve o booleano dela;
     se **não** for função, devolve `false` **quando o banner existir**
     (`document.getElementById('cmplz-cookiebanner-js')`) e `true` quando não existir
     banner (site sem Complianz não tem o que bloquear). Ou seja: fail-closed com banner.
   - `updateConsent()`: se `window.gtag` for função,
     `gtag('consent','update', { analytics_storage: statistics ? 'granted':'denied',
     ad_storage: marketing ? 'granted':'denied', ad_user_data: idem,
     ad_personalization: idem })`.
   - `loadHubSpot()`: não faz nada sem `JHW_CONSENT.hs`; se
     `document.getElementById('hs-script-loader')` já existir, não duplica; se
     `has('marketing')` for falso, não injeta; senão cria
     `<script id="hs-script-loader" async defer src="...">` e anexa em `document.head`.
   - `init()` = `updateConsent()` + `loadHubSpot()`.
   - Rodar em `DOMContentLoaded` (`document.readyState === 'complete'` → roda já;
     senão `addEventListener('DOMContentLoaded', init, {once:true})`). **Não** rodar
     direto no parse: o `complianz.min.js` é `defer` e pode executar depois deste arquivo.
   - Ouvir `cmplz_status_change` → `updateConsent(); loadHubSpot();`.

2. `jessica-haguiwara-child/functions.php`
   - `jhw_consent_default()` no `wp_head` **prioridade 0** (antes do Site Kit), imprime:
     ```html
     <script id="jhw-consent-default">
     window.dataLayer = window.dataLayer || [];
     window.gtag = window.gtag || function(){ window.dataLayer.push(arguments); };
     gtag('consent','default',{ad_storage:'denied',ad_user_data:'denied',ad_personalization:'denied',analytics_storage:'denied',wait_for_update:500});
     </script>
     ```
     Pular no `is_admin()`.
   - `jhw_gate_hubspot()` em `wp_enqueue_scripts` **prioridade 999**:
     - ler `wp_scripts()->registered['leadin-script-loader-js']->src` (se existir);
     - `wp_dequeue_script('leadin-script-loader-js')` (e `wp_deregister_script` só depois
       de capturar o `src`);
     - enfileirar `jhw-consent` (`assets/js/consent.js`, sem dependências, rodapé,
       `strategy => 'defer'`) e `wp_localize_script('jhw-consent','JHW_CONSENT', array('hs' => $src))`;
     - se o handle do HubSpot não existir, enfileirar `jhw-consent` mesmo assim, com
       `hs` vazio (o Consent Mode update continua valendo).
   - Comentário citando `T-P03-034`; não mexer nas outras funções.

3. `node scripts/validate-theme.mjs --record` para regravar `scripts/release.json`
   (mesma versão, hash novo de `functions.php` e o `consent.js` novo).

4. **Commit** por caminho explícito, identidade `EXECUTOR-P03`:
   `conversao: consentimento opt-in bloqueia _ga e HubSpot antes do clique + Consent Mode v2 (T-P03-034)`

## Fora de escopo — proibido

- Configurar o Complianz no banco/wp-admin (bloqueio humano), mexer em Site Kit,
  HubSpot ou Forminator.
- `AW-`, Google Ads, `gtag('config')` novo.
- Deploy real (sem `--dry-run`), `git push`, `git add -A`.
- Alterar `form-redirect.js`/`lead.js` da T-037, `style.css` (além de nada), `parts/`.
- Subir a versão (ela já foi para 1.3.13 na T-037; se a T-037 não estiver no repo,
  **pare e reporte**).

## Critério de aceite (rodar e colar a saída)

1. `node --check jessica-haguiwara-child/assets/js/consent.js` → exit 0.
2. `node scripts/validate-theme.mjs` → 0 falhas (o parse PHP real roda).
3. `node scripts/deploy-theme.mjs --dry-run` → exit 0 e plano com `functions.php`,
   `assets/js/consent.js` e `scripts/release.json`; **nada enviado**.
4. `grep -n "consent','default'\|ad_user_data\|leadin-script-loader-js\|jhw-consent" functions.php`
   → colar as linhas.
5. `grep -R "AW-" jessica-haguiwara-child` → 0.
6. `git status --porcelain` pós-commit limpo (exceto `planejamento/.../DEPOIMENTOS - PROXY.md`,
   que já estava sujo; não tocar). Colar `git log -1 --format="%h %an %s"`.

## Contrato de retorno (8 campos)

`RESULTADO` · `status` · `arquivos_alterados` · `comandos_executados` · `evidencia`
(saídas 1–6) · `nao_testado` (o comportamento em produção: ordem do default antes do
config, ausência de `_ga`/`__hstc` sem clique, HubSpot só após aceite) · `riscos` ·
`proximo_passo`.
