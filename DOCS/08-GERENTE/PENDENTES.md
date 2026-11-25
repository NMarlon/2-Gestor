# Pendentes do Gerente

> Tarefas em voo, para não se perderem quando a sessão quebrar. Atualizado em
> **2026-11-25 10:35**. Marcar ✅ ao fechar, com hash/medição ao lado.

## Em execução agora (duas sessões despachadas)

| # | Tarefa | Onde | O que se espera |
|---|---|---|---|
| 1 | **M-015** — P-05: fechar soltos + **M-013** (cota oficial ao vivo) + **T-P05-009** (autostart) | `painel-p05` | coletor gravando `cota_oficial` (2/18/35%) e painel voltando sozinho após reboot |
| 2 | **M-011** — P-03: rótulo "Projetos" + **auditoria de prontidão para deploy/Ads**; e M-006 item 2 | `jessica-p03` | tabela bloqueia × antes-da-campanha × depois, com dono por item |

## Fechado hoje

- ✅ **T-P05-008** (grade 1440) — commit `fa2f949`, árvore limpa. **Não medida por mim** —
  pedi print/tabela no relatório do gestor.
- ✅ **E-032** — vazamento de Edge: `scripts/medir-cdp.py` (reuso + teto 30/h + teardown por
  perfil), 6 scripts em quarentena, skill corrigida.
- ✅ Painel de pé (`127.0.0.1:8787`, HTTP 200) — caiu no boot das 10:01 e subi à mão;
  autostart é a T-P05-009.

## Esperando o Marlon

- **Q-037** — colar a `og:description` da `/chave-na-mao/` no Yoast (wp-admin).
- **Q-038** — escolher: 4 textos de WhatsApp (um por página) ou um só.
- **Q-034** — resolvido por ele (push).
- **Committar `Dos GERENTES.md`**, `Principais Regras e Princípios.md`, `Específicos/` —
  edições dele, uncommitted.

## Fila técnica conhecida

- Coletor: conferir se a série tem buraco entre 10:01 (boot) e a retomada de hoje.
- `p05-painel` fantasma aparece no painel como perfil "sem dado" — nome velho; limpar.
- E-032 aplicado: ferramenta única `scripts/medir-cdp.py`, scripts antigos em quarentena.
