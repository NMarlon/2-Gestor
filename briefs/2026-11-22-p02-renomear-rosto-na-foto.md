# P-02 · Editar o nome do rosto direto na foto

## CONTEXTO JÁ VERIFICADO (não re-investigue)

Repo: `C:\MarlonScripts\1-Mini-Projetos\Reconhecedor de Rostos de  Imagens` (dois espaços).
Base: `ad9b456` + correções do brief `2026-11-22-p02-correcoes-flags.md`.

Hoje, no lightbox (`app/static/index.html`, `renderBoxes`, ~linha 766): cada caixa `.lb-box`
ganha um `.lb-tip` com a miniatura do rosto e o nome (`face.person_name || 'sem nome'`).
Clicar em **qualquer ponto da caixa** — inclusive no nome — chama `closePhoto()` e
`openPerson(...)`. Ou seja: já abre o conjunto da pessoa, e o nome não é editável.

O Marlon pediu, olhando a foto: quer **clicar no nome e editar ali mesmo**, e fazer
vários nomes seguidos **sem sair da foto**. O clique no rosto (fora do nome) continua
abrindo o conjunto daquela pessoa.

## O QUE FAZER

1. **Nome editável no lightbox.** Clicar no texto do nome (`.lb-tip span`) transforma
   em `<input>` já preenchido com o nome atual, selecionado, `stopPropagation` em tudo
   (click, mousedown, keydown) para não fechar a foto nem navegar.
   - `Enter` e `blur` salvam via `PUT /api/people/{pid}` (FormData, campo `name`).
   - `Esc` cancela e volta ao texto.
   - Enquanto edita, `keydown` não pode vazar para os atalhos globais (Esc do lightbox,
     setas de navegação, F5 de refresh da lista).
2. **Sem sair da foto.** Ao salvar, atualiza o nome naquele rótulo e nos demais rótulos
   da mesma pessoa (a mesma pessoa pode aparecer em duas caixas da foto), atualiza a
   lista de pessoas em memória e mostra um toast. **Não fechar o lightbox, não recarregar
   a página.** O foco volta ao palco da foto, e o próximo clique em outro nome abre o
   input daquele outro rosto direto.
3. **Conflito de nome.** Se o `PUT` devolver **409 `name_exists`**, abrir o diálogo de
   mesclar que já existe (6 miniaturas de cada lado), com o lightbox atrás. Mesclar →
   o nome no rótulo passa a ser o do dono do nome e o toast informa "Mesclado: X → Y".
   Cancelar → nome antigo, nada muda.
4. **Clique no rosto continua abrindo o conjunto**, mas só quando o clique não foi no
   nome e não há edição em andamento. Hoje isso já funciona: preservar.
5. **Rosto sem grupo** (`person_id` nulo): nome não editável, cursor normal, e um
   `title` explicando "rosto sem grupo — use Atribuir". Não criar pessoa por aqui.

## PROIBIDO

- Tocar em backend, schema, cluster ou no banco (a rota `PUT /api/people/{pid}` já basta).
- Refazer o lightbox inteiro ou trocar as cores das caixas.
- Deixar o `Esc` de edição fechar o lightbox — são dois `Esc` diferentes.

## CRITÉRIO DE ACEITE

1. Foto aberta, clique no nome → input com o nome atual; digitar "Élder Teste" + Enter →
   rótulo muda na hora, **lightbox continua aberto**, sem F5; recarregar a página e o
   nome persiste (conferir no banco).
2. `Esc` durante a edição → volta ao nome antigo, foto continua aberta.
3. Renomear para um nome que já existe → aparece o diálogo de mesclar; **Cancelar** não
   altera nada; **Mesclar** junta e o rótulo recebe o nome do dono.
4. Clicar na miniatura/borda da caixa (fora do nome) → abre o conjunto daquela pessoa,
   como hoje.
5. Numa foto com centenas de rostos, editar um nome não deve travar a tela (não
   re-renderizar todas as caixas).
6. Screenshots: input aberto, depois do rename, e o diálogo de conflito.

## CONTRATO DE RETORNO

`RESULTADO / status / arquivos_alterados / comandos_executados / evidencia / nao_testado / riscos / proximo_passo`
