import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_mobile/models/criterios_sorteio.dart';
import 'package:projeto_mobile/models/filme.dart';
import 'package:projeto_mobile/services/filme_service.dart';
import 'package:projeto_mobile/utils/sorteio.dart';

List<String> _titulos(List<Filme> filmes) => [for (final f in filmes) f.titulo];

List<String> _filtrar(CriteriosSorteio criterios) =>
    _titulos(criterios.filtrar(filmesDeExemplo));

void main() {
  group('CriteriosSorteio', () {
    test('por padrão deixa de fora os filmes já assistidos', () {
      expect(_filtrar(const CriteriosSorteio()), [
        'O Batman',
        'Shrek',
        'Vingadores: Ultimato',
      ]);
    });

    test('incluirAssistidos aceita todos os filmes', () {
      expect(
        _filtrar(const CriteriosSorteio(incluirAssistidos: true)),
        hasLength(filmesDeExemplo.length),
      );
    });

    test('filtra por um ou mais gêneros', () {
      expect(_filtrar(const CriteriosSorteio(generos: {'Ação'})), [
        'O Batman',
        'Vingadores: Ultimato',
      ]);
      expect(
        _filtrar(
          const CriteriosSorteio(
            generos: {'Animação', 'Drama'},
            incluirAssistidos: true,
          ),
        ),
        ['Coringa', 'Shrek'],
      );
    });

    test('filtra pela duração máxima, inclusive o limite', () {
      expect(_filtrar(const CriteriosSorteio(duracaoMaxima: 120)), ['Shrek']);
      expect(_filtrar(const CriteriosSorteio(duracaoMaxima: 90)), ['Shrek']);
      expect(_filtrar(const CriteriosSorteio(duracaoMaxima: 89)), isEmpty);
    });

    test('filtra pela nota mínima', () {
      expect(_filtrar(const CriteriosSorteio(notaMinima: 8)), [
        'Vingadores: Ultimato',
      ]);
    });

    test('classificação máxima aceita as classificações menores', () {
      expect(_filtrar(const CriteriosSorteio(classificacaoMaxima: '12')), [
        'Shrek',
        'Vingadores: Ultimato',
      ]);
      expect(_filtrar(const CriteriosSorteio(classificacaoMaxima: 'Livre')), [
        'Shrek',
      ]);
    });

    test('somenteMinhaLista aceita só os filmes da Minha Lista', () {
      final filmes = [
        for (final f in filmesDeExemplo)
          f.titulo == 'Shrek' ? f.copyWith(naMinhaLista: true) : f,
      ];
      expect(
        _titulos(
          const CriteriosSorteio(somenteMinhaLista: true).filtrar(filmes),
        ),
        ['Shrek'],
      );
    });

    test('combina todos os critérios', () {
      expect(
        _filtrar(
          const CriteriosSorteio(
            generos: {'Ação'},
            classificacaoMaxima: '12',
            notaMinima: 8,
          ),
        ),
        ['Vingadores: Ultimato'],
      );
    });
  });

  group('sortearFilme', () {
    final [interestelar, batman, ..._] = filmesDeExemplo;

    test('devolve null quando não há candidatos', () {
      expect(sortearFilme([]), isNull);
    });

    test('com um só candidato, devolve ele mesmo que repita', () {
      expect(sortearFilme([batman], anteriorId: batman.id)?.titulo, 'O Batman');
    });

    test('com mais de um candidato, nunca repete o anterior', () {
      for (var semente = 0; semente < 20; semente++) {
        final sorteado = sortearFilme(
          [interestelar, batman],
          anteriorId: batman.id,
          random: Random(semente),
        );
        expect(sorteado?.titulo, 'Interestelar');
      }
    });

    test('sempre escolhe um dos candidatos', () {
      for (var semente = 0; semente < 20; semente++) {
        final sorteado = sortearFilme(filmesDeExemplo, random: Random(semente));
        expect(filmesDeExemplo, contains(sorteado));
      }
    });
  });

  group('validarDuracaoMaxima', () {
    test('vazio é válido (sem limite)', () {
      expect(validarDuracaoMaxima(''), isNull);
      expect(validarDuracaoMaxima(null), isNull);
    });

    test('aceita valores entre 1 e o máximo', () {
      expect(validarDuracaoMaxima('120'), isNull);
      expect(validarDuracaoMaxima('$duracaoMaximaPermitida'), isNull);
    });

    test('rejeita zero e valores acima do máximo', () {
      expect(validarDuracaoMaxima('0'), 'Deve ser maior que zero');
      expect(
        validarDuracaoMaxima('${duracaoMaximaPermitida + 1}'),
        'No máximo $duracaoMaximaPermitida minutos',
      );
    });
  });
}
