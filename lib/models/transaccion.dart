// lib/models/transaccion.dart
import 'puesto.dart';
import 'concepto_transaccion.dart';

class Transaccion {
  final String id;
  final String feriaId;
  final Puesto puesto;
  bool asistio;
  List<ConceptoTransaccion> conceptos;
  int totalPagado;
  DateTime fechaCreacion;

  Transaccion({
    required this.id,
    required this.feriaId,
    required this.puesto,
    required this.asistio,
    required this.conceptos,
    required this.totalPagado,
    required this.fechaCreacion,
  });

  factory Transaccion.fromJson(Map<String, dynamic> json) {
    return Transaccion(
      id: json['id'],
      feriaId: json['feriaId'],
      puesto: Puesto.fromJson(json['puesto']),
      asistio: json['asistio'],
      conceptos: (json['conceptos'] as List)
          .map((c) => ConceptoTransaccion.fromJson(c))
          .toList(),
      totalPagado: json['totalPagado'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'feriaId': feriaId,
      'puesto': puesto.toJson(),
      'asistio': asistio,
      'conceptos': conceptos.map((c) => c.toJson()).toList(),
      'totalPagado': totalPagado,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }
}
