import 'package:flutter/material.dart';

class NutricaoView extends StatelessWidget {
  const NutricaoView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Nutrição')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          // Ações rápidas
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _QuickAction(icon: Icons.restaurant, label: 'Registrar refeição'),
              _QuickAction(icon: Icons.assignment, label: 'Plano alimentar'),
              _QuickAction(icon: Icons.menu_book, label: 'Receitas'),
              _QuickAction(icon: Icons.local_drink, label: 'Hidratação'),
            ],
          ),
          const SizedBox(height: 16),

          // Hoje
          Text('Hoje', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const _MealTile(hora: '08:00', titulo: 'Café da manhã', detalhe: 'Ovos + aveia + fruta'),
          const _MealTile(hora: '12:30', titulo: 'Almoço', detalhe: 'Arroz, feijão, frango, salada'),
          const _MealTile(hora: '16:00', titulo: 'Lanche', detalhe: 'Iogurte + castanhas'),
          const _MealTile(hora: '20:00', titulo: 'Jantar', detalhe: 'Peixe + legumes'),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  const _QuickAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label (TODO)')),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        width: 160,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: cs.surfaceVariant.withOpacity(.35),
          border: Border.all(color: cs.outlineVariant.withOpacity(.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: cs.primary),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealTile extends StatelessWidget {
  final String hora;
  final String titulo;
  final String detalhe;
  const _MealTile({required this.hora, required this.titulo, required this.detalhe});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: cs.primaryContainer.withOpacity(.35),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.restaurant, color: cs.primary),
        ),
        title: Text('$titulo • $hora'),
        subtitle: Text(detalhe),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Editar $titulo (TODO)')),
          );
        },
      ),
    );
  }
}
