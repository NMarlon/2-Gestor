# Hermes-Mobile — sincronizar documentação com a realidade verificada

## Contexto

O projeto está em `C:\MarlonScripts\1-Mini-Projetos\Hermes-Mobile` (dentro do repo
`C:\MarlonScripts\1-Mini-Projetos`). O sistema **está funcionando**; o problema é
só documentação atrasada.

Evidências coletadas hoje (2026-11-20) pelo gestor — não precisa re-sondar:

- `curl http://127.0.0.1/api/status` → `200`, `"version": "0.23.2"`,
  `gateway_running: true`.
- `tailscale serve status` → três rotas ativas:
  `443 → 127.0.0.1:28894` (OpenCode), `8443 → 127.0.0.1:80` (Hermes),
  `8444 → 127.0.0.1:9120` (Webapp).

## Tarefa

Sincronizar a documentação com esses fatos. **Somente documentação.**

1. `DOCS/10-TAREFAS.md`
   - Fase 2 (Tailscale na porta 8443): marcar como concluída 🟢, com a data
     2026-11-20 e uma linha de evidência citando `tailscale serve status` e as
     rotas acima.
   - Fase 6 (plugin de push / `ateymoori/pomelu-hermes-plugin`): marcar como
     parkeada, registrando que é decisão do Marlon deixar para depois.
2. `DOCS/01-VISAO-GERAL.md`: onde aparecer versão antiga (0.23.1) ou porta
   antiga, atualizar para `0.23.2` e as portas reais (443/8443/8444).
3. `AGENTS.md` do projeto: se houver seção "estado atual" desatualizada,
   atualizar com 0.23.2 e a data 2026-11-20.
4. `README.md`: idem, se citar versão/porta.

## Restrições

- Não altere código, scripts, systemd, Tailscale ou config. Nada de deploy.
- Não renomeie nem crie arquivos novos. Não traduza a documentação existente.
- Não faça `git commit` nem `git push` — o gestor commita.
- Se encontrar divergência que não esteja nesta lista, **não invente**: anote no
  fim da resposta e deixe como está.

## Critério de aceite

- `git status --short` no repo pai mostra alterações apenas em arquivos `.md`
  dentro de `Hermes-Mobile/`.
- `grep -rn "0.23.1" Hermes-Mobile/DOCS AGENTS.md README.md` não retorna nada.

Responda com a lista de arquivos alterados e o que mudou em cada um (1 linha cada).
