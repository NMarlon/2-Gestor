# Brief — P-06 · T-P06-009 · ler o planejamento SEM baixar (camada de texto do viewer)

**Data:** 2026-11-25 · **Executor:** OpenCode · **Dir:** `C:\MarlonScripts\81 - Alerta Planejamento Missionario CTM`

## Resultado esperado

O `verificar.py` deixa de tentar baixar o PDF (o dono bloqueou) e passa a **ler o documento
pelo visualizador do Drive**: descobre o número de páginas e extrai o **texto de cada
página, com coordenadas**, para comparar com a versão anterior e dizer o que mudou.

## CONTEXTO JÁ VERIFICADO (não re-investigue — foi medido hoje, com estas URLs)

**1. O visualizador expõe três endpoints internos, e nenhum deles exige login.**

Depois que a página `https://drive.google.com/file/d/<FILE_ID>/preview` carrega num
navegador, ela faz requisições para:

```
https://drive.google.com/viewer/meta?id=<TOKEN>&dsmi=texmex&fssid=<SESSAO>
   → application/json:  )]}'
                        {"pages":7,"maxPageWidth":3200}

https://drive.google.com/viewer/presspage?id=<TOKEN>&dsmi=texmex&fssid=<SESSAO>&page=N
   → application/json:  )]}' [72,841,595, [ <blocos com palavras e coordenadas> ]]

https://drive.google.com/viewer/img?id=<TOKEN>&dsmi=texmex&fssid=<SESSAO>&auditContext=forDisplay&page=N&w=3200&webp=true
   → image/webp (1,18 MB por página em 3200 px)
```

**2. O `TOKEN` não está no HTML.** Ele é criado pelo JavaScript do viewer. A única forma de
obtê-lo é abrir a página num navegador e ler as requisições que ela faz
(`performance.getEntriesByType('resource')`). O token é de sessão e expira — **tem de ser
usado na mesma execução** em que foi capturado.

**3. A camada de texto é a fonte de verdade.** O JSON do `presspage` traz, por página:

```
[72, 841, 595, BLOCO, BLOCO, ...]
                 └── BLOCO = [bbox, [bbox, [ [bbox, "palavra"], [bbox, "palavra"], ... ]]]
     bbox = [x, y, ?, largura]   (unidades do PDF; A4 = 595 x 841)
```

Recursão que funcionou (validada hoje, 3 páginas lidas):

```python
def palavras(no, out):
    if isinstance(no, list):
        if len(no) == 2 and isinstance(no[0], list) and isinstance(no[1], str):
            out.append((no[0], no[1])); return
        for f in no: palavras(f, out)

# agrupar por linha: y arredondado (use y//4 para tolerar 1-2 unidades)
# ordenar por x dentro da linha e juntar com espaço
```

**Atenção:** o documento é uma **grade de horários**. Várias palavras compartilham o mesmo
`y` em colunas diferentes; o agrupamento por `y` junta colunas. Isso é aceitável **desde que
seja determinístico** — o mesmo PDF produz o mesmo texto sempre. Não tente "consertar" a
ordem com heurística esperta: estabilidade vale mais que beleza.

**4. O que NÃO funciona** (testado hoje, para você não repetir): `uc?export=download`
(recusa do dono), `drive.usercontent.google.com/download` (idem), `gdown` (idem),
`viewerng/text` e `viewer/textlayer` (404), `viewer/upload?ds=` (é POST, 400 no GET).

## O que construir

1. **`scripts/capturar_sessao.py`** — abre o preview com
   `python C:\MarlonScripts\2-Gestor\scripts\medir-cdp.py <url_preview> 1200 900 "" --js "<js>"`
   e devolve `{meta_url, img_url, token, fssid}`. O JS que já funcionou:

   ```js
   (async()=>{
     performance.setResourceTimingBufferSize(10000);
     const sc=document.scrollingElement;
     for(let y=0;y<20000;y+=700){ sc.scrollTop=y; await new Promise(r=>setTimeout(r,80)); }
     await new Promise(r=>setTimeout(r,2500));
     const u=performance.getEntriesByType('resource').map(e=>e.name);
     return JSON.stringify({
       meta:u.find(n=>n.includes('/viewer/meta')),
       img:[...new Set(u.filter(n=>n.includes('/viewer/img')))][0]
     });
   })()
   ```

2. **`scripts/ler_paginas.py`** — com o token em mãos: `meta` → número de páginas; para cada
   página, `presspage` → palavras → linhas normalizadas. Devolve
   `{"paginas": [[linha, ...], ...], "n_paginas": N}`.

3. **`verificar.py`** passa a usar esse leitor. O fluxo vira:
   1. listar a pasta (já existe) → arquivo escolhido + `modifiedTime`;
   2. **atalho de mudança:** se nome e `modifiedTime` são iguais ao último registro do Drive,
      sai **0** sem abrir navegador (economiza 1 lançamento e 5 s);
   3. capturar sessão (1 navegador), ler as páginas, comparar com o snapshot anterior;
   4. gravar snapshot de texto (`dados/snapshots/<AAAAMMDD-HHMM>-<sha-do-texto>.json`),
      atualizar `historico.json`, escrever `relatorios/ultima-alteracao.md` e `.html`;
   5. códigos: **0** sem mudança · **10** mudou · **1** erro de leitura (com o motivo) ·
      **2** não consegui listar.
4. **Hash do texto** = sha256 do JSON de páginas. É o que identifica "esta versão".
5. **Fallback honesto:** se o `presspage` falhar numa página, registre `"pagina N: sem texto
   (motivo)"` e marque a leitura como **incompleta** — nunca compare uma leitura incompleta
   com uma completa e chame a diferença de "mudança".

## Proibido

- Tentar burlar a restrição de download (é decisão do dono; nós só **lemos** o que o viewer
  mostra a qualquer visitante com o link).
- Guardar o token em arquivo, log ou commit — ele é efêmero e não deve sobreviver à execução.
- Abrir navegador fora do `medir-cdp.py`.
- Tocar em qualquer coisa fora do repo do P-06.

## Critério de aceite (eu vou rodar)

1. `python scripts/verificar.py` → **exit 10** na primeira execução real, com
   `relatorios/ultima-alteracao.md` contendo algo como
   `lido: 7 páginas · 0 páginas alteradas (primeira leitura registrada)` e o cabeçalho com
   `arquivo`, `modifiedTime`, nº de páginas e origem `viewer/presspage`.
2. Execução imediata seguinte → **exit 0** ("sem mudanças"), sem abrir navegador (prove com
   o contador da ferramenta: mesmo número antes e depois).
3. Simulação de mudança: alterne o snapshot anterior para uma versão com uma linha a menos e
   rode de novo → **exit 10**, com a linha aparecendo como adicionada.
4. Nenhum arquivo de token no repo (`git status` limpo, sem `.json` novo em `dados/` além do
   snapshot).
5. Relatório diz quantos navegadores a tarefa lançou.

## Contrato de retorno

`RESULTADO / status / arquivos_alterados / comandos_executados / evidencia (as 4 saídas
reais) / nao_testado / riscos / proximo_passo`. Commit no repo do projeto com identidade
própria, só caminhos explícitos.
