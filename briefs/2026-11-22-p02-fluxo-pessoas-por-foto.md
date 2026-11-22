# P-02 · Fluxo de pessoas por foto (lista distinta → fotos → rostos na foto)

## CONTEXTO JÁ VERIFICADO (não re-investigue)

App FastAPI + SQLite em `C:\MarlonScripts\1-Mini-Projetos\Reconhecedor de Rostos de  Imagens`
(atenção: a pasta tem DOIS espaços entre "de" e "Imagens").

Estado do banco `data/faces.db`:
- `images(id, path, filename, hash, width, height, size, mtime, processed)` — 21.482 linhas, 10,4 GB de originais, média 0,5 MB.
- `faces(id, image_id, bbox, det_score, embedding, thumb_path, person_id)` — 52.726 linhas. `bbox` é JSON de 4 floats `[x1,y1,x2,y2]` em **pixels da imagem original**.
- `people(id, name, notes)` — 17.470 linhas, nome padrão "Pessoa N".
- `tags(id, name, color)`.
- Miniaturas de rosto já existem: `data/thumbs/face_<id>.jpg`, servidas em `/thumbs/<arquivo>` (1,1 GB).
- **Não existe miniatura de foto inteira.**
- Contagens medidas: 10.416 pessoas têm ao menos um rosto com lado ≥ 48 px; 2.915 têm ≥ 2 rostos e ao menos um ≥ 48 px.

Código atual:
- `app/main.py` (382 linhas) tem `GET /api/people` que percorre todas as pessoas e faz `len(p.faces)` por pessoa — N+1 — e **não devolve miniatura**. `PUT /api/people/{pid}` (Form `name`, `notes`) já existe e funciona.
- `GET /api/faces?person_id=&limit=&offset=` devolve rostos (id, image_id, image_path, bbox, det_score, thumb, person_id, person_name, tags).
- Não existe endpoint por foto nem de fotos de uma pessoa.
- UI: `app/static/index.html`, arquivo único, JS inline (`api()`, `loadPeople()`, `loadFaces()`, `openModal()`). A grade principal hoje mostra **rostos**, e "Todos" repete a mesma pessoa milhares de vezes.

## OBJETIVO

Transformar a UI num fluxo de três níveis, para o Marlon achar pessoas e nomeá-las:

1. **Lista de pessoas distintas** (uma linha por pessoa, com miniatura do rosto) → clicar abre a pessoa.
2. **Pessoa**: grade de **fotos inteiras** (miniatura da foto, não do rosto) onde ela aparece → clicar abre a foto.
3. **Foto**: lightbox com a foto inteira e **todas as caixas dos rostos detectados** naquela foto, cada uma com miniatura e nome; clicar num rosto leva à pessoa dele.

## ESCOPO (só isto; nada além)

### Backend

1. Tabela derivada `person_stats(person_id INTEGER PRIMARY KEY, face_count, photo_count, biggest_px, thumb_face_id)`, reconstruída por uma função `rebuild_person_stats()` que: roda ao final de `POST /api/cluster` e por `POST /api/people/reindex`. `biggest_px` = menor lado do bbox (px), do maior rosto do grupo; `thumb_face_id` = o rosto de maior área (é a miniatura representativa). Reconstrução única em SQL/pandas sobre as 52.726 linhas, sem N+1.

2. `GET /api/people` — reescrito, paginado e sem N+1:
   - query: `q` (busca por nome, case-insensitive), `page` (0), `page_size` (100, máx 500), `min_face_px` (padrão **48**), `order` (`face_count` padrão | `name`).
   - resposta: `{total, people:[{id, name, face_count, photo_count, biggest_px, thumb}]}`; `thumb` = `/thumbs/face_<thumb_face_id>.jpg` (ou `null`).
   - se `person_stats` estiver vazia, preenche na primeira chamada.

3. `GET /api/people/{pid}/photos?page=0&page_size=60` → fotos **distintas** onde a pessoa aparece:
   `{total, photos:[{image_id, thumb:"/api/photo/<iid>", width, height, face_bbox}]}`
   `total` = `count(distinct image_id)`; nenhum `image_id` repetido. `face_bbox` = bbox dela naquela foto.

4. `GET /api/images/{iid}` → `{image_id, width, height, file:"/api/image/<iid>/file", faces:[{id, bbox, thumb, person_id, person_name, person_thumb}]}` com **todos** os rostos daquela imagem.

5. `GET /api/photo/{iid}` → miniatura da foto inteira, 480 px no maior lado, JPEG q80, gerada sob demanda com Pillow e cacheada em `data/photos/<iid>.jpg`; se o arquivo já existe, servir direto. Respeitar EXIF orientation.

6. `GET /api/image/{iid}/file` → `FileResponse` da foto original (somente leitura). 404 se o arquivo não existir no disco.

### UI (`app/static/index.html`)

- **Nível 1 — Pessoas:** lista paginada (100 por página), cada linha com miniatura 40×40, nome e contagem ("412 rostos · 231 fotos"). Campo de busca por nome. Toggle "só rostos ≥ 48 px" (ligado por padrão). Ordenação por quantidade (padrão) ou nome. Renomear inline: clique no nome → input, Enter salva via `PUT /api/people/{pid}`, Esc cancela; atualiza a lista sem recarregar a página. Clicar na linha (fora do nome) abre o nível 2.
- **Nível 2 — Pessoa:** cabeçalho com miniatura grande, nome editável, contagens e botão voltar. Grade de fotos inteiras (miniatura `/api/photo/<iid>`), com borda destacando a foto onde ela foi selecionada. Clique abre o nível 3.
- **Nível 3 — Foto (lightbox):** foto original centralizada, caixas absolutas sobre os rostos usando `bbox` escalado por `%` (funciona em qualquer tamanho de tela). Cada caixa tem contorno fino colorido e, ao passar o mouse, a miniatura do rosto + nome. Clique na caixa (ou na miniatura) vai para a pessoa correspondente. Fecha com Esc ou clique fora.
- Manter funcionando o que já existe: escanear, agrupar, seleção múltipla, atribuir, etiquetar, exportar, filtros por tag. A grade de rostos continua acessível (botão "rostos"), mas a tela inicial passa a ser a lista de pessoas.

## PROIBIDO

- Alterar o pipeline de detecção, embeddings ou o algoritmo de clustering.
- Rodar `POST /api/cluster` (os grupos atuais são a referência; reagrupar está bloqueado aguardando decisão).
- Escrever, mover ou renomear qualquer arquivo do acervo de fotos. Somente leitura.
- Migrar/alterar o schema das tabelas existentes (`images`, `faces`, `people`, `tags`). A única tabela nova permitida é `person_stats`.
- Dependência nova além do que já está instalado (Pillow, FastAPI, SQLAlchemy, numpy). Nada de Node, nada de CDN externo.

## CRITÉRIO DE ACEITE (medir e colar o número)

1. `GET /api/people?page_size=100` responde em **< 500 ms** e **≤ 4 consultas SQL** (contar com `sqlite3.Connection.set_trace_callback` ou equivalente) — anexar a contagem.
2. `GET /api/people/1/photos?page_size=60`: nenhum `image_id` repetido; `total` igual a `select count(distinct image_id) from faces where person_id=1`.
3. `GET /api/images/<iid>` devolve exatamente `select count(*) from faces where image_id=<iid>` rostos.
4. `GET /api/photo/<iid>`: primeira chamada < 1 s; segunda < 100 ms e **não** reescreve o arquivo (comparar `mtime`).
5. Renomear uma pessoa pela UI e recarregar a página: o nome persiste. Conferir no banco.
6. Lista de pessoas: 17.470 no total; com `min_face_px=48`, 10.416. Conferir os dois números na UI e por API.
7. Lightbox: as caixas caem sobre os rostos na foto exibida (validar em uma foto com ≥ 4 rostos, citando o `image_id`).

## CONTRATO DE RETORNO

Responda em:
`RESULTADO / status / arquivos_alterados / comandos_executados / evidencia (números medidos, não adjetivos) / nao_testado / riscos / proximo_passo`
