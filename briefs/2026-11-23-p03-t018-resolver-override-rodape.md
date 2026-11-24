# Brief T-P03-018 — publicar o link de cookies: resolver o override do rodapé

Projeto: P-03 (site Jéssica Haguiwara) · Emitido: 2026-11-23 · Gestor: Hermes

## ESCOPO ÚNICO

Fazer o rodapé publicado voltar a ser o do arquivo `parts/footer.html` (que já tem o
link da Política de Cookies), e provar na URL pública que passou. **Só o rodapé.**

## CONTEXTO JÁ VERIFICADO (não re-investigue)

Você mesmo levantou isto no T-P03-017, e eu confirmei do lado de fora:

- Cache de página **já purgado e limpo**: duas leituras limpas seguidas, idênticas,
  `style.css?ver=1.3.8` nas duas. O HTML servido tem 178248 bytes.
- O rodapé publicado continua **3426 bytes, sem `politica-de-cookies`**.
- Origem provada: `wp_template_part` **ID 185**, `post_name='footer'`, tema
  `jessica-haguiwara-child`, salvo em 2026-11-19 14:11:25, **4917 bytes**.
  O conteúdo do banco é o do arquivo **menos o link novo** (e com travessão).
- Existe outra parte com `post_name='footer'` (ID 7) — é de **outro tema**. Não toque.
- `parts/footer.html` no servidor tem md5 conferido e **tem** o link.

## PLANO (nesta ordem, com prova em cada passo)

1. **Backup antes de tocar.** Salvar o conteúdo atual do template part ID 185 em
   `backups/template-part-185-footer-2026-11-23.json` (conteúdo bruto, ID, tema,
   `post_modified_gmt`). Sem esse arquivo, não siga.
2. **Confirmar o alvo.** Antes de qualquer escrita, reimprimir ID, `post_name`, tema
   e bytes do 185. Se os bytes não forem 4917, **pare e reporte** — o alvo mudou.
3. **Remover o override**, devolvendo a autoridade ao arquivo do tema:
   - se o MCP tiver ferramenta de apagar template part (`wp_delete_template` ou
     equivalente), use-a **com `force`/lixo definitivo**, não para a lixeira;
   - se não houver, use PHP de uso único via UAPI: valida `get_post(185)` (post_type
     `wp_template_part`, `post_name` `footer`, tema do child), chama
     `wp_delete_post(185, true)`, e se auto-apaga no `register_shutdown_function`;
   - **nunca** apague por ID sem as três validações acima.
4. **Purgar o cache** de página de novo (o caminho one-shot que você já usa).
5. **Medir a URL limpa, sem query string, duas vezes seguidas.** Registrar em cada
   leitura: presença de `politica-de-cookies` no `<footer>`, tamanho do `<footer>`,
   versão do `style.css` e md5 do bloco `<footer>`.
6. **Parar.**

## PROIBIDO

- Tocar em qualquer template part que não seja o **185**. Em especial o ID 7 e as
  partes do cabeçalho (`header`) — o menu vive no banco e não é escopo.
- Editar `parts/footer.html`, `style.css`, `functions.php` — já estão prontos.
- Deixar arquivo PHP executável no servidor. Endpoint novo tem que devolver 404
  depois de rodar, e você tem que provar com um GET.
- Limpar os `jhw-*.php` antigos agora — é tarefa separada, já registrada.

## CRITÉRIO DE ACEITE

- `backups/template-part-185-footer-2026-11-23.json` existe, com o conteúdo anterior.
- Duas leituras limpas, **iguais entre si**, com `politica-de-cookies` presente e
  `footer > 3426` bytes.
- Se o link não aparecer: dizer exatamente onde a cadeia quebrou, com a leitura que
  sustenta a conclusão, e **sem** deixar o site pior do que estava. Nesse caso o
  restore do backup é obrigatório antes de encerrar.

## ROLLBACK

Se o rodapé sumir, ficar vazio ou perder conteúdo: recriar o template part a partir do
JSON do passo 1 (`wp_insert_post` com os mesmos campos), purgar o cache e medir de novo.
O site tem que terminar esta tarefa no mesmo estado ou melhor — nunca pior.

## CONTRATO DE RETORNO

```
RESULTADO:
status: (feito | parcial | bloqueado)
arquivos_alterados:
comandos_executados:
evidencia: (as duas leituras limpas, com bytes, versão e md5 do footer)
rodape_publicado: (arquivo | banco | inconclusivo)
nao_testado:
riscos:
proximo_passo:
```
