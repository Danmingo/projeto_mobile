import 'filme.dart';

/// Números da biblioteca do usuário, mostrados no Perfil.
class EstatisticasBiblioteca {
  const EstatisticasBiblioteca._({
    required this.total,
    required this.assistidos,
    required this.naMinhaLista,
    required this.minutosAssistidos,
    required this.generoFavorito,
    required this.notaMedia,
  });

  factory EstatisticasBiblioteca.de(List<Filme> filmes) {
    final vistos = filmes.where((f) => f.assistido);
    return EstatisticasBiblioteca._(
      total: filmes.length,
      assistidos: vistos.length,
      naMinhaLista: filmes.where((f) => f.naMinhaLista).length,
      minutosAssistidos: vistos.fold(0, (soma, f) => soma + f.duracao),
      generoFavorito: _generoMaisFrequente(filmes),
      notaMedia: filmes.isEmpty
          ? null
          : filmes.fold(0.0, (soma, f) => soma + f.nota) / filmes.length,
    );
  }

  final int total;
  final int assistidos;
  final int naMinhaLista;

  /// Soma da duração dos filmes já assistidos.
  final int minutosAssistidos;

  /// Gênero com mais filmes cadastrados; `null` se não há filmes.
  final String? generoFavorito;

  /// Média das notas de todos os filmes; `null` se não há filmes.
  final double? notaMedia;

  /// Fração dos filmes já assistidos, de 0 a 1.
  double get progresso => total == 0 ? 0 : assistidos / total;

  String get tempoAssistidoFormatado {
    final horas = minutosAssistidos ~/ 60;
    final minutos = minutosAssistidos % 60;
    if (horas == 0) return '${minutos}min';
    return '${horas}h ${minutos.toString().padLeft(2, '0')}min';
  }
}

/// Em caso de empate, vale o gênero que aparece primeiro em [generos].
String? _generoMaisFrequente(List<Filme> filmes) {
  final contagem = <String, int>{};
  for (final filme in filmes) {
    contagem[filme.genero] = (contagem[filme.genero] ?? 0) + 1;
  }
  String? favorito;
  for (final genero in generos) {
    final quantidade = contagem[genero] ?? 0;
    if (quantidade > 0 && quantidade > (contagem[favorito] ?? 0)) {
      favorito = genero;
    }
  }
  return favorito;
}
