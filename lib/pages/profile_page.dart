import 'package:flutter/material.dart';

import '../models/estatisticas_biblioteca.dart';
import '../services/auth_scope.dart';
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
          const SizedBox(height: 28),
          OutlinedButton.icon(
            onPressed: () => _sair(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.perigo,
              side: const BorderSide(color: AppColors.perigo),
              minimumSize: const Size.fromHeight(48),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sair da conta'),
          ),
        ],
      ),
    );
  }

  /// Confirma e volta ao login, apagando as telas abertas: depois de sair,
  /// o botão voltar do celular não reabre a área do usuário.
  Future<void> _sair(BuildContext context) async {
    final navigator = Navigator.of(context);
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text('Você vai voltar para a tela de login.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (confirmou ?? false) {
      AuthScope.ler(context).sair();
      navigator.pushNamedAndRemoveUntil('/login', (_) => false);
    }
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
