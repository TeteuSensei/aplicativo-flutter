import 'package:flutter/material.dart';

class ConsultoriaView extends StatelessWidget {
  const ConsultoriaView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          child: ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text('Consultoria personalizada'),
            subtitle: const Text('Planos, vídeos e acompanhamento.'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}
