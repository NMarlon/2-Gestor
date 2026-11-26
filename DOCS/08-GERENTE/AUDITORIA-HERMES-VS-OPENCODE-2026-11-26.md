# Auditoria — quem programou: Hermes ou OpenCode (25–26/11)

> Pedido do Marlon (26/11): "quem de fato estava programando?" Fonte: `state.db` dos
> perfis (mensagens, chamadas de ferramenta, tokens), `git log` dos repos e logs
> `oc-*.log`. Medição: 26/11 08:50.

## Números por perfil (desde 25/11 00:00)

| Perfil | Sessões | `terminal` | `oc-brief` (sessões) | `node` | `python` | Escritas em código |
|---|---:|---:|---:|---:|---:|---|
| **ctm-p06** (gestor P-06) | 19 | 313 | 14 (12) | 0 | 113 | **0** |
| **jessica-p03** (gestor P-03) | 119 | 2.590 | 158 (72) | 663 | 415 | **~530** (101 no `medir-cdp.py`) |
| **manager-developer-hermes** (Gerente) | 14 | 880 | 25 (2) | 9 | 356 | 9 no `commit-agent.sh`, 5 no `digest-manha.py` |

Tokens (input / output / cache): P-06 **1,32M / 151k / 9,0M**; P-03 **7,70M / 583k /
37,2M**; Gerente **5,77M / 753k / 177,8M**. A sessão "GERENTE GERAL" sozinha foi 3,9M
input e 81 `patch` + 52 `write_file`.

## P-06 — o código foi do OpenCode

- **14 commits `OPENCODE-P06`** no repo, incluindo o motor, a grade, o diff, as bordas,
  o painel do vigia, o CSRF e o alvo de toque. **0 commit do gestor** no repo.
- **4 commits `GERENTE`**: esqueleto (`AGENTS.md`, `README`, `.gitignore`), documentação,
  versionamento de `historico.json` e `.gitignore`. Nenhum é código de produto.
- Escritas do gestor no workspace: **só `DOCS/` e `briefs/`** (caderno, fila, 14 briefs).
- O gestor **executou** muito — 313 `terminal`, 113 `python` — para medir e testar. Não
  escreveu código.

**Veredito P-06: a suspeita não se confirma.** O Hermes mediu e documentou; o OpenCode
programou.

## P-03 — o gestor escreveu ferramenta, não o site

- No repo do site, 25/11: **2 commits `EXECUTOR-P03`**, 2 `GESTOR-P03` (docs/release), 1
  com a identidade errada do Marlon. O código do site foi do OpenCode.
- Mas o gestor deu **101 `patch` em `C:\MarlonScripts\2-Gestor\scripts\medir-cdp.py`** e
  escreveu scripts de diagnóstico no scratch (`verify-cta.mjs`, `mcp-read.mjs`,
  `probe-cta.mjs`). Isso é Hermes programando ferramenta — e o medidor é compartilhado.
- 119 sessões, 158 `oc-brief` em 72 delas: o gestor delegou muito, mas também rodou
  **663 `node`** e **415 `python`** por conta própria.

**Veredito P-03:** o site foi do OpenCode; o Hermes gastou token escrevendo e rodando
ferramentas de medição.

## Gerente — escreveu scripts do workspace

- `commit-agent.sh` recebeu **9 `patch`** e `digest-manha.py` **5** — script do workspace
  deveria virar brief, não edição de próprio punho.
- 25 `oc-brief` concentrados em 2 sessões; nas outras, 880 `terminal` e 356 `python`.

## O que explica o custo

1. **Muitas sessões curtas**: 119 no P-03, 19 no P-06. Cada uma recarrega system prompt,
   docs e histórico — o cache de 37M/178M mostra releitura. O OpenCode trabalha num brief
   e commita.
2. **Hermes executando em vez de delegar**: `node`/`python` direto no gestor, quando o
   brief ao OpenCode faria o mesmo com menos contexto.
3. **Hermes escrevendo ferramenta**: `medir-cdp.py` 101 vezes, scripts de scratch,
   `commit-agent.sh`.

## Regra que sai desta auditoria

- **Escrita de código — inclusive ferramenta e script de diagnóstico — é do OpenCode, por
  brief.** O Hermes lê, mede, decide e documenta; não patcheia código.
- `medir-cdp.py` e afins: escritos **uma vez**, mantidos por brief. O gestor usa, não edita.
- **Uma tarefa, uma sessão.** Encerrou a lista, para e reporta (M-028).
