# Janela de perguntas — regra do Marlon (25/11/2026)

> Palavras dele: *"somente entre os horários das seis e meia até as dez horas da manhã
> permitam perguntas que exijam que eu, o DEV, manualmente faça alguma coisa. Porque fora
> desse horário, das dez da manhã até as 21, eu vou estar trabalhando fora."*

## A regra

| Horário | O que os agentes fazem |
|---|---|
| **06:30 – 10:00** | **Janela de perguntas.** O que exige ação manual do DEV pode ser perguntado e esperado. |
| **10:00 – 21:00** | **Trabalho autônomo.** Ninguém pergunta. O que travar vira pendência registrada e o agente segue no que não depende dela. |
| **21:00 – 06:30** | **Autônomo também.** Ele pode aparecer, mas a regra não depende disso. |

## O que conta como "exige ação manual do DEV"

- criar/colar credencial (PAT, `AW-`, senha);
- clicar em algo que só ele acessa (wp-admin, conta de Ads, painel de hospedagem);
- decidir algo que muda o que o cliente vê — **quando não houver default seguro**;
- autorizar gasto, publicação ou remoção.

Não conta: escolha técnica com default reversível, redação de texto, ordem de execução,
nomenclatura. Isso o agente decide e registra.

## O que nunca espera a janela

Segurança, perda de dado, mudança visível ao cliente sem aprovação, e qualquer coisa
irreversível. Nesses casos: **para e reporta na hora**, independente do horário.

## Default quando a pergunta não pode esperar

Escolher a opção **mais conservadora e reversível**, registrar em `06-PERGUNTAS.md` com o
default aplicado, e seguir. A pergunta fica na fila para a próxima janela.

## Digest das 06:30

Toda manhã às **06:30**, um resumo das ações que dependem dele, por projeto:

- fonte: bloco `<!-- DIGEST:INICIO -->` de `DOCS/08-GERENTE/PENDENTES.md`;
- entrega: cronjob `b9ef34e0295c` (`no_agent`, script puro) — **não gasta token**;
- script: `scripts/digest-manha.py` (versionado aqui; wrapper no perfil do Gerente).

Se o bloco estiver vazio, nada é enviado. Digest com item inventado é pior que digest nenhum.
