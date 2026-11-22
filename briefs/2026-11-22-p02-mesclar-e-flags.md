# P-02 · Mesclar pessoas e flags coloridas por pessoa

## CONTEXTO JÁ VERIFICADO (não re-investigue)

Repo: `C:\MarlonScripts\1-Mini-Projetos\Reconhecedor de Rostos de  Imagens`
(dois espaços em "de  Imagens"). Base: commit `190cb4c` (fluxo pessoas → fotos → foto já no ar).

Banco `data/faces.db` — estado conferido agora:
- Tabelas existentes: `images, faces, people, tags, face_tag, person_tag, face_person, image_person, person_stats`.
- **`tags(id, name, color)` está vazia (0 linhas) e `person_tag(person_id, tag_id)` também. Ambas já existem: não crie tabela nova.**
- `people.name` é **UNIQUE** — hoje, renomear para um nome já existente estoura `IntegrityError` e a API devolve 500.
- `models.py` já declara `Person.tags` (secondary `person_tag`), mas **nenhum endpoint usa isso**.
- Rotas atuais: `POST/PUT/DELETE /api/people`, `GET /api/people`, `GET /api/people/{pid}/photos`, `GET /api/people/reindex`, `GET /api/tags`, `POST /api/tags`, `DELETE /api/tags/{tid}` — **não existe PUT de tag, nem tag por pessoa, nem merge**.
- Tags hoje são só por rosto (`/api/faces/{fid}/tag`, `/api/faces/bulk_tag`).
- UI: `app/static/index.html` (715 linhas), lista de pessoas já paginada com miniatura e renomear inline; renomear chama `PUT /api/people/{pid}`.

## OBJETIVO 1 — Mesclar duas pessoas que são a mesma

Fluxo do Marlon: ele vai renomear "Pessoa 412" para "Élder Silva"; se já existe alguém com esse nome, ele quer ser avisado e poder **juntar** as duas, vendo fotos de ambas antes de decidir.

### Backend

1. `GET /api/people/{pid}` → `{id, name, notes, face_count, photo_count, tags:[{id,name,color}], thumbs:[<até 6 urls de /thumbs/...>]}` (miniaturas dos maiores rostos do grupo).
2. `PUT /api/people/{pid}`: quando o nome já pertence a outra pessoa, responder **409** com
   `{"detail": {"code": "name_exists", "person_id": <id do dono atual do nome>, "name": "<nome>", "face_count": n, "photo_count": m, "thumbs": [<até 6>]}}`.
   Não devolver 500. Nome igual ao próprio (sem mudança) não é conflito.
3. `POST /api/people/{pid}/merge` com JSON `{"into": <target_id>}` → move **todos** os rostos de `pid` para `into`, move as linhas de `person_tag`, apaga `pid`, reconstrói `person_stats` do alvo. Resposta `{"into": id, "faces_moved": n, "faces_total": m, "photo_count": k}`. Transação única; `pid == into` → 400; id inexistente → 404.

### UI

- Ao salvar um nome que volta 409, abrir diálogo: **"Já existe 'X' — 597 rostos, 596 fotos"** com 6 miniaturas de cada lado (a pessoa atual e a que já tem o nome), e dois botões: **"Mesclar nesta pessoa"** e **"Cancelar"**.
- Confirmar → `POST .../merge`, atualizar a lista, mostrar aviso discreto "Mesclado: 412 → 116".

## OBJETIVO 2 — Flag por pessoa, com cor e nome editáveis

Uso real: grupos que a detecção juntou errado (rostos aleatórios numa "pessoa" só). Ele quer marcar e **não perder tempo** com eles.

### Backend

4. `POST /api/tags` já existe — garantir `name` + `color` (`#RRGGBB`), sem duplicar nome.
5. `PUT /api/tags/{tid}` → renomear e/ou trocar cor. `DELETE` mantém o comportamento atual.
6. `POST /api/people/{pid}/tag/{tid}` e `DELETE /api/people/{pid}/tag/{tid}`. Idempotentes.
7. `GET /api/people` passa a devolver `tags:[{id,name,color}]` por pessoa **sem N+1** (um `select` extra para todas as linhas da página) e aceita `tag_id` (só quem tem) e `hide_tagged=true` (esconde quem tem qualquer tag).

### UI

- Cada linha da lista: chip pequeno com o nome da flag na cor dela; **fundo da linha tingido com a cor da flag** (alfa baixo, legível no tema escuro).
- Menu "+ flag" na linha: escolher flag existente ou **criar nova** (nome + seletor de cor).
- Editar a flag (nome e cor) em um só lugar — um botão de engrenagem na lista de flags; a mudança reflete em todas as pessoas que a têm, sem recarregar.
- Filtro **"esconder marcadas"** para tirar da frente os grupos ruins.
- Remover flag de uma pessoa pela própria linha.

## PROIBIDO

- Criar tabela nova ou alterar schema (tudo já existe).
- Rodar `POST /api/cluster`.
- Escrever/mover/renomear arquivos do acervo.
- Testar merge no banco real: **copie `data/faces.db` para `data/test_merge.db`, rode a API de teste com `FACES_DB` (ou o mecanismo que o projeto já usa) apontando para a cópia, na porta 8014**, e apague a cópia ao final.
- Dependência nova.

## CRITÉRIO DE ACEITE (medir e colar o número)

1. **Merge no banco de teste:** pessoas A (3 rostos) e B (2 rostos), ambas com fotos próprias → após merge: A extinta, B com 5 rostos, `person_stats` de B atualizado, nenhum rosto órfão (`select count(*) from faces where person_id not in (select id from people)` = 0).
2. **Conflito de nome:** `PUT /api/people/<B>` com o nome de A → **409** com `code: name_exists` e `person_id` de A (não 500).
3. **Merge na UI:** diálogo mostra 6 miniaturas de cada lado; confirmar mescla e a lista reflete a nova contagem.
4. **Flag:** criar "Revisar" `#FFA500`, marcar uma pessoa, `GET /api/people` devolve a tag naquela pessoa; linha com fundo tingido (screenshot); renomear a flag para "Grupo ruim" e trocar a cor → aparece atualizado sem F5; `hide_tagged=true` remove a pessoa da lista; ao final, desmarcar e apagar a flag, deixando `tags` com 0 linhas como está hoje.
5. `GET /api/people?page_size=100` continua **< 500 ms** e ≤ 6 consultas SQL com as tags incluídas.
6. Nenhuma alteração no banco real além das tags criadas e apagadas no teste 4 — conferir `select count(*) from people` = 17.470 ao final.

## CONTRATO DE RETORNO

`RESULTADO / status / arquivos_alterados / comandos_executados / evidencia (números medidos) / nao_testado / riscos / proximo_passo`
