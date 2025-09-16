import 'package:flutter/material.dart';
import '../models/treino.dart';

class NovoTreinoSheet extends StatefulWidget {
  const NovoTreinoSheet({super.key});

  @override
  State<NovoTreinoSheet> createState() => _NovoTreinoSheetState();
}

class _NovoTreinoSheetState extends State<NovoTreinoSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  DateTime? _inicio;
  DateTime? _fim;
  bool _favorito = false;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isInicio}) async {
    final now = DateTime.now();
    final first = DateTime(now.year - 2);
    final last = DateTime(now.year + 3, 12, 31);
    final initial = isInicio ? (_inicio ?? now) : (_fim ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      helpText: isInicio ? 'Data de início' : 'Data de término',
    );
    if (picked != null) {
      setState(() {
        if (isInicio) {
          _inicio = picked;
          if (_fim != null && _fim!.isBefore(_inicio!)) {
            _fim = _inicio;
          }
        } else {
          _fim = picked;
          if (_inicio != null && _fim!.isBefore(_inicio!)) {
            _inicio = _fim;
          }
        }
      });
    }
  }

  String _fmt(DateTime? d) {
    if (d == null) return 'Selecionar';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    return '$dd/$mm/$yy';
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    final agora = DateTime.now();
    final novo = Treino(
      id: agora.microsecondsSinceEpoch, // temporário (mock)
      nome: _nomeCtrl.text.trim(),
      criadoEm: agora,
      vigenciaInicio: _inicio,
      vigenciaFim: _fim,
      favorito: _favorito,
    );
    Navigator.of(context).pop(novo);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              Row(
                children: [
                  Icon(Icons.add, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('Novo treino', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome do treino',
                  hintText: 'Ex.: Hipertrofia ABC',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe um nome' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickDate(isInicio: true),
                      icon: const Icon(Icons.calendar_today),
                      label: Text('Início: ${_fmt(_inicio)}'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickDate(isInicio: false),
                      icon: const Icon(Icons.event),
                      label: Text('Fim: ${_fmt(_fim)}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Marcar como favorito'),
                value: _favorito,
                onChanged: (v) => setState(() => _favorito = v),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _salvar,
                icon: const Icon(Icons.check),
                label: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
