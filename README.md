# Cardápio Kattamaram — 3 barcos

Cardápio digital em 3 idiomas (PT-BR, English, Español) com um link para cada barco e um painel de edição com login.

## Barcos e links

| Barco | Link do cardápio |
|---|---|
| Kattamaram II • Foz do Iguaçu | `/` e `/foz` |
| Catamarã Itapema | `/itapema` |
| Catamarã Florianópolis | `/floripa` |
| Painel de edição | `/admin` |

O endereço principal (o do QR code) abre o cardápio do Foz, então a placa atual continua funcionando.

## Quem acessa o quê

| Login | Pode editar |
|---|---|
| Administrador (você) | Os 3 barcos, escolhendo no topo do painel |
| Itapema | Somente Itapema |
| Floripa | Somente Florianópolis |

O bloqueio é feito no banco de dados (Supabase RLS), então um login não consegue mexer em outro barco mesmo que tente burlar o site.

## Arquivos

| Arquivo | Para quê |
|---|---|
| `index.html` | Cardápio público |
| `admin.html` | Painel de edição |
| `config.js` | Endereço e chave pública (anon) do Supabase |
| `_redirects` | Faz funcionar `/foz`, `/itapema`, `/floripa` e `/admin` no Netlify |
| `migracao.sql` | Prepara o banco (rodar uma vez no Supabase) |
| `personalizacao-banner.sql` | Adiciona os controles de tamanho e aparência da capa em um banco já existente |
| `images/` | Imagens do site, como a capa do Foz (`images/barco-kattamaram.jpg`) |

## Instalação

### 1. Banco de dados (Supabase)

1. Abra **SQL Editor → New query**, cole o conteúdo de `migracao.sql` e clique em **Run**.
   - Não apaga nada: seus produtos, fotos e traduções atuais continuam e passam a pertencer ao Foz.
   - Pode ser executado mais de uma vez.
2. Em **Authentication → Users**, crie os 3 usuários (administrador, Itapema e Floripa).
3. Copie o UUID de cada usuário e rode:

```sql
insert into profiles (id, role, boat_id) values
  ('UUID_ADMIN',    'admin', null),
  ('UUID_ITAPEMA',  'boat', (select id from boats where slug = 'itapema')),
  ('UUID_FLORIPA',  'boat', (select id from boats where slug = 'floripa'));
```

### 2. Publicação (Netlify)

Suba `index.html`, `admin.html`, `config.js`, `_redirects` e a pasta `images/`.

- **Para testar:** crie um site novo (**Add new site → Deploy manually**) e dê um nome como `kattamaram-teste`. O site antigo e o QR code não são afetados.
- **Para valer:** suba os mesmos arquivos no site atual. O endereço não muda.
- Se o site estiver ligado ao GitHub, troque os arquivos no repositório e o Netlify atualiza sozinho.

## Usando o painel (`/admin`)

- **Categorias:** nome, ícone (emoji), ordem e se aparece no cardápio.
- **Produtos:** categoria, nome, descrição, preço, foto, ordem, destaque (⭐) e se aparece no cardápio.
- **Subprodutos:** dentro de cada produto, com nome e valor (tamanhos, extras, sabores).
- **Personalização da capa:** imagem, altura (180–1200 px), largura (40–100%), zoom (50–200%), posição horizontal e vertical (0–100%) e escurecimento (0–90%). As configurações são individuais por barco.
- **Dados do barco:** nome, foto de capa, WhatsApp (só números, com 55) e Instagram (sem @).
- **Traduções:** deixe os campos de English e Español vazios e o painel traduz sozinho ao salvar. Se preferir, preencha à mão.
- **Fotos:** enviadas direto pelo painel e guardadas no bucket `product-images`.

## Como os dados ficam guardados

- `boats`: os 3 barcos (nome, slug, WhatsApp, Instagram, capa).
- `categories` e `products`: cada linha tem `boat_id`.
- `products.options`: subprodutos (JSON).
- `categories.translations` e `products.translations`: traduções en/es (JSON).
- `profiles`: liga cada usuário ao seu papel (`admin` ou `boat`) e ao barco.

## Observações

- Se o controle de estoque usar o mesmo projeto Supabase, **não rode** a migração sem revisar: ela troca as regras de acesso de `categories` e `products`.
- Durante o período de teste, o painel antigo deixa de salvar (as regras mudaram). Use o novo `/admin`.
- A chave em `config.js` é a chave pública (anon) do Supabase e pode ficar no site. Nunca coloque a chave `service_role` nos arquivos.
- Todos os produtos pré-existentes ficam no Foz. Itapema e Floripa começam vazios e são cadastrados pelo painel.

## Atualização: controles da imagem de capa

Se você já executou a `migracao.sql` anteriormente, **não precisa executar a migração inteira novamente**. Abra o Supabase → SQL Editor e execute somente `personalizacao-banner.sql`. Depois publique os arquivos atualizados no Netlify.

No painel `/admin`, clique em **Dados do barco** para encontrar os controles de imagem. As alterações são salvas no registro do barco selecionado.
