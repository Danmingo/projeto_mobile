import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_mobile/utils/validadores_filme.dart';

void main() {
  group('titulo', () {
    test('recusa vazio ou só espaços', () {
      expect(ValidadoresFilme.titulo(''), isNotNull);
      expect(ValidadoresFilme.titulo('   '), isNotNull);
      expect(ValidadoresFilme.titulo('Shrek'), isNull);
    });
  });

  group('ano', () {
    test('aceita de 1888 até o ano que vem', () {
      expect(ValidadoresFilme.ano('1888', anoAtual: 2026), isNull);
      expect(ValidadoresFilme.ano('2027', anoAtual: 2026), isNull);
    });

    test('recusa fora do intervalo ou não numérico', () {
      expect(ValidadoresFilme.ano('1887', anoAtual: 2026), isNotNull);
      expect(ValidadoresFilme.ano('2028', anoAtual: 2026), isNotNull);
      expect(ValidadoresFilme.ano('abc', anoAtual: 2026), isNotNull);
      expect(ValidadoresFilme.ano('', anoAtual: 2026), 'Informe o ano');
    });
  });

  group('duracao', () {
    test('precisa ser maior que zero', () {
      expect(ValidadoresFilme.duracao('0'), isNotNull);
      expect(ValidadoresFilme.duracao('1'), isNull);
      expect(ValidadoresFilme.duracao(''), 'Informe a duração');
    });
  });

  group('nota', () {
    test('aceita de 0 a 10 com vírgula ou ponto', () {
      expect(ValidadoresFilme.nota('0'), isNull);
      expect(ValidadoresFilme.nota('10'), isNull);
      expect(ValidadoresFilme.nota('8,5'), isNull);
      expect(ValidadoresFilme.nota('8.5'), isNull);
    });

    test('recusa fora do intervalo ou mal formatada', () {
      expect(ValidadoresFilme.nota('10.1'), isNotNull);
      expect(ValidadoresFilme.nota('-1'), isNotNull);
      expect(ValidadoresFilme.nota('8,,5'), isNotNull);
    });

    test('lerNota converte vírgula em ponto', () {
      expect(ValidadoresFilme.lerNota(' 7,25 '), 7.25);
    });
  });

  test('selecao exige um valor escolhido', () {
    expect(ValidadoresFilme.selecao(null, 'o gênero'), 'Selecione o gênero');
    expect(ValidadoresFilme.selecao('Drama', 'o gênero'), isNull);
  });
}
