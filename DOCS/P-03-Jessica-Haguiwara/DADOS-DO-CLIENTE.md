# Dados que só a cliente fornece — P-03 (site Jéssica Haguiwara)

Levantado em 2026-11-23, conferido no site no ar (home + 3 páginas legais).
Base anterior: `DOCS/09-DADOS-À-ATUALIZAR.md` do repo do site (14 itens, 2026-11-19).
Este arquivo é a lista de trabalho do gestor: o que pedir, para que serve e o que trava.

## 0. O que já está no ar (não é pendência)

- Endereço completo, telefone, e-mail e CNPJ 40.130.946/0001-97 — publicados na política de privacidade.
- Política de privacidade e política de cookies — publicadas.
- Formulário com metragem e faixa de orçamento — já aplicado, valores **provisórios**.
- 7 imagens de ambiente na home — genéricas, sem lastro de projeto real.

## 1. Defeito no ar, hoje (não depende da cliente)

**1.1 `/privacy-policy/` publica `Registro profissional: CAU/A nº [INSERIR REGISTRO]`.**
Placeholder visível em página legal. Correção imediata: remover a linha até o número chegar.
Ela volta assim que a cliente informar o registro.

**1.2 Três depoimentos fictícios na home** — Amanda & Ricardo, Lucas Mendes, Camila Torres, 5 estrelas.
Estão marcados na tela com etiqueta "exemplo" (`.jhw-pendente::after` no `style.css` 1.3.7), então não há
fabricação passando por verdade. Mas conteúdo de exemplo não pode ficar em produção indefinidamente:
ou entram os reais, ou a seção sai.

## 2. Dados da cliente — na ordem em que destravam o site

| # | Dado | Onde aparece | Por que importa | Trava |
|---|---|---|---|---|
| 1 | **Número do CAU** (e UF: CAU/BR ou CAU/SP) | rodapé de todas as páginas + política de privacidade | registro profissional é o lastro legal da arquiteta; hoje a linha legal está com bracket | T-011 |
| 2 | **3 depoimentos reais**: frase, primeiro nome, tipo de projeto e autorização para publicar | home, seção Depoimentos | prova social é o que converte visita em contato; sem autorização não publica | Depoimentos |
| 3 | **Projetos reais**: 6 a 8 fotos + nome, bairro/cidade, ano, área em m², tipo (residencial/comercial/interiores) e quem detém os direitos das fotos | home, `#projetos` | portfólio é o produto do escritório; área e ano não podem ser inventados | Portfólio |
| 4 | **Foto profissional dela** (alta resolução, com direito de uso) | `#quem-somos` | hoje a seção é só texto; rosto humano ancora confiança | Foto |
| 5 | **Instagram** (perfil) | rodapé (hoje "em breve") + feed no fim da home | canal vivo de prova e de tráfego; o rodapé está com marcador provisório | Instagram |
| 6 | **Formação e credenciais**: curso, ano de formação, especializações, tempo de atuação | "Sobre o escritório" / bio | autoridade técnica; hoje o texto é genérico porque não temos o dado | Bio |
| 7 | **Confirmar ou corrigir** as faixas do formulário: metragem (até 100 / 100–300 / acima de 300 m²) e orçamento (até 50 mil / 50–150 / 150–300 / acima de 300 mil) | formulário da home | valor provisório errado filtra o lead errado e queima a primeira conversa | Formulário |
| 8 | **Área de atuação**: quais cidades e regiões atende | hero (hoje "São Caetano do Sul · SP") + SEO local | define raio comercial e o que o Google mostra para busca local | SEO |
| 9 | **Horário de atendimento** e canal preferido (WhatsApp ou e-mail) | contato + dados estruturados do Google | quem procura quer saber quando será respondido | Contato |
| 10 | **Serviços e o que cada um inclui**: projeto arquitetônico, interiores, gestão de obra, chave na mão — e como cobra (% da obra, por m², pacote fechado) | páginas de serviço (não existem ainda) | sem isso o site só tem 3 etapas genéricas e nenhuma página que ranqueie por serviço | Serviços |
| 11 | **Confirmar CNPJ e razão social**, e quem responde por dados pessoais (LGPD) | política de privacidade | dado legal publicado precisa de confirmação dela | Legal |
| 12 | **Aprovação dos textos legais** (privacidade e cookies) | páginas legais | responsabilidade jurídica é dela, não do escritório de dev | Legal |
| 13 | **Autorização de uso de imagem** dos projetos e dos clientes que aparecem nas fotos | todo o portfólio | foto de obra alheia sem cessão é risco jurídico | Portfólio |
| 14 | **Google Business Profile**: existe ficha do escritório? quem tem acesso? | busca do Google / mapa | ficha desatualizada derruba a busca local | SEO |
| 15 | **Pauta do Journal** (assuntos que ela quer escrever) | blog (futuro) | sem pauta o blog nasce vazio e morre | Journal |

## 3. O que NÃO é dela (Marlon resolve)

Logo em vetor e favicon, DKIM do e-mail, GA4/GTM, cache e backup, imagem do site.
Já medido: backup WPvivid ativo, último 2026-11-22 21:17, destino OneDrive.

## 4. Mensagem para copiar e enviar (versão curta)

> Jéssica, para o site ficar completo e no ar sem pendência, preciso de alguns dados que só você tem.
> Vou por ordem de importância — pode responder por partes.
>
> 1. Seu número de registro no CAU (e se é CAU/BR ou CAU/SP).
> 2. Três depoimentos de clientes: uma frase de cada, primeiro nome, tipo de projeto, e se autorizam publicar.
> 3. Fotos dos seus projetos (6 a 8, boa resolução) com nome do projeto, bairro/cidade, ano, metragem e tipo.
> 4. Uma foto sua profissional, de boa resolução.
> 5. Seu Instagram.
> 6. Sua formação: curso, ano de formação, especializações.
> 7. Confirma se as faixas do formulário estão certas: metragem até 100 / 100 a 300 / acima de 300 m² e
>    orçamento até 50 mil / 50 a 150 mil / 150 a 300 mil / acima de 300 mil.
> 8. Quais cidades você atende e seu horário de atendimento.
> 9. Como você cobra: percentual da obra, por metro quadrado ou pacote fechado — e o que cada serviço inclui.
> 10. Confirmação do CNPJ e razão social que estão na política de privacidade.
>
> Enquanto isso, dois ajustes já feitos: a política de privacidade sai com o CAU em branco até você informar,
> e os depoimentos de exemplo saem do ar — não vou publicar depoimento inventado.

## 5. Regra que governa tudo isto

Sem o dado, a seção não existe. Nunca preencher CAU, área, prazo, preço, obra ou depoimento com estimativa.
