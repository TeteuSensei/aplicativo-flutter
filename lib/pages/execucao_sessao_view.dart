import 'package:flutter/material.dart';
import '../models/sessao.dart';
import '../models/exercicio.dart';

class ExecucaoSessaoView extends StatefulWidget {
  final Sessao sessao;
  const ExecucaoSessaoView({super.key, required this.sessao});

  @override
  State<ExecucaoSessaoView> createState() => _ExecucaoSessaoViewState();
}

class _ExecucaoSessaoViewState extends State<ExecucaoSessaoView> {
  // mapa: índice do exercício -> lista de séries concluídas
  late final Map<int, List<bool>> feito;

  @override
  void initState() {
    super.initState();
    feito = {
      for (int i = 0; i < widget.sessao.exercicios.length; i++)
        i: List<bool>.filled(widget.sessao.exercicios[i].series, false),
    };
  }

  int get seriesConcluidasTotal =>
      feito.values.fold(0, (acc, l) => acc + l.where((v) => v).length);

  int get seriesTotal =>
      widget.sessao.exercicios.fold(0, (acc, e) => acc + e.series);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Sessão • ${widget.sessao.nome}'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(child: Text('$seriesConcluidasTotal/$seriesTotal')),
          )
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        itemCount: widget.sessao.exercicios.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) {
          final ex = widget.sessao.exercicios[i];
          final feitos = feito[i]!;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ex.nome, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(ex.series, (s) {
                      final checked = feitos[s];
                      return FilterChip(
                        label: Text('Série ${s + 1}'),
                        selected: checked,
                        onSelected: (_) => setState(() => feitos[s] = !feitos[s]),
                      );
                    }),
                  ),
                  const SizedBox(height: 6),
                  Text('${ex.reps} reps • descanso ${ex.descanso ?? 60}s',
                      style: Theme.of(context).textTheme.labelMedium),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FilledButton.icon(
        onPressed: seriesConcluidasTotal == seriesTotal
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sessão concluída!')),
                );
                Navigator.pop(context);
              }
            : null,
        icon: const Icon(Icons.check_circle),
        label: const Text('Concluir sessão'),
        style: FilledButton.styleFrom(backgroundColor: cs.primary, foregroundColor: cs.onPrimary),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
