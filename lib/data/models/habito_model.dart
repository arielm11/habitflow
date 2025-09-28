class Habito {
  // Atributos
  int? id;
  String nome;
  String? descricao;
  String tipoMeta;
  String? metaValor;
  bool ativo;

  // Construtor
  Habito({
    this.id,
    required this.nome,
    this.descricao,
    required this.tipoMeta,
    this.metaValor,
    required this.ativo,
  });

  // BD
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'tipoMeta': tipoMeta,
      'metaValor': metaValor,
      'ativo': ativo ? 1 : 0,
    };
  }

  // Convertendo o Map para um objeto
  factory Habito.fromMap(Map<String, dynamic> map) {
    return Habito(
        id: map['id'],
        nome: map['nome'],
        tipoMeta: map['tipoMeta'],
        descricao: map['descricao'],
        metaValor: map['metaValor'],
        ativo: map['ativo'] == 1);
  }
}
