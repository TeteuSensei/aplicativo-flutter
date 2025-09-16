// lib/pages/consultoria_view.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// ConsultoriaView
/// Replica as funcionalidades da página React "certa":
/// - Estados: usuário (mock/placeholder), aba ativa (TabBar), treinos, loading.
/// - Regras de exibição de treinos para PERSONAL vs ALUNO.
/// - Abas: Treinos, Feedbacks, Progresso, Resultados, Bioimpedância.
/// - Sem dependências extras. TODOs onde plugará sua API/banco.
///
/// Integração depois:
/// - Obter usuário logado (tipo_usuario: "aluno"/"personal") do AuthService/local storage.
/// - GET treinos:
///     aluno   -> http://localhost:4000/api/treinos-aluno
///     personal-> http://localhost:4000/api/consultoria/treinos
///   com Authorization: Bearer <token>
/// - Navegar para páginas de detalhes conforme suas rotas reais.

class ConsultoriaView extends StatefulWidget {
  const ConsultoriaView({super.key});

  @override
  State<ConsultoriaView> createState() => _ConsultoriaViewState();
}

class _ConsultoriaViewState extends State<ConsultoriaView> with TickerProviderStateMixin {
  // ========================
  // 🔹 Estados principais
  // ========================
  bool carregando = true;
  _AppUser? user; // tipo_usuario: "aluno" | "personal"
  List<_TreinoItem> treinos = [];

  // TabController para sincronizar com a AppBar
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 5, vsync: this);
    _bootstrap();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    // 1) Carrega usuário (mock/placeholder). Depois, pegue do AuthService/local storage.
    _loadUser();
    // 2) Busca treinos (mock). Depois, troque por chamada de API conforme tipo_usuario.
    await _fetchTreinos();
    if (!mounted) return;
    setState(() => carregando = false);
  }

  void _loadUser() {
    // TODO: Carregar do AuthService/local storage (ex.: claims/JSON)
    // Exemplo (quando tiver):
    // final raw = AuthService.I.userJson; // string JSON
    // final map = jsonDecode(raw);
    // user = _AppUser.fromMap(map);
    //
    // Por enquanto, deixa um usuário fictício "aluno":
    user ??= const _AppUser(id: 101, nome: 'Aluno Demo', tipoUsuario: 'aluno');
    // Para testar como personal, troque acima para: tipoUsuario: 'personal'
  }

  Future<void> _fetchTreinos() async {
    final token = AuthService.I.token; // já existe no seu projeto
    final isPersonal = user?.tipoUsuario == 'personal';

    // TODO: Use http/axios do Flutter (http package) para buscar treinos.
    // final endpoint = isPersonal
    //   ? 'http://localhost:4000/api/consultoria/treinos'
    //   : 'http://localhost:4000/api/treinos-aluno';
    // final resp = await http.get(Uri.parse(endpoint), headers: {'Authorization': 'Bearer $token'});
    // final list = jsonDecode(resp.body);
    // setState(() => treinos = (list as List).map((j) => _TreinoItem.fromMap(j)).toList());

    // MOCK alinhado ao React: data no passado = “Realizado”
    final agora = DateTime.now();
    treinos = [
      _TreinoItem(
        id: 1,
        nome: isPersonal ? 'Treino A (Aluno Pedro)' : 'Full-Body',
        alunoNome: isPersonal ? 'Pedro' : null,
        data: agora.subtract(const Duration(days: 1)),
        objetivo: isPersonal ? null : 'Emagrecimento',
        observacoes: 'Sequência base',
        origem: 'manual',
        imagemUrl: null,
        personalId: isPersonal ? 999 : null,
      ),
      _TreinoItem(
        id: 2,
        nome: isPersonal ? 'Treino B (Aluna Ana)' : 'Peito/Tríceps',
        alunoNome: isPersonal ? 'Ana' : null,
        data: agora.add(const Duration(days: 1)),
        objetivo: isPersonal ? null : 'Hipertrofia',
        observacoes: 'Ajustar carga',
        origem: 'manual',
        imagemUrl: null,
        personalId: isPersonal ? 999 : null,
      ),
    ];
  }

  // ========================
  // 🔹 Render Treinos
  // ========================
  Widget _renderTreinos() {
    if (carregando) return const Padding(padding: EdgeInsets.all(16), child: Text('⏳ Carregando treinos...'));
    if (user == null) return const Padding(padding: EdgeInsets.all(16), child: Text('❌ Usuário não autenticado.'));

    final isPersonal = user!.tipoUsuario == 'personal';

    // PERSONAL: lista “Treinos dos Alunos” filtrando por personal_id == user.id
    if (isPersonal) {
      final meus = treinos.where((t) => t.personalId == user!.id).toList();
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _H3('📋 Treinos dos Alunos'),
            const SizedBox(height: 8),
            if (meus.isEmpty)
              const Text('Você ainda não criou treinos para seus alunos.')
            else
              ...meus.map((treino) => _TreinoCardPersonal(
                    treino: treino,
                    onVerDetalhes: () => _abrirDetalheTreinoPersonal(treino),
                  )),
          ],
        ),
      );
    }

    // ALUNO: "Meus Treinos"
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _H3('📋 Meus Treinos'),
          const SizedBox(height: 8),
          if (treinos.isEmpty)
            const Text('Você ainda não recebeu treinos.')
          else
            ...treinos.map((treino) => _TreinoCardAluno(
                  treino: treino,
                  onVerDetalhes: () => _abrirDetalheTreinoAluno(treino),
                )),
        ],
      ),
    );
  }

  void _abrirDetalheTreinoPersonal(_TreinoItem t) {
    // No React: navigate(`/treino/${treino.id}`)
    // TODO: substitua pela sua rota de detalhes:
    // Navigator.pushNamed(context, '/treino/${t.id}');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('👁 Ver Detalhes: /treino/${t.id}')));
  }

  void _abrirDetalheTreinoAluno(_TreinoItem t) {
    // No React: navigate(`/aluno/${user.id}/treino/${treino.id}?origem=${treino.origem||"manual"}`)
    // TODO: substitua pela sua rota real:
    final origem = t.origem ?? 'manual';
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('👁 Ver Detalhes: /aluno/${user?.id}/treino/${t.id}?origem=$origem')));
  }

  // ========================
  // 🔹 Render Feedbacks
  // ========================
  Widget _renderFeedbacks() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _H3('💬 Feedbacks'),
          SizedBox(height: 8),
          Text('Aqui ficarão os comentários e avaliações sobre os treinos realizados.'),
          Text('(Exemplo: ⭐⭐⭐⭐ - "Treino muito bom, senti evolução!")'),
        ],
      ),
    );
  }

  // ========================
  // 🔹 Render Progresso
  // ========================
  Widget _renderProgresso() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        _H3('📈 Acompanhamento de Progresso'),
        SizedBox(height: 10),
        _CardResultados(title: 'Dados Gerais', lines: [
          'Peso: 91,2 kg',
          'Altura: 1,85 m',
          'IMC: 27,3 (Pré-obesidade)',
          'Taxa Metabólica Basal: 2059 kcal',
        ]),
        SizedBox(height: 10),
        _CardResultados(title: 'Composição Corporal', lines: [
          'Massa Gorda: 29,9% (Muito ruim)',
          'Massa Muscular: 63,9 kg',
          'Massa Óssea: 22,0 kg',
        ]),
        SizedBox(height: 10),
        _CardResultados(title: 'Avaliação Postural', lines: [
          'Ombros: alinhados',
          'Quadril: anteversão',
          'Joelhos: recurvatum',
          'Pés: pronado',
        ]),
      ]),
    );
  }

  // ========================
  // 🔹 Render Resultados
  // ========================
  Widget _renderResultados() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _H3('📊 Resultados da Consultoria'),
        SizedBox(height: 10),
        _CardResultados(title: 'Resumo', lines: [
          'Peso: 91,1 kg',
          '% Gordura: 26,6%',
          '% Músculos: 33,5%',
          'IMC: 29,5',
          'Idade Corporal: 33 anos',
        ]),
      ]),
    );
  }

  // ========================
  // 🔹 Render Bioimpedância
  // ========================
  Widget _renderBioimpedancia() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _H3('⚡ Análise da Composição Corporal (Bioimpedância)'),
        const SizedBox(height: 10),

        // Dados gerais
        const _CardResultados(title: 'Dados Gerais', lines: [
          'Peso: 91,2 kg',
          'Altura: 1,85 m',
          'Taxa Metabólica Basal: 2059 kcal',
          'IMC: 26,6 (Pré-obesidade)',
        ]),
        const SizedBox(height: 10),

        // Dobras cutâneas
        const _CardResultados(title: 'Dobras Cutâneas (mm)', lines: [
          'Subescapular: 25',
          'Peitoral: 33',
          'Tricipital: 26',
          'Axilar média: 34',
          'Bicipital: 10',
          'Supra-ilíaca: 27',
          'Abdominal: 54',
          'Coxa: 40',
          'Panturrilha: 38',
        ]),
        const SizedBox(height: 10),

        // Resultados principais
        const _CardResultados(title: 'Resultados', lines: [
          'Gordura atual: 29,9%',
          'Massa gorda: 27,3 kg',
          'Massa livre de gordura: 63,9 kg',
          'Massa muscular: 41,9 kg',
          'Massa residual: 22,0 kg',
          'Massa óssea: 0,0 kg',
        ]),
        const SizedBox(height: 10),

        // Classificação
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Classificação', style: TextStyle(fontWeight: FontWeight.w700)),
              SizedBox(height: 6),
              _Line('• % Gordura Corporal: Muito Ruim'),
              _Line('• IMC: Pré-obesidade'),
            ]),
          ),
        ),
        const SizedBox(height: 10),

        // Avaliação postural com "fotos"
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('📷 Avaliação Postural', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              LayoutBuilder(builder: (ctx, c) {
                final twoCols = c.maxWidth >= 700;
                final itemW = twoCols ? (c.maxWidth - 12) / 2 : c.maxWidth;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _FotoPostural(
                      width: itemW,
                      titulo: 'Visão Lateral',
                      detalhes: const ['Ombros: alinhados', 'Quadril: anteversão', 'Joelhos: recurvatum', 'Pés: pronado'],
                    ),
                    _FotoPostural(
                      width: itemW,
                      titulo: 'Visão Posterior',
                      detalhes: const ['Escápula: direita alada', 'Coluna: escoliose torácica', 'Ombros: alinhados'],
                    ),
                    _FotoPostural(
                      width: itemW,
                      titulo: 'Visão Anterior',
                      detalhes: const ['Cabeça: neutro', 'Joelhos: valgo', 'Patela: alinhada'],
                    ),
                  ],
                );
              }),
            ]),
          ),
        ),
        const SizedBox(height: 10),

        // Gráficos (placeholder)
        const _CardResultados(title: 'Gráficos', lines: [
          '[Em breve: gráfico de pizza/barras com % gordura, massa magra, massa óssea]',
        ]),
      ]),
    );
  }

  // ========================
  // 🔹 Scaffold + Abas
  // ========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user?.tipoUsuario == 'personal' ? '👨‍🏫 Consultoria do Personal' : '🙋‍♂️ Consultoria do Aluno'),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Treinos'),
            Tab(text: 'Feedbacks'),
            Tab(text: 'Progresso'),
            Tab(text: 'Resultados'),
            Tab(text: 'Bioimpedância'),
          ],
        ),
        actions: [
          // Toggle rápido só pra você testar ALUNO x PERSONAL durante o dev
          PopupMenuButton<String>(
            tooltip: 'Mudar papel (dev)',
            onSelected: (v) {
              setState(() {
                user = _AppUser(id: user?.id ?? 101, nome: user?.nome ?? 'Demo', tipoUsuario: v);
                carregando = true;
              });
              _fetchTreinos().then((_) => mounted ? setState(() => carregando = false) : null);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'aluno', child: Text('Ver como: aluno')),
              PopupMenuItem(value: 'personal', child: Text('Ver como: personal')),
            ],
            icon: const Icon(Icons.swap_horiz),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _renderTreinos(),
          _renderFeedbacks(),
          _renderProgresso(),
          _renderResultados(),
          _renderBioimpedancia(),
        ],
      ),
    );
  }
}

// ===================================================================
// =======================  COMPONENTES/UI  ===========================
// ===================================================================

class _TreinoCardPersonal extends StatelessWidget {
  final _TreinoItem treino;
  final VoidCallback onVerDetalhes;
  const _TreinoCardPersonal({required this.treino, required this.onVerDetalhes});

  @override
  Widget build(BuildContext context) {
    final realizado = treino.data.isBefore(DateTime.now());
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (treino.imagemUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(treino.imagemUrl!, height: 140, width: double.infinity, fit: BoxFit.cover),
            ),
          if (treino.imagemUrl != null) const SizedBox(height: 10),
          Text(treino.nome ?? 'Treino', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          _Line('Aluno: ${treino.alunoNome ?? '-'}'),
          _Line('Data: ${_fmtDate(treino.data)}'),
          const SizedBox(height: 6),
          Row(
            children: [
              _Badge(text: realizado ? '✅ Realizado' : '⌛ Pendente', color: realizado ? cs.primary : cs.tertiary),
              const Spacer(),
              TextButton(onPressed: onVerDetalhes, child: const Text('👁 Ver Detalhes')),
            ],
          ),
        ]),
      ),
    );
  }
}

class _TreinoCardAluno extends StatelessWidget {
  final _TreinoItem treino;
  final VoidCallback onVerDetalhes;
  const _TreinoCardAluno({required this.treino, required this.onVerDetalhes});

  @override
  Widget build(BuildContext context) {
    final realizado = treino.data.isBefore(DateTime.now());
    final objetivo = treino.objetivo ?? treino.observacoes ?? '-';
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(treino.nome ?? 'Treino Aplicado', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          _Line('Objetivo: $objetivo'),
          _Line('Data: ${_fmtDate(treino.data)}'),
          const SizedBox(height: 6),
          Row(
            children: [
              _Badge(text: realizado ? '✅ Realizado' : '⌛ Pendente', color: realizado ? cs.primary : cs.tertiary),
              const Spacer(),
              TextButton(onPressed: onVerDetalhes, child: const Text('👁 Ver Detalhes')),
            ],
          ),
        ]),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(.5)),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class _H3 extends StatelessWidget {
  final String text;
  const _H3(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800));
  }
}

class _Line extends StatelessWidget {
  final String text;
  const _Line(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.bodyMedium);
  }
}

class _CardResultados extends StatelessWidget {
  final String title;
  final List<String> lines;
  const _CardResultados({required this.title, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          ...lines.map((l) => _Line('• $l')),
        ]),
      ),
    );
  }
}

class _FotoPostural extends StatelessWidget {
  final String titulo;
  final List<String> detalhes;
  final double width;
  const _FotoPostural({required this.titulo, required this.detalhes, required this.width});

  @override
  Widget build(BuildContext context) {
    final ph = Container(
      height: 200,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(.35),
      alignment: Alignment.center,
      child: const Text('[Foto]'),
    );

    return SizedBox(
      width: width,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titulo, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ph, // placeholder. Depois, Image.network(...) com URL real.
            const SizedBox(height: 8),
            ...detalhes.map((d) => _Line(d)),
          ]),
        ),
      ),
    );
  }
}

// ===================================================================
// ============================  MODELOS  =============================
// ===================================================================

class _AppUser {
  final int id;
  final String nome;
  final String tipoUsuario; // "aluno" | "personal"
  const _AppUser({required this.id, required this.nome, required this.tipoUsuario});

  factory _AppUser.fromMap(Map<String, dynamic> m) {
    return _AppUser(
      id: (m['id'] as num).toInt(),
      nome: (m['nome'] as String?) ?? (m['name'] as String?) ?? 'Usuário',
      tipoUsuario: (m['tipo_usuario'] as String?) ?? 'aluno',
    );
  }
}

class _TreinoItem {
  final int id;
  final String? nome;
  final String? alunoNome;
  final DateTime data; // usa data_aplicacao || data || created_at
  final String? objetivo;
  final String? observacoes;
  final String? origem;
  final String? imagemUrl;
  final int? personalId;

  _TreinoItem({
    required this.id,
    required this.data,
    this.nome,
    this.alunoNome,
    this.objetivo,
    this.observacoes,
    this.origem,
    this.imagemUrl,
    this.personalId,
  });

  factory _TreinoItem.fromMap(Map<String, dynamic> j) {
    // Resolve data em múltiplas chaves: data_aplicacao || data || created_at
    DateTime _parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      return DateTime.tryParse(v.toString()) ?? DateTime.now();
    }

    return _TreinoItem(
      id: (j['id'] as num).toInt(),
      nome: j['nome'] as String?,
      alunoNome: j['aluno_nome'] as String?,
      data: _parseDate(j['data_aplicacao'] ?? j['data'] ?? j['created_at']),
      objetivo: j['objetivo'] as String?,
      observacoes: j['observacoes'] as String?,
      origem: j['origem'] as String?,
      imagemUrl: j['imagem_url'] as String?,
      personalId: (j['personal_id'] as num?)?.toInt(),
    );
  }
}

// ===================================================================
// =======================  HELPERS LOCAIS  ===========================
// ===================================================================

String _fmtDate(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year}';
}
