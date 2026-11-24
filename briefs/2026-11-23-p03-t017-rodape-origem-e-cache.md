# Brief T-P03-017 — o rodapé publicado não é o do arquivo: medir, explicar, destravar

Projeto: P-03 (site Jéssica Haguiwara) · Emitido: 2026-11-23 · Gestor: Hermes

## ESCOPO ÚNICO

Fazer o link da Política de Cookies aparecer na URL pública e, se ele não aparecer,
**provar por que** — sem editar banco, sem editar tema além do que já está feito.

## CONTEXTO JÁ VERIFICADO (não re-investigue)

Feito por mim agora, com medição registrada:

- T-P03-016 entregue e **deploy real já executado por mim** (não refaça):
  `parts/footer.html` com o link novo, versão **1.3.8** em `style.css` e `functions.php`.
  Upload: 3 arquivos OK; verificação pós-deploy: **11/11 arquivos conferem**.
- Medição da URL pública **sem query string** (o que o visitante recebe):
  `style.css?ver=1.3.7`, rodapé **3426 bytes**, sem o link de cookies.
- Medição com `?cb=1` (bypass do cache de página):
  `style.css?ver=1.3.8`, rodapé **3701 bytes**, e **mesmo assim sem o link**.
  Conclusão parcial: os arquivos novos estão no servidor, mas **o rodapé servido não
  vem de `parts/footer.html`** — há um `wp_template_part` no banco sobrescrevendo.
- O HTML do rodapé publicado difere do arquivo em três caracteres: usa travessão
  `–` onde o arquivo tem hífen, e "Instagram – em breve" onde o arquivo tem "·".
  É a assinatura de conteúdo passado pelo editor de site, não pelo arquivo.
- O cache de página do WP Fastest Cache serve HTML velho para visitante anônimo.
- Não temos login de wp-admin no `.env` (só CPANEL_* e WORDPRESS_MCP_TOKEN).
- O token do `.env` **não** autentica `/wp/v2/` (devolve `rest_not_logged_in`); ele
  serve o endpoint do plugin `easy-mcp-ai` em `/wp-json/easy-mcp-ai/v1/mcp`, que só
  responde ao cliente MCP (Mod_Security devolve 406 para requisição manual).
- Arquivos de diagnóstico antigos (`jhw-*.php` em `backups/`) **não estão mais no ar**
  — conferi os 11, todos 404.

## O QUE FAZER, NESTA ORDEM

1. **Purgar o cache do WP Fastest Cache** por um caminho que você já saiba usar
   (MCP, ou PHP de uso único via UAPI do cPanel). Se usar PHP:
   - o arquivo chama `wp_cache_clear_cache()` / a função de purge do WPFC e depois
     **se apaga** (`@unlink(__FILE__)`) — não deixe endpoint órfão no servidor;
   - ele não pode ficar acessível depois de rodar: confirme com um segundo GET que
     devolve 404.
2. **Medir de novo** a URL limpa, sem query string, duas vezes seguidas:
   versão do `style.css`, tamanho do `<footer>`, presença de `politica-de-cookies`.
3. **Se o link não aparecer**, provar a existência do override:
   - usar o MCP para listar os `wp_template_part` (slug `footer`, tema
     `jessica-haguiwara-child`) e **reportar o conteúdo do rodapé salvo no banco**;
   - comparar com `parts/footer.html` do disco e dizer, caractere a caractere, onde
     divergem.
4. **Parar.** Não edite o conteúdo do template part no banco. O que está publicado
   no rodapé é decisão do gestor e da cliente.

## PROIBIDO

- Editar `wp_template_part`, página, menu ou configuração do WordPress.
- Rodar `deploy-theme.mjs` de novo (nada mudou desde o último).
- Instalar/remover plugin.
- Deixar qualquer arquivo PHP executável no servidor depois de terminar.
- Mexer em `parts/header.html` ou `style.css`.

## CRITÉRIO DE ACEITE

- Duas leituras limpas seguidas, iguais entre si, com a versão e o tamanho do rodapé
  registrados.
- Resposta objetiva: **o rodapé publicado vem do banco ou do arquivo?** Com a
  evidência que sustenta a resposta.
- Se vem do banco: conteúdo do rodapé salvo, lado a lado com o do arquivo.
- Nenhum arquivo PHP novo acessível por URL ao final.

## CONTRATO DE RETORNO

```
RESULTADO:
status: (feito | parcial | bloqueado)
arquivos_alterados:
comandos_executados:
evidencia: (as duas leituras, com versão e bytes; o diff do rodapé)
origem_do_rodape: (banco | arquivo | inconclusivo)
nao_testado:
riscos:
proximo_passo:
```
