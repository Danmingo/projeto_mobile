import 'package:flutter/foundation.dart';

import '../models/filme.dart';
import 'filme_repository.dart';

/// Lista de filmes que as telas leem e alteram.
///
/// Cada alteração é gravada primeiro no [FilmeRepository]; só depois de
/// gravada a cópia em memória muda e as telas são avisadas. Assim, se a
/// gravação falhar, a tela continua mostrando o que está de fato salvo.
class FilmeService extends ChangeNotifier {
  FilmeService(this._repositorio) : _filmes = [];

  /// Só em memória e já com [iniciais] na lista (testes e versão web).
  FilmeService.emMemoria([List<Filme> iniciais = const []])
    : _repositorio = FilmeRepositoryMemoria(iniciais),
      _filmes = [...iniciais];

  factory FilmeService.comExemplos() => FilmeService.emMemoria(filmesDeExemplo);

  final FilmeRepository _repositorio;
  final List<Filme> _filmes;

  bool _carregando = false;
  Object? _erroAoCarregar;

  bool get carregando => _carregando;
  bool get falhouAoCarregar => _erroAoCarregar != null;

  /// Lê os filmes guardados no repositório (ao abrir o app).
  ///
  /// Enquanto lê, [carregando] fica `true`; se der erro, [falhouAoCarregar]
  /// fica `true` e as telas podem oferecer para tentar de novo.
  Future<void> carregar() async {
    if (_carregando) return;
    _carregando = true;
    _erroAoCarregar = null;
    notifyListeners();
    try {
      final lidos = await _repositorio.listar();
      _filmes
        ..clear()
        ..addAll(lidos);
    } catch (erro) {
      debugPrint('Erro ao carregar os filmes: $erro');
      _erroAoCarregar = erro;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

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
    final novo = await _repositorio.inserir(filme);
    _filmes.add(novo);
    notifyListeners();
    return novo;
  }

  Future<void> atualizar(Filme filme) async {
    await _repositorio.atualizar(filme);
    final indice = _filmes.indexWhere((f) => f.id == filme.id);
    if (indice != -1) _filmes[indice] = filme;
    notifyListeners();
  }

  Future<void> remover(String id) async {
    await _repositorio.remover(id);
    _filmes.removeWhere((f) => f.id == id);
    notifyListeners();
  }

  /// Coloca ou tira o filme da Minha Lista e devolve o filme atualizado.
  Future<Filme> alternarMinhaLista(String id) =>
      _alterar(id, (f) => f.copyWith(naMinhaLista: !f.naMinhaLista));

  /// Marca o filme como assistido ou não assistido e devolve o atualizado.
  Future<Filme> alternarAssistido(String id) =>
      _alterar(id, (f) => f.copyWith(assistido: !f.assistido));

  Future<Filme> _alterar(String id, Filme Function(Filme) mudanca) async {
    final atual = buscarPorId(id);
    if (atual == null) throw ArgumentError('Filme $id não encontrado');
    final novo = mudanca(atual);
    await atualizar(novo);
    return novo;
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
