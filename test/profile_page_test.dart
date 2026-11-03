import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_mobile/main.dart';
import 'package:projeto_mobile/pages/profile_page.dart';
import 'package:projeto_mobile/services/filme_service.dart';

import 'helpers.dart';

void main() {
  testWidgets('mostra as estatísticas dos filmes de exemplo', (tester) async {
    usarTelaGrande(tester);
    // Exemplos: 5 filmes, 2 assistidos (Interestelar 169 min + Coringa 122).
    await abrirTela(tester, FilmeService.comExemplos(), const ProfilePage());

    expect(find.text('5'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Você já assistiu 40% dos seus filmes'), findsOneWidget);
    expect(find.text('4h 51min'), findsOneWidget);
    expect(find.text('Ação'), findsOneWidget);
    expect(find.text('8,2'), findsOneWidget);
  });

  testWidgets('atualiza quando um filme é marcado como assistido', (
    tester,
  ) async {
    usarTelaGrande(tester);
    final service = FilmeService.comExemplos();
    await abrirTela(tester, service, const ProfilePage());

    final shrek = service.filmes.firstWhere((f) => f.titulo == 'Shrek');
    await service.alternarAssistido(shrek.id);
    await tester.pump();

    expect(find.text('Você já assistiu 60% dos seus filmes'), findsOneWidget);
  });

  testWidgets('biblioteca vazia mostra traços', (tester) async {
    usarTelaGrande(tester);
    await abrirTela(tester, FilmeService.emMemoria(), const ProfilePage());

    expect(find.text('Você já assistiu 0% dos seus filmes'), findsOneWidget);
    expect(find.text('—'), findsNWidgets(2));
  });

  Future<void> abrirPerfilPeloApp(WidgetTester tester) async {
    usarTelaGrande(tester, largura: 800);
    await tester.pumpWidget(
      MoviePickApp(filmeService: FilmeService.comExemplos(), authService: await authAutenticadoParaTeste()),
    );
      await tester.pumpAndSettle();
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sair da conta'));
    await tester.pumpAndSettle();
  }

  testWidgets('sair pede confirmação e volta ao login', (tester) async {
    await abrirPerfilPeloApp(tester);
    expect(find.text('Sair da conta?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Sair'));
    await tester.pumpAndSettle();

    expect(find.text('Bem-vindo!'), findsOneWidget);
    // Nenhuma tela ficou por baixo do login.
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navigator.canPop(), isFalse);
  });

  testWidgets('cancelar sair continua no perfil', (tester) async {
    await abrirPerfilPeloApp(tester);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.text('Sair da conta?'), findsNothing);
    expect(find.text('Sua biblioteca'), findsOneWidget);
  });
}
