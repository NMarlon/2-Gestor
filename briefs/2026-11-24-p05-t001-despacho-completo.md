# DESPACHO T-P05-001 — prompt completo enviado ao OpenCode em 2026-11-24

> Snapshot: contrato do Gerente (na íntegra) + regras de execução do GESTOR-P05.
> Fontes: briefs/2026-11-24-p05-t001-kickoff-coletor.md e briefs/2026-11-24-p05-t001-despacho-p05-gestor.md

---

# P-05 · Kickoff — Painel Hermes (painel local de estatísticas ao vivo)

Data: 2026-11-24 21:15 · Autor: GERENTE · Destino: GESTOR-P05 → OpenCode.
Aprovação do Marlon nesta data: "Então pode fazer P05 Painel Hermes."

## O que o Marlon pediu (palavras dele)

- "aplicativo local de estatísticas ao vivo do ambiente de trabalho": **se o Hermes
  está aberto e funcional**, **o uso do OpenCode Go**, o **desempenho dos gestores**.
- "scripts que vai rodar de fundo, que vai mostrar no navegador local (semelhante ao
  projeto do Terabox Auto-Backuper e Reconhecedor de Rostos de Imagens, que está
  dentro de 1-Mini-Projetos, o OpenCode SABE o que é isso que estou querendo)".
- Pasta: `C:\MarlonScripts\5-Painel-Hermes`. "Nome da pasta ainda pode mudar" — o
  nome de exibição fica **Painel Hermes** até ele decidir.
- Sem cron de IA: "não crie a cron job por enquanto, porque eu não quero o consumo
  de IA nisso. Eu quero que tenha um script me mostrando isso." Análise é
  **esporádica, semanal**, não diária.
- Documentação conforme `Definições Oficiais Manuais/Instrução Básicas de Novo
  Projeto para os Agentes Executores.md` (deste workspace): repo único, `DOCS/`,
  `AGENTS.md` como mapa, erros e aprendizados, tarefas, backlog, commit ao fim de
  cada tarefa, autonomia máxima, dúvida → perguntar.
- GitHub próprio — **bloqueado** por `Q-034` (credencial). Comece local; quando o
  Marlon resolver o push, o remote entra.

## Contexto já verificado (não re-investigue)

1. `C:\MarlonScripts\5-Painel-Hermes` **não existe**. Crie.
2. Perfil Hermes `p05-gestor` já existe em
   `C:\Users\Marlon\AppData\Local\hermes\profiles\p05-gestor` (config copiada do
   gerente, `SOUL.md` de 81 linhas). **Não edite `SOUL.md`.**
   Perfis existentes hoje: `manager-developer-hermes` (gerente), `p03-gestor`,
   `p05-gestor`, `matematico`, `conversa`.
3. Fontes de dado locais que já funcionam (usadas por `2-Gestor/scripts/consumo.py`):
   - `C:\Users\Marlon\AppData\Local\hermes\profiles\*\state.db` → tabela `sessions`
     (sessões dos perfis Hermes: gestores, gerente, matematico, default).
   - `C:\Users\Marlon\.local\share\opencode\opencode.db` → tabela `session_v2`
     (sessões do executor OpenCode).
   - `~/.local/share/opencode/auth.json` existe (credencial do OpenCode — **nunca
     imprimir, nunca commitar**).
4. **A cota do OpenCode Go não é medida por ninguém hoje.** Números de cota que
   apareceram antes (32%, reset 12/12 21:45, esgotamento 18/12) vieram do dashboard
   do site, não de uma fonte programática confirmada. O endpoint
   `/api/experimental/usage/limits` respondeu **403** com UA padrão.
   → Tratar como **desconhecido até provar**. Não invente percentual.
5. O CLI do OpenCode é `2.3.2-x64`. Ele tem subcomandos de estatística? **Não
   sabemos** — descubra (`opencode --help`, `opencode stats --help`) e registre a
   saída no relatório.
6. Hermes vivo: gateway está rodando; há log e `state.db`. Descubra a forma
   confiável de dizer "aberto e funcional" (processo + última escrita no `state.db`
   como heartbeat). Não use porta fixa sem confirmar.

## Escopo desta primeira entrega — um item só: o coletor

Entregue **o coletor e nada além dele**. A UI vem na tarefa seguinte; tentar as
duas coisas de uma vez é como o escopo se perde.

`coletor.py` (ou `.mjs`, o que o repo adotar) que, a cada execução:

1. Detecta se o Hermes está vivo e funcional: processo(s) do Hermes, há quanto
   tempo o `state.db` mais recente foi escrito, perfis com sessão ativa.
2. Lê tokens/dia por perfil Hermes e por sessão OpenCode das bases acima
   (somente leitura, abrindo como `file:...?mode=ro` — o Hermes pode estar
   escrevendo; não trave o banco dele).
3. Tenta medir a cota do OpenCode Go **por três caminhos, nesta ordem**, parando no
   primeiro que funcionar de verdade:
   a. CLI do OpenCode, se expuser algo;
   b. endpoint de usage com UA de navegador e credencial local do `auth.json`
      (mascarar qualquer valor no relatório);
   c. se (a) e (b) falharem: marcar cota como `indisponivel` e registrar o motivo
      técnico — **sem chutar número**.
4. Grava série histórica em arquivo append-only (`stats.jsonl` ou `SQLite`), porque
   "ao vivo" só é útil com histórico; guarde 1 linha por coleta com timestamp,
   tokens, sessões, estado do Hermes, e o que houver de cota.
5. Sai com código 0 mesmo quando a cota estiver indisponível (indisponível é dado,
   não erro), e imprime um resumo curto legível no terminal.

Sem dependência pesada: Python da stdlib ou Node sem `node_modules` se possível.
`pip`/`npm install` só se for inevitável, e explique por quê.

## Cadência (importa)

- **Nada de cron de IA.** Agenda no Task Scheduler do Windows (a cada 15 min) roda
  o script; script não gasta token de LLM. Deixe o comando de registro pronto num
  arquivo (`scripts/instalar-agendador.ps1`) mas **não instale sem o Marlon pedir**.
- Relatório semanal: `relatorio-semanal.py` gera um `.md` com a semana (tokens por
  perfil, por projeto, sessões, picos, dias parados). Também não agenda; é comando.

## Proibido

- Ler, imprimir ou commitar chave/token (`auth.json`, `.env`) — mascarar sempre.
- Escrever em `state.db` / `opencode.db` de qualquer forma (somente leitura).
- Criar cron do Hermes, instalar serviço do Windows ou abrir porta pública.
- Mexer em qualquer outro projeto (`Jessica Haguiwara`, `4-Portfolio`, `P-02`).
- Inventar cota, custo ou número de assinatura.

## Documentação do repo (obrigatória nesta entrega)

`AGENTS.md` (mapa: objetivos, regras, o que ler antes de mexer, commit obrigatório,
autonomia máxima, dúvida → perguntar), `DOCS/00-INDICE.md`, `DOCS/01-ESCOPO.md`,
`DOCS/02-ARQUITETURA.md` (fontes de dado e por que são confiáveis), `DOCS/03-ERROS-E-APRENDIZADOS.md`
(comece com o 403 do endpoint), `DOCS/04-TAREFAS.md`, `DOCS/05-BACKLOG.md`
(UI, cota se destravar, GitHub, alertas), `README.md` com o comando de uma linha.

## Critério de aceite

1. `git init` feito, primeiro commit com autoria `P05-EXECUTOR`, `.gitignore` com
   `auth.json`, `.env`, `*.db` grandes, `__pycache__`, `node_modules`, `logs/`.
2. Coletor roda duas vezes seguidas e as duas saem com código 0; a segunda
   acrescenta exatamente 1 linha na série.
3. `stats.jsonl` (ou tabela) com pelo menos 2 registros reais desta máquina, com
   número de perfis e sessões coerente com o que existe.
4. Cota: `indisponivel` **ou** número com fonte provada — em nenhum caso inventada.
5. Nenhum segredo em arquivo versionado: `git grep -iE "sk-|token|secret|password"`
   no repo limpo.
6. Relatório com `RESULTADO / status / arquivos_alterados / comandos_executados /
   evidencia / nao_testado / riscos / proximo_passo`.

## Próxima tarefa (não faça agora)

`T-P05-002` — UI local em `http://127.0.0.1:8787` lendo a série: Hermes vivo/sem
resposta, tokens do dia, gasto por projeto, semáforo da cota, histórico de 14 dias.
Padrão visual dos projetos de `1-Mini-Projetos` (dashboard escuro, cards, atualiza
sozinho por polling). Brief próprio, depois de o coletor estar provado.

---

# DESPACHO T-P05-001 · GESTOR-P05 → EXECUTOR (OpenCode)

Data: 2026-11-24 · Autor: GESTOR-P05 (perfil `p05-gestor`)

## Antes de qualquer coisa

Você é o **EXECUTOR** do projeto P-05 (Painel Hermes). Seu contrato é o brief:

```
C:\MarlonScripts\2-Gestor\briefs\2026-11-24-p05-t001-kickoff-coletor.md
```

**Leia o brief inteiro** antes de agir. Ele manda no escopo. Este arquivo só
acrescenta regras de execução que o brief não explicita; **não amplia nem reduz**
o escopo, e em caso de conflito vale o brief — exceto nos pontos marcados abaixo
como decisão do gestor, que são resolução de ambiguidade dentro do próprio brief.

## Diretório

Trabalhe em `C:\MarlonScripts\5-Painel-Hermes`. Ele já existe e está **vazio**
(criado pelo gestor só para o despacho funcionar). É sua a responsabilidade de
`git init` e de criar tudo o que o brief pede.

## Decisões do gestor (resolvem ambiguidade do brief)

1. **Linguagem: Python da stdlib.** O brief aceita `.py` ou `.mjs`; fica Python,
   pelo precedente de `2-Gestor/scripts/consumo.py` (sqlite3, stdlib) e porque a UI
   da próxima tarefa é servidor HTTP local. Sem `pip install`. Compatível com
   Python 3.11+ (nesta máquina há `python` 3.11.9 e `python3` 3.14.9 — o comando
   documentado no `README.md` deve funcionar com o que existir; cite o que usou).
2. **A entrega é o coletor e nada além dele.** `relatorio-semanal.py` **não** entra
   hoje: registre-o em `DOCS/05-BACKLOG.md`. UI também não.
3. **`scripts/instalar-agendador.ps1`** existe só como documentação do comando de
   registro. **Não execute, não registre tarefa, não instale nada.** Proteja o
   arquivo com um parâmetro de confirmação (`-IUnderstand`) para que rodá-lo por
   acidente não registre nada.
4. **Cota — regra dura.** Nenhum percentual sem fonte. Se os três caminhos do brief
   falharem, grave `cota.status = "indisponivel"` e `cota.motivo` com o erro técnico
   real (status HTTP, mensagem). Se um caminho devolver número, grave também
   `cota.fonte` com o comando/URL exato — número sem fonte não entra no JSON.
5. **Bancos em somente leitura.** URI `file:...?mode=ro` (e `immutable=1` se
   precisar). **Nunca** copie `opencode.db`/`state.db` para dentro do repo. Perfil
   sem `state.db` (o perfil `conversa` não tem) é **ausência de dado**, não zero.
6. **`auth.json`**: pode ler em memória para a tentativa (b) do brief. Nunca
   imprimir, nunca gravar em arquivo, nunca logar. No relatório, `[REDACTED]`.

## Git (o brief pede commit; isto é como)

- `git init` com branch `master`.
- **Autoria `P05-EXECUTOR`** — nunca a identidade do Marlon:
  `git -c user.name="P05-EXECUTOR" -c user.email="p05@2gestor.local" commit -m "..."`
- `git add` por **caminho explícito**. `git add -A`, `git add .` e `commit -a` são
  proibidos (varrem segredo e lixo).
- **Nenhum remote, nenhum `git push`.** GitHub está bloqueado (`Q-034`).
- Commit ao fim da tarefa, com o coletor já executado com sucesso.

## Verificação que você faz antes de reportar

1. Rode o coletor **duas vezes seguidas** e cole as duas saídas e os dois códigos de
   saída.
2. Conte as linhas da série antes e depois da segunda execução (tem de ser +1).
3. `git grep -iE "sk-|token|secret|password"` no repo e cole a saída (esperado:
   nada, ou só nomes de campo sem valor).
4. `git log --format='%an <%ae> %s'` e cole.
5. Leia o último registro do `stats.jsonl` e confira se os números batem com o que
   existe na máquina (5 perfis, 4 com `state.db`).

## Se algo for impossível

Pare naquele ponto, registre em `DOCS/03-ERROS-E-APRENDIZADOS.md` com o erro real e
diga no relatório em `nao_testado` / `riscos`. **Não invente número, não improvise
escopo novo, não mexa em outro projeto.**

## Contrato de retorno (obrigatório)

```
RESULTADO:
status:
arquivos_alterados:
comandos_executados:
evidencia:
nao_testado:
riscos:
proximo_passo:
```
