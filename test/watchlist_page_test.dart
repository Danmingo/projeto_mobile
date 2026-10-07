import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_mobile/pages/resultado_sorteio_page.dart';
import 'package:projeto_mobile/pages/watchlist_page.dart';
import 'package:projeto_mobile/services/filme_service.dart';

import 'helpers.dart';

void main() {
  late FilmeService service;

  setUp(() => service = FilmeService.comExemplos());

  /// Coloca na Minha Lista os filmes de exemplo com estes títulos.
  Future<void> guardar(List<String> titulos) async {
    for (final filme in filmesDeExemplo) {
      if (titulos.contains(filme.titulo)) {
        await service.alternarMinhaLista(filme.id);
      }
    }
  }

  Future<void> abrirLista(WidgetTester tester) async {
    usarTelaGrande(tester);
    await abrirTela(tester, service, const WatchlistPage());
  }

  testWidgets('lista vazia não mostra o botão de sortear', (tester) async {
    await abrirLista(tester);

    expect(find.text('Sua lista está vazia.'), findsOneWidget);
    expect(find.text('Sortear da lista'), findsNothing);
  });

  testWidgets('sorteia apenas entre os filmes da lista', (tester) async {
    await guardar(['Shrek']);
    await abrirLista(tester);

    await tester.tap(find.text('Sortear da lista'));
    await tester.pumpAndSettle();

    expect(find.byType(ResultadoSorteioPage), findsOneWidget);
    expect(find.text('Shrek'), findsOneWidget);
  });

  testWidgets('deixa de fora os filmes da lista já assistidos', (tester) async {
    // Interestelar está na lista, mas já foi assistido.
    await guardar(['Interestelar', 'O Batman']);
    await abrirLista(tester);

    await tester.tap(find.text('Sortear da lista'));
    await tester.pumpAndSettle();

    expect(find.text('O Batman'), findsOneWidget);
    expect(find.text('Interestelar'), findsNothing);
  });

  testWidgets('avisa quando todos da lista já foram assistidos', (
    tester,
  ) async {
    await guardar(['Interestelar', 'Coringa']);
    await abrirLista(tester);

    await tester.tap(find.text('Sortear da lista'));
    await tester.pump();

    expect(
      find.text('Todos os filmes da sua lista já foram assistidos.'),
      findsOneWidget,
    );
    expect(find.byType(ResultadoSorteioPage), findsNothing);
  });
}
