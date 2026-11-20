# 06 — Perguntas para o Marlon

> Perguntas que mudam o resultado. Enquanto não respondidas, o trabalho segue no
> que **não** depende delas.

---

## Q-01 · Acervo real — RESOLVIDA em 2026-11-20 ✅

**O que fiz:** listei o tar sem extrair (30.873 entradas), confirmei que eram as
fotos da missão e extraí para `C:\AREA DE POUSO\Fotos da Missão` — exatamente a
pasta que o app já usa como `PHOTOS_DIR` default. 21.651 imagens, 14 GB, disco
com 303 GB livres. Operação reversível (é cópia; o tar original continua em
`Downloads\Fotos`).

**Se estiver errado:** delete a pasta `C:\AREA DE POUSO\Fotos da Missão` e me
avise; o tar não foi tocado.

**Sub-pergunta aberta (Q-06).**

---

## Q-02 · Aprovar a criação do `AGENTS.md` na raiz 🟡

A escrita em `AGENTS.md` foi bloqueada pela proteção de arquivo de instrução de
agente (o prompt de aprovação expirou enquanto você estava fora). Não vou
contornar por outro caminho.

**Preciso:** sua aprovação para eu escrever `C:\MarlonScripts\2-Gestor\AGENTS.md`
(o contrato do workspace, apontando para `DOCS/`).

Até lá, a documentação funciona por `DOCS/00-INDICE.md`.

---

## Q-03 · P-01 (Hermes-Mobile) está encerrado? 🟡

O servidor responde `0.23.2`, Tailscale ativo nos três ports e você marcou "está
funcionando". Restam só o aviso de versão do Mono Hermes (upstream) e o plugin de
push (backlog).

Confirma que P-01 pode ir para "encerrado, em manutenção" e o foco vira P-02?

---

## Q-04 · Prioridade: ordem da lista ou rentabilidade? 🔴 decide o próximo projeto

`Definições Oficiais Manuais/Principal.md` diz: "prioridade para os projetos de
maior rentabilidade e maiores chances de sucesso". Sua instrução de hoje diz:
"comece pelo primeiro projeto aprovado da lista".

São critérios diferentes. Hoje segui a **lista** (P-01 → P-02). Se quiser que eu
passe a ordenar por potencial comercial — com plano de negócio antes de codar —,
diga que eu reorganizo a fila e justifico caso a caso.

---

## Q-05 · Feedback dos projetos publicados 📝

O `Principal.md` pede canal de feedback nos projetos que vão ao ar, com seu
e-mail (`marlonrviana@gmail.com`). Vale para os projetos locais (P-01, P-02) ou só
para os que tiverem usuário externo? Sugiro: só nos publicados.

---

## Q-06 · Acervo tem duplicatas — o que fazer com elas? 🟡

O tar trouxe três árvores: `CÓPIAS COMPRIMIDAS DAS FOTOS`, `CÓPIAS COMPRIMIDAS
DOS VÍDEOS` e `Takeout` (Google). A mesma foto pode aparecer em mais de uma.

Consequência: o mesmo rosto entra duas vezes no banco, e a lista "fotos desta
pessoa" mostra a mesma cena repetida.

**O que eu faço por padrão (se você não disser nada):** mantenho todas as fotos
no banco, marcando duplicata por hash de conteúdo, e **escondo duplicatas nas
listagens**. Assim nada se perde e a leitura fica limpa.

Diga se prefere o contrário (apagar duplicatas do acervo) ou ignorar o assunto.
