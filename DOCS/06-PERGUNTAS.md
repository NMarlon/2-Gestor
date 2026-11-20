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

`Definições Oficiais Manuais/Principais Regras e Princípios.md` diz: "prioridade para os projetos de
maior rentabilidade e maiores chances de sucesso". Sua instrução de hoje diz:
"comece pelo primeiro projeto aprovado da lista".

São critérios diferentes. Hoje segui a **lista** (P-01 → P-02). Se quiser que eu
passe a ordenar por potencial comercial — com plano de negócio antes de codar —,
diga que eu reorganizo a fila e justifico caso a caso.

---

## Q-05 · Feedback dos projetos publicados 📝

O `Principais Regras e Princípios.md` pede canal de feedback nos projetos que vão ao ar, com seu
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

---

## Q-07 · P-03: publicar a remoção de 394 KB de CSS morto? ✅ resolvida

**Publicado em 2026-11-20 sob a regra "se você não disser nada, publico".**
Home de 577.433 → 183.203 B, sem perda de CSS do site. Se não quiser no ar, o
rollback é o commit `723548c` (redeploy de 1.3.4). Contexto original:

O site carrega, em toda página, 394 KB de CSS utilitário do Spectra que
**nenhuma** página usa (medi: 0 classes em 4 páginas, 0 bloco Spectra). Removi no
tema e a home cai de ~578 KB para menos de 200 KB.

Não há mudança visual esperada — é peso morto. Mas é alteração no ar.

**Se você não disser nada:** publico como 1.3.5 e meço o antes/depois na URL
pública, com rollback pronto (é um commit).

---

## Q-10 · P-03: manter o `jhw-purge.php` público no root do site? ⚪

Para limpar o cache eu chamei `https://jessicahaguiwara.arq.br/jhw-purge.php?k=…`
(chave em `backups/jhw-purge.php`). Funciona, mas é um endpoint público que
qualquer um com a chave pode martelar — cache flush repetido derruba performance.

**O que eu faço por padrão:** deixo como está (é a única forma de publicar hoje) e
registro o risco. Se quiser, troco a chave e/ou passo a remover o arquivo depois
de cada publicação — mas a UAPI não apaga arquivo, então seria pelo File Manager.

---

## Q-08 · P-03: `logs/` do projeto entra no `.gitignore`? ⚪

O repo do site tem `logs/` (saída dos briefs do OpenCode) aparecendo como `??` em
todo `git status`. Isso suja o `git add -A` do executor e pode acabar commitando
log. Sugiro `.gitignore` com `logs/`. Autorizo?

---

## Q-09 · P-03: o que fazer com o órfão `save-probe.css`? ⚪

O deploy sai `exit 1` por causa desse arquivo, que está no servidor e não é usado
por nada. A doc diz que a UAPI do cPanel não apaga arquivo; a doc da cPanel diz
que apaga (`Fileman::delete_file`, e `trash_file` é reversível).

**O que eu faço por padrão:** testo `trash_file` (vai para a lixeira do cPanel,
reversível) e, funcionando, o deploy volta a sair 0. Sem apagar nada de forma
permanente.
