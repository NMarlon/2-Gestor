# AGENTS.md — contrato do workspace `2-Gestor`

Este diretório é a **sala de gerência** do Marlon. Quem lê este arquivo é agente
(gestor ou executor). Leia antes de qualquer ação.

## Papéis

Fluxo padrão (`Definições Oficiais Manuais/Dos GERENTES.md`, item 12):
**Gerente → Gestor → Executor.** O Marlon fala com o Gerente; o Gerente faz os
gestores trabalharem; o gestor briefa o OpenCode.

- **Gerente (este perfil):** cuida dos gestores. Mede progresso individual e geral
  (`08-GERENTE/PAINEL-DE-GESTORES.md`), decide e prioriza entre projetos, dá ordem
  direta de execução e de interrupção ao gestor, presta contas ao Marlon.
  **Não faz código de projeto de próprio punho** (item 3): script que precisar
  existir vira brief para o OpenCode. Escreve em `DOCS/`, `briefs/` **deste** repo.
- **Gestor (Hermes, um por projeto):** decide, briefa, mede, publica, reporta o do
  projeto dele. Escreve em `DOCS/` (a seção do projeto), `briefs/` e `scripts/`
  **deste** repo. Não escreve no repo dos projetos.
- **Executor (OpenCode):** escreve o código do projeto, a partir de um brief
  fechado. Um escritor por vez, por projeto.

A regra que sustenta tudo: **o relatório do executor é hipótese; a medição do
gestor é o fato.** Nunca declare entrega pronto porque o executor disse.
Meça na fonte pública (URL, banco, arquivo), com o comando registrado.

**Vários gestores:** o workspace roda mais de um gestor ao mesmo tempo, um por
projeto. Regra: **um projeto, um gestor, um escritor.** Numeração de tarefa com
prefixo (`T-P03-016`). Detalhes e regras anti-colisão em `DOCS/07-GESTORES.md`.

**Commit é obrigatório, e é o seguro do Marlon.** Cada entrega — de gestor ou de
executor, no repo que for — termina em commit. O commit é o ponto de retorno: sem
ele, erro não se desfaz. Não é adorno de fim de dia. E o Gerente **mantém o próprio
GitHub atualizado** (item 6 do `Dos GERENTES.md`): commit local todo dia, `push` para
`origin/master` deste repo quando o diff estiver conferido.

- Assinatura própria por agente, nunca a identidade do Marlon:
  `scripts/commit-agent.sh GERENTE -m "..." -- DOCS/02-PROJETOS.md`
  (ou `git -c user.name="GERENTE-P03" -c user.email="p03@2gestor.local" commit`).
- `git add` por caminho explícito. `git add -A`, `git add .` e `commit -a` são
  proibidos: varrem arquivo de outro agente e de outro projeto.
- Proibido: `--amend` em commit alheio, `rebase` de histórico já comitado,
  `push --force`. Commit feito é história; não se reescreve.
- `push`: só deste repo, e só depois de colar `git diff origin/master..master --stat`
  no relatório. Repo de projeto não recebe push sem pedido explícito do Marlon.

**Sessão e compactação.** Uma tarefa, uma sessão. Ao fechar a tarefa, grave o
estado em `DOCS/` e comece sessão nova — compactação é exceção, não rotina.
Ordem de leitura para gastar menos contexto: `DOCS/00-INDICE.md` → a seção da
tarefa → o arquivo citado. **Gestor, ao abrir sessão, lê também
`DOCS/08-GERENTE/PARA-GESTORES.md`**: é o canal direto do Gerente, e mensagem não
lida é trabalho feito na direção errada. Não releia o que já está resumido em
documento.

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
| `DOCS/07-GESTORES.md` | vários gestores em paralelo: donos, numeração, regras anti-colisão |
| `DOCS/08-GERENTE/PAINEL-DE-GESTORES.md` | quem é de quê, progresso medido, fila de ordens do Gerente |

## Regras permanentes

1. **Português (Brasil), direto, sem hype.** Números medidos, não adjetivos.
2. **Nunca inventar** dado de cliente: CAU, área, prazo, preço, obra, depoimento.
   Sem o dado, a seção não existe — nada de placeholder.
   **Exceção autorizada (Marlon, 23/11):** bloco marcado na tela como `EXEMPLO`,
   a pedido do cliente, para demonstração de layout. Nunca sem a marca, nunca
   passando por prova real, e a resposta ao cliente diz que é exemplo.
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
