import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_mobile/services/auth_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  test('cadastro, e-mail duplicado, senha inválida, login e logout', () async {
    final auth = AuthService(memory: true);
    addTearDown(auth.dispose);
    final user = await auth.cadastrar('Maria', 'MARIA@EXEMPLO.COM', 'senha1234');
    expect(user.email, 'maria@exemplo.com');
    expect(auth.autenticado, false);
    await expectLater(auth.cadastrar('Outra', 'maria@exemplo.com', 'senha1234'),
        throwsA(isA<AuthException>()));
    await expectLater(auth.entrar('maria@exemplo.com', 'errada'),
        throwsA(isA<AuthException>()));
    await auth.entrar('maria@exemplo.com', 'senha1234');
    expect(auth.autenticado, true);
    auth.sair();
    expect(auth.autenticado, false);
  });

  test('cadastro permanece no SQLite depois de reabrir o banco', () async {
    final pasta = await Directory.systemTemp.createTemp('moviepick_auth_test_');
    addTearDown(() => pasta.delete(recursive: true));
    final caminho = '${pasta.path}/usuarios.sqlite';
    final fabrica = databaseFactoryFfi;
    final auth = AuthService(factory: fabrica, databasePath: caminho);
    await auth.cadastrar('Ana', 'ana@exemplo.com', 'senha12345');
    await auth.fechar();
    final novo = AuthService(factory: fabrica, databasePath: caminho);
    final user = await novo.entrar('ana@exemplo.com', 'senha12345');
    expect(user.nome, 'Ana');
    await novo.fechar();
    auth.dispose();
    novo.dispose();
  });
}
