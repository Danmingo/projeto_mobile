import 'package:flutter/material.dart';

import 'pages/login_page.dart';
import 'pages/main_page.dart';
import 'pages/register_page.dart';
import 'services/filme_scope.dart';
import 'services/filme_service.dart';

void main() {
  runApp(const MoviePickApp());
}

class MoviePickApp extends StatefulWidget {
  const MoviePickApp({super.key, this.filmeService});

  /// Permite que os testes comecem com outra lista; no app, usa os exemplos.
  final FilmeService? filmeService;

  @override
  State<MoviePickApp> createState() => _MoviePickAppState();
}

class _MoviePickAppState extends State<MoviePickApp> {
  late final _filmeService = widget.filmeService ?? FilmeService.comExemplos();

  @override
  void dispose() {
    if (widget.filmeService == null) _filmeService.dispose();
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
      builder: (context, child) =>
          FilmeScope(service: _filmeService, child: child!),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/home': (_) => const MainPage(),
        '/cadastro': (_) => const RegisterPage(),
      },
    );
  }
}
