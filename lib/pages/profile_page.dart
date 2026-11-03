import 'package:flutter/material.dart';

import '../models/estatisticas_biblioteca.dart';
import '../services/filme_scope.dart';
import '../theme/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final estatisticas = EstatisticasBiblioteca.de(
      FilmeScope.of(context).filmes,
    );
    final nota = estatisticas.notaMedia;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 42,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.person_outline_rounded,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Usuário',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Sua biblioteca',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Numero(
                  valor: '${estatisticas.total}',
                  rotulo: 'Cadastrados',
                  icone: Icons.movie_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Numero(
                  valor: '${estatisticas.assistidos}',
                  rotulo: 'Assistidos',
                  icone: Icons.check_circle_outline_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Numero(
                  valor: '${estatisticas.naMinhaLista}',
                  rotulo: 'Na lista',
                  icone: Icons.bookmark_border_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Você já assistiu ${(estatisticas.progresso * 100).round()}% '
            'dos seus filmes',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: estatisticas.progresso,
              minHeight: 10,
              color: AppColors.roxo,
              backgroundColor: AppColors.roxoClaro,
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.schedule_rounded),
                  title: const Text('Tempo assistido'),
                  trailing: Text(estatisticas.tempoAssistidoFormatado),
                ),
                ListTile(
                  leading: const Icon(Icons.favorite_border_rounded),
                  title: const Text('Gênero favorito'),
                  trailing: Text(estatisticas.generoFavorito ?? '—'),
                ),
                ListTile(
                  leading: const Icon(Icons.star_outline_rounded),
                  title: const Text('Nota média'),
                  trailing: Text(
                    nota == null
                        ? '—'
                        : nota.toStringAsFixed(1).replaceAll('.', ','),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Numero extends StatelessWidget {
  const _Numero({
    required this.valor,
    required this.rotulo,
    required this.icone,
  });

  final String valor;
  final String rotulo;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icone, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              valor,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(rotulo, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
