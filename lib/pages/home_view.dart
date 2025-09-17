import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// Home minimalista:
/// - AppBar
/// - Botões de acesso rápido
/// - Calendário mensal com marcações e lista de sessões do dia selecionado
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // === Sessões de exemplo (trocar pela sua API depois) ===
  final List<_Sessao> _todasSessoes = [
    _Sessao(
      titulo: 'Peito e Tríceps',
      inicio: DateTime.now().add(const Duration(hours: 3)),
      duracaoMin: 60,
      local: 'Academia X',
    ),
    _Sessao(
      titulo: 'Costas e Bíceps',
      inicio: DateTime.now().add(const Duration(days: 1, hours: 2)),
      duracaoMin: 55,
      local: 'Academia X',
    ),
    _Sessao(
      titulo: 'Pernas (Força)',
      inicio: DateTime.now().add(const Duration(days: 2, hours: 19)),
      duracaoMin: 70,
      local: 'Academia X',
    ),
  ];

  late Map<DateTime, List<_Sessao>> _eventosPorDia;

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = _normalize(DateTime.now());

  @override
  void initState() {
    super.initState();
    _eventosPorDia = _agruparPorDia(_todasSessoes);
  }

  // ===== Utils =====
  static DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  Map<DateTime, List<_Sessao>> _agruparPorDia(List<_Sessao> xs) {
    final map = <DateTime, List<_Sessao>>{};
    for (final s in xs) {
      final key = _normalize(s.inicio);
      (map[key] ??= []).add(s);
    }
    return map;
  }

  List<_Sessao> _getEventos(DateTime day) =>
      _eventosPorDia[_normalize(day)] ?? const [];

  String _fmtHoraMin(DateTime dt) {
    String dois(int n) => n.toString().padLeft(2, '0');
    return '${dois(dt.hour)}:${dois(dt.minute)}';
  }

  // ===== Ações rápidas (placeholder) =====
 void _onGerarTreino() =>
    Navigator.pushNamed(context, '/gerar-treino');

  void _onTreinos() =>
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ir para Treinos (TODO)')));
  void _onConsultoria() =>
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Abrir Consultoria (TODO)')));
  void _onPerfil() =>
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Abrir Perfil (TODO)')));

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final eventosHoje = _getEventos(_selectedDay);

    return Scaffold(
      appBar: AppBar(title: const Text('Início')),
      body: RefreshIndicator(
        onRefresh: () async {
          // quando ligar a API, atualize _todasSessoes e _eventosPorDia aqui
          await Future.delayed(const Duration(milliseconds: 400));
          if (!mounted) return;
          setState(() {});
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            // ===== Botões de acesso rápido =====
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _QuickAction(icon: Icons.settings, label: 'Gerar Treino', onTap: _onGerarTreino),
                _QuickAction(icon: Icons.list_alt, label: 'Treinos', onTap: _onTreinos),
                _QuickAction(icon: Icons.support_agent, label: 'Consultoria', onTap: _onConsultoria),
                _QuickAction(icon: Icons.person, label: 'Perfil', onTap: _onPerfil),
              ],
            ),

            const SizedBox(height: 16),

            // ===== Calendário =====
            Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant),
              ),
              padding: const EdgeInsets.all(8),
              child: TableCalendar<_Sessao>(
                firstDay: DateTime.utc(2022, 1, 1),
                lastDay: DateTime.utc(2032, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.monday,
                selectedDayPredicate: (d) => _normalize(d) == _selectedDay,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = _normalize(selectedDay);
                    _focusedDay = focusedDay;
                  });
                },
                eventLoader: _getEventos,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: Theme.of(context).textTheme.titleMedium!,
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: cs.primary.withOpacity(.2),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: cs.onSurfaceVariant),
                  weekendStyle: TextStyle(color: cs.onSurfaceVariant),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ===== Sessões do dia selecionado =====
            if (eventosHoje.isEmpty)
              _EmptyInline(
                icon: Icons.event_busy,
                text: 'Nenhuma sessão para ${_selectedDay.day}/${_selectedDay.month}.',
                actionLabel: 'Nova sessão',
                onAction: _onGerarTreino,
              )
            else
              ...eventosHoje.map((s) => _SessaoTile(sessao: s)),
          ],
        ),
      ),
    );
  }
}

// ======== COMPONENTES ========

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
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

class _Sessao {
  final String titulo;
  final DateTime inicio;
  final int duracaoMin;
  final String local;
  _Sessao({required this.titulo, required this.inicio, required this.duracaoMin, required this.local});
}

class _SessaoTile extends StatelessWidget {
  final _Sessao sessao;
  const _SessaoTile({required this.sessao});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    String dois(int n) => n.toString().padLeft(2, '0');
    final data = '${dois(sessao.inicio.day)}/${dois(sessao.inicio.month)}/${sessao.inicio.year}';
    final hora = '${dois(sessao.inicio.hour)}:${dois(sessao.inicio.minute)}';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: cs.primaryContainer.withOpacity(.35),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.event_available, color: cs.primary),
        ),
        title: Text(sessao.titulo, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('$data • $hora • ${sessao.duracaoMin} min • ${sessao.local}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Abrir sessão: ${sessao.titulo} (TODO)')),
          );
        },
      ),
    );
  }
}

class _EmptyInline extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _EmptyInline({required this.icon, required this.text, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: cs.outlineVariant.withOpacity(.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
          if (actionLabel != null && onAction != null)
            TextButton.icon(onPressed: onAction, icon: const Icon(Icons.add), label: Text(actionLabel!)),
        ],
      ),
    );
  }
}
