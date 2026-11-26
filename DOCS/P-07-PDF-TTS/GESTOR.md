# P-07 · Pathway PDF TTS — caderno do gestor

**Estado:** 2026-11-26 · auditado e liberado para alunos; avisos: precisa de internet, ~27 s até a primeira tela, só PDF com texto (escaneado não serve)

**Perfil:** `pdf-tts` · **Repo:** `C:\MarlonScripts\1-Mini-Projetos\PDF TTS` (repo compartilhado
com outros mini-projetos — commit só por caminho explícito).

## O que é

App Windows que converte PDF do Pathway em audiolivro (MP3/M4B por semana, capítulos, SRT).
Pacotes em `dist/` (19/11/2026). O Marlon quer enviar aos alunos.

## Auditoria de 26/11 (resumo; relatório completo em `briefs/2026-11-26-pdf-tts-auditoria.md`)

- App abre e converte: **22,7 s** para PDF de 4 páginas → `completo.mp3`, `S01–S04.mp3`, `.m4b`,
  `.srt`, capa, `coverage.json`.
- `ffmpeg` **embutido**; vozes via Edge TTS (**precisa de internet**).
- PDF escaneado: mensagem clara em português. PDF com senha: HTTP 400 com causa em inglês.
- `.exe` com assinatura válida (Python Software Foundation).
- ZIP é do dia do último commit de código — não está velho.
- **Não testado:** comportamento sem internet, aviso de disco, clique na interface.
