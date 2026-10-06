import 'dart:math';

import 'package:flutter/material.dart';

import '../services/filme_scope.dart';

class DrawPage extends StatefulWidget {
  const DrawPage({super.key});

  @override
  State<DrawPage> createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  /// Guarda só o id: se o filme for editado ou excluído, a tela acompanha.
  String? _sorteadoId;

  void _draw() {
    final filmes = FilmeScope.ler(context).filmes;
    if (filmes.isEmpty) return;
    setState(() {
      _sorteadoId = filmes[Random().nextInt(filmes.length)].id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = FilmeScope.of(context);
    final id = _sorteadoId;
    final sorteado = id == null ? null : service.buscarPorId(id);

    return Scaffold(
      appBar: AppBar(title: const Text('Sortear filme')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: service.filmes.isEmpty
              ? const Text(
                  'Cadastre pelo menos um filme para realizar o sorteio.',
                  textAlign: TextAlign.center,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shuffle_rounded, size: 72),
                    const SizedBox(height: 24),
                    if (sorteado == null)
                      const Text(
                        'Pronto para descobrir o próximo filme?',
                        textAlign: TextAlign.center,
                      )
                    else ...[
                      Text(
                        sorteado.titulo,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('${sorteado.genero} • ${sorteado.ano}'),
                      const SizedBox(height: 24),
                    ],
                    FilledButton.icon(
                      onPressed: _draw,
                      icon: const Icon(Icons.casino_outlined),
                      label: const Text('Sortear filme'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
