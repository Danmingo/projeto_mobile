import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Conta autenticada. A senha e o hash nunca são expostos à interface.
class Usuario {
  const Usuario({required this.id, required this.nome, required this.email});
  final int id;
  final String nome;
  final String email;
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Autenticação local/offline. Não há sincronização com outros aparelhos.
/// Senhas são derivadas com PBKDF2-HMAC-SHA256 e salt aleatório.
class AuthService extends ChangeNotifier {
  AuthService({this._factory, this._databasePath, this._memory = false});

  final DatabaseFactory? _factory;
  final String? _databasePath;
  final bool _memory;
  final Map<String, Map<String, Object?>> _contasMemoria = {};
  Database? _database;
  Usuario? _usuario;
  bool _ocupado = false;

  Usuario? get usuario => _usuario;
  bool get autenticado => _usuario != null;
  bool get ocupado => _ocupado;

  static final _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 120000,
    bits: 256,
  );

  Future<Database> _abrir() async {
    if (_database != null) return _database!;
    final factory = _factory ?? databaseFactory;
    final path = _databasePath ??
        join(await factory.getDatabasesPath(), 'moviepick_usuarios.db');
    _database = await factory.openDatabase(path,
        options: OpenDatabaseOptions(version: 1, onCreate: (db, _) async {
      await db.execute("""CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        salt TEXT NOT NULL,
        senha_hash TEXT NOT NULL
      )""");
    }));
    return _database!;
  }

  String _normalizar(String email) => email.trim().toLowerCase();

  Future<String> _hash(String senha, List<int> salt) async {
    final key = await _pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(senha)),
      nonce: salt,
    );
    return base64Encode(await key.extractBytes());
  }

  List<int> _novoSalt() {
    final random = Random.secure();
    return List<int>.generate(16, (_) => random.nextInt(256));
  }

  Future<T> _executar<T>(Future<T> Function() operacao) async {
    if (_ocupado) throw const AuthException('Aguarde a operação anterior.');
    _ocupado = true;
    notifyListeners();
    try {
      return await operacao();
    } finally {
      _ocupado = false;
      notifyListeners();
    }
  }

  Future<Usuario> cadastrar(String nome, String email, String senha) =>
      _executar(() async {
        final nomeLimpo = nome.trim();
        final emailLimpo = _normalizar(email);
        if (nomeLimpo.length < 2) {
          throw const AuthException('Informe um nome com pelo menos 2 caracteres.');
        }
        if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(emailLimpo)) {
          throw const AuthException('Informe um e-mail válido.');
        }
        if (senha.length < 8) {
          throw const AuthException('A senha deve ter pelo menos 8 caracteres.');
        }
        final salt = _novoSalt();
        final linha = <String, Object?>{
          'nome': nomeLimpo,
          'email': emailLimpo,
          'salt': base64Encode(salt),
          'senha_hash': await _hash(senha, salt),
        };
        int id;
        if (_memory) {
          if (_contasMemoria.containsKey(emailLimpo)) {
            throw const AuthException('Este e-mail já está cadastrado.');
          }
          id = _contasMemoria.length + 1;
          _contasMemoria[emailLimpo] = {...linha, 'id': id};
        } else {
          try {
            id = await (await _abrir()).insert('usuarios', linha);
          } on DatabaseException catch (e) {
            if (e.isUniqueConstraintError()) {
              throw const AuthException('Este e-mail já está cadastrado.');
            }
            rethrow;
          }
        }
        // O cadastro cria uma conta, mas requer login explícito.
        return Usuario(id: id, nome: nomeLimpo, email: emailLimpo);
      });

  Future<Usuario> entrar(String email, String senha) => _executar(() async {
    final emailLimpo = _normalizar(email);
    if (emailLimpo.isEmpty || senha.isEmpty) {
      throw const AuthException('Preencha e-mail e senha.');
    }
    Map<String, Object?>? linha;
    if (_memory) {
      linha = _contasMemoria[emailLimpo];
    } else {
      final linhas = await (await _abrir()).query('usuarios',
          where: 'email = ?', whereArgs: [emailLimpo], limit: 1);
      if (linhas.isNotEmpty) linha = linhas.first;
    }
    if (linha == null) {
      throw const AuthException('E-mail ou senha inválidos.');
    }
    final salt = base64Decode(linha['salt'] as String);
    final tentativa = base64Decode(await _hash(senha, salt));
    final esperado = base64Decode(linha['senha_hash'] as String);
    var diferenca = tentativa.length ^ esperado.length;
    for (var i = 0; i < tentativa.length && i < esperado.length; i++) {
      diferenca |= tentativa[i] ^ esperado[i];
    }
    if (diferenca != 0) {
      throw const AuthException('E-mail ou senha inválidos.');
    }
    _usuario = Usuario(
      id: linha['id'] as int,
      nome: linha['nome'] as String,
      email: linha['email'] as String,
    );
    notifyListeners();
    return _usuario!;
  });

  void sair() {
    _usuario = null;
    notifyListeners();
  }

  Future<void> fechar() async {
    final db = _database;
    _database = null;
    if (db != null) await db.close();
  }
}
