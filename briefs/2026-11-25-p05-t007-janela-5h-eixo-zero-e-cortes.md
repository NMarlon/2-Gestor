# T-P05-007 · janela 5 h real, eixo Y com zero e fim dos cortes no cartão

Projeto: **P-05 · Painel Hermes** (`C:\MarlonScripts\5-Painel-Hermes`).
Ordem: Gerente → Gestor (M-009, item "gráfico legível e honesto").
Data: 2026-11-25. Executor: OpenCode. Tarefa: **T-P05-007** (não renumere nada; a
`T-P05-005` do backlog é `relatorio-semanal.py` e **não** é esta).

## CONTEXTO JÁ VERIFICADO (não re-investigue)

- `HEAD` = `b286467` (`T-P05-005: rotulo Y do topo desloca so no mobile`), árvore limpa.
- Servidor local em `http://127.0.0.1:8787/` (pid 56624, `scripts/painel.py`).
- A T-P05-006 está **aprovada**: 390 px com 0 sobreposições e 0 textos fora do SVG;
  1440 com 3 SVGs de 1318×458. **Não refaça** esse trabalho.
- Quatro defeitos medidos pelo gestor hoje, com o código apontado:
  1. **Eixo Y sem o zero.** `scripts/painel.py:355-356` omite o rótulo `0` em todas as
     larguras para evitar colisão em 390. Medido: o gráfico de 5 h tem só 2 marcas
     (`5 M`, `10 M`) em 390 e em 1440. Barra sem linha zero rotulada não se lê.
  2. **A janela "5 h" não tem 5 h.** `scripts/coletor.py:833-836` corta para os
     **últimos 20 pares de amostras**. Com coletas extras (manuais e do agendador) o
     intervalo encolhe: `janelas.5h.inicio=2026-11-25T05:10:49`, `fim=09:00:59`
     (**3 h 50**), buckets `05:25→09:00`. A soma ainda bate com a janela porque os
     pares descartados estavam zerados — **mas um par descartado com token > 0
     desapareceria do total em silêncio**. É bug latente, não só rótulo.
  3. **Cartão por perfil estoura em 1440.** A `.rolagem` da tabela "tokens hoje" mede
     `scrollWidth 409` contra `clientWidth 292` (**+117 px**): cabeçalho e valores
     cortados. É o único elemento cortado da página em 1440.
  4. **Cartão da cota mostra dump cru.** O bloco vermelho traz
     `HTTP 401: {"tag":"UnauthorizedError"...}`, `data=null` e
     "rota de API inexistente neste host". O motivo é verdadeiro e deve ficar; o
     dump não precisa aparecer desse jeito.
- Números da janela agora (`dados/grafico.json`): input `1.896.275`, output `183.953`,
  cache read `20.606.464`; 20 buckets; soma dos buckets = janela.

## ESCOPO ÚNICO (quatro itens, nada além)

**A. 5 h = 20 fatias fixas de 15 min.** Em `scripts/coletor.py`, trocar o corte por
contagem por **agrupamento por fatia**: fatia = `floor(ts_fim / 900)`; cada par de
amostras soma o seu delta na fatia do instante final; manter as 20 fatias da janela
`[agora-5h, agora]`, inclusive as vazias (zero). Remover o `if len(buckets) > 20`.
`inicio` = `coletado_em` da amostra-base (pode ser até um intervalo antes do corte —
o `fim` continua sendo a última amostra); `fim` = `coletado_em` da última amostra.
Não invente amostra: lacuna continua marcada como lacuna. 7 d e 30 d não mudam.

**B. Zero do eixo Y de volta.** Em `scripts/painel.py`, o rótulo `0` volta em todas
as larguras. Em 390, resolver a colisão **sem apagar o zero**: o primeiro rótulo do X
ganha `text-anchor="start"` com `x = m_esq` (ou, se preferir, rotular X a cada 2
fatias). Critério: nenhuma sobreposição de texto e o `0` presente.

**C. Cartão por perfil sem corte em 1440.** Fazer o cartão da tabela por perfil ocupar
duas colunas do grid quando a largura for ≥ 1200 px; se ainda não couber, reduzir a
tabela a Perfil · Sessões · Input · Output e mandar cache read/reasoning para o
`title` da linha. Critério: **zero** elementos com `scrollWidth > clientWidth + 1`.

**D. Cartão da cota legível.** Manter o selo `OFICIAL · INDISPONIVEL` e o motivo
verdadeiro. Trocar o dump por uma frase curta ("o provedor não expõe leitura de cota
neste host — HTTP 401 na rota de API") e guardar o texto técnico em
`<details><summary>detalhe técnico</summary>` ou no `title`. **Nada de número
inventado, nada de chamar API do provedor.**

## PROIBIDO

- Instalar dependência, usar CDN, criar arquivo novo de biblioteca.
- Chamar API externa do provedor; ler, imprimir ou commitar `auth.json`, `.env` ou
  qualquer `.db`.
- Editar `dados/*.json` à mão; mexer no agendador, serviço, porta, firewall ou GitHub;
  `push`.
- `git reset`, `--amend`, `rebase`, `git add -A`, `git add .`, `commit -a`.
- Renumerar tarefas ou reabrir T-P05-004/005/006.

## CRITÉRIO DE ACEITE (eu meço, com curl e CDP)

1. `dados/grafico.json` após uma coleta: `len(fluxo_5h) == 20`; `janelas.5h.inicio`
   a no máximo 15 min antes de `agora-5h`; distância entre o primeiro e o último
   bucket ≥ 4 h 45; soma dos buckets Hermes = `janelas.5h.hermes`.
2. Em 1440: CDP `scrollWidth > clientWidth+1` → **lista vazia**; 3 SVGs 1318×458.
3. Em 390: 0 sobreposições de texto, 0 textos fora do SVG, rótulo `0` presente,
   0 corte.
4. `curl /` 200; `python -m py_compile scripts/coletor.py scripts/painel.py` exit 0.
5. Reiniciar o servidor do painel ao fim (mate o pid antigo e suba de novo) e dizer o
   pid novo no relatório.
6. Commit único, autoria `P05-EXECUTOR`, caminhos explícitos:
   `git -c user.name=P05-EXECUTOR -c user.email=p05@2gestor.local commit`
   (regra do `AGENTS.md` do repo), mensagem começando por `T-P05-007:`.

## RETORNO (contrato)

```
RESULTADO / status / arquivos_alterados / comandos_executados / evidencia /
nao_testado / riscos / proximo_passo
```
`evidencia` = hash do commit, saída do `py_compile`, o `len(fluxo_5h)`/`inicio`/`fim`
que você mediu e o pid novo do servidor. Se algo do escopo não puder ser feito, diga
qual item e por quê — não entregue pela metade sem avisar.
