import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_mobile/services/filme_scope.dart';
import 'package:projeto_mobile/services/filme_service.dart';

/// Tela de celular alta o bastante para o formulário inteiro caber sem rolar.
void usarTelaGrande(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 3200);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
}

/// Abre [tela] por cima de uma tela inicial, para que `Navigator.pop`
/// tenha para onde voltar.
Future<void> abrirTela(
  WidgetTester tester,
  FilmeService service,
  Widget tela,
) async {
  await tester.pumpWidget(
    FilmeScope(
      service: service,
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () =>
                    Navigator.of(context)
                        .push(MaterialPageRoute<void>(builder: (_) => tela)),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
}

Future<void> escolherOpcao(
  WidgetTester tester,
  String chaveCampo,
  String opcao,
) async {
  await tester.tap(find.byKey(ValueKey(chaveCampo)));
  await tester.pumpAndSettle();
  await tester.tap(find.text(opcao).last);
  await tester.pumpAndSettle();
}
