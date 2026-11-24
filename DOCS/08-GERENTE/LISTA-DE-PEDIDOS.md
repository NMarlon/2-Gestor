# Lista de pedidos e perguntas do Marlon

> Arquivo de continuidade do GERENTE. Se eu sumir, quem chegar lê **este** arquivo,
> depois `PAINEL-DE-GESTORES.md`, depois `DOCS/04-TAREFAS.md`. Cada linha tem estado,
> evidência e próximo passo — não é ata de conversa, é fila de trabalho.
> Atualizado: **24/11/2026, 10:20** (America/Sao_Paulo).

## Decisões dele em 24/11 (turno das 21 respostas)

1. **Publicar as 4 páginas de serviço: APROVADO.** "Pode publicar… quero ver como
   ficaram. E me diga exatamente o que mudou."
2. **Dropdown: 4 itens.** "Qualquer coisa eu mudo depois."
3. **Cor do botão "Aceito": decisão minha.** "Pode deixar o que achar melhor."
4. **Revisão editorial (`Q-033`): eu reviso** e apresento **antes/depois**.
5. **`Q-030`: sem cron job.** Ele não quer consumo de IA nisso — quer um **script
   read-only** e análise **esporádica** (não diária), quando ele perguntar.
6. **P-04 (Portfólio): não mexer.** Ele decidiu ontem; **não será WordPress**; stack
   ainda indefinida. Congelado até ele dar os detalhes.
7. **P-02 (Reconhecedor): não mexer.** Ele está fazendo o destrinchamento manual das
   imagens e chama quando precisar.
8. **Prioridade de tokens, dita por ele:** Jéssica Haguiwara é urgente **porque já
   está paga**. Erdos 711 só consome o que sobrar do mês, antes da renovação.
   "Não quero ultrafocus em tokens" — qualidade e segurança primeiro.
9. **Máximo para o OpenCode.** "Quero que você passe o máximo possível para o OpenCode
   executar. Não você." — inclusive scripts.
10. **`AGENTS.md` é mapa para todo tipo de IA** — gestor, gerente e executor, cada um
    com sua especialidade. Regra pedida: "se você for GERENTE, leia tais arquivos".
    **Autorizada.**
11. **Janela do Credential Helper: pode ser GCM.** Ele autorizou abrir quando eu
    precisar e ele clica.
12. **Backup `.bundle`: quer, mas quis entender.** Explicado; feito.
13. **Novo projeto (painel/monitor): aprovado** — pasta em `C:\MarlonScripts`, GitHub
    próprio, gestor novo, docs pelo padrão de "Novo Projeto".
14. **Cliente Jéssica:** ele já cobrou; aguardando o cliente mandar os dados. Esperar.

## Pendências vivas

| # | O que o Marlon pediu/perguntou | Estado | Evidência / onde está | Próximo passo |
|---|---|---|---|---|
| 1 | **"O menu vai ter um drop com 3–4 opções"** | 🟢 **4 itens, aprovado 24/11**; ainda não está no ar | menu plano de 3 links, 0 submenu, 4 páginas em 404 (medido no HTML servido) | entra no 2º run do `T-P03-022` |
| 2 | **3 ou 4 itens no dropdown?** | ✅ **4** | decisão dele, 24/11 | — |
| 3 | **Revisão editorial das 4 páginas** | 🟢 minha, decidido | `Q-033`; ele quer **antes e depois** do que eu mudar | revisar depois de publicar |
| 4 | **Publicar as 4 páginas de serviço** | 🟢 **aprovado 24/11 10:10**, run 1 em andamento | `T-P03-022`; run 1 para no `--dry-run` | conferir dry-run → liberar run 2 |
| 5 | **Cor do botão "Aceito" dos cookies** | 🟢 decisão minha | `Q-032`, brief `T-P03-023`; azul `rgb(59,41,255)` fora da paleta | vou de tinta escura: 13,72:1 (vs 7,13:1 do azul) |
| 6 | **Como está a comunicação com os gestores** | ✅ respondido | `PARA-GESTORES.md`, `PAINEL-DE-GESTORES.md` | — |
| 7 | **Quantos gestores existem / um por projeto** | ✅ confirmado | regra dele em 20/11 (`155552d`) | — |
| 8 | **Gasto e orçamento do OpenCode Go** | ✅ resolvido; **histórico pesquisado** | ver seção "Quota" | — |
| 9 | **Lista de pedidos para não esquecer** | ✅ este arquivo | — | atualizar a cada sessão |
| 10 | **Compactação: parâmetro melhor** | 🟡 parcial | `Q-029`, `COMPACTACAO.md` | falta decidir o teto |
| 11 | **Relatório de consumo** | ✅ **sem cron**; script sob demanda | `Q-030`; análise esporádica, não diária | brief do script |
| 12 | **Push do workspace para o GitHub** | ✅ **ele fez o push em 24/11** (`origin/master` = `c4b3950`, ahead 0) | `Q-034`; eu continuo sem credencial própria | discutir política (prós/contras entregues) |
| 13 | **Docs com a nova hierarquia** | ✅ feito 24/11 | `AGENTS.md`, `07-GESTORES.md`, `PAINEL` | — |
| 14 | **Mensagem cortada: "E o próximo I…"** | ⚪ sem continuação | veio truncada | perguntar; não adivinhar |
| 15 | **P-04 (Portfólio)** | ⛔ **congelado por ele** 24/11 | não será WordPress; stack indefinida | esperar os detalhes |
| 16 | **P-02 (Reconhecedor)** | ⛔ **congelado por ele** 24/11 | ele faz o destrinchamento manual | ele chama |
| 17 | **`AGENTS.md`: 107 linhas — vira ponteiro?** | 🟡 ele pediu o conteúdo do item; não decidiu enxugar | 107 linhas / 6.063 bytes / ~1.550 tokens; "Papéis" = 50 %; **não há nome de gestor lá** | levar como pergunta na próxima, com o texto na mão |
| 18 | **Janela "Credential Help Selector"** | ✅ resolvido: é o GCM, ele autorizou | `credential.helper=helper-selector` no system; nada gravado | abrir quando eu precisar de push |
| 19 | **Novo projeto: painel de estatísticas ao vivo** | 🟢 **aprovado 24/11** | pasta em `C:\MarlonScripts`, GitHub próprio, gestor novo, scripts de fundo + navegador local | docs pelo padrão + brief do app |
| 20 | **Backup `.bundle` do workspace** | ✅ feito 24/11 | `backups/2-Gestor-20261124.bundle`, 8,1 MB, `git bundle verify` = "complete history", HEAD `c4b3950` | repetir a cada entrega grande |
| 21 | **Coleta de cota em background, com histórico** | 🟢 aprovado | ele quer série para média, não retrato | brief do coletor |
| 22 | **"Histórico no site" do consumo** | ✅ pesquisado 24/11 | **não existe API de série temporal** (feature request aberto no repo do OpenCode) | série só sai de coleta própria |
| 23 | **Dados da cliente Jéssica** | ⏳ ele já cobrou o cliente | "só estou aguardando o retorno" | esperar; não inventar |
| 24 | **Ele atualizou `Dos GERENTES.md`** | ✅ lido 24/11 | novo item: pedir aprovação antes de editar `AGENTS.md`, e deixar para o fim | respeitar: edição de `AGENTS.md` só com o "pode" |

## Regras que ele deu e valem sempre

- **Commit constante**, sempre, em todo repo. Nunca reescrever commit antigo — o
  commit é o ponto de retorno.
- **Não apagar os depoimentos fictícios**: são exemplo pedido pelo cliente, e estão
  marcados como `EXEMPLO`. Nunca apresentar como prova real.
- **Tokens**: agentes podem **ver** o consumo, nunca ganhar acesso a mais token nem
  criar credencial. Tudo read-only.
- **`AGENTS.md` é editável** — ele liberou; mas pediu **aprovação antes** de editar e
  deixar para o fim da fila.
- **Gerente não escreve código de projeto de próprio punho**; briefa o OpenCode.
  Vale para script também: script vira brief.
- **Nunca inventar dado de cliente**: CAU, área, prazo, preço, obra, depoimento.
- **Quando ele pede opinião, é opinião**: "não execute nada ainda sobre isso" é ordem.
  Reflexão primeiro, execução só com "pode".
- **Não é ultrafocus em tokens.** Economizar é meio, não fim: qualidade e segurança
  vêm antes. Prioridade dele: Jéssica (paga) → demais → Erdos 711 só com a sobra.

## Quota do OpenCode Go — como se mede (24/11)

Não existe painel local: o `opencode` CLI não está no PATH desta máquina e o
`opencode.db` não guarda percentual de cota. O que existe é o endpoint que o
console usa, e ele responde com a chave que já está no `.env`:

```bash
curl -s -H "Authorization: Bearer $OPENCODE_GO_API_KEY" \
     -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/131.0" \
     https://opencode.ai/zen/go/v1/usage
```

Resposta medida hoje, 24/11, 09:00 local:

| Janela | Uso | Reseta |
|---|---|---|
| Rolante (5 h) | **1 %** | 24/11 13:12 (local) |
| Semanal | **11 %** | 29/11 21:00 (local) |
| Mensal | **32 %** | 12/12 21:45 (local) |

**O que a pesquisa de 24/11 acrescentou (item 19 do pedido dele):**

- **Não existe API de histórico.** "Expose OpenCode Go usage history through the API
  key" é *feature request* ainda aberto no repo do OpenCode. O endpoint devolve **o
  percentual de agora** (arredondado para baixo), não série temporal. O "histórico no
  site" que ele lembra é a página Console → Go, com os mesmos três números.
- **A única série temporal real está na máquina**: o `opencode.db` guarda custo e
  requisições **por dia**, por dispositivo. É dele que saem histórico e média.
- **Rota mais rica, não testada:** a Console API tem permissão `Usage: Read` e
  medidores em **micro-centavos** (`usedMicroCents`/`limitMicroCents`) — **dólar**,
  não porcentagem. Exigiria criar chave de API, e ele disse que agentes **não** criam
  credencial. Fica como pergunta, não como ação.
- Existe também `GET /api/experimental/usage/limits` no servidor local do OpenCode
  (experimental, mesmas três janelas).
- **Plano:** a doc lista Go (US$ 10/mês) e Go Plus (US$ 40/mês); cada modelo tem teto
  mensal próprio em dólares (DeepSeek V4.1 Flash: US$ 100 no Go). **Não sei qual é o
  plano dele** — o endpoint não diz. A cota é um balde único ponderado, por isso o
  percentual sobe devagar num modelo barato.

Ressalvas do endpoint: **não é documentado** e pode sumir sem aviso (é o mesmo que o
console usa); `User-Agent` de `curl`/`urllib` padrão leva 403; o campo `cost` das
respostas do Go é sempre `"0"`, então não serve para contabilidade. A visão por
projeto continua sendo `python scripts/consumo.py --dias 30`, que lê os bancos locais.

Automação: o coletor em background (item 21) precisa gravar **as três janelas + o
`resetsAt`** de tempos em tempos — é o único jeito de ter série. Daí saem média por dia
e projeção de esgotamento. **Não escrevo isso de próprio punho** (item 3 do
`Dos GERENTES.md`, e ele reforçou em 24/11): vira brief para o OpenCode.

## Ordem de leitura para quem chegar depois

1. Este arquivo.
2. `DOCS/08-GERENTE/PAINEL-DE-GESTORES.md` — quem é de quê e o que foi medido.
3. `DOCS/08-GERENTE/PARA-GESTORES.md` — canal e protocolo.
4. `DOCS/04-TAREFAS.md` — tarefas por projeto, com ID.
5. `DOCS/06-PERGUNTAS.md` — o que espera resposta do Marlon, com default.
