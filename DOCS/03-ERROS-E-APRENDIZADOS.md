# 03 — Erros e aprendizados

> Memória de cicatriz. Cada entrada: o que aconteceu, por que doeu, qual a regra
> que passa a valer. A próxima IA não deve cair nas mesmas.

---

## E-001 · Documentação desatualizada mente com confiança (2026-11-20)

**O que aconteceu:** `Hermes-Mobile/DOCS/10-TAREFAS.md` marcava a Fase 2
(Tailscale `:8443`) como ⚪ não iniciada. O `tailscale serve status` mostrava a
rota `8443` ativa e funcionando.

**Por que dói:** quem confia na doc refaz trabalho pronto, ou pior, "conserta" o
que já funciona.

**Regra:** estado só vale com verificação do ambiente, não com a leitura do
último documento. Antes de retomar um projeto, checar o artefato real (serviço
no ar, `git log`, banco, URL).

---

## E-002 · Código sem dado real não é código pronto (2026-11-20)

**O que aconteceu:** o Reconhecedor de Rostos tem API completa, UI e 10 commits
— mas `data/faces.db` tem 0 imagens e a pasta de fotos está vazia. Nunca viu uma
foto real.

**Por que dói:** o requisito do Marlon é "dezenas de milhares de imagens". O
gargalo (clustering `O(n·k)` em Python puro) só aparece nessa escala. Sem acervo,
o app parece pronto e quebra na primeira execução de verdade.

**Regra:** antes de declarar qualquer coisa "pronta", responder: já rodou com
volume real? Se não, o status é "código pronto, não validado".

---

## E-003 · Repositório aninhado aparece como lixo no repo pai (2026-11-20)

**O que aconteceu:** `Reconhecedor de Rostos de  Imagens/` tem `.git` próprio
dentro de `1-Mini-Projetos`, que também é repo. Resultado: aparece como `??`
(untracked) no pai, e um `git add -A` no pai ou ignora ou cria um gitlink pela
metade.

**Por que dói:** commit acidental arrasta projeto inteiro para o repo errado.

**Regra:** `git add` sempre escopado no caminho do projeto. Antes de commitar,
`git status --short` no repo pai para ver se algo alheio entrou na fila.

---

## E-004 · Escrever AGENTS.md exige aprovação humana (2026-11-20)

**O que aconteceu:** a tentativa de criar `AGENTS.md` na raiz do workspace foi
bloqueada pela proteção de "arquivo de instrução de agente" — o prompt de
aprovação expirou sem resposta (Marlon estava fora).

**Por que dói:** sem `AGENTS.md` a raiz perde o contrato; a doc fica só em `DOCS/`.

**Regra:** `AGENTS.md` é arquivo sensível na origem. Não contornar por terminal
nem pedir ao OpenCode — isso é burlar a proteção. Registrar em `06-PERGUNTAS.md`
e pedir aprovação ao Marlon.

---

## E-005 · Sessão de agente não é o servidor do app (2026-11-20)

**O que aconteceu:** `opencode-cli.exe` rodando com 1,9 GB deu a impressão de
"outro agente escrevendo". A linha de comando era `serve --service` — é o
servidor do app desktop, não uma sessão de trabalho.

**Regra:** checar `CommandLine` do processo antes de concluir que há escritor
concorrente. `serve --service` não conta como sessão.
