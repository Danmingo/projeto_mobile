import 'package:flutter/material.dart';

import '../models/filme.dart';
import '../services/filme_scope.dart';
import '../theme/app_colors.dart';
import '../widgets/excluir_filme_dialog.dart';
import '../widgets/poster_filme.dart';
import 'filme_form_page.dart';

class DetalhesFilmePage extends StatefulWidget {
  const DetalhesFilmePage({super.key, required this.filme});

  final Filme filme;

  @override
  State<DetalhesFilmePage> createState() => _DetalhesFilmePageState();
}

class _DetalhesFilmePageState extends State<DetalhesFilmePage> {
  /// Última versão vista do filme. Depois da exclusão o filme some do
  /// serviço, mas a tela ainda aparece durante a animação de saída.
  late Filme _ultimoVisto = widget.filme;

  Future<void> _editar(Filme filme) async {
    await Navigator.of(context).push(
      MaterialPageRoute<bool>(builder: (_) => FilmeFormPage(filme: filme)),
    );
  }

  Future<void> _excluir(Filme filme) async {
    final excluiu = await excluirFilme(context, filme);
    if (excluiu && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final atual = FilmeScope.of(context).buscarPorId(widget.filme.id);
    if (atual != null) _ultimoVisto = atual;
    final filme = _ultimoVisto;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes'),
        backgroundColor: AppColors.roxo,
        foregroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            decoration: const BoxDecoration(
              color: AppColors.roxo,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(
              children: [
                PosterFilme(
                  poster: filme.poster,
                  largura: 170,
                  altura: 245,
                  raio: 18,
                ),
                const SizedBox(height: 20),
                Text(
                  filme.titulo,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${filme.ano} • ${filme.genero} • ${filme.duracaoFormatada}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 14),
                _Nota(filme.nota),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Etiqueta(
                      icone: Icons.shield_outlined,
                      texto: filme.classificacaoFormatada,
                    ),
                    _Etiqueta(
                      icone: filme.assistido
                          ? Icons.check_circle_outline_rounded
                          : Icons.schedule_rounded,
                      texto: filme.assistido ? 'Assistido' : 'Não assistido',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Sinopse',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.texto,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  filme.sinopse.isEmpty
                      ? 'Nenhuma sinopse cadastrada.'
                      : filme.sinopse,
                  style: TextStyle(color: Colors.grey.shade700, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: atual == null ? null : () => _editar(filme),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: atual == null ? null : () => _excluir(filme),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Excluir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.perigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Nota extends StatelessWidget {
  const _Nota(this.nota);

  final double nota;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.roxoMedio,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
          const SizedBox(width: 4),
          Text(
            nota.toStringAsFixed(1).replaceAll('.', ','),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({required this.icone, required this.texto});

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.roxoClaro,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 18, color: AppColors.roxo),
          const SizedBox(width: 6),
          Text(
            texto,
            style: const TextStyle(
              color: AppColors.texto,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
