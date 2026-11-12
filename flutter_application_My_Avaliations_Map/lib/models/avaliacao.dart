class Avaliacao {
  const Avaliacao({
    this.id,
    required this.apelido,
    required this.comentario,
    required this.nota,
    required this.latitude,
    required this.longitude,
  });

  final int? id;
  final String apelido;
  final String comentario;
  final int nota;
  final double latitude;
  final double longitude;

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'apelido': apelido,
      'comentario': comentario,
      'nota': nota,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Avaliacao.fromMap(Map<String, Object?> map) {
    return Avaliacao(
      id: map['id'] as int,
      apelido: map['apelido'] as String,
      comentario: map['comentario'] as String,
      nota: map['nota'] as int,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
    );
  }
}
