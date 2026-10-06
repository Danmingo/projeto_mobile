import 'package:flutter/foundation.dart';

import '../models/filme.dart';

/// Guarda os filmes do usuário em memória (Parte 1 do trabalho).
///
/// Os métodos que alteram dados já retornam [Future] para que, na Parte 2,
/// esta classe possa gravar em um banco de dados sem mudar as telas.
class FilmeService extends ChangeNotifier {
  FilmeService({List<Filme> iniciais = const []}) : _filmes = [...iniciais];

  factory FilmeService.comExemplos() => FilmeService(iniciais: filmesDeExemplo);

  final List<Filme> _filmes;
  int _sequencia = 0;

  /// Filmes na ordem em que foram cadastrados.
  List<Filme> get filmes => List.unmodifiable(_filmes);

  Filme? buscarPorId(String id) {
    for (final filme in _filmes) {
      if (filme.id == id) return filme;
    }
    return null;
  }

  /// Cadastra o filme com um id novo e devolve o filme salvo.
  Future<Filme> adicionar(Filme filme) async {
    _sequencia++;
    final novo = filme.copyWith(id: 'filme-$_sequencia');
    _filmes.add(novo);
    notifyListeners();
    return novo;
  }

  Future<void> atualizar(Filme filme) async {
    final indice = _filmes.indexWhere((f) => f.id == filme.id);
    if (indice == -1) {
      throw ArgumentError('Filme ${filme.id} não encontrado');
    }
    _filmes[indice] = filme;
    notifyListeners();
  }

  Future<void> remover(String id) async {
    _filmes.removeWhere((f) => f.id == id);
    notifyListeners();
  }
}

const filmesDeExemplo = [
  Filme(
    id: 'exemplo-1',
    titulo: 'Interestelar',
    genero: 'Ficção Científica',
    ano: 2014,
    duracao: 169,
    classificacao: '10',
    nota: 8.7,
    assistido: true,
    sinopse:
        'Com a Terra à beira do colapso, um grupo de astronautas atravessa '
        'um buraco de minhoca em busca de um novo lar para a humanidade.',
  ),
  Filme(
    id: 'exemplo-2',
    titulo: 'O Batman',
    genero: 'Ação',
    ano: 2022,
    duracao: 176,
    classificacao: '14',
    nota: 7.8,
    sinopse:
        'Em seu segundo ano como vigilante, Batman investiga uma série de '
        'assassinatos que expõe a corrupção de Gotham.',
  ),
  Filme(
    id: 'exemplo-3',
    titulo: 'Coringa',
    genero: 'Drama',
    ano: 2019,
    duracao: 122,
    classificacao: '16',
    nota: 8.4,
    assistido: true,
    sinopse:
        'Ignorado pela sociedade, um comediante fracassado de Gotham entra '
        'em uma espiral de violência.',
  ),
  Filme(
    id: 'exemplo-4',
    titulo: 'Shrek',
    genero: 'Animação',
    ano: 2001,
    duracao: 90,
    classificacao: 'Livre',
    nota: 7.9,
    sinopse:
        'Um ogro que só quer sossego aceita resgatar uma princesa para '
        'recuperar seu pântano.',
  ),
  Filme(
    id: 'exemplo-5',
    titulo: 'Vingadores: Ultimato',
    genero: 'Ação',
    ano: 2019,
    duracao: 181,
    classificacao: '12',
    nota: 8.4,
    sinopse:
        'Depois do estalar de dedos de Thanos, os heróis restantes se unem '
        'para tentar desfazer a tragédia.',
  ),
];
