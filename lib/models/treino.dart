// lib/models/treino.dart
enum TreinoStatus { ativo, futuro, expirado }

class Treino {
  final int id;
  final String nome;
  final DateTime criadoEm;
  final DateTime? vigenciaInicio;
  final DateTime? vigenciaFim;
  final bool favorito;

  Treino({
    required this.id,
    required this.nome,
    required this.criadoEm,
    this.vigenciaInicio,
    this.vigenciaFim,
    this.favorito = false,
  });

  Treino copyWith({
    int? id,
    String? nome,
    DateTime? criadoEm,
    DateTime? vigenciaInicio,
    DateTime? vigenciaFim,
    bool? favorito,
  }) => Treino(
        id: id ?? this.id,
        nome: nome ?? this.nome,
        criadoEm: criadoEm ?? this.criadoEm,
        vigenciaInicio: vigenciaInicio ?? this.vigenciaInicio,
        vigenciaFim: vigenciaFim ?? this.vigenciaFim,
        favorito: favorito ?? this.favorito,
      );

  TreinoStatus get status {
    final now = DateTime.now();
    if (vigenciaInicio == null || vigenciaFim == null) return TreinoStatus.ativo;
    if (now.isBefore(DateTime(vigenciaInicio!.year, vigenciaInicio!.month, vigenciaInicio!.day))) return TreinoStatus.futuro;
    if (now.isAfter(DateTime(vigenciaFim!.year, vigenciaFim!.month, vigenciaFim!.day, 23, 59, 59))) return TreinoStatus.expirado;
    return TreinoStatus.ativo;
  }

  String get periodoFormatado =>
      (vigenciaInicio == null || vigenciaFim == null)
          ? 'Sem vigência'
          : '${fmtDate(vigenciaInicio!)} – ${fmtDate(vigenciaFim!)}';

  static String fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    return '$dd/$mm/$yy';
  }
}
