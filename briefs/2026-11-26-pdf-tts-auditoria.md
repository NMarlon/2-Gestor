# Auditoria — Pathway PDF TTS antes de enviar aos alunos

**Data:** 26/11/2026 · **Quem mediu:** gestor `pdf-tts` (conversão, vozes) e Gerente (duplo clique,
escaneado, senha, frescor, assinatura) · **Pacote:** `dist/Pathway-PDF-TTS-Windows-PyInstaller.zip`
(121 MB, build de 19/11/2026 12:12) · **Máquina:** Windows 11, o mesmo PC do Marlon.

## Veredito

**Pode enviar.** O app abre e converte de verdade, com o pacote completo. Três coisas precisam ir
no recado ao aluno, senão ele trava por expectativa errada.

## O que foi medido

| Item | Resultado |
|---|---|
| App abre como o aluno abre (sem console, sem `PYTHONPATH`) | **sim**, primeira resposta em **26,8 s** |
| Vozes | `/api/voices` → **200** com **3 vozes pt-BR** em 1,16 s (Edge TTS, precisa de internet) |
| Conversão real | PDF de 4 páginas → 4 capítulos → **done em 22,7 s** |
| Arquivos gerados | `completo.mp3`, `S01–S04.mp3`, `completo.m4b`, `S01–S04.m4b`, `.srt`, `cover.jpg`, `coverage.json` |
| Cobertura | 4/4 páginas narradas, 0 descartadas |
| ffmpeg | **embutido** no pacote (`ffmpeg.exe`, `ffprobe.exe`) — aluno não instala nada |
| PDF escaneado (sem texto) | mensagem clara em português: *"Este PDF não tem camada de texto. A v1 não consegue narrar PDFs escaneados; use um PDF com texto ou aguarde o OCR."* |
| PDF com senha | `HTTP 400` — *"Não foi possível ler o PDF: File has not been decrypted"* (a causa sai em inglês) |
| Frescor do ZIP | o único commit posterior ao build (`a0fccef`, 12:13) toca **só documentação** — nenhum código ficou de fora |
| Assinatura do `.exe` | **válida**, assinada por *Python Software Foundation* (o Python portátil) — sem "editor desconhecido" |

## O que vai no recado ao aluno (obrigatório)

1. **Precisa de internet.** As vozes vêm do Edge TTS. Sem conexão, não narra.
2. **A primeira tela demora ~27 s.** Não clique duas vezes: a segunda instância só diz "já aberto"
   e o aluno acha que quebrou.
3. **PDF escaneado não serve.** Tem que ser o PDF do curso **com texto** (o baixado do site, não
   foto/print).

## Não testado (honestidade)

- **Sem internet:** não simulei. Sei que a voz depende de rede; não sei qual mensagem o aluno vê
  quando cai a conexão no meio.
- **Aviso de disco:** 1 GB por livro. Não confirmei se o app avisa antes de encher o disco.
- **Clique real no navegador na interface:** medi pela API (`/api/analyze`, `/api/jobs`); a tela
  em si não foi clicada.

## Ruído de ambiente (não é bug do produto)

- `PYTHONPATH` do Hermes vaza para o app e quebra o `pydantic_core`. É o meu shell, não o aluno.
- `OSError 22` no `tqdm` aparece quando a saída padrão é redirecionada para arquivo morto. No
  caminho do aluno (duplo clique) **não aconteceu**.
- Uma cópia de teste minha ficou religando o servidor na porta 8765 e atrapalhou o gestor por
  vários minutos. Encerrada.
