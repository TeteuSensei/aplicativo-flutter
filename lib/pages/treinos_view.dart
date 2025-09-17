// lib/pages/treinos_view.dart
import 'package:flutter/material.dart';
import 'package:consultoria_app/pages/treino_detalhe_view.dart'; //


// Modelo (status, datas, etc.)
import '../models/treino.dart';


// Widgets reutilizáveis da tela
import '../widgets/treino_card.dart';
import '../widgets/novo_treino_sheet.dart';


/// Tela de listagem de treinos do usuário.
/// - Lista em cards com ações (editar, duplicar, excluir, favorito)
/// - Filtros: busca por nome, status (Ativo/Futuro/Expirado) e "somente favoritos"
/// - Pull-to-refresh (placeholder para integrar com API depois)
/// - FAB para criar novo treino (abre bottom sheet com formulário)
class TreinosView extends StatefulWidget {
  const TreinosView({super.key});

  @override
  State<TreinosView> createState() => _TreinosViewState();
}

class _TreinosViewState extends State<TreinosView> {
  // ---------------------------------------------------------------------------
  // MOCK: lista inicial de treinos (substituir depois por carregamento via API)
  // ---------------------------------------------------------------------------
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

  // Estado de UI: busca, filtro por status e favoritos
  String _busca = '';
  TreinoStatus? _filtroStatus; // null = todos
  bool _somenteFavoritos = false;

  // Controller da lista (para dar scroll ao topo após criar novo treino)
  final _scrollCtrl = ScrollController();

  // ----------------------------------------------------------------------------
  // Getter que aplica os filtros na lista original e ordena:
  //   1) favoritos primeiro; 2) por data de criação (mais recente primeiro)
  // ----------------------------------------------------------------------------
  List<Treino> get _listaFiltrada {
    return _treinos.where((t) {
      final byBusca =
          _busca.isEmpty || t.nome.toLowerCase().contains(_busca.toLowerCase());
      final byFav = !_somenteFavoritos || t.favorito;
      final byStatus = _filtroStatus == null || t.status == _filtroStatus;
      return byBusca && byFav && byStatus;
    }).toList()..sort((a, b) {
      final favDiff = (b.favorito ? 1 : 0) - (a.favorito ? 1 : 0);
      if (favDiff != 0) return favDiff;
      return b.criadoEm.compareTo(a.criadoEm);
    });
  }

  // ----------------------------------------------------------------------------
  // Abre o bottom sheet de "Novo treino" e adiciona o resultado na lista
  // (Depois: substituir por POST na API e recarregar via GET)
  // ----------------------------------------------------------------------------
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
      // Scroll até o topo pra evidenciar o novo item
      if (mounted) {
        _scrollCtrl.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  // Ações do card (stubs para integrar depois)
  void _editarTreino(Treino t) {
    // TODO: navegar para tela de edição/detalhe
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Editar: ${t.nome} (TODO)')));
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
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
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

  // Pull-to-refresh (placeholder)
  Future<void> _pullRefresh() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: integrar com API -> GET /treinos
    if (mounted) setState(() {});
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
      // Se seu Shell já tiver AppBar, remova este `appBar:` para evitar duplicidade.
      appBar: AppBar(
        title: const Text('Treinos'),
        actions: [
          // BOTÃO DE BUSCA: abre o SearchDelegate e aplica a query
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

          // FAVORITOS: alterna entre "mostrar todos" e "somente favoritos"
          IconButton(
            tooltip: _somenteFavoritos ? 'Mostrar todos' : 'Somente favoritos',
            onPressed: () =>
                setState(() => _somenteFavoritos = !_somenteFavoritos),
            icon: Icon(_somenteFavoritos ? Icons.star : Icons.star_border),
          ),

          // FILTRO POR STATUS: Todos / Ativos / Futuros / Expirados
          PopupMenuButton<TreinoStatus?>(
            tooltip: 'Filtrar status',
            onSelected: (v) => setState(() => _filtroStatus = v),
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: null, child: Text('Todos')),
              PopupMenuItem(value: TreinoStatus.ativo, child: Text('Ativos')),
              PopupMenuItem(value: TreinoStatus.futuro, child: Text('Futuros')),
              PopupMenuItem(
                value: TreinoStatus.expirado,
                child: Text('Expirados'),
              ),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),

      // LISTA + REFRESH
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        // Quando a lista está vazia, mostramos um "estado vazio" convidando a criar o primeiro treino
        child: lista.isEmpty
            ? _buildEmptyState(context)
            : _buildList(context, lista),
      ),

      // BOTÃO DE AÇÃO FLUTUANTE: cria novo treino
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirNovoTreino,
        icon: const Icon(Icons.add),
        label: const Text('Novo treino'),
      ),
    );
  }

  // ----------------------------------------------------------------------------
  // Constrói a lista de cards com TreinoCard
  // ----------------------------------------------------------------------------
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TreinoDetalheView(treino: t)),
            );
          },
          onEditar: () => _editarTreino(t),
          onDuplicar: () => _duplicarTreino(t),
          onExcluir: () => _excluirTreino(t),
          onToggleFavorito: () {
            /* ... */
          },
        );
      },
    );
  }

  // ----------------------------------------------------------------------------
  // Estado vazio (primeiro acesso, sem treinos ainda)
  // Usamos ListView para permitir o pull-to-refresh mesmo vazio.
  // ----------------------------------------------------------------------------
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
            textAlign: TextAlign.center,
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
    // Dica: você pode exibir aqui também dicas/atalhos para "treinos favoritos" do personal.
  }
}

/// SearchDelegate simples que só devolve a string buscada.
/// A tela principal aplica o filtro de fato (em `_listaFiltrada`).
class _TreinoSearchDelegate extends SearchDelegate<String?> {
  _TreinoSearchDelegate({String? initialQuery}) {
    query = initialQuery ?? '';
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear)),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    onPressed: () => close(context, null),
    icon: const Icon(Icons.arrow_back),
  );

  @override
  Widget buildResults(BuildContext context) {
    // Ao confirmar, retornamos a query para a TreinosView aplicar o filtro.
    return Center(
      child: FilledButton(
        onPressed: () => close(context, query),
        child: const Text('Aplicar busca'),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => const Padding(
    padding: EdgeInsets.all(16),
    child: Text('Digite para buscar por nome do treino...'),
  );
}
