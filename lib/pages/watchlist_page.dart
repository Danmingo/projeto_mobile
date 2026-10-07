import 'package:flutter/material.dart';

import '../models/criterios_sorteio.dart';
import '../services/filme_scope.dart';
import '../theme/app_colors.dart';
import '../widgets/acoes_filme.dart';
import 'detalhes_filme_page.dart';
import 'resultado_sorteio_page.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final watchlist = FilmeScope.of(context).filmes
        .where((filme) => filme.naMinhaLista)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Minha Lista')),
      floatingActionButton: watchlist.isEmpty
          ? null
          : FloatingActionButton.extended(
              // Sorteia só entre os filmes da lista que ainda não foram vistos.
              onPressed: () => ResultadoSorteioPage.sortearEAbrir(
                context,
                const CriteriosSorteio(somenteMinhaLista: true),
                semCandidatos:
                    'Todos os filmes da sua lista já foram assistidos.',
              ),
              backgroundColor: AppColors.roxo,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.casino_outlined),
              label: const Text('Sortear da lista'),
            ),
      body: watchlist.isEmpty
          ? const Center(child: Text('Sua lista está vazia.'))
          : ListView.separated(
              // Espaço no fim para o botão de sortear não cobrir o último.
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
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
