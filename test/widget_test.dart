import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_mobile/main.dart';

void main() {
  testWidgets('exibe login e navega para a home', (WidgetTester tester) async {
    await tester.pumpWidget(const MoviePickApp());

    expect(find.text('Bem-vindo!'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Olá, Usuário! 👋'), findsOneWidget);
    expect(find.text('Resumo'), findsOneWidget);
    expect(find.text('Início'), findsOneWidget);
  });
}
