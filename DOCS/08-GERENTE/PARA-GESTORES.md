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


