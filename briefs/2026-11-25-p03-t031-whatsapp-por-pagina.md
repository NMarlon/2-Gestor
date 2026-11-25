# T-P03-031 — texto de WhatsApp por página de serviço (M-016 B)

Data: 2026-11-25 · Projeto: P-03 (jessicahaguiwara.arq.br) · Gestor: GESTOR-P03
Executor: OpenCode (agent build) · Origem: M-016 (B) do Gerente

## Objetivo

Trocar o texto do link de WhatsApp que fica **dentro do conteúdo** das 4 páginas de
serviço: cada uma passa a ter o seu texto, exatamente como na tabela abaixo. Nada
mais. Sem tema, sem CSS, sem menu, sem header, sem rodapé, sem cookies, sem SEO,
sem depoimentos.

## CONTEXTO JÁ VERIFICADO (não re-investigue)

- As 4 páginas e IDs: `/consultoria/` = **226**, `/projetos/` = **227**,
  `/gestao-de-obra/` = **228**, `/chave-na-mao/` = **229**.
- O link no corpo é `https://api.whatsapp.com/send?phone=5511983236422&text=<encoded>`.
  O `phone=5511983236422` **não muda**. Só o valor de `text=`.
- Texto antigo, idêntico nas 4, já codificado (**107 chars**):

      Ol%C3%A1!%20Quero%20saber%20mais%20sobre%20os%20servi%C3%A7os%20de%20Arquitetura%20de%20Jessica%20Haguiwara

  literal: `Olá! Quero saber mais sobre os serviços de Arquitetura de Jessica Haguiwara`
- No `post_content` o href está gravado com `&` cru (é JSON de bloco Gutenberg):
  busque só o trecho `text=Ol%C3%A1!...Haguiwara`, **nunca** com `&amp;`.
- Medição de 25/11 no HTML servido de `/consultoria/`: **1 ocorrência do texto antigo
  dentro do `entry-content`** (o CTA do corpo) e **2 fora** (header e rodapé, com
  `%0A` no fim). Isso é esperado e **não** se mexe: o texto genérico antigo continua
  valendo no header/rodapé. A conferência é sempre dentro do `entry-content`.
- Leitura/escrita por MCP:
  - ler: `wp_get_cpt_item @{rest_base:'pages', item_id:<id>}` → block markup bruto;
  - escrever: `wp_replace_in_post @{id, field:'post_content', search, replace}`.
    `field:'content'` é recusado com erro explícito. Não há parâmetro de regex —
    a busca é literal.
- Cache: `node scripts/diagnostics/purge-wpfc-once.mjs` (o próprio script grava o
  PHP de purge e apaga no fim; conferido em 25/11: "arquivo apagado (404 confirmado)").
  Sem purge a URL serve HTML velho e a medição mente.
- Baseline medido em 25/11 (HTML servido, 2 leituras idênticas, UA Chrome/131):
  `/consultoria/` 149.770 B · `/projetos/` 149.678 B · `/gestao-de-obra/` 149.667 B
  · `/chave-na-mao/` 149.601 B. O texto novo é mais curto, então os bytes **caem**.

## Tabela — texto de cada página (literal → codificado que vai no `text=`)

| página | ID | texto novo (literal) | codificado |
|---|---|---|---|
| /consultoria/ | 226 | `Olá! Quero conversar sobre consultoria para o meu projeto.` | `Ol%C3%A1!%20Quero%20conversar%20sobre%20consultoria%20para%20o%20meu%20projeto.` |
| /projetos/ | 227 | `Olá! Quero conversar sobre o projeto arquitetônico da minha casa.` | `Ol%C3%A1!%20Quero%20conversar%20sobre%20o%20projeto%20arquitet%C3%B4nico%20da%20minha%20casa.` |
| /gestao-de-obra/ | 228 | `Olá! Quero conversar sobre gestão da minha obra.` | `Ol%C3%A1!%20Quero%20conversar%20sobre%20gest%C3%A3o%20da%20minha%20obra.` |
| /chave-na-mao/ | 229 | `Olá! Quero conversar sobre o projeto completo, do início à entrega.` | `Ol%C3%A1!%20Quero%20conversar%20sobre%20o%20projeto%20completo%2C%20do%20in%C3%ADcio%20%C3%A0%20entrega.` |

Bytes esperados no HTML servido depois da troca (baseline menos o delta do encoded:
-28, -14, -35, -3):

| página | esperado |
|---|---|
| /consultoria/ | 149.742 B |
| /projetos/ | 149.664 B |
| /gestao-de-obra/ | 149.632 B |
| /chave-na-mao/ | 149.598 B |

Tolerância de ±4 B (o resto da página não pode mudar). **Crescimento é erro** — pare
e reporte se a página ficar maior que o baseline.

## Escopo (nesta ordem)

1. Para cada página, na ordem 226, 227, 228, 229:
   a. `wp_get_cpt_item` e conte quantas vezes o trecho antigo aparece no `post_content`;
   b. `wp_replace_in_post` trocando o trecho antigo pelo codificado da tabela
      (somente esse trecho; não troque a URL inteira, não toque no `phone`);
   c. releia e reconte: **0 do antigo, 1 do novo**. Se sobrou antigo, repita (máximo
      3 chamadas na mesma página). Se ainda sobrar, **pare** e reporte.
2. `node scripts/diagnostics/purge-wpfc-once.mjs`.
3. Meça o HTML servido das 4 URLs: `urllib`/`curl`, UA
   `Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36`,
   `Accept-Encoding: identity`, **sem query string e sem no-cache**, 2 leituras por
   URL. Grave status, bytes e md5 de cada leitura.
4. Na fatia `entry-content` → `</main>` de cada página, conte ocorrências do texto
   antigo e do novo (é a contagem que vale; no HTML inteiro o rodapé dá falso
   positivo de propósito).

Não meça navegador nesta tarefa — `medir-cdp.py` é do gestor.

## Proibido

- Qualquer arquivo do tema (`jessica-haguiwara-child/`), `scripts/`, `release.json`,
  `AGENTS.md`, `DOCS/`.
- Menu, header, rodapé (os 2 links de WhatsApp fora do corpo), cookies/Complianz,
  Yoast/SEO, depoimentos, título, excerpt, slug, status, datas.
- Criar post novo, apagar revisão, mexer em rascunho.
- Trocar o `phone=` ou o formato do link (`api.whatsapp.com`, não `wa.me`).
- Rodar deploy de tema de qualquer tipo.
- Gravar a chave/token em relatório, print ou commit.

## Critério de aceite

1. `wp_get_cpt_item` das 4 páginas: **0** ocorrências do trecho antigo no
   `post_content`, **1** do novo daquela página.
2. HTML servido após purge, na fatia `entry-content` → `</main>`: **0** antigo,
   **1** novo por página; e nenhuma página com o texto de outra.
3. Bytes servidos dentro da tabela de esperados (±4 B).
4. `git status --short` no repo do projeto: nada além do que já estava
   (`planejamento/Obsidian Pages/DEPOIMENTOS - PROXY.md`). Tarefa sem arquivo
   alterado = sem commit.
5. Relatório no contrato abaixo.

## Contrato de retorno

    RESULTADO / status / arquivos_alterados / comandos_executados / evidencia /
    nao_testado / riscos / proximo_passo

Em `evidencia`, por página: contagem antes/depois no `post_content`, link final do
`text=`, e as 2 leituras (status, bytes, md5) com a contagem dentro do `entry-content`.
Em `arquivos_alterados`, escreva "nenhum arquivo (post_content de 226–229 via MCP)".
