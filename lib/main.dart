import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'pages/login_page.dart';
import 'services/auth_scope.dart';
import 'services/auth_service.dart';
import 'pages/main_page.dart';
import 'pages/register_page.dart';
import 'services/filme_repository_sqlite.dart';
import 'services/filme_scope.dart';
import 'services/filme_service.dart';

void main() {
  runApp(const MoviePickApp());
}

class MoviePickApp extends StatefulWidget {
  const MoviePickApp({super.key, this.filmeService, this.authService});

  /// Permite que os testes comecem com outra lista; no app, usa os exemplos.
  final FilmeService? filmeService;
  final AuthService? authService;

  @override
  State<MoviePickApp> createState() => _MoviePickAppState();
}

class _MoviePickAppState extends State<MoviePickApp> {
  late final _authService = widget.authService ?? AuthService(memory: kIsWeb);
  late final _filmeService = widget.filmeService ?? _criarFilmeService();

  /// No celular os filmes ficam no SQLite. O sqflite não roda no navegador,
  /// então a versão web continua guardando só em memória.
  static FilmeService _criarFilmeService() => kIsWeb
      ? FilmeService.comExemplos()
      : FilmeService(FilmeRepositorySqlite(iniciais: filmesDeExemplo));

  @override
  void initState() {
    super.initState();
    // Um serviço recebido pronto (testes) já vem com a lista carregada.
    if (widget.filmeService == null) _filmeService.carregar();
  }

  @override
  void dispose() {
    if (widget.filmeService == null) _filmeService.dispose();
    if (widget.authService == null) {
      _authService.fechar();
      _authService.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoviePick',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C42C5),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F7FC),
        useMaterial3: true,
      ),
      // Deixa o FilmeService acessível em todas as telas e diálogos.
      builder: (context, child) => AuthScope(
        service: _authService,
        child: FilmeScope(service: _filmeService, child: child!),
      ),
      initialRoute: _authService.autenticado ? '/home' : '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/home': (context) => AuthScope.of(context).autenticado
            ? const MainPage()
            : const LoginPage(),
        '/cadastro': (_) => const RegisterPage(),
      },
    );
  }
}
