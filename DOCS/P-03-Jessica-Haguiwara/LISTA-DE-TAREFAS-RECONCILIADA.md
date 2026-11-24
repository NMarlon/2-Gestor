# Lista de tarefas do Marlon — reconciliada com o site (2026-11-23)

Fonte: `planejamento/Obsidian Pages/Arquivo de Tarefas.md` + páginas linkadas
(`Menu Superior`, `Footer`, `TODAS AS PÁGINAS vão ter`, `TEMA`).
Cada item foi conferido no HTML servido ou na API pública do WordPress.
A lista original não foi alterada — as caixas continuam como estavam.

## A. Pendente e visível ao cliente — fazer

| # | Tarefa (como está na sua lista) | Estado medido | Ação |
|---|---|---|---|
| A1 | **Menu Superior › Soluções (hover) com 3 subitens**: Consultoria, Projeto, Gestão de Obra | Menu usa `wp:navigation ref:6`. No site não existe a palavra "Soluções". O WordPress tem **4 páginas** (home, privacidade, cookies, obrigado) — **as três páginas não existem** | Criar 3 páginas + montar o submenu. É obra de tema, não ajuste de menu |
| A2 | **Imagens em WebP/AVIF** (Converter for Media) | **0 de 9 imagens** em WebP na home | Converter; ganho estimado relevante no peso |
| A3 | ~~Minificar CSS e JS~~ | **Já está minificado.** Os 5 CSS são servidos por `cache/wpfc-minified/` (WP Fastest Cache), uma regra por linha. O problema é **volume**, não minificação: 218 KB (Spectra + Forminator), 103 KB (tema + fontes), 72 KB (Complianz), 22 KB (AOS) | Rebaixado. A alavanca é enxugar Spectra, não minificar |
| A4 | ~~Lazy loading~~ | 7 de 9 imagens com `loading="lazy"`. As 2 sem lazy são **o logo do header** | Nada a fazer: logo acima da dobra carrega imediato, de propósito |
| A5 | **CAU no rodapé** | Ausente | Depende da cliente (número + UF) |
| A6 | **Instagram no rodapé** | Publicado como "Instagram · em breve" | Depende da cliente (perfil) |
| A7 | **Política de Cookies linkada** | A página existe (`/politica-de-cookies/`, 200) e **não é linkada em lugar nenhum** do site | T-P03-016, em execução |
| A8 | ~~Botão flutuante de WhatsApp~~ | Plugin **`wp-whatsapp-chat` instalado** e ativo. Ele injeta o botão por JavaScript, por isso não aparece no HTML cru | Feito |

## B. Feito na prática, caixa ainda vazia — pode marcar

| Tarefa | Evidência |
|---|---|
| Forminator para os formulários | Formulário **ID 168** no ar, na home |
| WPvivid para backup | **16 execuções**, última 22/11 21:15, 236,6 MB, OneDrive |
| Google Analytics | Site Kit 1.188.0 + GTM `GT-TBVGGKRR` + GA4 `G-NGGYW0ZYHP` |
| Horário de Brasília nas configs | WordPress com GMT **−3** |
| Remover página "Hello World" | **0 posts** publicados; nada de hello-world no HTML |
| Plugin de cache | **WP Fastest Cache** ativo (não é LiteSpeed/WP Rocket, mas cumpre) |
| Verificar Yoast | Yoast instalado e ativo (Rank Math não) |
| Verificar SSL | Site serve em HTTPS |
| GitHub Backup | O repositório **tem remote**: `github.com/NMarlon/Jessica-Haguiwara` |
| Copyright, privacidade | Rodapé com ©, aviso de reprodução e link da Política de Privacidade |
| Banner LGPD / consentimento | **Complianz** ativo |
| Domínio, hospedagem, WhatsApp comercial | Domínio no ar, cPanel, `(11) 98323-6422` no rodapé |
| Easy MCP IA para OpenCode | `opencode.json` com 2 MCPs (WordPress remoto + navegador) |

## C. Obsoleto — não fazer

| Tarefa | Por quê |
|---|---|
| **Instalar Elementor** | O site foi feito em Gutenberg com tema próprio. Instalar Elementor agora cria dois sistemas de layout concorrentes e infla o peso |
| **TEMA.md: fontes Plus Jakarta Sans / Inter** | O site publicado usa **Cardo + Marcellus** (serifadas). A nota é anterior à decisão de design |
| Comprar domínio / hospedagem / cartão | Feito |

## D. Só dá para verificar dentro do wp-admin (ou é opcional)

| Tarefa | Situação |
|---|---|
| All-in-One Security + authenticator | Sem rastro no HTML; só confirma logando |
| Backups SFTP manual | WPvivid já cobre; SFTP manual seria redundância |
| UptimeRobot | Marcado como feito por você; não confirmei externamente |
| HubSpot para CRM | O rastreador HubSpot **está no site**; se o CRM está em uso, não dá para ver daqui |
| Documentar OpenCode para o Alexandre | Pendente de verdade — é texto, e serve |
| Google ADS ("fail on edit") | Antigo; não há campanha rodando hoje |
| Plugin PageSpeed / Feedback do site | Opcionais, sem efeito sobre o cliente |
| Redes sociais (Facebook, TikTok, YouTube) | Sem perfil; bloqueado na cliente |

## Prioridade sugerida

1. **A7** (link de cookies) — em execução, brief T-P03-016.
2. **A1** (Soluções + 3 páginas) — a maior, e a que você lembrou. A home já tem os quatro
   serviços escritos (Consultoria, Projetos, Gestão de Obra, Chave na Mão); as páginas
   podem nascer desse texto, sem inventar nada.
3. **A2** (WebP) — única alavanca real de peso que sobrou, depois que a minificação se
   mostrou já feita.
4. **A5 + A6** — quando a cliente responder o questionário.
