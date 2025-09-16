import 'package:flutter/material.dart';
import 'exercicio.dart';

@immutable
class Sessao {
  final int id;
  final String nome;
  final List<Exercicio> exercicios;

  const Sessao({
    required this.id,
    required this.nome,
    required this.exercicios,
  });
}

