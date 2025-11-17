// lib/data/models/registro_progresso_model.dart

class RegistroProgresso {
  int? id;
  final int habitoId;
  final DateTime data;
  final double progressoAtual;

  RegistroProgresso({
    this.id,
    required this.habitoId,
    required this.data,
    required this.progressoAtual,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitoId': habitoId,
      'data': data.toIso8601String().substring(0, 10),
      'progressoAtual': progressoAtual,
    };
  }

  factory RegistroProgresso.fromMap(Map<String, dynamic> map) {
    return RegistroProgresso(
      id: map['id'],
      habitoId: map['habitoId'],
      data: DateTime.parse(map['data']),
      progressoAtual: (map['progressoAtual'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
