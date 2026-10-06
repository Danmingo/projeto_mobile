import 'package:flutter/material.dart';

import '../models/movie.dart';

class MoviesPage extends StatelessWidget {
  const MoviesPage({
    required this.movies,
    required this.onAddMovie,
    required this.onRemoveMovie,
    required this.onToggleWatchlist,
    required this.onToggleWatched,
    super.key,
  });

  final List<Movie> movies;
  final ValueChanged<Movie> onAddMovie;
  final ValueChanged<Movie> onRemoveMovie;
  final ValueChanged<Movie> onToggleWatchlist;
  final ValueChanged<Movie> onToggleWatched;

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Preencha este campo.';
    return null;
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final genreController = TextEditingController();
    final yearController = TextEditingController();

    Movie? movie;
    try {
      movie = await showDialog<Movie>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Cadastrar filme'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    key: const Key('movie-title'),
                    controller: titleController,
                    validator: _required,
                    decoration: const InputDecoration(labelText: 'Título'),
                  ),
                  TextFormField(
                    key: const Key('movie-genre'),
                    controller: genreController,
                    validator: _required,
                    decoration: const InputDecoration(labelText: 'Gênero'),
                  ),
                  TextFormField(
                    key: const Key('movie-year'),
                    controller: yearController,
                    validator: (value) {
                      if (value == null || int.tryParse(value) == null) {
                        return 'Informe um ano numérico válido.';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Ano'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;
                Navigator.pop(
                  dialogContext,
                  Movie(
                    title: titleController.text.trim(),
                    genre: genreController.text.trim(),
                    year: int.parse(yearController.text.trim()),
                  ),
                );
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      );
      // O Future do showDialog termina antes da animação de saída acabar.
      await Future<void>.delayed(const Duration(milliseconds: 300));
    } finally {
      titleController.dispose();
      genreController.dispose();
      yearController.dispose();
    }

    if (movie == null || !context.mounted) return;
    onAddMovie(movie);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filme adicionado com sucesso!')),
    );
  }

  Future<void> _confirmRemove(BuildContext context, Movie movie) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remover filme?'),
        content: Text('Deseja remover ${movie.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    onRemoveMovie(movie);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filme removido com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Filmes')),
      body: movies.isEmpty
          ? const Center(child: Text('Nenhum filme cadastrado.'))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: movies.length,
              separatorBuilder: (_, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final movie = movies[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        movie.watched
                            ? Icons.check_rounded
                            : Icons.movie_outlined,
                      ),
                    ),
                    title: Text(
                      movie.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${movie.genre} • ${movie.year}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (action) {
                        switch (action) {
                          case 'watchlist':
                            onToggleWatchlist(movie);
                          case 'watched':
                            onToggleWatched(movie);
                          case 'remove':
                            _confirmRemove(context, movie);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'watchlist',
                          child: Text(
                            movie.inWatchlist
                                ? 'Remover da Minha Lista'
                                : 'Adicionar à Minha Lista',
                          ),
                        ),
                        PopupMenuItem(
                          value: 'watched',
                          child: Text(
                            movie.watched
                                ? 'Marcar como não assistido'
                                : 'Marcar como assistido',
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'remove',
                          child: Text('Excluir'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add-movie'),
        tooltip: 'Adicionar filme',
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
