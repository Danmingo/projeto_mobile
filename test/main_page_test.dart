import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_mobile/main.dart';
import 'package:projeto_mobile/services/filme_service.dart';

import 'helpers.dart';

/// Abre o app já carregando os filmes de [repositorio] e entra na home.
Future<void> _entrarCarregando(
  WidgetTester tester,
  RepositorioControlado repositorio,
) async {
  usarTelaGrande(tester, largura: 800);
  final service = FilmeService(repositorio);
  unawaited(service.carregar());
  await tester.pumpWidget(MoviePickApp(filmeService: service));
  await tester.tap(find.text('Entrar'));
  // O indicador gira para sempre: pumpAndSettle nunca terminaria.
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets('mostra carregando e depois os filmes salvos', (tester) async {
    final repositorio = RepositorioControlado();
    await _entrarCarregando(tester, repositorio);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Início'), findsNothing);

    repositorio.leitura.complete(filmesDeExemplo);
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Vingadores: Ultimato'), findsOneWidget);
  });

  testWidgets('erro ao carregar permite tentar de novo', (tester) async {
    final repositorio = RepositorioControlado();
    await _entrarCarregando(tester, repositorio);

    repositorio.leitura.completeError(Exception('banco corrompido'));
    await tester.pumpAndSettle();
    expect(find.text('Não foi possível carregar seus filmes.'), findsOneWidget);

    repositorio.leitura = Completer()..complete(filmesDeExemplo);
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(find.text('Não foi possível carregar seus filmes.'), findsNothing);
    expect(find.text('Vingadores: Ultimato'), findsOneWidget);
  });
}
