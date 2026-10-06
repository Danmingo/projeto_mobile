import 'dart:typed_data';

const generos = [
  'Ação',
  'Animação',
  'Aventura',
  'Comédia',
  'Drama',
  'Ficção Científica',
  'Romance',
  'Terror',
  'Outro',
];

/// Classificação indicativa brasileira (ClassInd).
const classificacoes = ['Livre', '10', '12', '14', '16', '18'];

class Filme {
  const Filme({
    required this.id,
    required this.titulo,
    required this.genero,
    required this.ano,
    required this.duracao,
    required this.classificacao,
    required this.nota,
    this.sinopse = '',
    this.assistido = false,
    this.poster,
  });

  final String id;
  final String titulo;
  final String genero;
  final int ano;

  /// Duração em minutos.
  final int duracao;
  final String classificacao;

  /// Nota de 0 a 10.
  final double nota;
  final String sinopse;
  final bool assistido;

  /// Bytes da imagem escolhida na galeria (em memória, como o resto da Parte 1).
  final Uint8List? poster;

  String get duracaoFormatada =>
      '${duracao ~/ 60}h ${(duracao % 60).toString().padLeft(2, '0')}min';

  String get classificacaoFormatada =>
      classificacao == 'Livre' ? 'Livre' : '$classificacao anos';

  Filme copyWith({
    String? id,
    String? titulo,
    String? genero,
    int? ano,
    int? duracao,
    String? classificacao,
    double? nota,
    String? sinopse,
    bool? assistido,
    Uint8List? poster,
  }) {
    return Filme(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      genero: genero ?? this.genero,
      ano: ano ?? this.ano,
      duracao: duracao ?? this.duracao,
      classificacao: classificacao ?? this.classificacao,
      nota: nota ?? this.nota,
      sinopse: sinopse ?? this.sinopse,
      assistido: assistido ?? this.assistido,
      poster: poster ?? this.poster,
    );
  }
}
