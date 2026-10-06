import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_mobile/main.dart';

Future<void> _openHome(WidgetTester tester) async {
  await tester.pumpWidget(const MoviePickApp());
  await tester.tap(find.text('Entrar'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('login aparece e Cadastre-se abre Cadastro', (tester) async {
    await tester.pumpWidget(const MoviePickApp());

    expect(find.text('Bem-vindo!'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);

    final registerLink = find.byType(TextButton).last;
    await tester.ensureVisible(registerLink);
    await tester.tap(registerLink);
    await tester.pumpAndSettle();

    expect(find.text('Cadastro'), findsOneWidget);
    expect(find.text('Crie sua conta'), findsOneWidget);
  });

  testWidgets('Entrar abre Home com estado vazio', (tester) async {
    await _openHome(tester);

    expect(find.text('Olá, Usuário! 👋'), findsOneWidget);
    expect(find.text('Filmes cadastrados'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(3));
    expect(find.text('Nenhum filme cadastrado ainda.'), findsOneWidget);
  });

  testWidgets('BottomNavigationBar troca para as páginas', (tester) async {
    await _openHome(tester);

    for (final label in ['Início', 'Filmes', 'Sortear', 'Lista', 'Perfil']) {
      expect(find.text(label), findsOneWidget);
    }

    await tester.tap(find.text('Filmes'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhum filme cadastrado.'), findsOneWidget);

    await tester.tap(find.text('Sortear'));
    await tester.pumpAndSettle();
    expect(
      find.text('Cadastre pelo menos um filme para realizar o sorteio.'),
      findsOneWidget,
    );
  });

  testWidgets('Sortear mostra estado vazio sem filmes', (tester) async {
    await _openHome(tester);
    await tester.tap(find.text('Sortear'));
    await tester.pumpAndSettle();

    expect(
      find.text('Cadastre pelo menos um filme para realizar o sorteio.'),
      findsOneWidget,
    );
  });

  testWidgets('adiciona filme e atualiza contador da Home', (tester) async {
    await _openHome(tester);
    await tester.tap(find.text('Filmes'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-movie')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('movie-title')), 'Duna');
    await tester.enterText(find.byKey(const Key('movie-genre')), 'Ficção');
    await tester.enterText(find.byKey(const Key('movie-year')), '2021');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    expect(find.text('Duna'), findsOneWidget);
    await tester.tap(find.text('Início'));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Duna'), findsOneWidget);
  });

  testWidgets('remove filme e volta contador para zero', (tester) async {
    await _openHome(tester);
    await tester.tap(find.text('Filmes'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-movie')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('movie-title')), 'Duna');
    await tester.enterText(find.byKey(const Key('movie-genre')), 'Ficção');
    await tester.enterText(find.byKey(const Key('movie-year')), '2021');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    expect(find.text('Remover filme?'), findsOneWidget);
    await tester.tap(find.text('Remover'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Início'));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsNWidgets(3));
    expect(find.text('Nenhum filme cadastrado ainda.'), findsOneWidget);
  });

  testWidgets('adiciona filme e mostra em Minha Lista', (tester) async {
    await _openHome(tester);
    await tester.tap(find.text('Filmes'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-movie')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('movie-title')), 'Duna');
    await tester.enterText(find.byKey(const Key('movie-genre')), 'Ficção');
    await tester.enterText(find.byKey(const Key('movie-year')), '2021');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adicionar à Minha Lista'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lista'));
    await tester.pumpAndSettle();
    expect(find.text('Duna'), findsOneWidget);
  });

  testWidgets('sortear mostra filme cadastrado', (tester) async {
    await _openHome(tester);
    await tester.tap(find.text('Filmes'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-movie')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('movie-title')), 'Duna');
    await tester.enterText(find.byKey(const Key('movie-genre')), 'Ficção');
    await tester.enterText(find.byKey(const Key('movie-year')), '2021');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sortear'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Sortear filme'));
    await tester.pumpAndSettle();

    expect(find.text('Duna'), findsOneWidget);
  });
}
