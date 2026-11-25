# P-06 · Alerta de Planejamento Missionário (CTM) — caderno do gestor

**Perfil:** `ctm-p06` · **Repo:** `C:\MarlonScripts\81 - Alerta Planejamento Missionario CTM`
(git local, sem remote) · **Criado:** 25/11/2026

## O que o Marlon quer

Saber, sem abrir o PDF por conta própria, **o que mudou** no planejamento dos missionários
— e ter material para **apresentar a mudança a eles**.

## Medido (25/11, pelo Gerente)

| Fato | Medida |
|---|---|
| Pasta do Drive | pública, lista 1 arquivo: `POR6.4.pdf` |
| Download | **recusado pelo dono** — "the owner hasn't given you permission to download this file" (`uc?export=download`, com cookie, e com `gdown`) |
| Preview | `/file/d/<id>/preview` → 200, mas entrega **PNG** (página renderizada), não PDF |
| Python | 3.11 + pymupdf 2.1 instalados |
| Motor entregue | commit `de5be3c`; relatório `relatorios/teste-local.md` com 3 tipos de mudança |
| Aceite 1 | `--fonte local` → "3 páginas · 1 adicionada · 2 linhas alteradas · 1 adicionada · 1 removida" |
| Aceite 2 | `--dry-run` → sem escrita (md5 do `historico.json` igual antes/depois) |
| Aceite 3 | execução real → **exit 1** com a frase do Google; `historico.json` intacto |
| Idempotência | segunda execução local não duplica entrada (1 → 1) |

## Decisões tomadas

- Histórico e relatórios **versionados**; snapshots e PDFs **ignorados** (`.gitignore`).
- `--fonte local` **não** pode gravar no histórico real (correção pedida na M-017).
- Nada de OCR como plano A: sem download, o projeto para e reporta; OCR só se o Marlon
  escolher a opção (c) da `Q-040`.

## Aberto

- **Q-040** — dono do arquivo precisa permitir download (ou Marlon escolhe alternativa).
- T-P06-004 (agendar semanal) — só depois da Q-040.
- T-P06-005 (HTML bonito para os missionários) — medir em 390 e 1280 antes.
