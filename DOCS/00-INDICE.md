# 00 — Índice da documentação

> Esta pasta é o cérebro do workspace. Leia por rota, não por curiosidade.

## Rota rápida

| Sua pergunta | Leia |
|---|---|
| "O que é este workspace e quais são as regras?" | [`../AGENTS.md`](../AGENTS.md) |
| "Como eu executo uma tarefa daqui?" | [`01-PROTOCOLO.md`](01-PROTOCOLO.md) |
| "Qual projeto existe, em que pé está, qual a evidência?" | [`02-PROJETOS.md`](02-PROJETOS.md) |
| "Já tentaram isso e deu errado?" | [`03-ERROS-E-APRENDIZADOS.md`](03-ERROS-E-APRENDIZADOS.md) |
| "O que eu faço agora?" | [`04-TAREFAS.md`](04-TAREFAS.md) |
| "O que ficou para depois?" | [`05-BACKLOG-E-IDEIAS.md`](05-BACKLOG-E-IDEIAS.md) |
| "O que está esperando o Marlon?" | [`06-PERGUNTAS.md`](06-PERGUNTAS.md) |
| "Peguei o projeto X: o que é só meu e o que está no repo dele?" | [`P-03-Jessica-Haguiwara/GESTOR.md`](P-03-Jessica-Haguiwara/GESTOR.md) |
| "Somos vários gestores: quem é de quê e como não colidir?" | [`07-GESTORES.md`](07-GESTORES.md) |
| "Quem responde pelo conjunto dos gestores e como audita?" | [`08-GERENTE/REGRAS.md`](08-GERENTE/REGRAS.md) |
| "Quando compactar a sessão e com que parâmetro?" | [`08-GERENTE/COMPACTACAO.md`](08-GERENTE/COMPACTACAO.md) |
| "Quanto cada agente e cada projeto consumiu?" | `python scripts/consumo.py --dias 7` |

Cadernos por projeto ficam em `DOCS/P-<numero>-<nome>/GESTOR.md` e contêm apenas o
que é exclusivo do gestor. O que é do projeto mora no repo do projeto.

`08-GERENTE/` responde pelo **conjunto**: `REGRAS.md` (como o GERENTE trabalha),
`AUDITORIA-AAAA-MM-DD.md` (o que foi medido, com evidência),
`MEDICOES-AAAA-MM-DD.md` (números de progresso por projeto e por gestor) e
`PARA-GESTORES.md` (canal direto GERENTE ↔ gestor, ver `Dos GERENTES.md` itens 4–5).
Gestor de projeto lê; não escreve ali.

## Documentos externos ao workspace (referência)

| Caminho | O que é |
|---|---|
| `../PROJETOS_APROVADOS.md` | Lista de projetos que o Marlon autorizou. Fonte de escopo. |
| `../Definições Oficiais Manuais/Principais Regras e Princípios.md` | Princípios do Marlon. **Somente leitura.** |
| `../IDEA.md` | O que este workspace deve ser. |
| `../scripts/oc-brief.ps1` | Canal oficial gestor → OpenCode. |
| `../briefs/` | Histórico de briefs enviados ao OpenCode. |

## Convenções

- Nomes de arquivo em `DOCS/` são numerados: `00` a `07`; a pasta `08-GERENTE/`
  guarda as regras e auditorias do GERENTE. Documento novo entra com o próximo
  número livre.
- Status: 🟢 feito e verificado · 🟡 em andamento · 🔴 bloqueado · ⚪ não iniciado.
- Toda afirmação de estado carrega **data** e **evidência** (comando + saída,
  caminho de log, URL, hash de commit).
