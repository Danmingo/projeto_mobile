MoviePick
Aplicativo mobile desenvolvido em Flutter com o objetivo de auxiliar o usuário na organização de filmes e na escolha do que assistir.
O MoviePick permite cadastrar filmes, acompanhar quais já foram assistidos, manter uma lista de interesse e realizar o sorteio aleatório de um filme cadastrado. O projeto foi desenvolvido como parte da disciplina de desenvolvimento mobile e, nesta primeira etapa, tem foco na construção da interface, navegação entre páginas, utilização de formulários, validações e gerenciamento temporário dos dados em memória.

Integrantes

Daniel Moreira Cesar de Souza Mingolelli
Emanuel Caetano Chemin Goulart
Pedro Rosim Sunfeld Giordano

Objetivo do projeto
Escolher um filme para assistir pode se tornar difícil quando existem muitas opções disponíveis. O MoviePick foi pensado para ajudar nesse processo através de uma biblioteca pessoal de filmes.
O aplicativo permite que o usuário organize os filmes que deseja assistir e utilize um sistema de sorteio quando estiver indeciso.
Nesta primeira etapa do projeto, o foco está no desenvolvimento da interface e no fluxo de utilização do aplicativo. Os dados são armazenados apenas durante a execução da aplicação, sem persistência em banco de dados.

Funcionalidades implementadas
Atualmente o projeto possui as seguintes funcionalidades:
Tela de login;
Tela de cadastro de usuário;
Navegação entre login, cadastro e área principal do aplicativo;
Menu inferior para navegação entre as principais páginas;
Tela inicial com resumo dos filmes;
Cadastro de filmes;
Listagem dos filmes cadastrados;
Exclusão de filmes com confirmação;
Marcação de filmes como assistidos ou não assistidos;
Adição e remoção de filmes da "Minha Lista";
Visualização da lista de filmes de interesse;
Sorteio aleatório entre os filmes cadastrados;
Exibição dos filmes adicionados recentemente;
Contadores de:
filmes cadastrados;
filmes presentes na Minha Lista;
filmes assistidos;
Formulários com validação;
Mensagens de erro e feedback ao usuário;
Tela de perfil preparada para implementações futuras.

Telas do aplicativo
Login
A tela de login contém:
campo de e-mail;
campo de senha;
opção para exibir ou ocultar a senha;
botão para entrar;
acesso à tela de cadastro;
opção de recuperação de senha.
Nesta primeira etapa, a autenticação ainda não está integrada a um serviço ou banco de dados. Portanto, o botão Entrar direciona o usuário diretamente para a tela principal.
A recuperação de senha também está representada somente na interface e apresenta uma mensagem informando que será implementada posteriormente.

Cadastro de usuário
A tela de cadastro possui os seguintes campos:
Nome;
E-mail;
Senha;
Confirmação de senha.
O formulário possui validações para impedir o envio de campos vazios e também verifica se a confirmação da senha corresponde à senha informada.
Após a validação, o aplicativo informa ao usuário que a integração do cadastro com um sistema de autenticação será realizada em uma etapa futura.

Página inicial
A página inicial apresenta uma visão geral da biblioteca do usuário.
São exibidos:
quantidade total de filmes cadastrados;
quantidade de filmes presentes na Minha Lista;
quantidade de filmes marcados como assistidos;
últimos filmes adicionados;
acesso rápido para a listagem completa;
acesso rápido para o sorteio de um filme.
Os valores apresentados são atualizados automaticamente de acordo com as alterações realizadas durante a execução do aplicativo.

Filmes
A página Filmes concentra o gerenciamento da biblioteca.
O usuário pode cadastrar um novo filme informando:
Título;
Gênero;
Ano.
O cadastro possui validações que impedem campos obrigatórios vazios e exigem que o ano seja informado como um valor numérico válido.
Cada filme cadastrado pode ainda ser:
adicionado à Minha Lista;
removido da Minha Lista;
marcado como assistido;
marcado novamente como não assistido;
excluído.
Antes da exclusão, uma caixa de diálogo solicita a confirmação do usuário.
Após operações de cadastro ou remoção, mensagens de feedback são apresentadas através de SnackBar.

Sorteio de filmes
A página Sortear permite escolher aleatoriamente um dos filmes atualmente cadastrados.
Caso nenhum filme tenha sido cadastrado, o aplicativo informa que é necessário adicionar pelo menos um filme para realizar o sorteio.
Quando existem filmes disponíveis, o usuário pode pressionar Sortear filme e o aplicativo selecionará aleatoriamente um item da lista, exibindo:
título;
gênero;
ano.
O sorteio pode ser realizado novamente quantas vezes o usuário desejar.

Minha Lista
A página Minha Lista apresenta somente os filmes que foram adicionados pelo usuário à lista de interesse.
Nesta página é possível:
visualizar título, gênero e ano do filme;
remover um filme da Minha Lista.
Caso nenhum filme tenha sido adicionado, é apresentada uma mensagem indicando que a lista está vazia.

Perfil
A página de perfil atualmente possui uma interface inicial com identificação genérica do usuário.
Dados pessoais e demais funcionalidades relacionadas ao perfil serão implementados em etapas futuras do projeto.

Formulários e validações
O projeto utiliza componentes de formulário do Flutter, principalmente Form, TextFormField, GlobalKey<FormState> e funções validator.
Cadastro de usuário
São realizadas as seguintes verificações:
Nome não pode estar vazio;
E-mail não pode estar vazio;
Senha não pode estar vazia;
Confirmação de senha não pode estar vazia;
Senha e confirmação de senha precisam ser iguais.
Cadastro de filmes
São realizadas as seguintes verificações:
Título não pode estar vazio;
Gênero não pode estar vazio;
Ano deve ser um valor numérico válido.
As mensagens de validação são apresentadas diretamente abaixo dos respectivos campos.
Também são utilizadas caixas de diálogo e SnackBar para fornecer feedback das operações realizadas.

Navegação
A aplicação utiliza dois tipos principais de navegação.
Rotas nomeadas
As principais rotas são definidas no MaterialApp:
'/login'
'/home'
'/cadastro'
A tela inicial da aplicação é a rota:
/login
Navegação principal
Depois do login, a classe MainPage utiliza um PageView associado a um BottomNavigationBar.
O menu inferior possui cinco seções:
Início;
Filmes;
Sortear;
Lista;
Perfil.
Essa estrutura permite navegar entre as principais funcionalidades sem sair da área principal do aplicativo.

Estrutura e organização do projeto
O código foi separado de acordo com as responsabilidades das classes, mantendo modelos e páginas em diretórios distintos.
Estrutura principal:
projeto_mobile/
│
├── android/
├── ios/
├── linux/
├── macos/
├── web/
├── windows/
│
├── assets/
│   └── images/
│       └── movepick_logo_app_azul.png
│
├── lib/
│   ├── models/
│   │   └── movie.dart
│   │
│   ├── pages/
│   │   ├── draw_page.dart
│   │   ├── home_page.dart
│   │   ├── login_page.dart
│   │   ├── main_page.dart
│   │   ├── movies_page.dart
│   │   ├── profile_page.dart
│   │   ├── register_page.dart
│   │   └── watchlist_page.dart
│   │
│   └── main.dart
│
├── test/
├── pubspec.yaml
└── README.md
Model
A classe Movie, localizada em:
lib/models/movie.dart
representa os filmes utilizados pela aplicação.
Atualmente um filme possui:
title
genre
year
inWatchlist
watched
Os três primeiros atributos armazenam os dados básicos do filme, enquanto inWatchlist e watched representam o estado do filme dentro da aplicação.
Gerenciamento dos dados
Nesta primeira etapa não existe persistência em banco de dados.
A lista de filmes é mantida em memória pela MainPage:
final List<Movie> _movies = [];
A MainPage concentra o estado compartilhado dos filmes e fornece callbacks às demais páginas para operações como:
adicionar;
remover;
adicionar/remover da Minha Lista;
marcar/desmarcar como assistido.
Dessa forma, diferentes páginas trabalham sobre a mesma coleção durante a execução do aplicativo.
Essa implementação atende à proposta da Parte 1 de trabalhar com dados temporários ou em memória. Nas próximas etapas, essa camada poderá ser substituída ou complementada por uma solução de persistência de dados.

Tecnologias utilizadas
O projeto utiliza:
Flutter — desenvolvimento da aplicação;
Dart — linguagem de programação;
Material Design 3 — componentes e identidade visual da interface;
Git — controle de versão;
GitHub — hospedagem e colaboração no código-fonte.
O projeto utiliza atualmente apenas dependências essenciais do Flutter:
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
Para desenvolvimento e análise de código:
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

Identidade visual
A interface utiliza Material Design 3 e tem como cor principal o roxo, definido a partir da cor:
#6C42C5
O projeto também possui uma identidade visual própria do MoviePick, incluindo logotipo utilizado na tela de login e arquivos relacionados à marca.
Os recursos de imagem utilizados pela aplicação estão registrados no pubspec.yaml:
flutter:
  uses-material-design: true

  assets:
    - assets/images/

Instalação e execução
Pré-requisitos
Antes de executar o projeto, é necessário possuir:
Git instalado;
Flutter SDK instalado;
Dart compatível com o projeto;
Android SDK configurado;
Android Studio ou outra configuração compatível com o desenvolvimento Android;
dispositivo Android físico ou emulador.
O pubspec.yaml atual define:
environment:
  sdk: ^3.13.5
Portanto, é necessário utilizar uma versão do Flutter que forneça uma versão compatível do Dart.
Para verificar a configuração do ambiente:
flutter doctor
Os componentes necessários para desenvolvimento Android devem estar corretamente configurados.

1. Clonar o repositório
No terminal, execute:
git clone [LINK_DO_REPOSITORIO]
Depois entre na pasta do projeto:
cd projeto_mobile

2. Instalar as dependências
Dentro da pasta que contém o arquivo pubspec.yaml, execute:
flutter pub get
Esse comando fará o download das dependências necessárias para o funcionamento do projeto.

3. Verificar os dispositivos disponíveis
Execute:
flutter devices
O Flutter apresentará os dispositivos disponíveis para execução.
Exemplo:
Android Device • ID_DO_DISPOSITIVO • android-arm64
Chrome         • chrome            • web-javascript
Windows        • windows           • windows-x64

4. Executar em um celular Android
Para utilizar um aparelho Android físico, é necessário habilitar as Opções do desenvolvedor e a Depuração USB no celular.
Após conectar o aparelho ao computador através de USB, verifique se ele foi reconhecido:
adb devices
Em seguida:
flutter devices
Com o aparelho listado, o aplicativo pode ser executado através de:
flutter run
Caso existam vários dispositivos disponíveis:
flutter run -d ID_DO_DISPOSITIVO

5. Executar em um emulador Android
Com um emulador configurado, é possível verificar os disponíveis através de:
flutter emulators
Inicie o emulador desejado e execute:
flutter run

6. Execução pelo VS Code
Também é possível executar o projeto utilizando o Visual Studio Code:
Abrir a pasta do projeto no VS Code;
Certificar-se de que as extensões Flutter e Dart estão instaladas;
Selecionar o dispositivo desejado;
Executar o projeto utilizando F5 ou a opção Run and Debug.

Fluxo básico de utilização
Após iniciar o aplicativo:
Login
   │
   ├── Cadastro
   │
   └── Entrar
        │
        ▼
      Início
        │
        ├── Filmes
        │    ├── Cadastrar filme
        │    ├── Minha Lista
        │    ├── Marcar como assistido
        │    └── Excluir
        │
        ├── Sortear
        │    └── Sorteio aleatório
        │
        ├── Minha Lista
        │
        └── Perfil

Estado atual e limitações da Parte 1
Esta versão corresponde à Parte 1 do projeto, portanto algumas funcionalidades ainda são propositalmente simplificadas ou estão planejadas para etapas posteriores.
Atualmente:
os dados são mantidos somente em memória;
os dados são perdidos quando o aplicativo é encerrado;
não existe banco de dados integrado;
o login ainda não realiza autenticação real;
o cadastro do usuário ainda não é persistido;
a recuperação de senha ainda não está implementada;
a tela de perfil apresenta dados estáticos;
o botão de notificações presente na tela inicial ainda não possui funcionalidade;
o sorteio atualmente considera todos os filmes cadastrados, sem filtros adicionais;
não existe edição completa dos dados de um filme já cadastrado;
não há integração com APIs externas de filmes.
Esses pontos poderão ser evoluídos nas próximas etapas do projeto.

Possíveis evoluções
Para as próximas etapas estão previstas ou podem ser adicionadas funcionalidades como:
persistência dos dados em banco de dados;
autenticação de usuários;
armazenamento individual de filmes por usuário;
edição dos dados dos filmes;
filtros de sorteio;
sorteio baseado em gênero;
sorteio baseado em duração;
sorteio baseado em classificação indicativa;
sorteio baseado em nota;
informações adicionais dos filmes;
imagens/capas dos filmes;
integração com API externa de filmes;
aprimoramento da página de perfil.


Particularidades do projeto
Esta primeira entrega tem como objetivo principal apresentar a interface e os fluxos da aplicação.
Por esse motivo, funcionalidades que dependem de armazenamento permanente ou serviços externos ainda não estão presentes. Os filmes cadastrados são armazenados em memória durante a execução da aplicação.
A estrutura atual permite que a persistência seja adicionada posteriormente sem a necessidade de reconstruir toda a interface do aplicativo.

Controle de versão
O projeto utiliza Git e GitHub para controle de versão.
Durante o desenvolvimento, os integrantes devem realizar commits das próprias contribuições, permitindo acompanhar o histórico e a participação de cada membro do grupo.
A branch:
main
deve representar a versão estável utilizada para a entrega do trabalho.
Repositório:
[LINK_DO_REPOSITORIO_GITHUB]

Observações
Caso ocorram problemas durante a execução, recomenda-se executar:
flutter doctor
seguido de:
flutter clean
flutter pub get
flutter run
Também é importante verificar se o comando está sendo executado na raiz do projeto, ou seja, na pasta em que está localizado o arquivo:
pubspec.yaml

Disciplina
Projeto Prático — Desenvolvimento Mobile em Flutter
Parte 1 — Interface, Navegação, Formulários e Validações
Professor: Prof. Diego Roberto Antunes 
Instituição: UTFPR-PG
Ano: 2026

