// lib/data/models/habito_model.dart

class Habito {
  final int? id;
  final String nome;
  final String? descricao;
  final String tipoMeta;
  final String? metaValor;
  final bool ativo;

  final String? dataInicio;
  final String? dataTermino;

  final bool itemLembrete;
  final String? horaLembrete;

  Habito({
    this.id,
    required this.nome,
    this.descricao,
    required this.tipoMeta,
    this.metaValor,
    required this.ativo,
    this.dataInicio,
    this.dataTermino,
    this.itemLembrete = false,
    this.horaLembrete,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'tipoMeta': tipoMeta,
      'metaValor': metaValor,
      'ativo': ativo ? 1 : 0,
      'dataInicio': dataInicio,
      'dataTermino': dataTermino,
      'itemLembrete': itemLembrete ? 1 : 0,
      'horaLembrete': horaLembrete,
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
      dataInicio: map['dataInicio'] as String?,
      dataTermino: map['dataTermino'] as String?,
      itemLembrete: map['itemLembrete'] == 1,
      horaLembrete: map['horaLembrete'] as String?,
    );
  }
}
