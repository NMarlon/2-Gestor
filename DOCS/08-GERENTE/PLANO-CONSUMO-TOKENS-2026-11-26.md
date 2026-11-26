# Plano de contenção de tokens — 26/11/2026

**Autor:** GERENTE · **Prioridade:** máxima (decisão do Marlon) · **Status:** aguardando execução
**Objetivo:** o plano do OpenCode Go durar até o fim do ciclo sem estourar.

## 1. O que está medido (fonte: `state.db`, tabela `session_model_usage`)

| Perfil | Chamadas | Input | Saída | Cache read | **Contexto médio por chamada** |
|---|---|---|---|---|---|
| **GERENTE** | 1.230 | 7,4 M | 0,97 M | **212 M** | **172 k** |
| GESTOR `ctm-p06` | 115 | 0,6 M | 0,13 M | 5,2 M | **46 k** |
| GESTOR `pdf-tts` | 100 | 1,4 M | 0,32 M | 5,2 M | **52 k** |

**A hipótese do Marlon está certa, e o número é este: o Gerente carrega 3,7× mais contexto por
chamada que um gestor.** Não é o modelo, não é o prompt: é o **tamanho da conversa multiplicado
pelo número de idas e voltas**.

Sessão mais cara (esta, `…24d39a`): **686 chamadas a 200 k de contexto** = 137 M de tokens de
cache. A segunda mais cara: 167 chamadas de *background review* a 229 k = 38 M (18 % do total).

## 2. Cota do OpenCode Go (medida agora, 26/11 01:40)

| Janela | Uso | Reseta |
|---|---|---|
| Rolante (5 h) | 0 % | 26/11 13:19 |
| **Semanal** | **41 %** | 29/11 21:00 |
| **Mensal** | **47 %** | 12/12 21:45 |

Mensal: 53 % para 17 dias ⇒ **teto de 3,1 %/dia**. Hoje a média do período foi ~3,6 %/dia.
Sem mudança, estoura antes do fim. Semanal: 59 % para 3,8 dias ⇒ 15 %/dia de folga; é a janela
que aperta primeiro se o ritmo subir.

## 3. De onde vem o contexto de 200 k

| Componente | Tamanho aproximado |
|---|---|
| Prompt de sistema (ferramentas + persona + ambiente) | 15–18 k |
| `AGENTS.md` (8.026 B) | ~2 k |
| Memória + perfil do usuário | ~0,9 k |
| **Histórico da sessão** (saídas de ferramenta, colagens, resumos de compactação) | **~180 k** |

A causa dominante é o item 4: **a sessão nunca fecha**. Cada resposta nova reenvia 180 k de
histórico. `tool_output.max_bytes` está em **75.000** e `file_read_max_chars` em **100.000** —
uma saída grande entra no contexto e fica lá até a compactação, que por sua vez gera um resumo
que também fica.

## 4. Ações, por retorno esperado

| # | Ação | Ganho estimado | Risco | Quem executa |
|---|---|---|---|---|
| **A1** | **Uma tarefa, uma sessão.** Ao fechar a tarefa, gravar estado no `DOCS/` e abrir sessão nova — sem "aproveitar" a aberta | **até 60 %** | perde o fio entre tarefas; mitigado pelo registro em arquivo | Gerente (disciplina) |
| **A2** | `tool_output.max_bytes` 75.000 → **20.000**; `max_lines` 5.000 → 800; `file_read_max_chars` 100.000 → **30.000** | **15–25 %** | saída longa precisará de recorte consciente | Marlon (`hermes config set`) |
| **A3** | **Brief por arquivo**: despachar com `hermes -p X -z "leia briefs/<arquivo>.md e execute"` em vez de colar o brief no prompt | ~5 %, e reduz o boot de cada gestor | nenhum | Gerente (já é prática em parte) |
| **A4** | `auxiliary.background_review.model` → modelo barato (hoje `auto`) | **até 18 %** | revisão de fundo fica menos criteriosa | Marlon (config global) |
| **A5** | Verificação proporcional: **um** comando que responde, não três; medir de novo só quando há suspeita concreta | 10–15 % | menos redundância — aceitável | Gerente (disciplina) |
| **A6** | Nunca colar saída bruta no chat: salvar em arquivo e ler o trecho | embutido em A2 | nenhum | Gerente |

**Combinadas A1 + A2 + A5**, a conta cai de ~200 k para ~60–80 k por chamada e o número de
chamadas por tarefa cai pela metade: projeção de **~65 % de redução** no consumo do Gerente.

## 5. O que já está decidido por outra sessão (não duplicar)

O Marlon já mandou, em paralelo: revogar a proatividade do `AGENTS.md`, exigir **planejar antes e
apresentar o plano ao DEV**, e restringir o trabalho autônomo a quando ele mandar. Isso é
**compatível e ajuda**: proatividade é exatamente o comportamento que multiplica chamadas (A5).

## 6. Regras a acrescentar em `REGRAS.md`

1. **Sessão é descartável, documento é permanente.** Tarefa nova = sessão nova. O estado vive em
   `DOCS/`, não no histórico.
2. **Nenhuma saída de ferramenta entra no contexto sem recorte.** Se passa de 100 linhas, vai
   para arquivo e se lê o trecho.
3. **Uma medição por pergunta.** Repetir comando para "confirmar" custa 200 k por repetição.
4. **Brief nunca vai no prompt.** Vai em arquivo; o prompt é o caminho.
5. **Relatório ao Marlon: cinco campos** (M-026), sem repetir o que já está no arquivo.

## 7. Aplicado em 26/11, 02:10 — só nos gestores

Decisão do Marlon: aplicar os limites **apenas nos perfis de gestor**, deixando o Gerente com o
limite alto para não perder evidência na verificação.

| Perfil | `tool_output.max_bytes` | `max_lines` | `file_read_max_chars` |
|---|---|---|---|
| `ctm-p06` | 20.000 | 800 | 30.000 |
| `jessica-p03` | 20.000 | 800 | 30.000 |
| `painel-p05` | 20.000 | 800 | 30.000 |
| `pdf-tts` | 20.000 | 800 | 30.000 |
| **`manager-developer-hermes` (Gerente)** | **75.000 (inalterado)** | 5.000 | **100.000** |

Comando usado (repetido por perfil):

```
hermes -p <perfil> config set tool_output.max_bytes 20000
hermes -p <perfil> config set tool_output.max_lines 800
hermes -p <perfil> config set file_read_max_chars 30000
```

**Prova de runtime (não só de config).** Sessão de teste no `pdf-tts` lendo um arquivo de
52.609 B:

```
truncated=true, truncated_by="bytes", next_offset=554,
~30.000 caracteres entregues (limite atingido após 553 de 944 linhas)
```

O limite de 30.000 chars está **em vigor** no perfil do gestor. O arquivo de 52,6 KB passaria
inteiro antes (100.000 chars) e agora entra pela metade.

**O que isso NÃO resolve:** o Gerente continua em 172 k de contexto por chamada. As ações A1
(sessão por tarefa), A4 (background review barato) e A5 (uma medição por pergunta) continuam
abertas — são elas que atacam os 95 % do tráfego.
