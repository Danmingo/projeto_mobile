import 'package:flutter/material.dart';

import '../models/filme.dart';
import '../services/filme_scope.dart';
import '../theme/app_colors.dart';
import '../widgets/excluir_filme_dialog.dart';
import '../widgets/poster_filme.dart';
import 'detalhes_filme_page.dart';
import 'filme_form_page.dart';

class MeusFilmesPage extends StatefulWidget {
  const MeusFilmesPage({super.key});

  @override
  State<MeusFilmesPage> createState() => _MeusFilmesPageState();
}

class _MeusFilmesPageState extends State<MeusFilmesPage> {
  final _busca = TextEditingController();

  /// Gênero escolhido nos filtros; `null` mostra todos.
  String? _genero;

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  /// Mais recentes primeiro, para o filme recém-cadastrado aparecer no topo.
  List<Filme> _filtrar(List<Filme> filmes) {
    final termo = _semAcento(_busca.text.trim().toLowerCase());
    return [
      for (final filme in filmes.reversed)
        if ((_genero == null || filme.genero == _genero) &&
            _semAcento(filme.titulo.toLowerCase()).contains(termo))
          filme,
    ];
  }

  void _abrir(Widget tela) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => tela));
  }

  @override
  Widget build(BuildContext context) {
    final todos = FilmeScope.of(context).filmes;
    final filmes = _filtrar(todos);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meus Filmes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.fundo,
        scrolledUnderElevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrir(const FilmeFormPage()),
        backgroundColor: AppColors.roxo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Novo filme'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: TextField(
              key: const ValueKey('campo-busca'),
              controller: _busca,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Buscar pelo título',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _busca.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpar busca',
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(_busca.clear),
                      ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              key: const ValueKey('filtros-genero'),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final genero in [null, ...generos])
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(genero ?? 'Todos'),
                      selected: _genero == genero,
                      onSelected: (_) => setState(() => _genero = genero),
                      showCheckmark: false,
                      selectedColor: AppColors.roxo,
                      labelStyle: TextStyle(
                        color: _genero == genero
                            ? Colors.white
                            : AppColors.texto,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filmes.isEmpty
                ? _ListaVazia(semFilmes: todos.isEmpty)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                    itemCount: filmes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _ItemFilme(
                      filme: filmes[i],
                      onAbrir: () =>
                          _abrir(DetalhesFilmePage(filme: filmes[i])),
                      onEditar: () => _abrir(FilmeFormPage(filme: filmes[i])),
                      onExcluir: () => excluirFilme(context, filmes[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

enum _Acao { editar, excluir }

class _ItemFilme extends StatelessWidget {
  const _ItemFilme({
    required this.filme,
    required this.onAbrir,
    required this.onEditar,
    required this.onExcluir,
  });

  final Filme filme;
  final VoidCallback onAbrir;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onAbrir,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
          child: Row(
            children: [
              PosterFilme(poster: filme.poster),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            filme.titulo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.texto,
                            ),
                          ),
                        ),
                        if (filme.assistido) ...[
                          const SizedBox(width: 6),
                          const Tooltip(
                            message: 'Assistido',
                            child: Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: AppColors.roxo,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${filme.genero} • ${filme.ano}',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${filme.duracaoFormatada} • '
                      '${filme.classificacaoFormatada}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  PopupMenuButton<_Acao>(
                    tooltip: 'Opções',
                    onSelected: (acao) => switch (acao) {
                      _Acao.editar => onEditar(),
                      _Acao.excluir => onExcluir(),
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: _Acao.editar, child: Text('Editar')),
                      PopupMenuItem(
                        value: _Acao.excluir,
                        child: Text(
                          'Excluir',
                          style: TextStyle(color: AppColors.perigo),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 18,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          filme.nota.toStringAsFixed(1).replaceAll('.', ','),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListaVazia extends StatelessWidget {
  const _ListaVazia({required this.semFilmes});

  /// `true` quando não há nenhum filme; `false` quando o filtro não achou nada.
  final bool semFilmes;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              semFilmes ? Icons.movie_filter_outlined : Icons.search_off,
              size: 56,
              color: AppColors.roxoMedio,
            ),
            const SizedBox(height: 12),
            Text(
              semFilmes
                  ? 'Nenhum filme cadastrado ainda'
                  : 'Nenhum filme encontrado',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.texto,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              semFilmes
                  ? 'Toque em "Novo filme" para começar.'
                  : 'Tente outro título ou gênero.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

String _semAcento(String texto) {
  const de = 'áàâãäéèêëíìîïóòôõöúùûüç';
  const para = 'aaaaaeeeeiiiiooooouuuuc';
  final buffer = StringBuffer();
  for (final letra in texto.split('')) {
    final i = de.indexOf(letra);
    buffer.write(i == -1 ? letra : para[i]);
  }
  return buffer.toString();
}
