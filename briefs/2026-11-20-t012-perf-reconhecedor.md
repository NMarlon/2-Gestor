# Brief · T-012 · Performance de busca e export (Reconhecedor de Rostos)

Data: 2026-11-20
Executor: OpenCode
Projeto: `C:\MarlonScripts\1-Mini-Projetos\Reconhecedor de Rostos de  Imagens`
(atenção: **dois espaços** entre "de" e "Imagens")

## Contexto

O acervo real está processado e não pode ser perdido:

- `data/faces.db`: **21.482 imagens**, **52.726 rostos**, **17.470 pessoas**,
  0 rostos sem grupo. Clustering já executado.
- Python do projeto: `./.venv/Scripts/python.exe` (Python 3.11).
- A API está no ar em `http://127.0.0.1:8011` (subida pelo gestor, uvicorn).

## Problema medido (não é estimativa)

| endpoint | medido agora | meta |
|---|---|---|
| `GET /api/faces/{id}/similar` | **1,40 s** | < 300 ms |
| `GET /api/export/people` | **103,7 s** / 8,3 MB / 17.470 pessoas | < 10 s |

Comandos que reproduzem:

```
curl -s -o /dev/null -w "%{time_total}s\n" "http://127.0.0.1:8011/api/faces/1/similar"
curl -s -o exports/people.json -w "%{time_total}s %{size_download}B\n" http://127.0.0.1:8011/api/export/people
```

## O que fazer

1. **Medir antes de mexer.** Use `cProfile` (ou log de queries SQLAlchemy) para
   provar onde o tempo vai. Não aceito "provavelmente é N+1" — quero a linha.
   Rode a API numa porta separada para não derrubar a que está em uso:
   `./.venv/Scripts/python.exe -m uvicorn app.main:app --host 127.0.0.1 --port 8012`
2. **Otimizar os dois endpoints.** Hipóteses a confirmar, não a assumir:
   - `similar` recomputa/carrega a matriz inteira de embeddings a cada chamada →
     cache em memória (52.726 × 512 float32 ≈ 108 MB) invalidado por
     `POST /api/cluster`.
   - `export/people` faz uma consulta por pessoa para buscar caminhos de imagem →
     trocar por joins/consultas em lote.
3. **Re-medir** com os mesmos comandos, mesma porta, e registrar os dois números
   antes/depois em `DOCS/PERF.md` (criar se não existir).

## Critério de aceite

- `similar` **< 300 ms** e `export/people` **< 10 s**, medidos, não estimados.
- **Mesmo resultado:** para o rosto `id=1`, a lista de vizinhos (ids, na mesma
  ordem) tem que ser idêntica à de antes; o JSON do export tem que trazer as
  mesmas 17.470 pessoas com os mesmos `face_count`.
- Nenhum dado perdido: antes de qualquer migração, copie o banco para
  `data/faces.db.bak`. Migração só aditiva.

## Proibido

- Não apagar, mover ou reescrever nada em `C:\AREA DE POUSO`.
- Não rodar nova varredura do acervo (`scan_cli`) — o dado já está no banco.
- Não tocar na porta 8011 enquanto mede; use 8012.
- Não inventar número: se algo não foi medido, diga que não foi.

## Entrega

Ao terminar: commit com mensagem `perf: similar e export/people (T-012)` e, no
corpo do commit, os quatro tempos medidos (2 endpoints × antes/depois) e a causa
real encontrada no profiling.
