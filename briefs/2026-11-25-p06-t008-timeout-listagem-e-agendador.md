# T-P06-008 · timeout de listagem com retentativa (código 2) + `scripts/agendar.ps1` provado com `-WhatIf`

**Projeto:** P-06 — Alerta de Planejamento Missionário (CTM)
**Repo:** `C:\MarlonScripts\81 - Alerta Planejamento Missionario CTM`
**Data:** 2026-11-25
**Origem:** M-019 do Gerente, itens 1 e 2
**Executor:** OpenCode (`OPENCODE-P06`)

## Escopo único

- **A.** A listagem da pasta deixa de confundir "não consegui listar" com "não mudou":
  timeout de **60 s**, **1 retentativa com 3 s de espera**, e **código de saída 2**.
- **B.** Entregar `scripts\agendar.ps1`, que **cria/atualiza** a tarefa semanal e roda com
  `-WhatIf` — **sem instalar a tarefa**.

Nada além disso. Não é para reescrever o motor, não é para mexer no download, no diff, no
histórico nem no HTML.

## CONTEXTO JÁ VERIFICADO (não re-investigue)

Medido pelo gestor em 25/11/2026, com o código como está em `79117cc`:

1. `scripts\verificar.py`: `TIMEOUT = 30` na **linha 47**, usado só em `_baixar()` (linha 172),
   que serve tanto para listagem quanto para download. `listar_arquivos()` está nas linhas
   180-201; `escolher_arquivo()` nas 204-222; `main()` captura `(FalhaVerificacao, ErroExtracao)`
   e devolve **1** (linhas 956-958).
2. Execução real hoje: **exit 1** em 3,5 s, com a recusa do Google por extenso (a `Q-040`
   continua aberta; isso não muda).
3. Listagem com `pasta_id` inexistente hoje: `ERRO: listagem respondeu HTTP 404: …` e
   **exit 1** — hoje é indistinguível do resto. Depois desta tarefa tem de sair **2**.
4. O `.gitignore` já ignora `testes/`, `dados/*.pdf`, `dados/snapshots/`, `logs/`,
   `historico-local.json`. Use `testes\` para o config de prova e `logs\` para log do agendador.
5. `historico.json` está em `[]` (2 bytes) e **não pode mudar**. `historico-local.json` existe
   com 1 leitura de teste.
6. Python: `C:\Users\Marlon\AppData\Local\Programs\Python\Python311\python.exe` (o `python` do
   PATH já resolve para ele). `pymupdf` 2.1. PowerShell da máquina é o **5.1** (`powershell.exe`);
   não conte com `pwsh`.
7. A numeração de tarefa do workspace segue `T-P06-NNN`; esta é a **T-P06-008**.

## A. Listagem: 60 s, 1 retentativa, código 2

Decisão do gestor, para você não decidir no meio do caminho:

1. `TIMEOUT = 60` (constante única, serve para listagem e download; o PDF tem 1 página e o
   download termina em menos de 1 s, então 60 s não atrapalha).
2. Constantes novas, junto das outras: `LISTAGEM_TENTATIVAS = 2` e `LISTAGEM_ESPERA = 3`.
3. Exceção própria `FalhaListagem(FalhaVerificacao)` com docstring curta dizendo que é
   "não consegui obter o arquivo da pasta" e que **sai 2, nunca 0**.
4. `listar_arquivos()` faz o laço: tenta até 2 vezes; entre as tentativas **imprime na stderr**
   uma linha dizendo qual tentativa falhou, o motivo e que vai repetir em 3 s; dorme de fato 3 s
   (`time.sleep`). Esgotadas as tentativas, levanta `FalhaListagem` com a frase literal
   **"não consegui listar"**, a URL, o número de tentativas e o motivo da última.
5. Também sobem como `FalhaListagem` (e portanto saem 2) os dois casos em que a listagem
   tecnicamente respondeu mas não deu arquivo para vigiar:
   - lista vazia / página sem entradas (hoje "listagem sem arquivos");
   - nenhum nome casando com `padrao_nome` (hoje "nenhum arquivo casou com o padrão").
   Motivo: nos dois a resposta correta é "não consegui obter o planejamento", nunca
   "sem alterações". `baixar_pdf()` **não** muda: recusa do Google continua **exit 1**.
6. `main()`: capturar `FalhaListagem` **antes** de `FalhaVerificacao` e devolver **2**;
   `(FalhaVerificacao, ErroExtracao)` continua devolvendo **1**. Não use `sys.exit` espalhado.
7. `--dry-run` não muda de comportamento em nada além disso: continua sem gravar nada.

Formato da mensagem final (o texto exato é seu, desde que cumpra): começa com
`ERRO: não consegui listar a pasta (2 tentativas, 60 s cada, 3 s entre elas): <motivo>` e
mostra a URL. Ela **não pode** conter a palavra "sem mudanças".

## B. `scripts\agendar.ps1` — cria/atualiza, não instala

O arquivo não existe. Requisitos:

1. **Grave o arquivo em UTF-8 com BOM.** O PowerShell 5.1 lê `.ps1` sem BOM como ANSI e os
   acentos quebram. (Alternativa aceita: script 100% ASCII.)
2. `[CmdletBinding(SupportsShouldProcess = $true)]` para o `-WhatIf` ser nativo.
3. Parâmetros:
   - `-Tarefa` (default `P06-Planejamento-Missionario`)
   - `-Dia` (ValidateSet dos nomes em inglês aceitos pelo cmdlet: `Monday`…`Sunday`; default `Monday`)
   - `-Hora` (ValidatePattern `^([01]\d|2[0-3]):[0-5]\d$`; default `08:00`)
   - `-Python` (default `C:\Users\Marlon\AppData\Local\Programs\Python\Python311\python.exe`)
   - `-Repo` (default: pasta-pai de `$PSScriptRoot`)
   - `-LimiteMinutos` (default 30)
   - `-Executar` (switch: modo "sou o trabalho agendado")
   - `-Remover` (switch: desregistra a tarefa, também sob `ShouldProcess`)
4. **Modo padrão (registrar/atualizar):**
   - ação = `powershell.exe` com
     `-NoProfile -ExecutionPolicy Bypass -File "<Repo>\scripts\agendar.ps1" -Executar -Repo "<Repo>"`
     e `-WorkingDirectory $Repo`;
   - gatilho = `New-ScheduledTaskTrigger -Weekly -DaysOfWeek $Dia -At $Hora`;
   - configurações = `-StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes $LimiteMinutos)
     -MultipleInstances IgnoreNew -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries`;
   - principal = usuário atual, `-LogonType Interactive -RunLevel Limited` (sem senha, sem admin);
   - **antes** de registrar, imprima um bloco `PLANO:` com tarefa, dia, hora, ação completa e
     `WorkingDirectory`; depois passe pelo `ShouldProcess($Tarefa, "registrar tarefa semanal")`;
   - `Register-ScheduledTask … -Force` (cria **ou atualiza**, idempotente).
   - No fim, imprima como conferir (`schtasks /Query /TN "<Tarefa>"`) e como remover
     (`powershell -File <este script> -Remover`).
5. **Modo `-Executar`** (é o que a tarefa chama toda semana):
   - roda `<Python> "<Repo>\scripts\verificar.py"` capturando stdout, stderr e a duração;
   - **anexa** uma linha em `<Repo>\logs\agendador-AAAAMM.txt` (UTF-8, cria a pasta se faltar)
     com data/hora local `yyyy-MM-dd HH:mm:ss`, `exit=`, duração em segundos e a última linha
     de stdout;
   - **mapeia o código:** `0` e `10` → sai **0** (sem mudança e mudou são sucesso);
     `1` e `2` → sai **1** e **2** respectivamente; outros → repassa. Motivo: no Agendador,
     código diferente de 0 é tarefa em falha, e é assim que o erro fica visível em vez de
     treinar o Marlon a ignorar. O stdout do `verificar.py` continua indo para o console/log.
   - `-Executar` e `-Remover` juntos: erro de parâmetro. `-WhatIf` com `-Executar`: apenas
     imprime o comando e não roda.
6. Sem caminho relativo solto: tudo derivado de `-Repo`/`$PSScriptRoot`. Sem `cmd /c start`,
   sem `Start-Process` de URL. O script **não** instala nada quando recebe `-WhatIf`.

## Proibições

- **Não crie a tarefa de verdade.** `Q-040` continua aberta; tarefa que falha toda semana é
  ruído. Só `-WhatIf`.
- **Não** mexa em `historico.json`, `historico-local.json`, snapshots, diff, limiar, HTML,
  `medir-cdp.py`.
- **Não** tente contornar a `Q-040` (nada de OCR, `gdown`, cookie, preview PNG). A execução
  real tem de continuar saindo **1** com a recusa do Google.
- **Não** escreva em `C:\MarlonScripts\2-Gestor\` — brief e DOCS do workspace são meus.
- **Não** crie arquivo versionado fora do repo; o config de prova vai em `testes\` (ignorado).

## Critério de aceite (eu meço depois; você mede antes e cola os números)

Rode de `C:\MarlonScripts\81 - Alerta Planejamento Missionario CTM`.

### A — código 2 e retentativa

Config de prova (crie em `testes\config-pasta-inexistente.json`, é ignorado pelo git):

```json
{
  "pasta_id": "1PastaQueNaoExiste0000000000000000000000",
  "padrao_nome": "POR(\\d+(?:\\.\\d+)*)\\.pdf",
  "pasta_dados": "dados",
  "pasta_relatorios": "relatorios",
  "limiar_similaridade": 0.6
}
```

```bash
md5sum historico.json                                  # anote: tem de continuar igual até o fim
python scripts/verificar.py --config testes/config-pasta-inexistente.json; echo "exit=$?"
#   esperado: 2 · a stderr mostra a tentativa 1 falhando e a retentativa; a mensagem final
#   contém "não consegui listar" e a URL; o comando leva ~3 s a mais por causa da espera
python scripts/verificar.py; echo "exit=$?"             # esperado: 1 (recusa do Google), inalterado
python scripts/verificar.py --dry-run --fonte local --antes testes/v1.pdf --depois testes/v2.pdf; echo "exit=$?"
#   esperado: 10 e NADA gravado (nem relatorio, nem historico-local)
rm -f historico-local.json
python scripts/verificar.py --fonte local --antes testes/v1.pdf --depois testes/v2.pdf; echo "exit=$?"   # 10
python scripts/verificar.py --fonte local --antes testes/v1.pdf --depois testes/v2.pdf; echo "exit=$?"   # 0
md5sum historico.json                                  # TEM de ser igual ao anotado
grep -n "TIMEOUT = 60\|LISTAGEM_TENTATIVAS\|LISTAGEM_ESPERA\|FalhaListagem" scripts/verificar.py
```

Cole a saída inteira dos comandos com `exit=`. Tempo de parede do teste com pasta inexistente:
informe (tem de ser ≥ 3 s).

### B — `agendar.ps1` com `-WhatIf`, sem instalar

```bash
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/agendar.ps1 -WhatIf; echo "exit=$?"
#   esperado: 0 · imprime PLANO com tarefa, Monday, 08:00, a ação completa e o WorkingDirectory
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/agendar.ps1 -WhatIf -Dia Friday -Hora 19:30; echo "exit=$?"
#   esperado: 0 · o PLANO mostra Friday e 19:30
schtasks /Query /TN "P06-Planejamento-Missionario" ; echo "exit=$?"
#   esperado: erro "não é possível encontrar" / exit != 0 — prova de que NADA foi instalado
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/agendar.ps1 -Executar; echo "exit=$?"
#   esperado: roda o verificar.py real (exit interno 1), mapeia para 1, e ANEXA uma linha
#   em logs/agendador-AAAAMM.txt com data, exit=1 e duração
ls -l logs/ ; cat logs/agendador-*.txt
```

Anexe também a saída de `powershell -NoProfile -Command "$PSVersionTable.PSVersion.ToString()"`
para registrar a versão usada.

## Docs do repo (parte da entrega)

- `README.md`: tabela "Códigos de saída" ganha a linha **2** — "não consegui listar a pasta
  (rede, HTTP, pasta vazia ou nenhum PDF no padrão) — **não** é 'sem mudanças'". Acrescente o
  comando do agendador (`-WhatIf` e a ressalva de que a instalação espera a Q-040).
- `DOCS\02-ARQUITETURA.md`: linha 50 passa a `0 / 10 / 1 / 2`; no passo [1] do fluxo,
  registre "timeout 60 s, 1 retentativa de 3 s, falha → 2".
- Docstring de `scripts\verificar.py`: incluir o 2.
- `DOCS\03-TAREFAS.md`: linha da **T-P06-008** concluída com o resultado medido; a linha da
  **T-P06-004** passa a dizer "script entregue (T-P06-008); instalação bloqueada pela Q-040".

## Commit

Um commit no repo do projeto, assinatura própria de executor, caminhos explícitos:

```bash
git add scripts/verificar.py scripts/agendar.ps1 README.md DOCS/02-ARQUITETURA.md DOCS/03-TAREFAS.md
git -c user.name="OPENCODE-P06" -c user.email="p06@2gestor.local" commit -m "P-06: T-P06-008 listagem com 60s e 1 retentativa (exit 2) + agendar.ps1 com -WhatIf"
```

Sem `git add -A`, sem `--amend`, sem push (o repo não tem remote). `testes\` e `logs\` não entram.

## Contrato de retorno

Responda exatamente com:

```
RESULTADO: (uma linha)
status: concluido | parcial | bloqueado
arquivos_alterados: (caminho + o que mudou, um por linha)
comandos_executados: (os que importam, com a saída relevante colada)
evidencia: os exit codes medidos (pasta inexistente, real, dry-run, local 1ª e 2ª), o tempo de
           parede do teste com pasta inexistente, e o resultado do schtasks /Query
nao_testado: (o que você NÃO rodou)
riscos: (o que pode quebrar)
proximo_passo: (se houver)
```

Número colado ou não vale. Se algo do brief contradisser o código, pare e reporte em vez de
improvisar.
