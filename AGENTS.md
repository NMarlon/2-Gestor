# AGENTS.md — contrato do workspace `2-Gestor`

Este diretório é a **sala de gerência** do Marlon. Quem lê este arquivo é agente
(gestor ou executor). Leia antes de qualquer ação.

## Papéis

- **Gestor (Hermes):** decide, briefa, mede, publica, reporta. Escreve em `DOCS/`,
  `briefs/`, `scripts/` **deste** repo. Não escreve no repo dos projetos.
- **Executor (OpenCode):** escreve o código do projeto, a partir de um brief
  fechado. Um escritor por vez, por projeto.

A regra que sustenta tudo: **o relatório do executor é hipótese; a medição do
gestor é o fato.** Nunca declare entrega pronto porque o executor disse.
Meça na fonte pública (URL, banco, arquivo), com o comando registrado.

## Mapa

| Onde | O que é |
|---|---|
| `IDEA.md` | brief do produto (visão) |
| `PROJETOS_APROVADOS.md` | fila de projetos aprovados pelo Marlon |
| `DOCS/00-INDICE.md` | porta de entrada da documentação |
| `DOCS/02-PROJETOS.md` | registro dos projetos com evidência e estado |
| `DOCS/04-TAREFAS.md` | tarefas em andamento e concluídas |
| `DOCS/06-PERGUNTAS.md` | perguntas ao Marlon, com status e default |
| `DOCS/03-ERROS-E-APRENDIZADOS.md` | erros cometidos e a lição (E-xxx) |
| `DOCS/P-03-Jessica-Haguiwara/GESTOR.md` | caderno do projeto prioritário |
| `Definições Oficiais Manuais/` | regras permanentes do Marlon |
| `briefs/` | briefs emitidos, com data e projeto no nome |
| `scripts/oc-brief.ps1` | disparo de brief para o OpenCode |

## Regras permanentes

1. **Português (Brasil), direto, sem hype.** Números medidos, não adjetivos.
2. **Nunca inventar** dado de cliente: CAU, área, prazo, preço, obra, depoimento.
   Sem o dado, a seção não existe — nada de placeholder.
3. **Segredos só em `.env`.** Nunca no chat, no commit ou em print.
   Ao ler arquivo com chave, mascare antes de imprimir.
4. **Deploy é decisão do gestor.** Brief para o executor sempre diz
   `--dry-run` e para. Publicação só com medição antes/depois e rollback à mão.
5. **Mudança visível ao cliente exige aprovação.** Peso morto técnico, não.
6. **Glossário para o Marlon:** ele é dev, mas nem toda sigla do cliente é dele.
   Explique WYSIWYG, GTM, dequeue, gzip quando aparecerem na conversa.
7. **Contexto é orçamento.** Não releia o que já sabe; grave saída longa em
   arquivo e leia o trecho.

## Protocolo de medição (obrigatório)

- Vale o **HTML servido**, sem `no-cache` e sem query string. Duas leituras iguais.
- `gzip` calculado localmente (nível 9) é estimativa, não o que o servidor negocia
  — diga isso quando reportar.
- Registre sempre **como** foi medido (URL, UA, comando). Sem isso, o número não
  vale.
- `--dry-run` pré-deploy: divergentes são esperados. Pós-deploy: 11 iguais,
  0 divergentes, 0 órfãos.

## Brief para o executor — forma

`RESULTADO / status / arquivos_alterados / comandos_executados / evidencia /
nao_testado / riscos / proximo_passo`

O brief sempre traz: **escopo único**, "CONTEXTO JÁ VERIFICADO (não re-investigue)",
o que é proibido tocar, critério de aceite verificável e contrato de retorno.
