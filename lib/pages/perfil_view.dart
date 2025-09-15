import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class PerfilView extends StatelessWidget {
  const PerfilView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: const Text('Seu nome'),
            subtitle: Text('Token: ${AuthService.I.token ?? '-'}'),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.tonal(
          onPressed: () {
            AuthService.I.logout();
            Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
          },
          child: const Text('Sair'),
        ),
      ],
    );
  }
}
