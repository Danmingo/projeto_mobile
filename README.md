# MoviePick — Projeto Flutter (Parte 2)

Aplicativo mobile para **organizar, cadastrar e sortear filmes**, com persistência local de dados e **autenticação de usuários**.

## Integrantes

- Daniel Moreira Cesar de Souza Mingolelli
- Emanuel Caetano Chemin Goulart
- Pedro Rosim Sunfeld Giordano

> **Antes da entrega:** cada integrante deve preencher suas atividades reais na seção "Contribuições da equipe"; não atribuir tarefas sem verificar o histórico de commits.

## Funcionalidades

- Cadastro de usuário com nome, e-mail e senha; e-mail único e validações.
- Login que consulta usuário no SQLite e **não permite entrar com credenciais inválidas**.
- Senhas **não são gravadas em texto puro**: PBKDF2-HMAC-SHA256 (120 mil iterações) e salt aleatório individual.
- Sessão em memória enquanto o aplicativo está aberto, logout com confirmação e proteção da rota `/home`.
- Filmes persistidos em SQLite (inclusão, consulta, edição, exclusão, assistidos e lista de interesse).
- Sorteio de filmes, filtros e detalhes.
- Perfil com estatísticas de filmes e progresso da biblioteca.
- Câmera e galeria para pôsteres via `image_picker`.

## Requisitos

- Flutter SDK compatível com Dart `^3.13.5` (ver `pubspec.yaml`).
- Android SDK, emulador Android ou aparelho físico com depuração USB habilitada.
- VS Code com extensões Flutter/Dart ou Android Studio.
- Conexão com a internet **somente para baixar as dependências** na instalação.

## Como instalar e executar

```bash
git clone https://github.com/Danmingo/projeto_mobile
cd projeto_mobile
flutter doctor
flutter pub get
flutter devices
flutter run
```

Execute preferencialmente em Android. Para criar um APK de teste:

```bash
flutter build apk --debug
```

Para verificar o código e os testes:

```bash
flutter analyze
flutter test
```

## Como testar o login e cadastro

1. Abra o aplicativo e toque em **Cadastre-se**.
2. Digite nome, e-mail válido e senha de **pelo menos 8 caracteres**; confirme a senha.
3. Toque em **Cadastrar** e volte à tela de login.
4. Entre com as credenciais cadastradas. Senha errada e e-mail inexistente devem ser rejeitados.
5. Em **Perfil**, selecione **Sair da conta** e confirme. O botão voltar não deve reabrir as telas internas.
6. Feche e abra o app e faça login novamente com a mesma conta; ela permanece no SQLite.
7. Tente cadastrar o mesmo e-mail de novo; deve aparecer erro de duplicidade.

## Estrutura do projeto

- `lib/pages/`: telas e formulários, incluindo `login_page.dart`, `register_page.dart` e `profile_page.dart`.
- `lib/services/auth_service.dart`: cadastro, validação, hash, login, sessão e logout.
- `lib/services/auth_scope.dart`: disponibiliza o serviço de autenticação às telas.
- `lib/services/filme_repository_sqlite.dart`: persistência dos filmes.
- `lib/services/filme_service.dart`: operações sobre biblioteca de filmes.
- `test/`: testes unitários e de widgets.

### Catálogo compartilhado e evolução do projeto

O MoviePick utiliza um catálogo de filmes compartilhado entre as contas cadastradas no mesmo dispositivo.

Essa estrutura é uma decisão de projeto: o aplicativo foi pensado para permitir que os usuários consultem filmes disponíveis em um catálogo comum, em vez de manter bibliotecas completamente isoladas.

Nesta etapa acadêmica, usuários autenticados podem cadastrar, consultar, atualizar e excluir filmes (CRUD).

Como evolução futura, está previsto um sistema de permissões com diferentes perfis de acesso, permitindo que usuários comuns consultem os filmes e que administradores ou parceiros autorizados gerenciem o catálogo.

Também está prevista a integração com um catálogo online, possibilitando que distribuidoras e produtoras divulguem seus lançamentos.

Atualmente, o catálogo é compartilhado apenas entre contas locais do mesmo aparelho, sem sincronização entre dispositivos.

## Limitações / pontos pendentes

- A versão **web** usa autenticação e filmes em memória: ao recarregar a página os dados não são preservados. O SQLite está direcionado a Android/iOS.
- Recuperação de senha ainda não implementada; o botão exibe uma mensagem informativa.
- A persistência de login não foi implementada propositalmente: é necessário entrar novamente após reiniciar o app.
- A integração final deve ser verificada no aparelho com `flutter analyze`, `flutter test` e `flutter run`.

## Entrega

O repositório deve estar **público**, com a branch `main` contendo a versão executável. Um único integrante deve enviar o URL no Moodle. É recomendado testar o clone em outro computador antes da apresentação.
