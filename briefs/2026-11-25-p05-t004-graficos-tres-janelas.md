# Brief T-P05-004 — gráficos das três janelas (5 h, 7 d, 30 d) + cota oficial `INDISPONIVEL`

**Projeto:** P-05 Painel Hermes — repo `C:\MarlonScripts\5-Painel-Hermes`
**Tarefa:** `T-P05-004` (ordem M-009 do Gerente, em nome do Marlon, prazo 25/11)
**Executor:** OpenCode (`P05-EXECUTOR`). Um escritor, este brief, nada fora dele.
**Autor do brief:** GESTOR-P05, 2026-11-25.

---

## 1. Resultado esperado (uma frase)

O painel em `http://127.0.0.1:8787` passa a mostrar **três gráficos com os tokens
medidos localmente** — janelas de **5 h, 7 dias e 30 dias** — mais o **cartão do plano**
(US$ 10/mês informado pelo Marlon) e o **cartão oficial do provedor** marcado
`INDISPONIVEL`, com motivo e o que o Marlon precisa fazer. Tudo legível em 1440 px e em
390 px, sem CDN e sem dependência nova.

---

## 2. Contexto já verificado (não re-investigue)

Medido pelo gestor em 2026-11-25, 08:10–08:20:

- **Números de referência hoje (30 dias, sessões iniciadas no período):**
  - Hermes, 4 perfis com `state.db`: **396 sessões**, input **21.812.023**, output
    **1.595.066**, cache_read **120.590.976**, tool_calls **15.287**.
    Por perfil: `jessica-p03` 16 s / `manager-developer-hermes` 348 s /
    `matematico` 8 s / `painel-p05` 24 s.
  - OpenCode: **75 sessões**, input **47.051.734**, output **3.787.628**,
    cache_read **2.068.396.096**, cache_write **255.851**, reasoning **6.350.375**.
  - Esses números **mudam a cada minuto** — não são critério de igualdade exata, são
    ordem de grandeza para conferência.
- **`dados/stats.jsonl`**: 41 amostras, de `2026-11-24T21:22:13-03:00` a
  `2026-11-25T08:10:51-03:00`, uma a cada 15 min. Chaves da linha:
  `schema, coletado_em, epoch, host, coletor, duracao_ms, hermes, hermes_tokens,
  opencode, cota`.
  `hermes_tokens.hoje` = `{sessoes,input,output,cache_read,cache_write,reasoning,tool_calls,custo_usd}`;
  `hermes_tokens.hoje_por_perfil` = mesmo objeto por perfil; `hermes_tokens.serie_7d`
  = lista por dia. `opencode.hoje` idem; `opencode.serie_7d` idem.
- **Perfis reais hoje** (renomeados em 25/11, M-010): `jessica-p03`,
  `manager-developer-hermes`, `matematico`, `painel-p05`; `conversa` **não tem**
  `state.db` (ausência de dado, nunca zero). `.deleted` é lixo, ignorar.
- **Cota oficial é impossível hoje**, já medido: `opencode.db` → tabela `account`
  **0 linhas**, `control_account` 0, `account_state` 0; CLI responde `data=null`;
  HTTP local 401/404. **Não tente de novo**: o brief proíbe chamada de rede/credencial.
- **Hermes não tem token por mensagem**: `messages.token_count` é NULL em 100% das
  linhas. O único dado temporal é `sessions` (total por sessão) e
  `session_model_usage` (total por sessão/modelo, sem série). Logo, janela de 5 h
  **não** pode ser calculada somando `sessions` por `started_at` — sessão longa
  iniciada ontem consumiria hoje e apareceria como zero. O caminho correto é o
  descrito no item 4.3.
- **Arquitetura vigente:** `coletor.py` grava `dados/stats.jsonl` (append-only);
  `painel.py` só lê arquivo de `dados/`. A UI **não** abre `.db`, `.env`, `auth.json`,
  não serve arquivo do repo, `POST` → 405.
- **Servidor rodando agora:** PID **42216** em `127.0.0.1:8787` com o código antigo.
  Ele precisa ser parado antes do teste e **deixado parado** no fim (o gestor sobe a
  versão final e mede).
- Python do PATH é 3.14.9; **stdlib apenas**.

---

## 3. Escopo único

Três arquivos de código e a documentação listada:

1. `scripts/coletor.py` — gravar `dados/grafico.json` a cada execução e acrescentar
   dois campos de total na amostra.
2. `scripts/painel.py` — ler `dados/grafico.json` e renderizar os três gráficos e os
   dois cartões novos.
3. `.gitignore` — ignorar `dados/*.json`.
4. Docs do repo: `DOCS/02-ARQUITETURA.md`, `DOCS/04-TAREFAS.md`, `DOCS/05-BACKLOG.md`.
   (Detalhe no item 8.)

Nada mais.

---

## 4. O que fazer

### 4.1 `coletor.py` — dois campos novos na amostra (retrocompatível)

Na linha gravada em `stats.jsonl`, **sem remover nem renomear chave existente**, acrescente:

```json
"hermes_tokens": {
  "...": "...",
  "total": {"input": 0, "output": 0, "cache_read": 0, "cache_write": 0, "reasoning": 0,
            "tool_calls": 0, "sessoes": 0},
  "total_por_perfil": {"<perfil>": {"input": 0, "output": 0, "cache_read": 0,
                                    "cache_write": 0, "reasoning": 0, "tool_calls": 0,
                                    "sessoes": 0}}
},
"opencode": {
  "...": "...",
  "total": {"input": 0, "output": 0, "cache_read": 0, "cache_write": 0,
            "reasoning": 0, "sessoes": 0}
}
```

`total` = **todas** as sessões do banco (não só hoje, não só 7 dias). É a base do
fluxo de 5 h. Perfil sem `state.db` **não entra** no mapa.

### 4.2 `coletor.py` — `dados/grafico.json` (escrita atômica: `.tmp` + `os.replace`)

Gerado **depois** de gravar a amostra, a cada execução. Se falhar, não derruba a
amostra (imprima o erro no stderr, exit 1, como o backup já faz). Contrato:

```json
{
  "schema": 1,
  "gerado_em": "2026-11-25T08:30:00-03:00",
  "amostra_em": "2026-11-25T08:30:00-03:00",

  "janelas": {
    "5h":  {"inicio": "<iso>", "fim": "<iso>", "metodo": "fluxo_entre_coletas",
            "hermes":   {"input":0,"output":0,"cache_read":0,"tool_calls":0,"sessoes":0,
                         "por_perfil": {"<perfil>": {"input":0,"output":0,"cache_read":0,"tool_calls":0,"sessoes":0}}},
            "opencode": {"input":0,"output":0,"cache_read":0,"sessoes":0}},
    "7d":  {"inicio": "<iso>", "fim": "<iso>", "metodo": "sessoes_iniciadas",
            "hermes": {"...": "...", "por_perfil": {"<perfil>": {"...": "..."}}},
            "opencode": {"input":0,"output":0,"cache_read":0,"sessoes":0}},
    "30d": {"...": "mesma forma do 7d"}
  },

  "fluxo_5h": [
    {"ts": 1795600000, "hhmm": "07:45", "lacuna": false,
     "hermes":   {"input":0,"output":0,"cache_read":0},
     "opencode": {"input":0,"output":0,"cache_read":0}}
  ],

  "serie_diaria": {
    "dias": ["2026-10-27", "...", "2026-11-25"],
    "hermes": {
      "total": [{"dia":"2026-11-25","input":0,"output":0,"cache_read":0,"tool_calls":0,"sessoes":0}],
      "por_perfil": {"painel-p05": [{"dia":"2026-11-25","input":0,"output":0,"cache_read":0,"tool_calls":0,"sessoes":0}]}
    },
    "opencode": {"total": [{"dia":"2026-11-25","input":0,"output":0,"cache_read":0,"sessoes":0}]}
  },

  "plano": {
    "valor_usd_mes": 10, "valor_brl_mes": 60,
    "fonte": "informado pelo Marlon (M-009)",
    "preco_por_token": null,
    "mes": "2026-11",
    "tokens_mes": {"input":0,"output":0,"cache_read":0,"total":0}
  },

  "oficial": {
    "status": "indisponivel",
    "motivo": "<copiado de cota.motivo da amostra>",
    "acao": "Abrir o Console do OpenCode e conectar o workspace desta máquina; depois a coleta passa a ler os limites do plano."
  }
}
```

Regras de cálculo:

- **`janelas.7d` e `janelas.30d` = sessões iniciadas na janela.** Hermes: `sessions`
  dos 4 bancos, `started_at >= corte`; OpenCode: `session_v2.time_created` (epoch **ms**).
  `corte` = agora − 7×86400 / 30×86400. `por_perfil` = um mapa por perfil.
- **`serie_diaria`** = 30 dias, do mais antigo ao mais recente, incluindo dias sem
  sessão (valor 0, que é zero medido: nenhuma sessão iniciada). `por_perfil` por dia,
  para os 4 perfis; perfil sem sessão no dia = 0.
- **`plano.tokens_mes`** = soma de `serie_diaria` dos dias do mês corrente.
- **`fluxo_5h`** (o único cálculo delicado): reconstrua a partir das **últimas ~60
  amostras do `stats.jsonl`**, par a par:
  - `dt = b.epoch - a.epoch`. Se `dt <= 0` ou `dt > 1800` (30 min, duas coletas
    perdidas) → bucket de `b` com `lacuna: true` e valores 0.
  - Se **as duas** amostras têm `total` (novo campo) → delta de `total` (Hermes e
    OpenCode). Senão, se as duas são do **mesmo `hermes_tokens.dia`** → delta de
    `hoje`. Senão → `lacuna: true`.
  - Delta negativo em qualquer campo → aquele campo vira 0 (reajuste/renome); não
    propague negativo.
  - **Por perfil** (`janelas.5h.hermes.por_perfil`): só some o delta quando **as duas**
    amostras têm a mesma chave de perfil (em `total_por_perfil`, ou em
    `hoje_por_perfil` no modo antigo). Perfil que aparece do nada contribui 0 naquele
    intervalo — evita o pico falso da renomeação de 25/11.
  - Inclua só buckets com `ts >= agora − 5 h`. Não invente bucket para intervalo em
    que a máquina estava desligada; o buraco é `lacuna`.
  - Janela de 5 h tem no máximo 20 buckets de 15 min. A soma dos buckets é o total da
    janela.
- **Nunca** leia `.env`, `auth.json`, tabela `credential`, nem faça HTTP. `motivo` vem
  da amostra já coletada.

### 4.3 `painel.py` — leitura

- Continuar lendo `dados/stats.jsonl` (cache por size+mtime, como hoje).
- Passar a ler **também** `dados/grafico.json` (mesmo padrão de cache; arquivo ausente
  → cartões de gráfico dizem `sem dado` e a página continua 200).
- **Não** abrir banco nenhum. Atualize o docstring: fonte = `dados/stats.jsonl` +
  `dados/grafico.json`, nada mais.
- `grafico.json` inválido/parcial → usar o último válido em memória, ou `sem dado`.

### 4.4 `painel.py` — três gráficos SVG (gerados no servidor, sem JS de terceiro)

Um cartão largo por janela, nesta ordem:

1. `T-P05 — Tokens nas últimas 5 horas` — barras empilhadas por bucket de 15 min
   (Hermes + OpenCode). Buracos (`lacuna`) aparecem como espaço vazio, nunca como
   zero silencioso.
2. `T-P05 — Tokens por dia · 7 dias` — barra por dia, empilhada Hermes + OpenCode.
3. `T-P05 — Tokens por dia · 30 dias` — idem, 30 barras.

Requisitos visuais e técnicos:

- `<svg>` inline com `id="grafico-5h"`, `grafico-7d`, `grafico-30d`; `viewBox`,
  `width:100%`, `height:auto`; nada de CDN, `<script src>`, fonte externa ou imagem.
- Empilhado: Hermes e OpenCode com cores distintas e legenda textual
  (`Hermes` / `OpenCode`), não só cor.
- Eixo Y com 3–4 marcas em formato compacto (`0`, `350 k`, `1,2 M`); eixo X com data
  ou hora: `HH:MM` no 5 h, `dd/mm` no 7 d, `dd/mm` a cada ~5 dias no 30 d.
- **Tooltip no hover** via `<title>` dentro de cada barra: ex.
  `25/11 07:45 — Hermes 1,2 M · OpenCode 340 k`. Sem JS.
- Barra com valor 0 é desenhada com 1 px de base para o dia existir no eixo; dia
  inexistente no `serie_diaria` (fora dos 30) não aparece.
- Sem dado (arquivo ausente, janela vazia) → texto `sem dado` no lugar do SVG; nunca
  barra inventada, nunca eixo com número fictício.
- **Abaixo de cada gráfico, uma nota** com o método, texto exato:
  - 5 h: `Fluxo medido entre coletas de 15 min. O Hermes grava o total por sessão, então o valor aparece quando a sessão atualiza.`
  - 7 d/30 d: `Tokens das sessões iniciadas no dia (Hermes e OpenCode). Sessão longa conta inteira no dia em que começou.`
- **Tabela por perfil** no cartão de 30 d: perfil | sessões | entrada | saída | cache
  lido | chamadas (Hermes `tool_calls`; OpenCode = `—`, não invente). Linha de total.
- Tabela por dia não é necessária: o gráfico já é por dia.

### 4.5 Cartão do plano (local, medido — NÃO é o oficial)

Título `Plano` com selo `INFORMADO`, cara de cartão local (cor de destaque igual aos
outros cards medidos). Conteúdo:

- `US$ 10/mês (R$ 60)` e `fonte: informado pelo Marlon`.
- `novembro/2026: 10.412.345 tokens medidos` (valor de `plano.tokens_mes.total`,
  formatado) com a quebra entrada/saída/cache em uma linha secundária.
- Nota literal: `Sem preço configurado — não convertemos token em % do plano.`

### 4.6 Cartão oficial do provedor (cara diferente, nunca misturado)

Título `Cota oficial do provedor`, **borda tracejada** e cor neutra (classe CSS
própria, ex. `.oficial`), selo `OFICIAL · INDISPONIVEL`. Conteúdo:

- `motivo` da cota (texto existente, truncado com `title` completo).
- **Ação**, texto exato: `Para virar dado: abrir o Console do OpenCode e conectar o
  workspace desta máquina. Hoje a tabela account do banco local tem 0 linhas — não há
  workspace conectado.`
- Nota: `Sem percentual estimado: não há contador oficial legível nesta máquina.`

Os cartões existentes (`Hermes`, `Série`, `Hermes — tokens hoje`, `OpenCode hoje`,
`Histórico`) continuam funcionando. O cartão `Cota OpenCode Go` atual pode ser
substituído pelo novo cartão oficial — não duplique os dois.

### 4.7 Responsivo

- Em 390 px: uma coluna, sem rolagem horizontal, sem texto cortado, SVG legível
  (fonte do SVG dimensionada para sobrar ~10 px na tela estreita).
- Em 1440 px: cartões largos ocupando a linha inteira, gráfico com altura confortável.
- Teste real: `@media (max-width: 520px)` já existe; ajuste o que precisar.

### 4.8 Documentação (dentro do repo do projeto)

- `DOCS/02-ARQUITETURA.md`: acrescentar `dados/grafico.json` ao diagrama e à lista de
  fontes (derivado, escrito pelo coletor, lido pela UI); **corrigir os nomes de perfil
  para `jessica-p03` e `painel-p05`** (M-010); registrar por que a tabela oficial não é
  lida (`account`/`control_account`/`account_state` = 0 linhas, 401/404) — item 7 da
  M-009.
- `DOCS/04-TAREFAS.md`: renumerar o item de backlog `T-P05-004 — relatorio-semanal.py`
  para **`T-P05-005`** e abrir a entrada `T-P05-004 — gráficos das três janelas` como
  entregue nesta tarefa, com os comandos de verificação.
- `DOCS/05-BACKLOG.md`: acrescentar "retenção/rotação de `dados/grafico.json` não é
  necessária (arquivo reescrito, ~50 KB); `stats.jsonl` cresce ~0,5 MB/dia" — só se
  ainda não estiver lá.

---

## 5. Proibições

- Não chamar API externa, não usar credencial, não abrir `auth.json`, `.env`,
  `credential`, não imprimir segredo.
- Não inventar preço, câmbio, percentual de plano, cota ou data.
- Não alterar `dados/stats.jsonl` à mão; só o coletor escreve.
- Não mexer em porta/host (`127.0.0.1:8787`), não abrir serviço, não criar agendador,
  não criar cron do Hermes.
- Não instalar dependência; stdlib.
- Não tocar em outro projeto nem no repo `2-Gestor`.
- Não usar `git add -A`, `git add .`, `commit -a`; sem push, sem `--amend`.
- Não reescrever os cartões existentes além do necessário; não mudar o formato das
  chaves antigas de `stats.jsonl`.

---

## 6. Critério de aceite (rode e cole a saída no relatório)

No diretório `C:\MarlonScripts\5-Painel-Hermes`:

1. `python -m py_compile scripts/coletor.py scripts/painel.py` → exit 0.
2. Pare o servidor antigo: `taskkill /PID 42216 /F` (confirme com
   `netstat -ano | findstr :8787` → vazio).
3. `python scripts/coletor.py --sem-cota` → grava 1 linha nova em `stats.jsonl` **e**
   cria `dados/grafico.json`; imprime a linha de resumo.
4. `python -c "import json;d=json.load(open('dados/grafico.json',encoding='utf-8'));print(d['schema'],len(d['serie_diaria']['dias']),list(d['janelas']),len(d['fluxo_5h']))"`
   → `1 30 ['5h','7d','30d'] <n>` com `n` entre 1 e 20.
5. **Conferência independente** (cole os dois números): total de 30 d do Hermes e do
   OpenCode calculado por você direto nos bancos (`mode=ro`) **e** os valores de
   `janelas.30d` no `grafico.json`. Diferença aceitável: só o que entrou entre as duas
   leituras (minutos).
6. `python scripts/painel.py` (numa janela) e, noutra:
   - `curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8787/` → `200`
   - `curl -s http://127.0.0.1:8787/ | grep -c 'id="grafico-'` → `3`
   - `curl -s http://127.0.0.1:8787/ | grep -ci 'INDISPONIVEL'` → `>= 1`
   - `curl -s http://127.0.0.1:8787/ | grep -c 'US\$ 10'` → `>= 1`
   - `curl -s -X POST -o /dev/null -w "%{http_code}" http://127.0.0.1:8787/` → `405`
   - `curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8787/scripts/painel.py` → `404`
   - `curl -s http://127.0.0.1:8787/api/stats | python -c "import json,sys;d=json.load(sys.stdin);print(sorted(d['cards']))"` → inclui as chaves dos gráficos.
7. `git status --short` → só os arquivos deste escopo; `dados/grafico.json` **não**
   aparece (gitignored).
8. Pare o servidor de teste e **deixe a porta livre**; informe o comando.
9. Commit único, autoria `P05-EXECUTOR <p05@2gestor.local>`, caminhos explícitos.

---

## 7. Contrato de retorno (formato exato)

```
RESULTADO:
status: entregue | parcial | bloqueado
arquivos_alterados:
  - <caminho> — <o que mudou>
comandos_executados:
  - <comando> -> <saída resumida>
evidencia:
  - <números do grafico.json x consulta independente>
  - <http codes>
nao_testado:
  - <o que não deu para testar e por quê>
riscos:
  - <risco real, sem enfeite>
proximo_passo:
  - <o que o gestor deve medir>
```

Sem esse formato, a entrega volta.
