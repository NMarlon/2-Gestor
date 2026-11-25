# Brief T-P05-010 — P-05: cota oficial ao vivo do OpenCode Go (M-013)

Projeto: `C:\MarlonScripts\5-Painel-Hermes`
Executor: OpenCode — **um escritor**, um repositório.
Origem: M-013 do Gerente (`DOCS/08-GERENTE/PARA-GESTORES.md`), dentro da M-015.
Data: 2026-11-25.

## ESCOPO ÚNICO

Fazer o coletor ler a **cota oficial do OpenCode Go ao vivo**, a cada rodada, e o
painel mostrar as três janelas oficiais (5 h, semanal, mensal) como dado medido,
com a hora da leitura. Falha de leitura vira **motivo legível**, nunca zero.

Nada além disso. Não é tarefa de layout, não é tarefa de autostart (essa vem
depois, em T-P05-009), não é tarefa de mexer no bloco de plano.

## CONTEXTO JÁ VERIFICADO PELO GESTOR (não re-investigue)

1. O endpoint oficial responde. Medido hoje 10:26 pelo gestor, com a chave do
   `.env` do Hermes, HTTP 200 em 0,48 s:

   ```json
   {"usage":{
     "rolling":{"status":"ok","percent":8,"resetsAt":"2026-11-25T16:03:04.000Z"},
     "weekly":{"status":"ok","percent":20,"resetsAt":"2026-11-30T00:00:00.000Z"},
     "monthly":{"status":"ok","percent":37,"resetsAt":"2026-12-13T00:45:05.000Z"}}}
   ```

   - URL: `https://opencode.ai/zen/go/v1/usage`
   - Headers que funcionaram: `Authorization: Bearer <chave>`, `Accept: application/json`,
     e **User-Agent de navegador** (o `UA_NAVEGADOR` que já existe em `coletor.py:67`).
   - `percent` é inteiro 0–100 do **plano**, não dos tokens medidos aqui.

2. A chave está em `%LOCALAPPDATA%\hermes\.env`, variável **`OPENCODE_GO_API_KEY`**
   (51 caracteres, prefixo `oc_`). O gestor confirmou a presença e o tamanho; **não
   imprima o valor** em console, log, arquivo, commit ou `motivo`.

3. A chave que o coletor lê hoje — `credencial_opencode_go()` em `coletor.py:541`,
   tabela `credential` do `opencode.db` — **não serve** para este endpoint: com ela o
   servidor responde 401. Não mexa nessa função; ela continua servindo o caminho legado.

4. Código atual, onde mexer:
   - `coletor.py:71-72` — constantes `ENDPOINT_LIMITES` / `ENDPOINT_LIMITES_CLOUD`.
   - `coletor.py:601` — `medir_cota(cli)`, o caminho **legado** (CLI → servidor local
     → cloud). Ele devolve `indisponivel` com o motivo de hoje. **Não altere o
     comportamento dele.**
   - `coletor.py:1010` — chamada de `medir_cota` no fluxo principal; `coletor.py:1039`
     grava a chave `"cota"` na amostra.
   - `coletor.py:940-954` e `montar_grafico()` (`coletor.py:866`, bloco `oficial` em
     `coletor.py:975`) — derivam `dados/grafico.json` a partir da última amostra.
   - `painel.py:897` — `_card_oficial()`; hoje, no sucesso, só escreve "Limites
     oficiais legíveis nesta coleta" **sem mostrar número**. `painel.py:881`
     `_resumo_cota()` tem a frase fixa "o provedor não expõe leitura de cota neste host",
     que deixou de ser verdade.
   - O sentinela de sucesso no `grafico.json` é `status: "disponivel"` (não `"ok"`).
     Mantenha esse vocabulário para não quebrar o painel.

5. `dados/oficial.jsonl` **não existe** — a leitura manual do M-012 nunca foi
   implementada. Portanto: **não crie esse bloco nesta tarefa** e **não invente**
   leitura manual. A comparação do item 5 da M-013 fica preparada para o futuro:
   se o arquivo existir um dia, comparar; se não existir, não mostrar nada.

6. `dados/` é gitignored. Não versione série, não versione print.

## O QUE FAZER

### A. `scripts/coletor.py` — leitura

1. Nova função `credencial_go_env() -> tuple[str | None, str | None>`:
   - tenta `os.environ.get("OPENCODE_GO_API_KEY")`;
   - senão lê `%LOCALAPPDATA%\hermes\.env` (fallback `~/AppData/Local/hermes/.env`),
     tolerando `export `, espaços e aspas em volta do valor;
   - devolve `(chave, erro)` e **nunca** loga o valor.
2. Nova função `medir_cota_oficial() -> dict`, que:
   - chama `GET https://opencode.ai/zen/go/v1/usage` com timeout de 25 s, headers do
     item 1 do contexto;
   - valida que a resposta tem `usage.rolling/weekly/monthly` com `percent` numérico;
   - devolve, no sucesso:
     ```json
     {"status":"disponivel","consultado_em":"<ISO local>",
      "fonte":"GET https://opencode.ai/zen/go/v1/usage",
      "rolling":{"percent":8,"resets_at":"2026-11-25T16:03:04.000Z","status":"ok"},
      "weekly":{"percent":20,"resets_at":"2026-11-30T00:00:00.000Z","status":"ok"},
      "monthly":{"percent":37,"resets_at":"2026-12-13T00:45:05.000Z","status":"ok"}}
     ```
   - na falha, devolve `{"status":"indisponivel","consultado_em":"<ISO>","motivo":"<frase>"}`
     com frase específica, sem chave e sem stack:
     - chave ausente → `"chave OPENCODE_GO_API_KEY ausente no ambiente e no .env do Hermes"`;
     - HTTP 401 → `"chave inválida ou revogada (HTTP 401)"`;
     - HTTP 403 → `"acesso bloqueado na borda (HTTP 403) — Cloudflare pode ter barrado a assinatura do cliente"`;
     - HTTP 429 → `"limite de consultas atingido (HTTP 429)"`;
     - timeout/URLError → `"sem resposta do endpoint em 25 s"`;
     - JSON sem `usage` → `"resposta sem o bloco usage"`.
   - **Nunca** devolver percentual 0 como substituto de falha.
3. No fluxo principal (`coletor.py:1010` em diante): chamar `medir_cota_oficial()`
   **sempre** (inclusive com `--sem-cota`? não: com `--sem-cota`, pule e grave
   `{"status":"nao_medida"}`) e gravar a nova chave `"cota_oficial"` na amostra de
   `stats.jsonl`, ao lado de `"cota"`. O bloco `"cota"` legado continua sendo gravado
   como hoje.
4. Linha de console: acrescentar, depois da linha atual da cota,
   `cota oficial: 5h 8% | semanal 20% | mensal 37% (lida 10:26)` ou, na falha,
   `cota oficial: indisponivel | motivo: <frase>`.
5. Em `montar_grafico()`, o bloco `"oficial"` passa a sair de `cota_oficial` da amostra
   mais recente que tenha `cota_oficial.status == "disponivel"`:
   ```json
   {"status":"disponivel","consultado_em":"...","fonte":"GET https://opencode.ai/zen/go/v1/usage",
    "nota":"percentual do plano oficial, não dos tokens medidos neste painel",
    "rolling":{"percent":8,"resets_at":"..."},
    "weekly":{"percent":20,"resets_at":"..."},
    "monthly":{"percent":37,"resets_at":"..."}}
   ```
   Se nenhuma amostra tiver leitura oficial, o bloco volta ao formato de hoje
   (`status: "indisponivel"`, `motivo` vindo do `cota` legado, `acao` mantida).
   Compatibilidade: painel antigo lendo `grafico.json` novo **não** pode quebrar
   (o `status` continua `disponivel`/`indisponivel`).

### B. `scripts/painel.py` — cartão

6. `_card_oficial()`, quando `status == "disponivel"`:
   - selo `OFICIAL · AO VIVO` (classe `ok`);
   - três linhas/rótulos curtos: **5 horas**, **Semanal**, **Mensal**, cada um com
     `NN%` e a hora local de renovação (`resets_at` convertido de UTC para
     America/Sao_Paulo, formato `dd/mm HH:MM`);
   - uma nota: `percentual do plano oficial, lido às HH:MM — não é o consumo de tokens medido aqui`;
   - o endereço do endpoint em `<details class="tecnico">`, sem chave.
7. Quando `status != "disponivel"`:
   - selo `OFICIAL · INDISPONIVEL` (classe `mudo`);
   - `_resumo_cota()` passa a devolver o **motivo real** vindo do dado, sem a frase
     fixa "o provedor não expõe leitura de cota neste host". Mantenha o `<details>`
     com o motivo técnico completo.
8. Preparação tolerante do item 5 da M-013: se `dados/oficial.jsonl` existir e tiver
   uma leitura do dia, e qualquer janela divergir mais de 2 pontos, acrescentar uma
   linha `fontes divergem — manual X% · ao vivo Y%`. **Arquivo ausente = nada aparece.**
   Não criar o arquivo, não gravar leitura manual.
9. A UI **continua só lendo arquivo local**. O painel não chama a API do provedor;
   quem coleta é o coletor. Rotas e status HTTP atuais (GET/HEAD 200, resto 404,
   POST 405) ficam como estão. Porta 8787, host 127.0.0.1, sem escolher outra porta.

## PROIBIDO

- Imprimir, logar, versionar ou colar a chave — em qualquer arquivo, inclusive
  `motivo`, `fonte` e mensagem de erro. Se precisar citar, `[REDACTED]`.
- Copiar `.env`, `auth.json` ou `opencode.db` para dentro do repo.
- Abrir navegador de qualquer tipo (nem `Start-Process` de URL, nem script CDP
  próprio). Print não é seu: o gestor mede com a ferramenta única do workspace.
- Mexer em `dados/*.jsonl`, `dados/grafico.json`, `backups/` como se fossem código.
- Alterar `medir_cota()` legado, as outras funções de cartão, o bloco de plano, o
  layout das janelas 5 h/7 d/30 d, a porta, as rotas.
- Adicionar dependência externa. Só biblioteca padrão (`urllib`, `json`, `os`,
  `datetime`).
- Tocar em qualquer arquivo fora de `C:\MarlonScripts\5-Painel-Hermes`.
- Criar agendador, serviço ou cron nesta tarefa (isso é T-P05-009).

## CRITÉRIO DE ACEITE (verificável, o gestor refaz)

1. `python scripts/coletor.py` **duas vezes seguidas**: a última linha de
   `dados/stats.jsonl` em cada rodada tem `cota_oficial.status == "disponivel"` e os
   três percentuais entre 0 e 100. Cole os dois blocos `cota_oficial` no retorno.
2. `OPENCODE_GO_API_KEY=chave_invalida_de_teste python scripts/coletor.py` (variável
   só naquele processo): grava `cota_oficial.status == "indisponivel"` com
   `motivo` começando por `chave inválida ou revogada`. Sem exceção, sem zero. Depois
   uma rodada normal volta a `disponivel`.
3. Reiniciar o painel com o código novo e **deixá-lo de pé, destacado, sem janela**
   (`pythonw.exe scripts/painel.py`, sem console). `curl -s -o NUL -w "%{http_code}" http://127.0.0.1:8787/`
   devolve `200`.
4. O HTML servido contém os rótulos `5 horas`, `Semanal`, `Mensal` e os mesmos
   percentuais de `dados/grafico.json` (dados.oficial). Cole o trecho do HTML.
5. `git grep -nE "oc_[A-Za-z0-9]{20,}"` no repo **não** acha nada. `git status --short`
   não mostra `.env`, `auth.json`, `*.db`, `dados/`.
6. Commit no repo do projeto, assinado pelo executor:
   `T-P05-010: cota oficial ao vivo do OpenCode Go (3 janelas, erro como motivo)`.

## CONTRATO DE RETORNO

Responda exatamente neste formato:

- **RESULTADO** — o que passou a existir, em 3 linhas.
- **status** — `ENTREGUE` | `PARCIAL` | `BLOQUEADO`.
- **arquivos_alterados** — caminho e o que mudou em cada um.
- **comandos_executados** — os comandos reais, com a saída relevante colada.
- **evidencia** — os dois blocos `cota_oficial` (rodada normal), o bloco da rodada com
  chave inválida, o `curl` 200 e o trecho do HTML com os três percentuais.
- **nao_testado** — o que você não rodou, e por quê.
- **riscos** — o que pode quebrar, incluindo o que o gestor deve conferir na tela.
- **proximo_passo** — o que você sugere depois.

Não invente saída. Se um passo falhar, cole o erro real e marque `PARCIAL`/`BLOQUEADO`.
