import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_mobile/pages/filme_form_page.dart';
import 'package:projeto_mobile/services/filme_service.dart';

import 'helpers.dart';

Finder _campo(String chave) => find.byKey(ValueKey(chave));

Future<void> _preencherValido(WidgetTester tester) async {
  await tester.enterText(_campo('campo-titulo'), 'Duna');
  await escolherOpcao(tester, 'campo-genero', 'Ficção Científica');
  await tester.enterText(_campo('campo-ano'), '2021');
  await tester.enterText(_campo('campo-duracao'), '155');
  await escolherOpcao(tester, 'campo-classificacao', '14 anos');
  await tester.enterText(_campo('campo-nota'), '8,5');
}

void main() {
  testWidgets('salvar vazio mostra os erros e não cadastra', (tester) async {
    usarTelaGrande(tester);
    final service = FilmeService();
    await abrirTela(tester, service, const FilmeFormPage());

    await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastrar filme'));
    await tester.pump();

    expect(find.text('Informe o título'), findsOneWidget);
    expect(find.text('Selecione o gênero'), findsWidgets);
    expect(find.text('Informe o ano'), findsOneWidget);
    expect(find.text('Informe a duração'), findsOneWidget);
    expect(find.text('Selecione a classificação'), findsOneWidget);
    expect(find.text('Informe a nota'), findsOneWidget);
    expect(find.text('Corrija os campos destacados.'), findsOneWidget);
    expect(service.filmes, isEmpty);
  });

  testWidgets('cadastra filme válido, avisa e fecha a tela', (tester) async {
    usarTelaGrande(tester);
    final service = FilmeService();
    await abrirTela(tester, service, const FilmeFormPage());

    await _preencherValido(tester);
    await tester.tap(_campo('campo-assistido'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastrar filme'));
    await tester.pumpAndSettle();

    final salvo = service.filmes.single;
    expect(salvo.titulo, 'Duna');
    expect(salvo.genero, 'Ficção Científica');
    expect(salvo.ano, 2021);
    expect(salvo.duracao, 155);
    expect(salvo.classificacao, '14');
    expect(salvo.nota, 8.5);
    expect(salvo.assistido, isTrue);
    expect(find.text('Filme cadastrado com sucesso!'), findsOneWidget);
    expect(find.byType(FilmeFormPage), findsNothing);
  });

  testWidgets('recusa nota fora do intervalo', (tester) async {
    usarTelaGrande(tester);
    final service = FilmeService();
    await abrirTela(tester, service, const FilmeFormPage());

    await _preencherValido(tester);
    await tester.enterText(_campo('campo-nota'), '11');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastrar filme'));
    await tester.pump();

    expect(find.text('Nota de 0 a 10'), findsOneWidget);
    expect(service.filmes, isEmpty);
  });

  testWidgets('edição abre preenchida e atualiza o filme', (tester) async {
    usarTelaGrande(tester);
    final service = FilmeService.comExemplos();
    final original = service.filmes.first;
    await abrirTela(tester, service, FilmeFormPage(filme: original));

    expect(find.text('Editar filme'), findsOneWidget);
    expect(find.text(original.titulo), findsOneWidget);

    await tester.enterText(_campo('campo-titulo'), 'Interestelar (2014)');
    await tester.tap(find.text('Salvar alterações'));
    await tester.pumpAndSettle();

    expect(service.buscarPorId(original.id)!.titulo, 'Interestelar (2014)');
    expect(service.filmes, hasLength(filmesDeExemplo.length));
    expect(find.text('Filme atualizado com sucesso!'), findsOneWidget);
  });

  testWidgets('cancelar a edição não altera nada', (tester) async {
    usarTelaGrande(tester);
    final service = FilmeService.comExemplos();
    final original = service.filmes.first;
    await abrirTela(tester, service, FilmeFormPage(filme: original));

    await tester.enterText(_campo('campo-titulo'), 'Outro título');
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.byType(FilmeFormPage), findsNothing);
    expect(service.buscarPorId(original.id)!.titulo, original.titulo);
  });

  testWidgets('editar mantém o filme na Minha Lista', (tester) async {
    usarTelaGrande(tester);
    final service = FilmeService.comExemplos();
    final original = await service.alternarMinhaLista(service.filmes.first.id);
    await abrirTela(tester, service, FilmeFormPage(filme: original));

    await tester.enterText(_campo('campo-titulo'), 'Interestelar (2014)');
    await tester.tap(find.text('Salvar alterações'));
    await tester.pumpAndSettle();

    expect(service.buscarPorId(original.id)!.naMinhaLista, isTrue);
  });
}
