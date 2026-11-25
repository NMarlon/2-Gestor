# T-P03-026 — revisão editorial das 4 páginas de serviço (10 das 11 propostas)

Projeto: P-03 Jessica Haguiwara · site `https://jessicahaguiwara.arq.br` · tema `jessica-haguiwara-child`
Brief de: GESTOR-P03 · data: 2026-11-25 · origem: M-004 do Gerente (`DOCS/08-GERENTE/PARA-GESTORES.md`)
Fonte do texto: `DOCS/P-03-Jessica-Haguiwara/REVISAO-EDITORIAL-2026-11-24.md` (Q-033, aprovada com 1 veto)

## ESCOPO ÚNICO

Aplicar **10 trocas de texto** no `post_content` de **4 páginas** (IDs 226, 227, 228, 229), exatamente como
escritas abaixo. Nove são substituição de trecho; uma (C3) converte um parágrafo em lista de três itens.
**Nada além disso.** Não é tarefa de deploy, de tema, de SEO, de menu, de home.

**P2 está VETADA pelo dono do projeto** e não pode mudar nem um byte.

## CONTEXTO JÁ VERIFICADO (não re-investigue)

Medido por mim em 2026-11-25, em duas leituras idênticas por URL (UA `Mozilla/5.0 (Windows NT 10.0; Win64;
x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0 Safari/537.36`, `curl` sem query string,
`https://jessicahaguiwara.arq.br`):

| Página | URL | ID | Bytes servidos | md5 |
|---|---|---|---|---|
| consultoria | `/consultoria/` | 226 | 149.346 | `4dfb983b56d0c59c79b8b3536d68b747` |
| projetos | `/projetos/` | 227 | 149.175 | `5398826c11a96c23bb701a1005def99f` |
| gestão de obra | `/gestao-de-obra/` | 228 | 149.140 | `14a200cc372fc1c1d3bd11c1f4bdd70d` |
| chave na mão | `/chave-na-mao/` | 229 | 149.062 | `ba77eb353b69083c74360aaae1b27848` |

Confirmado: as 11 citações do campo ANTES existem **1× cada** no HTML servido, dentro de
`<div class="entry-content … wp-block-post-content">`. O HTML servido **não** tem `<article class="jhw-service">`
nem os delimitadores `<!-- wp:… -->` (o WordPress os remove na renderização). O CSS servido é `style.css?ver=1.3.10`;
a T-P03-025 está fechada — não mexa em estilo.

Duas armadilhas já medidas neste site, e que valem para esta tarefa:

1. **`wptexturize()`** roda no `the_content` e transforma `" - "` em `&#8211;`. Portanto **o HTML servido não é
   fonte confiável para montar o `search`**: copie o trecho **do conteúdo cru** devolvido por `wp_get_cpt_item`.
   Os textos desta tarefa usam travessão `—` digitado (não hífen), que passa intacto.
2. **O `search` é literal** (`regex: false`) e tem limite de **500 caracteres**. Todas as buscas abaixo têm
   menos de 230 caracteres — cabem.

Fato que muda o critério de aceite do M1: a frase ANTES do M1 é **também** o `og:description` da
`/chave-na-mao/` (ela aparece 2× no HTML servido: 1× no `entry-content`, 1× na meta). A meta é Yoast e
**está fora do escopo** (Yoast nem grava por MCP neste site, §28 do caderno). Depois da troca, é **correto**
que a frase antiga do M1 continue aparecendo **1× na meta** — o que tem de zerar é a ocorrência dentro do
`entry-content`.

## AS 10 TROCAS (verbatim — não reescreva, não "melhore")

### Página 226 · `/consultoria/` — 4 trocas

**C1** — substituição de trecho dentro de um parágrafo.
- search: `A consultoria é essa conversa com projeto.`
- replace: `A consultoria é essa conversa técnica sobre um espaço específico.`
- delta esperado: +23 chars (+26 bytes)

**C2** — substituição de trecho dentro de um parágrafo.
- search: `Muitas vezes o que falta é uma leitura técnica do espaço antes de uma decisão cara: derrubar uma parede, escolher o revestimento, definir onde fica a bancada, entender se aquele móvel cabe.`
- replace: `Muitas vezes o que falta é uma leitura técnica do espaço antes de uma decisão cara. Derrubar uma parede, escolher o revestimento, definir onde fica a bancada, saber se aquele móvel cabe.`
- delta esperado: −3 chars (−3 bytes)

**C3** — **troca estrutural**: o parágrafo inteiro vira lista de 3 itens (bloco `wp:list` com 3 `wp:list-item`).
- search: o **bloco de parágrafo inteiro**, copiado do cru, incluindo os delimitadores. No molde padrão é
  `<!-- wp:paragraph -->` + `\n` + `<p>Quem já tem o imóvel e quer clareza antes de contratar uma reforma; quem vai mobiliar e não sabe por onde começar; quem quer uma segunda opinião técnica sobre uma decisão já tomada.</p>` + `\n` + `<!-- /wp:paragraph -->` (233 chars).
  **Se o cru estiver em outro molde, use o molde real** — nunca busque só o texto solto, senão a `<ul>` nasce
  dentro de um `<p>`.
- replace: bloco de lista, no molde abaixo, com os três itens **sem numeração escrita** (`1.`/`2.`/`3.` são
  só a contagem da tabela da revisão — a numeração é do `<li>`, não do texto):

```
<!-- wp:list -->
<ul class="wp-block-list"><!-- wp:list-item -->
<li>Quem já tem o imóvel e quer clareza antes de contratar uma reforma.</li>
<!-- /wp:list-item -->
<!-- wp:list-item -->
<li>Quem vai mobiliar e não sabe por onde começar.</li>
<!-- /wp:list-item -->
<!-- wp:list-item -->
<li>Quem quer uma segunda opinião técnica sobre uma decisão já tomada.</li>
<!-- /wp:list-item --></ul>
<!-- /wp:list -->
```

- As três frases são as do ANTES, com `;` virando ponto final e o espaço após o `;` removido. O `H2`
  "Para quem faz sentido" acima do bloco **não se toca**.
- **Molde:** a mesma página já tem uma `<ul class="wp-block-list">` de 4 itens. Espelhe a serialização
  dela (com ou sem `<!-- wp:list-item -->`) em vez de inventar outra — o bloco novo tem de parecer irmão
  do que já está lá.
- delta esperado: **depende do molde** — no molde padrão acima dá +174 chars. Reporte o delta real.

**C4** — troca só do rótulo do link do CTA.
- search: `Fale sobre o seu projeto`
- replace: `Fale sobre o seu caso`
- delta esperado: −3 chars (−3 bytes)
- O `href` (`api.whatsapp.com/send?phone=5511983236422&text=…`) **não se toca**: o texto pré-preenchido
  continua "Quero saber mais sobre os serviços de Arquitetura". A revisão diz que ele também mudaria, mas
  **não há texto DEPOIS aprovado** para ele — inventar seria terceira versão. Deixe como está e reporte.

### Página 227 · `/projetos/` — 1 troca

**P1** — o parágrafo inteiro (só o texto; o bloco continua parágrafo).
- search: `O projeto é o desenho completo do espaço: planta, implantação, materiais, iluminação e mobiliário resolvidos juntos, para que a obra tenha direção e o resultado não dependa de improviso.`
- replace: `O projeto é o desenho completo do espaço: planta, implantação, materiais, iluminação e mobiliário resolvidos juntos. É o que dá direção à obra e evita que o resultado dependa de improviso.`
- delta esperado: +2 chars (+4 bytes)

**P2 — VETADA. Não execute nada nesta página sobre `Briefing e conceito: entendimento da rotina, do estilo e das necessidades.`** A frase tem de continuar idêntica (conferível: continua 1× no cru e 1× no servido).

### Página 228 · `/gestao-de-obra/` — 2 trocas

**G1** — o parágrafo inteiro (só o texto).
- search: `O escritório acompanha a execução com rigor técnico e atenção aos detalhes, conferindo o que está sendo feito contra o que foi projetado, e resolvendo as adaptações que a obra sempre pede — com critério, não por improviso.`
- replace: `O escritório acompanha a execução conferindo o que está sendo feito contra o que foi projetado, e resolve as adaptações que a obra sempre pede — com critério, não por improviso.`
- delta esperado: −45 chars (−48 bytes)

**G2** — item de lista (só o texto do `<li>`).
- search: `Compatibilização entre projeto, fornecedores e mão de obra.`
- replace: `Alinhamento entre projeto, fornecedores e mão de obra, para que todos sigam a mesma versão.`
- delta esperado: +32 chars (+31 bytes)

### Página 229 · `/chave-na-mao/` — 3 trocas

**M1** — o parágrafo inteiro (só o texto).
- search: `Do projeto à entrega, com a tranquilidade de cuidar de cada etapa.`
- replace: `Do projeto à entrega, com cada etapa conduzida pelo escritório.`
- delta esperado: −3 chars (−2 bytes)
- Atenção: essa string é também o `og:description` (meta). O `search` precisa casar **1×** no `post_content`.
  Se o retorno disser `replacements_count: 1`, está certo. **Não toque na meta.**

**M2** — item de lista (só o texto do `<li>`).
- search: `Etapas acompanhadas de perto, do primeiro esboço à entrega.`
- replace: `Coordenação de fornecedores e equipes ao longo da obra.`
- delta esperado: −4 chars (−4 bytes)

**M3** — trecho no fim de um parágrafo (só o texto).
- search: `Uma interlocução, um padrão de acabamento.`
- replace: `Um interlocutor só, um padrão de acabamento.`
- delta esperado: +2 chars (+1 byte)

## FERRAMENTA E MÉTODO

1. **Leia antes de escrever.** Para cada página: `wp_get_cpt_item` com `{ rest_base: 'pages', item_id: <ID> }`.
   Salve o `content` cru em `logs/t026/antes-<slug>.html` (`logs/` já é ignorado pelo git) e confirme que as
   strings ANTES casam 1× no cru. **Se alguma não casar 1×, pare e reporte — não aproxime, não reescreva.**
2. **Escreva com `wp_replace_in_post`**: `field: "post_content"`, `regex: false`, `max_replacements: 1`.
   Uma chamada por troca, na ordem em que estão escritas aqui (C1, C2, C3, C4, P1, G1, G2, M1, M2, M3).
3. **Critério por chamada:** `replacements_count` **tem de ser 1**. Se vier `0` (não casou) ou `>1`
   (ambíguo), **pare a tarefa** e reporte — não tente contornar com busca mais curta.
   O `content_length_after − content_length_before` tem de bater com o delta esperado (em bytes; o plugin
   usa `strlen`). Divergência de sinal ou de magnitude = investigar antes da chamada seguinte.
4. **Depois das 10:** releia as 4 páginas com `wp_get_cpt_item` e conte, no cru: cada DEPOIS 1×, cada ANTES
   0× (M1 e P2 conforme acima), `Briefing e conceito: entendimento da rotina` 1×.
5. **Purge do WPFC** (senão o servido continua velho): `node scripts/diagnostics/purge-wpfc-once.mjs`,
   da raiz do repo. Guarde o JSON de retorno. Se falhar, reporte — não invente outro caminho de purge.
6. **Prova no HTML público** (depois do purge, sem query string): GET nas 4 URLs e conte, dentro do
   `entry-content`: cada DEPOIS 1×, cada ANTES 0×. Registre status, bytes e md5 de cada uma.
   - Em `/consultoria/`: `Fale sobre o seu caso` 1× e `Fale sobre o seu projeto` 0×.
   - Em `/projetos/`, `/gestao-de-obra/`, `/chave-na-mao/`: o CTA continua `Fale sobre o seu projeto` 1×.
   - Em `/chave-na-mao/`: `Do projeto à entrega, com a tranquilidade` → 0× no `entry-content`, 1× no
     `og:description` (esperado, é meta).

## PROIBIDO TOCAR

- P2 (vetada) e qualquer outra frase das 4 páginas que não esteja na tabela acima.
- H1, H2, subtítulos, títulos (`post_title`), slugs, excerpt, status, autor, datas, ordem das páginas.
- Qualquer meta de SEO/Yoast (`_yoast_wpseo_*`) — não há tool que grave, e está fora do escopo.
- Outras páginas (home 38, política de privacidade 3, contato, obrigado) e outros posts/CPTs.
- Tema: nenhum arquivo em `jessica-haguiwara-child/` (`style.css`, `functions.php`, templates, `release.json`).
- Menu (`wp_navigation`), plugins, MCP config, `.env`, `opencode.json`.
- Deploy (`deploy-theme.mjs`) — **não há deploy nesta tarefa**, o conteúdo vive no banco. Rodar deploy aqui é erro.
- Commit no repo do projeto: esta tarefa não deve produzir diff versionado. Evidência vai em `logs/t026/`.

## CRITÉRIO DE ACEITE (verificável)

1. 10 chamadas a `wp_replace_in_post`, todas com `replacements_count: 1` e delta compatível com a tabela.
2. Releitura do cru: 10 DEPOIS presentes 1×; 10 ANTES ausentes; P2 intacta; nenhum outro trecho alterado.
3. C3 é `<ul class="wp-block-list">` com exatamente 3 `<li>`, irmã do `H2` (não dentro de `<p>`, não dentro
   do `H2`) — e cada `<li>` com uma das três frases.
4. `/consultoria/` com CTA `Fale sobre o seu caso`; as outras três com o CTA antigo, 1× cada.
5. Purge executado; 4 URLs HTTP 200 no HTML público; contagens do item 2 batendo no `entry-content`;
   `/chave-na-mao/` com 1 ocorrência da frase antiga do M1 **só** na meta.
6. `git status --short` do repo do projeto **igual antes e depois** (rode e guarde antes de começar; já existe
   hoje um arquivo modificado por outro trabalho, `planejamento/Obsidian Pages/DEPOIMENTOS - PROXY.md` — não é seu).
7. Nenhuma promessa nova: as 10 trocas não introduzem preço, prazo, garantia, exclusividade, área de
   atendimento, número de projetos, CAU ou depoimento. Se o seu diff introduzir algo assim, é erro.

## CONTRATO DE RETORNO

Responda exatamente nesta forma, em português:

```
RESULTADO: <uma frase: o que está no ar agora>
status: concluido | parcial | bloqueado
arquivos_alterados: <no repo do projeto: esperado "nenhum"; liste os arquivos de logs/t026/ que criou>
comandos_executados: <as 10 chamadas com id + trecho que buscava; o purge; os GETs>
evidencia: <tabela: página | replacements_count | content_length antes→depois (delta) ; depois: página | status | bytes | md5 ; contagens ANTES/DEPOIS no cru e no servido>
nao_testado: <o que você não conseguiu provar>
riscos: <ex.: revisões criadas, WPFC, meta do M1 desatualizada em relação ao corpo>
proximo_passo: <o que o gestor precisa decidir>
```

Se qualquer passo falhar no meio: pare, não "conserte" o texto por conta própria, e devolva `status: parcial`
com o que já foi aplicado (id + troca), para eu decidir rollback por revisão.
