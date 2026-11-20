# P-03 · Jessica Haguiwara — caderno do gestor

> Só o que é **exclusivo do gestor** neste projeto. O que é do projeto mora no
> repo dele e é a fonte de verdade.

## Onde ler (nesta ordem)

1. `C:\MarlonScripts\Jessica Haguiwara\AGENTS.md` — **contrato**. Precede tudo.
2. `C:\MarlonScripts\Jessica Haguiwara\DOCS\00-INDICE.md` — índice da doc do projeto.
3. `C:\MarlonScripts\Jessica Haguiwara\DOCS\12-PLANO-EXECUCAO.md` — plano vigente
   (lotes A–H) e registro §5 do que já foi feito.
4. `C:\MarlonScripts\Jessica Haguiwara\DOCS\04-TAREFAS.md` — tarefas do projeto,
   com as pendências por ID (T1…T26).
5. Estado resumido do portfólio: `../02-PROJETOS.md` § P-03.

## Fronteira que não se cruza

- **O gestor não escreve no repo do projeto.** Quem escreve é o OpenCode, via
  brief. O gestor decide, briefa, mede e aprova publicação.
- **Publicar é decisão do gestor**, não do executor. Brief de execução não
  inclui `deploy-theme.mjs` de verdade; só `--dry-run`.
- **Nunca inventar** CAU/registro, área, prazo, preço, obra ou depoimento. Se
  falta o dado da cliente, a seção não existe — não vira placeholder.

## Como falar com o executor

```
powershell -NoProfile -ExecutionPolicy Bypass -File `
  C:\MarlonScripts\2-Gestor\scripts\oc-brief.ps1 `
  -Dir "C:\MarlonScripts\Jessica Haguiwara" `
  -Brief "<caminho do brief>.md" -Agent build
```

Briefs dentro de `AGENTS.md` e no skill local `jessica-brief`. Regras que já
custaram caro:

- Brief com **uma** tarefa, contexto já verificado, arquivos permitidos, fora de
  escopo, critério de aceite verificável e contrato de retorno.
- `--auto` está ok para tarefa sem efeito em produção. **Deploy real exige
  `-NoAuto`** e revisão do diff antes.
- Sessão longa não morre em background; já morreu em foreground de 600 s.
- O agente resolve o `cwd` por `$env:PWD`: não chame o CLI direto do bash/MSYS.
  O `oc-brief.ps1` já normaliza isso e conserta o PATH do git.
- Não confiar no relato do executor: medir a URL pública, ler o `git diff` e
  rodar o validador.

## Armadilhas do projeto (medidas)

| Armadilha | Fato |
|---|---|
| Cache | WP Fastest Cache serve HTML velho e faz a medição mentir. Limpar antes de medir. |
| Purge | Na prática: `https://jessicahaguiwara.arq.br/jhw-purge.php?k=<chave>` (chave em `backups/`, nunca no chat) e depois `curl -X PURGE` em cada URL → 204. Sem isso a medição mostra o HTML antigo. |
| Deploy | **Sai 0** desde 2026-11-20 (órfão foi para `~/.trash/`). Prova boa: `N igual(is), 0 divergente(s), 0 novo(s), 0 orfao(s)` e nenhum envio. Se voltar a sair 1, é divergência real ou órfão novo — não ignorar. |
| Gate de versão | Bump em `style.css` + `functions.php` + `scripts/release.json`, senão o deploy recusa. |
| MCP WordPress | Não é fonte de verdade sobre o que está no ar. Sempre abrir a URL pública. |
| `custom_css` | Gravação pela REST responde vazio; o CSS foi movido para o `style.css` do child. Não voltar a usar o Customizer. |
| Spectra | O plugin injeta **394 KB** de CSS utilitário inline em toda página e **nenhuma** página usa essas classes. Ver T-009. |

## Decisões tomadas

- **2026-11-20 (executada)** — 1.3.5 no ar: removidos 394 KB de CSS utilitário
  morto do Spectra em cada página. Home 577.433 → **183.203 B**. Medido na URL
  pública depois de limpar WPFC + proxy. Rollback = commit `723548c`.
  Antes de publicar conferi que o bloco não tinha seletor global nem `@font-face`.

- **2026-11-20** — Publicar 1.3.5 removendo o CSS utilitário morto do Spectra,
  condicionado a página sem bloco Spectra. Meta: home < 200 KB. Visual idêntico.
- **2026-11-19** — Aprovar o site como está para a cliente; o que falta é dado
  dela, não código.
- **2026-11-20** — Corrigir a doc do projeto antes de qualquer nova feature: 4
  afirmações verificadas como falsas (T-008). Doc que mente sobre o próprio
  estado faz o próximo a mexer no projeto errar.

## Pendências que dependem do Marlon

- Levar à cliente a lista de dados reais (T-011).
- Decidir se o `logs/` do projeto entra no `.gitignore` — hoje aparece como `??`.
