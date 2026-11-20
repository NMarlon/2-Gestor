Você é o executor do projeto Jessica Haguiwara Arquitetura
(WordPress + child theme + MCP). Antes de qualquer ação, leia AGENTS.md
e os documentos listados abaixo. Siga-os integralmente.

Sua tarefa é UMA só. Não expanda o escopo.

TAREFA: Eliminar o CSS inline morto do Spectra (394 KB por página) sem
alterar um pixel do visual.
ID: G3-b (lote G, execução de 2026-11-20)

CONTEXTO JÁ VERIFICADO (não re-investigue):

- Home no ar em 2026-11-20: HTTP 200, **577.745 bytes** de HTML, 39 scripts,
  31 `<link rel=stylesheet>`. Medido com fetch + User-Agent de navegador.
- A página traz **26 blocos `<style>` inline**. O maior:
  `<style id="spectra-gs-utility-classes-inline-css">` = **394.171 bytes**,
  **byte-idêntico** nas 4 páginas do sitemap (`/`, `/privacy-policy/`,
  `/obrigado/`, `/politica-de-cookies/`).
- Esse bloco contém 2.755 seletores utilitários (`.flex`, `.grid`, `.hidden`,
  `.rounded`, `.w-1`, …).
- **Nenhuma das 4 páginas usa uma única dessas classes**: varredura de todos os
  `class="…"` do `<body>`, com match exato de token, retornou **0 ocorrências**
  (269 classes na home, 151/156/107 nas outras). Também não existe nenhum
  `wp-block-uagb` em página nenhuma — o Spectra não é usado como bloco.
- Outros inline do mesmo plugin, menores: `spectra-style-guide-tokens-inline-css`
  (3.731 B) e `uagb-style-frontend-38` (260 B).
- `global-styles-inline-css` (51.060 B) é do WordPress/theme.json — **não é
  Spectra, não mexa nele**.
- O CSS do site vive em `jessica-haguiwara-child/style.css` (53.041 B no ar,
  `?ver=1.3.4`), que É enfileirado. `jhw-home-v2`, `jhw-hero`,
  `forminator-module-168` e `jhw-pendente` estão todos lá. O T10 está concluído —
  a linha antiga do registro dizendo "custom_css não pôde ser gravado / CSS segue
  no Customizer" está **desatualizada**.
- Estado do repo em `C:\MarlonScripts\Jessica Haguiwara`: árvore limpa, último
  commit `fc38a81 banner de cookies: corrige estouro de 12px no mobile (1.3.4)`.
- Validadores hoje: `validate-theme` → **TUDO OK**; `check-live-footer` →
  **rodape do ar OK**.

ARQUIVOS QUE PODEM SER TOCADOS:

- `jessica-haguiwara-child/functions.php` (enfileiramento/dequeue + versão)
- `jessica-haguiwara-child/style.css` (só o cabeçalho `Version:`)
- `scripts/release.json` (gate de versão)
- `DOCS/12-PLANO-EXECUCAO.md` §5 (registro de execução)
- `DOCS/04-TAREFAS.md` (status do item)

FORA DE ESCOPO (não toque):

- Qualquer bloco CSS/JS do WordPress core, do tema pai `extendable`, do
  `global-styles-inline-css`, do Forminator, do Complianz ou do QLWapp.
- Conteúdo das páginas (IDs 38, 214, 219, privacy policy).
- `.env`, `opencode.json`, `backups/`, `Anexos/`.
- O órfão `assets/css/save-probe.css` (é a tarefa T5, outra sessão).

RESTRIÇÕES:

- **Não use hack de string/`ob_start` para reescrever o HTML.** Use o filtro ou
  o handle oficial do Spectra. Pesquise na internet a forma normativa de
  desativar a geração de "utility classes" do Spectra/Ultimate Addons para
  Gutenberg (versão instalada: confirme no `functions.php`/plugins). Cite a
  fonte no retorno.
- **A remoção deve ser condicional, não cega.** Se um dia uma página passar a
  usar um bloco Spectra, o CSS tem que voltar sozinho. Condicione a remoção a
  "esta página não contém `wp-block-uagb`" (ex.: `has_block()` no `wp_enqueue_scripts`
  com a query do post atual). Um `dequeue` incondicional é resposta errada.
- Se o plugin expuser uma opção em banco que desliga isso globalmente, **não
  mexa no banco**; resolva por código no child theme e explique por quê.
- Se não existir filtro/handle público e a única saída for frágil, **pare** e
  reporte: prefiro não remover a remover de forma que quebre na próxima
  atualização do plugin.
- Bump obrigatório de versão **1.3.4 → 1.3.5** em `style.css` e `functions.php`
  (o gate do `release.json` reprova sem isso).
- **Não faça deploy.** Rode `--dry-run` e pare. A publicação é decisão do gestor,
  depois de ver seu diff. `node scripts/deploy-theme.mjs` de verdade está fora
  do seu escopo nesta sessão.
- Não invente dado, hook, API ou caminho.
- Não use `--auto`, force-push ou reset --hard.
- Pode usar `git add` (inclusive -A) para preparar o rollback; o commit é o
  ponto de rollback.
- Não altere arquivo fora da lista acima.
- **ORFÃO CONHECIDO:** `node scripts/deploy-theme.mjs` sai com **exit 1** por
  causa de `assets/css/save-probe.css` no servidor ("1 orfao(s)"), mesmo quando
  todos os arquivos conferem. Isso é esperado e **não é falha do seu envio**.
  A prova de sucesso é a linha `N igual(is), 0 divergente(s), 0 novo(s)`.

CRITÉRIO DE ACEITE (verificável por você, sem deploy):

- [ ] O dequeue/remoção está condicionado a "página sem bloco Spectra" e é
      reversível se o plugin voltar a ser usado.
- [ ] `validate-theme.mjs` → TUDO OK.
- [ ] `deploy-theme.mjs --dry-run` → `N igual(is), 0 divergente(s), 0 novo(s)`
      (o exit 1 do órfão é esperado; ignore).
- [ ] Versão 1.3.5 em `style.css` e `functions.php`, e `release.json` coerente.
- [ ] Nenhum `class` do `<body>` das 4 páginas públicas referencia seletor do
      bloco utilitário (varredura que você roda contra o site atual, prova de
      que o bloco é morto).
- [ ] Registro no `DOCS/12-PLANO-EXECUCAO.md` §5 com data, o que mudou, e a
      correção das duas linhas desatualizadas do T10 (o CSS está no `style.css`,
      `custom_css` está vazio — confirme antes de escrever).

O que fica para o gestor (não é seu aceite): publicar, limpar o cache e medir o
HTML público antes/depois.

VERIFICAÇÃO QUE VOCÊ DEVE RODAR:

```
node scripts/validate-theme.mjs
node scripts/deploy-theme.mjs --dry-run
node -e "const UA='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36';(async()=>{for(const p of ['','privacy-policy/','obrigado/','politica-de-cookies/']){const r=await fetch('https://jessicahaguiwara.arq.br/'+p,{headers:{'User-Agent':UA}});const t=await r.text();console.log('/'+p, r.status, t.length, 'spectra:', t.includes('spectra-gs-utility-classes'))}})()"
```

EVIDÊNCIA QUE VOCÊ DEVE RETORNAR:

- `git diff --stat` e lista de arquivos alterados
- comandos executados + resultado resumido (tamanho antes/depois, 4 URLs)
- o filtro/handle usado e o link da fonte que o documenta
- como a condição "página sem bloco Spectra" foi implementada
- o que NÃO foi testado
- riscos ou efeitos colaterais (ex.: comportamento se o Spectra for atualizado)

CONDIÇÕES DE PARADA:

- Se o único caminho for dequeue incondicional ou hack de HTML, **pare e
  reporte**. Não improvise.
- Se depois de limpar o cache o HTML continuar gigante, pare e reporte onde o
  bloco está sendo reinjetado em vez de tentar esconder.
- Se a evidência contradizer o contexto acima (ex.: alguma página realmente usa
  classe utilitária), pare e reporte com a lista.

CONTRATO DE RETORNO (obrigatório, neste formato):

RESULTADO
status: concluido | parcial | bloqueado
objetivo:
arquivos_alterados:
comandos_executados:
evidencia:
nao_testado:
riscos:
proximo_passo:
