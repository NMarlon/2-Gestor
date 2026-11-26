# Brief — 2-Gestor · commit-agent v2.1 · correção do lease e do T6

**Data:** 2026-11-26 · **Executor:** OpenCode · **Repo:** `C:\MarlonScripts\2-Gestor`
**Autor:** GERENTE · **Origem:** medição do v2 (`b50f37e`): 11 PASS, 1 FAIL.

## Contexto já verificado (não re-investigue)

- `scripts/commit-agent.sh` v2 passou em T2, T3, T4 (40/40), T5, T7a, T8, T9.
- **T6 falhou** com duas causas medidas:
  1. **Bug de portabilidade:** `stat -c %Y -- "$lock"` no MSYS/Git-bash devolve o relatório
     inteiro (`File: … ID: … Namelen: …`) em vez do epoch. A linha `[ "$mtime" -gt 0 ]`
     recebe texto e imprime `integer expected`; o lease de lock órfão não funciona.
  2. **Teto apertado:** 4 commits concorrentes levaram **6.996 ms** com a máquina carregada
     (dois executores rodando). O requisito real é serializar sem deadlock, não 5 s.
- O refresh do índice compartilhado (`atualizar_indice_compartilhado`) foi **aceito**: está
  seguro — `read-tree` só quando o índice está limpo; com stage alheio, mexe só nos caminhos
  nomeados.

## Escopo único

1. **Corrigir o mtime do lock** em `scripts/commit-agent.sh`:
   - usar `date -r <lock> +%s` (GNU) e, se falhar, `stat -c %Y` / `stat -f %m`;
   - **validar que o resultado é numérico** (`case "$mtime" in ''|*[!0-9]*) mtime=0;; esac`);
   - nunca deixar saída multilinha chegar ao `[`.
2. **Ajustar o T6** em `scripts/testes/test_commit_agent.sh`: teto de **15.000 ms** (máquina
   com múltiplos agentes); continuar exigindo `total_commits=5` e 4 commits válidos. Registrar
   o tempo medido na saída.
3. **Re-rodar a suíte inteira** e commitar com o próprio v2, assinatura
   `OPENCODE-WORKSPACE <opencode-workspace@2gestor.local>`, só os 2 arquivos.

## Proibido

Tocar em `DOCS/`, `briefs/`, `AGENTS.md`, hooks, `oc-brief.ps1`, repos de projeto. `git add -A`
ou `commit -a`. Alterar o comportamento de partição de arquivos ou o refresh do índice.

## Critério de aceite (o Gerente mede)

1. `bash scripts/testes/test_commit_agent.sh` → **12 PASS, 0 FAIL**, exit 0.
2. T6 sem a mensagem `integer expected` em nenhum log.
3. `bash -n scripts/commit-agent.sh` → exit 0.
4. Commit `OPENCODE-WORKSPACE` com exatamente `scripts/commit-agent.sh` e
   `scripts/testes/test_commit_agent.sh`.

## Retorno

`RESULTADO / status / arquivos_alterados / comandos_executados / evidencia / nao_testado /
riscos / proximo_passo`.
