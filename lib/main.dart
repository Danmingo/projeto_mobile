import 'package:flutter/material.dart';

import 'pages/login_page.dart';
import 'pages/main_page.dart';
import 'pages/register_page.dart';

void main() {
  runApp(const MoviePickApp());
}

class MoviePickApp extends StatelessWidget {
  const MoviePickApp({super.key});

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
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/home': (_) => const MainPage(),
        '/cadastro': (_) => const RegisterPage(),
      },
    );
  }
}
