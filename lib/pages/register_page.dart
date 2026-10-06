import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Preencha este campo.';
    return null;
  }

  void _register() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Cadastro será integrado à autenticação em uma próxima etapa.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Cadastro'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Crie sua conta',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF25213B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Comece a organizar seus filmes favoritos.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  key: const Key('register-name'),
                  controller: _nameController,
                  validator: _required,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('register-email'),
                  controller: _emailController,
                  validator: _required,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('register-password'),
                  controller: _passwordController,
                  validator: _required,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Senha'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('register-confirm-password'),
                  controller: _confirmPasswordController,
                  validator: (value) {
                    final requiredError = _required(value);
                    if (requiredError != null) return requiredError;
                    if (value != _passwordController.text) {
                      return 'As senhas precisam ser iguais.';
                    }
                    return null;
                  },
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar senha',
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _register,
                    child: const Text('Cadastrar'),
                  ),
                ),
                const SizedBox(height: 18),
                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text('Já tem uma conta? Entrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
