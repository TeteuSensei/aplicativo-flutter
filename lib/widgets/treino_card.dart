import 'package:flutter/material.dart';
import '../models/treino.dart';

class TreinoCard extends StatelessWidget {
  final Treino treino;
  final VoidCallback? onTap;
  final VoidCallback? onEditar;
  final VoidCallback? onDuplicar;
  final VoidCallback? onExcluir;
  final VoidCallback? onToggleFavorito;

  const TreinoCard({
    super.key,
    required this.treino,
    this.onTap,
    this.onEditar,
    this.onDuplicar,
    this.onExcluir,
    this.onToggleFavorito,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusChip = _statusChip(context, treino.status);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.fitness_center, size: 28, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            treino.nome,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          tooltip: treino.favorito ? 'Remover dos favoritos' : 'Marcar como favorito',
                          onPressed: onToggleFavorito,
                          icon: Icon(
                            treino.favorito ? Icons.star : Icons.star_border,
                            color: treino.favorito ? Colors.amber : theme.iconTheme.color,
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'editar':
                                onEditar?.call();
                                break;
                              case 'duplicar':
                                onDuplicar?.call();
                                break;
                              case 'excluir':
                                onExcluir?.call();
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'editar', child: Text('Editar')),
                            const PopupMenuItem(value: 'duplicar', child: Text('Duplicar')),
                            const PopupMenuItem(
                              value: 'excluir',
                              child: Text('Excluir'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      treino.periodoFormatado,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        statusChip,
                        _chip(context, Icons.event, 'Criado: ${Treino.fmtDate(treino.criadoEm)}'),
                        if (treino.favorito) _chip(context, Icons.star, 'Favorito'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(BuildContext context, TreinoStatus status) {
    final theme = Theme.of(context);
    final (label, icon, color) = switch (status) {
      TreinoStatus.ativo => ('Ativo', Icons.check_circle, theme.colorScheme.primary),
      TreinoStatus.futuro => ('Futuro', Icons.schedule, theme.colorScheme.tertiary),
      TreinoStatus.expirado => ('Expirado', Icons.history, theme.colorScheme.error),
    };
    return Chip(
      label: Text(label),
      avatar: Icon(icon, size: 18, color: color),
      side: BorderSide(color: color.withOpacity(.4)),
      backgroundColor: color.withOpacity(.08),
      labelStyle: theme.textTheme.labelMedium,
    );
  }

  Widget _chip(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Chip(
      label: Text(text),
      avatar: Icon(icon, size: 18),
      labelStyle: theme.textTheme.labelMedium,
    );
  }
}
