import 'package:flutter/material.dart';

/// Home com layout moderno (Material 3)
/// - AppBar próprio (como combinamos, cada página tem o seu)
/// - Pull-to-refresh (placeholder para integração com API)
/// - Cards de estatísticas
/// - Ações rápidas
/// - Lista de "Próximas sessões"
/// - Seção horizontal de "Treinos favoritos"
///
/// TODO (integração):
///  - Substituir mocks por GET /dashboard (ou endpoints específicos)
///  - Navegar nas ações rápidas para as páginas reais
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // =======================
  // Mocks de dashboard
  // (depois trocar por dados da API)
  // =======================
  int sessoesSemana = 4;
  int concluidosSemana = 3;
  int minutosTreinoSemana = 180;

  // Sessões futuras (ex.: próximas 48h)
  final List<_Sessao> proximasSessoes = [
    _Sessao(
      titulo: 'Peito e Tríceps',
      inicio: DateTime.now().add(const Duration(hours: 4)),
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
      inicio: DateTime.now().add(const Duration(days: 1, hours: 20)),
      duracaoMin: 70,
      local: 'Academia X',
    ),
  ];

  // Favoritos (nomes de treinos)
  final List<String> favoritos = [
    'Hipertrofia ABC',
    'Full-Body 3x',
    'Emagrecimento HIIT',
    'Mobilidade Diária',
  ];

  // Pull-to-refresh: simula atualização
  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    // TODO: chamar API e setState com os novos dados
    if (!mounted) return;
    setState(() {
      // exemplo bobo só pra dar cara de atualização
      minutosTreinoSemana += 5;
    });
  }

  // Ações rápidas (placeholder)
  void _novaSessao() {
    // TODO: navegar para criação de sessão/treino
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Criar nova sessão (TODO)')));
  }

  void _verTreinos() {
    // TODO: navegar para /Treinos
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Ir para Treinos (TODO)')));
  }

  void _abrirConsultoria() {
    // TODO: navegar para /Consultoria
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Abrir Consultoria (TODO)')));
  }

  void _abrirPerfil() {
    // TODO: navegar para /Perfil
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Abrir Perfil (TODO)')));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Início'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _novaSessao,
        icon: const Icon(Icons.play_arrow),
        label: const Text('Começar sessão'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          children: [
            // ===== Welcome =====
            _WelcomeCard(
              onTap: _verTreinos,
              title: 'Bem-vindo 👋',
              subtitle: 'Seu painel de treinos e progresso.',
            ),
            const SizedBox(height: 12),

            // ===== Stats (grade 2 colunas) =====
            _StatsGrid(
              items: [
                _StatItem(
                  icon: Icons.schedule,
                  label: 'Sessões / semana',
                  value: '$sessoesSemana',
                ),
                _StatItem(
                  icon: Icons.check_circle,
                  label: 'Concluídos',
                  value: '$concluidosSemana',
                ),
                _StatItem(
                  icon: Icons.timer,
                  label: 'Min. na semana',
                  value: '$minutosTreinoSemana',
                ),
                _StatItem(
                  icon: Icons.local_fire_department,
                  label: 'Consistência',
                  value: '${((concluidosSemana / (sessoesSemana == 0 ? 1 : sessoesSemana)) * 100).round()}%',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ===== Ações rápidas =====
            _SectionHeader(
              title: 'Ações rápidas',
              icon: Icons.flash_on,
              trailing: IconButton(
                tooltip: 'Ver mais',
                onPressed: _verTreinos,
                icon: const Icon(Icons.chevron_right),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _QuickAction(
                  icon: Icons.add_circle,
                  label: 'Nova sessão',
                  onTap: _novaSessao,
                ),
                _QuickAction(
                  icon: Icons.fitness_center,
                  label: 'Ver treinos',
                  onTap: _verTreinos,
                ),
                _QuickAction(
                  icon: Icons.support_agent,
                  label: 'Consultoria',
                  onTap: _abrirConsultoria,
                ),
                _QuickAction(
                  icon: Icons.person,
                  label: 'Perfil',
                  onTap: _abrirPerfil,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ===== Próximas sessões =====
            _SectionHeader(
              title: 'Próximas sessões',
              icon: Icons.event,
            ),
            const SizedBox(height: 8),
            if (proximasSessoes.isEmpty)
              _EmptyInline(
                icon: Icons.event_busy,
                text: 'Sem sessões agendadas. Comece criando uma!',
                actionLabel: 'Nova sessão',
                onAction: _novaSessao,
              )
            else
              ...proximasSessoes
                  .map((s) => _SessaoTile(sessao: s))
                  .toList(growable: false),
            const SizedBox(height: 20),

            // ===== Favoritos =====
            _SectionHeader(
              title: 'Treinos favoritos',
              icon: Icons.star,
            ),
            const SizedBox(height: 8),
            if (favoritos.isEmpty)
              _EmptyInline(
                icon: Icons.star_border,
                text: 'Sem favoritos ainda.',
                actionLabel: 'Ver treinos',
                onAction: _verTreinos,
              )
            else
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: favoritos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (ctx, i) => ActionChip(
                    label: Text(favoritos[i]),
                    avatar: const Icon(Icons.star, size: 18),
                    onPressed: _verTreinos, // TODO: navegar direto pro detalhe
                    backgroundColor: cs.primaryContainer.withOpacity(.25),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ===================================================================
// =======================  COMPONENTES UI  ===========================
// ===================================================================

class _WelcomeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  const _WelcomeCard({
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withOpacity(.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.fitness_center, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  const _StatItem({required this.icon, required this.label, required this.value});
}

/// Grade 2 colunas com cards de estatísticas
class _StatsGrid extends StatelessWidget {
  final List<_StatItem> items;
  const _StatsGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 480;
    final crossAxisCount = isWide ? 3 : 2; // 3 colunas em telas mais largas

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: 92,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (ctx, i) => _StatTile(item: items[i]),
    );
  }
}

class _StatTile extends StatelessWidget {
  final _StatItem item;
  const _StatTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(.35),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: cs.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.label, style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 2),
                  Text(
                    item.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cabeçalho de seção com ícone e ação opcional
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  const _SectionHeader({required this.title, required this.icon, this.trailing});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: cs.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Ação rápida (botão em card)
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
          color: cs.surfaceContainerHighest.withOpacity(.35),
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

/// Sessão (modelo local)
class _Sessao {
  final String titulo;
  final DateTime inicio;
  final int duracaoMin;
  final String local;
  _Sessao({required this.titulo, required this.inicio, required this.duracaoMin, required this.local});
}

/// Tile para “Próximas sessões”
class _SessaoTile extends StatelessWidget {
  final _Sessao sessao;
  const _SessaoTile({required this.sessao});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final inicioFmt = _fmtDataHora(sessao.inicio);
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
        subtitle: Text('$inicioFmt • ${sessao.duracaoMin} min • ${sessao.local}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: navegar para a sessão/treino específico
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Abrir sessão: ${sessao.titulo} (TODO)')),
          );
        },
      ),
    );
  }

  static String _fmtDataHora(DateTime dt) {
    String dois(int n) => n.toString().padLeft(2, '0');
    final d = dois(dt.day), m = dois(dt.month), h = dois(dt.hour), min = dois(dt.minute);
    return '$d/$m • $h:$min';
    // Se quiser por extenso (qui/sex): use DateFormat EEE from intl (quando adicionar intl).
  }
}

/// Estado vazio compacto para linhas
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
