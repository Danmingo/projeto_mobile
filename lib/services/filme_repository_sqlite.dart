import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/filme.dart';
import 'filme_repository.dart';

/// Guarda os filmes em um banco SQLite no aparelho: continuam lá depois que
/// o app é fechado.
///
/// O banco só é aberto no primeiro acesso. Na primeira vez que ele é criado,
/// já recebe os filmes de [iniciais].
class FilmeRepositorySqlite implements FilmeRepository {
  FilmeRepositorySqlite({
    this.iniciais = const [],
    this._fabrica,
    this._caminho,
  });

  final List<Filme> iniciais;

  /// Permitem que os testes usem o SQLite do computador e outro arquivo.
  final DatabaseFactory? _fabrica;
  final String? _caminho;

  static const _tabela = 'filmes';

  Future<Database>? _banco;
  Future<Database> get _db => _banco ??= _abrir();

  Future<Database> _abrir() async {
    final fabrica = _fabrica ?? databaseFactory;
    final caminho =
        _caminho ?? join(await fabrica.getDatabasesPath(), 'moviepick.db');
    return fabrica.openDatabase(
      caminho,
      options: OpenDatabaseOptions(version: 1, onCreate: _criar),
    );
  }

  Future<void> _criar(Database db, int versao) async {
    await db.execute('''
      CREATE TABLE $_tabela (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        genero TEXT NOT NULL,
        ano INTEGER NOT NULL,
        duracao INTEGER NOT NULL,
        classificacao TEXT NOT NULL,
        nota REAL NOT NULL,
        sinopse TEXT NOT NULL DEFAULT '',
        assistido INTEGER NOT NULL DEFAULT 0,
        na_minha_lista INTEGER NOT NULL DEFAULT 0,
        poster BLOB
      )
    ''');
    final lote = db.batch();
    for (final filme in iniciais) {
      lote.insert(_tabela, _paraLinha(filme));
    }
    await lote.commit(noResult: true);
  }

  /// Fecha o banco; o próximo acesso abre de novo.
  Future<void> fechar() async {
    final banco = _banco;
    _banco = null;
    if (banco != null) await (await banco).close();
  }

  @override
  Future<List<Filme>> listar() async {
    final linhas = await (await _db).query(_tabela, orderBy: 'id');
    return linhas.map(_deLinha).toList();
  }

  @override
  Future<Filme> inserir(Filme filme) async {
    final id = await (await _db).insert(_tabela, _paraLinha(filme));
    return filme.copyWith(id: '$id');
  }

  @override
  Future<void> atualizar(Filme filme) async {
    final alterados = await (await _db).update(
      _tabela,
      _paraLinha(filme),
      where: 'id = ?',
      whereArgs: [filme.id],
    );
    if (alterados == 0) {
      throw ArgumentError('Filme ${filme.id} não encontrado');
    }
  }

  @override
  Future<void> remover(String id) async {
    await (await _db).delete(_tabela, where: 'id = ?', whereArgs: [id]);
  }
}

/// O SQLite não tem tipo booleano: `true` vira 1 e `false` vira 0.
/// O id fica de fora porque é o banco que gera.
Map<String, Object?> _paraLinha(Filme filme) => {
  'titulo': filme.titulo,
  'genero': filme.genero,
  'ano': filme.ano,
  'duracao': filme.duracao,
  'classificacao': filme.classificacao,
  'nota': filme.nota,
  'sinopse': filme.sinopse,
  'assistido': filme.assistido ? 1 : 0,
  'na_minha_lista': filme.naMinhaLista ? 1 : 0,
  'poster': filme.poster,
};

Filme _deLinha(Map<String, Object?> linha) => Filme(
  id: '${linha['id']}',
  titulo: linha['titulo']! as String,
  genero: linha['genero']! as String,
  ano: linha['ano']! as int,
  duracao: linha['duracao']! as int,
  classificacao: linha['classificacao']! as String,
  // Uma nota inteira, como 8, pode voltar do banco como int.
  nota: (linha['nota']! as num).toDouble(),
  sinopse: linha['sinopse']! as String,
  assistido: linha['assistido'] == 1,
  naMinhaLista: linha['na_minha_lista'] == 1,
  poster: linha['poster'] as Uint8List?,
);
