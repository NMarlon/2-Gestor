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
| Brief vigente | `briefs/2026-11-24-p05-t001-kickoff-coletor.md` |
| Estado | 🟢 T-P05-001 **entregue e medida** em 2026-11-24 21:27 — coletor no ar local |
| UI | **não iniciada** — é a T-P05-002, brief próprio depois do coletor provado |

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

T-P05-002 (UI em `127.0.0.1:8787`), brief próprio. Antes disso, nada pendente do
coletor.

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

## Escalonamento

Nada travado nesta sessão. `Q-034` (credencial GitHub) é do Gerente/Marlon, não
bloqueia o coletor.
