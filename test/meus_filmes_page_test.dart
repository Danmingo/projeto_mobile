import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_mobile/models/filme.dart';
import 'package:projeto_mobile/pages/detalhes_filme_page.dart';
import 'package:projeto_mobile/pages/meus_filmes_page.dart';
import 'package:projeto_mobile/services/filme_service.dart';

import 'helpers.dart';

Finder _chip(String genero) => find.widgetWithText(ChoiceChip, genero);

void main() {
  late FilmeService service;

  setUp(() => service = FilmeService.comExemplos());

  Future<void> abrirLista(WidgetTester tester) async {
    usarTelaGrande(tester);
    await abrirTela(tester, service, const MeusFilmesPage());
  }

  testWidgets('lista todos os filmes cadastrados', (tester) async {
    await abrirLista(tester);

    for (final filme in filmesDeExemplo) {
      expect(find.text(filme.titulo), findsOneWidget);
    }
  });

  testWidgets('busca pelo título ignorando maiúsculas', (tester) async {
    await abrirLista(tester);

    await tester.enterText(find.byKey(const ValueKey('campo-busca')), 'VINGA');
    await tester.pump();

    expect(find.text('Vingadores: Ultimato'), findsOneWidget);
    expect(find.text('Shrek'), findsNothing);
  });

  testWidgets('busca ignora acentos', (tester) async {
    await service.adicionar(
      const Filme(
        id: '',
        titulo: 'Pânico',
        genero: 'Terror',
        ano: 1996,
        duracao: 111,
        classificacao: '16',
        nota: 7.4,
      ),
    );
    await abrirLista(tester);

    await tester.enterText(find.byKey(const ValueKey('campo-busca')), 'panico');
    await tester.pump();

    expect(find.text('Pânico'), findsOneWidget);
  });

  testWidgets('filtra por gênero', (tester) async {
    await abrirLista(tester);

    await tester.tap(_chip('Animação'));
    await tester.pump();

    expect(find.text('Shrek'), findsOneWidget);
    expect(find.text('Interestelar'), findsNothing);

    await tester.tap(_chip('Todos'));
    await tester.pump();
    expect(find.text('Interestelar'), findsOneWidget);
  });

  testWidgets('avisa quando o filtro não encontra nada', (tester) async {
    await abrirLista(tester);

    // Os últimos gêneros ficam fora da tela, à direita: rola até aparecer.
    await tester.scrollUntilVisible(
      _chip('Romance'),
      150,
      scrollable: find.descendant(
        of: find.byKey(const ValueKey('filtros-genero')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(_chip('Romance'));
    await tester.pump();

    expect(find.text('Nenhum filme encontrado'), findsOneWidget);
  });

  testWidgets('avisa quando não há filmes cadastrados', (tester) async {
    service = FilmeService();
    await abrirLista(tester);

    expect(find.text('Nenhum filme cadastrado ainda'), findsOneWidget);
  });

  testWidgets('tocar no filme abre os detalhes', (tester) async {
    await abrirLista(tester);

    await tester.tap(find.text('Shrek'));
    await tester.pumpAndSettle();

    expect(find.byType(DetalhesFilmePage), findsOneWidget);
  });

  testWidgets('excluir pelo menu pede confirmação e remove', (tester) async {
    await abrirLista(tester);

    final itemShrek = find.ancestor(
      of: find.text('Shrek'),
      matching: find.byType(Card),
    );
    await tester.tap(
      find.descendant(of: itemShrek, matching: find.byTooltip('Opções')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Excluir'));
    await tester.pumpAndSettle();

    expect(find.text('Shrek'), findsNothing);
    expect(service.filmes, hasLength(filmesDeExemplo.length - 1));
    expect(find.text('Filme excluído com sucesso!'), findsOneWidget);
  });

  Future<void> escolherNoMenu(
    WidgetTester tester,
    String titulo,
    String acao,
  ) async {
    final item = find.ancestor(
      of: find.text(titulo),
      matching: find.byType(Card),
    );
    await tester.tap(
      find.descendant(of: item, matching: find.byTooltip('Opções')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(acao));
    await tester.pumpAndSettle();
  }

  testWidgets('adiciona à Minha Lista pelo menu e avisa', (tester) async {
    await abrirLista(tester);

    await escolherNoMenu(tester, 'Shrek', 'Adicionar à Minha Lista');

    final shrek = service.filmes.firstWhere((f) => f.titulo == 'Shrek');
    expect(shrek.naMinhaLista, isTrue);
    expect(find.text('"Shrek" adicionado à Minha Lista.'), findsOneWidget);
    expect(find.byTooltip('Na Minha Lista'), findsOneWidget);

    await escolherNoMenu(tester, 'Shrek', 'Remover da Minha Lista');
    expect(service.buscarPorId(shrek.id)!.naMinhaLista, isFalse);
  });

  testWidgets('marca como assistido pelo menu', (tester) async {
    await abrirLista(tester);

    await escolherNoMenu(tester, 'Shrek', 'Marcar como assistido');

    final shrek = service.filmes.firstWhere((f) => f.titulo == 'Shrek');
    expect(shrek.assistido, isTrue);
    expect(find.text('"Shrek" marcado como assistido.'), findsOneWidget);
  });
}
