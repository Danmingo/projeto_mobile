import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_mobile/models/filme.dart';
import 'package:projeto_mobile/services/filme_service.dart';

const _rascunho = Filme(
  id: '',
  titulo: 'Duna',
  genero: 'Ficção Científica',
  ano: 2021,
  duracao: 155,
  classificacao: '14',
  nota: 8.0,
);

void main() {
  late FilmeService service;
  late int notificacoes;

  setUp(() {
    service = FilmeService();
    notificacoes = 0;
    service.addListener(() => notificacoes++);
  });

  test('adicionar gera id único e avisa as telas', () async {
    final primeiro = await service.adicionar(_rascunho);
    final segundo = await service.adicionar(_rascunho);

    expect(primeiro.id, isNotEmpty);
    expect(primeiro.id, isNot(segundo.id));
    expect(service.filmes, hasLength(2));
    expect(notificacoes, 2);
  });

  test('atualizar substitui o filme com o mesmo id', () async {
    final salvo = await service.adicionar(_rascunho);

    await service.atualizar(salvo.copyWith(titulo: 'Duna: Parte Um'));

    expect(service.buscarPorId(salvo.id)!.titulo, 'Duna: Parte Um');
    expect(service.filmes, hasLength(1));
  });

  test('atualizar um filme inexistente falha', () {
    expect(
      () => service.atualizar(_rascunho.copyWith(id: 'nao-existe')),
      throwsArgumentError,
    );
  });

  test('remover tira o filme da lista', () async {
    final salvo = await service.adicionar(_rascunho);

    await service.remover(salvo.id);

    expect(service.filmes, isEmpty);
    expect(service.buscarPorId(salvo.id), isNull);
  });

  test('a lista exposta não pode ser alterada por fora', () {
    expect(() => service.filmes.add(_rascunho), throwsUnsupportedError);
  });

  test('comExemplos começa com filmes cadastrados', () {
    expect(FilmeService.comExemplos().filmes, isNotEmpty);
  });

  test('duracaoFormatada converte minutos em horas', () {
    expect(_rascunho.duracaoFormatada, '2h 35min');
    expect(_rascunho.copyWith(duracao: 90).duracaoFormatada, '1h 30min');
  });

  test('alternarMinhaLista coloca e tira o filme da lista', () async {
    final salvo = await service.adicionar(_rascunho);

    final dentro = await service.alternarMinhaLista(salvo.id);
    expect(dentro.naMinhaLista, isTrue);
    expect(service.buscarPorId(salvo.id)!.naMinhaLista, isTrue);

    final fora = await service.alternarMinhaLista(salvo.id);
    expect(fora.naMinhaLista, isFalse);
  });

  test('alternarAssistido inverte o status de assistido', () async {
    final salvo = await service.adicionar(_rascunho);

    final assistido = await service.alternarAssistido(salvo.id);

    expect(assistido.assistido, isTrue);
    expect(service.buscarPorId(salvo.id)!.assistido, isTrue);
  });

  test('alternar um filme inexistente falha', () {
    expect(() => service.alternarMinhaLista('nao-existe'), throwsArgumentError);
  });
}
