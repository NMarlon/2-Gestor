# Brief T-P03-019 — limpar os PHP de diagnóstico do docroot

Projeto: P-03 (site Jéssica Haguiwara) · Emitido: 2026-11-23 · Gestor: Hermes

## ESCOPO ÚNICO

Tirar de `public_html` (docroot) **todos** os `jhw-*.php` de diagnóstico que sobraram,
incluindo o `jhw-purge.php`, que executa com chave estática na URL. Nada além disso.

## CONTEXTO JÁ VERIFICADO (não re-investigue)

- Levantados **30** arquivos `jhw-*.php` no docroot na sessão do T-P03-017. Todos
  devolvem 404 para GET anônimo — código `http_response_code(404); exit;` — **menos**
  `jhw-purge.php`, que responde e purga o cache com uma chave estática na URL.
- Eu conferi 11 desses nomes por HTTP e todos deram 404; **404 não prova arquivo
  apagado**, prova só que ele não responde. O risco continua no disco.
- O purge do WPFC **não depende mais** do `jhw-purge.php`: você mesmo publicou o hook
  público `wpfc_clear_all_cache` e o gerador `scripts/diagnostics/purge-wpfc-once.mjs`,
  que emite um PHP de uso único e se apaga. Esse é o caminho daqui pra frente.
- Rodapé publicado já está correto (1.3.8, `<footer>` 3478 B, com o link). Não mexer.

## O QUE FAZER

1. **Listar antes de apagar.** Gerar `backups/jhw-php-manifest-2026-11-23.txt` com
   nome, tamanho e data de modificação de cada arquivo. Sem manifesto, não siga.
2. **Classificar antes de apagar.** Separar em duas listas: (a) diagnóstico inerte
   (404), (b) `jhw-purge.php` e qualquer outro que **responda** — esses saem primeiro.
3. **Apagar, não mover para lixo dentro do docroot.** Use `Fileman::fileop op=trash`
   (API 2) se funcionar; se não, o caminho que você já validou. O destino final tem que
   ser **fora** de `public_html`. Não deixar `.bak`, `.old`, `.txt` com o código dentro
   do docroot.
4. **Provar duas coisas, por arquivo:** (i) o arquivo não está mais no diretório
   (listagem do UAPI), e (ii) a URL devolve 404 **com User-Agent completo de Chrome** —
   com UA curto o ModSecurity devolve 406 e mascara o resultado.
5. **Provar que o site continua de pé:** home 200 duas vezes seguidas, `<footer>` com
   3478 B e `politica-de-cookies` presente, `style.css?ver=1.3.8`.
6. **Parar.**

## PROIBIDO

- Tocar em qualquer arquivo de tema, plugin, core, `.htaccess`, `wp-config.php`.
- Apagar qualquer coisa que não case com `jhw-*.php` (ou equivalente de diagnóstico que
  você tenha criado e comprove ser seu).
- Deixar chave, token ou senha no manifesto ou no relatório — mascare.
- Mexer no rodapé, no cache além do necessário para medir, ou em template part.

## CRITÉRIO DE ACEITE

- Manifesto salvo, com 30 entradas (ou o número real, se divergir — e a divergência
  explicada).
- 0 arquivos `jhw-*.php` no docroot; `jhw-purge.php` incluso.
- Home 200, duas leituras idênticas, rodapé 3478 B com o link, 404 em cada URL apagada.
- Nenhum segredo impresso.

## CONTRATO DE RETORNO

```
RESULTADO:
status: (feito | parcial | bloqueado)
arquivos_alterados: (quantidade apagada + caminho do manifesto)
comandos_executados:
evidencia: (listagem antes/depois, status HTTP de cada URL, as duas leituras da home)
nao_testado:
riscos:
proximo_passo:
```
