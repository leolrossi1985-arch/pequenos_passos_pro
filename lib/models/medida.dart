class Medida {
  final String id;
  final DateTime data;
  final double peso; // em Kg
  final double altura; // em cm

  Medida({
    required this.id,
    required this.data,
    required this.peso,
    required this.altura,
  });

  factory Medida.fromMap(String id, Map<String, dynamic> map) {
    return Medida(
      id: id,
      data: DateTime.parse(map['data']),
      peso: (map['peso'] as num).toDouble(),
      altura: (map['altura'] as num).toDouble(),
    );
  }
}