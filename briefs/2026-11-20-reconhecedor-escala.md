# Reconhecedor — escalar para 21k fotos reais

## Contexto verificado (não precisa re-testar)

- Projeto: `C:\MarlonScripts\1-Mini-Projetos\Reconhecedor de Rostos de  Imagens`
- Python: `.venv\Scripts\python.exe` (3.11, insightface 2.1, onnxruntime CPU,
  SQLAlchemy 2.1.8, numpy). Modelo `buffalo_l` já em cache.
- O app sobe (`uvicorn app.main:app --port 8011`) e a API responde 200.
- `data/faces.db` está **vazio**: 0 imagens, 0 rostos, 0 pessoas. O app nunca
  rodou com foto real.
- Acervo real disponível a partir de agora: ~21.600 imagens em
  `C:\AREA DE POUSO\Fotos da Missão` (Google Takeout + pastas de transferência),
  com muitos grupos, fotos de baixa resolução (WhatsApp) e metadados `.json`.

## Problemas a resolver (nesta ordem)

### 1. Clustering não escala
`app/services.py::cluster_embeddings` faz greedy com laço Python por cluster
(`O(n·k)` chamadas de `np.dot`) e `DBSCAN(metric="cosine")`, que é `O(n²)`.
Com 21k–50k rostos isso vira horas e memória alta.

**Fazer:** greedy vetorizado em blocos — para cada bloco de N embeddings,
calcular a matriz de similaridade contra os centróides existentes com uma única
`np.dot` (bloco × centróides), pegar `argmax` e comparar com o limiar. Memória
controlada por `--chunk`. Manter assinatura pública e semântica atual
(mesmo resultado do greedy, tolerância de empate aceitável). Se o DBSCAN ficar,
que seja opção explícita e não o caminho padrão.

### 2. `similar` e `propagate` carregam a tabela inteira
`app/main.py::similar_faces` e `propagate` fazem `SELECT * FROM faces`, montam
lista Python e calculam cosine em laço puro, por requisição.

**Fazer:** carregar embeddings uma vez em `np.ndarray` (`np.frombuffer` em lote),
usar produto matricial, `argpartition` para top-k, e devolver só o que a resposta
precisa. Preservar o formato JSON de resposta atual.

### 3. Orientação EXIF ignorada
Fotos de celular vêm com orientação EXIF; lidas sem correção, o rosto fica de
lado e o detector perde. Verificar como a imagem é aberta no pipeline e aplicar
transpose EXIF antes da detecção (Pillow `ImageOps.exif_transpose`, ou
`cv2.IMREAD_IGNORE_ORIENTATION` + rotação correta).

### 4. Scan sem modo headless
Hoje o scan parece só existir pela UI. Para rodar 21k imagens durante a noite é
preciso um comando de terminal.

**Fazer:** `scripts/scan_cli.py` com:
- `--dir` (default `PHOTOS_DIR`), `--limit N`, `--resume`
- progresso a cada 200 imagens (processadas, novos rostos, erros, ETA)
- retomada idempotente: pular imagem já registrada (usar o hash existente)
- `--dry-run` que só conta arquivos por extensão
- saída final: JSON com tempos e contagens, e exit code ≠ 0 se houver erro fatal

## Restrições

- Não trocar modelo (`buffalo_l`), não mudar caminho de `data/`, não mudar
  `PHOTOS_DIR` default.
- Não quebrar a API existente: os endpoints atuais devem continuar respondendo
  com o mesmo formato.
- Schema do banco: só mudanças aditivas. Se precisar de coluna nova, criar
  migração idempotente que roda no startup.
- Dependências: só stdlib + o que já está instalado (numpy incluso). Nada de
  FAISS/torch. Se achar que precisa, **não instale**: explique na resposta.
- Sem `git commit`, sem `git push` — o gestor commita.
- Não apagar nada em `data/` nem em `DOCS/`.

## Critério de aceite

1. `python scripts/bench_cluster.py --n 20000` (criar) gera 20k embeddings
   sintéticos 512-d e clusteriza em **< 120 s**, imprimindo tempo e nº de clusters.
2. `curl -s localhost:8011/api/stats` continua 200 depois das mudanças.
3. `python scripts/scan_cli.py --dir "<pasta com 20-30 fotos>" --limit 30`
   processa, grava no banco e imprime o resumo; rodar de novo com `--resume`
   não reprocessa nada.
4. `git status --short` mostra mudanças só em `app/`, `scripts/` e `DOCS/`.

Responda com: arquivos alterados, tempos medidos no bench, e o que **não** foi
possível testar.
