import 'package:flutter/material.dart';

import '../models/movie.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({
    required this.movies,
    required this.onToggleWatchlist,
    super.key,
  });

  final List<Movie> movies;
  final ValueChanged<Movie> onToggleWatchlist;

  @override
  Widget build(BuildContext context) {
    final watchlist = movies.where((movie) => movie.inWatchlist).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Minha Lista')),
      body: watchlist.isEmpty
          ? const Center(child: Text('Sua lista está vazia.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: watchlist.length,
              separatorBuilder: (_, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final movie = watchlist[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.bookmark),
                    title: Text(movie.title),
                    subtitle: Text('${movie.genre} • ${movie.year}'),
                    trailing: IconButton(
                      tooltip: 'Remover da Minha Lista',
                      onPressed: () => onToggleWatchlist(movie),
                      icon: const Icon(Icons.bookmark_remove_outlined),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
