# Pendentes do Gerente

> Tarefas em voo, para não se perderem quando a sessão quebrar. Atualizado em
> **2026-11-25 14:30**. Marcar ✅ ao fechar, com hash/medição ao lado.

## Em execução agora

| # | Tarefa | Onde | O que se espera |
|---|---|---|---|
| 1 | **M-016** — P-03: página 404 personalizada + 4 textos de WhatsApp por página | `jessica-p03` | deploy medido antes/depois; cada página com seu texto |
| 2 | **M-017** — P-06: histórico do teste separado + HTML do relatório medido em 390/1280 | `ctm-p06` | `historico-local.json`; prints e alturas do HTML |

## Fechado hoje (medido por mim)

- ✅ **P-05 · M-015** (`7cb057d`): cota oficial ao vivo — painel mostra `5h 0% · semanal 22%
  · mensal 37%`, fonte `GET /zen/go/v1/usage`, "lido às 13:55"; autostart `PainelHermes-Painel`
  existe e está *Ready*; série em 13:55:52.
- ✅ **P-03 · M-011** (`dd751d2`): menu da home mostra `Projetos` (1 ocorrência) e nenhum
  `Projeto</a>` — conferido no HTML servido.
- ✅ **P-06 · T-P06-001** (`de5be3c`): motor entregue; medi os 3 critérios — diff local com
  página adicionada + linha alterada + removida; `--dry-run` sem escrita (md5 igual);
  execução real sai **1** com a recusa do Google. Idempotência 1 → 1.
- ✅ **T-P05-008** (`fa2f949`), **E-032** (Edge), painel de pé.

## Esperando o Marlon

- **PAT** — criar token fine-grained (Contents: read/write em `NMarlon/2-Gestor`) e colar
  `GITHUB_PAT=...` no `.env` do 2-Gestor. O script está pronto: `bash scripts/push.sh`.
- **Q-040** — pedir ao dono do PDF que permita download (ou escolher alternativa).
- **Q-037** — colar a `og:description` da `/chave-na-mao/` no Yoast.
- **Q-038** — ✅ decidido por ele (4 textos); vai na M-016.
- **Edições dele uncommitted**: `Dos GERENTES.md`, `Principais Regras`, `Específicos/`.

## Fila técnica

- P-06: agendar semanal (T-P06-004) só depois da Q-040.
- Perfil fantasma `p05-painel` no painel — limpar.
- Série do painel: buraco `21:29 → 01:17` — investigar suspensão da máquina.
