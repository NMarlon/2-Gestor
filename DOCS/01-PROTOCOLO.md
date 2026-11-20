# 01 — Protocolo de operação

## 1. Papéis

| Papel | Quem | Faz |
|---|---|---|
| Gestor | Hermes (este workspace) | Descobre estado, decide, briefa, verifica, commita, reporta |
| Executor | OpenCode (CLI, via `oc-brief.ps1`) | Escreve código, roda comandos, entrega diff |
| Aprovador | Marlon | Autoriza escopo, aprova mudanças visíveis, responde dúvidas |

O gestor **não digita código de projeto**. Ele lê, inspeciona, roda verificação e
escreve brief. Exceção: documentação de gestão deste workspace.

## 2. Canal com o OpenCode

```bash
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/oc-brief.ps1 \
  -Dir "C:\MarlonScripts\1-Mini-Projetos\<Projeto>" \
  -Brief "C:\MarlonScripts\2-Gestor\briefs\AAAA-MM-DD-<slug>.md"
```

- O script resolve o `opencode-cli.exe` mais novo em
  `%APPDATA%\ai.opencode.desktop\cli\` e roda `run --auto --archived`.
- Normaliza `$env:PWD` (vindo do bash/MSYS chega como `/c/...` e o binário nativo
  falha em "change directory").
- Log: `<Dir>\logs\oc-<timestamp>.log` (ou `-LogPath`).
- Exit code ≠ 0 = falha do executor. Nunca presumir sucesso.

## 3. Anatomia de um brief que funciona

1. **Contexto**: onde está, o que já foi verificado (com evidência), o que não
   repetir.
2. **Objetivo**: um resultado verificável, não uma lista de desejos.
3. **Restrições**: o que não tocar, o que não instalar, sem `push`, sem segredo.
4. **Arquivos-alvo**: caminhos exatos.
5. **Critério de aceite**: comando que prova que funcionou.
6. **Commit**: mensagem pedida e escopo do `git add`.

Brief vago gera retrabalho caro. Brief completo é o produto do gestor.

## 4. Verificação (nunca pular)

| Entrega | Como verificar |
|---|---|
| Código | `git -C <repo> diff --stat` + rodar o teste/comando do critério de aceite |
| Serviço/site | `curl` na URL real, status + corpo; não aceitar "subiu" |
| Doc | abrir o arquivo e conferir que a afirmação está lá, com data |
| Commit | `git log -1 --stat` no repo certo |

Regra: **relatório do executor não é evidência**. Evidência é artefato.

## 5. Commit

- Commit ao fim de **cada** tarefa, no repositório do projeto.
- `git add` escopado no projeto trabalhado (os repos têm vários projetos).
- Mensagem em português, imperativo, tipo convencional (`feat:`, `fix:`,
  `docs:`, `chore:`).
- **Nunca** `push` sem pedido explícito do Marlon.

## 6. Concorrência

Antes de acionar o OpenCode: confirmar que não há outro agente escrevendo no
mesmo projeto (`opencode-cli.exe serve --service` é só o servidor do app — não
conta). Um escritor por vez, por projeto.

## 7. Orçamento de contexto

- Ler a seção, não o arquivo inteiro.
- Pedir `--stat`/diff, não transcrição.
- Não reler o que já está registrado em `02-PROJETOS.md`.
- Mas: verificação não é onde se economiza.

## 8. Quando parar

Parar e perguntar quando (a) a resposta muda o resultado, (b) há risco
irreversível, (c) a mudança é visível ao cliente. Registrar a pergunta em
`06-PERGUNTAS.md` **e** seguir no que não depende dela.
