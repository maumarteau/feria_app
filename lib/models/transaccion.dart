import 'puesto.dart';

class Transaccion {
  final Puesto puesto;
  final bool asistio;
  final Map<String, bool> conceptosPagados;
  final int totalPagado;

  Transaccion({
    required this.puesto,
    required this.asistio,
    required this.conceptosPagados,
    required this.totalPagado,
  });

  factory Transaccion.fromJson(Map<String, dynamic> json) {
    return Transaccion(
      puesto: Puesto.fromJson(json['puesto']),
      asistio: json['asistio'],
      conceptosPagados: Map<String, bool>.from(json['conceptosPagados']),
      totalPagado: json['totalPagado'],
    );
  }

  Map<String, dynamic> toJson() => {
        'puesto': puesto.toJson(),
        'asistio': asistio,
        'conceptosPagados': conceptosPagados,
        'totalPagado': totalPagado,
      };
}
