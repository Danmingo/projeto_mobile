import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_mobile/models/estatisticas_biblioteca.dart';
import 'package:projeto_mobile/models/filme.dart';

Filme _filme(
  String genero, {
  int duracao = 100,
  double nota = 8,
  bool assistido = false,
  bool naMinhaLista = false,
}) => Filme(
  id: '',
  titulo: 'Filme',
  genero: genero,
  ano: 2020,
  duracao: duracao,
  classificacao: 'Livre',
  nota: nota,
  assistido: assistido,
  naMinhaLista: naMinhaLista,
);

void main() {
  test('biblioteca vazia não quebra', () {
    final e = EstatisticasBiblioteca.de([]);

    expect(e.total, 0);
    expect(e.progresso, 0);
    expect(e.generoFavorito, isNull);
    expect(e.notaMedia, isNull);
    expect(e.tempoAssistidoFormatado, '0min');
  });

  test('conta cadastrados, assistidos e Minha Lista', () {
    final e = EstatisticasBiblioteca.de([
      _filme('Ação', assistido: true),
      _filme('Ação', naMinhaLista: true),
      _filme('Drama', assistido: true, naMinhaLista: true),
      _filme('Drama'),
    ]);

    expect(e.total, 4);
    expect(e.assistidos, 2);
    expect(e.naMinhaLista, 2);
    expect(e.progresso, 0.5);
  });

  test('tempo assistido soma só os filmes vistos', () {
    final e = EstatisticasBiblioteca.de([
      _filme('Ação', duracao: 169, assistido: true),
      _filme('Drama', duracao: 122, assistido: true),
      _filme('Drama', duracao: 500),
    ]);

    expect(e.minutosAssistidos, 291);
    expect(e.tempoAssistidoFormatado, '4h 51min');
  });

  test('gênero favorito é o mais cadastrado', () {
    final e = EstatisticasBiblioteca.de([
      _filme('Drama'),
      _filme('Terror'),
      _filme('Terror'),
    ]);

    expect(e.generoFavorito, 'Terror');
  });

  test('no empate, vale a ordem da lista de gêneros', () {
    final e = EstatisticasBiblioteca.de([_filme('Drama'), _filme('Ação')]);

    expect(e.generoFavorito, 'Ação');
  });

  test('nota média de todos os filmes', () {
    final e = EstatisticasBiblioteca.de([
      _filme('Ação', nota: 7),
      _filme('Ação', nota: 8.5),
    ]);

    expect(e.notaMedia, closeTo(7.75, 0.001));
  });
}
