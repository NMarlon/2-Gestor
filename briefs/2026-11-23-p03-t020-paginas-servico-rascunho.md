# Brief T-P03-020 — criar as quatro páginas de serviço em rascunho

Projeto: P-03 (site Jéssica Haguiwara) · Emitido: 2026-11-23 · Gestor: Hermes

## ESCOPO ÚNICO

Criar **quatro páginas em rascunho** no WordPress — `consultoria`, `projetos`,
`gestao-de-obra`, `chave-na-mao` — com o texto do arquivo de conteúdo. **Não publicar.
Não tocar no menu.**

## CONTEXTO JÁ VERIFICADO (não re-investigue)

- O texto final está em `DOCS/P-03-Jessica-Haguiwara/PAGINAS-SERVICOS-CONTEUDO.md`
  (repo `2-Gestor`), por página: slug, título, abertura, corpo, listas, CTA. É a fonte
  da verdade do conteúdo. **Não reescreva o texto** — copie.
- Não há plugin de SEO no site (sem Yoast, sem RankMath). Não invente campo de meta
  description; se a ferramenta aceitar `excerpt`, use a primeira frase como resumo.
- O site usa blocos (Spectra). A home tem a seção "Serviços" com os quatro itens
  (01 Consultoria, 02 Projetos, 03 Gestão de Obra, 04 Chave na Mão). **Leia a home
  com `wp_get_page` e espelhe o padrão de blocos dessa seção** nas páginas novas —
  mesmo estilo de título, mesmo tipo de bloco de texto, mesma hierarquia. Não invente
  layout novo e não crie CSS novo.
- Menu: o item SOLUÇÕES é bloco de navegação no banco (`wp_navigation`), com submenu
  **vazio**. **Fora do escopo deste brief** — a ligação com as páginas é a tarefa
  seguinte, depois de aprovação do cliente.
- Rodapé publicado: 1.3.8, `<footer>` 3478 B, com link de cookies. Não mexer.

## O QUE FAZER

1. **Backup antes.** `wp_history_list` no estado atual; anotar que não existe página com
   esses slugs (se existir, **pare e reporte** — não sobrescreva).
2. **Ler a home** e identificar os blocos da seção Serviços.
3. **Criar as quatro páginas** com `wp_create_page` (ou equivalente), cada uma:
   `status = draft`, `slug` e `title` do arquivo, conteúdo em blocos no padrão da home,
   sem imagem destacada, sem comentários, autor o usuário do token.
4. **Provar que são invisíveis:** abrir a URL pública de cada slug com User-Agent
   completo de Chrome e confirmar **404** (rascunho não é servido a anônimo).
   UA curto devolve 406 do ModSecurity — não serve como prova.
5. **Provar que o site não mudou:** home 200 duas vezes, `<footer>` 3478 B com
   `politica-de-cookies`, `style.css?ver=1.3.8`.
6. **Parar.** Publicação é decisão do gestor/cliente, não sua.

## PROIBIDO

- Publicar, agendar, definir página inicial, mexer em menu, template part, tema ou
  plugin.
- Criar CSS, bloco novo, ou alterar qualquer página existente.
- Inventar dado de cliente: preço, prazo, CAU, área, número de visitas, depoimento.
- Reescrever o texto do arquivo de conteúdo, ainda que para "melhorar".
- Deixar PHP de diagnóstico no docroot.

## CRITÉRIO DE ACEITE

- Quatro IDs de página devolvidos, todos `status=draft`, com slug exato.
- Quatro URLs públicas em **404**.
- Home 200 duas vezes, rodapé 3478 B com o link, versão 1.3.8.
- Nenhuma página existente alterada (`wp_history_list` do período mostra só as criações).

## CONTRATO DE RETORNO

```
RESULTADO:
status: (feito | parcial | bloqueado)
paginas: (id, slug, status, bytes de conteudo, uma por linha)
arquivos_alterados:
comandos_executados:
evidencia: (os 4 status HTTP, as duas leituras da home)
nao_testado:
riscos:
proximo_passo:
```
