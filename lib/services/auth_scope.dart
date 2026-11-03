import 'package:flutter/widgets.dart';
import 'auth_service.dart';

class AuthScope extends InheritedNotifier<AuthService> {
  const AuthScope({super.key, required AuthService service, required super.child})
      : super(notifier: service);

  static AuthService of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope não encontrado.');
    return scope!.notifier!;
  }
  static AuthService ler(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope não encontrado.');
    return scope!.notifier!;
  }
}
