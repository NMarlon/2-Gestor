# Princípio: subagente ou sessão

> Regra de decisão para Gerente, Gestor e Executor. Escrita a pedido do Marlon
> (2026-11-25), para entrar nas **Definições Oficiais Manuais**.
>
> Em uma linha: **subagente é chamada de função — sem estado, descartável, devolve um
> resultado. Sessão é mandato — tem memória, identidade e sobrevive a quem a abriu.**

## A regra, na ordem em que se decide

1. **Precisa existir amanhã**, ou durar mais que a sessão de quem coordena? → **sessão**.
2. **Precisa perguntar, negociar, discordar** ou receber ordem no meio do caminho? →
   **sessão**. Subagente não pergunta: recebe o texto e devolve o resultado — ou devolve
   o erro de ter entendido errado.
3. **Precisa de identidade** — caderno, memória, assinatura em commit, histórico entre
   tarefas? → **sessão**.
4. **Precisa de alguém que responda pelo resultado** depois de entregue? → **sessão**.
5. **É uma entrega única, verificável de uma vez?** → **subagente**.
6. **São N pedaços independentes** que podem rodar ao mesmo tempo? → **N subagentes**.
7. **É leitura pesada cujo resultado cabe em um resumo?** → **subagente**. O contexto de
   quem coordena é o recurso escasso; subagente existe para gastar o dele, não o seu.
8. **Dá para fazer com script, sem IA?** → **script**. Nem subagente, nem sessão: token
   zero e resultado determinístico.

## O que não se delega a subagente

- **Escrita em repositório de projeto** — um escritor por vez, e subagente não tem
  assinatura: o commit sairia com o nome de quem mandou.
- **Decisão que muda o que o cliente vê** — exige alguém que responda por ela.
- **Tarefa que precisa de acompanhamento** depois do resumo.
- **Qualquer coisa que exija aprovação humana** no meio do caminho: subagente não tem
  canal para pedir.

## O que não se delega a sessão (desperdício)

- Ler N arquivos para produzir um documento único.
- Calcular, agrupar, formatar dado — script faz, e não gasta token.
- Tarefa de minutos que não vai se repetir.

## Regra de ouro

**Subagente devolve trabalho. Sessão devolve responsabilidade.** Quem responde continua
sendo quem coordenou — em ambos os casos. Por isso o resumo de um subagente é
**hipótese, não medição**: quem verificou foi ele, quem confirma é quem mandou.

## Aplicação por papel

**Gerente.** Delega a subagente: auditoria de páginas, revisão de texto, leitura de
documentação de terceiros, levantamento comparativo — trabalho de uma vez, que volta
como documento. Abre sessão de gestor: todo trabalho que pertence a um projeto e
precisa continuar amanhã. Nunca escreve código de projeto, nem dentro de subagente.

**Gestor.** Usa subagente para levantamento e conferência dentro do próprio projeto
(medir 40 links, checar 12 páginas). O que **escreve** no repositório vai para a sessão
do executor — o escritor tem que ser rastreável. Subagente não substitui o escritor do
projeto.

**Executor (OpenCode).** Usa subagente para varrer o repositório, levantar referências,
rodar testes em paralelo — trabalho cujo resultado cabe num relatório. Escreve ele mesmo
o que é a entrega e **assina o próprio commit**. Não delega a assinatura.

## Sinais de que a escolha está errada

- Vai criar um subagente para algo que precisa estar certo amanhã.
- Vai abrir uma sessão para ler 30 páginas e devolver um parágrafo.
- Vai usar IA para somar, contar ou agrupar o que um script faz em um segundo.
- O brief do subagente precisa explicar o projeto inteiro — sinal de que a tarefa é de
  sessão.
