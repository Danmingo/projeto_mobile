import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Usuário',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text('MoviePick'),
              const SizedBox(height: 20),
              Text(
                'Os dados de perfil serão implementados posteriormente.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
