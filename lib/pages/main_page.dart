import 'package:flutter/material.dart';

import '../models/movie.dart';
import 'draw_page.dart';
import 'home_page.dart';
import 'movies_page.dart';
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
  final List<Movie> _movies = [];

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

  void _addMovie(Movie movie) => setState(() => _movies.add(movie));

  void _removeMovie(Movie movie) => setState(() => _movies.remove(movie));

  void _toggleWatchlist(Movie movie) {
    setState(() => movie.inWatchlist = !movie.inWatchlist);
  }

  void _toggleWatched(Movie movie) {
    setState(() => movie.watched = !movie.watched);
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF6C42C5);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: [
          HomePage(
            movies: _movies,
            onViewAll: () => _goToPage(1),
            onDraw: () => _goToPage(2),
          ),
          MoviesPage(
            movies: _movies,
            onAddMovie: _addMovie,
            onRemoveMovie: _removeMovie,
            onToggleWatchlist: _toggleWatchlist,
            onToggleWatched: _toggleWatched,
          ),
          DrawPage(movies: _movies),
          WatchlistPage(movies: _movies, onToggleWatchlist: _toggleWatchlist),
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
