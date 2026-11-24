# P-03 · Jessica Haguiwara — caderno do gestor

> Só o que é **exclusivo do gestor** neste projeto. O que é do projeto mora no
> repo dele e é a fonte de verdade.

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
| Purge | Na prática: `https://jessicahaguiwara.arq.br/jhw-purge.php?k=<chave>` (chave em `backups/`, nunca no chat) e depois `curl -X PURGE` em cada URL → 204. Sem isso a medição mostra o HTML antigo. |
| Deploy | **Sai 0** desde 2026-11-20 (órfão foi para `~/.trash/`). Prova boa: `N igual(is), 0 divergente(s), 0 novo(s), 0 orfao(s)` e nenhum envio. Se voltar a sair 1, é divergência real ou órfão novo — não ignorar. |
| Gate de versão | Bump em `style.css` + `functions.php` + `scripts/release.json`, senão o deploy recusa. |
| MCP WordPress | Não é fonte de verdade sobre o que está no ar. Sempre abrir a URL pública. |
| `custom_css` | Gravação pela REST responde vazio; o CSS foi movido para o `style.css` do child. Não voltar a usar o Customizer. |
| Spectra | O plugin injeta **394 KB** de CSS utilitário inline em toda página e **nenhuma** página usa essas classes. Ver T-009. |
| Template part no banco | `wp_template_part` **ID 185** (`post_name=footer`) vence `parts/footer.html`. Deploy verde, verificação 11/11, e o visitante vê o rodapé velho. Resolvido em 2026-11-23 apagando o override — o arquivo voltou a mandar. **Antes de editar tema, checar se a parte está salva no banco.** |
| Menu | Não está em `parts/header.html`: é `wp_navigation` no banco. Desde a **1.3.9** (24/11) o item SOLUÇÕES aponta para `#solucoes` (âncora existe) e o submenu (`open-on-hover-click`) tem **4 filhos**: consultoria, projetos, gestao-de-obra, chave-na-mao. Antes disso estava vazio. **Não verifiquei nesta medição onde os itens vivem** (bloco no tema ou `wp_navigation` no banco); se for no banco, rollback do tema **não** desfaz o submenu — desfazer é pelo editor de navegação. |
| Medição | Medir sempre as duas leituras: a servida (limpa) e a dinâmica (`?cb=1`). O cache já me fez afirmar três coisas falsas (E-020). |
| `curl` no Windows | `curl.exe -o /dev/null` sai **23** (erro de write) e reporta `size_download 0`: o código HTTP continua válido e o **tamanho mente**. Use `-o nul`. Aconteceu em 24/11 — por um instante a home "tinha" 0 B. |
| PHP de diagnóstico | 30 `jhw-*.php` no docroot, inertes (`http_response_code(404)`), exceto `jhw-purge.php`, que **executa** com chave estática na URL. 404 anônimo não prova arquivo apagado. |
| Slug em inglês | Política de Privacidade vive em `/privacy-policy/`; `/politica-de-privacidade/` dá 404. O rodapé tem os dois links, um em cada idioma. Não mexer sem checar referências do Complianz. |

## Decisões tomadas

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
- Decidir se o `logs/` do projeto entra no `.gitignore` — hoje aparece como `??`.
