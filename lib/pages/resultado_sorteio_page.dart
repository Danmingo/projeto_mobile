import 'package:flutter/material.dart';

import '../models/criterios_sorteio.dart';
import '../models/filme.dart';
import '../services/filme_scope.dart';
import '../theme/app_colors.dart';
import '../utils/sorteio.dart';
import '../widgets/acoes_filme.dart';
import '../widgets/info_filme.dart';
import '../widgets/mensagem.dart';
import '../widgets/poster_filme.dart';

/// Mostra o filme sorteado e permite sortear de novo com os mesmos critérios.
class ResultadoSorteioPage extends StatefulWidget {
  const ResultadoSorteioPage({
    super.key,
    required this.criterios,
    required this.sorteado,
  });

  final CriteriosSorteio criterios;
  final Filme sorteado;

  /// Sorteia um filme com os [criterios] e abre a tela de resultado.
  ///
  /// Se nenhum filme atender aos critérios, mostra [semCandidatos] e fica
  /// na tela atual.
  static Future<void> sortearEAbrir(
    BuildContext context,
    CriteriosSorteio criterios, {
    String semCandidatos =
        'Nenhum filme atende aos critérios. Tente afrouxar os filtros.',
  }) async {
    final candidatos = criterios.filtrar(FilmeScope.ler(context).filmes);
    final sorteado = sortearFilme(candidatos);
    if (sorteado == null) {
      mostrarMensagem(ScaffoldMessenger.of(context), semCandidatos, erro: true);
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ResultadoSorteioPage(criterios: criterios, sorteado: sorteado),
      ),
    );
  }

  @override
  State<ResultadoSorteioPage> createState() => _ResultadoSorteioPageState();
}

class _ResultadoSorteioPageState extends State<ResultadoSorteioPage> {
  /// Filme mostrado agora. É atualizado a cada "Sortear novamente" e quando
  /// o usuário marca o filme como assistido ou o coloca na Minha Lista.
  late Filme _filme = widget.sorteado;

  void _sortearNovamente() {
    final messenger = ScaffoldMessenger.of(context);
    final candidatos = widget.criterios.filtrar(FilmeScope.ler(context).filmes);
    final novo = sortearFilme(candidatos, anteriorId: _filme.id);

    if (novo == null) {
      mostrarMensagem(
        messenger,
        'Nenhum outro filme atende aos critérios.',
        erro: true,
      );
    } else if (novo.id == _filme.id) {
      mostrarMensagem(
        messenger,
        'Este é o único filme que atende aos critérios.',
      );
    } else {
      setState(() => _filme = novo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final atual = FilmeScope.of(context).buscarPorId(_filme.id);
    if (atual != null) _filme = atual;
    final filme = _filme;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filme sorteado'),
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
            // Troca com animação a cada novo sorteio.
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Column(
                key: ValueKey(filme.id),
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
                    '${filme.ano} • ${filme.genero} • '
                    '${filme.duracaoFormatada}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 14),
                  NotaFilme(filme.nota),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EtiquetaFilme(
                  icone: Icons.shield_outlined,
                  texto: filme.classificacaoFormatada,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _BotaoStatus(
                      ativo: filme.naMinhaLista,
                      iconeAtivo: Icons.bookmark_rounded,
                      iconeInativo: Icons.bookmark_add_outlined,
                      textoAtivo: 'Na lista',
                      textoInativo: 'Minha Lista',
                      onPressed: atual == null
                          ? null
                          : () => alternarMinhaLista(context, filme),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _BotaoStatus(
                      ativo: filme.assistido,
                      iconeAtivo: Icons.check_circle_rounded,
                      iconeInativo: Icons.check_circle_outline_rounded,
                      textoAtivo: 'Assistido',
                      textoInativo: 'Já assisti',
                      onPressed: atual == null
                          ? null
                          : () => alternarAssistido(context, filme),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _sortearNovamente,
                  icon: const Icon(Icons.casino_outlined),
                  label: const Text('Sortear novamente'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.roxo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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

/// Botão que liga e desliga um status do filme (Minha Lista ou assistido).
class _BotaoStatus extends StatelessWidget {
  const _BotaoStatus({
    required this.ativo,
    required this.iconeAtivo,
    required this.iconeInativo,
    required this.textoAtivo,
    required this.textoInativo,
    required this.onPressed,
  });

  final bool ativo;
  final IconData iconeAtivo;
  final IconData iconeInativo;
  final String textoAtivo;
  final String textoInativo;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(ativo ? iconeAtivo : iconeInativo),
        label: Text(ativo ? textoAtivo : textoInativo),
        style: OutlinedButton.styleFrom(
          backgroundColor: ativo ? AppColors.roxoClaro : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
