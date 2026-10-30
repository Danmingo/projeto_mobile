import 'package:flutter/material.dart';

import '../models/filme.dart';
import '../services/filme_scope.dart';
import 'mensagem.dart';

/// Coloca ou tira o filme da Minha Lista e avisa o usuário.
Future<void> alternarMinhaLista(BuildContext context, Filme filme) async {
  final service = FilmeScope.ler(context);
  final messenger = ScaffoldMessenger.of(context);

  final Filme atualizado;
  try {
    atualizado = await service.alternarMinhaLista(filme.id);
  } catch (_) {
    mostrarMensagem(
      messenger,
      'Não foi possível atualizar a Minha Lista.',
      erro: true,
    );
    return;
  }
  mostrarMensagem(
    messenger,
    atualizado.naMinhaLista
        ? '"${filme.titulo}" adicionado à Minha Lista.'
        : '"${filme.titulo}" removido da Minha Lista.',
  );
}

/// Marca o filme como assistido ou não assistido e avisa o usuário.
Future<void> alternarAssistido(BuildContext context, Filme filme) async {
  final service = FilmeScope.ler(context);
  final messenger = ScaffoldMessenger.of(context);

  final Filme atualizado;
  try {
    atualizado = await service.alternarAssistido(filme.id);
  } catch (_) {
    mostrarMensagem(
      messenger,
      'Não foi possível atualizar o filme.',
      erro: true,
    );
    return;
  }
  mostrarMensagem(
    messenger,
    atualizado.assistido
        ? '"${filme.titulo}" marcado como assistido.'
        : '"${filme.titulo}" marcado como não assistido.',
  );
}
