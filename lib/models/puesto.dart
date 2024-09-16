// lib/models/puesto.dart
class Puesto {
  final String id;
  final String codigo;
  String nombreResponsable;
  String apellidoResponsable;

  Puesto({
    required this.id,
    required this.codigo,
    required this.nombreResponsable,
    required this.apellidoResponsable,
  });

  factory Puesto.fromJson(Map<String, dynamic> json) {
    return Puesto(
      id: json['id'],
      codigo: json['codigo'],
      nombreResponsable: json['nombreResponsable'],
      apellidoResponsable: json['apellidoResponsable'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'nombreResponsable': nombreResponsable,
      'apellidoResponsable': apellidoResponsable,
    };
  }
}
