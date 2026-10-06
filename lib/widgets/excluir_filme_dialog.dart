import 'package:flutter/material.dart';

import '../models/filme.dart';
import '../services/filme_scope.dart';
import '../theme/app_colors.dart';
import 'mensagem.dart';

/// Pergunta se o usuário quer mesmo excluir. Devolve `true` só se confirmar.
Future<bool> confirmarExclusao(BuildContext context, String titulo) async {
  final confirmou = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.delete_outline, color: AppColors.perigo, size: 32),
      title: const Text('Excluir filme?'),
      content: Text(
        'Tem certeza que deseja excluir "$titulo"? '
        'Essa ação não pode ser desfeita.',
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(backgroundColor: AppColors.perigo),
          child: const Text('Excluir'),
        ),
      ],
    ),
  );
  return confirmou ?? false;
}

/// Confirma, exclui e avisa o usuário. Devolve `true` se o filme foi excluído.
Future<bool> excluirFilme(BuildContext context, Filme filme) async {
  final service = FilmeScope.ler(context);
  final messenger = ScaffoldMessenger.of(context);

  if (!await confirmarExclusao(context, filme.titulo)) return false;

  await service.remover(filme.id);
  mostrarMensagem(messenger, 'Filme excluído com sucesso!');
  return true;
}
