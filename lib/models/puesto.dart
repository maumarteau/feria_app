class Puesto {
  final int id;
  final String nombre;
  String? nombreResponsable;
  String? apellidoResponsable;

  Puesto({
    required this.id,
    required this.nombre,
    this.nombreResponsable,
    this.apellidoResponsable,
  });

  factory Puesto.fromJson(Map<String, dynamic> json) {
    return Puesto(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      nombreResponsable: json['nombreResponsable'] ?? '',
      apellidoResponsable: json['apellidoResponsable'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'nombreResponsable': nombreResponsable ?? '',
        'apellidoResponsable': apellidoResponsable ?? '',
      };
}
