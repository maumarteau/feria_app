// lib/models/feria.dart
import 'package:feria_app/models/puesto.dart';

class Feria {
  final String id;
  final String nombre;
  final String descripcion;
  final List<Puesto> puestos;

  Feria({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.puestos,
  });

  factory Feria.fromJson(Map<String, dynamic> json) {
    return Feria(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      puestos: (json['puestos'] as List<dynamic>)
          .map((e) => Puesto.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'descripcion': descripcion,
        'puestos': puestos.map((e) => e.toJson()).toList(),
      };
}
