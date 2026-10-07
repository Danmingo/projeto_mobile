import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_mobile/models/criterios_sorteio.dart';
import 'package:projeto_mobile/models/filme.dart';
import 'package:projeto_mobile/pages/resultado_sorteio_page.dart';
import 'package:projeto_mobile/services/filme_service.dart';

import 'helpers.dart';

void main() {
  late FilmeService service;

  setUp(() => service = FilmeService.comExemplos());

  Filme exemplo(String titulo) =>
      filmesDeExemplo.firstWhere((f) => f.titulo == titulo);

  Future<void> abrirResultado(
    WidgetTester tester, {
    required CriteriosSorteio criterios,
    required String sorteado,
  }) async {
    usarTelaGrande(tester);
    await abrirTela(
      tester,
      service,
      ResultadoSorteioPage(criterios: criterios, sorteado: exemplo(sorteado)),
    );
  }

  testWidgets('mostra as informações do filme sorteado', (tester) async {
    await abrirResultado(
      tester,
      criterios: const CriteriosSorteio(),
      sorteado: 'Shrek',
    );

    expect(find.text('Filme sorteado'), findsOneWidget);
    expect(find.text('Shrek'), findsOneWidget);
    expect(find.text('2001 • Animação • 1h 30min'), findsOneWidget);
    expect(find.text('7,9'), findsOneWidget);
    expect(find.text('Livre'), findsOneWidget);
    expect(find.textContaining('Um ogro que só quer sossego'), findsOneWidget);
  });

  testWidgets('Sortear novamente troca por outro filme', (tester) async {
    await abrirResultado(
      tester,
      criterios: const CriteriosSorteio(generos: {'Ação'}),
      sorteado: 'O Batman',
    );

    await tester.tap(find.text('Sortear novamente'));
    await tester.pumpAndSettle();

    expect(find.text('Vingadores: Ultimato'), findsOneWidget);
    expect(find.text('O Batman'), findsNothing);
  });

  testWidgets('avisa quando só um filme atende aos critérios', (tester) async {
    await abrirResultado(
      tester,
      criterios: const CriteriosSorteio(generos: {'Animação'}),
      sorteado: 'Shrek',
    );

    await tester.tap(find.text('Sortear novamente'));
    await tester.pump();

    expect(
      find.text('Este é o único filme que atende aos critérios.'),
      findsOneWidget,
    );
    expect(find.text('Shrek'), findsOneWidget);
  });

  testWidgets('adiciona à Minha Lista e avisa', (tester) async {
    await abrirResultado(
      tester,
      criterios: const CriteriosSorteio(),
      sorteado: 'Shrek',
    );

    await tester.tap(find.text('Minha Lista'));
    await tester.pump();

    expect(service.buscarPorId(exemplo('Shrek').id)!.naMinhaLista, isTrue);
    expect(find.text('"Shrek" adicionado à Minha Lista.'), findsOneWidget);
    expect(find.text('Na lista'), findsOneWidget);
  });

  testWidgets('marca como assistido e deixa de sortear o filme', (
    tester,
  ) async {
    await abrirResultado(
      tester,
      criterios: const CriteriosSorteio(generos: {'Animação'}),
      sorteado: 'Shrek',
    );

    await tester.tap(find.text('Já assisti'));
    await tester.pump();
    expect(service.buscarPorId(exemplo('Shrek').id)!.assistido, isTrue);
    expect(find.text('Assistido'), findsOneWidget);

    // Os critérios não incluem assistidos: não sobra nenhum outro filme.
    await tester.tap(find.text('Sortear novamente'));
    await tester.pump();
    expect(
      find.text('Nenhum outro filme atende aos critérios.'),
      findsOneWidget,
    );
  });

  testWidgets('a seta de voltar retorna para a tela anterior', (tester) async {
    await abrirResultado(
      tester,
      criterios: const CriteriosSorteio(),
      sorteado: 'Shrek',
    );

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(ResultadoSorteioPage), findsNothing);
    expect(find.text('abrir'), findsOneWidget);
  });
}
