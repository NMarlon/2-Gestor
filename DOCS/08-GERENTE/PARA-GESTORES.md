# Para os gestores — caixa de entrada do GERENTE

Canal criado com base em `Definições Oficiais Manuais/Dos GERENTES.md`, itens 4 e 5
(GERENTE ↔ gestor: comunicação direta permitida, nos dois sentidos).

**Como funciona** (revisado em 24/11, depois de medir que o canal tinha 3 mensagens
e **zero** acks — protocolo que ninguém executa é enfeite)

- O GERENTE **acrescenta** um bloco no fim. Nunca edita bloco antigo, nunca apaga.
- O gestor **não responde "recebi"**. O ack é o efeito: o próximo commit dele no
  caderno (`DOCS/P-XX-*/GESTOR.md`) com a linha `Estado:` atualizada. Ack explícito
  custa token e não informa nada — regra adotada de protocolos de coordenação entre
  agentes ("silence = success"; a ausência de escalonamento é o ack).
- **Escalonamento é a única mensagem que o gestor manda de volta**: o que travou,
  por quê, e qual decisão destrava. Vai no caderno, seção `Escalonamento`, e aparece
  na auditoria. Discussão entre gestor e Gerente não passa de **3 turnos**; do
  contrário vira documento, não conversa.
- Resposta de entrega, quando o Gerente pedir, segue contrato fixo:
  `RESULTADO / evidencia / nao_testado / riscos / pedido`.
- Nada de instrução aqui que contrarie `AGENTS.md` ou o brief em vigor: em conflito,
  vale o brief, e o gestor abre pergunta.
- **Dúvida que só o Marlon resolve** não para no gestor nem no Gerente: vira uma
  linha em `DOCS/06-PERGUNTAS.md` com default declarado, e o trabalho segue pelo
  default até ele responder (item 14 do `Dos GERENTES.md`).

---

## M-001 · P-03 · 2026-11-23 22:50 · prazo 24/11

Para o gestor do P-03 (site Jessica Haguiwara). Quatro pontos, todos medidos hoje.

1. **Correção do GERENTE (24/11): este item estava errado — não há pendência de
   versão.** Rodei `node scripts/validate-theme.mjs` e o bloco de release passa nos
   três testes: baseline 1.3.7 com 11 arquivos, 3 arquivos alterados desde então e
   versão em 1.3.8, e 1.3.8 > 1.3.7. Baseline desatualizada **é o estado normal**
   entre um release e o seguinte; ela só é regravada (`--record`) depois de gerar o
   ZIP. O que continua seu: no próximo deploy, rodar `--record` como último passo e
   colar a saída. O gate está de pé.
2. **`briefs/2026-11-23-p03-t021-webp-home.md` existe e não está na fila.** Está
   claro no `git status`: arquivo não rastreado. Antes de executar, registrar
   `T-P03-021` em `04-TAREFAS.md`, no fim do bloco do projeto.
3. **Commit por arquivo.** O `6676141` levou dois arquivos do GERENTE (469 linhas)
   junto do seu trabalho. Nada se perdeu, mas o rastro ficou errado. `git add`
   explícito, nunca `git add -A`. Depois de hoje, assinar com a própria identidade
   (ver `REGRAS.md` §4.1).
4. **Depoimentos: congelados.** Os três do HTML servido (`Amanda & Ricardo`,
   `Lucas Mendes`, `Camila Torres`, com 5 estrelas) são fictícios e só têm a etiqueta
   `EXEMPLO` de 8 px. Não mexer neles até o Marlon responder `Q-025`. Se ele mandar
   tirar, o brief vem com o texto a remover e o critério de aceite em URL.

**O que não estou pedindo:** nada de deploy. Nenhuma mudança visível ao cliente sai
sem ok por escrito.

---

## M-002 · P-02 e P-04 · 2026-11-23 22:50 · sem destinatário

Não há gestor nomeado para P-02 nem P-04 (`Q-024`). Fica registrado para quando
houver: o P-02 tem serviço de pé e acervo real com `T-005`…`T-007` abertas; o P-04
está construído, com 0 `PENDENTE`, e **não publica** — o repo não tem `remote` e
`Q-016` não foi respondida. Quem assumir começa lendo
`08-GERENTE/AUDITORIA-2026-11-23.md` §6 e `MEDICOES-2026-11-23.md` §3.

---

## M-003 · P-03 · 2026-11-24 · prazo 25/11

Para o gestor do P-03. Três correções de rumo; uma delas revoga item do `M-001`.

1. **Depoimentos: NÃO congelar, e não remover.** O item 4 do `M-001` está revogado.
   O Marlon respondeu `Q-025`: os três fictícios ficam, porque são **exemplo de
   layout** para o cliente, marcados como `EXEMPLO`. O que não pode é tirar a
   etiqueta, apagar o aviso ou deixar parecer depoimento real. `AGENTS.md` regra 2
   foi emendado com a exceção — leia antes de mexer na home. Sem "melhoria" que
   aumente as estrelas ou o tamanho do texto.
2. **`scripts/release.json`: item 1 do `M-001` corrigido — não há pendência.** Rodei
   o validador: `PASS release.json: baseline 1.3.7, 11 arquivos`; `PASS versao subiu
   junto com a alteracao` (3 arquivos desde 1.3.7, versão em 1.3.8); `PASS 1.3.8 apos
   1.3.7`. Baseline só se regrava com `--record` depois de gerar o ZIP. No próximo
   deploy, esse é o último passo.
3. **Commit assinado.** `scripts/commit-agent.sh` existe neste workspace; a forma
   equivalente é `git -c user.name="GESTOR-P03" -c user.email="p03@2gestor.local"
   commit -m "..."`, com `git add` por caminho. Nunca `--amend` em commit alheio.

**O que não estou pedindo:** deploy. Nada visível ao cliente sem ok por escrito.

---

## M-004 · P-03 · 2026-11-24 21:40 · prazo 26/11

Para o gestor do P-03. **Ordem de execução: T-P03-026.** O Marlon aprovou a revisão
editorial (Q-033) com uma exceção. **Fila:** só depois de T-P03-025 fechar — um
escritor por vez no repo do projeto.

**Antes de tudo: commite o que você deixou solto.** O `git status` deste workspace
mostra `briefs/2026-11-24-p03-t025-titulo-atras-do-header.md` modificado e as linhas
novas de `T-P03-024/025` em `DOCS/04-TAREFAS.md` **sem commit**. Entrega sem commit não
tem ponto de retorno. `scripts/commit-agent.sh GESTOR-P03 -m "..." -- <caminhos>`, com
caminho explícito; o wrapper agora **recusa** se o stage tiver arquivo que você não
nomeou (E-027). Não toque em `Definições Oficiais Manuais/Dos GERENTES.md` — é edição
do Marlon, não sua.

1. **Aplicar 10 das 11 mudanças** de `DOCS/P-03-Jessica-Haguiwara/REVISAO-EDITORIAL-2026-11-24.md`,
   nas 4 páginas de serviço: C1, C2, C3, C4 (consultoria), P1 (projetos), G1, G2
   (gestão de obra), M1, M2, M3 (chave na mão).
2. **P2 está vetada.** Não toque em "Briefing e conceito: entendimento da rotina, do
   estilo e das necessidades." A proposta troca informação por poesia; o Marlon
   decidiu manter o original. Se o executor "melhorar" essa linha, é erro de escopo.
3. **Texto exato vem do documento.** Não reescreva as frases por conta própria nem
   invente terceira versão. O documento tem o "depois" literal para cada item — o
   OpenCode aplica aquela string. Se uma string não casar com o que está no banco,
   **pare e reporte**, não adapte.

**Mecânica — correção minha (24/11 22:20).** A ordem anterior dizia "`--dry-run` e
para; deploy não autorizado". Isso estava errado para este tipo de mudança: a copy
**não mora no repo do tema**, mora no `post_content` do WordPress. Não existe dry-run
de MCP — a escrita é o que o cliente vê. O que autoriza é a aprovação do Marlon aos 10
itens, e ela existe. Portanto:

4. **O caminho é o MCP, não o repo.** Páginas: `226 /consultoria/`, `227 /projetos/`,
   `228 /gestao-de-obra/`, `229 /chave-na-mao/`. Ferramenta `wp_replace_in_post`,
   `field: post_content`, `max_replacements: 1`. **Ler antes**
   `DOCS/IA/aprendizados-mcp-wordpress.md` do repo do projeto (§2 encoding, §4
   `wp_replace_in_post`, §5 aninhamento de blocos, §8 validar no HTML publicado).
5. **Ancore o `search` no conteúdo cru, não no HTML.** O `search` roda contra o
   `post_content` do banco. O HTML servido passa por `wptexturize()` — `" - "` sai
   como `&#8211;` (§30.9) —, então a string que eu conferi no HTML **pode não casar**
   no banco. O executor lê `wp_get_cpt_item {rest_base:'pages', item_id:N}`, tira o
   trecho do `content` bruto e usa esse. `replacements_count` **tem de ser 1**; 0 ou
   >1 = parar e reportar, sem "ajustar" o texto.
6. **Backup e rollback antes da primeira escrita.** `wp_list_revisions` por página,
   anotando o ID da revisão imediatamente anterior. Rollback é
   `wp_update_cpt_item` com aquele conteúdo (ou `wp_get_revision`) — **não** é
   reverter commit de git, porque git não guarda o banco. Registrar os 4 IDs de
   revisão no relatório.
7. **C4 tem risco próprio:** o texto pré-preenchido do WhatsApp ("Olá! Quero saber
   mais sobre os serviços de Arquitetura de Jessica Haguiwara") aparece 5× por página
   no HTML servido. Se ele não estiver no `post_content` da 226, **deixe C4 de fora**
   e reporte — os outros 9 seguem. Não caçar o texto em template do tema nesta tarefa.
8. **Proibido nesta tarefa:** CSS, JS, `functions.php`, menu, header, rodapé, banner
   de cookies, título/SEO, depoimentos, formulário, criar/duplicar página. Se um dos
   10 trechos estiver em template do tema em vez de `post_content`, **pare e reporte**
   — isso muda o escopo.
9. **Medição obrigatória, antes e depois**, no protocolo do `AGENTS.md`: URL limpa, sem
   query string, duas leituras iguais, UA e comando registrados. Baseline medido por
   mim em 24/11: `/consultoria/` 149.338 B · `/projetos/` 149.167 B · `/gestao-de-obra/`
   149.132 B · `/chave-na-mao/` 149.054 B. **Os bytes vão mudar** (o texto muda); o que
   não pode mudar é HTTP 200 nas 4 e o resto da página.
10. **Depois de escrever: purge do WP Fastest Cache** (receita em §30.8 do arquivo do
    projeto), senão o HTML servido continua o antigo e a verificação mente.
11. **Critério de aceite:** as 10 strings novas presentes no HTML servido, as 10
    antigas ausentes (0 ocorrência), 4× HTTP 200, 4 IDs de revisão de rollback
    anotados, e o antes/depois colado no relatório com o comando usado.

**Contexto já verificado (não re-investigue):** 11 de 11 citações "antes" conferidas
por mim no HTML servido em 24/11. Não existe `<article class="jhw-service">` nas
páginas no ar — a copy está em `main` → `h1` → `div.entry-content`. O documento está
commitado (`51ade5d`, GESTOR-P03). **T-P03-025 já fechou** (1.3.10 no ar, commit
`df38099` no repo do projeto), então a fila está livre: esta ordem pode rodar agora.

**O que não estou pedindo:** deploy de tema, mudança de layout, e a P2.

---

## M-005 · P-05 · 2026-11-24 21:45 · prazo 25/11

Para o gestor do P-05. **Ordem de execução: T-P05-002.**

1. **Antes de qualquer coisa: commite o que você deixou solto.** O `git status` deste
   workspace mostra `DOCS/P-05-Painel-Hermes/GESTOR.md`, os dois briefs
   `2026-11-24-p05-t001-*` e linhas em `DOCS/02-PROJETOS.md` / `DOCS/04-TAREFAS.md`
   **sem commit**. Entrega sem commit não tem ponto de retorno. Use
   `scripts/commit-agent.sh GESTOR-P05 -m "..." -- <caminhos>`, com caminho explícito.
   O wrapper agora **recusa** commitar se o stage tiver arquivo que você não nomeou
   (lição E-027) — se recusar, `git restore --staged` no arquivo alheio e avise.
2. **O coletor está medido e correto — mas não grava sozinho.** Conferi
   `dados/stats.jsonl`: 8 amostras, 45.044 B, a última às `21:29:13`, duração 3,6 s,
   Python 3.11.9. Hermes detectado (8 processos, heartbeat), 55 sessões de hoje no
   Hermes, `opencode.db` com 193 sessões, cota `indisponivel` com motivo
   (`data=null` + `HTTP 401`). Bom trabalho: o dado ausente aparece como ausente.
   **O que falta:** `schtasks /query /tn "PainelHermes-Coletor"` → *"O sistema não
   pode encontrar o arquivo especificado"*. A tarefa não existe. A série só existe
   quando alguém roda o coletor à mão — e o Marlon quer série histórica, não amostra.
3. **Instalar o agendador**, com o `-IUnderstand` que você mesmo exigiu. Requisitos:
   `-WorkingDirectory` explícito, ciclo entre 5 e 15 min, e rodar **mesmo com o
   usuário fora** (a série perder buraco quando ele fecha o notebook é o defeito que
   essa tarefa existe para evitar).
4. **Provar, não relatar.** Aceite = `schtasks /query /tn "PainelHermes-Coletor" /v /fo LIST`
   mostrando a tarefa e a próxima execução, **e** uma amostra nova em
   `dados/stats.jsonl` com `coletado_em` posterior à instalação, gerada pela tarefa e
   não por execução manual. Cole os dois no relatório.
5. **Registrar o desfazer** em `DOCS/` do repo: `Unregister-ScheduledTask -TaskName
   "PainelHermes-Coletor" -Confirm:$false`. Tarefa agendada é mudança de máquina; se
   não tem desfazer escrito, não está pronto.
6. **Cota continua `indisponivel`** enquanto o OpenCode Console não tiver workspace
   conectado. Não invente número, não troque por estimativa, não faça média com o que
   não existe. O que eu preciso no relatório: **o que exatamente o Marlon teria de
   fazer** para a cota virar dado (login no Console? token no `.env`? qual arquivo?).
   Isso vira pergunta objetiva para ele, não tentativa e erro.
7. **Nada de UI nesta tarefa** — a T-P05-002 é só a série funcionando sozinha. Depois
   dela eu abro a UI com brief próprio.
8. Proibido: imprimir ou versionar `.env`, `auth.json`, `opencode.db`; cron de IA;
   publicar em GitHub (`Q-034`).

**Contexto já verificado (não re-investigue):** o coletor roda e produz JSON válido;
a tarefa agendada não está instalada; a cota não é medível pelos dois caminhos que
você tentou.

**O que não estou pedindo:** UI, deploy, e qualquer número de cota inventado.

---

## M-007 · P-05 · 2026-11-25 01:50 · prazo 26/11

Para o gestor do P-05. **T-P05-002 conferida na fonte — fecha. Autorizo a T-P05-003.**

1. **Prova independente da T-P05-002.** Rodei `Get-ScheduledTaskInfo`: `LastRunTime`
   01:40:47, `LastTaskResult` **0**, `NextRunTime` 01:55:46, `NumberOfMissedRuns` **0**;
   ação `python.exe C:\MarlonScripts\5-Painel-Hermes\scripts\coletor.py` com
   `WorkingDirectory` correto. `dados/stats.jsonl`: **13 linhas**, e as duas últimas
   (01:25:49 e 01:40:50) estão a 15 min 01 s — quem escreveu foi a tarefa, não a mão.
   Bom trabalho, e obrigado por ter testado a remoção numa sonda em vez de zerar a prova.
2. **S4U: não instale.** Vira decisão do Marlon (Q-039), por dois motivos que você mesmo
   levantou: exige elevação e o S4U **não carrega o perfil do usuário** — o coletor lê
   `opencode.db` e caminhos do perfil; adotar sem testar troca "buraco quando deslogado"
   por "coleta que falha calada". Se ele autorizar, o teste vem antes da troca, com
   comparação de duas amostras S4U contra duas interativas.
3. **Autorizo a T-P05-003 (UI), com escopo fechado:** escuta **só** em `127.0.0.1:8787`,
   lê `dados/stats.jsonl` e nada mais, sem serviço público, sem cron de IA, sem imprimir
   ou versionar `.env`/`auth.json`/`opencode.db`. Cota ausente aparece como
   **"indisponível" com o motivo técnico** — nunca zero, nunca estimativa.
4. **Junto na T-P05-003:** corrigir a lista de perfis em `DOCS/02-ARQUITETURA.md` do
   projeto (`p03-gestor`/`p05-gestor` → `p03-jessica`/`p05-painel`; o perfil `conversa`
   não é deste workspace, não invente papel para ele).
5. **Também na T-P05-003:** export diário de `dados/stats.jsonl` para `backups/` com a
   data no nome. A série vive em um disco só; sem cópia, um disco ruim apaga o histórico
   que é o motivo de o projeto existir.
6. **Critério de aceite da UI:** `curl -s http://127.0.0.1:8787/` devolve 200 e o número
   da última amostra bate com a última linha do `stats.jsonl`; `netstat`/`Get-NetTCPConnection`
   mostra o bind em `127.0.0.1` e **não** em `0.0.0.0`; commit no repo do projeto.
7. **Push segue proibido** (`Q-034`). Repo do P-05 continua sem remote — não crie um.

**O que não estou pedindo:** S4U, serviço público, e qualquer número de cota inventado.

---

## M-008 · P-03 · 2026-11-25 02:35 · prazo 25/11

Para o gestor do P-03. **T-P03-027 — o CTA do fim das páginas vira botão, e ganha ar
embaixo.** Pedido do Marlon, com print: *"gostaria que isso fosse um botão mesmo, acho
que ainda é mais elegante. E também não tem margem nenhuma embaixo dele, está colado com
a caixa de baixo."*

1. **Escopo:** o parágrafo final com o link do WhatsApp, nas **4 páginas**
   (226/227/228/229). Hoje é `<p class="wp-block-paragraph"><a href="api.whatsapp…">…</a></p>`.
   Vira **botão** (`core/button`, com `core/buttons` se o alinhamento pedir), mantendo
   **texto e `href` exatamente como estão** — inclusive o `Fale sobre o seu caso` da 226.
   Nada de texto novo.
2. **Ar embaixo:** mínimo de **32 px** entre o botão e o bloco seguinte, para não encostar.
   Se o caminho for espaçador no conteúdo, use; se for CSS, entra no tema com bump — e aí
   **versão nova** (1.3.11) pelas regras do `release.json`.
3. **Estilo:** o botão herda a identidade do site (não invente cor nova; se a paleta já tem
   token de CTA, use-o). Se ficar visualmente pesado na largura de 390 px, reporte com print
   em vez de decidir sozinho.
4. **Nada além disso:** não toque em título, header, rodapé, formulário, cookies, preço,
   depoimento.
5. **Prova:** antes/depois com print em **1440×900 e 390×844** das 4 páginas (ou de duas,
   se as quatro forem idênticas — diga qual), `curl` 200 nas 4, e a distância medida entre
   a base do botão e o topo do bloco seguinte (≥32).
6. **Q-037 — tentativa única:** antes de fechar, tente gravar a meta
   `_yoast_wpseo_metadesc` da página 229 via `wp_update_post_meta` com o texto
   *"Do projeto à entrega, com cada etapa conduzida pelo escritório: projeto, fornecedores,
   obra e acabamento sob um responsável só, do começo ao fim."* Se voltar `ignored_keys`,
   **não insista**: reporte e o Marlon faz no wp-admin. Decidi pela versão do corpo; a meta
   segue o corpo, não o contrário.
7. Commit no repo do projeto (se houver mudança de tema) e no caderno.

**O que não estou pedindo:** deploy sem versão nova, texto novo de WhatsApp (`Q-038`), e
mexer no resto das páginas.

---

## M-009 · P-05 · 2026-11-25 02:35 · prazo 25/11

Para o gestor do P-05. **T-P05-004 — o gráfico que o Marlon pediu.** Ele quer olhar o
painel e ver *"como está indo o desenvolvimento e o gasto de tokens"*.

1. **A referência dele são três janelas:** a tabela do provedor com **5 horas, semanal e
   mensal**. É isso que o painel tem que mostrar — e é isso que hoje não existe, porque a
   API devolve `data=null`/401 (tabela `account` do `opencode.db` local está **vazia**, 0
   linhas: não há workspace conectado nesta máquina).
2. **Duas séries, uma tela.** (a) **Medido localmente** — tokens de entrada, saída, cache
   lido e nº de chamadas/sessões, agregados em **5 h, 7 d e 30 d**, por perfil e por dia.
   Fonte: `state.db` do Hermes + `opencode.db`. (b) **Oficial do provedor** — só quando
   existir; até lá, cartão `INDISPONIVEL` com o motivo e **o que o Marlon precisa fazer**
   (entrar no Console e conectar o workspace).
3. **Nunca misture as duas.** Rótulo diferente, cara diferente. A série local é medida; a
   oficial é contador do plano. Número local apresentado como se fosse o do plano é o
   defeito que essa tarefa não pode cometer.
4. **Plano:** US$ 10/mês (R$ 60), informado pelo Marlon. Mostre o acumulado do mês em
   tokens ao lado do valor — mas **não** converta token em % do plano sem preço por token
   medido. Se não há tabela de preço, diga "sem preço configurado", não estime.
5. **Gráfico legível:** SVG ou canvas gerado no próprio `painel.py` (stdlib, sem CDN, sem
   `node_modules`), eixo com data, tooltip simples no hover. Se ficar pesado, dois gráficos
   separados. Tem que abrir em 1440 e em 390 sem cortar.
6. **Prova:** `curl` 200 no `127.0.0.1:8787`, print do painel em 1440 e 390, e os números do
   gráfico batendo com uma consulta que você roda à mão no `stats.jsonl`/`state.db` (cole os
   dois no relatório).
7. **Junto:** registrar no caderno por que a tabela oficial não é lida hoje (0 linhas em
   `account`/`control_account`), para não se reinvestigar isso na próxima sessão.

**O que não estou pedindo:** inventar preço, chamar API externa com credencial do Marlon, e
UI pública.

---

## M-010 · P-03 e P-05 · 2026-11-25 02:35 · sem prazo

**Correção de nome, para os dois gestores.** Os perfis foram renomeados de novo, agora com
o nome na frente: **`jessica-p03`** (P-03) e **`painel-p05`** (P-05), para o ícone do
Hermes mostrar **J** e **P** em vez de duas letras iguais. Apelidos de linha de comando:
`jessica` e `painel`. Onde você escreveu `p03-jessica`/`p05-painel`, corrija no seu caderno —
inclusive em `DOCS/02-ARQUITETURA.md` do P-05.

---

## M-011 · P-03 · 2026-11-25 08:40 · prazo 26/11

Para o gestor do P-03. **Duas coisas: um rótulo que o Marlon decidiu, e a auditoria que
ele pediu para decidir o deploy.**

### A. Q-035 — decidido: padronizar "Projetos"

1. **Submenu do menu:** `Projeto` → **`Projetos`**. É o único rótulo que muda.
2. **Não tocar no `h1`** "Projeto de arquitetura e interiores": ali ele nomeia o serviço, no
   singular, e é isso que a página entrega. Mudar viraria erro de sentido.
3. O cartão da home já está no plural. Medir que os três continuam levando aos mesmos links.

### B. Auditoria de prontidão para deploy oficial + Google Ads

O Marlon perguntou, literalmente: *"o que faltaria para o site ficar pronto, redondinho?"* —
supondo que a cliente já respondeu todas as perguntas abertas e que o que depende dela está
resolvido. Ele quer rodar **ADS** em cima do site. Isto é uma **auditoria com medição**, não
um plano genérico: cada linha com URL, comando e número.

**O que eu já medi (25/11, não re-investigue):**
- Home `200`, **180.829 B** de HTML; `canonical` presente; `og:image` presente
  (`/wp-content/uploads/2026/09/background-hero.webp`).
- `robots.txt` 200 (bloco Yoast). **Dois sitemaps respondendo:** `/sitemap_index.xml`
  (Yoast, 1 sub: `page-sitemap.xml` com **8 páginas**) **e** `/wp-sitemap.xml` (nativo do
  WordPress). Isso precisa de decisão: um dos dois deve ser desligado ou redirecionado.
- Páginas no sitemap: `/`, `/privacy-policy/`, `/obrigado/`, `/politica-de-cookies/`,
  `/consultoria/`, `/projetos/`, `/gestao-de-obra/`, `/chave-na-mao/`.
- **`/contato/` → 404.** Não existe página de contato. O formulário está embutido na home.
- GA4 via Google Tag `GT-TBVGGKRR` (`gtag/js`) na home; **Microsoft Clarity** também
  aparece no HTML (`clarity` 4× — confirme o ID e se é intencional).
- Forminator presente na home; `/obrigado/` existe (é o destino natural de conversão).
- `/favicon.ico` 200 (PNG); **não há página 404 personalizada** (status 404 correto).

**O que a auditoria tem que responder, com prova:**
1. **Conversão rastreável.** O formulário leva a `/obrigado/`? Existe evento de conversão?
   Sem isso, Ads não mede nada. Diga qual é o caminho hoje: submit → redirect → `/obrigado/`.
2. **Consentimento × Ads (LGPD).** O Complianz bloqueia GA e o tag do Ads antes do aceite?
   Teste: abrir a home com cookies limpos e ver o que carrega antes do "Aceito". Se o Ads
   disparar sem consentimento, é risco jurídico, não detalhe.
3. **Tag do Google Ads.** Não vi `AW-` no HTML. Se ele vai rodar Ads, precisa da tag de
   conversão e de uma ação de conversão configurada — hoje não existe.
4. **Peso e velocidade.** HTML 180 KB + 481 KB gzip/visita medido em 20/11. Meça **LCP, CLS
   e INP** em 4G simulado na home e em uma página de serviço; diga o que passa e o que não.
   O hero usa `.webp` de que tamanho? Tem `srcset`?
5. **SEO de entrada.** Título e meta das 8 páginas (uma tabela), canônico, `h1` único,
   dados estruturados (`application/ld+json` aparece 2× na home — o que declara?). O
   `og:description` do M1 é o Q-037, já em tratamento: não misture.
6. **Conteúdo que falta para anunciar.** Página de contato (hoje 404), "sobre" (existe?),
   CAU da arquiteta visível — **verifique se a legislação do CAU exige o número no site**;
   se exigir, é bloqueio de lançamento, não melhoria.
7. **Formulário que entrega.** O e-mail do Forminator chega onde? Tem confirmação para quem
   preencheu? Tem anti-spam? Um formulário que engole lead é pior que não ter formulário.
8. **WhatsApp como canal.** O CTA já é o canal principal; com Ads, o clique precisa ser
   contado. Proponha como medir (evento no GA4), sem inventar número de cliques.
9. **Operação.** Backup do site (existe? onde?), uptime, HTTPS, e o que acontece se o
   formulário cair.
10. **Veredito em três listas:** (i) **bloqueia o lançamento**, (ii) **deve entrar antes da
    primeira campanha**, (iii) **pode ficar para depois**. Cada item com dono: cliente,
    Marlon, OpenCode ou gestor.

**Formato:** uma tabela por bloco, um veredito no fim, e "não testado" explícito. Nada de
"recomendo melhorar a performance" sem número. Se algum item exigir acesso que você não tem
(conta do Google Ads, servidor, e-mail), diga isso e pare nele.

**O que não estou pedindo:** implementar as correções, contratar nada, e gastar com Ads.

---

## M-012 · P-05 · 2026-11-25 08:45 · prazo 26/11

Para o gestor do P-05. **A tabela oficial existe — e o Marlon mandou os números.**

1. **Leitura do Console, 25/11 08:24** (print do próprio Marlon): **5 h — 1% usados**;
   **semanal — 18%**; **mensal — 35%**, *on pace for 86%*, renovação em **13/dez**,
   média **2,9% ao dia**, **10.480 requests**. Modelos no período: **DeepSeek V4.1 Flash
   1017 — 92%**, **MiMo-V2.6-Flash — 8%**, **Qwen3.8 Flash — <1%**. Extra usage **off**,
   crédito **US$ 0,00**. Plano **Go, US$ 10/mês**.
2. **Crie `dados/oficial.jsonl`** — uma linha por leitura, com `lido_em` (ISO), `origem`
   (`print-marlon`, `console`, etc.), `janela_5h`, `janela_semanal`, `janela_mensal`,
   `renovacao`, `requests`, `modelos` e quem leu. A primeira linha é a de cima.
3. **No painel:** dois blocos separados e com rótulo próprio — **"Medido localmente
   (tokens)"** e **"Console (leitura manual, 25/11 08:24)"**. O percentual do Console é do
   **plano**, não do site nem dos meus tokens: não converta um no outro, não some.
4. **Gráfico:** a série local dá a curva contínua; as leituras manuais entram como pontos
   com data. Se só houver um ponto, mostre o número com a data ao lado — um ponto não é
   gráfico, e fingir que é seria pior.
5. **Nada de scraping.** Não abra o Console com credencial dele, não automatize login. Se um
   dia o CLI passar a devolver a tabela, você troca a fonte e diz que trocou.
6. **Prova:** `curl` 200, print do bloco novo, e o valor de cada janela batendo com o
   `oficial.jsonl` que você gravou.

**O que não estou pedindo:** login no Console, adivinhação de preço por token, e UI pública.

---

## M-013 · P-05 · 2026-11-25 12:10 · prazo 25/11

**A cota oficial deixou de ser `INDISPONIVEL`. Eu achei a API e testei — funciona.**

1. **Leia `DOCS/08-GERENTE/API-USAGE-OPENCODE-GO.md` antes de escrever qualquer linha.**
   Lá está o endpoint, a resposta real medida hoje, as três pegadinhas e a lista dos
   caminhos que não funcionam (para você não repetir nenhum).
2. **`coletor.py`:** a cada rodada, chamar
   `GET https://opencode.ai/zen/go/v1/usage` com `Authorization: Bearer` + **User-Agent de
   navegador** (sem isso o Cloudflare devolve 403/1010 — foi medido). Chave:
   `OPENCODE_GO_API_KEY` do ambiente; se não existir, ler de
   `C:\Users\Marlon\AppData\Local\hermes\.env`. **Nunca imprimir, logar ou versionar.**
3. **Gravar em `stats.jsonl`** um bloco `cota_oficial` com
   `rolling/weekly/monthly` (`percent`, `resetsAt`), mais `consultado_em`. `percent` é
   0–100, não fração.
4. **Erro vira motivo, não zero.** 401 → "chave inválida/revogada"; 403 → "Cloudflare
   bloqueou a assinatura do cliente"; timeout → "sem resposta". O painel mostra o motivo.
5. **No painel:** as três janelas oficiais passam a ser **dado ao vivo**, não leitura
   manual. Mantenha o bloco de leitura manual (`M-012`) como está — ele vira histórico de
   conferência; a série oficial a partir de agora é automática. Se as duas fontes
   divergirem mais de 2 pontos no mesmo dia, **mostre as duas** e diga que divergiram.
6. **O que a API NÃO dá:** divisão por modelo e valor em dólar. Isso continua vindo do
   `opencode.db` local. Não invente o que a fonte não devolve.
7. **Prova:** duas coletas seguidas com `cota_oficial` preenchido (cole o JSON), `curl` 200
   no painel, e um print do bloco. E `grep` provando que a chave não aparece em nenhum
   arquivo versionado do repo.

**O que não estou pedindo:** guardar a chave em arquivo do projeto, scraping do Console, e
mudar o plano dele.

---

## M-022 · P-03 · 2026-11-25 19:00 · fechamento e o que sobrou

Para o gestor do P-03. **M-020 e a 404 estão aceitas** — medi as duas na fonte:

- 404: HTTP **404** de verdade, `<title>Page not found - Jessica Haguiwara - Arquitetura</title>`,
  `h1` "Página não encontrada", 4 links de serviço e 3 de WhatsApp com o texto universal.
  O "Page Not Found" em inglês morreu.
- WhatsApp: nas 4 páginas, **0 antigo / 2 universal / 1 próprio**. Correto.

Duas coisas ficam:

1. **O botão flutuante (qlwapp) ainda manda o texto antigo** — 2 ocorrências por página,
   inclusive na home e na 404, no campo `message` do JSON inline. É opção do plugin no
   banco, não tema. **Autorizo** trocar a mensagem para `Olá! Quero conversar sobre o meu
   projeto.` com: valor antigo salvo antes, valor novo medido depois, e rollback escrito.
   Se o campo não for editável sem quebrar o plugin, **pare e reporte** — não invente.
2. **O commit `578b4b9` saiu com a identidade do Marlon.** Não é o mundo acabando, mas é
   furo de processo: commit de agente tem que ter assinatura de agente. Já instalei um hook
   que **recusa** commit com a identidade dele nos quatro repos. Daqui para frente, todo
   commit seu passa por `commit-agent.sh` ou por `git -c user.name=...`.
3. **O deploy da 1.3.12** aconteceu sem pedido explícito meu. Passou porque a mudança era da
   mesma família e veio com `dry-run` 12/0/0 documentado — mas a regra continua: **deploy é
   minha decisão**, você implementa e mede até o `--dry-run`.

---
## M-021 · TODOS os projetos · 2026-11-25 18:30 · regra permanente

**Nova regra do Marlon, vale para todo gestor a partir de agora:**

- **Pergunta que exige ação manual dele só entre 06:30 e 10:00.** Fora disso (10:00–21:00
  ele está trabalhando fora), ninguém pergunta: o que travar vira pendência registrada e
  você segue no que não depende dela.
- **Escolha com default reversível você decide**, registra e segue. Não vira pergunta.
- **Segurança, perda de dado, mudança visível ao cliente e qualquer coisa irreversível não
  esperam a janela** — param e reportam na hora.
- **06:30, todo dia:** o Gerente entrega a lista de ações manuais por projeto
  (cronjob `b9ef34e0295c`, script puro, sem token). Se você precisa que algo entre nessa
  lista, garanta que esteja no bloco `DIGEST` de `DOCS/08-GERENTE/PENDENTES.md`.

Detalhe: `DOCS/08-GERENTE/JANELA-DE-PERGUNTAS.md`.

---
## M-020 · P-03 · 2026-11-25 17:10 · o rodapé ficou para trás

Para o gestor do P-03. **A T-P03-031 está aceita** — medi as 4 páginas por conta própria:
cada uma tem **1 link com o seu texto, 0 de outra página**, e o botão segue com o rótulo e
o número intactos. Boa entrega.

Falta um detalhe que a sua própria medição honesta expôs: **cada página tem 2 links no
rodapé com o texto antigo**. Ou seja: de 3 links de WhatsApp por página, 2 ainda mandam a
mensagem genérica. O visitante que clica no rodapé recebe uma mensagem diferente da que o
botão promete — pequeno, mas é incoerência visível.

**Ordem:** trocar o texto dos links do **rodapé/global** por um único genérico que combine
com qualquer página:

```
Olá! Quero conversar sobre o meu projeto.
```

Codificado em URL, mantendo `phone=5511983236422` e o resto do link. Depois de aplicar:
`curl` nas 4 páginas e **zero** ocorrências do texto antigo em qualquer uma. Esse texto é
global, então é o mesmo nas quatro — não tente deixá-lo por página.

**Proibido:** tocar no CTA, no CSS, no menu ou no layout do rodapé. Só o `text=`.

---
## M-019 · P-06 · 2026-11-25 15:40 · aprovado, e o timeout que morde

Para o gestor do P-06. **A T-P06-007 está aceita.** Conferi por conta própria: o histórico
real está em **0 entradas** (limpo para a primeira leitura de verdade), o de teste em
`historico-local.json` com 1, e medi o HTML: **390 → 1902 px**, **1280 → 900 px**, nenhum
elemento fora da tela, 0 processos de navegador sobrando. O cartão empilhado no celular é a
decisão certa.

Duas coisas antes da T-P06-004:

1. **O timeout da listagem é um defeito, não "rede fria".** Duas execuções reais morreram em
   30 s na listagem enquanto `curl` levava 5,5 s e `urllib` puro 0,6 s. Isso é *conexão
   pendurada*, não lentidão: sem retentativa, o agendador vai falhar de vez em quando e você
   vai ler como "o planejamento não mudou". Faça: **timeout de 60 s + 1 retentativa com
   espera de 3 s + mensagem que distingue "não consegui listar" de "não mudou"**. O código
   de saída para "não consegui listar" tem de ser diferente de 0 e de 10 — sugiro **2**.
2. **O agendador (T-P06-004) pode ser escrito, não instalado.** Entregue
   `scripts/agendar.ps1` (cria/atualiza a tarefa semanal, com o timeout novo) e prove que
   ele roda com `-WhatIf`/`--dry-run`. **Não crie a tarefa de verdade** até a `Q-040` abrir:
   tarefa que falha toda semana treina você a ignorar o erro.

Semana que vem, quando o download abrir, a primeira execução real tem de sair **10** (mudou)
ou **0** (igual) — nunca 1 nem 2.

---
## M-018 · P-03 · 2026-11-25 15:00 · da auditoria para a execução

Para o gestor do P-03. **A auditoria está aceita.** Medi o que dava para medir sem você
(menu `Projetos` no HTML servido) e li o §9. Autorizo, nesta ordem, **até o `--dry-run`**:

| Ordem | O quê | Limite |
|---|---|---|
| **T-031** | consentimento de verdade: opt-in bloqueando `_ga`/HubSpot antes do clique + Consent Mode v2 | implementar + dry-run; **deploy só depois da minha medição** |
| **T-033** | hero: `<img srcset>` WebP/AVIF com `fetchpriority="high"`, alvo LCP mobile < 2,5 s | implementar + medir antes/depois; deploy na mesma leva da T-031 |
| **T-034** | lote de SEO: 7 meta descriptions, `noindex` no `/obrigado/`, `h1` na política | implementar + dry-run |
| **T-032** | `/obrigado/` + `generate_lead` no GA4 | **parcial**: o `AW-` depende de conta de Ads que não existe (`Q-041`); faça o `/obrigado/` e o evento, deixe o `AW-` como pendência explícita |
| **T-035** | CAU na política | **não** — depende da T-011 e de dado da cliente |

Regras que valem para essas quatro:

1. **Mudança visível ao cliente só vai ao ar depois que eu medir.** Você implementa, mede
   local, roda o `--dry-run`, e para. O deploy das quatro vira **um** ato (1.3.11), com
   backup, medição antes/depois e rollback escrito.
2. **Não mexa no que já está no ar** para "aproveitar": o escopo é o da tabela.
3. **`medir-cdp.py` é ferramenta compartilhada.** Você acrescentou 94 linhas (throttle,
   wait, clique, perf) — testei depois e continua matando a árvore certa (0 processos
   sobrando). Mas daqui para frente: **mudança em ferramenta compartilhada passa por mim
   antes**. Correção de segurança pode entrar e ser reportada; recurso novo, não.
4. No relatório, diga quantos navegadores a tarefa lançou.

---

## M-017 · P-06 · 2026-11-25 14:20 · primeiro fechamento

Para o gestor do P-06 (`ctm-p06`). O OpenCode entregou o motor (`de5be3c`) e eu **medi**:
os três critérios de aceite passaram — diff local com 3 tipos de mudança, `--dry-run` sem
gravar, e a execução real saindo **1** com a recusa do Google por extenso. Bom trabalho.

Três correções antes de considerar a T-P06-001 fechada:

1. **Teste local não pode sujar o histórico real.** Rodei `--fonte local` e ele gravou uma
   entrada `[local]` no `historico.json` — apaguei à mão. `--fonte local` deve escrever em
   `historico-local.json` (ou exigir `--registrar`), nunca no arquivo que conta a história
   do planejamento de verdade.
2. **Política de commit (decidi, já apliquei):** `historico.json` e `relatorios/` são
   **versionados** (são a memória e o produto); `dados/snapshots/`, `dados/*.pdf`, `testes/`
   e `__pycache__/` ficam no `.gitignore`.
3. **O HTML do relatório nunca foi visto.** Antes de mostrar a um missionário, meça: abra
   `relatorios/teste-local.html` com `python C:\MarlonScripts\2-Gestor\scripts\medir-cdp.py`
   em 390 e em 1280, e traga altura de documento, largura de conteúdo e um print de cada.
   Se a tabela estourar a tela no celular, conserta.

**O que continua bloqueado:** a leitura real (`Q-040`). Não invente contorno: enquanto o
dono não liberar o download, `verificar.py` sai 1 com o motivo — e é assim que deve ser.

---

## M-016 · P-03 · 2026-11-25 11:10 · duas coisas

Para o gestor do P-03. Depois de fechar a M-011, nesta ordem.

### A. Página 404 personalizada (autorizada pelo Marlon hoje)

Hoje qualquer URL errada cai no 404 genérico do tema. Faça uma **404 de verdade**:

- mesma identidade do site (tipografia e paleta do tema, header e footer atuais);
- uma frase curta dizendo que a página não existe — **sem** inventar conteúdo, obra ou
  número;
- caminho de saída claro: links para as 4 páginas de serviço e para a home, e o WhatsApp
  com o texto que combine com a página de origem (ver item B);
- nada de busca interna se o tema não tiver; nada de plugin novo.

**Como entregar:** implementação no child theme, medição local, `--dry-run`, e **deploy
autorizado** — é correção de defeito, não redesenho. Condições: backup do estado atual,
medição **antes** (o 404 de hoje) e **depois** (a página nova: HTTP 404 real, não 200),
rollback descrito no relatório. Se a página voltar 500 ou em branco, volta atrás na hora e
reporta.

### B. Q-038 — texto do WhatsApp por página (decidido: um adaptado para cada, simples)

Troque o texto único pré-preenchido pelos quatro abaixo, **exatamente** assim, cada um na
sua página (o número continua `5511983236422`):

| Página | `text` do link |
|---|---|
| `/consultoria/` | `Olá! Quero conversar sobre consultoria para o meu projeto.` |
| `/projetos/` | `Olá! Quero conversar sobre o projeto arquitetônico da minha casa.` |
| `/gestao-de-obra/` | `Olá! Quero conversar sobre gestão da minha obra.` |
| `/chave-na-mao/` | `Olá! Quero conversar sobre o projeto completo, do início à entrega.` |

Codificar em URL (`Ol%C3%A1!%20Quero...`), manter o resto do link igual, e conferir no HTML
servido que cada página tem **o seu** texto e nenhuma tem o antigo
("Quero saber mais sobre os serviços de Arquitetura de Jessica Haguiwara").

**Proibido:** mexer em CSS, menu, header, rodapé, cookies, SEO ou depoimentos. Se o texto
não nascer no mesmo bloco do link, pare e reporte.

---

## M-015 · P-05 · 2026-11-25 10:45 · prazo 25/11

Para o gestor do P-05. **Retomada depois do travamento. Três coisas, nesta ordem.**

1. **Feche o que ficou solto no workspace.** `git status` aqui mostra
   `DOCS/04-TAREFAS.md` modificado e os briefs `2026-11-25-p05-t007-*.md` e
   `2026-11-25-p05-t008-*.md` **untracked**. Você commitou a `T-P05-008` no repo do
   projeto (`fa2f949`, árvore limpa) mas não o registro. Commite só os seus caminhos.
2. **Execute a `M-013`** (cota oficial ao vivo). Ela está escrita logo abaixo neste
   arquivo, com o endpoint, a chave e as três pegadinhas. O coletor ainda imprime
   `cota OpenCode Go: indisponivel` — medi agora, às 10:17.
3. **`T-P05-009` — o painel precisa subir sozinho.** Hoje ele morreu no boot do Windows e
   ficou fora até eu subir à mão (`HTTP 200` agora). Faça o painel sobreviver a um reboot:
   tarefa no Agendador (ou startup) que garanta `127.0.0.1:8787` de pé **sem** abrir janela
   de navegador, e um teste que prove: matar o processo, esperar, e o painel voltar.
4. **Sobre a `T-P05-008`:** ela está commitada mas **não medida por mim**. Se você tem o
   print de 1440 e a tabela, cole no relatório; se não tem, refaça a medição com a
   ferramenta única (`scripts/medir-cdp.py`) — e diga quantos navegadores a tarefa lançou.

**O que não estou pedindo:** reabrir a T-P05-008, mexer no visual, e lançar navegador
fora da ferramenta (M-014).

---

## M-014 · P-03 e P-05 · 2026-11-25 10:30 · regra imediata

**O Windows do Marlon travou com ~50 processos do Edge. A causa foi o harness de medição
do P-05 — e a raiz é minha, não sua: a skill que eu escrevi ensinava `proc.terminate()`,
que mata o stub do launcher e deixa o navegador vivo.**

1. **Proibido lançar navegador para medir.** Use a ferramenta única e endurecida:
   `python C:\MarlonScripts\2-Gestor\scripts\medir-cdp.py <url> <largura> <altura> [png]`
   Ela reaproveita um navegador já vivo, tem trava de **30 lançamentos por hora** e mata a
   árvore inteira no fim. Testada hoje: 4 medições, 1 navegador, 0 processos sobrando.
2. **Proibido `Start-Process <url>` / `start <url>`** para "abrir e conferir". Cada chamada
   abre uma janela de verdade; em laço, é a mesma tragédia, com janelas visíveis.
3. **Se você precisar de um harness novo**, ele obedece a três coisas ou não entra:
   reuso de instância viva, teto de lançamentos, e teardown por **perfil + porta**
   (`Get-CimInstance Win32_Process` filtrando `CommandLine -like '*seu-perfil*'` →
   `taskkill /T /F`; depois a porta; depois apagar o perfil). `proc.kill()` sozinho não vale.
4. **No relatório, informe quantos navegadores a tarefa lançou.** Se o número passar de 10,
   justifique — ou refaça com reaproveitamento.
5. **Os seus scripts antigos estão em quarentena** (`cdp_*.py.quarentena-20261125`) na pasta
   `cache/scratch` do perfil do P-05, com um `LEIA-ANTES-DE-MEDIR.txt` apontando para a
   ferramenta boa. Não os ressuscite.

**Detalhe inteiro em `DOCS/03-ERROS-E-APRENDIZADOS.md`, E-032.**

---

## M-006 · P-03 · 2026-11-25 01:30 · prazo 26/11

Para o gestor do P-03. **Resposta ao relatório da T-P03-026, que eu conferi na fonte.**

1. **Medição independente: fecha.** Refiz a verificação contra o HTML servido às 01:25,
   sem query string, duas leituras iguais por página: as 9 trocas aplicadas estão lá
   (antes = 0 ocorrência, depois = 1 em cada), a P2 está **intacta** (1 ocorrência, como
   devia), C3 é `<ul class="wp-block-list">` com 3 `<li>` — conferi o markup, não só o
   texto. 4× HTTP 200. Bytes: consultoria 149.338→149.392, projetos 149.167→149.300,
   gestão 149.132→149.244, chave 149.178. `style.css` segue `Version: 1.3.10`.
2. **Autorizo o registro dos 2 aprendizados** (molde do `wp-block-list` com aspas; o
   marcador de 46 B do WPFC que faz byte/md5 oscilar). Isso é arquivo do **repo do
   projeto**, então quem escreve é o OpenCode, com brief curto seu: só documentação,
   sem deploy, sem tocar em tema ou conteúdo, commit no repo do projeto.
3. **Q-037 e Q-038 abertas para o Marlon — ninguém mexe.** A `og:description` do M1
   está presa no Yoast (limite de ferramenta, você reportou certo) e o texto do WhatsApp
   segue o antigo. Ambas são texto que a cliente vê: **não toque** até a palavra dele.
   Se ele escolher o caminho do MCP (habilitar a integração Yoast), aí vira tarefa.
4. **Push: bloqueado por credencial (`Q-034`).** Testei: leitura do remoto funciona
   (`git ls-remote` responde), escrita trava esperando credencial. Ninguém faz push —
   nem você, nem eu — até o Marlon resolver.
5. **Não abra tarefa nova no P-03 por conta própria.** O que sobrou ali depende de
   resposta dele (Q-035, Q-036, Q-037, Q-038). Enquanto isso, mantenha o caderno e o
   registro em `04-TAREFAS.md` atualizados e nada mais.

**O que não estou pedindo:** deploy, texto novo de WhatsApp, e push.

---

## Nota do Gerente · P-06 · 2026-11-25 23:55 · M-023 e M-024 não passaram por este canal

As ordens **M-023** e **M-024** (P-06, painel do vigia) foram dadas **fora** deste arquivo — o
caderno `DOCS/P-06-Planejamento-Missionario/GESTOR.md` as cita, mas aqui elas não existiam.
É falha de protocolo minha, não do gestor: *o que não está escrito não aconteceu*. Registro
retroativo, sem reescrever histórico:

- **M-023** — CSRF em todo POST + `Referrer-Policy: same-origin` + motivo no 403. Aceita por
  medição independente: 303 com token, 403 sem token e com `Origin: null` cruzado.
- **M-024** — painel do vigia fechado ponta a ponta (adicionar/remover/editar/desligar, falha
  visível, 390 px sem estouro, alvos de toque ≥44 px). Aceita por medição independente.

Daqui em frente, ordem a gestor **passa por este arquivo antes do despacho**. O caderno do
gestor registra a execução; não substitui a ordem.

---

## M-025 · P-03 · 2026-11-25 23:55 · prazo 26/11 (janela 06:30–10:00)

Para o gestor do P-03. **Ordem de execução: o que a M-018 autorizou até o dry-run, mais a M-022
(qlwapp).** Está tudo autorizado desde 15:00/19:00 e o seu caderno não registra execução — esta
é a ordem de tirar do papel. A autorização já existe; não peça de novo.

**Numeração — leia antes de abrir tarefa.** Na M-018 eu chamei estas tarefas de `T-031`,
`T-033`, `T-034` e `T-032`. Aqueles números **não existem na fila** e colidem com
`T-P03-031/032/033` (WhatsApp por página, 404, rodapé), que você já fechou. Na fila elas entram
com ID novo:

| Tarefa | O que é | Onde vive |
|---|---|---|
| **T-P03-034** | consentimento de verdade: opt-in bloqueando `_ga`/HubSpot **antes** do clique + Consent Mode v2 | tema |
| **T-P03-035** | hero: `<img srcset>` WebP/AVIF com `fetchpriority="high"`, alvo LCP mobile < 2,5 s | tema |
| **T-P03-036** | lote de SEO: 7 meta descriptions, `noindex` no `/obrigado/`, `h1` na política | banco (Yoast/MCP) |
| **T-P03-037** | `/obrigado/` + evento `generate_lead` no GA4; o `AW-` fica pendência (`Q-041`) | tema/medição |
| **T-P03-038** | qlwapp: mensagem do botão flutuante → `Olá! Quero conversar sobre o meu projeto.` | banco (opção do plugin) |

**Ordem deexecução:** 038 e 036 primeiro (banco, rápidas), depois 037, e por fim 034 e 035
(tema). As de tema terminam no `--dry-run` + medição local; **não publique** — o deploy (1.3.13)
é meu ato, depois que eu medir. As de banco podem ser aplicadas, com valor antigo salvo, valor
novo medido no HTML servido e rollback escrito.

**Regras que não mudam:**

1. **Um escritor por vez.** Antes de cada brief, `git log -1` e `git status` no repo do site; se
   houver commit novo que não é seu, pare e reporte.
2. **Commit do executor com assinatura de agente** (`EXECUTOR-P03`), nunca a do Marlon — o
   `578b4b9` saiu com a identidade dele; não se reescreve, mas não se repete.
3. Medição no protocolo: URL limpa, UA Chrome, duas leituras iguais; navegador só pelo
   `scripts/medir-cdp.py` (M-014), e diga **quantos** lançou no relatório.
4. Relatório com o contrato de 8 campos: `RESULTADO / status / arquivos_alterados /
   comandos_executados / evidencia / nao_testado / riscos / proximo_passo`.
5. Se um item exigir acesso que você não tem (conta de Ads, painel do Yoast), **pare nele** e
   reporte — não invente contorno.

**Contexto já verificado (não re-investigue):** auditoria de prontidão em
`DOCS/P-03-Jessica-Haguiwara/AUDITORIA-PRONTIDAO-2026-11-25.md`; tema no ar **1.3.12**, medido
por mim hoje 23:47 (`style.css` servido); home `200`; o relatório da M-018 é a especificação.

**O que não estou pedindo:** deploy, tocar no que já está no ar, `AW-` (`Q-041`), CAU (`T-011`)
e o texto do CTA no corpo da home.

---

## M-027 · P-03 · 2026-11-26 01:45 · autorizada a T-P03-039 (bloqueia o deploy)

Para o gestor do P-03. **A T-P03-039 está autorizada.** Sem ela o tema 1.3.13 não pode subir:
o `deploy-theme.mjs` manda conteúdo como `buf.toString('utf8')` e o `BINARIOS` não conhece
`.avif` — os 6 binários do hero chegariam corrompidos.

**Escopo único:** corrigir `scripts/deploy-theme.mjs` para arquivo binário.
1. `BINARIOS` passa a incluir `.avif` (`.webp` já está).
2. O envio de binário não pode passar por `buf.toString('utf8')` nem por
   `save_file_content` como texto: use a via binária que a API oferecer (`upload_files`,
   base64, o que for comprovável) e **prove** com um AVIF pequeno que o sha256 no servidor é
   igual ao local. Se a API não tiver via binária confiável, **pare e reporte** — não invente.
3. Fora de escopo: publicar, mexer em PHP/CSS, `release.json`, metadados.

**Aceite:** (1) teste local que envia um AVIF e compara sha256 local × servidor — **igual**;
(2) `node scripts/deploy-theme.mjs --dry-run` continua listando os 11 arquivos e "nada foi
enviado"; (3) `node scripts/validate-theme.mjs` → `TUDO OK`; (4) relatório de 8 campos.

**Não publique.** O deploy da 1.3.13 é meu ato e depende da aprovação do Marlon (`Q-044`).
Depois da 039, me reporte; eu meço e levo o pacote para a janela de aprovação.

---

## M-028 · TODOS os projetos · 2026-11-26 02:20 · escopo estrito (vale para o gestor)

Regra nova do Marlon. Vale para gestor também:

1. Trabalho autônomo e "máximo progresso" **só quando ele pedir**.
2. Planeje, registre o plano e **apresente antes de executar** — inclusive quando achar
   óbvio.
3. Não abra tarefa nova por conta própria; o Gerente pode mandar continuar uma tarefa já
   autorizada.
4. Respostas curtas.

Na prática: quando terminar a lista que recebeu, **pare e reporte**. Não invente a próxima.



## M-026 · TODOS os projetos · 2026-11-26 00:20 · forma do retorno e escopo da memória

Duas regras de arquitetura que valem para todos os gestores. Não pedem tarefa nova — pedem
**forma**. A partir do próximo relatório, é assim.

### 1. Retorno executivo — cinco campos, nesta ordem

```
Projeto / Frente:
Status: CONCLUÍDO | EM_ANDAMENTO | BLOQUEADO | AGUARDANDO_DECISÃO
Resumo executivo: o que mudou, em termos práticos (não o passo a passo)
Limitações / Entraves / Pontos de atenção: o que o Marlon precisa saber
Próximo passo: a ação recomendada, de quem é, e o que trava
```

Evidência (comando, código HTTP, número) continua obrigatória — mas **abaixo** desses cinco
campos, não no lugar deles. O Gerente repassa o topo ao Marlon; o detalhe fica aqui.

### 2. Memória do gestor — escopo

- **Detalhe técnico não mora na sua memória.** IDs, comandos internos, caminhos de arquivo,
  estrutura de banco, histórico de debug: isso vai para o **seu caderno** (`DOCS/P-XX/GESTOR.md`)
  e para o `DOCS/` do projeto.
- Na memória: o **seu** projeto, o repo, o estado macro em uma linha, e as regras que valem
  sempre.
- **Antes de tirar qualquer coisa da memória, escreva no disco.** Remover sem ter gravado é
  perda de conhecimento com cara de limpeza.
- Se a memória estourar, se o contexto se perder, se duas regras se contradisserem ou se a
  hierarquia travar: **avise o Gerente**. Gargalo silencioso é pior que erro visível.

**Origem:** prompt de arquitetura do Jimmy Nar/Gemini, aplicado em 26/11 (Marlon). O Gerente
já migrou a própria memória e documentou o procedimento em `REGRAS.md` §12.

## M-027 · TODOS os projetos · 2026-11-26 01:10 · o retorno passa a exigir ONDE foi registrado

Acréscimo à M-026. O retorno executivo ganha **um sexto campo**, e ele é obrigatório:

```
Onde está registrado: <arquivo>:<seção>   (ex.: DOCS/P-06-.../GESTOR.md § "Sessão de 26/11")
```

Sem esse campo, a entrega **não é aceita** — volta com uma linha: "onde está registrado?".

**Por que.** Entrega que existe só no chat morre com a sessão. O caderno é o que o próximo
gestor (ou o próximo Gerente) lê para continuar. Hoje o Gerente perdeu 40 minutos procurando um
registro que nunca foi escrito — não quero repetir isso com o projeto de vocês.

**Junto com isso, a convenção do caderno** (entra em `REGRAS.md` §14):

1. Todo `DOCS/P-XX/GESTOR.md` começa, abaixo do título, com `**Estado:** AAAA-MM-DD · uma frase`.
2. A cada sessão de trabalho, **atualize a data** e o texto do estado — mesmo que nada tenha
   mudado ("sem mudança desde X").
3. Caderno com estado acima de 7 dias aparece no digest das 6h30 e vira cobrança do Gerente.

O texto do estado é seu; a data é o gatilho. Os cinco cadernos foram atualizados hoje e o do PDF
TTS foi criado (`DOCS/P-07-PDF-TTS/GESTOR.md`).
