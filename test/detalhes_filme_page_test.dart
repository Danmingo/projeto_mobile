import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_mobile/pages/detalhes_filme_page.dart';
import 'package:projeto_mobile/services/filme_service.dart';

import 'helpers.dart';

void main() {
  late FilmeService service;

  setUp(() => service = FilmeService.comExemplos());

  Future<void> abrirDetalhesDoPrimeiro(WidgetTester tester) async {
    usarTelaGrande(tester);
    await abrirTela(
      tester,
      service,
      DetalhesFilmePage(filme: service.filmes.first),
    );
  }

  testWidgets('mostra as informações do filme', (tester) async {
    await abrirDetalhesDoPrimeiro(tester);

    expect(find.text('Interestelar'), findsOneWidget);
    expect(find.text('2014 • Ficção Científica • 2h 49min'), findsOneWidget);
    expect(find.text('8,7'), findsOneWidget);
    expect(find.text('10 anos'), findsOneWidget);
    expect(find.text('Assistido'), findsOneWidget);
    expect(find.textContaining('buraco de minhoca'), findsOneWidget);
  });

  testWidgets('cancelar a exclusão mantém o filme', (tester) async {
    await abrirDetalhesDoPrimeiro(tester);

    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    expect(find.text('Excluir filme?'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.byType(DetalhesFilmePage), findsOneWidget);
    expect(service.filmes, hasLength(filmesDeExemplo.length));
  });

  testWidgets('confirmar a exclusão remove, avisa e fecha', (tester) async {
    await abrirDetalhesDoPrimeiro(tester);
    final id = service.filmes.first.id;

    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Excluir'));
    await tester.pumpAndSettle();

    expect(service.buscarPorId(id), isNull);
    expect(find.byType(DetalhesFilmePage), findsNothing);
    expect(find.text('Filme excluído com sucesso!'), findsOneWidget);
  });

  testWidgets('editar atualiza os detalhes ao voltar', (tester) async {
    await abrirDetalhesDoPrimeiro(tester);

    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('campo-titulo')),
      'Interstellar',
    );
    await tester.tap(find.text('Salvar alterações'));
    await tester.pumpAndSettle();

    expect(find.byType(DetalhesFilmePage), findsOneWidget);
    expect(find.text('Interstellar'), findsOneWidget);
  });
}
