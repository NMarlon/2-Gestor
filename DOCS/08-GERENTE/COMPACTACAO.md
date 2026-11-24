# Política de compactação — o parâmetro e o porquê

Decisão do GERENTE, 24/11. Responde ao pedido do Marlon: "qual é o melhor parâmetro
de quando compactar, neste fluxo". Medido neste perfil e nos bancos do OpenCode;
pesquisa nas duas fontes que mandam no assunto (Anthropic, engenharia de contexto;
documentação do OpenCode).

Resumo em uma linha: **o gatilho não deve ser uma fração da janela do modelo — deve
ser um teto fixo de trabalho por sessão, e a compactação deve ser exceção.**

## 1. O que acontece hoje (medido, não estimado)

Hermes, perfil `manager-developer-hermes`, banco `state.db`:

| Medida | Valor | Como medi |
|---|---|---|
| Compactação dispara com | **27k–38k tokens** de contexto (mediana **32,7k**, n=15) | soma de `len(content)+len(tool_calls)` até a mensagem que absorve o histórico, dividido por 3,6 |
| Configuração da causa | `compression.threshold: 0.75` sobre teto artificial `context_length: 65500` | `config.yaml` |
| Alvo do resumo | `target_ratio: 0.2` — descarta ~80% | `config.yaml` |
| Sessões (30 dias, `2-Gestor`) | 260 | `sessions` |
| Dessas, quantas compactaram | 85 (33%), **1 evento cada** | `messages.absorbed_message_uids` |
| Entrada por sessão | p50 **51,8k**, p90 74,6k, máx 190k | `sessions.input_tokens` |
| Cascata observada | 12 compactações em 15 min, uma a cada ~75 s | sessão de 23/11, 21:57–22:12 |

OpenCode (executor), banco `opencode.db`, 189 sessões desde agosto:

| Medida | Valor |
|---|---|
| Compactações | 96 (91 automáticas, 3 manuais, 2 falharam) |
| Sessões afetadas | 20; a pior com **19 compactações** |
| Pior sessão por entrada | **7,35 M tokens** numa única sessão |
| Tamanho do resumo | mediana 11.946 caracteres; máx 56.565 |

Leitura: o gestor compacta **cedo** (32k tokens, ~3% da janela real de 1 M do
`deepseek-v4.1-flash`) e **fundo demais** (guarda 20%). Cedo + fundo = perde o fio,
refaz trabalho, compacta de novo. O executor, no extremo oposto, deixa a sessão
chegar a 7,35 M tokens — que é caro e é onde o modelo fica burro.

## 2. O que a pesquisa diz

- **Anthropic, "Effective context engineering for AI agents"**: a janela é um
  orçamento de atenção, não um contêiner. "Context rot": a capacidade de recuperar
  o que está no meio da janela cai conforme o total cresce — vale para todos os
  modelos. Compactação é a primeira alavanca, e a destilação precisa ser de **alta
  fidelidade**: decisões, arquivos, estado, próximo passo. Sub-agente devolve
  **1.000–2.000 tokens** de resumo destilado; o Claude Code mantém os 5 arquivos
  acessados por último em texto integral.
- **Documentação do OpenCode**: compactação automática é padrão; dispara em
  `janela − buffer`, com `buffer` padrão de **15%** e mínimo de 16k, mantendo
  `keep.tokens` (padrão **15.000**) recentes em texto integral. Compactação em
  segundo plano (`background`) reaproveita cache; resumo preparado e não usado
  ainda custa tokens.

Conclusão que os dois sustentam: compactar é perda. O objetivo não é compactar
bem, é **compactar pouco** — cortando o trabalho em sessões do tamanho certo.

## 3. A regra

**3.1 Estrutural (vale mais que qualquer número).** Uma tarefa, uma sessão. Fechou
a tarefa: handoff em arquivo (≤ 8.000 caracteres, oito seções), `commit`, sessão
nova. Se uma sessão compactou **duas vezes**, a tarefa estava grande demais —
quebre na próxima. Compactação é exceção: alvo ≤ 1 por tarefa.

**3.2 Teto por sessão, não fração da janela.** Gatilho em torno de **90k tokens**,
que é onde o custo por chamada ainda é baixo e o "context rot" ainda não cobrou.
Não use 75% de 1 M (750k): paga 20× mais por chamada para o modelo ficar pior.

**3.3 Parâmetros — gestor (Hermes).** `config.yaml` do perfil, seção `compression`.
Aplicado em 24/11 via `hermes config set` (o agente não edita o arquivo direto — o
app bloqueia, corretamente):

```yaml
compression:
  enabled: true
  threshold: 0.70        # era 0.75 — aplicado
  target_ratio: 0.25     # era 0.20 (resume guardando mais, refaz menos) — aplicado
  protect_last_n: 24     # era 20 — aplicado
  protect_first_n: 3
  in_place: false
```

Verificado por `hermes config get` (`0.7`, `0.25`, `24`). Reverter é a mesma porta:
`hermes config set compression.threshold 0.75` (idem para as outras duas).

Com `context_length: 65500` no auxiliar, isso põe o gatilho em ~46k — ainda cedo.
Para chegar aos ~90k, o teto usado pelo compressor precisa subir para ~131.000.
**Essa parte não foi aplicada**: não há como testar localmente se o modelo auxiliar
aceita 131k, e uma falha de resumo no meio da tarefa é pior que compactar cedo.
Fica em `Q-029`, com o resto.

**3.4 Parâmetros — executor (OpenCode).** `~/.config/opencode/opencode.json`:

```json
{
  "compaction": {
    "auto": true,
    "prune": true,
    "keep": { "tokens": 24000 },
    "buffer": "70%",
    "background": true
  }
}
```

`buffer: "70%"` numa janela de 1 M faz o gatilho cair para 300k; com `keep` de 24k,
o resumo preserva o suficiente para não refazer. Padrão do OpenCode (15%) só
faz sentido em janela de 200k.

## 4. Orçamento de tarefa: onde ele serve

O "orçamento" (150k tokens por tarefa) **não é controle, é termômetro**. Ninguém
consegue parar no meio de uma tarefa porque o contador passou — o trabalho já foi
feito pela metade. Serve para três coisas: detectar tarefa mal definida, comparar
projetos, e justificar quebra de escopo na próxima. Por isso continua como
**alarme de revisão**, não como gate que bloqueia.

O que governa o custo, na ordem em que importa:

1. **Escopo da sessão** (uma tarefa por sessão) — maior efeito, medido acima.
2. **Higiene de documento** (regra 11 do Marlon): o próximo agente lê o índice, a
   seção, o arquivo citado — nada além.
3. **Não despejar saída bruta**: medir com script que imprime 5 linhas em vez de
   ler 178 KB de HTML.

Métrica que vale para progresso: **tokens por entrega aceita**, não tokens por dia.
Hoje: P-03 7,17 M de entrada / 36 commits; P-04 273 k / 4; P-02 1,15 M / 6. Amostra
pequena (Marlon tem razão, item 4): n = 4 a 36 commits, e o custo do P-03 inclui
o aprendizado do fluxo inteiro. Serve de ordem de grandeza, não de ranking.

## 5. Como medir

```bash
python scripts/consumo.py --dias 7            # por fonte, projeto, dia, modelo
python scripts/consumo.py --projeto "Jessica" --dias 30
python scripts/consumo.py --json               # para relatório
```

Fontes (somente leitura): `~/AppData/Local/hermes/profiles/*/state.db` e
`~/.local/share/opencode/opencode.db`. O console do provedor
(`opencode.ai/console/.../activity`) continua sendo a fonte de **faturamento**;
o script mede o que o agente gastou. Divergiu, vale o console. Nenhuma credencial
é lida, nenhum token é gasto: é `sqlite3` em modo `ro`.

## 6. O que não fazer

- Proibir leitura de arquivo grande. A cura é ler a faixa, não proibir.
- Resumo de 26 mil caracteres: handoff tem 8 seções e teto de 8.000 caracteres.
- Compactar "sempre que passar de X%" em modelo de 1 M: 750k é o pior dos mundos.
- Deixar sessão chegar a milhões de tokens: 96 compactações e uma sessão de 7,35 M
  mostram o custo de não ter teto.
