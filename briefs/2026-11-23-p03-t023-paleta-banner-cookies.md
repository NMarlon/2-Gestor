# T-P03-023 — Paleta do banner de cookies (Complianz)

**Projeto:** P-03 Jessica Haguiwara · **Repo:** `C:/MarlonScripts/Jessica Haguiwara`
**Emitido:** 2026-11-23 · **Executor:** OpenCode · **Escritor:** um só
**STATUS: BLOQUEADO POR APROVAÇÃO** — não execute sem a marca `APROVADO` do Marlon.
Mudança visível em todo o site.

---

## Objetivo (escopo único)

Trocar a cor de destaque do banner de cookies — hoje `#3B29FF`, azul elétrico, fora da
paleta do site — pela tinta da paleta. **Nada além disso.**

## CONTEXTO JÁ VERIFICADO (não re-investigue)

Medido em 23/11/2026 na home publicada, 1440 px, via CDP `getComputedStyle`:

- O banner é do plugin **Complianz**. Geometria: **500×313**, `position:fixed`,
  canto inferior esquerdo (`top 516` / `bottom 828`), `z-index 99999`,
  fundo `rgb(220,216,200)` = `#DCD8C8`. **Está bem posicionado e não cobre o conteúdo** —
  `elementFromPoint` sobre o `h1` do hero devolve o próprio `h1`. Não mexa em posição,
  tamanho, `z-index`, fundo nem texto.
- A cor azul **não vem do tema**. Vem de variáveis CSS geradas pelo Complianz, no arquivo
  `wp-content/uploads/complianz/css/banner-1-optin.css`:
  ```
  --cmplz_button_accept_background_color: #3B29FF
  --cmplz_button_accept_text_color:       #ffffff
  --cmplz_button_accept_border_color:     #f2eed4
  --cmplz_hyperlink_color:                #3B29FF
  --cmplz_slider_active_color:            #3B29FF
  ```
  São **3 ocorrências** de `#3B29FF` nesse arquivo (conferido com `grep -c`).
- O botão "Aceito" mede **149×45**, `border-radius: 6px`, fundo `rgb(59,41,255)`,
  texto branco. É o único elemento azul que o visitante vê no banner fechado.
- O link dentro do banner **já está oliva** (`rgb(79,91,67)`), por regra mais específica.
  `--cmplz_hyperlink_color` **não** o alcança. Por isso essa variável **fica fora do escopo**.
- O slider ativo (`--cmplz_slider_active_color`) só aparece quando o visitante abre
  "Escolher preferências". Entra no escopo.

**Contraste medido (WCAG):**

| par | razão | veredito |
|---|---|---|
| `#EDE3D6` sobre `#1A1A1A` (proposto) | **13,72:1** | passa AA e AAA |
| `#FFFFFF` sobre `#3B29FF` (atual) | 7,13:1 | passa, mas é azul |
| `#1A1A1A` sobre `#DCD8C8` (proposto) | **12,18:1** | passa |
| `#3B29FF` sobre `#DCD8C8` (atual) | 4,99:1 | passa por pouco |

## O que fazer

1. **No tema filho** `jessica-haguiwara-child/style.css`, ao final, bloco novo com
   comentário de data e tarefa. Sem `!important` — as variáveis do Complianz são
   declaradas em `:root` e a sua regra vem depois no cascade. Se não pegar, use
   `:root:root` antes de recorrer a `!important`.
   ```css
   /* T-P03-023 (2026-11-23) — paleta do banner de cookies do Complianz */
   :root {
     --cmplz_button_accept_background_color: #1A1A1A;
     --cmplz_button_accept_text_color:       #EDE3D6;
     --cmplz_button_accept_border_color:     #1A1A1A;
     --cmplz_slider_active_color:            #1A1A1A;
   }
   ```
2. **Bump de versão** conforme o gate do repo (`scripts/release.json` + patch em
   `style.css` e `functions.php`). Leia o repo antes; não invente o número.
3. **Deploy com `--dry-run` primeiro.** Divergentes são esperados no dry-run.
   Depois do deploy real, o verificador tem de dar **11 iguais, 0 divergentes, 0 órfãos**.

## Proibido tocar

- `position`, `width`, `z-index`, `background-color` do banner, ou o texto dele.
- Configuração do plugin Complianz no painel — a correção é versionada no tema, não
  em opção de banco. Se o painel sobrescrever o CSS, **pare e reporte**; não mexa no painel.
- `--cmplz_hyperlink_color` — o link já está correto por outra regra.
- Qualquer bloco `.jhw-home-v2` do `style.css`.
- Qualquer página, post ou menu do WordPress. Esta tarefa é só CSS + versão.

## Critério de aceite (verificável)

1. Na home publicada, 1440 px, com o banner visível:
   `getComputedStyle` do `.cmplz-btn.cmplz-accept` devolve
   `background-color: rgb(26, 26, 26)` e `color: rgb(237, 227, 214)`.
2. O botão continua **149×45** e o banner continua **500×313**, `fixed`, mesmo canto.
3. Abrindo "Escolher preferências", o slider ativo é `rgb(26, 26, 26)` — não azul.
4. `grep -c 3B29FF` no CSS servido do banner devolve **0** para as duas variáveis que
   foram sobrescritas (a do link pode continuar, é esperado).
5. `scrollWidth == innerWidth` em 1440 e em 390. Zero overflow.
6. O `h1` do hero continua em **74,88 px** — o CSS não vaza.

## Contrato de retorno

```
RESULTADO:        feito | parcial | bloqueado
status:           o que está no ar agora
arquivos_alterados: caminho + linhas
comandos_executados: comando e saída relevante
evidencia:        os 6 números do critério de aceite, medidos
nao_testado:      o que você não conseguiu medir
riscos:           o que pode quebrar
proximo_passo:    sua recomendação
```

Sem número medido, escreva `não medido`. Não estime.

## Rollback

`git revert` do commit do tema + deploy. A config do Complianz no banco não é tocada,
então o painel continua com o valor original — reverter o tema volta ao azul.
