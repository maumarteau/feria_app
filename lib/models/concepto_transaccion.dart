// lib/models/concepto_transaccion.dart
class ConceptoTransaccion {
  final String id;
  final String name;
  bool isPaid;
  final int amount;
  final DateTime date;

  ConceptoTransaccion({
    required this.id,
    required this.name,
    required this.isPaid,
    required this.amount,
    required this.date,
  });

  factory ConceptoTransaccion.fromJson(Map<String, dynamic> json) {
    return ConceptoTransaccion(
      id: json['id'],
      name: json['name'],
      isPaid: json['isPaid'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isPaid': isPaid,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
}
