import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Mostra um aviso rápido no rodapé da tela.
///
/// Recebe o [ScaffoldMessengerState] em vez do `context` para poder ser
/// chamado depois de um `await` ou de fechar a tela atual.
void mostrarMensagem(
  ScaffoldMessengerState messenger,
  String texto, {
  bool erro = false,
}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: erro ? AppColors.perigo : AppColors.texto,
        behavior: SnackBarBehavior.floating,
      ),
    );
}
