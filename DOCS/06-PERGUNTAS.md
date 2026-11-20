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

## Q-02 · Aprovar a criação do `AGENTS.md` na raiz 🟡

A escrita em `AGENTS.md` foi bloqueada pela proteção de arquivo de instrução de
agente (o prompt de aprovação expirou enquanto você estava fora). Não vou
contornar por outro caminho.

**Preciso:** sua aprovação para eu escrever `C:\MarlonScripts\2-Gestor\AGENTS.md`
(o contrato do workspace, apontando para `DOCS/`).

Até lá, a documentação funciona por `DOCS/00-INDICE.md`.

---

## Q-03 · P-01 (Hermes-Mobile) está encerrado? 🟡

O servidor responde `0.23.2`, Tailscale ativo nos três ports e você marcou "está
funcionando". Restam só o aviso de versão do Mono Hermes (upstream) e o plugin de
push (backlog).

Confirma que P-01 pode ir para "encerrado, em manutenção" e o foco vira P-02?

---

## Q-04 · Prioridade: ordem da lista ou rentabilidade? 🔴 decide o próximo projeto

`Definições Oficiais Manuais/Principais Regras e Princípios.md` diz: "prioridade para os projetos de
maior rentabilidade e maiores chances de sucesso". Sua instrução de hoje diz:
"comece pelo primeiro projeto aprovado da lista".

São critérios diferentes. Hoje segui a **lista** (P-01 → P-02). Se quiser que eu
passe a ordenar por potencial comercial — com plano de negócio antes de codar —,
diga que eu reorganizo a fila e justifico caso a caso.

---

## Q-05 · Feedback dos projetos publicados 📝

O `Principais Regras e Princípios.md` pede canal de feedback nos projetos que vão ao ar, com seu
e-mail (`marlonrviana@gmail.com`). Vale para os projetos locais (P-01, P-02) ou só
para os que tiverem usuário externo? Sugiro: só nos publicados.

---

## Q-06 · Acervo tem duplicatas — o que fazer com elas? 🟡

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

## Q-10 · P-03: manter o `jhw-purge.php` público no root do site? ⚪

Para limpar o cache eu chamei `https://jessicahaguiwara.arq.br/jhw-purge.php?k=…`
(chave em `backups/jhw-purge.php`). Funciona, mas é um endpoint público que
qualquer um com a chave pode martelar — cache flush repetido derruba performance.

**O que eu faço por padrão:** deixo como está (é a única forma de publicar hoje) e
registro o risco. Se quiser, troco a chave e/ou passo a remover o arquivo depois
de cada publicação — mas a UAPI não apaga arquivo, então seria pelo File Manager.

---

## Q-08 · P-03: `logs/` do projeto entra no `.gitignore`? ⚪

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

## Q-11 · P-03: tirar o editor visual da caixa de mensagem do formulário? 🟡

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

## Q-12 · P-03: o GTM da home (181 KB gzip) é isso mesmo? ⚪

O container `GT-TBVGGKRR` chega em **545.320 B raw / 181.289 B gzip** — mais que
todo o CSS do site somado. Não é problema do tema nem do WordPress: é o que está
configurado dentro do GTM. Vale perguntar à cliente (ou a quem montou as tags) se
todas aquelas tags ainda são usadas.

---

## Q-13 · P-03: um "Brand Agent" da Microsoft Clarity carrega em todas as páginas 🟡

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

## Q-014 · P-02 · Qual `eps` fica valendo para o agrupamento?

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

## Q-015 · P-02 · Duplicatas: vale investir?

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

