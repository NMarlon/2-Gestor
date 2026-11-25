# Revisão editorial das 4 páginas de serviço — 2026-11-24

Pedido: Marlon, Q-033 — revisão "antes → depois" das quatro páginas de serviço, para aprovação do dono do projeto.
Lido: `https://jessicahaguiwara.arq.br/consultoria/` (149.338 B) · `/projetos/` (149.167 B) · `/gestao-de-obra/` (149.132 B) · `/chave-na-mao/` (149.054 B), todas HTTP 200 em 2026-11-24, UA `Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0 Safari/537.36`, `curl` sem query string, uma leitura por URL.
Critério: só reescrever o que já existe, com motivo nomeável (redundância, frase longa, ambiguidade, jargão, promessa não sustentada, ordem fraca, CTA). Nada inventado, nada aplicado no site.

**Nota de estrutura (fato medido):** o HTML servido **não** tem `<article class="jhw-service">`. A copy das quatro páginas está em `<main id="wp--skip-link--target">` → `<h1 class="… wp-block-post-title …">` seguido de `<div class="entry-content wp-block-post-content">`, e termina num único parágrafo com CTA para o WhatsApp (`api.whatsapp.com/send?phone=5511983236422`). Medi o texto visível desse bloco, sem menu, rodapé nem scripts. As 11 citações do campo ANTES foram conferidas por busca literal contra o HTML baixado.

---

## /consultoria/ — Consultoria em arquitetura e interiores

A página é a mais bem escrita das quatro: a abertura ("Nem todo projeto começa do zero") faz o trabalho de segurar o leitor que não quer um projeto inteiro, e o corpo explica o serviço sem prometer prazo nem preço. Quatro ajustes. Um deles é o único erro de sentido real do conjunto: a página diz que nem todo caso tem projeto e, duas linhas depois, define a consultoria como "conversa com projeto".

| # | ANTES (verbatim) | DEPOIS (proposta) | Motivo |
|---|---|---|---|
| C1 | A consultoria é essa conversa com projeto. | A consultoria é essa conversa técnica sobre um espaço específico. | Ambiguidade e quase contradição: o parágrafo anterior afirma que nem todo caso começa com projeto, e a frase define o serviço por ter um projeto. A troca também não depende da resposta 10.1 do questionário (se a consultoria existe avulsa). |
| C2 | Muitas vezes o que falta é uma leitura técnica do espaço antes de uma decisão cara: derrubar uma parede, escolher o revestimento, definir onde fica a bancada, entender se aquele móvel cabe. | Muitas vezes o que falta é uma leitura técnica do espaço antes de uma decisão cara. Derrubar uma parede, escolher o revestimento, definir onde fica a bancada, saber se aquele móvel cabe. | Frase longa: 32 palavras com quatro exemplos depois dos dois-pontos. O ponto final separa a tese da lista e os exemplos passam a ser escaneáveis. Mesmos fatos, mesmo sentido. |
| C3 | Quem já tem o imóvel e quer clareza antes de contratar uma reforma; quem vai mobiliar e não sabe por onde começar; quem quer uma segunda opinião técnica sobre uma decisão já tomada. | (lista de três itens) 1. Quem já tem o imóvel e quer clareza antes de contratar uma reforma. 2. Quem vai mobiliar e não sabe por onde começar. 3. Quem quer uma segunda opinião técnica sobre uma decisão já tomada. | Ordem fraca: três perfis distintos espremidos numa frase com ponto e vírgula, logo abaixo de um H2 que é uma pergunta ao visitante. Em lista, ele se reconhece em um item. Texto idêntico, só a forma muda. |
| C4 | Fale sobre o seu projeto | Fale sobre o seu caso | CTA: a página inteira fala com quem talvez ainda não tenha projeto. É o único lugar onde o CTA genérico das quatro páginas custa alguma coisa. Se aplicado, o texto pré-preenchido do link do WhatsApp também muda (hoje diz "Quero saber mais sobre os serviços de Arquitetura"). |

## /projetos/ — Projeto de arquitetura e interiores

Boa página, e a mais concreta das quatro: nomeia as peças do projeto (planta, implantação, materiais, iluminação, mobiliário) e descreve o processo em ordem. Dois ajustes, ambos de forma: uma frase que carrega dois objetivos e um item de lista que repete o parágrafo de cima.

| # | ANTES (verbatim) | DEPOIS (proposta) | Motivo |
|---|---|---|---|
| P1 | O projeto é o desenho completo do espaço: planta, implantação, materiais, iluminação e mobiliário resolvidos juntos, para que a obra tenha direção e o resultado não dependa de improviso. | O projeto é o desenho completo do espaço: planta, implantação, materiais, iluminação e mobiliário resolvidos juntos. É o que dá direção à obra e evita que o resultado dependa de improviso. | Frase longa: 29 palavras, e o "para que" empilha dois objetivos (dar direção, evitar improviso) no fim de uma enumeração de cinco itens. Duas frases, mesmos fatos. |
| P2 | Briefing e conceito: entendimento da rotina, do estilo e das necessidades. | Briefing e conceito: a etapa em que a rotina vira desenho. | Redundância: o parágrafo anterior já descreve o briefing como "uma conversa próxima sobre como você vive, o que precisa guardar, como recebe, o que não abre mão". O item repete "rotina / estilo / necessidades" com outras palavras. A nova versão diz o que a etapa produz, não o que ela investiga. |

## /gestao-de-obra/ — Gestão de obra

A melhor abertura das quatro ("Entre o projeto aprovado e a obra pronta existe uma distância que não se resolve sozinha") e a lista mais concreta. Dois ajustes: um elogio vazio que enfraquece a frase que vem logo depois dele, e um jargão de prancha no meio da lista.

| # | ANTES (verbatim) | DEPOIS (proposta) | Motivo |
|---|---|---|---|
| G1 | O escritório acompanha a execução com rigor técnico e atenção aos detalhes, conferindo o que está sendo feito contra o que foi projetado, e resolvendo as adaptações que a obra sempre pede — com critério, não por improviso. | O escritório acompanha a execução conferindo o que está sendo feito contra o que foi projetado, e resolve as adaptações que a obra sempre pede — com critério, não por improviso. | Adjetivo vazio: "rigor técnico e atenção aos detalhes" é elogio que o próprio texto já prova ao dizer o que é conferido. Cortar os dois não tira fato nenhum e deixa a prova em primeiro plano. "resolvendo" vira "resolve" para casar com "acompanha". |
| G2 | Compatibilização entre projeto, fornecedores e mão de obra. | Alinhamento entre projeto, fornecedores e mão de obra, para que todos sigam a mesma versão. | Jargão: "compatibilização" é palavra de prancha técnica, não de cliente. A segunda metade explica o que o alinhamento evita, sem prometer nada novo (o parágrafo de cima já fala em "fornecedor que entrega diferente"). |

## /chave-na-mao/ — Projeto chave na mão

O melhor título e a melhor frase das quatro estão aqui ("você presente nas decisões que importam — e só nelas"; "Uma interlocução, um padrão de acabamento"). O problema está na lista: dois itens dizem a mesma coisa, com a mesma expressão, a três linhas de distância — e isso é visível a olho nu numa lista de quatro itens.

| # | ANTES (verbatim) | DEPOIS (proposta) | Motivo |
|---|---|---|---|
| M1 | Do projeto à entrega, com a tranquilidade de cuidar de cada etapa. | Do projeto à entrega, com cada etapa conduzida pelo escritório. | Ambiguidade: "a tranquilidade de cuidar" não diz quem cuida nem o que acontece — tranquilidade é efeito, não serviço. A troca usa o que o corpo já afirma ("com o escritório à frente das etapas") e mantém o "do projeto à entrega". |
| M2 | Etapas acompanhadas de perto, do primeiro esboço à entrega. | Coordenação de fornecedores e equipes ao longo da obra. | Repetição: o item 1 da mesma lista já diz "Um único ponto de contato do primeiro esboço à entrega". O intervalo e a promessa são idênticos. A vaga passa a cobrir o que o parágrafo anterior promete ("quem não tem tempo de coordenar fornecedores"), em vez de repetir. |
| M3 | Uma interlocução, um padrão de acabamento. | Um interlocutor só, um padrão de acabamento. | Jargão: "interlocução" é substantivo abstrato de ata de reunião. "Um interlocutor só" preserva o ritmo curto da frase com palavra comum. Não mexo na segunda metade — "um padrão de acabamento" é o que dá nome ao serviço. |

---

## Lacunas para o cliente responder (não inventar)

Nenhuma das quatro páginas afirma preço, prazo, frequência de visita, área de atendimento, número de projetos, CAU ou nome de obra. Isso está correto e não deve ser preenchido por mim. As perguntas abaixo já estão no `QUESTIONARIO-CLIENTE.md` deste projeto e continuam sem resposta:

1. **Q 10.1** — a consultoria pode ser contratada avulsa ou só existe dentro de um projeto maior? Hoje o texto serve para os dois casos; com a resposta, C1 pode virar uma frase mais forte.
2. **Q 10.2** — na gestão de obra, ela vai à obra e com que frequência? A página diz "acompanha a execução" sem prometer frequência; se for semanal, isso vira argumento na /gestao-de-obra/.
3. **Q 10.3** — no chave na mão, quem executa: equipe própria ou empreiteiros e fornecedores do cliente? Muda a frase de M2 e muda a expectativa de quem contrata.
4. **Q 11** — quanto tempo cada etapa leva. Nenhuma das quatro páginas tem prazo; é a primeira pergunta que o cliente faz no WhatsApp.
5. **Q 12** — faixas de orçamento do formulário (hoje provisórias). Sem isso não há como falar de investimento em nenhuma das quatro.
6. **O que o cliente recebe no fim da consultoria** — relatório, planta marcada, ata, encontro único ou série. A /consultoria/ descreve o que o escritório analisa e devolve, mas não o formato da entrega. É a lacuna que mais pesa na decisão de compra e não está no questionário.
7. **Consultoria presencial, online ou as duas coisas** — nenhuma página diz. Também não está no questionário, e é a primeira dúvida de quem mora longe.
8. **Q 1 e Q 8** — CAU e depoimentos reais não entram nestas quatro páginas, mas sustentam qualquer prova social que se queira acrescentar depois.

## O que eu NÃO mudaria

- **Os quatro H1.** Nomeiam o serviço sem adjetivo ("Consultoria em arquitetura e interiores", "Gestão de obra"). Servem para busca e para leitura; não há ganho em enfeitar.
- **"Nem todo projeto começa do zero."** (consultoria) — a melhor linha das quatro. Fala com quem não quer contratar um projeto inteiro, que é o público da consultoria.
- **"Entre o projeto aprovado e a obra pronta existe uma distância que não se resolve sozinha"** (gestão) — a única abertura que nomeia um problema concreto do cliente sem falar do escritório.
- **"e você presente nas decisões que importam — e só nelas."** (chave na mão) — específica, e define o serviço por oposição: não é ausência do cliente, é presença só onde importa.
- **"Correção de rota antes que o desvio vire custo."** (gestão) — imagem concreta em seis palavras. Não troco por "retrabalho", que já aparece na /consultoria/.
- **"Arquitetura e interiores desenvolvidos sob medida para o seu jeito de viver."** (projetos) — beira o clichê, mas é a única linha da página que fala da pessoa; sem ela a página fica só técnica. Não é hype vazio porque o corpo prova (briefing, rotina, como recebe).
- **O CTA único no WhatsApp nas quatro páginas.** Mesma ação em todo lugar, destino real, sem promessa. Só a palavra da /consultoria/ muda (C4); as outras três ficam.
- **A estrutura repetida:** H1 → subtítulo de uma linha → dois parágrafos → lista de quatro → "Para quem faz sentido" → CTA. Previsível no bom sentido; quem lê uma página sabe ler as outras.
- **A ausência de preço, prazo e garantia.** Conferi frase por frase: nenhuma das quatro promete prazo, preço, exclusividade, atendimento nacional ou número de projetos. Não há promessa a remover nesse eixo.
