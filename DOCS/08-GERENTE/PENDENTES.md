# Pendentes do Gerente

> Tarefas em voo, para não se perderem quando a sessão quebrar. Atualizado em
> **2026-11-25 10:35**. Marcar ✅ ao fechar, com hash/medição ao lado.

## Em execução / retomar

| # | Tarefa | Estado | Próximo passo |
|---|---|---|---|
| 1 | **P-05 · T-P05-008** (equilíbrio da grade em 1440) | interrompida pelo travamento; `scripts/painel.py` **modificado e não commitado** | decidir: terminar ou `git checkout -- scripts/painel.py`; depois commitar |
| 2 | **P-05 · M-013** (cota oficial ao vivo no coletor) | ordem escrita, **não despachada** | despachar junto com a T-008 |
| 3 | **P-03 · M-011-B** (auditoria de prontidão para deploy + Ads) | ordem escrita, não despachada | despachar; é a pergunta do Marlon sobre o que falta para anunciar |
| 4 | **P-03 · M-006 item 2** (registrar 2 aprendizados no repo do projeto) | autorizado, sem sessão | entra na próxima sessão do P-03 |
| 5 | **Painel sem autostart** | morre a cada reboot (aconteceu hoje: caiu às 10:01) | criar T-P05-009: autostart + verificação de que a série não perde ponto |

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
