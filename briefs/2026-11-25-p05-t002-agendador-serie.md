# Brief T-P05-002 — P-05 Painel Hermes: agendador do Windows (a série se preenche sozinha)

**Data:** 2026-11-25
**Projeto:** P-05 · Painel Hermes — `C:\MarlonScripts\5-Painel-Hermes`
**Executor:** OpenCode, um escritor por vez, via `scripts/oc-brief.ps1`
**Gestor:** perfil `p05-painel`
**Origem da ordem:** mensagem M-005 do Gerente (`2-Gestor\DOCS\08-GERENTE\PARA-GESTORES.md`), em nome do Marlon.
Essa mensagem é o **pedido explícito** que o `AGENTS.md` do repo exige para instalar o agendador.
Ela também muda o escopo: **T-P05-002 é o agendador, não a UI**. UI passa a T-P05-003.

## Escopo único

`scripts/instalar-agendador.ps1` passa a registrar de verdade a coleta periódica, com diretório de
trabalho explícito, intervalo validado e o desfazer escrito em `DOCS/` do repo. Nada além disso:
**não** escreva UI, **não** altere `scripts/coletor.py`.

## CONTEXTO JÁ VERIFICADO (não re-investigue, não repita a descoberta)

- Coletor entregue e medido: `python scripts/coletor.py` sai 0 em ~3,6 s; 8 amostras em
  `dados/stats.jsonl` (45.044 B), última `2026-11-24T21:29:13-03:00`. Só stdlib.
- Python que roda o coletor: `C:\Users\Marlon\AppData\Local\Programs\Python\Python311\python.exe`
  (3.11.9), medido agora. O PATH do bash **não é** o da tarefa agendada — use caminho absoluto.
- Tarefa `PainelHermes-Coletor` **não existe** (`schtasks /query /tn` → “O sistema não pode encontrar
  o arquivo especificado”).
- Sessão **não elevada** (`net session` falha). `Register-ScheduledTask` com
  `New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType S4U -RunLevel Limited` devolve
  **“Acesso negado”** — medido em 25/11 01:05, com tarefa-sonda já removida.
  Sem `-Principal`, registra e o `schtasks /query /v` mostra **“Modo de Logon: Interativo apenas”**.
- Conclusão que o script tem de respeitar: **cobertura com o usuário deslogado é impossível sem
  elevação**. Tentar S4U, cair para interativo e **dizer o modo obtido** — nunca afirmar cobertura de
  logoff no modo interativo.
- `dados/stats.jsonl` hoje tem 8 linhas. Não rode o coletor à mão: o gestor usa a contagem antes/depois
  como prova de que foi a tarefa que gravou.

## O que o script tem de fazer

1. **Manter a guarda `-IUnderstand`.** Sem ela: imprimir a ação completa (comando, diretório, intervalo,
   usuário) e `exit 1`, sem registrar nada.
2. **`-IntervaloMinutos`**: aceitar só **5 a 15**, padrão **15**. Fora da faixa: mensagem clara e
   `exit 2`, sem registrar.
3. **Ação**: python **absoluto** (resolva com `(Get-Command python).Source`, imprima o caminho e a
   versão) + `“<repo>\scripts\coletor.py”`, com `-WorkingDirectory <repo>`.
4. **Principal**: tentar `-LogonType S4U -RunLevel Limited`; se a mensagem for “Acesso negado”
   (ou equivalente `Access is denied`), registrar com `-LogonType Interactive` e imprimir
   `MODO=INTERATIVO` mais o aviso: *“não roda com o usuário deslogado; para isso é preciso registrar
   elevado com -LogonType S4U”*. Qualquer outro erro: **pare** e reporte, não invente fallback.
5. **Settings**: `-MultipleInstances IgnoreNew`,
   `-ExecutionTimeLimit (New-TimeSpan -Minutes 5)`, `-AllowStartIfOnBatteries`,
   `-DontStopIfGoingOnBatteries`, `-StartWhenAvailable`, `-WakeToRun`.
6. **Gatilho**: `-Once` em `agora + 1 min`, repetição a cada `-IntervaloMinutos` por 3650 dias (manter).
7. **Depois de registrar, imprimir a prova** (o gestor vai conferir o mesmo):
   `Get-ScheduledTask -TaskName <nome> | Select State, @{n='Logon';e={$_.Principal.LogonType}}`
   e `schtasks /query /tn <nome> /v /fo LIST` filtrado em
   `Status|Modo de Logon|Tarefa a ser executada|Executar como|Próxima hora|Última hora`.
   Se a tarefa não aparecer, `exit 3` — registro que não aparece não é registro.
8. **`-Remover`** desregistra e confirma; sem a tarefa, avise e saia 0.
9. Códigos de saída: `0` instalado/removido, `1` sem `-IUnderstand`, `2` intervalo inválido,
   `3` registro não visível.

## DOCS do repo (parte da entrega, não é opcional)

- `DOCS/04-TAREFAS.md`: **T-P05-002 = agendador** (nome da tarefa, intervalo, modo de logon obtido,
  estado). Renumerar: **UI → T-P05-003**, **relatório semanal → T-P05-004**. No bloco da T-P05-002,
  o desfazer em duas linhas:
  `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\instalar-agendador.ps1 -IUnderstand -Remover`
  e `Unregister-ScheduledTask -TaskName PainelHermes-Coletor -Confirm:$false`.
- `DOCS/02-ARQUITETURA.md`: seção curta **“Agendador (Windows)”** — nome da tarefa, intervalo, comando,
  modo de logon, a limitação do modo interativo, e como remover.
- `AGENTS.md`: a regra hoje diz que o agendador não é instalado sem pedido. Atualize para:
  instalado em 25/11 por ordem M-005 (T-P05-002), continua proibido **cron do Hermes** e qualquer
  agendador novo sem pedido escrito do Marlon.

## Proibido tocar

`scripts/coletor.py`, `dados/`, `logs/` (só o que o coletor gravar), `.env`, `auth.json`,
`opencode.db`, banco Hermes. Sem `pip install`, sem serviço do Windows, sem cron do Hermes, sem
porta pública, sem `git remote`/`push`, sem `git add -A`/`git add .`/`commit -a`.
Nenhum segredo em log, print ou commit.

## Critério de aceite (o gestor mede, não vale relatório)

1. `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\instalar-agendador.ps1` → `exit 1`,
   imprime a ação, **não** registra.
2. `... -IUnderstand -IntervaloMinutos 3` → `exit 2`, mensagem de faixa.
3. `... -IUnderstand` → `exit 0`; `schtasks /query /tn PainelHermes-Coletor /v /fo LIST` mostra a tarefa,
   “Executar como Usuário: Marlon”, a ação com python absoluto + `coletor.py`, e o modo de logon real.
4. `... -IUnderstand -Remover` → tarefa some; reinstalar em seguida (estado final: **instalada**).
5. `git status` limpo no repo, 1 commit `P05-EXECUTOR <p05@2gestor.local>` com caminhos explícitos.

Sequência obrigatória: (1) → (2) → (3) → (4 remover) → (3 reinstalar). Cole as saídas no relatório.

## Contrato de retorno

`RESULTADO / status / arquivos_alterados / comandos_executados / evidencia / nao_testado / riscos / proximo_passo`
— com a saída literal do `schtasks` e o `MODO=` impresso pelo script. Se algo do critério não passar,
diga qual e com que mensagem; não maquie.
