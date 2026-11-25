# Pendentes do Gerente

> Tarefas em voo, para não se perderem quando a sessão quebrar. Atualizado em
> **2026-11-25 14:30**. Marcar ✅ ao fechar, com hash/medição ao lado.

## Em execução agora

| # | Tarefa | Onde | O que se espera |
|---|---|---|---|
| 1 | **M-016** — P-03: 404 personalizada + 4 textos de WhatsApp | `jessica-p03` | deploy medido; cada página com seu texto |
| 2 | **M-019** — P-06: timeout 60 s + retentativa, código 2 para "não listei"; `agendar.ps1` com `-WhatIf` | `ctm-p06` | três modos rodados, códigos reais |

## Fechado (medido por mim)

- ✅ **P-06 · T-P06-007** (`79117cc`): histórico real em **0 entradas**, teste em
  `historico-local.json` (1); HTML medido por mim — **390 → 1902 px**, **1280 → 900 px**,
  0 navegadores sobrando.
- ✅ **P-05 · M-015** (`7cb057d`): cota `5h 0% · 22% · 37%` ao vivo; tarefa
  `PainelHermes-Painel` *Ready*. Reboot real: **não testado**.
- ✅ **P-03 · M-011** (`dd751d2`): menu `Projetos` confirmado no HTML servido.
- ✅ **P-06 · T-P06-001** (`de5be3c`): 3/3 no aceite; Q-040 bloqueia a leitura real.
- ✅ **E-032** (Edge), **E-036** (caminho MSYS), **M-018** (T-031/033/034 até dry-run),
  **Q-041** (AW-), **bundle** `backups/2-Gestor-20261125-1430.bundle` (8,8 MB, histórico
  completo verificado).

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
