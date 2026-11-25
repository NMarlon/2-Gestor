# Brief T-P05-011 — P-05: corrigir a repetição do autostart (tarefa não dispara sozinha)

Projeto: `C:\MarlonScripts\5-Painel-Hermes`
Executor: OpenCode — **um escritor**, um repositório.
Origem: medição do gestor sobre T-P05-009 (brief `2026-11-25-p05-t009-autostart-painel.md`).
Data: 2026-11-25.

## ESCOPO ÚNICO

Fazer a tarefa `PainelHermes-Painel` **disparar sozinha a cada N minutos**, sem
logon e sem `Start-ScheduledTask`, para o painel voltar depois de uma queda.

Correção pontual em `scripts/instalar-painel-auto.ps1` (+ prova). Nada mais.

## FATO MEDIDO PELO GESTOR (não re-investigue)

O que o brief anterior pedia não está funcionando. Medido agora, na máquina:

1. `Get-ScheduledTask -TaskName 'PainelHermes-Painel'` → `State: Ready`, gatilho
   `MSFT_TaskLogonTrigger` com `Delay PT30S` e `Repetition.Interval PT5M`.
2. `Get-ScheduledTaskInfo` → `LastRunTime: 30/11/1999 00:00:00`,
   `LastTaskResult: 267011` (0x41303 = "nunca executou"), **`NextRunTime` vazio**.
3. Teste real: matei o painel (PID 13348, era o `LISTENING` da 8787), esperei
   **6 minutos** em poll de 15 s, `http=000` nas 24 leituras. **A tarefa não disparou.**
   O log `logs/painel-auto.log` não ganhou linha nenhuma nesse período.
4. Conclusão: repetição de gatilho **AtLogOn** fica ancorada no evento de logon, que
   não aconteceu desde o registro — logo não há próxima execução. A tarefa hoje só
   roda em logon (não testado) ou em disparo manual (`Start-ScheduledTask`), que foi
   o que o teste anterior provou. Isso não cobre "painel cai e volta".
5. Estado agora: painel **de pé** (PID 23592, `http=200`), subido pelo supervisor
   `scripts/garantir_painel.py` (funciona: `exit=0`, log `inicio pid=23592 ok=sim`).
   O supervisor **não** é o problema; o gatilho é.

## O QUE FAZER

### A. `scripts/instalar-painel-auto.ps1`

1. Manter o gatilho **AtLogOn** (com atraso de 30 s) — cobre o boot.
2. **Acrescentar um segundo gatilho ancorado no relógio**, com repetição a cada
   `-IntervaloMinutos` (padrão 5), por duração indefinida. Formas aceitáveis, em
   ordem de preferência:
   - `New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes $n) -RepetitionDuration ([TimeSpan]::MaxValue)`;
   - se `MaxValue` for recusado, `-RepetitionDuration ([TimeSpan]::FromDays(3650))`;
   - em último caso, registrar via `schtasks /Create /SC MINUTE /MO $n` (ou XML) e
     provar que os dois gatilhos convivem.
3. **Portão de verificação dentro do instalador**: depois de registrar, ler
   `Get-ScheduledTaskInfo` e **falhar com `exit 5` e mensagem clara** se
   `NextRunTime` estiver vazio ou se ficar a mais de `2 × IntervaloMinutos` no futuro.
   O instalador não pode terminar "sucesso" com a tarefa que nunca vai rodar — foi
   exatamente esse o furo.
4. Idempotente: rodar duas vezes não duplica tarefa nem gatilho.
5. `-Remover` continua removendo a tarefa inteira.
6. Imprimir, ao final: nome, `State`, os dois gatilhos (tipo, atraso, intervalo,
   duração) e `NextRunTime`.

### B. Prova (o ponto central)

Não vale `Start-ScheduledTask` como prova. O aceite é **esperar o relógio**.

1. Instalar com `-IUnderstand`.
2. Anotar o PID do painel que está no `LISTENING` da 8787 e matá-lo.
3. **Sem tocar em nada**, esperar até `2 × IntervaloMinutos + 60 s`, com poll de 15 s
   em `curl --max-time 3 http://127.0.0.1:8787/`.
4. Provar que voltou: `http=200`, PID novo no `netstat`, linha nova em
   `logs/painel-auto.log` com `inicio pid=... ok=sim`, e `Get-ScheduledTaskInfo`
   com `LastRunTime` de hoje e `LastTaskResult: 0`.

### C. Documentação

- `DOCS/02-ARQUITETURA.md`: corrigir a seção "Autostart do painel" — dois gatilhos
  (logon + relógio), intervalo, e a ressalva de que a tarefa é `InteractiveToken`
  (não roda com o usuário deslogado).
- `DOCS/04-TAREFAS.md`: atualizar T-P05-009/T-P05-011 com o que foi medido.

## PROIBIDO

- Abrir navegador de qualquer forma (nada de `Start-Process` de URL, nada de script
  CDP próprio, nada de `msedge`/`chrome`/`firefox`).
- Criar serviço do Windows ou tarefa com senha armazenada.
- Mexer em `PainelHermes-Coletor`, `coletor.py`, `painel.py`, `garantir_painel.py`
  (o supervisor está correto; se precisar de um ajuste mínimo, justifique).
- `taskkill /IM python*.exe` ou matar processo que não seja o `pythonw.exe` do painel.
- Porta 8787, host, rotas: intocados.
- Tocar em arquivo fora de `C:\MarlonScripts\5-Painel-Hermes`.

## CRITÉRIO DE ACEITE (verificável, o gestor refaz)

1. `Get-ScheduledTask` mostra **dois** gatilhos: `MSFT_TaskLogonTrigger` (Delay 30 s)
   e um gatilho de tempo com `Repetition.Interval = PT5M`. Cole a saída.
2. `Get-ScheduledTaskInfo` com `NextRunTime` preenchido (hoje, ≤ 10 min). Cole.
3. Teste do relógio: painel morto → volta sozinho em ≤ 6 min, com `http=200`, PID novo,
   linha `inicio pid=... ok=sim` no log e `LastTaskResult: 0`. Cole o poll com os
   horários e o `netstat` antes/depois.
4. Instalador roda duas vezes sem duplicar; `-Remover` remove; reinstalar deixa tudo
   de pé de novo.
5. Nenhum processo de navegador novo (`Get-Process msedge,chrome,firefox` inalterado).
6. Commit no repo do projeto:
   `T-P05-011: repetição por relógio no autostart (portão de NextRunTime + prova real)`.

## CONTRATO DE RETORNO

- **RESULTADO** — em 3 linhas.
- **status** — `ENTREGUE` | `PARCIAL` | `BLOQUEADO`.
- **arquivos_alterados** — caminho e o que mudou.
- **comandos_executados** — reais, com saída.
- **evidencia** — itens 1 a 5 do aceite, cada um com a saída colada, incluindo o poll
  de até 6 min com os horários.
- **nao_testado** — o que não rodou, e por quê.
- **riscos** — inclusive o que acontece com o usuário deslogado.
- **proximo_passo** — sugestão.

Não invente saída. Falhou, cole o erro real e marque `PARCIAL`/`BLOQUEADO`.
