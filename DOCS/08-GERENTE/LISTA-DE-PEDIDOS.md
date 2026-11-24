# Lista de pedidos e perguntas do Marlon

> Arquivo de continuidade do GERENTE. Se eu sumir, quem chegar lê **este** arquivo,
> depois `PAINEL-DE-GESTORES.md`, depois `DOCS/04-TAREFAS.md`. Cada linha tem estado,
> evidência e próximo passo — não é ata de conversa, é fila de trabalho.
> Atualizado: **24/11/2026, 09:05** (America/Sao_Paulo).

## Pendências vivas

| # | O que o Marlon pediu/perguntou | Estado | Evidência / onde está | Próximo passo |
|---|---|---|---|---|
| 1 | **"O menu vai ter um drop com 3–4 opções"** — o dropdown não aparece no site | 🔴 **não está no ar**: menu plano de 3 links, 0 submenu, 4 páginas em 404 | Medido no HTML servido da home: `<nav>` com um `<ul>` plano e 3 links — QUEM SOMOS `#quem-somos`, SOLUÇÕES `#solucoes`, CONTATO `#contato`; `has-child` = 0; `submenu-toggle` = 0; a única menção a `wp-block-navigation-submenu` está no **CSS inline** do WP, não no markup. As 4 URLs de serviço respondem **404** | `Q-031`: liberar publicação → brief `T-P03-022` |
| 2 | **3 ou 4 itens no dropdown?** | 🟡 decisão aberta | home tem 4 serviços; spec `planejamento/Obsidian Pages/Menu Superior.md` lista 3 | default **4**; pode mudar até o deploy |
| 3 | **Revisão editorial das 4 páginas** (texto vende?) | 🟡 aberta | `Q-033` | publicar e revisar no ar, ou ler rascunhos antes |
| 4 | **Publicar as 4 páginas de serviço** | 🔴 bloqueado | `Q-031`, brief `2026-11-23-p03-t022-publicar-servicos.md` | um "pode" do Marlon |
| 5 | **Cor do botão "Aceito" do banner de cookies** | 🟡 aberta | `Q-032`, brief `T-P03-023` | default: não mexer |
| 6 | **Como está a comunicação com os gestores** | ✅ respondido 24/11 | `PARA-GESTORES.md` revisado; `PAINEL-DE-GESTORES.md` seção "Canal" | teste real quando P-04 tiver dono |
| 7 | **Quantos gestores existem / um por projeto** | ✅ respondido 24/11 | regra veio do Marlon em 20/11 (commit `155552d`); confirmada por ele | nada a fazer |
| 8 | **Gasto e orçamento do OpenCode Go** | ✅ **resolvido** 24/11 | `GET https://opencode.ai/zen/go/v1/usage` com `OPENCODE_GO_API_KEY`: rolling 1%, semanal 11%, mensal 32% | ver seção "Quota" abaixo |
| 9 | **Lista de pedidos para não esquecer** | ✅ este arquivo | — | atualizar a cada sessão |
| 10 | **Compactação: parâmetro melhor para o fluxo** | 🟡 parcial | `Q-029`, `08-GERENTE/COMPACTACAO.md` | falta decidir o teto do compressor |
| 11 | **Relatório de consumo automático semanal** | 🟡 aberto | `Q-030` | default: não criar cron ainda |
| 12 | **Push do workspace para o GitHub** | 🔴 bloqueado por credencial | `Q-034`: sem PAT, sem chave SSH, sem token | PAT fine-grained no `.env` |
| 13 | **Atualizar os docs com a nova hierarquia** (`Dos GERENTES.md`) | ✅ feito 24/11 | `AGENTS.md` (Papéis), `07-GESTORES.md` (itens 2/3/6/8/15/16), `08-GERENTE/PAINEL-DE-GESTORES.md` | — |
| 14 | **Mensagem cortada: "E o próximo I…"** | ⚪ sem continuação | veio truncada em 24/11 | perguntar quando ele voltar; não adivinhar |
| 15 | **Projeto P-04 (Portfólio) sem dono** | 🟡 parado | `Q-024` | abrir gestor só com "sim" dele |
| 16 | **Projeto P-02 (Reconhecedor) sem dono** | 🟡 parado | `Q-024` | idem |

## Regras que ele deu e valem sempre

- **Commit constante**, sempre, em todo repo. Nunca reescrever commit antigo — o
  commit é o ponto de retorno.
- **Não apagar os depoimentos fictícios**: são exemplo pedido pelo cliente, e estão
  marcados como `EXEMPLO`. Nunca apresentar como prova real.
- **Tokens**: agentes podem **ver** o consumo, nunca ganhar acesso a mais token nem
  criar credencial. Tudo read-only.
- **`AGENTS.md` é editável** — ele liberou explicitamente.
- **Gerente não escreve código de projeto de próprio punho**; briefa o OpenCode.
- **Nunca inventar dado de cliente**: CAU, área, prazo, preço, obra, depoimento.

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

Leitura: o Go é **assinatura com teto ponderado**, não cobrança por dólar. O teto de
referência é US$ 60/mês, e cada modelo consome em ritmo próprio (DeepSeek V4.1 Flash
tem limite mensal alto, então gasta devagar). 32 % em 24/11 deixa ~3,5 %/dia até
12/12 — folga confortável.

Ressalvas: o endpoint **não é documentado** e pode sumir sem aviso (é o mesmo que o
console usa); `User-Agent` de `curl`/`urllib` padrão leva 403; o campo `cost` das
respostas do Go é sempre `"0"`, então não serve para contabilidade. A visão por
projeto continua sendo `python scripts/consumo.py --dias 30`, que lê os bancos locais.

Automação pendente: um `scripts/quota.py` read-only, que imprime as três janelas e o
tempo até resetar. **Não escrevo isso de próprio punho** (item 3 do `Dos GERENTES.md`)
— vira brief para o OpenCode.

## Ordem de leitura para quem chegar depois

1. Este arquivo.
2. `DOCS/08-GERENTE/PAINEL-DE-GESTORES.md` — quem é de quê e o que foi medido.
3. `DOCS/08-GERENTE/PARA-GESTORES.md` — canal e protocolo.
4. `DOCS/04-TAREFAS.md` — tarefas por projeto, com ID.
5. `DOCS/06-PERGUNTAS.md` — o que espera resposta do Marlon, com default.
