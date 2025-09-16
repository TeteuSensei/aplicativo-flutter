import 'package:flutter/material.dart';
import '../models/treino.dart';
import '../models/sessao.dart';
import '../models/exercicio.dart';
import 'execucao_sessao_view.dart';

class TreinoDetalheView extends StatelessWidget {
  final Treino treino;
  const TreinoDetalheView({super.key, required this.treino});

  @override
  Widget build(BuildContext context) {
    final sessoes = _sessoesGenericas(treino);

    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(treino.nome),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Chip(
              label: Text(_statusText(treino.status)),
              side: BorderSide(color: cs.outlineVariant),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Período', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 6),
                  Text(treino.periodoFormatado),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Sessões', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...sessoes.map((s) => _SessaoCard(sessao: s)),
        ],
      ),
    );
  }

  static String _statusText(TreinoStatus s) {
    switch (s) {
      case TreinoStatus.ativo: return 'Ativo';
      case TreinoStatus.futuro: return 'Futuro';
      case TreinoStatus.expirado: return 'Expirado';
    }
  }

  /// Gera um "ABC" genérico só pra visualização.
  List<Sessao> _sessoesGenericas(Treino t) {
    return [
      Sessao(
        id: 1,
        nome: 'A — Peito/Tríceps',
        exercicios: const [
          Exercicio.simples('Supino reto', series: 4, reps: 10, descanso: 90),
          Exercicio.simples('Supino inclinado halter', series: 3, reps: 12),
          Exercicio.simples('Cross-over', series: 3, reps: 15),
          Exercicio.simples('Tríceps na polia', series: 3, reps: 12),
          Exercicio.simples('Mergulho no banco', series: 3, reps: 12),
        ],
      ),
      Sessao(
        id: 2,
        nome: 'B — Costas/Bíceps',
        exercicios: const [
          Exercicio.simples('Puxada frente', series: 4, reps: 10, descanso: 90),
          Exercicio.simples('Remada curvada', series: 3, reps: 12),
          Exercicio.simples('Remada baixa', series: 3, reps: 12),
          Exercicio.simples('Rosca direta', series: 3, reps: 12),
          Exercicio.simples('Rosca alternada', series: 3, reps: 12),
        ],
      ),
      Sessao(
        id: 3,
        nome: 'C — Pernas/Ombros',
        exercicios: const [
          Exercicio.simples('Agachamento livre', series: 4, reps: 8, descanso: 120),
          Exercicio.simples('Leg press', series: 3, reps: 12),
          Exercicio.simples('Cadeira extensora', series: 3, reps: 15),
          Exercicio.simples('Desenvolvimento halter', series: 3, reps: 12),
          Exercicio.simples('Elevação lateral', series: 3, reps: 15),
        ],
      ),
    ];
  }
}

class _SessaoCard extends StatelessWidget {
  final Sessao sessao;
  const _SessaoCard({required this.sessao});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sessao.nome, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...sessao.exercicios.map((e) => _ExRow(e)),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ExecucaoSessaoView(sessao: sessao)),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Iniciar sessão'),
                style: FilledButton.styleFrom(backgroundColor: cs.primary, foregroundColor: cs.onPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExRow extends StatelessWidget {
  final Exercicio e;
  const _ExRow(this.e);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(e.nome),
      subtitle: Text('${e.series}x${e.reps}  •  descanso ${e.descanso ?? 60}s'),
    );
  }
}
