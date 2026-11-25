# Brief T-P03-033 — M-020: texto do WhatsApp do rodapé (único global)

- **Projeto:** P-03 · `jessica-haguiwara.arq.br`
- **Repo:** `C:\MarlonScripts\Jessica Haguiwara`
- **Ordem que este brief executa:** `DOCS/08-GERENTE/PARA-GESTORES.md`, **M-020** (25/11 17:10).
- **Data:** 2026-11-25 · gestor GESTOR-P03 · executor OpenCode.
- **Estado do tema:** **1.3.11 no ar** (a 404 personalizada subiu hoje, medida por mim; não mexer nela além do item 2 abaixo).

## Escopo — 3 links, só o `text=`

O rodapé tem **2** links de WhatsApp, ambos em `jessica-haguiwara-child/parts/footer.html`:

| linha | onde | classe |
|---|---|---|
| 16 | botão de ação do rodapé | `jhw-footer-button` |
| 57 | link do título da coluna de contato | (dentro de `jhw-footer-col-title`) |

Os dois hoje mandam o texto **antigo**, igual em todas as páginas:

```
literal:   Olá! Quero saber mais sobre os serviços de Arquitetura de Jessica Haguiwara
codificado: Ol%C3%A1!%20Quero%20saber%20mais%20sobre%20os%20servi%C3%A7os%20de%20Arquitetura%20de%20Jessica%20Haguiwara
```

Troque **somente o valor de `text=`** dos dois por este (literal e codificado):

```
literal:    Olá! Quero conversar sobre o meu projeto.
codificado: Ol%C3%A1!%20Quero%20conversar%20sobre%20o%20meu%20projeto.
```

Link final, nos dois: `https://api.whatsapp.com/send?phone=5511983236422&text=Ol%C3%A1!%20Quero%20conversar%20sobre%20o%20meu%20projeto.`
(`phone=` **não muda**; no arquivo o `&` está cru.)

### Item 2 — coerência da 404 (mesmo arquivo de hoje)

`jessica-haguiwara-child/templates/404.html` linha 46 (botão "Fale sobre o seu projeto →")
também carrega o texto antigo. Troque o `text=` dele pelo **mesmo** texto universal acima —
o rodapé e o botão da 404 passam a mandar a mesma mensagem. Nada mais na 404 muda
(sem CSS, sem copy, sem link novo).

### Item 3 — versão

`style.css` (`Version:`) e `functions.php` (`JHW_CHILD_VERSION`): **1.3.11 → 1.3.12**.

## CONTEXTO JÁ VERIFICADO (não re-investigue)

- Deploy e medição de hoje: `templates/404.html` subiu, HTTP **404** real, h1 "Página não
  encontrada", 4 links de serviço, CTA de WhatsApp — medido por mim no ar.
- Dry-run de agora: **12 iguais, 0 divergentes, 0 novos, 0 órfãos**; `scripts/release.json`
  em 1.3.11 com 12 arquivos.
- Os **2** links do rodapé são a única origem do texto antigo no site: medido no HTML
  servido de `/consultoria/` — 3 ocorrências de `api.whatsapp.com/send`, na ordem: CTA do
  corpo (texto novo, intocado), footer linha 16, footer linha 57.
- O botão flutuante "Fale no WhatsApp" é do plugin qlwapp (JS, fora do HTML e fora deste
  escopo).
- O texto antigo **não está** em nenhum `post_content` (T-P03-031 já trocou os 4).

## Proibido tocar

CSS, `theme.json`, menu, header, layout/rótulo do rodapé, cookies/Complianz, SEO/Yoast,
depoimentos, `post_content` das páginas, qualquer arquivo fora de:
`jessica-haguiwara-child/parts/footer.html`, `jessica-haguiwara-child/templates/404.html`,
`jessica-haguiwara-child/style.css`, `jessica-haguiwara-child/functions.php`.

## Critério de aceite (verificável no seu retorno)

1. `grep -c "Quero%20saber%20mais%20sobre%20os%20servi" jessica-haguiwara-child/parts/footer.html` → **0**;
2. o mesmo grep em `templates/404.html` → **0**;
3. `grep -c "Quero%20conversar%20sobre%20o%20meu%20projeto"` em `parts/footer.html` → **2**;
4. `git diff --stat` do commit = **4 arquivos** (footer, 404, style.css, functions.php) e
   `git diff HEAD~1` mostra mudança só nas linhas `text=` e nas duas de versão;
5. `node scripts/validate-theme.mjs` → `TUDO OK` (sem BOM);
6. `node scripts/deploy-theme.mjs --dry-run` → o esperado é **4 divergentes** (footer, 404,
   style, functions) e **0 novos** — **não** "11 iguais": o gate de versão muda style/functions e
   `release.json` não é registrado por você; os outros 8 seguem iguais;
7. **PARE no dry-run.** Não publique, não rode `--record`, não commite `release.json`.

## Contrato de retorno

`RESULTADO / status / arquivos_alterados / comandos_executados / evidencia (as 4 contagens +
o resumo do dry-run) / nao_testado (publicação e medição no ar — é minha) / riscos /
proximo_passo`. Escreva o relatório em português, no log da sessão.
