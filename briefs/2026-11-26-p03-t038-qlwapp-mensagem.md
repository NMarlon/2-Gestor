# Brief — T-P03-038 · qlwapp: mensagem do botão flutuante

Projeto: P-03 · Jessica Haguiwara (`C:\MarlonScripts\Jessica Haguiwara`)
Data: 2026-11-26 · Origem: M-025 (ordem), M-022 item 1 (autorização)
Executor: OpenCode · Autor do commit: `EXECUTOR-P03`

## CONTEXTO JÁ VERIFICADO (não re-investigue)

- Home servida `https://jessicahaguiwara.arq.br/` medida hoje pelo gestor: HTTP 200,
  **181.045 bytes**, md5 `8293a41158f13bb16ec84945dd9eee6a` em duas leituras (UA
  Chrome/131, sem query string, sem no-cache).
- O JSON inline do qlwapp aparece **duas vezes** no HTML (`data-contacts` e
  `data-primary-contact`), e em cada uma o campo `message` está hoje como:
  `Olá! Quero saber mais sobre os serviços de Arquitetura de Jessica Haguiwara` +
  quebra de linha no fim (no HTML sai como `Ol\u00e1! ... Haguiwara\n`).
- O mesmo JSON tem `"response":"Escreva sua mensagem"` e um `message` vazio em outro
  ponto do objeto. **Não toque nesses dois.**
- O MCP WordPress deste site tem **117 ferramentas e nenhuma escreve option**
  (`wp_get_site_settings` só lê). Por isso esta tarefa NÃO se faz por MCP.
- O caminho já usado neste projeto para banco é PHP de uso único no docroot via cPanel
  UAPI `Fileman::save_file_content`, auto-destrutivo. Referência pronta:
  `scripts/diagnostics/purge-wpfc-once.mjs` (leia antes de escrever o seu; copie o padrão
  de nome aleatório, `register_shutdown_function` + `unlink`, segunda leitura 404 e
  fallback de texto inerte).
- WP Fastest Cache serve HTML velho: depois de gravar, purgue com
  `do_action( 'wpfc_clear_all_cache', true )` no mesmo script.

## ESCOPO (uma coisa só)

Trocar **somente** a mensagem do contato primário do qlwapp para exatamente:

```
Olá! Quero conversar sobre o meu projeto.
```

(sem quebra de linha no fim; acento e pontuação exatamente como acima)

## COMO FAZER

1. Antes de qualquer escrita: `git log -1` e `git status` no repo do site. Se houver
   commit novo que não seja deste projeto (autor `EXECUTOR-P03` ou `GESTOR-P03`), PARE
   e reporte. Não faça `git add -A`, não dê `push`.
2. Crie `scripts/diagnostics/qlwapp-message-once.mjs` no repo, no padrão do
   `purge-wpfc-once.mjs`:
   - gera `jhw-once-<16 hex>.php`, sobe por `Fileman::save_file_content` no docroot;
   - o PHP exige `?k=<16 hex>` gerado na hora (senão responde 403 e se apaga);
   - **Fase A — sonda read-only:** `get_option('qlwapp')`; devolve em JSON a estrutura
     (chaves de primeiro nível, quantos contatos, e para cada contato `id`, `phone`,
     `message`). Se a opção não existir, ou se o texto antigo não estiver em
     `contacts[*]['message']`, **PARE sem escrever** e reporte a estrutura encontrada.
   - **Fase B — escrita (só se a Fase A bater):** guarda o valor antigo inteiro
     (serializado em JSON) no retorno; altera **apenas** o `message` do contato cujo
     texto antigo casa; `update_option('qlwapp', $novo)`; relê a opção e devolve
     `old_message`, `new_message`, `updated=true/false`.
   - Purga o WPFC depois da escrita.
   - Apaga-se sempre (`unlink` no shutdown) e a segunda chamada tem de dar 404; se não
     der, sobrescreve com texto inerte (mesmo fallback do purge).
3. Salve o JSON da Fase A (valor antigo completo) em
   `backups/qlwapp-option-2026-11-26.json` e commite esse arquivo junto — é o rollback.
4. Meça o HTML servido você mesmo, duas vezes, UA Chrome/131, sem query string:
   `https://jessicahaguiwara.arq.br/` e uma URL inexistente (para pegar a 404, ex.:
   `https://jessicahaguiwara.arq.br/pagina-que-nao-existe-t038/`). Critério:
   - HTTP 200 (home) e 404 (inexistente);
   - **2 ocorrências** de `Olá! Quero conversar sobre o meu projeto.` em cada página
     (JSON inline, podendo sair com escape `\u00e1`);
   - **0 ocorrências** de `Quero saber mais sobre os servi` em cada página;
   - `response` continua `Escreva sua mensagem`.
5. Rode `node scripts/validate-theme.mjs` só para provar que nada do tema mudou (não é
   obrigatório para esta tarefa; se não existir, diga).

## PROIBIDO

- Tocar em qualquer arquivo do tema (`jessica-haguiwara-child/**`), em CSS, JS ou PHP do
  tema. Esta tarefa não é tema.
- Mexer em outra opção, em outro contato, no `response`, no telefone ou no nome.
- Editar arquivo do plugin qlwapp.
- Deixar o PHP no servidor, imprimir token do `.env`/cPanel no relatório ou no commit.
- Publicar/deployar qualquer coisa. `deploy-theme.mjs` não roda nesta tarefa.
- `git add -A` / `git add .` / `commit -a`. Commit por caminho explícito, com
  `scripts/commit-agent.sh EXECUTOR-P03 -m "..." -- <caminhos>` (ou
  `git -c user.name="EXECUTOR-P03" -c user.email="p03-exec@2gestor.local" commit`).

## CRITÉRIO DE ACEITE (verificável)

- [ ] `backups/qlwapp-option-2026-11-26.json` existe e contém o texto antigo;
- [ ] HTML servido da home: 2× texto novo, 0× texto antigo, `response` intacto;
- [ ] 404: idem;
- [ ] o PHP de uso único devolveu 404 na segunda chamada (prova no relatório);
- [ ] `git log -1` do site com commit de `EXECUTOR-P03`, só os caminhos desta tarefa;
- [ ] nenhum arquivo de `jessica-haguiwara-child/` no diff.

## RETORNO (contrato de 8 campos)

```
RESULTADO:
status: CONCLUÍDO | BLOQUEADO | AGUARDANDO_DECISÃO
arquivos_alterados:
comandos_executados:
evidencia: (URL, UA, código HTTP, bytes, md5 das duas leituras, ocorrências)
nao_testado:
riscos:
proximo_passo:
```

Se a Fase A não bater com o esperado: status **BLOQUEADO**, com a estrutura crua da opção
no campo `evidencia`, e **não escreva nada**.
