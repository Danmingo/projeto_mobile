import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/criterios_sorteio.dart';
import '../models/filme.dart';
import '../services/filme_scope.dart';
import '../theme/app_colors.dart';
import '../utils/sorteio.dart';
import '../widgets/mensagem.dart';
import 'resultado_sorteio_page.dart';

/// Tela do sorteador: o usuário escolhe os critérios e sorteia um filme
/// entre os cadastrados que atendem a todos eles.
class DrawPage extends StatefulWidget {
  const DrawPage({super.key});

  @override
  State<DrawPage> createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  final _formKey = GlobalKey<FormState>();
  final _duracao = TextEditingController();
  final _generos = <String>{};
  double _notaMinima = 0;
  String? _classificacaoMaxima;
  bool _incluirAssistidos = false;
  var _autovalidar = AutovalidateMode.disabled;

  @override
  void dispose() {
    _duracao.dispose();
    super.dispose();
  }

  CriteriosSorteio get _criterios => CriteriosSorteio(
    generos: {..._generos},
    duracaoMaxima: int.tryParse(_duracao.text.trim()),
    notaMinima: _notaMinima,
    classificacaoMaxima: _classificacaoMaxima,
    incluirAssistidos: _incluirAssistidos,
  );

  void _limparFiltros() {
    // O reset vem antes: ele devolve os campos ao valor inicial e avisa o
    // onChanged, o que desfaria a limpeza se viesse depois.
    _formKey.currentState?.reset();
    setState(() {
      _generos.clear();
      _duracao.clear();
      _notaMinima = 0;
      _classificacaoMaxima = null;
      _incluirAssistidos = false;
      _autovalidar = AutovalidateMode.disabled;
    });
  }

  void _sortear() {
    final messenger = ScaffoldMessenger.of(context);
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidar = AutovalidateMode.onUserInteraction);
      mostrarMensagem(messenger, 'Corrija os campos destacados.', erro: true);
      return;
    }

    ResultadoSorteioPage.sortearEAbrir(context, _criterios);
  }

  @override
  Widget build(BuildContext context) {
    final service = FilmeScope.of(context);
    final candidatos = _criterios.filtrar(service.filmes).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sortear filme',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.fundo,
        scrolledUnderElevation: 0,
        actions: [
          if (service.filmes.isNotEmpty)
            TextButton(
              onPressed: _limparFiltros,
              child: const Text('Limpar filtros'),
            ),
        ],
      ),
      body: service.filmes.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Cadastre pelo menos um filme para realizar o sorteio.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Form(
              key: _formKey,
              autovalidateMode: _autovalidar,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                children: [
                  const _Titulo(
                    'Gêneros',
                    dica: 'Nenhum selecionado = todos os gêneros',
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final genero in generos)
                        FilterChip(
                          label: Text(genero),
                          selected: _generos.contains(genero),
                          onSelected: (marcado) => setState(() {
                            marcado
                                ? _generos.add(genero)
                                : _generos.remove(genero);
                          }),
                          selectedColor: AppColors.roxoClaro,
                          checkmarkColor: AppColors.roxo,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const _Titulo('Duração máxima'),
                  TextFormField(
                    key: const ValueKey('campo-duracao-maxima'),
                    controller: _duracao,
                    validator: validarDuracaoMaxima,
                    onChanged: (_) => setState(() {}),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _decoracao(
                      dica: 'Ex.: 120 (vazio = sem limite)',
                      sufixo: 'min',
                    ),
                  ),
                  const SizedBox(height: 20),
                  _Titulo(
                    'Nota mínima',
                    dica: _notaMinima == 0
                        ? 'Qualquer nota'
                        : '${_formatarNota(_notaMinima)} ou mais',
                  ),
                  Slider(
                    key: const ValueKey('campo-nota-minima'),
                    value: _notaMinima,
                    max: 10,
                    divisions: 20,
                    label: _formatarNota(_notaMinima),
                    onChanged: (valor) => setState(() => _notaMinima = valor),
                  ),
                  const SizedBox(height: 12),
                  const _Titulo('Classificação indicativa'),
                  DropdownButtonFormField<String?>(
                    key: const ValueKey('campo-classificacao-maxima'),
                    initialValue: _classificacaoMaxima,
                    onChanged: (valor) =>
                        setState(() => _classificacaoMaxima = valor),
                    decoration: _decoracao(),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Qualquer classificação'),
                      ),
                      for (final classificacao in classificacoes)
                        DropdownMenuItem(
                          value: classificacao,
                          child: Text(
                            classificacao == 'Livre'
                                ? 'Somente Livre'
                                : 'Até $classificacao anos',
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    key: const ValueKey('campo-incluir-assistidos'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Incluir filmes já assistidos'),
                    value: _incluirAssistidos,
                    onChanged: (valor) =>
                        setState(() => _incluirAssistidos = valor),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: service.filmes.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                // O contador fica fixo junto do botão para o usuário ver o
                // efeito dos filtros sem precisar rolar a tela.
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ContadorCandidatos(candidatos),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _sortear,
                        icon: const Icon(Icons.casino_outlined),
                        label: const Text('Sortear filme'),
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

  InputDecoration _decoracao({String? dica, String? sufixo}) {
    return InputDecoration(
      hintText: dica,
      suffixText: sufixo,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}

String _formatarNota(double nota) =>
    nota.toStringAsFixed(1).replaceAll('.', ',');

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto, {this.dica});

  final String texto;
  final String? dica;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            texto,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.texto,
            ),
          ),
          if (dica != null) ...[
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                dica!,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Mostra, enquanto o usuário mexe nos filtros, quantos filmes sobram.
class _ContadorCandidatos extends StatelessWidget {
  const _ContadorCandidatos(this.quantidade);

  final int quantidade;

  @override
  Widget build(BuildContext context) {
    final nenhum = quantidade == 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: nenhum ? AppColors.perigo.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            nenhum
                ? Icons.filter_alt_off_outlined
                : Icons.movie_filter_outlined,
            color: nenhum ? AppColors.perigo : AppColors.roxo,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              switch (quantidade) {
                0 => 'Nenhum filme atende aos critérios',
                1 => '1 filme atende aos critérios',
                _ => '$quantidade filmes atendem aos critérios',
              },
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: nenhum ? AppColors.perigo : AppColors.texto,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
