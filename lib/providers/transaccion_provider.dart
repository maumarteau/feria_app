// lib/providers/transaccion_provider.dart
import 'package:feria_app/models/concepto_transaccion.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaccion.dart';
import '../models/puesto.dart';

class TransaccionProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TransaccionProvider();

  // Filtrar transacciones por stand
  Future<List<Transaccion>> getTransaccionesByStand(
      String feriaId, Puesto puesto) async {
    QuerySnapshot feriaSnapshot = await _firestore
        .collection('fairs')
        .where('id', isEqualTo: feriaId)
        .get();

    if (feriaSnapshot.docs.isEmpty) return [];

    var feriaDoc = feriaSnapshot.docs.first;

    QuerySnapshot standSnapshot = await _firestore
        .collection('fairs')
        .doc(feriaDoc.id)
        .collection('stands')
        .where('id', isEqualTo: puesto.id)
        .get();

    if (standSnapshot.docs.isEmpty) return [];

    var standDoc = standSnapshot.docs.first;

    QuerySnapshot paymentDocs = await _firestore
        .collection('fairs')
        .doc(feriaDoc.id)
        .collection('stands')
        .doc(standDoc.id)
        .collection('payments')
        .orderBy('createdAt', descending: true)
        .get();

    List<Transaccion> transacciones = paymentDocs.docs.map((doc) {
      return Transaccion(
        id: doc.id,
        feriaId: feriaId,
        puesto: puesto,
        asistio: doc['isPaid'],
        concepto: ConceptoTransaccion(
          id: doc.id,
          name: doc['concept']['name'],
          isPaid: doc['concept']['isPaid'],
          amount: doc['concept']['amount'],
          date: doc['concept']['date'] != null
              ? DateTime.parse(doc['concept']['date'])
              : DateTime.parse(doc['createdAt']),
        ),
        totalPagado: doc['isPaid'] ? doc['concept']['amount'] : 0,
        fechaCreacion: DateTime.parse(doc['createdAt']),
      );
    }).toList();

    return transacciones;
  }

  // Filtrar transacciones para hoy
  Future<List<Transaccion>> getTransaccionesForToday(
      String feriaId, Puesto puesto) async {
    DateTime hoy = DateTime.now();
    DateTime inicioDia = DateTime(hoy.year, hoy.month, hoy.day);
    DateTime finDia = inicioDia.add(const Duration(days: 1));

    QuerySnapshot feriaSnapshot = await _firestore
        .collection('fairs')
        .where('id', isEqualTo: feriaId)
        .get();

    if (feriaSnapshot.docs.isEmpty) return [];

    var feriaDoc = feriaSnapshot.docs.first;

    QuerySnapshot standSnapshot = await _firestore
        .collection('fairs')
        .doc(feriaDoc.id)
        .collection('stands')
        .where('id', isEqualTo: puesto.id)
        .get();

    if (standSnapshot.docs.isEmpty) return [];

    var standDoc = standSnapshot.docs.first;

    QuerySnapshot paymentDocs = await _firestore
        .collection('fairs')
        .doc(feriaDoc.id)
        .collection('stands')
        .doc(standDoc.id)
        .collection('payments')
        .where('createdAt', isGreaterThanOrEqualTo: inicioDia.toIso8601String())
        .where('createdAt', isLessThan: finDia.toIso8601String())
        .get();

    List<Transaccion> transacciones = paymentDocs.docs.map((doc) {
      return Transaccion(
        id: doc.id,
        feriaId: feriaId,
        puesto: puesto,
        asistio: doc['isPaid'],
        concepto: ConceptoTransaccion(
          id: doc.id,
          name: doc['concept']['name'],
          isPaid: doc['concept']['isPaid'],
          amount: doc['concept']['amount'],
          date: doc['concept']['date'] != null
              ? DateTime.parse(doc['concept']['date'])
              : DateTime.parse(doc['createdAt']),
        ),
        totalPagado: doc['isPaid'] ? doc['concept']['amount'] : 0,
        fechaCreacion: DateTime.parse(doc['createdAt']),
      );
    }).toList();

    return transacciones;
  }

  // Filtrar transacciones no pagadas y antiguas
  Future<List<Transaccion>> getTransaccionesUnpaidOld(
      String feriaId, Puesto puesto) async {
    DateTime hoy = DateTime.now();
    DateTime inicioDia = DateTime(hoy.year, hoy.month, hoy.day);

    QuerySnapshot feriaSnapshot = await _firestore
        .collection('fairs')
        .where('id', isEqualTo: feriaId)
        .get();

    if (feriaSnapshot.docs.isEmpty) return [];

    var feriaDoc = feriaSnapshot.docs.first;

    QuerySnapshot standSnapshot = await _firestore
        .collection('fairs')
        .doc(feriaDoc.id)
        .collection('stands')
        .where('id', isEqualTo: puesto.id)
        .get();

    if (standSnapshot.docs.isEmpty) return [];

    var standDoc = standSnapshot.docs.first;

    QuerySnapshot paymentDocs = await _firestore
        .collection('fairs')
        .doc(feriaDoc.id)
        .collection('stands')
        .doc(standDoc.id)
        .collection('payments')
        .where('isPaid', isEqualTo: false)
        .where('createdAt', isLessThan: inicioDia.toIso8601String())
        .get();

    List<Transaccion> transacciones = paymentDocs.docs.map((doc) {
      return Transaccion(
        id: doc.id,
        feriaId: feriaId,
        puesto: puesto,
        asistio: doc['isPaid'],
        concepto: ConceptoTransaccion(
          id: doc.id,
          name: doc['concept']['name'],
          isPaid: doc['concept']['isPaid'],
          amount: doc['concept']['amount'],
          date: doc['concept']['date'] != null
              ? DateTime.parse(doc['concept']['date'])
              : DateTime.parse(doc['createdAt']),
        ),
        totalPagado: doc['isPaid'] ? doc['concept']['amount'] : 0,
        fechaCreacion: DateTime.parse(doc['createdAt']),
      );
    }).toList();

    return transacciones;
  }

  Future<void> agregarTransaccion(String feriaId, String puestoId, String name,
      int amount, bool isPaid, DateTime date) async {
    QuerySnapshot feriaSnapshot = await _firestore
        .collection('fairs')
        .where('id', isEqualTo: feriaId)
        .get();

    if (feriaSnapshot.docs.isEmpty) return;

    var feriaDoc = feriaSnapshot.docs.first;

    QuerySnapshot standSnapshot = await _firestore
        .collection('fairs')
        .doc(feriaDoc.id)
        .collection('stands')
        .where('id', isEqualTo: puestoId)
        .get();

    if (standSnapshot.docs.isEmpty) return;

    var standDoc = standSnapshot.docs.first;

    CollectionReference payments = _firestore
        .collection('fairs')
        .doc(feriaDoc.id)
        .collection('stands')
        .doc(standDoc.id)
        .collection('payments');

    await payments.add({
      'createdAt': DateTime.now().toIso8601String(),
      'concept': {
        'name': name,
        'isPaid': isPaid,
        'amount': amount,
        'date': date.toIso8601String(),
      },
      'isPaid': isPaid,
      'amount': amount,
      'paidAt': isPaid ? DateTime.now().toIso8601String() : null,
      'chargedBy': 'system', // replace with current user if available
    });

    // Firestore snapshots would handle updates
  }

  Future<void> actualizarTransaccion(String feriaId, String puestoId,
      String transactionId, bool isPaid) async {
    QuerySnapshot feriaSnapshot = await _firestore
        .collection('fairs')
        .where('id', isEqualTo: feriaId)
        .get();

    if (feriaSnapshot.docs.isEmpty) return;

    var feriaDoc = feriaSnapshot.docs.first;

    QuerySnapshot standSnapshot = await _firestore
        .collection('fairs')
        .doc(feriaDoc.id)
        .collection('stands')
        .where('id', isEqualTo: puestoId)
        .get();

    if (standSnapshot.docs.isEmpty) return;

    var standDoc = standSnapshot.docs.first;

    DocumentReference paymentDoc = _firestore
        .collection('fairs')
        .doc(feriaDoc.id)
        .collection('stands')
        .doc(standDoc.id)
        .collection('payments')
        .doc(transactionId);

    await paymentDoc.update({
      'isPaid': isPaid,
      'concept.isPaid': isPaid,
      'paidAt': isPaid ? DateTime.now().toIso8601String() : null,
    });
  }

  Future<void> eliminarTransaccion(
      String feriaId, String puestoId, String transactionId) async {
    QuerySnapshot feriaSnapshot = await _firestore
        .collection('fairs')
        .where('id', isEqualTo: feriaId)
        .get();

    if (feriaSnapshot.docs.isEmpty) return;

    var feriaDoc = feriaSnapshot.docs.first;

    QuerySnapshot standSnapshot = await _firestore
        .collection('fairs')
        .doc(feriaDoc.id)
        .collection('stands')
        .where('id', isEqualTo: puestoId)
        .get();

    if (standSnapshot.docs.isEmpty) return;

    var standDoc = standSnapshot.docs.first;

    await _firestore
        .collection('fairs')
        .doc(feriaDoc.id)
        .collection('stands')
        .doc(standDoc.id)
        .collection('payments')
        .doc(transactionId)
        .delete();
  }
}
