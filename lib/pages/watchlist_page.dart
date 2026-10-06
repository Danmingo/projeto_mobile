import 'package:flutter/material.dart';

import '../services/filme_scope.dart';
import '../widgets/acoes_filme.dart';
import 'detalhes_filme_page.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final watchlist = FilmeScope.of(context).filmes
        .where((filme) => filme.naMinhaLista)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Minha Lista')),
      body: watchlist.isEmpty
          ? const Center(child: Text('Sua lista está vazia.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: watchlist.length,
              separatorBuilder: (_, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final filme = watchlist[index];
                return Card(
                  child: ListTile(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => DetalhesFilmePage(filme: filme),
                      ),
                    ),
                    leading: const Icon(Icons.bookmark),
                    title: Text(filme.titulo),
                    subtitle: Text('${filme.genero} • ${filme.ano}'),
                    trailing: IconButton(
                      tooltip: 'Remover da Minha Lista',
                      onPressed: () => alternarMinhaLista(context, filme),
                      icon: const Icon(Icons.bookmark_remove_outlined),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
