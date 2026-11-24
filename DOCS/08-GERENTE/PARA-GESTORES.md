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
