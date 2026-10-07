import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_mobile/main.dart';
import 'package:projeto_mobile/pages/meus_filmes_page.dart';
import 'package:projeto_mobile/services/filme_service.dart';

import 'helpers.dart';

/// Abre a home com a lista de filmes vazia.
Future<void> _openHome(WidgetTester tester) async {
  usarTelaGrande(tester, largura: 800);
  await tester.pumpWidget(MoviePickApp(filmeService: FilmeService()));
  await tester.tap(find.text('Entrar'));
  await tester.pumpAndSettle();
}

/// Cadastra "Duna" pelo formulário, a partir da aba Filmes.
Future<void> _cadastrarDuna(WidgetTester tester) async {
  await tester.tap(find.text('Filmes'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Novo filme'));
  await tester.pumpAndSettle();

  await tester.enterText(find.byKey(const ValueKey('campo-titulo')), 'Duna');
  await escolherOpcao(tester, 'campo-genero', 'Ficção Científica');
  await tester.enterText(find.byKey(const ValueKey('campo-ano')), '2021');
  await tester.enterText(find.byKey(const ValueKey('campo-duracao')), '155');
  await escolherOpcao(tester, 'campo-classificacao', '14 anos');
  await tester.enterText(find.byKey(const ValueKey('campo-nota')), '8');
  await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastrar filme'));
  await tester.pumpAndSettle();
}

Future<void> _abrirMenuDaDuna(WidgetTester tester, String acao) async {
  await tester.tap(find.byTooltip('Opções'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(acao));
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

  testWidgets('o app começa com os filmes de exemplo', (tester) async {
    usarTelaGrande(tester, largura: 800);
    await tester.pumpWidget(const MoviePickApp());
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('${filmesDeExemplo.length}'), findsOneWidget);
    expect(find.text('Últimos adicionados'), findsOneWidget);
    expect(find.text('Vingadores: Ultimato'), findsOneWidget);
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
    expect(find.byType(MeusFilmesPage), findsOneWidget);
    expect(find.text('Nenhum filme cadastrado ainda'), findsOneWidget);

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
    await _cadastrarDuna(tester);

    expect(find.text('Duna'), findsOneWidget);
    await tester.tap(find.text('Início'));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Duna'), findsOneWidget);
  });

  testWidgets('remove filme e volta contador para zero', (tester) async {
    await _openHome(tester);
    await _cadastrarDuna(tester);

    await _abrirMenuDaDuna(tester, 'Excluir');
    expect(find.text('Excluir filme?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Excluir'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Início'));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsNWidgets(3));
    expect(find.text('Nenhum filme cadastrado ainda.'), findsOneWidget);
  });

  testWidgets('adiciona filme e mostra em Minha Lista', (tester) async {
    await _openHome(tester);
    await _cadastrarDuna(tester);

    await _abrirMenuDaDuna(tester, 'Adicionar à Minha Lista');

    await tester.tap(find.text('Lista'));
    await tester.pumpAndSettle();
    expect(find.text('Duna'), findsOneWidget);
  });

  testWidgets('sortear mostra filme cadastrado', (tester) async {
    await _openHome(tester);
    await _cadastrarDuna(tester);

    await tester.tap(find.text('Sortear'));
    await tester.pumpAndSettle();
    // Espera o aviso "Filme cadastrado" sumir: ele cobre o botão de sortear.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Sortear filme'));
    await tester.pumpAndSettle();

    expect(find.text('Duna'), findsOneWidget);
  });
}
