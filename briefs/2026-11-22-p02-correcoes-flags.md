# P-02 · Correções de atrito nas flags e no diálogo de mesclar

## CONTEXTO JÁ VERIFICADO (não re-investigue)

Repo: `C:\MarlonScripts\1-Mini-Projetos\Reconhecedor de Rostos de  Imagens` (dois espaços).
Base: commit `ad9b456` (mesclar + flags). API no ar em `127.0.0.1:8011`, banco real
`data/faces.db` com 17.469 pessoas, 52.726 rostos, 0 órfãos, 1 flag.

O que o Marlon viveu usando o app (medido por mim no log dele):

1. Ele criou a flag `Identificação Quebrada (Rosto de Costas Aleatório)` `#b87700`
   → `POST /api/tags` 200, id 1.
2. Na sequência o app chamou `POST /api/people/507/tag/1` → **404 "Not Found"**.
   Causa: naquele instante a API no ar era a versão anterior, sem a rota de flag por
   pessoa (rota inexistente devolve `{"detail":"Not Found"}`). A rota nova funciona —
   testei depois: 200. Não é bug de código, é código antigo em memória.
3. Ele tentou de novo → `POST /api/tags` **400 "tag exists"** → agora nem cria nem aplica.
4. A tela mostrou o texto cru em inglês: "Não foi possível criar a flag: Not Found".

O que ainda é defeito de verdade:

- Criar flag com nome que já existe devolve 400 e o app desiste — devia usar a existente.
- `GET /api/people/{pid}` devolve `face_count: 0` para pessoa que tem 3 rostos quando
  a linha de `person_stats` não existe/é antiga (medido na cópia de teste).

## O QUE FAZER

1. `POST /api/tags` com nome já existente → **200** devolvendo a flag existente com
   `"reused": true` (mesmo `id`, sem criar duplicata). UI: aplica a flag na pessoa e
   avisa "Flag 'X' já existia — aplicada".
2. `GET /api/people/{pid}` → quando `person_stats` estiver ausente ou divergir da
   contagem real em `faces`, devolver a contagem real e atualizar a linha da stat.
   Nunca devolver 0 para quem tem rosto.
3. Mensagens de erro da UI em português. Em especial: resposta 404 com `detail == "Not Found"`
   numa rota que o app conhece → "A API no ar está desatualizada. Reinicie o servidor
   e recarregue a página (F5)." Nada de "Not Found" cru na cara dele.
4. Os demais `alert`/`toast` de erro que ainda mostram `err.message` cru: traduzir para
   frase curta em português, mantendo o código de status no fim entre parênteses.

## PROIBIDO

- Schema novo, dependência nova, `POST /api/cluster`.
- Tocar no banco real além de criar/apagar as flags do próprio teste (deixar
  `Identificação Quebrada (Rosto de Costas Aleatório)` intacta — é do Marlon).
- Mexer no fluxo de merge além da contagem do diálogo.

## CRITÉRIO DE ACEITE

1. `POST /api/tags` duas vezes com o mesmo nome → 2º chamada 200 com o mesmo `id`;
   `select count(*) from tags where name='X'` = 1.
2. Pessoa criada + 3 rostos atribuídos → `GET /api/people/{id}` devolve `face_count: 3`
   e `photo_count` igual ao número de imagens distintas no banco.
3. Colar no console do navegador uma chamada a rota inexistente e conferir que a
   mensagem ao usuário é a frase em português sobre API desatualizada (screenshot).
4. `GET /api/people?page_size=100` continua < 500 ms.
5. Ao final: `tags` com 1 linha (a do Marlon), `person_tag` com 0, `people` = 17.469.

## CONTRATO DE RETORNO

`RESULTADO / status / arquivos_alterados / comandos_executados / evidencia / nao_testado / riscos / proximo_passo`
