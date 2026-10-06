import 'package:flutter/material.dart';

import 'draw_page.dart';
import 'home_page.dart';
import 'meus_filmes_page.dart';
import 'profile_page.dart';
import 'watchlist_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF6C42C5);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: [
          // Os filmes vêm do FilmeService (FilmeScope), compartilhado por
          // todas as abas.
          HomePage(onViewAll: () => _goToPage(1), onDraw: () => _goToPage(2)),
          const MeusFilmesPage(),
          const DrawPage(),
          const WatchlistPage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _goToPage,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: purple,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie_outlined),
            label: 'Filmes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shuffle_rounded),
            label: 'Sortear',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border_rounded),
            label: 'Lista',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
