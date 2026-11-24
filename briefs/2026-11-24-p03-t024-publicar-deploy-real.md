# Brief T-P03-024 — publicar: deploy real + 4 páginas + submenu + link do cartão

Projeto: P-03 (site Jéssica Haguiwara) · Emitido: 2026-11-24 · Gestor: Hermes
**APROVADO pelo Marlon em 24/11, 10:10**: "Pode publicar as quatro páginas de serviço,
quero ver como ficaram." Dropdown: **4 itens**, decidido por ele.

Este é o run de produção. O run anterior (`T-P03-022`) parou no `--dry-run` — correto.
Rollback do tema 1.3.9 já está anotado em `DOCS/04-TAREFAS.md` (voltar 1.3.8 nos dois
arquivos, remover a seção `11. PAGINAS INTERNAS`).

## CONTEXTO JÁ VERIFICADO (não re-investigue)

Medido pelo Gerente agora, URL limpa, UA Chrome:

- `GET https://jessicahaguiwara.arq.br/` → **200**; CSS servido **`style.css?ver=1.3.8`**.
- **Domínio do site é `jessicahaguiwara.arq.br`** (não `.com.br` — `.com.br` dá NXDOMAIN).
- As quatro URLs de serviço respondem **404** porque as páginas seguem `draft`:
  `/consultoria/`, `/projetos/`, `/gestao-de-obra/`, `/chave-na-mao/`.
- Menu no ar: `<nav>` plano, **0** submenu real (as 2 ocorrências de
  `wp-block-navigation-submenu` no HTML são do CSS inline do WP, não do markup).
- Tema local em **1.3.9**; validador verde; dry-run do run anterior: 9 iguais,
  2 divergentes (`functions.php`, `style.css`), 0 órfãos.

## Escopo (nesta ordem, um passo por vez)

**1. Deploy real do tema 1.3.9.**
`node scripts\deploy-theme.mjs` (sem `--dry-run`). Depois:
`node scripts\check-live-footer.mjs` e purge do WPFC pelo script de diagnóstico que já
existe (`scripts\diagnostics\purge-wpfc-once.mjs`). Confirme `style.css?ver=1.3.9` no
ar. Só então `--record` em `release.json` (1.3.9).

**2. Publicar as 4 páginas** que estão em `draft` (IDs **226, 227, 228, 229**, com 1
entrada de histórico cada, 0 revisões). Publique as quatro como estão — **não reescreva
o texto**. Depois confirme `200` anônimo em cada slug.

**3. Submenu SOLUÇÕES com 4 itens**, no `wp_navigation` **id 6**. Os 4 itens apontam
para as 4 páginas publicadas no passo 2. Rótulos curtos, iguais ao `h1` de cada página.
Não mexa nos outros itens do menu; não crie menu novo.

**4. Link nos cartões de Serviço** (o bloqueio que você mesmo levantou).
Os cartões são `<article class="jhw-service">` sem `<a>` e sem `href`. Faça a mudança
**mínima e reversível**: envolva **apenas o título do cartão** num `<a href>` para a
página correspondente. **Não** envolva o cartão inteiro, **não** reescreva o CSS do
cartão, **não** invente efeito de hover. Se o título não for um elemento próprio,
diga isso e proponha a alternativa mínima antes de fazer.

**5. Yoast das 4 páginas**: título (`_yoast_wpseo_title`) e descrição
(`_yoast_wpseo_metadesc`) derivados **do texto que já está nelas**. Proibido inventar
CAU, área, prazo, preço, obra, cliente ou depoimento. Se faltar dado, escreva a meta
sem ele.

**6. Lixeira 164/165/166**: só se você confirmar que estão **vazias** (sem conteúdo,
sem filho, sem link interno). Confirmando, mande para a lixeira; não force exclusão
definitiva. Se alguma tiver conteúdo, **não toque** e reporte.

## Proibido

- Tocar em `planejamento/Obsidian Pages/DEPOIMENTOS - PROXY.md` (modificado pelo Marlon).
- Mexer em P-02, P-04, ou em qualquer arquivo fora do tema e das 4 páginas.
- Reescrever o texto das 4 páginas, trocar imagens, mudar cores além do que já está
  no tema 1.3.9.
- Deploy por FTP manual, edição direta no servidor, `wp db` ou SQL cru.
- Apagar qualquer coisa de forma definitiva.

## Critério de aceite (verificação sua, com comando)

1. `node scripts\validate-theme.mjs` → TUDO OK.
2. `node scripts\deploy-theme.mjs --dry-run` pós-deploy → **11 iguais, 0 divergentes,
   0 órfãos**.
3. As 4 URLs → **200** anônimo, com `curl` de UA Chrome. Cole o código de cada uma.
4. Home: **1** submenu real no markup (`wp-block-navigation-submenu` **dentro** do
   `<nav>`), com 4 links para as 4 páginas. Cole o trecho do HTML.
5. `node scripts\check-live-footer.mjs` → rodapé igual ao de referência.
6. `style.css?ver=1.3.9` no ar.
7. Commit com `scripts/commit-agent.sh` (ou `-c user.name="EXECUTOR-P03"`) e a mensagem
   `publica: 4 paginas de servico + submenu SOLUCOES + link do cartao (T-P03-024)`.
   `git add` por caminho explícito. **Nunca** `git add -A`.

## Contrato de retorno

Devolva exatamente:

```
RESULTADO / status
arquivos_alterados
comandos_executados (com exit code)
evidencia (medida por você, colada — não "deu certo")
nao_testado
riscos
proximo_passo
```

Se algo do escopo não for possível como está escrito, **pare naquele passo**, entregue
os anteriores prontos e diga o que bloqueou. Não improvise mudança visível nova.
