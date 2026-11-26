# P-03 · Jessica Haguiwara — caderno do gestor

> Só o que é **exclusivo do gestor** neste projeto. O que é do projeto mora no
> repo dele e é a fonte de verdade.

> **Perfil Hermes deste gestor:** `jessica-p03` (M-010, 25/11 — nasceu `p03-gestor`,
> passou por `p03-jessica`; apelido de linha de comando: `jessica`). Perfil ativo
> confirmado no runtime desta sessão.

**Estado:** 2026-11-26 · no ar, tema **1.3.12**; no repo, **1.3.13** com T-037 (form → /obrigado/ + `generate_lead`) e T-034 em execução; sem deploy. Pendências: mensagem do qlwapp e `AW-` do Google Ads (Marlon)

**Perfil:** `jessica-p03`

## Onde ler (nesta ordem)

1. `C:\MarlonScripts\Jessica Haguiwara\AGENTS.md` — **contrato**. Precede tudo.
2. `C:\MarlonScripts\Jessica Haguiwara\DOCS\00-INDICE.md` — índice da doc do projeto.
3. `C:\MarlonScripts\Jessica Haguiwara\DOCS\12-PLANO-EXECUCAO.md` — plano vigente
   (lotes A–H) e registro §5 do que já foi feito.
4. `C:\MarlonScripts\Jessica Haguiwara\DOCS\04-TAREFAS.md` — tarefas do projeto,
   com as pendências por ID (T1…T26).
5. Estado resumido do portfólio: `../02-PROJETOS.md` § P-03.

## Fronteira que não se cruza

- **O gestor não escreve no repo do projeto.** Quem escreve é o OpenCode, via
  brief. O gestor decide, briefa, mede e aprova publicação.
- **Publicar é decisão do gestor**, não do executor. Brief de execução não
  inclui `deploy-theme.mjs` de verdade; só `--dry-run`.
- **Nunca inventar** CAU/registro, área, prazo, preço, obra ou depoimento. Se
  falta o dado da cliente, a seção não existe — não vira placeholder.

## Como falar com o executor

```
powershell -NoProfile -ExecutionPolicy Bypass -File `
  C:\MarlonScripts\2-Gestor\scripts\oc-brief.ps1 `
  -Dir "C:\MarlonScripts\Jessica Haguiwara" `
  -Brief "<caminho do brief>.md" -Agent build
```

Briefs dentro de `AGENTS.md` e no skill local `jessica-brief`. Regras que já
custaram caro:

- Brief com **uma** tarefa, contexto já verificado, arquivos permitidos, fora de
  escopo, critério de aceite verificável e contrato de retorno.
- `--auto` está ok para tarefa sem efeito em produção. **Deploy real exige
  `-NoAuto`** e revisão do diff antes.
- Sessão longa não morre em background; já morreu em foreground de 600 s.
- O agente resolve o `cwd` por `$env:PWD`: não chame o CLI direto do bash/MSYS.
  O `oc-brief.ps1` já normaliza isso e conserta o PATH do git.
- Não confiar no relato do executor: medir a URL pública, ler o `git diff` e
  rodar o validador.

## Armadilhas do projeto (medidas)

| Armadilha | Fato |
|---|---|
| Cache | WP Fastest Cache serve HTML velho e faz a medição mentir. Limpar antes de medir. |
| Purge | **A receita antiga morreu:** o `jhw-purge.php` não existe mais no docroot (saiu no expurgo de 23/11) — `?k=<chave>` dá 404 e não limpa nada. O caminho que funciona em 25/11 é `node scripts/diagnostics/purge-wpfc-once.mjs`, que grava um PHP de uso único, chama, apaga e confere o 404 do arquivo. Depois medir. |
| Deploy | **Sai 0** desde 2026-11-20 (órfão foi para `~/.trash/`). Prova boa: `N igual(is), 0 divergente(s), 0 novo(s), 0 orfao(s)` e nenhum envio. Se voltar a sair 1, é divergência real ou órfão novo — não ignorar. |
| Gate de versão | Bump em `style.css` + `functions.php` + `scripts/release.json`, senão o deploy recusa. |
| MCP WordPress | Não é fonte de verdade sobre o que está no ar. Sempre abrir a URL pública. |
| `custom_css` | Gravação pela REST responde vazio; o CSS foi movido para o `style.css` do child. Não voltar a usar o Customizer. |
| Spectra | O plugin injeta **394 KB** de CSS utilitário inline em toda página e **nenhuma** página usa essas classes. Ver T-009. |
| Template part no banco | `wp_template_part` **ID 185** (`post_name=footer`) vence `parts/footer.html`. Deploy verde, verificação 11/11, e o visitante vê o rodapé velho. Resolvido em 2026-11-23 apagando o override — o arquivo voltou a mandar. **Antes de editar tema, checar se a parte está salva no banco.** |
| Menu | Não está em `parts/header.html`: é `wp_navigation` no banco. Desde a **1.3.9** (24/11) o item SOLUÇÕES aponta para `#solucoes` (âncora existe) e o submenu (`open-on-hover-click`) tem **4 filhos**: consultoria, projetos, gestao-de-obra, chave-na-mao. Antes disso estava vazio. **Não verifiquei nesta medição onde os itens vivem** (bloco no tema ou `wp_navigation` no banco); se for no banco, rollback do tema **não** desfaz o submenu — desfazer é pelo editor de navegação. |
| Medição | Medir sempre as duas leituras: a servida (limpa) e a dinâmica (`?cb=1`). O cache já me fez afirmar três coisas falsas (E-020). |
| Marcador do WPFC | O HTML servido às vezes termina com `<!-- need to refresh to see cached version -->` (**46 chars**). Isso muda bytes e md5 da **página inteira** sem mudar conteúdo. Comparação confiável neste site é o bloco `entry-content`, não a página. Medido em 25/11 (149.290 vs 149.244 B só por causa do marcador). |
| Copy no banco | A copy das páginas vive em `post_content` (não no tema). Editar texto = MCP `wp_replace_in_post`, nunca deploy. `search` é **literal**, `regex:false`, `max_replacements:1`, `search` ≤ **500 chars**; molde real da lista é `<ul class="wp-block-list">` com aspas + `<!-- wp:list-item -->`. |
| Print headless | `Page.captureScreenshot` **sem `clip`** devolve o **topo** da página, não a posição do scroll: em 25/11 (T-P03-027) os PNGs "antes" e "depois" saíram **byte-idênticos** e pareciam prova de que nada mudou. Use `clip` em coordenada absoluta (`rect.top + scrollY`) com `captureBeyondViewport: true`, e confira o PNG por pixel (cor do botão + cor da faixa abaixo). |
| `wp_update_post_meta` | Nesta instância o Easy MCP AI pede `post_id` + `meta` (dict) + `post_type`. Mesmo com a forma certa, meta do Yoast (`_yoast_wpseo_metadesc`) volta **`ignored_keys`** — é allowlist da ferramenta, não sintaxe. Tentativa única autorizada (Q-037), 25/11. Não insistir. |
| Botão no conteúdo | `core/button` **não** precisa de CSS neste site: herda `styles.elements.button` do `theme.json` (fundo `#4F5B43`, texto branco, pill, padding 12/28, Inter 500). O ar embaixo vem do `wp:spacer` **somado** ao `blockGap` do layout: 32+64 = **96 px @1440** e 32+40 = **72 px @390**. |
| `curl` no Windows | `curl.exe -o /dev/null` sai **23** (erro de write) e reporta `size_download 0`: o código HTTP continua válido e o **tamanho mente**. Use `-o nul`. Aconteceu em 24/11 — por um instante a home "tinha" 0 B. |
| PHP de diagnóstico | Os 30 `jhw-*.php` do docroot foram **apagados em 23/11**; o único PHP de diagnóstico que ainda pisa no ar é o de uso único criado (e apagado) por `purge-wpfc-once.mjs`. Docroot hoje: nenhum `jhw-*.php`, só `.jhw-test` (resíduo). |
| Pasta nova no tema | A UAPI do cPanel **não tem** `mkdir`/`rmdir`/`unlink` (dá `not implemented`). Criar pasta remota é **API 2**: `/json-api/cpanel` com `cpanel_jsonapi_apiversion=2`, `module=Fileman`, `func=mkdir`, params `path` (pai) + `name` (nova). Remover arquivo/pasta: `func=fileop`, `op=trash`, `sourcefiles=<caminho>` — vai para a lixeira do cPanel (recuperável). `save_file_content` (UAPI) **cria** arquivo novo, mas só em pasta que já existe. |
| `&` no link do tema | Nos `parts/*.html` e `templates/*.html` do child o separador do link de WhatsApp chega **serializado como `&amp;`** (block markup); no `post_content` do banco é `&` cru. Brief que falar de link no tema tem de citar `&amp;` — e quem for trocar `&amp;` por `&` cru no HTML quebra o `text=`. |
| `templates/` do child | Em 25/11 a pasta `templates/` **não existia** no child em produção (o child só tinha `parts/`, `assets/`, `style.css`, `functions.php`, `theme.json`, `README.md`). Foi criada vazia pela API 2. Consequência: até 25/11 o 404 era o do tema pai — **h1 em inglês "Page Not Found"**, parágrafo em inglês e formulário de busca. E `404.php` na raiz **não** resolve neste tema: quem manda é `templates/404.html` (block template). |
| Slug em inglês | Política de Privacidade vive em `/privacy-policy/`; `/politica-de-privacidade/` dá 404. O rodapé tem os dois links, um em cada idioma. Não mexer sem checar referências do Complianz. |

## Decisões tomadas

- **2026-11-26 (T-P03-034, M-025) — código no repo, não publicado.** Consent Mode v2
  `default` (4 sinais `denied`) no `wp_head` prioridade 0; HubSpot sai do PHP e só entra
  por `consent.js` com `marketing` = granted; `consent/update` em `cmplz_status_change`.
  Commit `0b6bb24`, tema 1.3.13. **Medi eu:** validador `TUDO OK`; `--dry-run`
  `10 igual(is), 2 divergente(s), 3 novo(s), 0 orfao(s)`, 5 arquivos, `nada foi enviado`.
  Risco de aceite: consentimento já existente no load pode não emitir evento — medir no
  deploy.
- **2026-11-26 (T-P03-037, M-025) — código no repo, não publicado.** Forminator 168
  passa a levar a `/obrigado/` (`form-redirect.js`) e a página dispara **um**
  `generate_lead` no GA4 (`lead.js`, dedupe 60 min, só com `jhw_form_sent` ou referrer
  próprio; sem `AW-`). Commit `eec91a3`, tema 1.3.13. **Medi eu:** validador `TUDO OK`;
  `--dry-run` `10 igual(is), 2 divergente(s), 2 novo(s), 0 orfao(s)`, enviaria 4 e
  `nada foi enviado`. Falta o deploy (decisão minha) e, depois, medir em produção.
- **2026-11-26 (T-P03-036, M-025) — parcial, bloqueio humano.** O `h1` de
  `/privacy-policy/` não era bloco faltando: a página estava no template `default`,
  enquanto as páginas de conteúdo usam `page-with-title`. `wp_update_page
  { template: "page-with-title" }` resolveu sem tocar conteúdo; medido 2× na URL servida,
  1 `<h1>` `wp-block-post-title` = `Política de Privacidade`, body
  `page-template-page-with-title`. As 7 descriptions e o `noindex` da `/obrigado/` **não
  entraram**: `wp_update_post_meta` recusa key Yoast (`ignored_keys`) com a integração
  desligada em `Easy MCP AI → Tools → Plugins`; para ligar é preciso wp-admin logado, e o
  perfil Edge `wp-admin-profile` está com `reauth=1` (sessão expirada). Lição: **antes de
  briefar tarefa de meta Yoast, checar se a integração está ligada** — o bloqueio já tinha
  histórico (aprendizados §36.1) e eu não conferi. Retomada: `briefs/2026-11-26-p03-t036b-yoast.md`,
  itens 1–6 intactos.
- **2026-11-26 (T-P03-038, M-025)** — mensagem do botão flutuante do WhatsApp trocada para
  `Olá! Quero conversar sobre o meu projeto.` **sem** tocar telefone, nome, `response` nem o
  resto do contato. A option do brief (`qlwapp`) **não existe** no wp-whatsapp-chat 8.6.5:
  o dado mora em **`qlwapp_contacts[0].message`** (é o `contacts[*].message` do HTML). O
  executor 1 achou o nome real, aplicou com backup e purge no mesmo request; o executor 2,
  despachado por engano em paralelo, parou no gate `existe=false` sem escrever. **Medição
  minha:** home `200 / 180.963 B / md5 814a2f12…`, 404 `404 / 145.861 B`, 2 leituras iguais
  por URL, **2× novo / 0× antigo** em ambas, `Escreva sua mensagem` 1× e
  `5511983236422` 5× (links + JSON). Commit do site `16e325f` (5 arquivos, `EXECUTOR-P03`),
  backup `backups/qlwapp-option-2026-11-26.json` (serializado `be0f49ad…`). **Erro meu de
  processo (E-041):** o despacho em background parecia morto (log vazio, `ps` sem PID) e
  re-despachei em foreground — dois escritores no mesmo brief. A lição do E-040 era
  exatamente essa e eu não apliquei.
- **2026-11-25 (M-020 executada e medida por mim)** — **T-P03-033**: 1.3.12 no ar (executor
  `578b4b9`, 4 arquivos, +5/−5). O `text=` dos 2 links do rodapé e do botão da 404 passou a
  `Olá! Quero conversar sobre o meu projeto.` — **0** ocorrências do texto antigo nos
  **links** (`href`/`text=`) das 4 páginas **e** da 404; cada página agora tem **1 texto
  próprio no corpo + 2 universais no rodapé** (3 links de WhatsApp, como antes). **Fora dos
  links**, o literal antigo persiste **2× por página** no JSON inline do plugin **qlwapp**
  (botão flutuante; campo `message`, não `text=`) — fora do escopo do brief e não tocado;
  decisão pendente do Gerente. Antes: 2 antigos por página
  (3 na 404). **Re-medido às 15:07** (cache do WPFC regravado, 2 leituras idênticas por URL):
  149.683 / 149.605 / 149.528 / 149.494 B, mesmos **0 antigo / 2 universal / 1 próprio /
  3 links**. O `−58 B` por página é o rodapé **−104 B** (2 links de 165 → 113 B) **+46 B**
  do marcador do WPFC (`need to refresh…`), não 2 × 29 B. Fora do rodapé, o diff
  antigo→novo do HTML é só `?ver=1.3.11 → 1.3.12`. A home (fora do escopo) mantém **1
  texto antigo no CTA do corpo** (`post_content`, intocado — CTA é proibido); o rodapé dela
  já é o universal. Backup em `backups/theme-1.3.11-antes-1.3.12/`; deploy 4 arquivos
  `todos conferem`; `--record` → 1.3.12; dry-run final **12 iguais, 0 divergentes**.
  `release.json` commit `19c84d3`, assinado `GESTOR-P03`. **Risco de processo:** o commit
  do executor `578b4b9` saiu com autor `Marlon Rebello Viana`, não `EXECUTOR-P03` — o brief
  não fixou a assinatura; não se reescreve commit, o próximo brief repete a regra.

- **2026-11-25 (M-020 aberta pelo Gerente)** — a T-P03-031 foi **aceita** por medição dele
  (1 link com o texto próprio por página, 0 de outra, rótulo e número intactos), com uma
  sobra que eu já tinha reportado: **2 links do rodapé** por página ainda mandavam o texto
  antigo. A ordem M-020 troca o `text=` desses dois por **um único genérico**
  (`Olá! Quero conversar sobre o meu projeto.`) — global, igual nas quatro, só o `text=`,
  proibido tocar CTA/CSS/menu/layout. Em `parts/footer.html` linhas **16** (botão
  `jhw-footer-button`) e **57** (link do título da coluna de contato). Virou **T-P03-033**;
  incluí o botão da 404 (`templates/404.html` linha 46), que nasceu hoje com o texto antigo,
  para o site não se contradizer na página de erro.

- **2026-11-25 (M-016 A publicada e medida por mim)** — **T-P03-032**: a 404 personalizada
  subiu em **1.3.11** (commit do executor `1713758`, 3 arquivos, +57/−2). Antes: fonte do
  tema pai, **404** real, 148.270 B, md5 `6f9a5372…`, h1 **`Page Not Found`** em inglês,
  parágrafo em inglês e **formulário de busca**, 0 links no `main`. Depois: **404** real,
  146.096 B, md5 `0d8e5df7…`, h1 `Página não encontrada`, **4** links de serviço, **1** CTA
  de WhatsApp (texto genérico), **0** form/search, `noindex`, header+footer, 3 links de
  WhatsApp na página, `lang="pt-BR"`; 2 leituras idênticas; `/?p=999999` também **404**.
  Geometria CDP: 1440×900 sem rolagem horizontal (1425 = 1425), h1 em 104–141 px abaixo da
  barra; 390×844 header 64 px, h1 em 104–130 px, documento 1372 px, sem estouro.
  **Backup antes:** `backups/theme-1.3.10-before-1.3.11/` (11 arquivos de `1713758^` +
  `BACKUP.md` com sha256 e rollback), conferido linha a linha contra o servidor pela UAPI
  (`style.css` e `functions.php`, 0 linhas diferentes). Deploy: 3 arquivos, **12/12 PASS** no
  SHA256 público; `--record` → release.json 1.3.11 (12 arquivos); dry-run final **12 iguais,
  0 divergentes**. Commit do `release.json` no repo do site: `2ffb716`, assinatura
  `GESTOR-P03`.

- **2026-11-25 (executada e medida por mim)** — **T-P03-031** (M-016 B): o `text=` do
  link de WhatsApp dentro do `post_content` das 4 páginas de serviço passou a ser o
  texto próprio de cada uma. Header/rodapé continuam com o genérico antigo, por
  instrução. Prova dupla: `wp_get_cpt_item` 226–229 → **0** antigo / **1** novo / **0**
  de outra página; HTML servido (UA Chrome/131, sem query string, 2 leituras
  idênticas) `/consultoria/` 149.741 B · `/projetos/` 149.709 B · `/gestao-de-obra/`
  149.632 B · `/chave-na-mao/` 149.598 B, com **0 antigo / 1 novo próprio** na fatia
  `entry-content`. O `+45 B` de `/projetos/` é o marcador de **46 B** do WPFC (§38):
  normalizado, −1 B. `phone=5511983236422` e o rótulo do botão intactos. Nenhum
  arquivo do projeto tocado, sem commit no repo do site.
- **2026-11-25 (M-011: parte A e parte B)** — **T-P03-028**: o rótulo do submenu
  `Projeto` virou **`Projetos`** em `wp_navigation` **ID 6** (o menu vive no banco, não
  no tema). Executor devolveu delta **+1 byte** e `relido_igual_ao_enviado: true`; repo
  do projeto **sem commit novo** (`HEAD b8cc298` é do T-P03-029; o T-028 não tocou
  arquivo). **Medição minha**, `curl` UA Chrome/131 sem query string, 2 leituras:
  md5 dos 7 rótulos **idêntico** (`105a167c248f7ffc1782000bf261e848`); submenu
  `Consultoria · Projetos · Gestão de Obra · Chave na Mão`; `h1` de `/projetos/`
  **intocado** (`Projeto de arquitetura e interiores`); purge **204**.
  **T-P03-030 (parte B)** — auditoria de prontidão em
  `DOCS/P-03-Jessica-Haguiwara/AUDITORIA-PRONTIDAO-2026-11-25.md`: **deploy oficial
  liberado**, **Google Ads BLOQUEIA** por 4 motivos medidos (conversão inexistente,
  consentimento que não bloqueia `_ga`/HubSpot, placeholder `[INSERIR REGISTRO]` na
  política, LCP mobile 7,5–8,2 s com hero de 131,3 KB em `background-image`).
  **T-P03-029**: §37 e §38 no `DOCS/IA/aprendizados-mcp-wordpress.md` do projeto
  (commit `b8cc298`, +50 linhas, só doc).
- **2026-11-25 (executada e medida por mim)** — **T-P03-027** (M-008): o link do WhatsApp
  no fim das **4 páginas de serviço** virou **botão** e ganhou ar embaixo. Caminho escolhido:
  **conteúdo, não tema** — `wp:paragraph` final → `wp:buttons` > `wp:button` (`core/button`,
  herda o `styles.elements.button` do `theme.json`: oliva `#4F5B43`, texto branco, pill,
  padding 12/28) **+** `wp:spacer` de **32 px**. Zero CSS novo, zero deploy, `style.css`
  segue **1.3.10**. Feito pelo OpenCode por MCP (`wp_get_cpt_item` → `wp_update_cpt_item`,
  4 páginas), purge WPFC com `cache_all_html_restantes: 0`. **Medição minha** (Edge
  headless/CDP, 8 combinações, dpr 1; HTML com UA Chrome/131, sem query string, **duas
  leituras idênticas** por página): 4× **200**; bytes **+376** em cada (`/consultoria/`
  149.768 · `/projetos/` 149.676 · `/gestao-de-obra/` 149.620 · `/chave-na-mao/` 149.554);
  **1** `.wp-block-button__link` e **1** `.wp-block-spacer` no `entry-content`, **0**
  parágrafo antigo; texto e `href` **byte a byte** iguais aos de antes (o `<a>` só ganhou
  a classe). Botão: **58 px** de altura @1440 e **49,09 px** @390, largura 272,17 / 297,88
  @1440 e 212,52 / 231,08 @390 — **não** fica pesado no mobile (M-008, item 3).
  **Ar embaixo: 96 px @1440 e 72 px @390** (32 do espaçador + 64/40 do `blockGap` do
  `theme.json`), contra **0 px** antes — medido em todas as 8 combinações. Sem overflow
  horizontal (`scrollWidth` = 1440 / 390). Prints recortados em
  `DOCS/P-03-Jessica-Haguiwara/evidencias/t027/print-<slug>-{1440,390}.png`, conferidos
  **pixel a pixel**: a faixa oliva do botão termina exatamente 96/72 px acima da faixa
  marrom do rodapé nos 8 arquivos. **Q-037:** uma tentativa de `wp_update_post_meta`
  (`_yoast_wpseo_metadesc`, 229) → `ignored_keys`, como previsto; **parei**. No ar, o
  `og:description` da /chave-na-mao/ segue com a frase antiga do M1 (não é regressão:
  é o mesmo limite de ferramenta).
- **2026-11-25 (executada e medida por mim)** — **T-P03-026**: as **10** trocas
  editoriais de Q-033 estão no ar (P2 vetada, intocada). Feito por MCP
  (`wp_replace_in_post`, 10 chamadas, todas `replacements_count: 1`), sem arquivo de
  tema e sem deploy — copy vive no banco. Medição minha na URL pública, UA Chrome/131,
  sem query string, duas leituras idênticas por URL: `/consultoria/` **200 149.392 B**
  `6bbd90df…` · `/projetos/` **149.300** `e8532940…` · `/gestao-de-obra/` **149.244**
  `6dfc674c…` · `/chave-na-mao/` **149.178** `e7a75bf3…`. Dentro do `entry-content`: os 10
  trechos novos aparecem 1×, os 10 velhos 0×; P2 continua 1×; `<title>`, canonical e
  `og:*` idênticos aos de antes. C3 virou `<ul>` de **3 `<li>`** irmão do H2. CTA: só
  a 226 mudou para "Fale sobre o seu caso"; as outras três seguem "Fale sobre o seu
  projeto". `style.css` continua **1.3.10**; `git status` do repo do projeto igual
  antes/depois. **Ressalva:** o `og:description` da /chave-na-mao/ ainda tem a frase
  antiga do M1 (Yoast não grava por MCP) — divergência conhecida, fora de escopo.
- **2026-11-24 (verificada na fonte pública)** — **T-P03-024**: tema **1.3.9**,
  4 páginas de serviço, submenu SOLUÇÕES com filhos e link nos cartões. Medido por
  mim, não pelo relatório do executor. UA Chrome/131, sem query string, duas
  leituras por URL:
  - `/` **200**, 181.139 B, md5 `8f73a2c0da296d23f9d7cee9eb34a416` nas duas.
    HTML sai com `Cache-Control: no-store` e `X-Proxy-Cache: MISS` — cada leitura
    bateu na origem, não em cache de borda.
  - CSS: `themes/jessica-haguiwara-child/style.css?ver=1.3.9` — arquivo servido com
    52.632 B, cabeçalho `Version: 1.3.9`, `Template: extendable`, e a seção
    `PAGINAS INTERNAS` (14 regras `.jhw-service`). O `themes/extendable/style.css?ver=1.3.9`
    é o **tema pai** enfileirado com a versão do filho; o cabeçalho dele diz 2.2.2 —
    isso é normal, não é release errado.
  - `/consultoria/` **200** 149.338 B · `/projetos/` **200** 149.167 B ·
    `/gestao-de-obra/` **200** 149.132 B · `/chave-na-mao/` **200** 149.054 B.
    md5 idêntico em duas leituras por página; `page-id` 226…229 (os mesmos rascunhos
    de 23/11); h1 presente com `has-large-font-size` (alvo do CSS do T-P03-022) e
    157–177 palavras dentro do `<main>`.
  - Submenu: **1** bloco `wp-block-navigation-submenu` dentro do `<nav>`, 2.448 B
    de markup, com **4 links de página**. O 5º `<a>` do bloco é o próprio SOLUÇÕES
    em `#solucoes`, e a âncora existe no HTML.
  - Cartões: **4** `<article class="jhw-service">`, cada um com **1** `<a>` no
    título para a página correspondente. Nenhum cartão sem link.
  - Rodapé segue em **3.478 caracteres**, com `/privacy-policy/` e
    `/politica-de-cookies/` em caminho relativo: igual à referência de 23/11.
  - Delta: home **178.621 → 181.139 B** (+2.518), coerente com 2.448 B de submenu
    novo mais os `<a>` dos títulos.
  - Comando: `curl -sS -A "$UA" -o nul -w "%{http_code} %{size_download}" <url>`
    e `python parse-menu.py home-r1.html` (parser `HTMLParser`, conta `<a>` dentro
    do bloco do submenu).
  - **Ressalva de copy:** o rótulo do submenu é "Projeto" (singular), o cartão diz
    "Projetos" e o h1 da página é "Projeto de arquitetura e interiores". Link
    correto nos três; só o rótulo não bate com o cartão. Não é falha técnica.
- **2026-11-23 (executada)** — Publicado o link da Política de Cookies no rodapé
  (versão **1.3.8**). Mudou mais que o link: havia um `wp_template_part` no banco
  (ID 185) vencendo o arquivo do tema, então o deploy saía verde e o ar não mudava.
  O override foi removido, o arquivo voltou a mandar, o cache foi purgado, e a URL
  limpa agora mostra `<footer>` de **3478 B** (era 3426 B) com os dois links, em duas
  leituras idênticas. `/politica-de-cookies/` responde 200. Rollback = recriar o
  template part a partir de `backups/template-part-185-footer-2026-11-23.json`.
- **2026-11-20 (executada)** — 1.3.5 no ar: removidos 394 KB de CSS utilitário
  morto do Spectra em cada página. Home 577.433 → **183.203 B**. Medido na URL
  pública depois de limpar WPFC + proxy. Rollback = commit `723548c`.
  Antes de publicar conferi que o bloco não tinha seletor global nem `@font-face`.

- **2026-11-20** — Publicar 1.3.5 removendo o CSS utilitário morto do Spectra,
  condicionado a página sem bloco Spectra. Meta: home < 200 KB. Visual idêntico.
- **2026-11-19** — Aprovar o site como está para a cliente; o que falta é dado
  dela, não código.
- **2026-11-20** — Corrigir a doc do projeto antes de qualquer nova feature: 4
  afirmações verificadas como falsas (T-008). Doc que mente sobre o próprio
  estado faz o próximo a mexer no projeto errar.

## Pendências que dependem do Marlon

- Levar à cliente a lista de dados reais (T-011).
- ~~Decidir se o `logs/` do projeto entra no `.gitignore`~~ — **resolvido**: conferido em
  25/11, `logs/` e `backups/` já estão no `.gitignore` do projeto. Nada de `??` por isso.

## Comandos do repositório do site (migrados da memória do Gerente, 26/11)

Regra do Jimmy Nar: detalhe técnico mora no repositório, não na memória macro. Estes comandos
saíram da memória e passam a morar aqui.

- `node scripts\validate-theme.mjs` — valida o child theme antes de qualquer deploy.
- `node scripts\deploy-theme.mjs --dry-run` — mostra o que subiria. Deploy real só com
  autorização escrita e medição antes/depois.
- `node scripts\check-live-footer.mjs` — confere o rodapé na URL pública servida.
- `node scripts\build-opencode-config.mjs` — gera o `opencode.json` do projeto (`opencode.json`
  e `.env` nunca entram no git).
- Gate de versão: bump em `style.css` + `functions.php` + `scripts\release.json`, senão o deploy
  recusa.
- Regras de conteúdo: nunca inventar CAU, área, preço, prazo, obra ou depoimento; `EXEMPLO` só
  com a marca visível na tela.
