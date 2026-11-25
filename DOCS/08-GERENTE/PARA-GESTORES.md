# Para os gestores — caixa de entrada do GERENTE

Canal criado com base em `Definições Oficiais Manuais/Dos GERENTES.md`, itens 4 e 5
(GERENTE ↔ gestor: comunicação direta permitida, nos dois sentidos).

**Como funciona** (revisado em 24/11, depois de medir que o canal tinha 3 mensagens
e **zero** acks — protocolo que ninguém executa é enfeite)

- O GERENTE **acrescenta** um bloco no fim. Nunca edita bloco antigo, nunca apaga.
- O gestor **não responde "recebi"**. O ack é o efeito: o próximo commit dele no
  caderno (`DOCS/P-XX-*/GESTOR.md`) com a linha `Estado:` atualizada. Ack explícito
  custa token e não informa nada — regra adotada de protocolos de coordenação entre
  agentes ("silence = success"; a ausência de escalonamento é o ack).
- **Escalonamento é a única mensagem que o gestor manda de volta**: o que travou,
  por quê, e qual decisão destrava. Vai no caderno, seção `Escalonamento`, e aparece
  na auditoria. Discussão entre gestor e Gerente não passa de **3 turnos**; do
  contrário vira documento, não conversa.
- Resposta de entrega, quando o Gerente pedir, segue contrato fixo:
  `RESULTADO / evidencia / nao_testado / riscos / pedido`.
- Nada de instrução aqui que contrarie `AGENTS.md` ou o brief em vigor: em conflito,
  vale o brief, e o gestor abre pergunta.
- **Dúvida que só o Marlon resolve** não para no gestor nem no Gerente: vira uma
  linha em `DOCS/06-PERGUNTAS.md` com default declarado, e o trabalho segue pelo
  default até ele responder (item 14 do `Dos GERENTES.md`).

---

## M-001 · P-03 · 2026-11-23 22:50 · prazo 24/11

Para o gestor do P-03 (site Jessica Haguiwara). Quatro pontos, todos medidos hoje.

1. **Correção do GERENTE (24/11): este item estava errado — não há pendência de
   versão.** Rodei `node scripts/validate-theme.mjs` e o bloco de release passa nos
   três testes: baseline 1.3.7 com 11 arquivos, 3 arquivos alterados desde então e
   versão em 1.3.8, e 1.3.8 > 1.3.7. Baseline desatualizada **é o estado normal**
   entre um release e o seguinte; ela só é regravada (`--record`) depois de gerar o
   ZIP. O que continua seu: no próximo deploy, rodar `--record` como último passo e
   colar a saída. O gate está de pé.
2. **`briefs/2026-11-23-p03-t021-webp-home.md` existe e não está na fila.** Está
   claro no `git status`: arquivo não rastreado. Antes de executar, registrar
   `T-P03-021` em `04-TAREFAS.md`, no fim do bloco do projeto.
3. **Commit por arquivo.** O `6676141` levou dois arquivos do GERENTE (469 linhas)
   junto do seu trabalho. Nada se perdeu, mas o rastro ficou errado. `git add`
   explícito, nunca `git add -A`. Depois de hoje, assinar com a própria identidade
   (ver `REGRAS.md` §4.1).
4. **Depoimentos: congelados.** Os três do HTML servido (`Amanda & Ricardo`,
   `Lucas Mendes`, `Camila Torres`, com 5 estrelas) são fictícios e só têm a etiqueta
   `EXEMPLO` de 8 px. Não mexer neles até o Marlon responder `Q-025`. Se ele mandar
   tirar, o brief vem com o texto a remover e o critério de aceite em URL.

**O que não estou pedindo:** nada de deploy. Nenhuma mudança visível ao cliente sai
sem ok por escrito.

---

## M-002 · P-02 e P-04 · 2026-11-23 22:50 · sem destinatário

Não há gestor nomeado para P-02 nem P-04 (`Q-024`). Fica registrado para quando
houver: o P-02 tem serviço de pé e acervo real com `T-005`…`T-007` abertas; o P-04
está construído, com 0 `PENDENTE`, e **não publica** — o repo não tem `remote` e
`Q-016` não foi respondida. Quem assumir começa lendo
`08-GERENTE/AUDITORIA-2026-11-23.md` §6 e `MEDICOES-2026-11-23.md` §3.

---

## M-003 · P-03 · 2026-11-24 · prazo 25/11

Para o gestor do P-03. Três correções de rumo; uma delas revoga item do `M-001`.

1. **Depoimentos: NÃO congelar, e não remover.** O item 4 do `M-001` está revogado.
   O Marlon respondeu `Q-025`: os três fictícios ficam, porque são **exemplo de
   layout** para o cliente, marcados como `EXEMPLO`. O que não pode é tirar a
   etiqueta, apagar o aviso ou deixar parecer depoimento real. `AGENTS.md` regra 2
   foi emendado com a exceção — leia antes de mexer na home. Sem "melhoria" que
   aumente as estrelas ou o tamanho do texto.
2. **`scripts/release.json`: item 1 do `M-001` corrigido — não há pendência.** Rodei
   o validador: `PASS release.json: baseline 1.3.7, 11 arquivos`; `PASS versao subiu
   junto com a alteracao` (3 arquivos desde 1.3.7, versão em 1.3.8); `PASS 1.3.8 apos
   1.3.7`. Baseline só se regrava com `--record` depois de gerar o ZIP. No próximo
   deploy, esse é o último passo.
3. **Commit assinado.** `scripts/commit-agent.sh` existe neste workspace; a forma
   equivalente é `git -c user.name="GESTOR-P03" -c user.email="p03@2gestor.local"
   commit -m "..."`, com `git add` por caminho. Nunca `--amend` em commit alheio.

**O que não estou pedindo:** deploy. Nada visível ao cliente sem ok por escrito.

---

## M-004 · P-03 · 2026-11-24 21:40 · prazo 26/11

Para o gestor do P-03. **Ordem de execução: T-P03-026.** O Marlon aprovou a revisão
editorial (Q-033) com uma exceção. **Fila:** só depois de T-P03-025 fechar — um
escritor por vez no repo do projeto.

1. **Aplicar 10 das 11 mudanças** de `DOCS/P-03-Jessica-Haguiwara/REVISAO-EDITORIAL-2026-11-24.md`,
   nas 4 páginas de serviço: C1, C2, C3, C4 (consultoria), P1 (projetos), G1, G2
   (gestão de obra), M1, M2, M3 (chave na mão).
2. **P2 está vetada.** Não toque em "Briefing e conceito: entendimento da rotina, do
   estilo e das necessidades." A proposta troca informação por poesia; o Marlon
   decidiu manter o original. Se o executor "melhorar" essa linha, é erro de escopo.
3. **Texto exato vem do documento.** Não reescreva as frases por conta própria nem
   invente terceira versão. O documento tem o "depois" literal para cada item — o
   OpenCode aplica aquela string. Se uma string não casar com o que está no banco,
   **pare e reporte**, não adapte.
4. **Proibido nesta tarefa:** mexer em CSS, JS, `functions.php`, menu, header, rodapé,
   banner de cookies, título/SEO, depoimentos, formulário. É troca de copy dentro de
   `post_content` das 4 páginas. Se o texto estiver em bloco, altere o bloco; se
   estiver em template do tema, **pare e reporte** — isso muda o escopo.
5. **C4 tem risco próprio:** o texto pré-preenchido do WhatsApp ("Olá! Quero saber
   mais sobre os serviços de Arquitetura de Jessica Haguiwara") aparece 5× por página
   no HTML servido. Confirme onde ele nasce antes de tocar: se não for no mesmo
   bloco do botão, **deixe C4 de fora** e reporte — os outros 9 seguem.
6. **Medição obrigatória, antes e depois**, com o protocolo do `AGENTS.md`: URL sem
   query string, duas leituras iguais, registrar UA e comando. Baseline medido por
   mim em 24/11: `/consultoria/` 149.338 B · `/projetos/` 149.167 B · `/gestao-de-obra/`
   149.132 B · `/chave-na-mao/` 149.054 B. **Esses bytes vão mudar** (o texto muda);
   o que não pode mudar é o HTTP 200 nas 4 e o resto da página.
7. **Critério de aceite:** as 10 strings novas presentes no HTML servido, as 10
   antigas ausentes, 4× HTTP 200, e o "antes" de C1/C2/P1/G1/M2 verificável contra a
   medição de hoje. Rollback = reverter o commit no repo do projeto.
8. **`--dry-run` e para.** Deploy não está autorizado por esta ordem.

**Contexto já verificado (não re-investigue):** 11 de 11 citações "antes" conferidas
por mim no HTML servido hoje. Não existe `<article class="jhw-service">` nas páginas
no ar — a copy está em `main` → `h1` → `div.entry-content`. O documento está commitado
(`51ade5d`, GESTOR-P03).

**O que não estou pedindo:** deploy, mudança de layout, e a P2.

