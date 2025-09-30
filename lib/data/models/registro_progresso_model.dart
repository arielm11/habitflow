class RegistroProgresso {
  int? id;
  final int habitoId;
  final DateTime data;

  RegistroProgresso({
    this.id,
    required this.habitoId,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitoId': habitoId,
      'data': data.toIso8601String().substring(0, 10),
    };
  }

  factory RegistroProgresso.fromMap(Map<String, dynamic> map) {
    return RegistroProgresso(
      id: map['id'],
      habitoId: map['habitoId'],
      data: DateTime.parse(map['data']),
    );
  }
}
