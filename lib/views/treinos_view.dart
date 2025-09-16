import 'package:flutter/material.dart';
import '../models/treino.dart';
import '../widgets/treino_card.dart';
import '../widgets/novo_treino_sheet.dart';

class TreinosView extends StatefulWidget {
  const TreinosView({super.key});

  @override
  State<TreinosView> createState() => _TreinosViewState();
}

class _TreinosViewState extends State<TreinosView> {
  final List<Treino> _treinos = [
    Treino(
      id: 1,
      nome: 'Hipertrofia ABC',
      criadoEm: DateTime.now().subtract(const Duration(days: 10)),
      vigenciaInicio: DateTime.now().subtract(const Duration(days: 7)),
      vigenciaFim: DateTime.now().add(const Duration(days: 14)),
      favorito: true,
    ),
    Treino(
      id: 2,
      nome: 'Emagrecimento Full-Body',
      criadoEm: DateTime.now().subtract(const Duration(days: 40)),
      vigenciaInicio: DateTime.now().add(const Duration(days: 3)),
      vigenciaFim: DateTime.now().add(const Duration(days: 40)),
    ),
    Treino(
      id: 3,
      nome: 'Recondicionamento',
      criadoEm: DateTime.now().subtract(const Duration(days: 120)),
      vigenciaInicio: DateTime.now().subtract(const Duration(days: 90)),
      vigenciaFim: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];

  String _busca = '';
  TreinoStatus? _filtroStatus; // null = todos
  bool _somenteFavoritos = false;
  final _scrollCtrl = ScrollController();

  List<Treino> get _listaFiltrada {
    return _treinos.where((t) {
      final byBusca = _busca.isEmpty || t.nome.toLowerCase().contains(_busca.toLowerCase());
      final byFav = !_somenteFavoritos || t.favorito;
      final byStatus = _filtroStatus == null || t.status == _filtroStatus;
      return byBusca && byFav && byStatus;
    }).toList()
      ..sort((a, b) {
        // favoritos primeiro, depois mais recentes pela criação
        final fav = (b.favorito ? 1 : 0) - (a.favorito ? 1 : 0);
        if (fav != 0) return fav;
        return b.criadoEm.compareTo(a.criadoEm);
      });
  }

  Future<void> _abrirNovoTreino() async {
    final novo = await showModalBottomSheet<Treino>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: NovoTreinoSheet(),
      ),
    );
    if (novo != null) {
      setState(() => _treinos.add(novo));
      // TODO: integrar com API: enviar POST e recarregar lista
      _scrollCtrl.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _editarTreino(Treino t) {
    // TODO: abrir tela de edição
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Editar: ${t.nome} (TODO)')));
  }

  void _duplicarTreino(Treino t) {
    final dup = t.copyWith(
      id: DateTime.now().microsecondsSinceEpoch,
      nome: '${t.nome} (cópia)',
      criadoEm: DateTime.now(),
      favorito: false,
    );
    setState(() => _treinos.add(dup));
  }

  void _excluirTreino(Treino t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir treino'),
        content: Text('Tem certeza que deseja excluir "${t.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              setState(() => _treinos.removeWhere((x) => x.id == t.id));
              Navigator.pop(ctx);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _pullRefresh() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: integrar com API: GET treinos
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lista = _listaFiltrada;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Treinos'),
        actions: [
          IconButton(
            tooltip: 'Buscar',
            onPressed: () async {
              final q = await showSearch<String?>(
                context: context,
                delegate: _TreinoSearchDelegate(initialQuery: _busca),
              );
              if (q != null) setState(() => _busca = q);
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: _somenteFavoritos ? 'Mostrar todos' : 'Somente favoritos',
            onPressed: () => setState(() => _somenteFavoritos = !_somenteFavoritos),
            icon: Icon(_somenteFavoritos ? Icons.star : Icons.star_border),
          ),
          PopupMenuButton<TreinoStatus?>(
            tooltip: 'Filtrar status',
            onSelected: (v) => setState(() => _filtroStatus = v),
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: null, child: Text('Todos')),
              PopupMenuItem(value: TreinoStatus.ativo, child: Text('Ativos')),
              PopupMenuItem(value: TreinoStatus.futuro, child: Text('Futuros')),
              PopupMenuItem(value: TreinoStatus.expirado, child: Text('Expirados')),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: lista.isEmpty ? _buildEmptyState(context) : _buildList(context, lista),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirNovoTreino,
        icon: const Icon(Icons.add),
        label: const Text('Novo treino'),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Treino> lista) {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: lista.length,
      itemBuilder: (ctx, i) {
        final t = lista[i];
        return TreinoCard(
          treino: t,
          onTap: () {
            // TODO: navegar para detalhes do treino
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Abrir: ${t.nome} (TODO)')));
          },
          onEditar: () => _editarTreino(t),
          onDuplicar: () => _duplicarTreino(t),
          onExcluir: () => _excluirTreino(t),
          onToggleFavorito: () {
            final idx = _treinos.indexWhere((x) => x.id == t.id);
            if (idx >= 0) {
              setState(() => _treinos[idx] = _treinos[idx].copyWith(favorito: !t.favorito));
            }
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        Icon(Icons.fitness_center, size: 72, color: theme.colorScheme.primary),
        const SizedBox(height: 12),
        Center(
          child: Text('Sem treinos ainda', style: theme.textTheme.titleLarge),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Crie seu primeiro plano de treino para começar.',
            style: theme.textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: FilledButton.icon(
            onPressed: _abrirNovoTreino,
            icon: const Icon(Icons.add),
            label: const Text('Criar primeiro treino'),
          ),
        ),
      ],
    );
  }
}

class _TreinoSearchDelegate extends SearchDelegate<String?> {
  _TreinoSearchDelegate({String? initialQuery}) {
    query = initialQuery ?? '';
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () => query = '',
          icon: const Icon(Icons.clear),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Apenas retorna a query; a tela principal faz o filtro.
    return Center(
      child: FilledButton(
        onPressed: () => close(context, query),
        child: const Text('Aplicar busca'),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text('Digite para buscar por nome do treino...'),
    );
  }
}
