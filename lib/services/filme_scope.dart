import 'package:flutter/widgets.dart';

import 'filme_service.dart';

/// Disponibiliza o [FilmeService] para todas as telas abaixo dele na árvore.
///
/// Telas que usam [of] durante o `build` são redesenhadas sempre que a lista
/// de filmes muda.
class FilmeScope extends InheritedNotifier<FilmeService> {
  const FilmeScope({
    super.key,
    required FilmeService service,
    required super.child,
  }) : super(notifier: service);

  /// Use no `build`: a tela passa a ser redesenhada quando os filmes mudam.
  static FilmeService of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FilmeScope>();
    assert(scope != null, 'Nenhum FilmeScope acima deste widget.');
    return scope!.notifier!;
  }

  /// Use em callbacks (botões, diálogos): só lê, sem redesenhar a tela.
  static FilmeService ler(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<FilmeScope>();
    assert(scope != null, 'Nenhum FilmeScope acima deste widget.');
    return scope!.notifier!;
  }
}
