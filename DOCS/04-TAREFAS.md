# 04 — Tarefas

> Para a próxima IA: pegue a primeira 🟡, siga o "como proceder", ao terminar
> atualize o status, registre a evidência e commite.

Legenda: 🟢 feito e verificado · 🟡 em andamento · 🔴 bloqueado · ⚪ não iniciado

---

## T-001 · Estruturar workspace do gestor 🟢

**Feito:** `DOCS/00` a `06`, `.gitignore`, repo git, commit inicial.
**Falta:** `AGENTS.md` na raiz — bloqueado por aprovação (ver `06-PERGUNTAS.md` Q-02).

---

## T-002 · Verificar e fechar P-01 (Hermes-Mobile) 🟡

**Feito:** servidor `:80` responde `0.23.2`; Tailscale `443/8443/8444` ativos;
repo limpo. Estado registrado em `02-PROJETOS.md`.

**Falta:**
1. Corrigir a deriva da doc: `Hermes-Mobile/DOCS/10-TAREFAS.md` — Fase 2 marcar 🟢
   com a evidência do `tailscale serve status`; Fase 6 marcar como parkeada.
2. Atualizar `DOCS/01-VISAO-GERAL.md` e `AGENTS.md` do projeto com a versão real
   (`0.23.2`) e a data 2026-11-20.
3. Commit no repo `1-Mini-Projetos`, escopo `Hermes-Mobile/`.

**Como proceder:** brief `briefs/2026-11-20-hermes-mobile-doc-sync.md` para o
OpenCode. Não reabrir o que já funciona; é sincronização de documentação.

---

## T-003 · P-02: acervo real + medição 🔴 (depende de Q-01)

**Objetivo:** ter o acervo real acessível e medir o app atual contra ele.

**Falta:**
1. Confirmar com o Marlon qual é o acervo
   (`C:\AREA DE POUSO\Fotos da Missão` está vazio; há
   `C:\Users\Marlon\Downloads\Fotos\transfer_fotos_videos.tar` com 14,7 GB).
2. Definir destino de extração com espaço em disco suficiente.
3. Rodar scan de amostra (500 imagens) e medir segundos/imagem, rostos/imagem,
   erros de leitura.

**Como proceder:** não extrair 14 GB sem autorização de destino. Com amostra,
medir com `time` e registrar em `Reconhecedor/DOCS/`.

---

## T-004 · P-02: escalar clustering e busca ⚪

**Objetivo:** aguentar ~50k rostos sem travar.

**Problema:** `services.py` faz greedy `O(n·k)` em Python puro; `main.py`
carrega a tabela inteira em `similar`/`propagate`.

**Direção:** vetorizar o greedy em blocos com matriz `numpy` (matmul em chunks,
não loop por cluster); avaliar FAISS/HNSW para busca aproximada; paginar
`similar`/`propagate`; guardar embeddings em `.npy`/memmap em vez de BLOB por
linha, se a leitura virar gargalo.

**Critério de aceite:** clustering de 20k embeddings sintéticos em < 2 min;
`/api/faces/{id}/similar` responde < 300 ms com 20k rostos.

**Como proceder:** brief com os números medidos em T-003. Sem medição, não otimizar.

---

## T-005 · P-02: documentação no padrão do Marlon ⚪

**Problema:** `DOCS/` do projeto está em inglês, com 6 arquivos curtos
(`TASKS.md`, `ERRORS_LEARNINGS.md`...), fora do padrão numerado usado nos outros
projetos.

**Feito quando:** existirem `00-INDICE`, `01-VISAO-GERAL`, `09-ERROS-E-APRENDIZADOS`,
`10-TAREFAS`, `11-BACKLOG-E-IDEIAS`, e `AGENTS.md` apontando para eles.

**Como proceder:** migrar o conteúdo existente (não jogar fora), em português,
mantendo histórico no git.
