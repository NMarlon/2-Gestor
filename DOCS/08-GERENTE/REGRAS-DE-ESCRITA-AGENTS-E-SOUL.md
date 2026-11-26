# Regras de escrita em `AGENTS.md` e `SOUL.md`

**Criado:** 26/11/2026, a pedido do Marlon · **Status:** vigente
**Origem da autoridade:** `Definições Oficiais Manuais/Dos GERENTES.md`, itens **23, 24 e 25**;
`DOCS/08-GERENTE/LISTA-DE-PEDIDOS.md`, item **24** (aprovação prévia do Marlon).
Este documento não cria autoridade nova: ele organiza **quem escreve o quê** e **o que pode
entrar** em cada arquivo.

---

## 1. `AGENTS.md` — o mapa por papel

**O que é.** O contrato de leitura do workspace. Todo agente que abre sessão neste diretório lê
este arquivo para saber quem é e o que ler em seguida. É o único arquivo que fala com **todos**
os papéis ao mesmo tempo.

**Quem pode editar.** O **GERENTE**, e **somente com aprovação prévia e por escrito do Marlon**.
Pedido original dele: *"pedir aprovação antes de editar e deixar para o fim da fila"*. Aprovar é
sobre o **texto exato** — não sobre a intenção.

**O que pode conter.**

- Papéis e hierarquia (Gerente → Gestor → Executor).
- A **lista de leitura por papel**, na ordem — é a parte que mais importa.
- Mapa de pastas e arquivos do workspace.
- Regras permanentes transversais (idioma, nunca inventar dado de cliente, segredo só em `.env`,
  deploy é decisão do gestor, contexto é orçamento).
- Protocolo de medição e forma do brief.

**O que nunca entra.**

- Dado de cliente: CAU, área, preço, prazo, obra, depoimento.
- Segredo, token, caminho de `.env`, chave de API.
- **Estado de tarefa** (isso é `04-TAREFAS.md`), nome e dono de gestor individual (isso é
  `07-GESTORES.md` e `PAINEL-DE-GESTORES.md`), histórico de sessão.
- Regra que só vale para um projeto — ela mora no caderno do projeto.

**Teste antes de escrever:** *"isto vale para todo agente, ou só para um?"* Se for um, não é aqui.

---

## 2. `SOUL.md` dos GESTORES — a identidade de um agente

**O que é.** Define **quem** é aquele gestor: o projeto dele, como trabalha, o que não faz, como
fala, o que entrega. Não é documentação técnica nem caderno de tarefas — é caráter e limite.

**Quem pode editar.**

| Quem | Pode? |
|---|---|
| **GERENTE** | **Sim** — item 23: "SOMENTE os GERENTES tem AUTORIDADE para editar o SOUL.MD dos GESTORES" |
| Gestor, no próprio SOUL | **Não sem autorização** de um GERENTE ou do DEV (item 24) |
| Executor (OpenCode) | **Nunca** |

**O que pode conter.**

- O papel e o projeto que ele responde.
- Como ele trabalha: ler antes de agir, medir na fonte, briefar o executor.
- Limites: o que ele não faz (não escreve no repo de outro projeto, não publica sem ordem).
- Voz: idioma, tom, o que evitar.

**O que nunca entra.**

- Estado de tarefa, números do projeto, caminhos de arquivo do repo — isso é o **caderno**
  (`DOCS/P-XX/GESTOR.md`) e o `AGENTS.md` do projeto.
- Segredo, token, credencial.
- **Cópia de regra do `AGENTS.md`.** Regra duplicada diverge com o tempo: um lado muda, o outro
  fica velho, e o agente obedece o lado errado. No SOUL vai o **ponteiro**, não a cópia.

**Teste antes de escrever:** *"isto descreve quem ele é, ou o que ele está fazendo agora?"* Se é
"agora", não é SOUL.

---

## 3. `SOUL.md` do próprio GERENTE

**Só o DEV altera** (item 25): *"GERENTES NÃO estão autorizados à alterar o próprio SOUL.MD SEM
autorização do DEV"*.

O Gerente pode — e deve — **propor** mudança, com o texto exato e o motivo, e **não aplicar**
enquanto não houver "pode" por escrito. Agente que reescreve o próprio caráter sem ninguém ver é
exatamente o que essa regra existe para impedir.

---

## 4. Fluxo obrigatório de alteração

1. **Proposta escrita** — o texto exato (ou o diff), o que muda e por quê.
2. **Aprovação do Marlon por escrito** — para `AGENTS.md` sempre; para `SOUL.md` de gestor,
   aprovação do Gerente; para o SOUL do próprio Gerente, aprovação do DEV.
3. **Aplicação** — commit por caminho explícito, com assinatura do agente (`commit-agent.sh`).
4. **Registro** — o que mudou e por quê, no caderno correspondente.

Alteração silenciosa em qualquer um dos dois é falha de processo, mesmo que o texto seja bom.

---

## 5. Por que a regra existe

- `AGENTS.md` é lido por **todo** agente: uma frase errada ali se propaga para todos os projetos
  ao mesmo tempo.
- `SOUL.md` define **comportamento**: mudá-lo sem controle é mudar o agente, não o documento.
- Um agente que edita o próprio SOUL sem autorização pode, em tese, afrouxar os próprios limites.
  A regra não desconfia de quem é honesto — ela tira a possibilidade de quem não for.
- O **Marlon não é obrigado a reler** esses arquivos toda semana. Aprovação prévia é o que
  substitui essa releitura.
