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
