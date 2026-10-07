import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Nota do filme em destaque, com estrela, sobre fundo roxo.
class NotaFilme extends StatelessWidget {
  const NotaFilme(this.nota, {super.key});

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

/// Plaquinha com ícone e texto (classificação, status etc.).
class EtiquetaFilme extends StatelessWidget {
  const EtiquetaFilme({super.key, required this.icone, required this.texto});

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
