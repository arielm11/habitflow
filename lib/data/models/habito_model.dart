// lib/data/models/habito_model.dart

class Habito {
  final int? id;
  final String nome;
  final String? descricao;
  final String tipoMeta;
  final String? metaValor;
  final bool ativo;

  // --- MUDANÇA 1: Adicionar os campos de data ---
  final String? data_inicio; // Formato 'AAAA-MM-DD'
  final String? data_termino; // Formato 'AAAA-MM-DD', pode ser nulo

  Habito({
    this.id,
    required this.nome,
    this.descricao,
    required this.tipoMeta,
    this.metaValor,
    required this.ativo,
    // --- MUDANÇA 2: Adicionar ao construtor ---
    this.data_inicio,
    this.data_termino,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'tipoMeta': tipoMeta,
      'metaValor': metaValor,
      'ativo': ativo ? 1 : 0,
      // --- MUDANÇA 3: Adicionar ao mapa para salvar no DB ---
      'data_inicio': data_inicio,
      'data_termino': data_termino,
    };
  }

  factory Habito.fromMap(Map<String, dynamic> map) {
    return Habito(
      id: map['id'],
      nome: map['nome'],
      descricao: map['descricao'],
      tipoMeta: map['tipoMeta'],
      metaValor: map['metaValor'],
      ativo: map['ativo'] == 1,
      // --- MUDANÇA 4: Ler do mapa vindo do DB ---
      data_inicio: map['data_inicio'] as String?,
      data_termino: map['data_termino'] as String?,
    );
  }
}