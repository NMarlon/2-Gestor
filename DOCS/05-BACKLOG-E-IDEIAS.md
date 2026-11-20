# 05 — Backlog e ideias

> O que não entra agora. Nada aqui é compromisso; é mapa para quando sobrar tempo.

## P-02 · Reconhecedor de Rostos

- **Export ZIP por pessoa** — já planejado no `TASKS.md` antigo, nunca feito.
  Endpoint que empacota as fotos originais de uma pessoa.
- **Merge de pessoas** — dois clusters da mesma pessoa é o erro mais comum.
  Precisa de "juntar pessoas" na UI, não só renomear.
- **Correção em lote por similaridade** — já existe `propagate`; falta UI clara
  com prévia e desfazer.
- **Detecção de duplicatas de imagem** — mesmo hash já evita reprocessar, mas não
  evita contar a mesma foto duas vezes no acervo.
- **Qualidade do rosto** — descartar rostos com `det_score` baixo ou blur alto
  antes de clusterizar melhora muito o resultado.
- **Modelo de embedding alternativo** — `buffalo_s` é ~4x mais rápido em CPU que
  `buffalo_l`, com perda pequena. Vale medir quando houver acervo.
- **GPU** — se houver GPU disponível, `CUDAExecutionProvider` muda a ordem de
  grandeza do scan. Verificar hardware antes.
- **Reconhecimento de "quem é" a partir de lista de nomes** — o Marlon tem a
  lista de missionários? Nomear cluster é o trabalho manual caro; uma lista
  prévia acelera.
- **Relatório QUEM ↔ fotos** — requisito 2 do Marlon. Exportar CSV/JSON e uma
  página imprimível com pessoa → caminhos de foto.

## P-01 · Hermes-Mobile

- Plugin de push (`ateymoori/pomelu-hermes-plugin`) — decisão do Marlon: backlog.
- Acompanhar release do Mono Hermes compatível com 0.23.x.
- T-01 antiga: investigar aviso `install out of sync` (exige backup antes).

## Workspace do gestor

- **Painel de estado** — um `DOCS/02-PROJETOS.md` é texto; um `status.html`
  gerado a partir dele daria visão de cima. Só se houver uso real.
- **Verificação automatizada diária** — cron que roda `curl` nos serviços e
  confere `git status` dos projetos; avisa só quando algo muda.
- **Template de brief** — `briefs/_template.md` para padronizar.
