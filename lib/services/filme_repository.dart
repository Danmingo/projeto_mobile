import '../models/filme.dart';

/// Onde os filmes ficam guardados.
///
/// O [FilmeService] só conversa com esta interface, então trocar a memória
/// por um banco de dados não muda nenhuma tela.
abstract interface class FilmeRepository {
  /// Todos os filmes, na ordem em que foram cadastrados.
  Future<List<Filme>> listar();

  /// Grava o filme com um id novo e devolve o filme salvo.
  Future<Filme> inserir(Filme filme);

  /// Substitui o filme com o mesmo id. Falha se ele não existir.
  Future<void> atualizar(Filme filme);

  Future<void> remover(String id);
}

/// Guarda os filmes só enquanto o app está aberto (testes e versão web).
class FilmeRepositoryMemoria implements FilmeRepository {
  FilmeRepositoryMemoria([List<Filme> iniciais = const []])
    : _filmes = [...iniciais];

  final List<Filme> _filmes;
  int _sequencia = 0;

  @override
  Future<List<Filme>> listar() async => [..._filmes];

  @override
  Future<Filme> inserir(Filme filme) async {
    _sequencia++;
    final novo = filme.copyWith(id: 'filme-$_sequencia');
    _filmes.add(novo);
    return novo;
  }

  @override
  Future<void> atualizar(Filme filme) async {
    final indice = _filmes.indexWhere((f) => f.id == filme.id);
    if (indice == -1) {
      throw ArgumentError('Filme ${filme.id} não encontrado');
    }
    _filmes[indice] = filme;
  }

  @override
  Future<void> remover(String id) async {
    _filmes.removeWhere((f) => f.id == id);
  }
}
