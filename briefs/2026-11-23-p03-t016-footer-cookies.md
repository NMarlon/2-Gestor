# Brief T-P03-016 — rodapé: link da Política de Cookies

Projeto: P-03 (site Jéssica Haguiwara) · Emitido: 2026-11-23 · Gestor: Hermes

## ESCOPO ÚNICO

Adicionar o link para a Política de Cookies no rodapé, ao lado do link da Política
de Privacidade. **Nada além disso.**

## CONTEXTO JÁ VERIFICADO (não re-investigue)

- Repo: `C:\MarlonScripts\Jessica Haguiwara`. Tema filho: `jessica-haguiwara-child`.
- Versão atual **1.3.7**, em `jessica-haguiwara-child/style.css:8` e
  `jessica-haguiwara-child/functions.php:29` (`JHW_CHILD_VERSION`).
- Rodapé: `jessica-haguiwara-child/parts/footer.html`, linha 79:
  `<p class="jhw-footer-privacy"><a href="/privacy-policy/">Política de Privacidade</a></p>`
- A página `/politica-de-cookies/` **existe e responde 200** (medido em 2026-11-23).
  Título público: "Política de Cookies - Jessica Haguiwara - Arquitetura".
- Hoje essa página **não é linkada em nenhum lugar do site** — é o defeito a corrigir.
- A classe `jhw-footer-privacy` já existe no CSS do tema. Não crie classe nova.
- Deploy: `node scripts/deploy-theme.mjs`, com gate de versão em `scripts/release.json`.
  O `release.json` atual tem 11 arquivos.

## O QUE FAZER

1. Em `parts/footer.html`, no mesmo parágrafo `jhw-footer-privacy`, publicar os dois
   links separados por ` · ` (espaço, ponto médio, espaço):
   `Política de Privacidade · Política de Cookies`
   - Privacidade continua apontando para `/privacy-policy/`.
   - Cookies aponta para `/politica-de-cookies/`.
   - Mantenha o bloco `wp:paragraph` válido e o HTML escapado como está no arquivo.
2. Subir a versão para **1.3.8** nos dois lugares (`style.css` e `functions.php`).
3. Rodar `node scripts/validate-theme.mjs` — precisa sair com 0 erros.
4. Rodar `node scripts/deploy-theme.mjs --dry-run` e **PARAR**.

## PROIBIDO

- Rodar `deploy-theme.mjs` **sem** `--dry-run`. O deploy é decisão do gestor.
- Tocar em `header.html`, em `style.css` além da linha da versão, ou em
  `functions.php` além da constante de versão.
- Alterar textos de copyright, aviso de reprodução, endereço, telefone ou e-mail.
- Instalar, remover ou atualizar plugin. Não entrar no wp-admin.
- Criar página nova no WordPress. A página de cookies já existe.

## CRITÉRIO DE ACEITE (verificável)

- `grep -c 'politica-de-cookies' jessica-haguiwara-child/parts/footer.html` ≥ 1.
- `grep -n '1.3.8' jessica-haguiwara-child/style.css jessica-haguiwara-child/functions.php`
  devolve as duas linhas.
- `node scripts/validate-theme.mjs` → 0 erros.
- `node scripts/deploy-theme.mjs --dry-run` → 11 arquivos listados, nenhum erro de
  gate; divergentes são esperados e devem ser reportados com o nome de cada um.
- `git diff --stat` mostra apenas `parts/footer.html`, `style.css`, `functions.php`
  e o `scripts/release.json` se o dry-run o tiver reescrito.

## CONTRATO DE RETORNO

Responda exatamente com estes campos:

```
RESULTADO:
status: (feito | parcial | bloqueado)
arquivos_alterados:
comandos_executados:
evidencia: (saída literal de validate e dry-run, resumida)
nao_testado:
riscos:
proximo_passo:
```

Não publique no site. Não rode deploy real. Pare no dry-run.
