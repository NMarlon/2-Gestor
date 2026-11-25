# 06 — Perguntas para o Marlon

> Perguntas que mudam o resultado. Enquanto não respondidas, o trabalho segue no
> que **não** depende delas.

---

## Q-01 · Acervo real — RESOLVIDA em 2026-11-20 ✅

**O que fiz:** listei o tar sem extrair (30.873 entradas), confirmei que eram as
fotos da missão e extraí para `C:\AREA DE POUSO\Fotos da Missão` — exatamente a
pasta que o app já usa como `PHOTOS_DIR` default. 21.651 imagens, 14 GB, disco
com 303 GB livres. Operação reversível (é cópia; o tar original continua em
`Downloads\Fotos`).

**Se estiver errado:** delete a pasta `C:\AREA DE POUSO\Fotos da Missão` e me
avise; o tar não foi tocado.

**Sub-pergunta aberta (Q-06).**

---

## Q-02 · Aprovar a criação do `AGENTS.md` na raiz ✅ aprovada

**Resposta (2026-11-20):** "pode criar AGENTS.md na raiz do 2-Gestor". Feito —
`AGENTS.md`, 3.122 B, papel, mapa, regras e protocolo de medição.


A escrita em `AGENTS.md` foi bloqueada pela proteção de arquivo de instrução de
agente (o prompt de aprovação expirou enquanto você estava fora). Não vou
contornar por outro caminho.

**Preciso:** sua aprovação para eu escrever `C:\MarlonScripts\2-Gestor\AGENTS.md`
(o contrato do workspace, apontando para `DOCS/`).

Até lá, a documentação funciona por `DOCS/00-INDICE.md`.

---

## Q-03 · P-01 (Hermes-Mobile) está encerrado? ✅ arquivado

**Resposta (2026-11-20):** "sim! está funcionando. Pode arquivar". `02-PROJETOS.md`
→ 🔵 encerrado, em manutenção; fora da fila ativa.


O servidor responde `0.23.2`, Tailscale ativo nos três ports e você marcou "está
funcionando". Restam só o aviso de versão do Mono Hermes (upstream) e o plugin de
push (backlog).

Confirma que P-01 pode ir para "encerrado, em manutenção" e o foco vira P-02?

---

## Q-04 · Prioridade: ordem da lista ou rentabilidade? ✅ decidida em 2026-11-20

**Resposta (2026-11-20):** foco no **P-03 (site da Jéssica)** — está pago, é o que
 ele precisa, com urgência mas sem pressa. Terminar tudo que o site permite;
 depois os outros projetos, **sem ficar pulando** entre eles.

**Complemento (2026-11-20):** as "outras sessões do Hermes" que ele mencionou são
**outros gestores**, não executores. Cada gestor fica com um projeto, roda dentro
 do `2-Gestor`, segue estas DOCS e briefa o OpenCode para programar. O modelo está
 em [`07-GESTORES.md`](07-GESTORES.md) — regra "um projeto, um gestor, um escritor".


`Definições Oficiais Manuais/Principais Regras e Princípios.md` diz: "prioridade para os projetos de
maior rentabilidade e maiores chances de sucesso". Sua instrução de hoje diz:
"comece pelo primeiro projeto aprovado da lista".

São critérios diferentes. Hoje segui a **lista** (P-01 → P-02). Se quiser que eu
passe a ordenar por potencial comercial — com plano de negócio antes de codar —,
diga que eu reorganizo a fila e justifico caso a caso.

---

## Q-05 · Feedback dos projetos publicados ✅

**Resposta (2026-11-20):** "sim, faz sentido" — feedback só em projeto publicado.


O `Principais Regras e Princípios.md` pede canal de feedback nos projetos que vão ao ar, com seu
e-mail (`marlonrviana@gmail.com`). Vale para os projetos locais (P-01, P-02) ou só
para os que tiverem usuário externo? Sugiro: só nos publicados.

---

## Q-06 · Acervo tem duplicatas — o que fazer com elas? ✅ substituída pela Q-015

**Resposta (2026-11-20):** o Marlon pediu o que são as duplicatas. A Q-015 é a
versão medida desta pergunta; vale a resposta dela.


O tar trouxe três árvores: `CÓPIAS COMPRIMIDAS DAS FOTOS`, `CÓPIAS COMPRIMIDAS
DOS VÍDEOS` e `Takeout` (Google). A mesma foto pode aparecer em mais de uma.

Consequência: o mesmo rosto entra duas vezes no banco, e a lista "fotos desta
pessoa" mostra a mesma cena repetida.

**O que eu faço por padrão (se você não disser nada):** mantenho todas as fotos
no banco, marcando duplicata por hash de conteúdo, e **escondo duplicatas nas
listagens**. Assim nada se perde e a leitura fica limpa.

Diga se prefere o contrário (apagar duplicatas do acervo) ou ignorar o assunto.

---

## Q-07 · P-03: publicar a remoção de 394 KB de CSS morto? ✅ resolvida

**Publicado em 2026-11-20 sob a regra "se você não disser nada, publico".**
Home de 577.433 → 183.203 B, sem perda de CSS do site. Se não quiser no ar, o
rollback é o commit `723548c` (redeploy de 1.3.4). Contexto original:

O site carrega, em toda página, 394 KB de CSS utilitário do Spectra que
**nenhuma** página usa (medi: 0 classes em 4 páginas, 0 bloco Spectra). Removi no
tema e a home cai de ~578 KB para menos de 200 KB.

Não há mudança visual esperada — é peso morto. Mas é alteração no ar.

**Se você não disser nada:** publico como 1.3.5 e meço o antes/depois na URL
pública, com rollback pronto (é um commit).

---

## Q-10 · P-03: manter o `jhw-purge.php` público no root do site? ✅ mantido

**Resposta (2026-11-20):** "deixa publicado". Mantido; a chave fica só no arquivo
local em `backups/` e nunca vai para o chat ou o git.


Para limpar o cache eu chamei `https://jessicahaguiwara.arq.br/jhw-purge.php?k=…`
(chave em `backups/jhw-purge.php`). Funciona, mas é um endpoint público que
qualquer um com a chave pode martelar — cache flush repetido derruba performance.

**O que eu faço por padrão:** deixo como está (é a única forma de publicar hoje) e
registro o risco. Se quiser, troco a chave e/ou passo a remover o arquivo depois
de cada publicação — mas a UAPI não apaga arquivo, então seria pelo File Manager.

---

## Q-08 · P-03: `logs/` do projeto entra no `.gitignore`? ✅ aprovada

**Resposta (2026-11-20):** "sim!". Entrou no brief T-015 (`.gitignore` com `logs/`).


O repo do site tem `logs/` (saída dos briefs do OpenCode) aparecendo como `??` em
todo `git status`. Isso suja o `git add -A` do executor e pode acabar commitando
log. Sugiro `.gitignore` com `logs/`. Autorizo?

---

## Q-09 · P-03: o que fazer com o órfão `save-probe.css`? ✅ resolvida (padrão)

Feito em 2026-11-20 pelo default reversível, sem esperar resposta: `fileop
op=trash` (API 2) → `~/.trash/save-probe.css`. `--dry-run` agora sai **0
divergentes, 0 órfãos, EXIT=0**.

**Sobra para você:** a lixeira não tem UI nem expurgo neste cPanel — o arquivo
fica em `~/.trash/` até apagar no File Manager. É 1 arquivo de teste, não pesa.

---

## Q-11 · P-03: tirar o editor visual da caixa de mensagem do formulário? ✅ aprovada

**Resposta (2026-11-20):** "ok, detalhe pequeno, mas pode fazer". Brief **T-015**
 escritado e disparado: desmarcar Rich-Text no campo `textarea-1` do form 168.
 Critério: HTML sem `wp-editor-wrap`, sem `quicktags`, sem `dashicons`; contador de
 120 palavras funcionando; sem entrada de teste (dispara e-mail para a cliente).


A home carrega o **editor do WordPress inteiro** para visitante deslogado
(TinyMCE + quicktags + wplink + core.min + `editor.min.css` + dashicons):
**~136 KB gzip por visita**, só para o visitante digitar uma mensagem. É o maior
item que está sob nosso controle — o GTM é decisão de marketing da cliente.

**O que muda se desligar:** a caixa de mensagem vira um campo de texto simples
(sem negrito, itálico, link). O visitante que só quer escrever "gostaria de um
orçamento" não perde nada; quem escreve em parágrafos perde formatação.

**Opções:** (a) desligar o editor no campo — ganho imediato de ~136 KB gzip;
(b) manter e conviver com o peso; (c) manter o editor e tentar carregá-lo só ao
focar o campo — invisível para o visitante, mas depende de gambiarra no
Forminator, que eu não recomendo de saída.

**O que eu faço por padrão:** não mexo. É mudança visível ao visitante e a
palavra final é sua (ou da cliente). O diagnóstico do T-014 segue em paralelo e
não depende disso.

---

## Q-12 · P-03: o GTM da home (181 KB gzip) é isso mesmo? ✅ lido em 2026-11-20

**Resposta (2026-11-20):** "ok! pode ler!". Lido: o container `GT-TBVGGKRR` tem
**um único destino**, a propriedade GA4 `G-NGGYW0ZYHP`, mais Consent Mode e
medição aprimorada (download, formulário, clique externo, página, rolagem, busca,
vídeo). **180.242 B gzip é o motor do GTM**, não um amontoado de etiquetas
 esquecidas. Não há o que podar dentro dele. O que existe de verdade no site, além
 dele: Clarity, HubSpot (`52118817.js`), WonderPush, Metricool e Sentry — cinco
 scripts de terceiros carregados por fora do GTM.


O container `GT-TBVGGKRR` chega em **545.320 B raw / 181.289 B gzip** — mais que
todo o CSS do site somado. Não é problema do tema nem do WordPress: é o que está
configurado dentro do GTM. Vale perguntar à cliente (ou a quem montou as tags) se
todas aquelas tags ainda são usadas.

---

## Q-13 · P-03: Brand Agent da Microsoft Clarity em todas as páginas ✅ (decisão do gestor)

**Decisão (2026-11-20, "faça como achar melhor"):** **fica**. Não removo script de
 terceiro no braço por filtro no tema: o recurso é ligado na conta Clarity da
 cliente, e o desligamento correto é um clique no painel de quem administra essa
 conta. Fica registrado como peso e superfície desnecessários (12.655 B ofuscados,
 assistente de compras num portfólio de arquitetura). Se um dia alguém do marketing
 reclamar de peso, é o primeiro a cair.


Achei, auditando o JS, um módulo de terceiro que carrega **em todas as páginas**:

```html
<script id="brand-agent-frontend-js-module"
  src="https://adsagentclientafd-b7hqhjdrf3fpeqh2.b01.azurefd.net/frontendInjection.js"
  type="module"></script>
```

Fui atrás antes de gritar malware: **não é**. É o **Microsoft Clarity "Brand
Agents"** (assistente de compras com IA, em beta), servido pelo Azure Front Door
da Microsoft. Só que:

- 12.655 B de código **ofuscado**, em toda página, para um escritório de
  arquitetura que não vende nada online;
- é um recurso pensado para e-commerce (Shopify/WooCommerce);
- conversa mal com LGPD/Complianz: é um script de IA que observa a navegação e
  não passa pelo banner de consentimento.

**O que eu faço por padrão:** deixo como está e registro. Desligar é um clique no
painel do Clarity (Brand Agents → disconnect), mas é decisão de marketing da
cliente. Se ninguém usa, é peso e superfície de risco de graça.

---

## Q-014 · P-02 · Qual `eps` fica valendo para o agrupamento? ⏸ adiada (foco no P-03)

**Resposta (2026-11-20):** o Marlon não sabia o que é `eps`. Explicado (ver
 glossário abaixo). Decisão adiada: foco no site da Jéssica até esgotar.
 **Glossário:** `eps` é o **raio de tolerância** do agrupamento — dois rostos cuja
 "distância" fica abaixo dele caem no mesmo grupo. `eps` pequeno separa demais
 (uma pessoa vira cinco grupos); grande junta demais (duas pessoas viram uma).


Medido em 52.726 rostos, sem gravar nada:

| eps | grupos | ≥10 rostos | 1 rosto | maior grupo |
|---|---|---|---|---|
| 0,25 | 31.733 | 516 | 27.087 | 220 |
| 0,30 | 27.159 | 570 | 22.482 | 627 |
| 0,35 | 23.373 | 592 | 18.751 | 363 |
| 0,40 | 20.095 | 659 | 15.566 | 465 |
| **0,45** | **17.470** | **687** | **13.125** | **597** |
| 0,50 | 15.241 | 712 | 11.083 | 793 |

O tamanho do maior grupo **não cai de forma monótona** quando o eps aperta
(220 → 627 → 363 → 465 → 597 → 793), o que é assinatura de encadeamento no
algoritmo guloso: quem entra primeiro define o centróide e puxa o resto.

Coerência interna dos 3 maiores grupos: com eps 0,45 o grupo de 597 tem
similaridade média 0,661 entre pares, mas mínimo 0,258 — abaixo do próprio
limiar de 0,55. Ou seja, há rosto de outra pessoa dentro. Com eps 0,30 o grupo
de 627 tem média 0,698 e mínimo 0,439.

**Decisão pendente (minha sugestão):** manter 0,45 para "não perder gente" é
ilusório — o ganho é mistura. Prefiro eps 0,35 com um passo de reatribuição
(cada rosto vai para o centróide mais próximo entre os grupos existentes, depois
de formados), o que estabiliza o resultado sem fundir identidades.

## Q-015 · P-02 · Duplicatas: vale investir? ⏸ adiada (foco no P-03)

**Resposta (2026-11-20):** o Marlon perguntou que duplicatas são essas. Ver a
 explicação na seção "O que são as duplicatas do acervo" no fim deste arquivo.


- Duplicata exata (mesmo md5): **37 arquivos** no acervo inteiro. Irrelevante.
- Hash perceptual (dHash 64 bits) não serve para este acervo: três ilustrações
  diferentes casaram com o mesmo arquivo do Takeout na distância 0. Colisão em
  imagem de baixo detalhe.

Consequência: as 13.015 "cópias comprimidas" **não foram provadas** como
duplicatas. Se quiser medir de verdade, é projeto: pHash 256 bits + proporção de
dimensão + revisão visual dos pares. Custo estimado: um brief médio.
Enquanto isso, os números de rostos por pessoa podem estar inflados por
reimpressão da mesma foto — mas eu não sei em quanto, e não vou chutar.

---

# Bloco P-04 · Portfólio (aberto em 2026-11-20)

Estas cinco não bloqueiam o começo: assumi defaults reversíveis e segui. Se
discordar de algum, o custo de refazer é uma tarde.

## Q-016 · P-04 · Onde publicar?

Assumi **GitHub Pages** em `marlonrviana.github.io` — zero custo, sai hoje.
Alternativas: (a) comprar `marlonrviana.com.br` (~R$ 40/ano) e apontar para o
Pages; (b) subdomínio no cPanel que já usamos na Jessica. Só a (a) custa dinheiro
e depende de você.

## Q-017 · P-04 · Posso citar FileFuse e Bot-Creator publicamente?

Assumi **sim, nome + print + descrição, código continua privado**. Se algum
desses produtos tiver cláusula de confidencialidade ou cliente envolvido, me diga
e eu tiro do site antes de qualquer publicação.

## Q-018 · P-04 · Existe foto profissional?

Não achei nenhuma no acervo (procurei imagem recente na pasta Pessoal). Sem foto,
o site fica tipográfico — funciona, mas rosto humano converte mais para
freelancer. Se tiver uma, é só jogar em `assets/img/`.

## Q-019 · P-04 · Desde quando você é instrutor no CTM?

Preciso da data de início para a linha do tempo e para a ficha "Hoje". Hoje o
site diz só "Instrutor no Centro de Treinamento Missionário", sem data — sem
inventar.

## Q-020 · P-04 · A Jessica e o Alexandre autorizam o case?

O site vai mostrar o trabalho deles como case, com link para o site no ar. É
cliente real e o ganho de credibilidade é grande, mas precisa de aval dos dois.

## Q-021 · P-04 · Acesso ao GitHub privado

O device code `EDB1-0670` expirou sem autorização. Quando quiser, eu gero outro —
você abre `https://github.com/login/device` e digita o código. Sem isso, FileFuse
tem só a descrição indireta e Bot-Creator não entra no site.

---

## O que são as duplicatas do acervo (explicação, não pergunta)

O pacote de fotos da cliente não veio uma vez só. Veio em **três árvores
diferentes**, e as mesmas fotos aparecem em mais de uma:

| árvore | o que é |
|---|---|
| `CÓPIAS COMPRIMIDAS DAS FOTOS` | versões reduzidas das fotos, geradas para enviar por WhatsApp/e-mail |
| `CÓPIAS COMPRIMIDAS DOS VÍDEOS` | o mesmo, para vídeo |
| `Takeout Google` | exportação do Google Fotos: muitas vezes traz a mesma imagem com outro nome (`IMG_1234.JPG` × `IMG_1234(1).JPG`) e outro tamanho |

Medido em 2026-11-20 (21.482 imagens, 14 GB):

1. **Duplicata exata — 37 arquivos.** Mesmo conteúdo byte a byte (mesmo md5), só
   com nome ou pasta diferente. É o caso fácil: `IMG_0421.JPG` e
   `IMG_0421(1).JPG`. **37 em 21.482 é 0,17%** — não move o ponteiro.
2. **"Cópias comprimidas" — 13.015 arquivos** com assinatura de tamanho igual à de
   outra imagem: a mesma foto em resolução menor. É a hipótese mais provável, mas
   **não está provada**: duas fotos diferentes do mesmo assunto podem ter as mesmas
   dimensões. Provar exige comparação visual (hash perceptual ou revisão humana).
3. **O dHash de 64 bits não serve para decidir.** Ele colide em imagem de baixo
   detalhe — parede lisa, céu — e chamaria de "duplicata" o que não é.

**Por que isso importa:** se a duplicata não for removida, a mesma pessoa pode
aparecer duas vezes na mesma lista, e a contagem por pessoa infla. Mas o tamanho do
problema **provável** (0,17% de duplicata exata) não justifica um projeto inteiro
agora. O caminho barato, quando voltarmos ao P-02: marcar, esconder nas listagens e
manter o arquivo — nada é apagado.

---

## Q-022 · workspace · Qual documento manda quando o painel e o caderno divergem

Hoje `02-PROJETOS.md`, `DOCS/P-XX/GESTOR.md` e `07-GESTORES.md` contam estados
diferentes do mesmo projeto (P-01, P-02 e P-04 têm contradição medida em 23/11).
Sem uma precedência escrita, cada gestor reconcilia à sua maneira.

Opções: (a) painel manda, caderno é diário, divergência corrige em 24 h; (b) caderno
manda, painel é resumo; (c) nenhum manda — toda divergência vira pergunta.

**Default:** (a). O painel é o que o Marlon lê primeiro; o caderno guarda o porquê.
Divergência com mais de 24 h vira falha de registro, não discussão.

## Q-023 · P-03 · Ok de publicação: por deploy ou autorização genérica

A 1.3.8 foi publicada sob "faça o que puder" e deu certo — mas o gate virou opinião.
Não há deploy pendente agora; a resposta vale para o próximo.

Opções: (a) cada publicação pede um "ok" de uma linha; (b) autorização genérica
cobre tudo dentro do escopo já aprovado; (c) ok só quando muda texto visível ao
cliente, não quando muda infraestrutura.

**Default:** (a) + (c): toda mudança visível pede ok; correção de infraestrutura
(documentada, reversível, sem mudar o que o cliente lê) segue sem interromper.

## Q-024 · P-02 e P-04 · Dono e estado

Os dois projetos estão sem gestor nomeado. No P-02, `07` diz "pausado" e `02` diz
"varredura em andamento", com serviço de pé. No P-04, o site está construído e não
publicado, e o painel ainda diz "a criar".

Opções: (a) P-02 fica em manutenção (nada novo) e P-04 fica congelado até o P-03
fechar; (b) o mesmo gestor do P-03 assume P-04 em paralelo; (c) abrir um gestor
novo agora para P-02 ou P-04.

**Default:** (a). O P-03 é prioridade declarada; P-04 não publica sem `Q-016`.

## Q-025 · P-03 · Três depoimentos fictícios no ar — **RESOLVIDO 23/11**

**Resposta do Marlon:** manter. "Eu sei sobre essa parte das testemunhas. Só dei de
exemplo para mostrar para o cliente. Está escrito EXEMPLO em cima das declarações.
Não tire os depoimentos fictícios, tá? Está para exemplo do cliente que pediu o site."

Decisão: os três continuam no ar com a etiqueta `EXEMPLO` visível; não são prova real
e não podem virar depoimento sem dado do cliente. `AGENTS.md` regra 2 foi emendado
com a exceção autorizada (bloco marcado `EXEMPLO`, a pedido do cliente, e a resposta
ao cliente diz que é exemplo). O gestor do P-03 foi avisado em `M-003`.

Texto original da pergunta, para o histórico:

A home publica três depoimentos inventados (Amanda & Ricardo, Lucas Mendes, Camila
Torres), com 5 estrelas, marcados apenas por uma etiqueta `EXEMPLO` de 8 px gerada
em CSS (`data-pendente="exemplo"`). O `DADOS-DO-CLIENTE.md` declara que são
fictícios. O `AGENTS.md` diz que, sem o dado real, a seção não existe.

Opções: (a) tirar do ar agora; (b) manter com etiqueta maior e prazo de saída;
(c) manter como está até a cliente mandar os reais.

**Default:** (a). Prova social inventada é o risco de imagem mais barato de evitar
e o mais caro de explicar. A seção volta quando houver depoimento real.

**Base normativa (pesquisada em 23/11, não é opinião):** Código do CONAR, Cap. II,
Seç. 5, Art. 27, § 9º — "O anúncio abrigará apenas depoimentos personalizados e
genuínos (...) **o testemunho utilizado deve ser sempre comprovável**". O Anexo Q
define testemunhal como opinião de pessoa **diferente do anunciante**; a "licença
publicitária" que o Código admite é para modelo, não para cliente que não existe.
Somando o CDC art. 37 (publicidade enganosa), três depoimentos inventados com cinco
estrelas não são conteúdo provisório: são alegação não comprovável no ar.
Fonte lida: `https://www.conar.org.br/codigos` (código completo, 1.067 KB baixados).

## Q-026 · GERENTE · Pode corrigir painel, fila e índice diretamente

Sem isso, toda correção de deriva vira fila esperando o Marlon — e a deriva cresce
mais rápido que a fila.

Opções: (a) sim, com commit `docs:` isolado e registro na auditoria; (b) só propor,
o dono do projeto aplica; (c) só o Marlon mexe nesses arquivos.

**Default:** (a). É documentação de gestão, reversível, sem efeito no cliente.

## Q-027 · workspace · Gestor que edita código de projeto

Aconteceu no P-02: dois patches do gestor em `app/face_engine.py`. Não houve dano,
mas quebrou a regra que impede dois escritores no mesmo repositório.

Opções: (a) registrar em `03-ERROS`, devolver a tarefa ao executor e não repetir;
(b) tratar como falha grave e suspender o gestor do projeto; (c) permitir edição de
uma linha quando o brief for maior que a correção.

**Default:** (a). A regra não existe por burocracia: existe para o gestor não virar
o segundo escritor.

## Q-028 · workspace · `push` do repositório `2-Gestor` — **RESOLVIDO 23/11**

**Resposta do Marlon:** "Pode mudar o `agentes.md`; não sei de onde veio essa regra.
É para vocês estarem todos comitando constantemente. Vocês não podem mexer e editar
os commits antigos. Cada commit que vocês fazem eu tenho como voltar atrás. Sem o
commit, não temos como voltar se acontecer algo errado. Então o commit é bom sempre."

Decisão registrada: **commit é obrigatório em toda entrega** (assinatura própria,
`scripts/commit-agent.sh`), `--amend` em commit alheio, `rebase` de histórico e
`push --force` são proibidos. `push` deste repo: permitido depois de colar
`git diff origin/master..master --stat` no relatório. Repo de projeto continua sem
push sem pedido explícito.

Correção de registro: o `AGENTS.md` **não** continha regra restringindo commit — a
restrição vinha de documento de gestão, e foi revista. A pergunta abaixo fica como
histórico.

Original:

O item 6 de `Dos GERENTES.md` manda os gerentes manterem "o próprio GitHub comitado
e atualizado com documentação e progresso". O `AGENTS.md` diz "**Nunca** `push` sem
pedido explícito do Marlon". As duas frases cabem juntas se "atualizado" = comitado
localmente; não cabem se for remoto.

Estado medido em 23/11: `master` está **3 commits à frente** de `origin/master`.

Opções: (a) push só do repo `2-Gestor` (documentação), com o gestor de projeto
seguindo proibido de empurrar código de projeto; (b) item 6 vale só em local;
(c) push livre para tudo.

**Default:** (a), e nada de `push --force`. Documentação de gestão não tem risco de
produção; código de projeto tem. Antes do primeiro push, eu rodo `git diff
origin/master..master --stat` e colo o resumo aqui.

---

## Q-029 · workspace · Aplicar os parâmetros de compactação no app? — **PARCIAL 24/11**

Feito: as três chaves seguras foram aplicadas pelo caminho sancionado do app
(`hermes config set`), e verificadas com `hermes config get`:
`compression.threshold` 0.75 → **0.70**, `target_ratio` 0.20 → **0.25**,
`protect_last_n` 20 → **24**. Reverter: os mesmos comandos com o valor antigo.

Falta decidir: **`context_length` do compressor, 65.500 → ~131.000**, que é o que
levaria o gatilho de ~46k para ~90k tokens. Não apliquei porque não há teste local —
se o modelo auxiliar não aceitar 131k, o resumo falha no meio da tarefa.

(a) Deixo como está (46k) e reavalio depois de uma semana de medição (recomendado).
(b) Subo para 131.000 e observo a primeira compactação.
(c) Subo só até 98.000, meio-termo.

**Default:** (a).

---

## Q-030 · workspace · Relatório de consumo automático toda semana?

`scripts/consumo.py` já lê os bancos locais em modo somente-leitura e imprime
entrada, saída, cache, compactações e custo por projeto, dia e modelo. Nenhuma
credencial, nenhum token gasto. O console do provedor continua fora de alcance (exige
login no navegador; robô logado em painel de faturamento é risco que eu não assumo).

(a) Cron semanal, segunda de manhã, resumo no `DOCS/08-GERENTE/MEDICOES.md`
    (recomendado).
(b) Só sob demanda, quando eu perguntar.
(c) Diário.

**Default:** (a).


---

## Q-031 · P-03 · Liberar a publicação das 4 páginas (T-P03-022)?

O brief está pronto e medido: 4 páginas em `draft` (226 consultoria, 227 projetos,
228 gestão de obra, 229 chave na mão), 4 cartões da home hoje apontando para `#contato`,
submenu SOLUÇÕES inexistente, e o CSS que corrige o título de página (31,67 px → 64 px).
Publicar é mudança visível ao cliente, então não ando sem tua palavra.

Reversível: revisão do WordPress em cada página + `git revert` do tema. Nada é
destrutivo; os legados 164–166 vão para a lixeira, não para o lixo.

(a) Pode — publica as 4, liga os cartões, cria o submenu, sobe o CSS (recomendado).
(b) Só o CSS do título; as páginas ficam em rascunho.
(c) Espera; quero ver o CSS antes.

**Default:** (c) — não publico nada. Se você não responder, o site fica como está:
funcionando, com as 4 páginas ainda invisíveis.

---

## Q-032 · P-03 · Trocar a cor do botão "Aceito" do banner de cookies?

Medido na home: o banner é 500×313, fixo no canto inferior esquerdo, fundo
`rgb(220,216,200)` — combina com o site. O botão "Aceito" é `rgb(59,41,255)`, azul
elétrico, fora da paleta bege/preto. É a única coisa fora de lugar no banner.

**Escopo real (medido no `banner-1-optin.css`):** 3 variáveis com `#3B29FF` —
`--cmplz_button_accept_background_color`, `--cmplz_hyperlink_color`,
`--cmplz_slider_active_color`. O link do banner já sai oliva `rgb(79,91,67)` por regra
mais específica, então na prática o azul aparece **só no botão "Aceito"** (e no slider
ativo, quando o visitante abre "Escolher preferências").

**Proposta, já validada em navegador** (`probe11` na home @1440):
`--cmplz_button_accept_background_color: #1A1A1A` com
`--cmplz_button_accept_text_color: #EDE3D6` (mais borda `#1A1A1A` e slider `#1A1A1A`).
Resultado medido: botão `rgb(26,26,26)` / `rgb(237,227,214)`, continua `149×45`; banner
segue `500×313`, `fixed`, mesmo canto, fundo `rgb(220,216,200)`; `scrollWidth 1440 =
innerWidth 1440`. **Contraste 13,72:1** — contra 7,13:1 do branco sobre o azul atual.

(a) Trocar para preto/bege da paleta (recomendado; CSS e brief prontos).
(b) Deixa como está.
(c) Mostrar a cor proposta antes.
(d) Só o botão; deixar o slider azul.

**Default:** (b) — não mexo. É cosmético e afeta todo o site.
**Brief:** `briefs/2026-11-23-p03-t023-paleta-banner-cookies.md` (marca `BLOQUEADO POR APROVAÇÃO`).

---

## Q-033 · P-03 · As 4 páginas de serviço: revisão editorial é tua ou minha?

As páginas 226–229 foram escritas pelo OpenCode com o texto que você aprovou. Eu
verifiquei estrutura: 2 H2 cada, CTA de WhatsApp correto (`5511983236422`), nada
inventado (sem CAU, sem preço, sem prazo, sem obra). O que eu **não** faço é julgar
se a frase vende bem — isso é teu, ou da Jéssica.

(a) Publico e você revisa depois, no ar (recomendado, se o texto já foi aprovado).
(b) Você lê os rascunhos antes de qualquer publicação.
(c) Peço à Jéssica para ler.

**Default:** (a), mas só depois de Q-031.

---

## Q-034 · workspace · Como o Gerente publica no GitHub (credencial que falta)?

O item 6 do `Dos GERENTES.md` pede GitHub do workspace atualizado. Tentei o `push`
hoje, 24/11, e ele **não passa**: `https://github.com/NMarlon/2-Gestor.git` sem
credencial salva (`fatal: could not read Username`), nenhuma chave SSH em `~/.ssh`
(`Permission denied (publickey)`) e nenhum token no `.env`. Os 22 commits locais
estão íntegros; falta só a porta de saída.

(a) Você cria um **fine-grained PAT** (só este repo, permissão `Contents: read and
    write`), põe em `.env` como `GITHUB_TOKEN=...` e eu configuro o helper. Nenhum
    agente lê nem imprime o valor. (recomendado)
(b) Você gera uma chave SSH e adiciona em GitHub → Settings → SSH keys; eu troco o
    remote para `git@github.com:NMarlon/2-Gestor.git`.
(c) Deixa sem `push` por enquanto: commit local todo dia e backup pelo `.bundle`.

**Default:** (c) até você decidir. Commit local continua obrigatório; o risco é
perder o repo se o disco morrer, não perder o histórico do dia.

---

## Q-035 · P-03 · O menu diz "Projeto" e o cartão diz "Projetos" — padronizo?

Medido na URL pública em 24/11, pelo gestor do P-03: o submenu SOLUÇÕES traz o item
**"Projeto"** (singular), o cartão da home diz **"Projetos"** e o `h1` da página é
**"Projeto de arquitetura e interiores"**. Os três links estão certos; é só o rótulo
que não fecha. Inconsistência visível ao visitante, não falha técnica.

(a) Padronizo para **"Projetos"** no submenu (o rótulo curto do menu fica no plural,
    igual ao cartão) — muda uma string no menu de navegação. (recomendado)
(b) Padronizo para **"Projeto"** também no cartão da home.
(c) Deixa como está: menu curto no singular é escolha editorial, e eu registro a
    decisão para não voltar em toda revisão.

**Default:** (c) — não mexo em rótulo visível sem sua palavra. A página está no ar e
funcional; isso é acabamento.

**Decidido: (a)** — o Gerente decidiu em **25/11** e mandou executar na **M-011 parte A**
(`08-GERENTE/PARA-GESTORES.md`), com a condição explícita de **não tocar no `h1`**.
Executado em 25/11 (**T-P03-028**): `wp_navigation` ID 6, `Projeto` → `Projetos`,
delta **+1 byte**; medido por mim na URL pública, duas leituras, md5
`105a167c248f7ffc1782000bf261e848` dos 7 rótulos, e o `h1` de `/projetos/` segue
`Projeto de arquitetura e interiores`. Fechada.

---

## Q-036 · P-03 · Duas lacunas de conteúdo que o questionário não cobre

A revisão editorial das 4 páginas (Q-033, `DOCS/P-03-Jessica-Haguiwara/REVISAO-EDITORIAL-2026-11-24.md`,
11 citações conferidas contra o HTML servido) achou duas perguntas que **faltam no
`QUESTIONARIO-CLIENTE.md`** — não é resposta em falta, é pergunta que ninguém fez:

1. **O que a cliente recebe no fim de uma consultoria?** Relatório, planta marcada,
   ata de encontro, ou é um encontro único? A `/consultoria/` descreve o que o
   escritório analisa, mas não o formato da entrega. É a lacuna que mais pesa na
   decisão de quem contrata.
2. **A consultoria é presencial, online, ou as duas?** Nenhuma das 4 páginas diz —
   e é a primeira dúvida de quem mora longe.

Também continuam abertas, já no questionário: Q 10.1 (consultoria avulsa?), Q 10.2
(frequência de visita à obra), Q 10.3 (quem executa no chave na mão), Q 11 (prazos)
e Q 12 (faixas de orçamento).

**O que preciso de você:** (a) autorizo incluir as duas no questionário e mandar para
a cliente junto com as outras; (b) você mesmo pergunta; (c) ficam abertas sem
perguntar — e então as 4 páginas continuam sem falar de entrega nem de formato.

**Default:** (c). Não pergunto nada à cliente por conta própria — nem para ela, nem
sobre ela.

**RESOLVIDA em 2026-11-25 — Marlon autorizou (opção a).** As duas entraram no
`QUESTIONARIO-CLIENTE.md` como **perguntas 21 e 22**, na seção nova "7. Sobre a
consultoria", com a nota de por que pergunto. Texto pronto para ele mandar à cliente.

## Q-037 · P-03 · O preview do link da /chave-na-mao/ ficou com o texto antigo

**Medido hoje no HTML servido** (25/11, URL limpa): a `/chave-na-mao/` tem

```
<meta property="og:description" content="Do projeto à entrega, com a tranquilidade de cuidar de cada etapa.">
```

É exatamente a frase do **M1 antes** da troca. O corpo da página já diz "com cada etapa
conduzida pelo escritório". O `twitter:description` acompanha. As outras três páginas
estão com o texto próprio delas — o problema é só nessa.

**Por que não foi corrigido:** o Yoast não grava por MCP. O `wp_update_post_meta`
devolve `ignored_keys` + aviso de integração desligada, e não existe tool de Yoast nas
117. Não é bug da execução; é limite da ferramenta.

**Opções:** (a) você edita no wp-admin — Yoast → página chave-na-mão → *Descrição*; é um
campo e leva um minuto, e eu te digo o texto exato; (b) habilitar a integração Yoast em
*Easy MCP AI → Tools → Plugins* e eu mando por MCP, junto com o resto; (c) deixar — o
corpo está certo e só o preview de link fica desatualizado.

**Default:** (a). É o único texto de SEO do site que contradiz a página, e preview de
link é o que a cliente vê quando manda o site no WhatsApp.

## Q-038 · P-03 · Texto pré-preenchido do WhatsApp desalinhado do botão

O C4 trocou o botão da `/consultoria/` para "Fale sobre o seu caso". O link do WhatsApp
das **4 páginas** (5 ocorrências por página) continua abrindo com o texto pronto
"Olá! Quero saber mais sobre os serviços de Arquitetura de Jessica Haguiwara" — que
serve bem as outras três e mal a consultoria, que agora fala com quem *não* tem projeto.

**Opções:** (a) trocar por um texto neutro para as quatro: "Olá! Quero falar sobre o meu
caso com a Jessica Haguiwara."; (b) deixar como está — é texto que a cliente vê e não
estava no escopo aprovado; (c) você escreve o texto e eu aplico.

**Default:** (b). Não troco texto visível ao cliente sem sua palavra, e o link é o mesmo
nas quatro páginas — mexer nele atinge todas de uma vez.

## Q-039 · P-05 · O coletor só coleta com você logado na máquina

**Medido agora** (`Get-ScheduledTaskInfo` + `Get-ScheduledTask`): a tarefa
`PainelHermes-Coletor` existe, `LastTaskResult = 0`, próxima execução 01:55:46, zero
execuções perdidas, ação `python.exe scripts\coletor.py` com `WorkingDirectory` correto.
A série está em 13 amostras, e as duas últimas caíram a 15 min 01 s uma da outra —
foi a tarefa que escreveu, não a mão.

**O limite:** `LogonType = Interactive` e `RunLevel = Limited`. Traduzindo: a tarefa
roda **enquanto a sua sessão está aberta**. Se você fecha o Windows, o próprio Windows
não executa — a série ganha buraco exatamente no período em que você está fora, que é
quando o painel mais interessa.

**Opções:** (a) deixar como está — série com buraco nos períodos deslogado;
(b) você roda **uma vez, elevado**, `.\scripts\instalar-agendador.ps1 -IUnderstand -LogonType S4U`,
e eu comparo duas amostras S4U contra duas interativas antes de adotar; (c) virar serviço
do Windows — mais trabalho e mais superfície para um painel local.

**Por que não fiz (b) sozinho:** S4U exige elevação (o gestor tentou e recebeu "Acesso
negado") e **não carrega o perfil do usuário** — o coletor lê `opencode.db` e caminhos do
perfil. Trocar sem medir seria substituir "buraco" por "coleta que falha calada".

**Default:** (a). Série com buraco é melhor que série que mente.

**Risco irmão, já endereçado:** a série vive em **um disco só** (o repo do P-05 não tem
remote, `Q-034`). Pedi export diário de `dados/stats.jsonl` para `backups/` na T-P05-003.

---

## Q-040 · P-06 · O PDF do planejamento está com download desativado

**FECHADA em 25/11/2026 — resolvida por mim, não pelo dono.** O Marlon respondeu que não
tem como liberar e que o bloqueio é intencional (os PDFs mudam toda semana). Ele mandou
contornar.

**A solução, medida na fonte.** O Drive não entrega o PDF, mas o **visualizador** entrega o
documento em dois pedaços que qualquer visitante com o link recebe:

```
/viewer/meta      → {"pages":7,"maxPageWidth":3200}
/viewer/presspage → camada de TEXT0 por página, com coordenadas de cada palavra
/viewer/img       → imagem da página em até 3200 px (não usada: texto é melhor)
```

O token (`ACFrOg...`) e a sessão (`fssid`) são criados pelo JavaScript do viewer — por isso
a leitura abre um navegador headless uma vez e colhe as URLs de `performance.getEntries`.
Provado: 7 páginas lidas, texto coerente (grade de horários, "Wednesday", "Day 1", etc.).

**Consequência:** o projeto não depende mais de ninguém. Brief `T-P06-009` despachado.
O bloqueio de download deixou de ser bloqueio.

**Medido em 25/11/2026, 13:40.** A pasta é pública e lista normalmente (1 arquivo:
`POR6.4.pdf`). O download, não:

```
https://drive.google.com/uc?export=download&id=1M_xdtXz-rkScXMg-i3rS57Kq7HmXrY5O
→ "Sorry, the owner hasn't given you permission to download this file.
   Only the owner and editors can download this file."
```

Mesma resposta com cookie de sessão e com `gdown`. A página `/preview` abre e entrega
**PNG renderizado** da página — não o PDF. Ou seja: dá para *ver*, não dá para *baixar*.

**Por que isso trava o projeto:** sem os bytes não há texto, e sem texto não há diff
confiável ("o que mudou" viraria comparação de imagem).

**Opções:**

- **(a) Pedir ao dono do arquivo que permita download** ("Qualquer pessoa com o link →
  Leitor" + *Permitir download*). É 30 segundos para eles e destrava tudo. **Recomendada.**
- **(b) Você baixa e deixa em `dados/`** — funciona, mas mata a automação: alguém precisa
  lembrar toda semana.
- **(c) OCR das páginas renderizadas** — funciona sem permissão, mas é frágil (erro de
  OCR vira "mudança" falsa) e caro. Só como último recurso.

**Default enquanto você decide:** construir e provar o motor com PDFs de teste (é o que o
OpenCode está fazendo agora), e deixar a execução real falhando de propósito com a frase do
Google — nunca "sem alterações".


---

## Q-041 · P-03 · Existe conta de Google Ads? (para a tag `AW-`)

**RESPONDIDA em 25/11/2026:** *"Sim, existe uma conta do Google ADS. Eu vou ter que procurar
depois, vai ser um processo manual."*

**Estado:** a conta existe; o **ID `AW-...` ainda não foi passado** — entra no digest das
6h30 até ele trazer. Enquanto isso vale o default: a T-032 entrega `/obrigado/` e o evento
`generate_lead`, e a tag do Ads fica como pendência explícita.

**Pergunta original:** você já tem conta de Google Ads para o site da Jessica — e o ID `AW-...`?

**Por que agora.** A auditoria de prontidão (25/11) fechou o diagnóstico: **sem
consentimento de verdade e sem conversão medida, ligar Ads é queimar dinheiro.** A T-032
faz a página `/obrigado/` e o evento `generate_lead` no GA4 — essas partes não dependem de
você. Mas a tag de conversão do Ads começa com um `AW-` que **só existe quando a conta
existe**, e inventar um ID é a única coisa pior que não ter ID.

**Opções:**

- **(a) Você já tem a conta** — me passe o `AW-` (ou diga que eu peço à Jessica) e a T-032
  fecha inteira. **Recomendada se a conta existe.**
- **(b) Ainda não existe** — a T-032 entrega `/obrigado/` + `generate_lead` e deixa o `AW-`
  como pendência; a campanha espera a conta.

**Default enquanto você decide:** (b) — o que não depende da conta é feito agora.
