import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _WelcomeCard(),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _StatTile(icon: Icons.schedule, label: 'Sessões', value: '0')),
            SizedBox(width: 12),
            Expanded(child: _StatTile(icon: Icons.check_circle, label: 'Concluídos', value: '0')),
          ],
        ),
      ],
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: ListTile(
        title: const Text('Bem-vindo 👋'),
        subtitle: const Text('Este é seu boilerplate base em Flutter.'),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () => ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Navegação de exemplo'))),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelMedium),
                Text(
                  value,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
