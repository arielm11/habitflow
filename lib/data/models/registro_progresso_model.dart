// lib/data/models/registro_progresso_model.dart

class RegistroProgresso {
  int? id;
  final int habitoId;
  final DateTime data;

  // --- IMPLEMENTAÇÃO ---
  // Adicionamos um campo para guardar o valor numérico do progresso.
  // Usamos 'double' para permitir valores decimais (ex: 1.5 litros).
  final double progressoAtual;

  RegistroProgresso({
    this.id,
    required this.habitoId,
    required this.data,
    required this.progressoAtual, // O construtor agora exige o progresso.
  });

  /// Converte o objeto Dart em um Map para ser salvo no banco de dados.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitoId': habitoId,
      'data': data.toIso8601String().substring(0, 10), // Formato AAAA-MM-DD
      'progressoAtual': progressoAtual, // Incluímos o novo campo no mapa.
    };
  }

  /// Cria um objeto a partir de um Map vindo do banco de dados.
  factory RegistroProgresso.fromMap(Map<String, dynamic> map) {
    return RegistroProgresso(
      id: map['id'],
      habitoId: map['habitoId'],
      data: DateTime.parse(map['data']),
      // --- IMPLEMENTAÇÃO ---
      // Lemos o valor do progresso do banco.
      // (map['progressoAtual'] as num?)?.toDouble() é uma forma segura de converter
      // o número do banco para double. Se o valor for nulo por algum motivo,
      // '?? 0.0' garante que o valor padrão seja 0.
      progressoAtual: (map['progressoAtual'] as num?)?.toDouble() ?? 0.0,
    );
  }
}