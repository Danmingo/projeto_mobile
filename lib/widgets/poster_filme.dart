import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Pôster do filme, ou um degradê com ícone quando não há imagem.
class PosterFilme extends StatelessWidget {
  const PosterFilme({
    super.key,
    required this.poster,
    this.largura = 56,
    this.altura = 80,
    this.raio = 12,
  });

  final Uint8List? poster;
  final double largura;
  final double altura;
  final double raio;

  @override
  Widget build(BuildContext context) {
    final imagem = poster;
    return ClipRRect(
      borderRadius: BorderRadius.circular(raio),
      child: SizedBox(
        width: largura,
        height: altura,
        child: imagem != null
            ? Image.memory(imagem, fit: BoxFit.cover)
            : DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.roxoMedio, AppColors.texto],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  Icons.movie_outlined,
                  color: Colors.white70,
                  size: largura * 0.4,
                ),
              ),
      ),
    );
  }
}
