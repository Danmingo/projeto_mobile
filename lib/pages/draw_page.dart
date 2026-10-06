import 'dart:math';

import 'package:flutter/material.dart';

import '../models/movie.dart';

class DrawPage extends StatefulWidget {
  const DrawPage({required this.movies, super.key});

  final List<Movie> movies;

  @override
  State<DrawPage> createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  Movie? _drawnMovie;

  void _draw() {
    if (widget.movies.isEmpty) return;
    setState(() {
      _drawnMovie = widget.movies[Random().nextInt(widget.movies.length)];
    });
  }

  @override
  void didUpdateWidget(covariant DrawPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_drawnMovie != null && !widget.movies.contains(_drawnMovie)) {
      _drawnMovie = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sortear filme')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: widget.movies.isEmpty
              ? const Text(
                  'Cadastre pelo menos um filme para realizar o sorteio.',
                  textAlign: TextAlign.center,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shuffle_rounded, size: 72),
                    const SizedBox(height: 24),
                    if (_drawnMovie == null)
                      const Text(
                        'Pronto para descobrir o próximo filme?',
                        textAlign: TextAlign.center,
                      )
                    else ...[
                      Text(
                        _drawnMovie!.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('${_drawnMovie!.genre} • ${_drawnMovie!.year}'),
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
