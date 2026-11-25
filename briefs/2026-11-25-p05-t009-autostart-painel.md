# Brief T-P05-009 — P-05: autostart do painel (127.0.0.1:8787 de pé sozinho)

Projeto: `C:\MarlonScripts\5-Painel-Hermes`
Executor: OpenCode — **um escritor**, um repositório.
Origem: item 3 da M-015 do Gerente (`DOCS/08-GERENTE/PARA-GESTORES.md`).
Data: 2026-11-25.

## ESCOPO ÚNICO

Garantir que `http://127.0.0.1:8787/` volte sozinho depois de logon e depois de
queda do processo, **sem abrir janela de navegador e sem console visível**.

Nada além disso. Não mexer no coletor, não mexer na cota oficial (T-P05-010, já
entregue), não mexer no layout.

## CONTEXTO JÁ VERIFICADO PELO GESTOR (não re-investigue)

1. O painel é `scripts/painel.py`: sobe em `127.0.0.1:8787`, `allow_reuse_address =
   False` (porta ocupada falha em vez de sequestrar), serve GET/HEAD 200, resto 404,
   POST 405. Hoje está no ar por `pythonw.exe` (PID 14312), iniciado à mão.
2. `pythonw.exe` existe em `C:\Users\Marlon\AppData\Local\Programs\Python\Python311\pythonw.exe`
   — é o que roda sem console. O `painel.py` já tolera stdout/stderr nulos (T-P05-010).
3. Já existe um agendador em produção neste projeto, criado por
   `scripts/instalar-agendador.ps1`: tarefa `PainelHermes-Coletor`, a cada 15 min,
   rodando o coletor. **Use-o como modelo de estilo e de parâmetros** (mesmo padrão
   `-IUnderstand`, `-Remover`, `-WorkingDirectory`, tratamento de erro), mas **não
   altere a tarefa do coletor**.
4. `logs/` existe e é gitignored. `dados/` é gitignored.
5. Medido agora: `curl http://127.0.0.1:8787/` → 200; `netstat` mostra
   `127.0.0.1:8787 LISTENING`; `%TEMP%\jhw-cdp-contador.json` já registra lançamentos
   de navegador desta hora (teto de 30/hora na ferramenta única do workspace).

## O QUE FAZER

### A. `scripts/garantir_painel.py` — supervisor idempotente (biblioteca padrão só)

- Faz `GET http://127.0.0.1:8787/` com timeout de 3 s.
  - Se responder **200** → escreve uma linha em `logs/painel-auto.log`
    (`<ISO> ja de pe`) e sai com código 0. **Não inicia segundo processo.**
- Se não responder:
  - toma uma trava `logs/painel-auto.lock` com criação exclusiva (`O_EXCL`); trava com
    mais de 120 s é considerada órfã e pode ser substituída;
  - sobe `pythonw.exe scripts/painel.py` com `cwd` = raiz do projeto,
    `CREATE_NO_WINDOW | DETACHED_PROCESS`, `stdout`/`stderr` em `logs/painel-auto.out.log`;
  - espera até 20 s por um `GET /` que devolva 200;
  - registra `<ISO> inicio pid=<pid> ok=<sim|nao> motivo=<...>` em `logs/painel-auto.log`;
    libera a trava no `finally`.
- Códigos de saída: `0` = painel de pé (já estava ou subiu), `1` = tentou e não subiu.
- Nunca abre navegador, nunca chama URL no navegador, nunca escreve em `dados/`.

### B. `scripts/instalar-painel-auto.ps1` — instalador/removedor da tarefa

- Parâmetros: `-IUnderstand` (obrigatório para instalar), `-IntervaloMinutos` (padrão 5,
  mínimo 1), `-Remover`, `-WorkingDirectory` (padrão: a raiz do projeto, resolvida a
  partir do `$PSScriptRoot`).
- Tarefa: nome **`PainelHermes-Painel`**, no usuário atual.
  - Gatilho: **AtLogOn** do usuário atual, com atraso de 30 s, **mais repetição a cada
    `-IntervaloMinutos`, por tempo indeterminado**.
  - Ação: `pythonw.exe` com argumento `scripts\garantir_painel.py`, diretório de
    trabalho = raiz do projeto, **sem janela** (tarefa `Hidden`, ação sem console).
  - Configurações: `MultipleInstances = IgnoreNew`, `ExecutionTimeLimit = 5 min`,
    `StartWhenAvailable`, não parar em bateria, não iniciar só com AC.
  - Nunca `Start-Process` com URL. Nenhum navegador é citado no script.
- `-Remover`: `Unregister-ScheduledTask -TaskName 'PainelHermes-Painel' -Confirm:$false`
  e informa se removeu.
- Ao instalar, imprime o resultado de `Get-ScheduledTask -TaskName 'PainelHermes-Painel'`
  (State, trigger, action) — prova de que ficou registrada.
- Idempotente: rodar duas vezes não cria tarefa duplicada (remove/recria a de mesmo nome).

### C. Documentação

- `DOCS/02-ARQUITETURA.md`: seção curta "Autostart do painel" com nome da tarefa,
  intervalo, como remover (`-Remover`) e onde ficam os logs.
- `DOCS/04-TAREFAS.md`: entrada T-P05-009 com entrega e verificação.

## PROIBIDO

- Abrir navegador de qualquer forma: nada de `Start-Process` de URL, nada de script
  CDP próprio, nada de `msedge`/`chrome`/`firefox` no script. Medição de tela é do
  gestor, com a ferramenta única do workspace.
- Criar serviço do Windows (`New-Service`, `sc create`), cron do Hermes, ou tarefa com
  senha armazenada.
- Alterar `PainelHermes-Coletor`, `coletor.py`, `painel.py` (só se um bug real
  impedir o autostart — nesse caso, justifique no retorno).
- Mexer na porta 8787 ou fazer o painel escolher outra porta.
- Matar processo que não seja o do painel (`pythonw.exe ... painel.py`). Nunca
  `taskkill /IM python*.exe`.
- Tocar em arquivo fora de `C:\MarlonScripts\5-Painel-Hermes`.

## CRITÉRIO DE ACEITE (verificável, o gestor refaz)

1. `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\instalar-painel-auto.ps1 -IUnderstand`
   termina sem erro e `Get-ScheduledTask -TaskName 'PainelHermes-Painel'` mostra a
   tarefa com gatilho AtLogOn + repetição e ação `pythonw.exe ... garantir_painel.py`.
   Cole a saída.
2. Com o painel já no ar, rodar `python scripts\garantir_painel.py` → sai `0`, escreve
   `ja de pe` no log e **não** cria segundo processo (contagem de `pythonw.exe` antes
   e depois é a mesma; cole os dois números).
3. Matar só o painel (`Stop-Process -Id <pid do painel>`), disparar a tarefa como o
   Agendador faria (`Start-ScheduledTask -TaskName 'PainelHermes-Painel'`) e, em até
   30 s, `curl http://127.0.0.1:8787/` → 200. Cole o log com `inicio pid=... ok=sim`.
4. `Get-Content logs\painel-auto.log` mostra as linhas das três verificações.
5. Nenhum navegador aberto pela tarefa: `Get-Process msedge -ErrorAction SilentlyContinue`
   não ganha processo novo depois de rodar a tarefa.
6. Commit no repo do projeto, assinado pelo executor:
   `T-P05-009: autostart do painel via Agendador (supervisor + instalador, sem navegador)`.

## CONTRATO DE RETORNO

- **RESULTADO** — em 3 linhas, o que passou a existir.
- **status** — `ENTREGUE` | `PARCIAL` | `BLOQUEADO`.
- **arquivos_alterados** — caminho e o que mudou.
- **comandos_executados** — reais, com a saída relevante colada.
- **evidencia** — item 1, 2, 3, 4 e 5 do aceite, cada um com a saída.
- **nao_testado** — o que não rodou, e por quê.
- **riscos** — o que pode quebrar (ex.: tarefa em sessão errada, pythonw sem PATH).
- **proximo_passo** — sugestão.

Não invente saída. Falhou, cole o erro real e marque `PARCIAL`/`BLOQUEADO`.
