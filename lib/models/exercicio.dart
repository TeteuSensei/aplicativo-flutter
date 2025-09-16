import 'package:flutter/material.dart';

@immutable
class Exercicio {
  final String nome;
  final int series;
  final int reps;        // reps por série (genérico)
  final double? carga;   // kg opcional
  final int? descanso;   // segundos
  final String? obs;

  const Exercicio({
    required this.nome,
    required this.series,
    required this.reps,
    this.carga,
    this.descanso,
    this.obs,
  });

  const Exercicio.simples(
    this.nome, {
    this.series = 3,
    this.reps = 12,
    this.carga,
    this.descanso = 60,
    this.obs,
  });
}
