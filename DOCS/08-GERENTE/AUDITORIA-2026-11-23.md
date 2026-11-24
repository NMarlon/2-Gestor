# Auditoria do conjunto — 2026-11-23

**Quem audita:** GERENTE (sessão "gerente dos gestores")
**O que é:** cumprimento de regras, dificuldades reais, deriva de documento e
prestação de contas por gestor.
**Regras contra as quais auditei:** `AGENTS.md`, `Definições Oficiais Manuais/`,
`DOCS/01-PROTOCOLO.md`, `DOCS/07-GESTORES.md`.
**Regras que saíram daqui:** `DOCS/08-GERENTE/REGRAS.md`.

---

## 1. Como medi — e o que não consegui medir

| Fonte | O que saiu dela |
|---|---|
| `state.db` do perfil (`sessions`, `messages`), filtro `cwd like '%2-Gestor%'` | 200 sessões, tokens, compactações, volume de saída por ferramenta, conteúdo dos sumários |
| `git log` / `git status` / `git diff` em `Jessica Haguiwara` e `4-Portfolio` | commits, árvore limpa, versão publicada, ausência de remote no P-04 |
| `curl` com UA de navegador, sem query string, duas leituras | HTML servido do P-03: status, bytes, `?ver=`, link de cookies, depoimentos |
| `grep` em `DOCS/`, `briefs/`, `.gitignore` | numeração, briefs emitidos, deriva de estado, segredo em arquivo de projeto |

**Não consegui medir, e digo isso em vez de estimar:**

- O **mecanismo** da publicação 1.3.8 de 23/11 22:12. O commit existe
  (`cbdf3d0`) e o HTML servido confirma que está no ar; não localizei o registro
  do `deploy-theme.mjs` nem o `--dry-run` daquela versão. Os dry-runs de 20/11
  estão registrados.
- **Qualidade visual** de qualquer entrega. Esta sessão não tem visão; print eu
  não julgo. O que posso afirmar é o que o HTML diz.
- O estado real do **P-02** em execução (jobs, fila, tempo de varredura agora).
- Leitura dos repositórios **privados** do GitHub (device flow expirou; `Q-021`).

---

## 2. O que as sessões mostram

| Métrica | Valor medido |
|---|---|
| Sessões do `2-Gestor` | **200** |
| Sumários de compactação | **156** (4.181.088 caracteres ≈ 1,05 M tokens de saída) |
| Tamanho do sumário | mediana **26.439** · maior **56.702** caracteres |
| Compactações em 23/11 | **12 entre 21:57 e 22:12** (uma a cada ~75 s) |
| Tokens de entrada | 10.407.440 |
| Leitura de cache | 49.047.296 |
| Tokens de saída | 706.709 |
| Saída de ferramenta somada (com repetição entre gerações) | 5.275.558 caracteres |
| Chamadas de `terminal` | 4.039 — 38% do volume, média 500 caracteres |
| `read_file` | 705 chamadas, média **1.418** caracteres |
| `skill_view` | 23 chamadas, média **4.868** caracteres (mesma skill recarregada 3×) |

Leitura: o custo não está no trabalho, está na **repetição de contexto**. O mesmo
estado é redescoberto, reescrito em sumário e redescoberto de novo. Um sumário de
26 KB carrega, ele mesmo, o próximo ciclo: nasce perto do teto e compacta em
minutos. Pior: sumário longo erra. Um deles trazia `C:\MarlonScripts\Jessica` como
caminho do projeto — pasta que não existe.

---

## 3. Cumprimento das regras

| Regra | Evidência | Veredito |
|---|---|---|
| Não fazer `push` sem pedido | 0 comandos `git push` nas sessões auditadas | ✅ cumpre |
| Segredo só em `.env` | token MCP escrito em `Jessica Haguiwara/opencode.json`; ignorado pelo git, nunca commitado | ⚠️ ressalva |
| Gestor não digita código de projeto | 2 patches do gestor em `app/face_engine.py` (P-02, `allowed_modules`) | ❌ viola |
| Um escritor por vez, por projeto | 1 processo `opencode-cli` ativo; sem escrita simultânea no mesmo repo | ✅ cumpre |
| Deploy com `--dry-run` e aprovação | dry-runs de 20/11 existem; a publicação de 1.3.8 correu sob autorização genérica | ⚠️ ressalva |
| Medir antes de reportar | HTML público medido, cache purgado, dois números de bytes declarados | ✅ cumpre |
| Registro central com `T-PXX-NNN` | `T-P03-016`…`T-P03-020` executados e **ausentes** de `04-TAREFAS.md` | ❌ viola |
| Estado com data e evidência | três documentos com estados incompatíveis (§6) | ❌ viola |
| Nada inventado | 3 depoimentos fictícios no ar, etiquetados `EXEMPLO`, declarados em `DADOS-DO-CLIENTE.md` | ⚠️ dívida declarada |
| Caderno do gestor atualizado | `GESTOR.md` do P-03 detalhado, com números e rollback | ✅ cumpre |

Detalhe dos dois "viola":

**Código de projeto pelo gestor (P-02).** Em duas chamadas, o gestor de sessão
editou `app/face_engine.py` para liberar módulos. Não importa se o patch estava
certo: a regra existe para o gestor não virar o segundo escritor do projeto. Se a
correção era de uma linha, o caminho é brief de uma linha.

**Fila contornada (P-03).** Cinco briefs emitidos em 23/11 (`t016`…`t020`) e
nenhuma linha correspondente na fila única. O trabalho foi feito; a fila não sabe.
Isso quebra exatamente a visão que permite vários gestores no mesmo workspace.

---

## 4. Dificuldades reais dos gestores

1. **Contexto.** Compacta a cada ~75 s em noite de trabalho. Cada compactação
   custa ~26 KB de reescrita e devolve um estado já degradado. É o problema número
   um, e é de forma, não de capacidade.
2. **Documento grande.** `04-TAREFAS.md` e `03-ERROS-E-APRENDIZADOS.md` passam de
   15 KB. O gestor lê o arquivo inteiro porque não há índice por tarefa/erro.
3. **Estado espalhado.** Painel, caderno, fila e índice contam histórias
   diferentes. O gestor gasta turno reconciliando em vez de produzindo.
4. **Verificação visual.** Ponto cego admitido. O bloco vazio do P-04 passou na
   primeira revisão e só caiu na segunda, com revisão de imagem.
5. **Canal com o executor.** Sessão longa morre em foreground de 600 s; `exit=1`
   com 75 bytes de log não diz nada. O gestor aprendeu a mediar pelo site, o que é
   correto, mas caro.
6. **Erro repetido.** `E-020` registra a mesma armadilha de cache três dias depois
   de ela ter sido documentada. Registro de erro que ninguém relê não previne nada.

---

## 5. Prestação de contas, um por um

### P-01 · Hermes-Mobile — sem gestor (arquivado)

- **Entrega:** encerrado em manutenção em 20/11; doc sincronizada em 14 arquivos
  (commit `79013d5`).
- **Hoje:** `curl http://127.0.0.1/api/status` **não respondeu**. O painel afirma
  `200` com `version: 0.23.2`.
- **Veredito:** trabalho de encerramento bom; **documento mentindo por omissão**
  agora. Correção: uma linha no painel — "API parada em 23/11; reabrir só a pedido".

### P-02 · Reconhecedor — a designar

- **Entrega:** acervo real (21.651 imagens), 0,29 s/rosto, fluxo de pessoas por
  foto, mesclar pessoas, flags coloridas, renomear rosto na foto (commits até
  `1681d3b`, 22/11).
- **Hoje:** serviço de pé em `:8011`; árvore com 1 arquivo não rastreado
  (`.scan_pass2_done`); workspace tem `T-005`, `T-006`, `T-007` em aberto.
- **Falha:** gestor editou código do projeto (§3). Estado contraditório: `07` diz
  "🔴 pausado a pedido do Marlon", `02` diz "🟡 varredura em andamento".
- **Veredito:** o projeto andou bem; a **operação** dele não tem dono nem status
  confiável. Sem dono definido, cada sessão nova improvisa.

### P-03 · Jessica Haguiwara — gestor ativo, prioridade

- **Entrega:** 1.3.8 no ar, medida por mim em 23/11: **200**, **178.614 bytes** de
  HTML, `style.css?ver=1.3.8`, link de cookies no rodapé, purge do cache comprovado
  no HTML público. Antes: 1.3.7 com 394 KB de CSS morto removido (T-009), deploy
  saindo 0 (T-010), editor rich-text fora do formulário (T-015).
- **Falha:** fila contornada (§3); depoimentos fictícios no ar (§7 das REGRAS) —
  autorizados como exemplo em `Q-025`. *Correção de 24/11:* o `release.json` **não**
  está com falha; o validador passa (`PASS baseline 1.3.7 / versão subiu / 1.3.8 apos
  1.3.7`). Baseline desatualizada entre releases é o comportamento previsto.
- **Veredito:** o gestor que mais entregou e o que melhor documenta o próprio
  trabalho. Precisa de gate de publicação explícito e de disciplina de fila.

### P-04 · Portfólio — a designar

- **Entrega:** home + 6 cases, 4 briefs (v1…v4), 4 commits (`dd561fb`…`047be25`),
  retrato e idiomas do autor, árvore limpa, **0 `PENDENTE`**, **sem remote** —
  respeitou "não publicar".
- **Hoje:** o painel ainda diz "(a criar)" e "executor ainda não acionado". É a
  deriva mais grosseira do conjunto: um projeto inteiro construído e o registro
  oficial não sabe.
- **Falha:** sem dono declarado; verificação visual dependeu de segunda passada.
- **Veredito:** entrega técnica sólida, **registro inaceitável**.

### O que isso diz do modelo, não das pessoas

Três dos quatro projetos não têm dono nomeado — e os três têm deriva de estado.
O único com dono declarado tem o melhor caderno. Não é coincidência: **dono é o
que faz o registro valer.** Enquanto "a designar" for aceitável, documento vai
continuar contando história.

---

## 6. Deriva de documento, lado a lado

| Onde | O que está escrito | O que é verdade em 23/11 |
|---|---|---|
| `02-PROJETOS.md` P-04 | "(a criar)", "executor ainda não acionado", brief v1 | repo com 7 páginas, 4 briefs, 4 commits |
| `02-PROJETOS.md` P-03 | 1.3.7, árvore limpa em 20/11, commit `f7ffce7` | 1.3.8 no ar, commits `3a4cbad`…`cbdf3d0` |
| `02-PROJETOS.md` P-01 | API `200`, `version: 0.23.2` | API não responde |
| `02-PROJETOS.md` P-02 | varredura completa em andamento | doc 07 diz pausado; serviço de pé |
| `07-GESTORES.md` | P-02 pausado · P-04 na fila · P-01 sem gestor | P-02 sem dono e ativo · P-04 construído · P-01 parado |
| `07-GESTORES.md` | nada sobre quem responde pelo conjunto | este documento e `08-GERENTE/` |
| `00-INDICE.md` | "docs numerados 00 a 06" | existe `07-GESTORES.md` e agora `08-GERENTE/` |
| `04-TAREFAS.md` | T-050 no topo; T-013…T-019 fora de ordem; sem `T-P03-*` | 5 tarefas do P-03 executadas fora da fila |

---

## 7. Plano de correção

| # | Ação | Dono | Critério de aceite |
|---|---|---|---|
| 1 | Corrigir os quatro blocos do painel com o estado medido aqui | gestor de cada projeto (P-03 tem; P-02/P-04 dependem de `Q-024`) | `grep` mostra data de 23/11 e nenhum "a criar" |
| 2 | Registrar `T-P03-016`…`T-P03-020` na fila e ordenar por projeto | gestor do P-03 | `grep T-P03` acha as cinco; ordem por projeto |
| 3 | Publicar `08-GERENTE/` no índice e em `07-GESTORES` | GERENTE | rota no `00-INDICE`, linha no `07` |
| 4 | Gate de publicação: ok por deploy, `--dry-run` registrado, `release.json` gravado depois de publicar | gestor do P-03, após `Q-023` | próximo deploy com as três provas no caderno |
| 5 | Depoimentos fictícios: decidir remoção ou prazo | Marlon (`Q-025`) | seção fora do ar ou etiqueta + data de saída |
| 6 | P-01: corrigir a linha do painel | GERENTE | linha diz "API parada em 23/11" |
| 7 | P-02: definir dono e se está pausado | Marlon (`Q-024`) | `07` e `02` dizem a mesma coisa |
| 8 | Forma da sessão: handoff ≤ 8 KB, uma tarefa por sessão | todos os gestores | próxima tarefa do P-03 sem compactação intermediária |

Nada aqui exige mexer em código de projeto. Tudo é registro, gate ou dono.

---

## 8. O que eu não testei

- Validação server-side do formulário do P-03 (o executor admitiu não ter testado).
- Se o `--dry-run` do P-03 continua saindo 11 iguais / 0 divergentes / 0 órfãos
  hoje — não rodei, para não disputar o repo com o escritor ativo.
- Serviço, banco e desempenho do P-02 em execução.
- Qualidade visual do P-04 e do P-03: sem visão nesta sessão.
- Conteúdo dos repositórios privados do GitHub.

---

## 9. Incidente medido **durante** esta auditoria — a colisão não é hipótese

Enquanto eu escrevia este documento, às **22:24:41 de 23/11**, um commit varreu os
meus arquivos em andamento:

```
6676141 Marlon Rebello Viana  11-23 22:24
P-03: conteudo final das 4 paginas + brief T-P03-020 (rascunho) + perguntas 10.1-10.3
 DOCS/00-INDICE.md                       |  10 +-
 DOCS/08-GERENTE/AUDITORIA-2026-11-23.md | 199 +++
 DOCS/08-GERENTE/REGRAS.md               | 270 +++
 DOCS/P-03-Jessica-Haguiwara/...         | 159 +++
 ...QUESTIONARIO-CLIENTE.md              |  11 +-
 briefs/...p03-t020...md                |  71 +++
```

Três fatos, todos verificáveis:

1. **A mensagem não descreve metade do commit.** `REGRAS.md` e `AUDITORIA` são meus,
   escritos para outra finalidade, e entraram junto do trabalho do P-03.
2. **O autor é `Marlon Rebello Viana`** — a mesma identidade de todos os agentes. O
   `git log` deste workspace **não distingue quem fez o quê**. Nenhuma auditoria
   futura consegue atribuir trabalho por autoria sem outro sinal.
3. **Nada se perdeu** — os arquivos estão íntegros no `HEAD`. O dano é de rastro,
   não de conteúdo.

Regras que isso cria (já em `REGRAS.md` §4):

- Commit é por arquivo tocado: `git add <caminho>`, nunca `git add -A` nem `git add DOCS`.
- Antes de commitar: `git status`. Arquivo que você não escreveu **fica fora**.
- Cada gestor assina com `--author="gestor P-0X <gestor@p0x.local>"`. Custa um
  parâmetro e devolve a única coisa que o `git log` não dá hoje: autoria.

Este é o tipo de erro que não aparece em relatório de executor. Apareceu porque eu
estava medindo enquanto acontecia.
