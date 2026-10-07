import 'filme.dart';

/// Filtros escolhidos na tela Sortear. Um filme só entra no sorteio se
/// atender a todos eles.
class CriteriosSorteio {
  const CriteriosSorteio({
    this.generos = const {},
    this.duracaoMaxima,
    this.notaMinima = 0,
    this.classificacaoMaxima,
    this.incluirAssistidos = false,
  });

  /// Gêneros aceitos; vazio aceita qualquer gênero.
  final Set<String> generos;

  /// Em minutos; `null` não limita a duração.
  final int? duracaoMaxima;

  /// De 0 a 10.
  final double notaMinima;

  /// Classificação mais alta aceita: '14' aceita Livre, 10, 12 e 14.
  /// `null` aceita todas.
  final String? classificacaoMaxima;

  final bool incluirAssistidos;

  bool aceita(Filme filme) {
    final duracao = duracaoMaxima;
    final classificacao = classificacaoMaxima;
    return (generos.isEmpty || generos.contains(filme.genero)) &&
        (duracao == null || filme.duracao <= duracao) &&
        filme.nota >= notaMinima &&
        (classificacao == null ||
            classificacoes.indexOf(filme.classificacao) <=
                classificacoes.indexOf(classificacao)) &&
        (incluirAssistidos || !filme.assistido);
  }

  /// Filmes de [filmes] que podem ser sorteados.
  List<Filme> filtrar(List<Filme> filmes) => filmes.where(aceita).toList();
}
