import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_mobile/pages/draw_page.dart';
import 'package:projeto_mobile/services/filme_service.dart';

import 'helpers.dart';

Finder _chip(String genero) => find.widgetWithText(FilterChip, genero);

Finder get _botaoSortear => find.widgetWithText(FilledButton, 'Sortear filme');

void main() {
  late FilmeService service;

  setUp(() => service = FilmeService.comExemplos());

  Future<void> abrirSorteador(WidgetTester tester) async {
    usarTelaGrande(tester);
    await abrirTela(tester, service, const DrawPage());
  }

  testWidgets('mostra quantos filmes atendem aos critérios', (tester) async {
    await abrirSorteador(tester);

    // Por padrão os já assistidos (Interestelar e Coringa) ficam de fora.
    expect(find.text('3 filmes atendem aos critérios'), findsOneWidget);

    await tester.tap(find.text('Incluir filmes já assistidos'));
    await tester.pump();
    expect(find.text('5 filmes atendem aos critérios'), findsOneWidget);
  });

  testWidgets('sorteia entre os filmes do gênero escolhido', (tester) async {
    await abrirSorteador(tester);

    await tester.tap(_chip('Animação'));
    await tester.pump();
    expect(find.text('1 filme atende aos critérios'), findsOneWidget);

    await tester.tap(_botaoSortear);
    await tester.pumpAndSettle();

    expect(find.text('Shrek'), findsOneWidget);
  });

  testWidgets('valida a duração máxima antes de sortear', (tester) async {
    await abrirSorteador(tester);

    await tester.enterText(
      find.byKey(const ValueKey('campo-duracao-maxima')),
      '0',
    );
    await tester.tap(_botaoSortear);
    await tester.pump();

    expect(find.text('Deve ser maior que zero'), findsOneWidget);
    expect(find.text('Corrija os campos destacados.'), findsOneWidget);
  });

  testWidgets('avisa quando nenhum filme atende aos critérios', (tester) async {
    await abrirSorteador(tester);

    await tester.enterText(
      find.byKey(const ValueKey('campo-duracao-maxima')),
      '60',
    );
    await tester.pump();
    expect(find.text('Nenhum filme atende aos critérios'), findsOneWidget);

    await tester.tap(_botaoSortear);
    await tester.pump();
    expect(
      find.text(
        'Nenhum filme atende aos critérios. Tente afrouxar os filtros.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('filtra pela classificação indicativa', (tester) async {
    await abrirSorteador(tester);

    await escolherOpcao(tester, 'campo-classificacao-maxima', 'Somente Livre');

    expect(find.text('1 filme atende aos critérios'), findsOneWidget);
  });

  testWidgets('Limpar filtros volta aos critérios padrão', (tester) async {
    await abrirSorteador(tester);

    await tester.tap(_chip('Animação'));
    await escolherOpcao(tester, 'campo-classificacao-maxima', 'Somente Livre');
    await tester.enterText(
      find.byKey(const ValueKey('campo-duracao-maxima')),
      '100',
    );
    await tester.pump();

    await tester.tap(find.text('Limpar filtros'));
    await tester.pumpAndSettle();

    expect(find.text('3 filmes atendem aos critérios'), findsOneWidget);
    expect(find.text('Qualquer classificação'), findsOneWidget);
    expect(find.text('100'), findsNothing);
  });

  testWidgets('sem filmes cadastrados, pede para cadastrar', (tester) async {
    service = FilmeService();
    await abrirSorteador(tester);

    expect(
      find.text('Cadastre pelo menos um filme para realizar o sorteio.'),
      findsOneWidget,
    );
    expect(_botaoSortear, findsNothing);
  });
}
