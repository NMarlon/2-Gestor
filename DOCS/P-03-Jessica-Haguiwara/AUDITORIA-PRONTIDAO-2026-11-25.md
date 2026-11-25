# Auditoria de prontidão — deploy oficial do tema + entrada em Google Ads

Projeto P-03 · Jessica Haguiwara · medido em **2026-11-25** · gestor `jessica-p03`
Origem: **M-011 parte B** (`DOCS/08-GERENTE/PARA-GESTORES.md`), prazo 26/11.

## Como foi medido (vale para todo número deste documento)

- Fonte: **HTML servido** por `https://jessicahaguiwara.arq.br`, sem `no-cache` e sem
  query string; UA `Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36
  (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36`.
- Navegador: **somente** `python C:/MarlonScripts/2-Gestor/scripts/medir-cdp.py`
  (M-014), uma página por vez (E-032), headless, cache desabilitado, rede emulada
  `--throttle 4g` (150 ms RTT / 200 KB/s down / 94 KB/s up) e `--wait 15`.
- Perf: instrumentação instalada **antes** da navegação
  (`Page.addScriptToEvaluateOnNewDocument`) com `PerformanceObserver` de
  `largest-contentful-paint`, `layout-shift`, `longtask` e `event` (INP via
  `Input.dispatchMouseEvent` — clique confiável).
- Cópias cruas e JSONs: `…\hermes\profiles\jessica-p03\cache\scratch\m011\` (16 HTMLs,
  `med\*.json`). Repetição: home medida **5×** no mesmo dia; LCP variou 7.496–8.172 ms
  e CLS ficou **0,244 em todas** — número estável, não ruído.

## VEREDITO

| Faixa | Situação |
|---|---|
| **DEPLOY OFICIAL do tema** | **liberado** — site no ar em 1.3.10, sem divergência de repo; ressalva única: investigar o `wp_template_part` do rodapé (item 8.2) |
| **GOOGLE ADS** | **BLOQUEIA** — 4 bloqueios duros (conversão, consentimento, placeholder legal, LCP mobile). Nenhum se resolve com anúncio; todos se resolvem antes. |

### Bloqueia (não ligar campanha antes de resolver)

1. **Não existe conversão configurada.** Nenhuma tag `AW-` em nenhuma das 8 páginas;
   GA4 presente só como `GT-TBVGGKRR` (Site Kit); **0** ocorrências de
   `gtag("event"…)`. A página `/obrigado/` existe (HTTP 200) mas **não é referenciada
   por nenhum link da home** — não há prova de que o formulário redirecione para ela.
   Sem conversão, o Ads otimiza às cegas e não há CPA para medir.
2. **Consentimento não bloqueia nada.** O banner Complianz está no HTML
   (`body data-cmplz=1`, `cmplz-cookiebanner-1-optin`, categorias
   `cmplz-desc-{functional,marketing,preferences,statistics}-1-optin`), mas em
   navegador limpo, **sem nenhum clique**, os cookies já existem:
   `_ga`, `_ga_NGGYW0ZYHP`, `__hstc`, `hubspotutk`, `__hssc`, `__hssrc`. Não há
   `gtag('consent','default',…)` (`0` ocorrências). Para LGPD e para o Ads (que exige
   consentimento para Ads em tráfego EEE quando aplicável) isso está errado: banner
   existe, bloqueio não.
3. **Placeholder legal no ar.** `/privacy-policy/` publica literalmente
   `Registro profissional: CAU/A nº [INSERIR REGISTRO]`. É placeholder, não dado da
   cliente. Regra do workspace: sem o dado, o trecho não existe. O Ads revisa a
   política de privacidade — e `[INSERIR REGISTRO]` é reprovação fácil.
4. **LCP mobile 3,0–3,3× acima do limite.** Home @390×844/4G: **LCP 7,5–8,2 s**
   (limite "bom" ≤2,5 s; "ruim" >4,0 s), com o elemento culpado sempre
   `DIV.jhw-hero__bg` (323.212 px²) — um **JPEG de 131,3 KB carregado como
   `background-image` inline**, sem `srcset`, sem `preload`, sem prioridade.

### Antes da campanha (resolver depois dos 4 acima, antes de subir o primeiro anúncio)

- **Meta description**: só a home tem (140 caracteres). As outras **7 páginas** saem
  com `d=0` — o Google escreve o snippet sozinho.
- **`/obrigado/` está `index, follow`** — página de agradecimento não deveria ser
  indexável (duplicata vazia no índice).
- **`/privacy-policy/` tem 0 `<h1>`** (todas as outras têm 1).
- **`/contato/` responde 404** (corpo real de 148.270 B, página 404 do tema,
  `noindex, follow`). O menu aponta para `#contato` (âncora na home), então o 404 só
  aparece quando um link externo ou o anúncio apontar `/contato/`. **Correção de
  destino**: a URL final do anúncio tem de ser uma página real, não `/#contato`.
- **Formulário**: estrutura conferida por markup — Forminator módulo **168**, **1 etapa**,
  campos `name-1`, `email-1`, `phone-1`, `select-area-1` ("Área estimada"),
  `select-budget-1` ("Faixa de investimento prevista"), endereço completo
  (`address-1-*`), `textarea-1` e `checkbox-lgpd-1[]` (consentimento LGPD explícito,
  bom para o Ads). Obrigatórios: nome, e-mail, WhatsApp e a descrição. Nonce
  `forminator_nonce` presente; **sem honeypot declarado** no HTML.
  **Envio real não testado** — não criei lead de teste na base da cliente. É o
  primeiro item a testar com um lead marcado `TESTE`.
- **CAU/registro**: ausente em todas as 8 páginas (só o placeholder acima). Depende de
  dado da cliente (T-011).
- **Operação**: WhatsApp `+55 11 98323-6422` (via `wa.me`) e
  `contato@jessicahaguiwara.arq.br` estão na página. Não há como medir daqui se
  alguém responde — combinar SLA de resposta antes de pagar por clique.

### Depois (acompanhar na primeira semana de campanha)

- CLS do widget QLWAPP (contribui **0,145** dos 0,244 da home) e do hero (**0,099**).
- INP de campo (CrUX/Ads), comparando com o laboratório: **16 ms** no clique do
  "Próximo" do formulário — bom em laboratório.

## 1. Conversão

| Item | Medido |
|---|---|
| Tags `AW-` (Google Ads) | **nenhuma**, nas 8 páginas |
| Tag GA4 | `GT-TBVGGKRR` (Site Kit) |
| Eventos `gtag("event"…)` | **0** |
| GTM | ausente |
| `/obrigado/` | HTTP **200**, título 42 caracteres, **`index, follow`**, sem meta description |
| Link para `/obrigado/` na home | **0** |
| Formulário | Forminator módulo **168**, `data-forminator-render="0"` (renderizado por JS), **1 etapa**, 12 campos, `forminator_nonce` presente |

## 2. Consentimento e tags (navegador limpo, sem clique)

- Banner Complianz: **presente** (`cmplz-cookiebanner-1-optin`, `-container`, `-js`,
  `-js-extra`), mas com classe `cmplz-hidden` no HTML servido.
- Cookies encontrados **antes** de qualquer aceite: `_ga`, `_ga_NGGYW0ZYHP`, `__hstc`,
  `hubspotutk`, `__hssc`, `__hssrc` → **GA4 e HubSpot disparam sem consentimento**.
- Consent Mode v2: **ausente** (0 ocorrências de `gtag('consent'`).
- Scripts de terceiros que chegam a baixar bytes na home: `js.hs-banner.com`
  **22,8 KB**, `js.sentry-cdn.com` **1,7 KB`. Os demais (WonderPush/Sendinblue,
  Clarity, Metricool, `adsagentclientafd…azurefd.net`, `googletagmanager.com`) ficam
  em 0 KB na 1ª carga, mas estão no HTML.

## 3. Desempenho (laboratório, 4G, `--wait 15`)

| Página / viewport | FCP | LCP | elemento do LCP | CLS | TBT | load | recursos | transfer |
|---|---|---|---|---|---|---|---|---|
| Home 1440×900 | 2.768 | 2.768 | `H1.` | **0,001** | 310 | 8.908 | 94 | 871,4 KB |
| Home 390×844 (5 leituras) | 2.264–2.732 | **7.496–8.172** | `DIV.jhw-hero__bg` | **0,244** | 112–396 | 7.927–9.027 | 88–97 | 846,5–850,0 KB |
| `/consultoria/` 390×844 | 2.316 | 2.316 | `P.wp-block-paragraph` | 0,145 | 81 | 6.492 | 80 | 298,1 KB |
| `/projetos/` 390×844 | 1.140 | 7.672 | `DIV.cmplz-message` | 0,182 | 226 | 5.237 | 86 | 301,6 KB |
| INP (clique no "Próximo" do formulário, home 390) | — | — | — | — | — | — | — | **16 ms** |

Shifts da home: **0,099** em `#text` / `DIV.jhw-hero__actions` / `P.jhw-hero__lead`
(texto do hero sem reserva de espaço) e **0,145** em
`DIV.qlwapp__container qlwapp__container--bot` (botão de WhatsApp injetado depois).

Peso da home: **822,1 KB** vêm do próprio domínio. As imagens maiores:
`5efea8…jpg` **131,3 KB** (o hero), `logo-scaled.png` 64,8 KB,
`c41507…webp` 56,9 KB, `a67922…webp` 37,2 KB, `flags.webp` 27,8 KB,
`logo-768x236.png` 20,1 KB. O hero é o LCP **e** o maior arquivo: um só conserto
mata os dois.

## 4. SEO das 8 páginas

| Página | `<title>` | meta desc | `h1` | og:image | canonical | robots |
|---|---|---|---|---|---|---|
| `/` | 66 | **140** | 1 | sim | ok | index, follow |
| `/consultoria/` | 73 | **0** | 1 | não | ok | index, follow |
| `/projetos/` | 69 | **0** | 1 | não | ok | index, follow |
| `/gestao-de-obra/` | 48 | **0** | 1 | não | ok | index, follow |
| `/chave-na-mao/` | 54 | **0** | 1 | não | ok | index, follow |
| `/obrigado/` | 42 | **0** | 1 | não | ok | index, follow |
| `/privacy-policy/` | 57 | **0** | **0** | não | ok | index, follow |
| `/politica-de-cookies/` | 53 | **0** | 1 | não | ok | index, follow |

Canonical correto em todas; `twitter:card = summary_large_image` em todas.

## 5. Contato e 404

- `/contato` e `/contato/` → **HTTP 404**, `nginx/1.31.8`, corpo de **148.270 B**
  (página 404 do tema, `noindex, follow`), `CSP frame-ancestors 'self'`,
  `X-Frame-Options: SAMEORIGIN`.
- Menu `CONTATO` → `https://jessicahaguiwara.arq.br/#contato` (âncora na home).
- Consequência para Ads: URL final `/#contato` é aceitável, `/contato/` **não**.

## 6. Dados da cliente (não inventar)

- **CAU/registro**: só o placeholder `[INSERIR REGISTRO]` em `/privacy-policy/`.
- **CNPJ** 40.130.946/0001-97 (presente na política).
- Endereço no JSON-LD `LocalBusiness`: R. Niterói, 362 — Conj. 91, São Caetano do Sul
  — SP, 09510-200; `areaServed: "São Caetano do Sul e região"`; **sem telefone e sem
  CAU no JSON-LD**.
- Falta da cliente (T-011): CAU, áreas/prazos/preços de obra, depoimentos reais.

## 7. Parte A da M-011 (Q-035) — feita e medida

- `wp_navigation` **ID 6**, rótulo `Projeto` → `Projetos` (T-P03-028, delta **+1 byte**,
  sem arquivo de repo alterado).
- Prova independente (minha, não a do executor): `curl` na home, 2 leituras com
  **md5 idêntico** dos 7 rótulos (`105a167c248f7ffc1782000bf261e848`), submenu com `Consultoria`,
  **`Projetos`**, `Gestão de Obra`, `Chave na Mão`; `h1` de `/projetos/` continua
  `Projeto de arquitetura e interiores`; purge responde **204**.

## 8. Riscos abertos (não bloqueiam o deploy)

1. **`/contato/` 404** com página temática de 148 KB — se um anúncio ou link antigo
   apontar para lá, o clique paga por um 404.
2. **`wp_template_part` do rodapé**: o executor reportou que o part do child não está
   mais no banco (o rodapé renderiza do arquivo, 3.478 B). Investigar com
   `scripts/diagnostics/diff-footer-db-vs-file.mjs` antes que um deploy futuro
   sobrescreva o rodapé.
3. **Peso de terceiros**: HubSpot + Sentry + WonderPush + Clarity + Metricool +
   injeção Azure num site de 5 páginas. Para Ads, cada 100 ms de mobile custa
   impressão.

## 9. Próximo passo (ordem de execução proposta)

1. T-031 — consentimento de verdade (Complianz em modo opt-in bloqueando `_ga`/HubSpot
   + Consent Mode v2). **Sem isso não se liga Ads.**
2. T-032 — conversão: destino do formulário em `/obrigado/` + evento
   `generate_lead` no GA4 + `AW-` criado quando o Gerente autorizar a conta.
3. T-033 — hero: trocar o `background-image` de 131,3 KB por `<img>` com `srcset`
   WebP/AVIF + `fetchpriority="high"`; alvo LCP mobile < 2,5 s.
4. T-034 — lote de SEO: meta description nas 7, `noindex` no `/obrigado/`, `h1` na
   política.
5. T-035 — dado legal: CAU da cliente em `/privacy-policy/` (depende de T-011).
6. Deploy oficial do tema (1.3.11) depois de 1–4; medir antes/depois e anotar rollback.
