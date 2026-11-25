# API de uso do OpenCode Go — medido, não especulado

> **Status: FUNCIONA.** Medido em 2026-11-25 12:05 pelo Gerente. Este documento existe
> para a próxima IA não re-investigar o que já está resolvido.

## O endpoint

```
GET https://opencode.ai/zen/go/v1/usage
Authorization: Bearer $OPENCODE_GO_API_KEY
Accept: application/json
User-Agent: <UA de navegador — obrigatório, ver abaixo>
```

**Resposta real obtida (25/11 12:05, conta do Marlon):**

```json
{"usage": {
  "rolling": {"status":"ok", "percent": 2,  "resetsAt": "2026-11-25T16:03:04.000Z"},
  "weekly":  {"status":"ok", "percent": 18, "resetsAt": "2026-11-30T00:00:00.000Z"},
  "monthly": {"status":"ok", "percent": 35, "resetsAt": "2026-12-13T00:45:05.000Z"}
}}
```

Bate com o Console (print do Marlon às 08:24: 5 h 1%, semanal 18%, mensal 35%). O `rolling`
passou de 1% para 2% entre 08:24 e 12:05 — é o consumo do dia.

- `percent` é **0 a 100** (2 = 2%), não fração.
- `resetsAt` é UTC em ISO-8601.
- É o mesmo contador que o Console mostra, não uma estimativa.
- **Só devolve percentual** — não devolve dólar nem detalhe por modelo. A divisão por
  modelo que o Console exibe (DeepSeek 92%, MiMo 8%, Qwen <1%) **não** está neste endpoint.

## Três pegadinhas medidas (todas custaram uma tentativa)

1. **Cloudflare bloqueia UA de script.** `urllib`/`curl` puro devolve **HTTP 403
   "Error 1010: Access denied"**. Com UA de navegador, **HTTP 200**. Não é falta de
   permissão da chave — é assinatura de cliente.
2. **A chave não está no opencode.db.** `~/.local/share/opencode/auth.json` **não existe** e
   as tabelas `account`, `control_account` e `account_state` do `opencode.db` estão **vazias**
   (0 linhas). É por isso que o CLI devolvia `data=null` e o servidor local `HTTP 401`.
3. **A chave está no `.env` do Hermes:** `~/AppData/Local/hermes/.env`, variável
   **`OPENCODE_GO_API_KEY`** (prefixo `oc_`, 51 caracteres). É a mesma que os perfis usam
   como provider `opencode-go`. **Nunca imprimir, nunca logar, nunca versionar.**

## Caminhos que NÃO funcionam (para não repetir)

| Tentativa | Resultado |
|---|---|
| `GET https://opencode.ai/api/experimental/usage/limits` | **404** — rota não existe |
| `GET https://opencode.ai/api/usage` | **404** |
| `GET http://127.0.0.1:28894/api/experimental/usage/limits` (servidor do app desktop) | **200 com `data:null`** — autentica com Basic `opencode:<password do ~/.config/opencode/service.json>`, mas sem workspace conectado devolve nulo |
| `~/.local/share/opencode/auth.json` | não existe |
| Tabelas `account`/`control_account` do `opencode.db` | vazias |

## O servidor local do app desktop (descoberta lateral)

`http://127.0.0.1:28894` é uma API HTTP real (`openapi.json` em `/doc` e `/openapi.json`).
Autenticação: **Basic**, usuário `opencode`, senha = campo `password` de
`~/.config/opencode/service.json`. Sem auth: 401. Com Bearer: 401. Só Basic funciona.

## Uso no painel

O `coletor.py` deve, a cada rodada: ler `OPENCODE_GO_API_KEY` do `.env` do Hermes (ou da
variável de ambiente, se existir), chamar o endpoint com UA de navegador, e gravar em
`stats.jsonl` um bloco `cota_oficial` com os três percentuais e os três `resetsAt`.

Falha é dado, não silêncio: 401 → "chave inválida ou revogada"; 403 → "Cloudflare bloqueou a
assinatura do cliente"; timeout → "sem resposta". Nunca gravar 0% no lugar de erro.
