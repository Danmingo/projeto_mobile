import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:projeto_mobile/models/filme.dart';
import 'package:projeto_mobile/services/filme_repository_sqlite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const _rascunho = Filme(
  id: '',
  titulo: 'Duna',
  genero: 'Ficção Científica',
  ano: 2021,
  duracao: 155,
  classificacao: '14',
  nota: 8.0,
);

/// Roda o SQLite do computador; no celular, quem faz isso é o sqflite.
FilmeRepositorySqlite _abrir(
  String caminho, {
  List<Filme> iniciais = const [],
}) => FilmeRepositorySqlite(
  iniciais: iniciais,
  fabrica: databaseFactoryFfi,
  caminho: caminho,
);

void main() {
  late Directory pasta;
  late String caminho;
  late FilmeRepositorySqlite repositorio;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    pasta = await Directory.systemTemp.createTemp('moviepick_teste_');
    caminho = join(pasta.path, 'moviepick.db');
    repositorio = _abrir(caminho);
  });

  tearDown(() async {
    await repositorio.fechar();
    await pasta.delete(recursive: true);
  });

  test('banco novo começa com os filmes iniciais', () async {
    repositorio = _abrir(caminho, iniciais: [_rascunho]);

    final filmes = await repositorio.listar();

    expect(filmes.map((f) => f.titulo), ['Duna']);
    expect(filmes.single.id, isNotEmpty);
  });

  test('inserir gera ids diferentes e listar mantém a ordem', () async {
    final primeiro = await repositorio.inserir(_rascunho);
    final segundo = await repositorio.inserir(
      _rascunho.copyWith(titulo: 'Duna: Parte Dois'),
    );

    expect(primeiro.id, isNot(segundo.id));
    expect((await repositorio.listar()).map((f) => f.titulo), [
      'Duna',
      'Duna: Parte Dois',
    ]);
  });

  test('atualizar grava todos os campos, inclusive pôster', () async {
    final salvo = await repositorio.inserir(_rascunho);
    final poster = Uint8List.fromList([1, 2, 3]);

    await repositorio.atualizar(
      salvo.copyWith(
        nota: 9,
        sinopse: 'Paul Atreides em Arrakis.',
        assistido: true,
        naMinhaLista: true,
        poster: poster,
      ),
    );

    final lido = (await repositorio.listar()).single;
    expect(lido.nota, 9.0);
    expect(lido.sinopse, 'Paul Atreides em Arrakis.');
    expect(lido.assistido, isTrue);
    expect(lido.naMinhaLista, isTrue);
    expect(lido.poster, poster);
  });

  test('atualizar um filme inexistente falha', () {
    expect(
      () => repositorio.atualizar(_rascunho.copyWith(id: '999')),
      throwsArgumentError,
    );
  });

  test('remover apaga o filme do banco', () async {
    final salvo = await repositorio.inserir(_rascunho);

    await repositorio.remover(salvo.id);

    expect(await repositorio.listar(), isEmpty);
  });

  test('os filmes continuam salvos depois de fechar o banco', () async {
    await repositorio.inserir(_rascunho);
    await repositorio.fechar();

    repositorio = _abrir(caminho, iniciais: [_rascunho]);

    // Os iniciais só entram na criação: o banco já existia.
    expect((await repositorio.listar()).map((f) => f.titulo), ['Duna']);
  });
}
