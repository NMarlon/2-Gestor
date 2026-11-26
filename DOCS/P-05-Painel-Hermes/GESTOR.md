# P-05 · Painel Hermes — caderno do gestor

> Só o que é **exclusivo do gestor** neste projeto. O que é do projeto mora no repo
> dele (`C:\MarlonScripts\5-Painel-Hermes`) e é a fonte de verdade.

**Estado:** 2026-11-26 · painel `127.0.0.1:8787` em uso; cota oficial ao vivo

**Perfil:** `painel-p05`

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

### 2026-11-25 01:44– · T-P05-003 despachada (UI local + perfis + export diário)

**Ordem:** M-007 do Gerente, em nome do Marlon. Três itens autorizados: UI em
`127.0.0.1:8787` lendo só `dados/stats.jsonl`; correção da lista de perfis em
`DOCS/02-ARQUITETURA.md` (repo do projeto); export diário de `dados/stats.jsonl` para
`backups/` com a data no nome. **S4U proibido nesta rodada** — nada de elevação, nada de
agendador novo.

**Plano (antes de executar):**

- `git status` do `2-Gestor` tinha só `Definições Oficiais Manuais/Dos GERENTES.md`
  modificado (não é caminho meu; não vai no commit). Repo do P-05 limpo em `e5046f4`.
- Registrar `T-P05-003` em `DOCS/04-TAREFAS.md` antes de despachar (feito).
- Brief `briefs/2026-11-25-p05-t003-ui-local.md` com escopo único, contexto verificado,
  proibições, aceite verificável e contrato de retorno (feito).
- Decisão de engenharia: o export diário **não** ganha agendador próprio — pega carona na
  tarefa `PainelHermes-Coletor` que já roda a cada 15 min. Isso respeita "sem agendador
  novo" e mantém um único escritor da série.
- Medição do gestor: `curl` 200 em `http://127.0.0.1:8787/`, `amostras` vs `wc -l`,
  `coletado_em` vs `tail -1`, `netstat` só `127.0.0.1:8787`, backup prefixo exato da
  série, commit `P05-EXECUTOR`, segredo nenhum.

**Despacho:** `powershell -NoProfile -ExecutionPolicy Bypass -File
C:\MarlonScripts\2-Gestor\scripts\oc-brief.ps1 -Dir "C:\MarlonScripts\5-Painel-Hermes"
-Brief "C:\MarlonScripts\2-Gestor\briefs\2026-11-25-p05-t003-ui-local.md"`, em
background (sessão `proc_3d4e2770438b`, 01:47).

### 2026-11-25 02:04–02:12 · T-P05-003 entregue e medida na fonte

**Entrega:** commit `3ce9186` do `P05-EXECUTOR` — 8 arquivos, +1.112/−42:
`scripts/painel.py` (798 linhas), `scripts/backup_serie.py` (131), `scripts/coletor.py`
(+14), `.gitignore` (+1), `DOCS/02-ARQUITETURA.md`, `DOCS/04-TAREFAS.md`,
`DOCS/05-BACKLOG.md`, `README.md`. Árvore limpa, repo sem remote (0).

**Medição do gestor (não é o relatório do executor; é o que eu rodei):**

| O que | Comando | Resultado |
|---|---|---|
| HTTP da UI | `curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:8787/` | **200**; `/api/stats` 200; `/nao-existe` 404; `POST /` 405 |
| Amostras na tela | API vs `wc -l dados/stats.jsonl` | 16 = 16 (coleta manual 02:08:48); depois 17 = 17 (agendada 02:10:50) |
| Última coleta | API vs `tail -1` | `2026-11-25T02:08:48-03:00` = mesma; depois `02:10:50`, `idade_s=57`, `ao_vivo` |
| Bind | `netstat -ano \| grep ':8787'` | só `127.0.0.1:8787 LISTENING 42216`; nenhum `0.0.0.0` nem `[::]` |
| Fora do loopback | `curl http://192.168.0.17:8787/` e `http://[::1]:8787/` | `000`, exit 7 nos dois — recusa, como devia |
| Cota | HTML da página | selo `INDISPONIVEL`, motivo triplo (cli `data=null`, http 401, http 404) e "Sem percentual estimado"; único `%` do HTML é CSS `width:100%` |
| Backup do dia | `backups/stats-2026-11-25.jsonl` | 15 linhas, sha256 `3ef6b45d…` **idêntico** ao `head -15` da série |
| Backup idempotente | `python scripts/backup_serie.py` de novo | "já existe … (use --forcar)", mesma sha256, exit 0 |
| Integração com o coletor | `python scripts/coletor.py` | exit 0; série 15→16; backup "já existe" (não reescreveu) |
| Integração com o agendador | tarefa 02:10:47 | `LastTaskResult=0`, `NextRunTime=02:25:46`; série 16→17; UI refletiu sem reiniciar |
| Commit/segredo | `git show --stat HEAD`; `git grep` por chave/segredo | só caminhos do escopo; nenhum valor de segredo; `backups/` no `.gitignore` |

**Achado e correção:** a nota anterior em `04-TAREFAS.md` dizia que `conversa` "não
existe mais". Errado: o diretório existe (`…\hermes\profiles\conversa`), não tem
`state.db` e não tem papel neste workspace. O executor manteve o perfil na lista como
"sem state.db" — correto. Corrigi a nota e registrei em `E-029`.

**Decisões e limites que ficam valendo:**

- A UI é **só leitura**: não serve arquivo do repo, não abre `auth.json`, `.env` nem
  `.db`; `POST` responde 405. O único arquivo aberto é `dados/stats.jsonl`.
- O backup diário é o **primeiro** do dia, idempotente; `--forcar` reescreve. Hoje ficou
  com 15 linhas enquanto a série já tem 17 — é o desenho. Risco aceito: se a série
  corromper depois do snapshot, perde-se o resto do dia; o de amanhã terá tudo.
- Retenção: nenhuma. Medido 82.424 B / 15 linhas ≈ 5,5 KB por linha; 96 linhas/dia ⇒
  ~0,5 MB/dia, ~190 MB/ano. Vira item de backlog antes de doer.
- UI não sobe sozinha — autostart exigiria serviço/agendador novo, não autorizado.
  Está rodando agora em `http://127.0.0.1:8787` (PID 42216); se o Hermes fechar, subir
  com `python scripts\painel.py` no diretório do projeto.
- Coleta continua só com sessão aberta (S4U não instalado, proibido nesta ordem).
  `idade_s > 1200` na UI significa coleta parada ou máquina deslogada — não "sem uso".

**Próximo:** backlog do projeto (`DOCS/05-BACKLOG.md`) já recebeu rotação/compactação da
série; autostart e `Q-034` (push) só com ordem escrita do Marlon.

---

## 2026-11-25 · T-P05-004 medida — três janelas, cota oficial `INDISPONIVEL`

**Brief:** `briefs/2026-11-25-p05-t004-graficos-tres-janelas.md`, despacho por
`scripts/oc-brief.ps1` (log `logs/oc-20261125-082203-t004.log`).
**Entrega:** commit `94b87f7` "T-P05-004: graficos 5h/7d/30d, plano informado e cota
oficial indisponivel" (`P05-EXECUTOR`, 08:47:47), árvore limpa. O executor **não
devolveu o contrato** no log; avaliei pelo commit e pela minha medição. Antes dele houve
`947db95` (08:41) e um `git reset --hard HEAD~1` da mesma sessão para refazer os rótulos:
`94b87f7` = `947db95` + 15/−3 linhas em `painel.py` (registro em `E-031`).

**Medição (meus comandos, 25/11 08:49–08:58):**

| O que | Comando | Resultado |
|---|---|---|
| UI | `curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:8787/` | **200**, HTML **27.940 B** |
| Gráficos no HTML | `grep -c` no HTML servido | 1× `grafico-5h`, 1× `grafico-7d`, 1× `grafico-30d` |
| Cota e plano | idem | 1× `INDISPONIVEL`, 1× `US$ 10/mês (R$ 60)` |
| Escrita | `POST /` | **405** |
| Arquivo do repo | `GET /scripts/painel.py` | **404** |
| Dependência externa | `grep` por `https?://` em `src`/`href` e `fetch(` | **0** e **0** |
| API | `/api/stats` | 200, 33.110 B, **46 amostras**, `status_coleta=ao_vivo` |
| Layout 1440×900 | CDP Edge, `getBoundingClientRect` | 3 SVGs **1318×458**, 31 textos, altura 27 px, overflow **0**, texto fora do SVG **0** |
| Layout 390×844 | idem | 3 SVGs **340×118**, 31 textos, altura 13 px, overflow **0**; defeitos 1–2 abaixo |
| Bind | `netstat -ano` | só `127.0.0.1:8787 LISTENING` |

**Números conferidos na fonte (`mode=ro`, no instante `amostra_em=2026-11-25T08:49:17`):**

- **5 h** — Hermes `input 1.554.346`, `output 156.073`, `cache_read 17.854.848`; OpenCode
  `459.912 / 68.057 / 20.422.144`. Igual ao delta das amostras 03:55:49→08:49:17 e à soma
  dos 20 buckets, **tolerância 0**.
- **7 d** — JSON 22.641.331 in / 1.695.172 out / 132.700.544 cache; banco 22.840.675 /
  1.702.502 / 133.597.824 → **−199.344 in (−0,87 %)**. **Fato medido:** duas sessões com
  `started_at` 08:46:58 e 08:47:11 existem no `state.db` e não entraram na amostra das
  08:49:17 (outras duas, 08:54, são posteriores à amostra — ausência correta). **Hipótese
  não confirmada** para o mecanismo: linha de sessão em curso só fica visível ao fechar.
- **30 d** — JSON 22.804.105 / 1.713.462 / 133.761.792 (Hermes) e 47.511.646 / 3.855.685 /
  2.088.818.240 (OpenCode); mesmo delta de −199.344 in pelas mesmas duas sessões.

**Defeitos residuais em 390 (medidos; repo é do executor, não corrigi à mão):**

1. `grafico-5h`: o "0" do eixo Y cruza o primeiro rótulo do X ("04:55") — 5×6 px.
2. `grafico-30d`: "25/11" termina **2 px além** da borda direita do SVG.
3. `janelas.5h.inicio` diz `03:49:17`, mas a amostra base é `03:55:49` (janela real 4,89 h).

→ brief `briefs/2026-11-25-p05-t006-rotulos-eixo-390.md` (**T-P05-006**) despachado
08:58. Numeração pulou a 005 porque o backlog do projeto já reservou `T-P05-005` para
`relatorio-semanal.py`.

**Cota oficial — por que não leio (M-009, item 7):** `account` e `control_account` em
`~/.local/share/opencode/opencode.db` têm **0 linhas** (consulta `mode=ro`, 25/11 08:58);
o CLI devolve `data=null`; HTTP 401 e 404. O cartão mostra `INDISPONIVEL` com motivo e
ação. O plano (`US$ 10/mês`, `R$ 60`) é informação do Marlon, e a UI escreve "sem preço
configurado — não convertemos token em % do plano". **Nenhum percentual inventado.**

**Decisão:** T-P05-004 aceita como entregue (os três gráficos existem, mostram números
conferidos e não há overflow). Os três defeitos de rótulo vão para T-P05-006; se o
executor não entregar, o aceite de T-P05-004 continua valendo — o defeito é cosmético e
está documentado.

---

## Sessão 2026-11-25 (retomada pós-travamento) — M-015 inteira

**Ordem:** M-015 do Gerente em três itens: fechar o que ficou solto, M-013 (cota
oficial ao vivo), T-P05-009 (autostart). Medição **só** com
`python C:/MarlonScripts/2-Gestor/scripts/medir-cdp.py` (M-014); dizer quantos
navegadores a tarefa lançou.

**Item 1 — soltos.** Commit `4803cdf` no 2-Gestor: `DOCS/04-TAREFAS.md` (T-P05-006 e
T-P05-007 ✅, T-P05-008 🟡) + briefs `t007` (5.547 B) e `t008` (2.554 B). Os arquivos de
`Definições Oficiais Manuais/` ficaram de fora de propósito — não são do P-05.

**Item 2 — M-013, cota oficial.** O endpoint morto era o problema, não a credencial:
`GET https://opencode.ai/zen/go/v1/usage` com `OPENCODE_GO_API_KEY` (do `.env` do
Hermes, 51 chars) e UA de navegador responde **200 em 0,48 s**. Brief `t010` despachado
10:29, commit do executor `555d175`. Medido por mim: duas coletas seguidas com
`cota_oficial` **10% / 21% / 37%** (5 h / semanal / mensal), falha com chave inválida
vira `motivo: chave inválida ou revogada (HTTP 401)` — nunca zero —, cartão servido com
`OFICIAL · AO VIVO`, horas de renovação em horário de Brasília, e nada de segredo no
repo (`git grep` de `oc_…`/`sk-…` vazio).

**Item 3 — T-P05-009, autostart.** O executor entregou e a minha medição **reprovou**:
6 minutos sem o painel voltar, `NextRunTime` vazio, `LastTaskResult 267011`. A repetição
estava pendurada num gatilho AtLogOn, que só existe quando há logon. Brief `t011`
(10:47) acrescentou gatilho de relógio e um portão no instalador que falha se
`NextRunTime` vier vazio. Refeito: matei o PID 8016 às 10:52:27, o Agendador trouxe o
PID 23716 às 10:55:19 (`LastTaskResult 0`, próxima 11:00:14). Lição em E-035.

**Números do dia (coletor, 10:30):** Hermes ABERTO+FUNCIONAL, 8 processos, heartbeat
2 s; perfis 4/5 com `state.db`; 84 sessões hoje (in 5,96 M / out 623,0 k / cache
80,32 M); OpenCode 206 sessões na base, 13 hoje (in 1,17 M / out 205,2 k).

**T-P05-008 fechada** na mesma sessão: em 1440, `#c-opencode` 668 px (2 colunas),
`#c-plano` e `#c-oficial` em `y=491`, sem overflow. Em 390 o cartão oficial fica
366×219, sem estouro.

**Decisões e limites registrados:**
- Cartão oficial guarda a **última leitura válida** quando a mais nova falha, com a hora
  visível; não pisca para `INDISPONIVEL` por falha isolada.
- A tarefa `PainelHermes-Painel` é `InteractiveToken`: **não roda com o usuário
  deslogado**. Cobrir isso exigiria S4U elevado ou serviço — decisão do Marlon, fora do
  escopo.
- Cota oficial é **percentual do plano**, não consumo de tokens; a UI diz isso na nota.

**Navegadores lançados nesta tarefa: 2** (um print em 1440×900 e um em 390×844, ambos
com `medir-cdp.py`, sem `Start-Process` de URL e sem script CDP próprio).
