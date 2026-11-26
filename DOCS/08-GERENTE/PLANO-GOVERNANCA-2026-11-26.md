# Plano — governança imposta (26/11/2026)

**Autor:** GERENTE · **Aprovado por:** Marlon ("pode fazer aquilo que você sugeriu") · **Status:** em execução
**Origem:** pergunta do Marlon — *"o que é melhor"* sobre estar tudo escrito e nada imposto.

## Problema

Três regras falharam hoje por falta de mecanismo, não de conteúdo: escopo de memória, escrita em
`AGENTS.md`/`SOUL.md` e registro de estado por projeto. Todas estavam escritas em algum lugar e
nenhuma era verificada. Documento novo não resolve — mecanismo resolve.

## Levantamento medido (antes de decidir)

| Item | Medido |
|---|---|
| Cadernos existentes | 4 (`P-03`, `P-04`, `P-05`, `P-06`) |
| Formato de estado | **inconsistente**: P-05 usa `## Estado em uma linha`; P-06 usa `**Estado deixado:**` dentro do texto; P-03 e P-04 não têm linha datada |
| PDF TTS | **sem caderno** no workspace — projeto tem gestor e não tem onde registrar |
| Memória dos gestores | **nenhum** dos 4 perfis tem `MEMORY.md` (nada a auditar hoje, nada impede amanhã) |

## Entregas

### G-01 · Gate de aceite (custo zero)
O retorno do gestor ganha o campo **`Onde está registrado:`** (arquivo + seção). Entrega sem esse
campo não é aceita pelo Gerente. Vai na M-027.

**Aceite:** o campo existe na M-027; o próximo retorno de gestor o traz; eu consigo abrir o
arquivo citado e achar a seção.

### G-02 · Auditoria de caderno (script puro, no digest)
`scripts/check-cadernos.py` varre `DOCS/P-*/GESTOR.md`, lê a linha `**Estado:** AAAA-MM-DD` e
acusa: caderno sem a linha, e caderno com data acima de `--dias` (padrão 7).

**Aceite:** roda nos 5 cadernos; acusa caderno atrasado no teste com data forjada; aparece no
digest das 6h30; exit 2 quando há achado.

### G-03 · Auditoria de memória nos perfis dos gestores
`check-memory.py --perfis` aplica as mesmas regras (§12.4) nos `memories/MEMORY.md` de todos os
perfis, não só no meu.

**Aceite:** hoje deve dizer "sem memória" para os 4; num teste com arquivo forjado, acusa.

### G-04 · Convenção de caderno (habilita G-02)
Todo caderno começa, logo abaixo do título, com:

```
**Estado:** AAAA-MM-DD · uma frase
```

Aplicada aos 4 existentes + caderno novo do PDF TTS (`DOCS/P-07-PDF-TTS/GESTOR.md`).

## Riscos

| Risco | Mitigação |
|---|---|
| Script aponta falso positivo e vira ruído | saída curta, máximo 8 itens, e só no digest |
| Gestor passa a escrever linha de estado protocolar ("ok") | o texto do estado continua sendo lido por mim na medição; a linha é o **gatilho**, não a prova |
| Mais uma convenção para ninguém seguir | entra em `REGRAS.md` §14 e no `AGENTS.md` do papel do gestor — não só no plano |

## Ordem de execução

1. G-04 (convenção + P-07) — sem isso, G-02 não tem o que ler.
2. G-02 (checker de caderno) + teste.
3. G-03 (checker de memória nos perfis) + teste.
4. G-01 (M-027) + §14 no REGRAS.
5. Ligar os dois no digest, medir a saída completa, commitar.
