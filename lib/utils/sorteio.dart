import 'dart:math';

import '../models/filme.dart';

/// Maior duração aceita no filtro (10 horas).
const duracaoMaximaPermitida = 600;

/// Escolhe um filme aleatório entre os [candidatos].
///
/// Quando há mais de uma opção, nunca repete [anteriorId]: assim
/// "Sortear novamente" sempre mostra um filme diferente.
Filme? sortearFilme(
  List<Filme> candidatos, {
  String? anteriorId,
  Random? random,
}) {
  final opcoes = candidatos.length > 1
      ? candidatos.where((f) => f.id != anteriorId).toList()
      : candidatos;
  if (opcoes.isEmpty) return null;
  return opcoes[(random ?? Random()).nextInt(opcoes.length)];
}

/// Valida o campo opcional de duração máxima (vazio = sem limite).
String? validarDuracaoMaxima(String? valor) {
  if (valor == null || valor.trim().isEmpty) return null;
  final minutos = int.tryParse(valor.trim());
  if (minutos == null || minutos <= 0) return 'Deve ser maior que zero';
  if (minutos > duracaoMaximaPermitida) {
    return 'No máximo $duracaoMaximaPermitida minutos';
  }
  return null;
}
