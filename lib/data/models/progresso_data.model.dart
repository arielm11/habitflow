// lib/data/models/progresso_data.model.dart

import 'package:habitflow/data/models/habito_model.dart';

/// Agrupa um hábito com seu progresso calculado.
class ProgressoData {
  final Habito habito;
  final int metaDias;
  final int diasConcluidos;

  ProgressoData({
    required this.habito,
    required this.metaDias,
    required this.diasConcluidos,
  });
}