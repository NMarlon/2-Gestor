# Pendentes do Gerente

> Tarefas em voo, para não se perderem quando a sessão quebrar. Atualizado em
> **2026-11-25 14:30**. Marcar ✅ ao fechar, com hash/medição ao lado.

<!-- DIGEST:INICIO -->
| Projeto | Ação manual (só você pode) | Por quê | Onde |
|---|---|---|---|
| **2-Gestor** | Criar PAT fine-grained (Contents: read/write) e colar `GITHUB_PAT=...` no `.env` | 22 commits só no disco; sem isso nada sobe ao GitHub | `C:\MarlonScripts\2-Gestor\.env` |
| **P-03** | Colar a `og:description` da `/chave-na-mao/` no Yoast | O preview do link no WhatsApp/Instagram mostra o texto antigo | wp-admin → página 229 → Yoast |
| **P-03** | Liberar a conta de Google Ads e me passar o `AW-...` | Sem o ID não existe tag de conversão; campanha sem conversão é dinheiro no lixo | conta Ads |
| **P-06** | Nada — o bloqueio de download foi contornado pelo viewer | — | — |
<!-- DIGEST:FIM -->

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

## Credencial de push — por que o device flow não serve (registro de 26/11)

Migrado da memória macro para cá. **Sem segredo nesta nota.**

- O `gh auth login` por **device flow** falhou **3 vezes**: o fluxo exige abrir
  `https://github.com/login/device` e digitar um código de 8 caracteres em poucos minutos, e o
  Marlon não recebe o código no app — ele espera notificação que nunca chega. O código expira
  antes.
- **Fallback combinado:** PAT *fine-grained*, escopo só neste repositório, permissão
  `Contents: read and write`, colado em `GITHUB_PAT=` no `.env` do `2-Gestor`. O token em si
  nunca aparece em markdown, commit, print ou chat.
- **Consequência prática:** com `credential.helper=helper-selector` e sem o PAT no `.env`,
  `GIT_TERMINAL_PROMPT=0 git push` falha. Push só sai interativo (Marlon digitando) ou via
  `scripts/push.sh` lendo o PAT.
- Repositórios privados de terceiros (`FileFuse`, `Bot Creator`) seguem ilegíveis a este agente.
