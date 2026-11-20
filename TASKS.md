
~Info update: Esse arquivo serão de tarefas que eu (o dev) adicionei manualmente oficialmente para tu (Gerente) buscar cumprir.
Você NÃO está autorizado à MODIFICAR o texto exato de cada tarefa, PORÉM no CUMPRIMENTO da tarefa, você deve: [ ] -> [x] (marcá-la), e segundo: adicionar em sub-tópicos da tarefa explicando sobre a conclusão daquela tarefa, como foi concluída etc.


1. [x] Fazer funcionar comunicação Hermes <-> OpenCode

   - **Status: funcionando de ponta a ponta, verificado em 2026-11-20 01:12.**
   - Teste real (`briefs/2026-11-20-canal-teste.md`, log `logs/canal-teste.log`):
     o Hermes disparou o wrapper, o OpenCode leu `PROJETOS_APROVADOS.md` no
     diretório certo, respondeu `PROJETOS: Hermes-Mobile | Reconhecedor de
     Rostos de Imagens` e `CWD: C:\MarlonScripts\2-Gestor | BRANCH: master |
     GITOK: sim`, com `exit=0` e **nenhum arquivo alterado**.
   - Como está montado: `scripts/oc-brief.ps1`
     (`-Dir`, `-Brief`, `-LogPath`). Ele resolve o `opencode-cli.exe` em
     `%APPDATA%\ai.opencode.desktop\cli\<versao>\`, valida que o brief existe,
     roda com `--auto` (sem prompt interativo), injeta `C:\Program Files\Git\cmd`
     no PATH (o `git` do WindowsApps do HermesAgent dá "acesso negado"), passa o
     brief como instrução e grava stdout+stderr em **UTF-8 sem BOM**.
   - Três defeitos corrigidos no caminho: (1) `$ErrorActionPreference='Stop'`
     matava o pipeline quando o nativo escrevia em stderr; (2) `Tee-Object`
     do PS 5.1 não tem `-Encoding` e gravava UTF-16 — agora é `StreamWriter`
     UTF-8 com `AutoFlush`; (3) `2>&1` sumia com o log — agora stderr vai para
     arquivo temporário e é anexado ao final.
   - Regra de uso: brief longo (>2 min) sempre em background com `notify`;
     não usar timeout de foreground (mata o processo pai e deixa o
     `opencode-cli` órfão escrevendo no repo).
