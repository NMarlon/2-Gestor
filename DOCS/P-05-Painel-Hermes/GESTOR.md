# P-05 · Painel Hermes — caderno do gestor

> Só o que é **exclusivo do gestor** neste projeto. O que é do projeto mora no repo
> dele (`C:\MarlonScripts\5-Painel-Hermes`) e é a fonte de verdade.

Aprovação do Marlon em 2026-11-24 21:15: *"Então pode fazer P05 Painel Hermes."*

## Estado em uma linha

| Campo | Valor |
|---|---|
| Caminho | `C:\MarlonScripts\5-Painel-Hermes` |
| Repo | git local, **sem remote** — GitHub bloqueado por `Q-034` (credencial) |
| Gestor | perfil `p05-painel` (era `p05-gestor`; renomeado em 24/11, commit `587f8f8`) |
| Escritor | OpenCode, um por vez, via `scripts/oc-brief.ps1` |
| Brief vigente | `briefs/2026-11-25-p05-t002-agendador-serie.md` |
| Estado | 🟢 T-P05-001 (coletor) medida em 24/11 21:27 · 🟢 T-P05-002 (agendador) medida em 25/11 01:26 |
| Coleta | **automática**, tarefa `\PainelHermes-Coletor` a cada 15 min, modo **interativo** (não roda deslogado) |
| UI | **não iniciada** — é a T-P05-003, brief próprio |

## Objetivo do Marlon

Aplicativo **local** que ele abre no navegador da própria máquina e vê ao vivo:

1. se o **Hermes Agent** está aberto e funcional;
2. o **uso do OpenCode Go** (quota, consumo por dia, projeção de esgotamento);
3. o **desempenho dos gestores** ao longo do tempo.

Scripts em segundo plano gravam a série histórica; a UI só lê. Sem cron de IA —
o consumo é o motivo: agenda do Windows roda script, script não gasta token.

## Fronteira que não se cruza

- **O gestor não escreve no repo do projeto.** Quem escreve é o OpenCode, via brief.
- **Sem cron do Hermes, sem serviço do Windows, sem porta pública, sem GitHub** nesta
  fase. `Q-034` continua bloqueada para push.
- **Nunca inventar cota.** Sem fonte programática provada, o campo é `indisponivel`
  com o motivo técnico — nunca 32%, nunca zero.
- **Segredo não sai do lugar:** `auth.json`, `.env` e os `.db` não vão para log,
  print, commit nem tela. Ao citar, mascarar (`[REDACTED]`).

## Onde ler (nesta ordem)

1. `Definições Oficiais Manuais/Dos GERENTES.md` — regras da camada acima.
2. `DOCS/08-GERENTE/PARA-GESTORES.md` — canal do Gerente; mensagem não lida é
   trabalho na direção errada.
3. `C:\MarlonScripts\5-Painel-Hermes\AGENTS.md` — contrato do projeto (depois de criado).
4. `C:\MarlonScripts\5-Painel-Hermes\DOCS\00-INDICE.md` — doc do projeto.
5. `../02-PROJETOS.md` § P-05 e `../04-TAREFAS.md` — estado e fila.

## Como falar com o executor

```
powershell -NoProfile -ExecutionPolicy Bypass -File `
  C:\MarlonScripts\2-Gestor\scripts\oc-brief.ps1 `
  -Dir "C:\MarlonScripts\5-Painel-Hermes" `
  -Brief "C:\MarlonScripts\2-Gestor\briefs\<brief>.md"
```

Regras que já custaram caro em outros projetos: brief com **uma** tarefa, contexto já
verificado, proibições, critério de aceite verificável e contrato de retorno. O
`oc-brief.ps1` exige que `-Dir` exista — por isso a pasta vazia foi criada antes do
despacho, sem nenhum arquivo.

## Medições do gestor

### 2026-11-24 · antes do despacho (baseline do ambiente)

| Fato | Como foi medido | Resultado |
|---|---|---|
| `5-Painel-Hermes` existe? | `ls /c/MarlonScripts/5-Painel-Hermes` | **não existia** (mkdir antes do despacho) |
| Perfis Hermes | `ls .../hermes/profiles/*/` | 5: `manager-developer-hermes`, `p03-gestor`, `p05-gestor`, `matematico`, `conversa` |
| `state.db` por perfil | `ls .../profiles/*/state.db` | 4 de 5 — **`conversa` não tem**, é caso de "sem dado", não de zero |
| Banco do OpenCode | `ls -la ~/.local/share/opencode/opencode.db` | 396.148.736 B, `nov 24 15:35` |
| CLI do OpenCode | `ls $APPDATA/ai.opencode.desktop/cli` | `2.3.2-x64` |
| Python / Node | `python3 --version` · `node --version` | 3.14.9 (e `python` = 3.11.9) · v26.12.1 |

**Consequência para o coletor:** abrir os bancos como `file:...?mode=ro`, nunca
escrever; tratar perfil sem `state.db` como ausência de dado; não assumir uma única
versão de Python disponível.

## Próximo passo

T-P05-003 (UI em `127.0.0.1:8787` lendo `dados/stats.jsonl`), brief próprio. No mesmo
brief, corrigir a lista de perfis do item 1 de `DOCS/02-ARQUITETURA.md` do projeto
(ainda diz `p03-gestor`, `p05-gestor`, `conversa`; hoje são `p03-jessica`, `p05-painel`,
e `conversa` não existe). Nada mais pendente do coletor nem do agendador.

### 2026-11-24 21:16–21:27 · T-P05-001 medida na fonte (executor OpenCode, 3 commits)

Todas as medições foram feitas pelo gestor, não lidas do relatório do executor.

| Critério do brief | Comando | Resultado |
|---|---|---|
| 1. `git init` + autoria própria | `git log --format='%h \| %an <%ae> \| %s'` | 3 commits (`c16ff41`, `6680a59`, `e88420d`), autores `P05-EXECUTOR <p05@2gestor.local>`, árvore limpa, **0 remotes** |
| 2. Duas execuções, exit 0, +1 linha cada | `python scripts/coletor.py` ×2 | `EXIT1=0` 5→6; `EXIT2=0` 6→7; delta **+1** em cada |
| 2b. Execução de outro diretório | `cd /tmp && python C:/.../coletor.py` | `exit=0`, 7→8, delta **+1** — caminhos absolutos, não depende do cwd |
| 3. Série real e coerente | `wc -l dados/stats.jsonl` + leitura do JSON | 8 registros reais; `hermes: 8 processos`, heartbeat 2–4 s |
| 3b. Contagem independente | `sqlite3 mode=ro` direto, sem usar o coletor | `manager-developer-hermes=336`, `matematico=31`, `p03-gestor=7`, `p05-gestor=2`, `conversa` **sem `state.db`** → JSON traz `null`, não `0`; `opencode.session_v2=193` — **bate exatamente** |
| 4. Cota | campo `cota` do último registro | `status="indisponivel"`, `fonte=null`, `motivo` com os dois caminhos tentados (CLI: `data=null`; HTTP: **401**). Nenhum percentual. |
| 5. Sem segredo | `git grep -iE "sk-\|token\|secret\|password"` | só nomes de campo em doc/código, **nenhum valor**; `grep` de `oc_…`/`Bearer` em `logs/` e `dados/` também limpo |
| 6. Contrato de retorno | log do despacho | os 8 campos preenchidos |

**Extras conferidos:**

- `taskschd`: `Get-ScheduledTask -TaskName 'PainelHermes-Coletor'` → **NAO EXISTE**.
  O `instalar-agendador.ps1` só age com `-IUnderstand` e define `-WorkingDirectory`.
- Bancos abertos em `mode=ro`; `grep` no código não acha `INSERT|UPDATE|DELETE|DROP`.
  `opencode.db` (396 MB) não foi copiado para dentro do repo.
- Credencial lida da tabela `credential` do `opencode.db`, em memória; a `fonte`
  gravada mascara como `Bearer ***`.

**Descoberta que o brief não sabia (paga com tempo, está em `DOCS/03` do projeto):**
`opencode stats --json` existe mas mede tokens/custo, **não cota**. O caminho da cota
é `opencode api GET /api/experimental/usage/limits`, que devolve `data:null` porque
**nenhum workspace do OpenCode Console está conectado**. A chave `oc_…` do banco não
é token de sessão do servidor local: com ela o servidor responde **401**. Ou seja,
`indisponivel` é o dado correto hoje — e o caminho para destravar é conectar o
workspace, não raspar o banco.

**Risco que fica registrado:** a série (`dados/stats.jsonl`) está no `.gitignore`.
Enquanto o repo é local, não há perda; quando o GitHub destravar (`Q-034`), decidir
se a série entra versionada ou só o código. Anotado no backlog do projeto.

### 2026-11-25 01:14–01:26 · T-P05-002 medida na fonte (executor OpenCode, commit `e5046f4`)

**Ordem:** M-005 do Gerente (`PARA-GESTORES.md`), em nome do Marlon — é o pedido
escrito que faltava para instalar o agendador. Escopo re-mapeado na hora: T-P05-002 =
**agendador**; a UI virou **T-P05-003**.

**Brief:** `briefs/2026-11-25-p05-t002-agendador-serie.md` (6.184 B). Despacho por
`oc-brief.ps1` em background; primeira tentativa morreu no help do CLI — ver E-028.

**Entrega:** commit `e5046f4` `T-P05-002: agendador do Windows (PainelHermes-Coletor,
15 min, modo interativo)`, autor `P05-EXECUTOR <p05@2gestor.local>`, 8 arquivos,
+397/−73 (`scripts/instalar-agendador.ps1` +258/−27 e seis docs). Árvore limpa, 0
remotes. `scripts/coletor.py` **não** foi tocado (0 linhas de diff contra `e88420d`).

**Medido pelo gestor (não é relatório do executor):**

| Prova | Comando | Resultado |
|---|---|---|
| Guarda | `instalar-agendador.ps1` sem `-IUnderstand` | `exit 1`, imprime a ação, nada registra |
| Faixa | `-IUnderstand -IntervaloMinutos 3` | `exit 2` |
| Instalar | `-IUnderstand` | `exit 0`, `MODO=INTERATIVO` |
| Desfazer | `-IUnderstand -Remover -NomeTarefa PainelHermes-SONDA-GESTOR` | `exit 0`; `schtasks` passa a responder que não acha — testado em sonda, tarefa real intacta |
| Tarefa | `schtasks /query /tn PainelHermes-Coletor /v /fo LIST` | ver bloco abaixo |
| Série | `wc -l dados/stats.jsonl` antes/depois | **11 → 12** sem execução manual |

Bloco do `schtasks` (25/11 01:26):

```
Nome da tarefa:            \PainelHermes-Coletor
Status:                    Pronto
Modo de Logon:             Interativo apenas
Tarefa a ser executada:    C:\Users\Marlon\AppData\Local\Programs\Python\Python311\python.exe "C:\MarlonScripts\5-Painel-Hermes\scripts\coletor.py"
Iniciar em:                C:\MarlonScripts\5-Painel-Hermes
Executar como Usuário:     Marlon
Repetir: a cada:           0 hora(s), 15 minuto(s)
Horário da última execução: 25/11/2026 01:25:46
Último resultado:          0
Hora da próxima execução:  25/11/2026 01:40:46
```

Amostra 12 da série: `2026-11-25T01:25:49-03:00`, `duracao_ms=1562`,
`coletor=1.0.0 (python 3.11.9)`, `host=DESKTOP-P05PR2E`. Gravada **3 s depois** do
horário agendado (01:25:46) e sem o gestor rodar o coletor — é a tarefa que escreve.

**Repetição medida também:** às 01:40:50 entrou a amostra 13 (`2026-11-25T01:40:50-03:00`),
no horário previsto `01:40:46` — exatos 15 min depois da anterior, sem ninguém mandar.
Série em **13 linhas**; próxima `01:55:46`.

**Limitação que fica registrada:** S4U recusado com `Acesso negado` (sessão não
elevada); a tarefa é **Interativo apenas**, então **não coleta com o usuário
deslogado**. Para isso: registrar elevado com `-LogonType S4U`. Consequência para a
UI: última coleta com mais de ~20 min = tarefa parada ou máquina deslogada, não
"sem uso".

**Pendência menor para o próximo brief:** `DOCS/02-ARQUITETURA.md` do projeto ainda
lista os perfis velhos no item 1 (`p03-gestor`, `p05-gestor`, `conversa`).

## Escalonamento

Duas decisões sobem para o Gerente/Marlon; nenhuma bloqueia a T-P05-003.

1. `Q-034` (credencial GitHub) — é do Gerente/Marlon; sem ela o repo do P-05 fica local
   e a série `dados/stats.jsonl` continua fora do git.
2. **Cobertura com o usuário deslogado:** o agendador ficou em modo interativo porque
   S4U exige elevação. Se o Marlon quiser coleta com a sessão fechada, alguém roda uma
   vez, **elevado**: `.\scripts\instalar-agendador.ps1 -IUnderstand -LogonType S4U`
   (hoje o script tenta S4U, cai para interativo e avisa). Sem isso, a série tem buraco
   sempre que a máquina fica deslogada.
