import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ===== Catálogo local de exercícios (placeholder) =====
class _ExCat {
  final String nome, grupo, equipamento, dificuldade;
  const _ExCat(this.nome, this.grupo, this.equipamento, this.dificuldade);
}

const List<_ExCat> _CAT = [
  // PEITO
  _ExCat("Supino reto com barra", "Peito", "barra", "intermediario"),
  _ExCat("Supino reto com halteres", "Peito", "halteres", "iniciante"),
  _ExCat("Supino inclinado com halteres", "Peito", "halteres", "intermediario"),
  _ExCat("Crucifixo com halteres", "Peito", "halteres", "iniciante"),
  _ExCat("Crucifixo na máquina", "Peito", "maquina", "iniciante"),
  // COSTAS
  _ExCat("Puxada frente na polia", "Costas", "maquina", "iniciante"),
  _ExCat("Remada curvada com barra", "Costas", "barra", "intermediario"),
  _ExCat("Remada baixa na máquina", "Costas", "maquina", "iniciante"),
  _ExCat("Pulldown com elástico", "Costas", "elastico", "iniciante"),
  _ExCat("Remada unilateral com halter", "Costas", "halteres", "iniciante"),
  // PERNAS
  _ExCat("Agachamento livre", "Pernas", "livre", "intermediario"),
  _ExCat("Agachamento no smith", "Pernas", "maquina", "iniciante"),
  _ExCat("Leg press", "Pernas", "maquina", "iniciante"),
  _ExCat("Cadeira extensora", "Pernas", "maquina", "iniciante"),
  _ExCat("Mesa flexora", "Pernas", "maquina", "iniciante"),
  _ExCat("Levantamento terra romeno", "Pernas", "barra", "intermediario"),
  // OMBROS
  _ExCat("Desenvolvimento com halteres", "Ombros", "halteres", "iniciante"),
  _ExCat("Desenvolvimento na máquina", "Ombros", "maquina", "iniciante"),
  _ExCat("Elevação lateral com halteres", "Ombros", "halteres", "iniciante"),
  _ExCat("Elevação frontal com halteres", "Ombros", "halteres", "iniciante"),
  // BÍCEPS
  _ExCat("Rosca direta com barra", "Bíceps", "barra", "iniciante"),
  _ExCat("Rosca alternada com halteres", "Bíceps", "halteres", "iniciante"),
  _ExCat("Rosca martelo", "Bíceps", "halteres", "iniciante"),
  // TRÍCEPS
  _ExCat("Tríceps na polia (corda)", "Tríceps", "maquina", "iniciante"),
  _ExCat("Tríceps testa com barra", "Tríceps", "barra", "intermediario"),
  _ExCat("Mergulho em banco", "Tríceps", "livre", "iniciante"),
  // ABDÔMEN
  _ExCat("Prancha abdominal", "Abdômen", "livre", "iniciante"),
  _ExCat("Crunch no solo", "Abdômen", "livre", "iniciante"),
  _ExCat("Elevação de pernas", "Abdômen", "livre", "intermediario"),
  // GLÚTEOS
  _ExCat("Elevação pélvica (hip thrust) com barra", "Glúteos", "barra", "intermediario"),
  _ExCat("Elevação pélvica no banco", "Glúteos", "livre", "iniciante"),
  _ExCat("Cadeira abdutora", "Glúteos", "maquina", "iniciante"),
];

const List<String> _GRUPOS = ["Peito","Costas","Pernas","Glúteos","Ombros","Bíceps","Tríceps","Abdômen"];
const List<String> _EQUIP = ["livre","halteres","maquina","elastico","barra"];

// ===== Prescrições por objetivo =====
class _Presc { final List<int> series, reps; final String pausa; const _Presc(this.series,this.reps,this.pausa); }
const Map<String, _Presc> _PRESC = {
  "Hipertrofia": _Presc([3,4], [8,12], "60–90s"),
  "Emagrecimento": _Presc([2,3], [12,15], "30–60s"),
  "Força": _Presc([4,5], [4,6], "120–180s"),
  "Resistência": _Presc([2,3], [15,20], "30–45s"),
};

// ===== Tela =====
class GerarTreinoView extends StatefulWidget {
  const GerarTreinoView({super.key});
  @override
  State<GerarTreinoView> createState() => _GerarTreinoViewState();
}

class _GerarTreinoViewState extends State<GerarTreinoView> {
  // parâmetros
  String objetivo = "Hipertrofia";
  String nivel = "Intermediário";
  int sessoes = 3;
  int duracaoSemanas = 8;
  int tempoSessao = 60;
  final Set<String> equipDisp = {..._EQUIP};
  final Set<String> focoGrupos = {};
  bool rJoelho = false, rOmbro = false, rLombar = false;
  final nomeCtrl = TextEditingController();

  Map<String, dynamic>? plano; // JSON do plano gerado

  @override
  void dispose() { nomeCtrl.dispose(); super.dispose(); }

  // ===== Lógica principal =====
  Map<String, dynamic> _prescricaoAtual() {
    final p = _PRESC[objetivo]!;
    final series = (nivel == "Avançado") ? p.series[1] : p.series[0];
    final repsStr = (objetivo == "Força")
        ? "${p.reps[0]}–${p.reps[1]}"
        : (nivel == "Iniciante")
            ? "${max(p.reps[0]-2, 6)}–${p.reps[1]}"
            : "${p.reps[0]}–${p.reps[1]}";
    return {"series": series, "reps": repsStr, "pausa": p.pausa};
  }

  List<String> _dividirSessoes(int q) {
    if (q <= 2) return ["Full Body","Full Body"];
    if (q == 3) return ["Empurrão (Peito/Ombro/Tríceps)","Puxão (Costas/Bíceps)","Pernas/Glúteos + Abdômen"];
    if (q == 4) return ["Superiores A","Inferiores A","Superiores B","Inferiores B"];
    if (q == 5) return ["Peito/Ombros/Tríceps","Costas/Bíceps","Pernas/Glúteos","Superiores Leve","Abdômen + Mobilidade"];
    return ["Peito","Costas","Pernas/Glúteos","Ombros/Braços","Full Body","Abdômen/Condicionamento"];
  }

  List<_ExCat> _filtrar(String grupo) {
    Iterable<_ExCat> xs = _CAT.where((e) => e.grupo == grupo && equipDisp.contains(e.equipamento));

    // nível
    if (nivel == "Iniciante") xs = xs.where((e) => e.dificuldade != "avancado");
    if (nivel == "Intermediário") xs = xs.where((e) => e.dificuldade != "avancado");

    // restrições
    if (rJoelho && (grupo == "Pernas" || grupo == "Glúteos")) {
      xs = xs.where((e) => !RegExp(r'agachamento|terra|leg press|levantar', caseSensitive: false).hasMatch(e.nome));
    }
    if (rOmbro && (grupo == "Peito" || grupo == "Ombros" || grupo == "Tríceps")) {
      xs = xs.where((e) => !RegExp(r'desenvolvimento|supino', caseSensitive: false).hasMatch(e.nome));
    }
    if (rLombar) {
      xs = xs.where((e) => !RegExp(r'terra|remada curvada|agachamento livre', caseSensitive: false).hasMatch(e.nome));
    }
    return xs.toList();
  }

  List<Map<String, dynamic>> _montarSessao(String tipo) {
    List<String> grupos = [];
    if (tipo.contains("Full Body")) {
      grupos = ["Pernas","Peito","Costas","Ombros","Bíceps","Tríceps","Abdômen"];
    } else if (RegExp("Empurrão").hasMatch(tipo)) {
      grupos = ["Peito","Ombros","Tríceps","Abdômen"];
    } else if (RegExp("Puxão").hasMatch(tipo)) {
      grupos = ["Costas","Bíceps","Abdômen"];
    } else if (RegExp("Inferiores|Pernas|Glúteos").hasMatch(tipo)) {
      grupos = ["Pernas","Glúteos","Abdômen"];
    } else if (RegExp("Superiores").hasMatch(tipo)) {
      grupos = ["Peito","Costas","Ombros","Bíceps","Tríceps","Abdômen"];
    } else if (RegExp("Abdômen").hasMatch(tipo)) {
      grupos = ["Abdômen"];
    }

    if (focoGrupos.isNotEmpty) {
      final set = {...focoGrupos, ...grupos};
      grupos = set.toList();
    }

    final pick = (String g) {
      final pool = _filtrar(g);
      pool.shuffle();
      return pool.take(2).toList();
    };

    final List<_ExCat> selecionados = [];
    for (final g in grupos) { selecionados.addAll(pick(g)); }

    final limite = tempoSessao <= 40 ? 5 : (tempoSessao <= 55 ? 6 : 7);
    final vistos = <String>{};
    final recorte = <_ExCat>[];
    for (final e in selecionados) {
      if (vistos.add(e.nome)) recorte.add(e);
      if (recorte.length >= limite) break;
    }

    final presc = _prescricaoAtual();
    return recorte.map((e) => {
      "grupo": e.grupo,
      "nome": e.nome,
      "series": presc["series"],
      "reps": presc["reps"],
      "pausa": presc["pausa"],
    }).toList();
  }

  void _gerarPlano() {
    final nomes = _dividirSessoes(sessoes);
    final estrutura = <Map<String, dynamic>>[];
    for (var i = 0; i < nomes.length; i++) {
      estrutura.add({
        "id": i + 1,
        "nome": nomes[i],
        "exercicios": _montarSessao(nomes[i]),
      });
    }

    final obj = {
      "nome": (nomeCtrl.text.trim().isEmpty) ? "Treino Auto - $objetivo" : nomeCtrl.text.trim(),
      "objetivo": objetivo,
      "nivel": nivel,
      "sessoes": sessoes,
      "duracaoSemanas": duracaoSemanas,
      "tempoPorSessao": tempoSessao,
      "equipamentos": equipDisp.toList(),
      "focoGrupos": focoGrupos.toList(),
      "restricoes": {"joelho": rJoelho, "ombro": rOmbro, "lombar": rLombar},
      "criado_em": DateTime.now().toIso8601String(),
      "estrutura": estrutura,
    };
    setState(() => plano = obj);
  }

  Future<void> _salvarPlano() async {
    if (plano == null) return;
    final prefs = await SharedPreferences.getInstance();

    // avisa o Dashboard
    await prefs.setString("treino_salvo", jsonEncode({
      "nome": plano!["nome"],
      "data": DateTime.now().toIso8601String(),
    }));

    // histórico
    final historicoRaw = prefs.getString("treinos_gerados");
    final List list = historicoRaw != null ? (jsonDecode(historicoRaw) as List) : [];
    list.add(plano);
    await prefs.setString("treinos_gerados", jsonEncode(list));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Treino salvo!")));
    }
  }

  void _aplicarAgora() async {
    await _salvarPlano();
    if (!mounted) return;
    // navega para Treinos (pode trocar por rota nomeada da sua app)
    // ignore: use_build_context_synchronously
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      // importe a sua TreinosView real se quiser.
      return Scaffold(
        appBar: AppBar(title: const Text('Treinos (preview)')),
        body: const Center(child: Text('Aqui você mostraria seus treinos salvos.')),
      );
    }));
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Gerar Treino')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          // Parâmetros
          _SectionCard(
            title: 'Parâmetros',
            child: Column(
              children: [
                _Grid2(children: [
                  TextField(
                    controller: nomeCtrl,
                    decoration: const InputDecoration(labelText: 'Nome do plano'),
                  ),
                  DropdownButtonFormField<String>(
                    value: objetivo,
                    decoration: const InputDecoration(labelText: 'Objetivo'),
                    items: _PRESC.keys.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                    onChanged: (v) => setState(() => objetivo = v!),
                  ),
                  DropdownButtonFormField<String>(
                    value: nivel,
                    decoration: const InputDecoration(labelText: 'Nível'),
                    items: const ['Iniciante','Intermediário','Avançado']
                        .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                        .toList(),
                    onChanged: (v) => setState(() => nivel = v!),
                  ),
                  DropdownButtonFormField<int>(
                    value: sessoes,
                    decoration: const InputDecoration(labelText: 'Sessões por semana'),
                    items: [2,3,4,5,6].map((n) => DropdownMenuItem(value: n, child: Text('$n'))).toList(),
                    onChanged: (v) => setState(() => sessoes = v!),
                  ),
                  DropdownButtonFormField<int>(
                    value: duracaoSemanas,
                    decoration: const InputDecoration(labelText: 'Duração do ciclo (semanas)'),
                    items: [4,8,12].map((n) => DropdownMenuItem(value: n, child: Text('$n'))).toList(),
                    onChanged: (v) => setState(() => duracaoSemanas = v!),
                  ),
                  DropdownButtonFormField<int>(
                    value: tempoSessao,
                    decoration: const InputDecoration(labelText: 'Tempo por sessão (min)'),
                    items: [30,45,60].map((n) => DropdownMenuItem(value: n, child: Text('$n'))).toList(),
                    onChanged: (v) => setState(() => tempoSessao = v!),
                  ),
                ]),
                const SizedBox(height: 12),

                // Equipamentos
                _SubBlock(
                  title: 'Equipamentos disponíveis',
                  subtitle: 'Selecione só o que você tem acesso.',
                  child: Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _EQUIP.map((eq) => FilterChip(
                      label: Text(eq),
                      selected: equipDisp.contains(eq),
                      onSelected: (_) => setState(() {
                        if (equipDisp.contains(eq)) { equipDisp.remove(eq); } else { equipDisp.add(eq); }
                      }),
                    )).toList(),
                  ),
                ),

                // Foco
                _SubBlock(
                  title: 'Grupos de foco (opcional)',
                  subtitle: 'Ex.: selecionar “Glúteos” prioriza esse grupo nas sessões.',
                  child: Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _GRUPOS.map((g) => FilterChip(
                      label: Text(g),
                      selected: focoGrupos.contains(g),
                      onSelected: (_) => setState(() {
                        if (focoGrupos.contains(g)) { focoGrupos.remove(g); } else { focoGrupos.add(g); }
                      }),
                    )).toList(),
                  ),
                ),

                // Restrições
                _SubBlock(
                  title: 'Restrições',
                  child: Wrap(
                    spacing: 16,
                    children: [
                      _Chk(label: 'Joelho', value: rJoelho, onChanged: (v) => setState(() => rJoelho = v)),
                      _Chk(label: 'Ombro', value: rOmbro, onChanged: (v) => setState(() => rOmbro = v)),
                      _Chk(label: 'Lombar', value: rLombar, onChanged: (v) => setState(() => rLombar = v)),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: _gerarPlano,
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text('Gerar plano'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Preview
          if (plano != null) _SectionCard(
            title: 'Preview do plano',
            trailing: Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _salvarPlano,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Salvar'),
                ),
                OutlinedButton.icon(
                  onPressed: _aplicarAgora,
                  icon: const Icon(Icons.rocket_launch_outlined),
                  label: const Text('Aplicar agora'),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${plano!['nome']}",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  "${plano!['objetivo']} • ${plano!['nivel']} • ${plano!['sessoes']} sessões/sem • "
                  "${plano!['tempoPorSessao']} min/sessão • ${plano!['duracaoSemanas']} semanas",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                ...List<Widget>.from((plano!['estrutura'] as List).map((sessao) {
                  final nome = sessao['nome'];
                  final exs = sessao['exercicios'] as List;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                      childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      title: Text('• $nome', style: Theme.of(context).textTheme.titleMedium),
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Grupo')),
                              DataColumn(label: Text('Exercício')),
                              DataColumn(label: Text('Séries')),
                              DataColumn(label: Text('Reps')),
                              DataColumn(label: Text('Pausa')),
                            ],
                            rows: exs.map<DataRow>((ex) => DataRow(cells: [
                              DataCell(Text('${ex['grupo']}')),
                              DataCell(Text('${ex['nome']}')),
                              DataCell(Text('${ex['series']}')),
                              DataCell(Text('${ex['reps']}')),
                              DataCell(Text('${ex['pausa']}')),
                            ])).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                })),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===== widgets de apoio =====
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  const _SectionCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Grid2 extends StatelessWidget {
  final List<Widget> children;
  const _Grid2({required this.children});
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 480;
    final cols = wide ? 2 : 1;
    return GridView.count(
      crossAxisCount: cols,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: wide ? 3.2 : 2.8,
      children: children,
    );
  }
}

class _SubBlock extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  const _SubBlock({required this.title, this.subtitle, required this.child});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        if (subtitle != null) Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _Chk extends StatelessWidget {
  final String label; final bool value; final ValueChanged<bool> onChanged;
  const _Chk({required this.label, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(value: value, onChanged: (v) => onChanged(v ?? false)),
        Text(label),
      ],
    );
  }
}
