# Brief — guard-code.sh: Hermes não escreve código

**Data:** 2026-11-26 · **Executor:** OpenCode · **Repo:** `C:\MarlonScripts\2-Gestor`
**Autor:** GERENTE · **Origem:** E-044 (auditoria: `medir-cdp.py` recebeu 101 patches do Hermes).

## Contexto já verificado (não re-investigue)

- Doc do Hermes: shell hooks no `config.yaml` do perfil, chave `hooks:` → evento →
  lista de `{command, matcher, timeout, fail_closed}`. `matcher` é regex no `tool_name`.
- Payload no stdin do hook: `{"hook_event_name":"pre_tool_call","tool_name":"...",
  "tool_input":{...},"session_id":"...","cwd":"...","extra":{...}}`.
- Resposta: stdout `{"decision":"block","message":"..."}` ou exit 2; qualquer outra coisa
  deixa passar. `fail_closed: true` só vale em `pre_tool_call`.
- Perfis a proteger: `ctm-p06`, `jessica-p03`, `painel-p05`, `manager-developer-hermes`.
  O executor OpenCode **não** usa hook do Hermes — a regra é só para os perfis Hermes.

## Escopo único

### 1. `scripts/guard-code.sh`

Lê o JSON do stdin e decide:

- **`write_file` / `patch` / `apply_patch`:** extrai `tool_input.path` (ou `file_path`).
  Se o arquivo for **código** — `.py .pyw .js .mjs .cjs .ts .tsx .jsx .php .css .scss
  .sass .sh .bash .ps1 .bat .cmd .html .htm .json` — e **não** estiver sob `DOCS/`,
  `briefs/`, `docs/`, `cache/`, `.scratch/`, `logs/`, `backups/`,
  `Definições Oficiais Manuais/`, e não for `.md` → **bloqueia**:
  `{"decision":"block","message":"Hermes não escreve código (E-044). Brief ao OpenCode."}`.
- **`terminal`:** bloqueia só escrita de arquivo de código por redirecionamento/tee
  (`> *.py`, `>> *.py`, `tee *.py`, `cat > *.py`). **Não** bloqueia execução
  (`python scripts/verificar.py`, `node scripts/deploy-theme.mjs --dry-run`).
- Qualquer outro caso: sem saída e exit 0 (deixa passar).
- JSON inválido ou campo ausente: exit 0 (o `fail_closed` do Hermes cobre a falha do
  script; o guard não pode derrubar `write_file` de `.md`).
- Log append em `logs/guard-code.log` (timestamp, tool, path ou comando, decisão) —
  opcional, mas útil; `logs/` é ignorado.

### 2. `scripts/instalar-guard.sh`

Para cada perfil em `C:/Users/Marlon/AppData/Local/hermes/profiles/<perfil>/config.yaml`:

1. backup `config.yaml.bak-guard-<AAAAMMDD-HHMMSS>`;
2. inserir/atualizar, preservando o resto do YAML:
   ```yaml
   hooks:
     pre_tool_call:
       - command: "C:/MarlonScripts/2-Gestor/scripts/guard-code.sh"
         matcher: "write_file|patch|apply_patch"
         timeout: 10
         fail_closed: true
   ```
3. validar com `hermes -p <perfil> hooks list` (tem de listar o hook) e
   `hermes -p <perfil> hooks doctor` (se existir). Se a validação falhar, restaurar o
   backup e reportar — não deixar config quebrado.
4. **Não reiniciar** o Hermes. Escrever no relatório: vale na próxima sessão do perfil.

### 3. `scripts/testes/test_guard_code.sh`

Payloads sintéticos, sem tocar em perfil:

| Caso | Esperado |
|---|---|
| `write_file` em `x.py` | **block** |
| `write_file` em `DOCS/x.md` | passa |
| `patch` em `scripts/medir-cdp.py` | **block** |
| `patch` em `briefs/x.md` | passa |
| `write_file` em `C:\Users\...\profiles\ctm-p06\SOUL.md` | passa (`.md`) |
| `terminal` `echo x > x.py` | **block** |
| `terminal` `python scripts/verificar.py` | passa |
| JSON inválido | passa (exit 0) |

Saída PASS/FAIL e exit 0 só se tudo passar.

## Proibido tocar

`AGENTS.md`, `SOUL.md`, `Definições Oficiais Manuais/`, `DOCS/`, `briefs/`, o código dos
projetos. Nada de `git add -A`. Nada de editar `config.yaml` fora do instalador.

## Critério de aceite (o Gerente mede)

1. `bash scripts/testes/test_guard_code.sh` → todos PASS.
2. `hermes -p ctm-p06 hooks list` e `hermes -p jessica-p03 hooks list` listam o hook;
   `hooks doctor` sem erro; backups existem.
3. `echo '{"hook_event_name":"pre_tool_call","tool_name":"patch","tool_input":{"path":"C:/x.py"}}' | bash scripts/guard-code.sh` → JSON `block`.
4. O mesmo com `path` `DOCS/x.md` → sem saída, exit 0.
5. Commit `OPENCODE-WORKSPACE` com os 3 arquivos e mais nada.

## Retorno

`RESULTADO / status / arquivos_alterados / comandos_executados / evidencia / nao_testado /
riscos / proximo_passo`.
