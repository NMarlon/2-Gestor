# Brief — P-06 · T-P06-010 · linha legível numa grade de horários

**Data:** 2026-11-25 · **Executor:** OpenCode · **Dir:** `C:\MarlonScripts\81 - Alerta Planejamento Missionario CTM`

## Resultado esperado

A extração de texto passa a devolver **linhas legíveis** do documento. Hoje ela devolve os
mesmos dados com as palavras em ordem errada, e o relatório de mudança sai assim:

```
| 4 | Linha adicionada | — | 6:30 and Cafeteria 9:30 Study 13:30 15:00 19:00 Activity Go your off |
```

Isso não serve para avisar missionário. Tem de sair algo como:

```
| 4 | Linha adicionada | — | 6:30 Breakfast | 9:30 Study | 13:30 Activity | 15:00 Go off campus | 19:00 ... |
```

## CONTEXTO JÁ VERIFICADO (não re-investigue)

- O documento é uma **grade**: horários no topo (6:30, 6:45 … AM/PM) e atividades nas
  células, cada célula com **várias linhas de texto**.
- O JSON do `presspage` traz cada palavra com `bbox = [x, y, ?, largura]`.
- Sua implementação atual agrupa por `y // 4` e ordena por `x`. O problema: numa célula de
  3 linhas, palavras de linhas diferentes caem no mesmo balde e se misturam.
- O resto do pipeline está **certo e medido por mim**: atalho por `modifiedTime` (exit 0 sem
  navegador), leitura completa (7 páginas, 868 linhas, 5.796 palavras, sha `69538f8f…`
  idêntico em execuções independentes), detecção de alteração (exit 10, página 4), e aviso
  honesto de snapshot inconsistente. **Nada disso pode quebrar.**

## O que mudar (só a reconstrução de linha)

1. Para cada página, trabalhe com as palavras **individuais** (já as tem), cada uma com
   `x`, `y` e a altura estimada (o 3º número do bbox quando existir; senão, diferencie `y`
   entre palavras vizinhas).
2. **Agrupe em linhas por `y`, com tolerância relativa** — não balde fixo. Duas palavras
   pertencem à mesma linha quando a diferença de `y` é menor que metade da altura típica da
   palavra naquela página.
3. Dentro da linha, ordene por `x`. Quando o vão horizontal entre duas palavras for maior
   que ~3× a largura média de um espaço, insira ` | ` — é a separação entre colunas da grade.
4. **Não invente texto, não junte palavras, não corrija ortografia.**
5. Mantenha a estrutura de saída (`paginas` = lista de listas de strings) e **o hash muda** —
   é esperado: é outra granularidade. Registre no README que a versão do snapshot mudou de
   formato e suba `versao` no JSON do snapshot.
6. Snapshots antigos (formato velho) **não podem ser comparados** com o novo: se o snapshot
   anterior não tiver a marca de formato atual, o script deve dizer isso e tratar como
   primeira leitura — nunca comparar formatos diferentes e chamar a diferença de mudança.

## Proibido

- Mexer em `capturar_sessao.py` além do necessário, no atalho por `modifiedTime`, no
  tratamento de falha de página (exit 1) ou no agendador.
- Tocar na restrição de download, no token/sessão, ou abrir navegador fora do `medir-cdp.py`.
- Inventar linha, "melhorar" o texto do documento ou reordenar por heurística de conteúdo.

## Critério de aceite (eu vou rodar)

1. `python scripts/verificar.py --forcar` → exit **10**, e a primeira linha da página 4 no
   relatório mostra **horários com suas atividades**, não palavras soltas.
2. `python scripts/verificar.py` em seguida → exit **0**, **0 navegadores**.
3. Duas execuções independentes com `--forcar` → **mesmo sha256** (determinismo preservado).
4. Snapshot de formato antigo no lugar → o script avisa e trata como primeira leitura
   (exit 10), sem quebrar.
5. Relatório diz quantos navegadores lançou.

## Contrato de retorno

`RESULTADO / status / arquivos_alterados / comandos_executados / evidencia (as saídas
reais, com a linha da página 4 antes e depois) / nao_testado / riscos / proximo_passo`.
Commit com identidade `OPENCODE-P06`, só caminhos explícitos.
