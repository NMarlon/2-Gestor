# DESPACHO T-P05-001 · GESTOR-P05 → EXECUTOR (OpenCode)

Data: 2026-11-24 · Autor: GESTOR-P05 (perfil `p05-gestor`)

## Antes de qualquer coisa

Você é o **EXECUTOR** do projeto P-05 (Painel Hermes). Seu contrato é o brief:

```
C:\MarlonScripts\2-Gestor\briefs\2026-11-24-p05-t001-kickoff-coletor.md
```

**Leia o brief inteiro** antes de agir. Ele manda no escopo. Este arquivo só
acrescenta regras de execução que o brief não explicita; **não amplia nem reduz**
o escopo, e em caso de conflito vale o brief — exceto nos pontos marcados abaixo
como decisão do gestor, que são resolução de ambiguidade dentro do próprio brief.

## Diretório

Trabalhe em `C:\MarlonScripts\5-Painel-Hermes`. Ele já existe e está **vazio**
(criado pelo gestor só para o despacho funcionar). É sua a responsabilidade de
`git init` e de criar tudo o que o brief pede.

## Decisões do gestor (resolvem ambiguidade do brief)

1. **Linguagem: Python da stdlib.** O brief aceita `.py` ou `.mjs`; fica Python,
   pelo precedente de `2-Gestor/scripts/consumo.py` (sqlite3, stdlib) e porque a UI
   da próxima tarefa é servidor HTTP local. Sem `pip install`. Compatível com
   Python 3.11+ (nesta máquina há `python` 3.11.9 e `python3` 3.14.9 — o comando
   documentado no `README.md` deve funcionar com o que existir; cite o que usou).
2. **A entrega é o coletor e nada além dele.** `relatorio-semanal.py` **não** entra
   hoje: registre-o em `DOCS/05-BACKLOG.md`. UI também não.
3. **`scripts/instalar-agendador.ps1`** existe só como documentação do comando de
   registro. **Não execute, não registre tarefa, não instale nada.** Proteja o
   arquivo com um parâmetro de confirmação (`-IUnderstand`) para que rodá-lo por
   acidente não registre nada.
4. **Cota — regra dura.** Nenhum percentual sem fonte. Se os três caminhos do brief
   falharem, grave `cota.status = "indisponivel"` e `cota.motivo` com o erro técnico
   real (status HTTP, mensagem). Se um caminho devolver número, grave também
   `cota.fonte` com o comando/URL exato — número sem fonte não entra no JSON.
5. **Bancos em somente leitura.** URI `file:...?mode=ro` (e `immutable=1` se
   precisar). **Nunca** copie `opencode.db`/`state.db` para dentro do repo. Perfil
   sem `state.db` (o perfil `conversa` não tem) é **ausência de dado**, não zero.
6. **`auth.json`**: pode ler em memória para a tentativa (b) do brief. Nunca
   imprimir, nunca gravar em arquivo, nunca logar. No relatório, `[REDACTED]`.

## Git (o brief pede commit; isto é como)

- `git init` com branch `master`.
- **Autoria `P05-EXECUTOR`** — nunca a identidade do Marlon:
  `git -c user.name="P05-EXECUTOR" -c user.email="p05@2gestor.local" commit -m "..."`
- `git add` por **caminho explícito**. `git add -A`, `git add .` e `commit -a` são
  proibidos (varrem segredo e lixo).
- **Nenhum remote, nenhum `git push`.** GitHub está bloqueado (`Q-034`).
- Commit ao fim da tarefa, com o coletor já executado com sucesso.

## Verificação que você faz antes de reportar

1. Rode o coletor **duas vezes seguidas** e cole as duas saídas e os dois códigos de
   saída.
2. Conte as linhas da série antes e depois da segunda execução (tem de ser +1).
3. `git grep -iE "sk-|token|secret|password"` no repo e cole a saída (esperado:
   nada, ou só nomes de campo sem valor).
4. `git log --format='%an <%ae> %s'` e cole.
5. Leia o último registro do `stats.jsonl` e confira se os números batem com o que
   existe na máquina (5 perfis, 4 com `state.db`).

## Se algo for impossível

Pare naquele ponto, registre em `DOCS/03-ERROS-E-APRENDIZADOS.md` com o erro real e
diga no relatório em `nao_testado` / `riscos`. **Não invente número, não improvise
escopo novo, não mexa em outro projeto.**

## Contrato de retorno (obrigatório)

```
RESULTADO:
status:
arquivos_alterados:
comandos_executados:
evidencia:
nao_testado:
riscos:
proximo_passo:
```
