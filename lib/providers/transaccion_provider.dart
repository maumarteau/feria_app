// lib/providers/transaccion_provider.dart
import 'package:feria_app/models/concepto_transaccion.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaccion.dart';
import '../models/puesto.dart';

class TransaccionProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Transaccion> _transacciones = [];

  List<Transaccion> get transacciones => _transacciones;

  TransaccionProvider() {
    _loadFromFirestore();
  }

  void _loadFromFirestore() {
    _firestore.collection('fairs').snapshots().listen((feriaSnapshot) {
      List<Transaccion> loadedTransacciones = [];
      for (var feriaDoc in feriaSnapshot.docs) {
        String feriaId = feriaDoc['id'];
        // Listen to stands subcollection
        _firestore
            .collection('fairs')
            .doc(feriaDoc.id)
            .collection('stands')
            .snapshots()
            .listen((standSnapshot) {
          for (var standDoc in standSnapshot.docs) {
            Puesto puesto = Puesto(
              id: standDoc['id'],
              codigo: standDoc['codigo'],
              nombreResponsable: standDoc['nombreResponsable'],
              apellidoResponsable: standDoc['apellidoResponsable'],
            );

            _firestore
                .collection('fairs')
                .doc(feriaDoc.id)
                .collection('stands')
                .doc(standDoc.id)
                .collection('payments')
                .snapshots()
                .listen((paymentSnapshot) {
              for (var paymentDoc in paymentSnapshot.docs) {
                Transaccion transaccion = Transaccion(
                  id: paymentDoc.id,
                  feriaId: feriaId,
                  puesto: puesto,
                  asistio: paymentDoc['isPaid'],
                  conceptos: [
                    ConceptoTransaccion(
                      id: paymentDoc.id,
                      name: paymentDoc['concept']['name'],
                      isPaid: paymentDoc['concept']['isPaid'],
                      amount: paymentDoc['concept']['amount'],
                      date: paymentDoc['concept']['date'] != null
                          ? DateTime.parse(paymentDoc['concept']['date'])
                          : DateTime.parse(paymentDoc['createdAt']),
                    ),
                  ],
                  totalPagado: paymentDoc['isPaid']
                      ? paymentDoc['concept']['amount']
                      : 0,
                  fechaCreacion: DateTime.parse(paymentDoc['createdAt']),
                );
                loadedTransacciones.add(transaccion);
                notifyListeners();
              }
            });
          }
        });
      }
      _transacciones = loadedTransacciones;
      notifyListeners();
    });
  }

  Future<List<Transaccion>> getTransaccionesForToday(
      String feriaId, Puesto puesto) async {
    DateTime hoy = DateTime.now();
    QuerySnapshot query = await _firestore
        .collection('fairs')
        .doc(feriaId)
        .collection('stands')
        .doc(puesto.id)
        .collection('payments')
        .where('createdAt',
            isGreaterThanOrEqualTo:
                DateTime(hoy.year, hoy.month, hoy.day).toIso8601String())
        .where('createdAt',
            isLessThan:
                DateTime(hoy.year, hoy.month, hoy.day + 1).toIso8601String())
        .get();

    List<Transaccion> transacciones = [];

    for (var doc in query.docs) {
      transacciones.add(Transaccion(
        id: doc.id,
        feriaId: feriaId,
        puesto: puesto,
        asistio: doc['isPaid'],
        conceptos: [
          ConceptoTransaccion(
            id: doc.id,
            name: doc['concept']['name'],
            isPaid: doc['concept']['isPaid'],
            amount: doc['concept']['amount'],
            date: doc['concept']['date'] != null
                ? DateTime.parse(doc['concept']['date'])
                : DateTime.parse(doc['createdAt']),
          ),
        ],
        totalPagado: doc['isPaid'] ? doc['concept']['amount'] : 0,
        fechaCreacion: DateTime.parse(doc['createdAt']),
      ));
    }

    return transacciones;
  }

  Future<void> agregarTransaccion(String feriaId, String puestoId, String name,
      int amount, bool isPaid, DateTime date) async {
    CollectionReference ferias = _firestore.collection('fairs');
    QuerySnapshot feriaSnapshot =
        await ferias.where('id', isEqualTo: feriaId).get();

    if (feriaSnapshot.docs.isEmpty) return;

    var feriaDoc = feriaSnapshot.docs.first;

    CollectionReference stands = ferias.doc(feriaDoc.id).collection('stands');

    QuerySnapshot standSnapshot =
        await stands.where('id', isEqualTo: puestoId).get();

    if (standSnapshot.docs.isEmpty) return;

    var standDoc = standSnapshot.docs.first;

    CollectionReference payments =
        stands.doc(standDoc.id).collection('payments');

    print(
        'Adding payment to $feriaId, $puestoId, $name, $amount, $isPaid, $date');

    DocumentReference newPayment = await payments.add({
      'createdAt': DateTime.now().toIso8601String(),
      'concept': {
        'name': name,
        'isPaid': isPaid,
        'amount': amount,
        'date': date.toIso8601String(),
      },
      'amount': amount,
      'isPaid': isPaid,
      'paidAt': isPaid ? DateTime.now().toIso8601String() : null,
      'chargedBy': 'system', // replace with actual user if available
    });

    // Firestore snapshots will handle updating the list
  }

  Future<void> actualizarTransaccion(String feriaId, String puestoId,
      String transactionId, bool isPaid) async {
    print('actualizarTransaccion $feriaId, $puestoId, $transactionId, $isPaid');

    // Get the payment document from fairs/{feriaId}/stands/{puestoId}/payments/{transactionId}
    DocumentReference paymentDoc = _firestore
        .collection('fairs')
        .doc(feriaId)
        .collection('stands')
        .doc(puestoId)
        .collection('payments')
        .doc(transactionId);

    await paymentDoc.update({
      'isPaid': isPaid,
      'concept.isPaid': isPaid,
      'paidAt': isPaid ? DateTime.now().toIso8601String() : null,
    });
  }

  Future<void> eliminarTransaccion(
      String feriaId, String puestoId, DateTime fecha) async {
    CollectionReference ferias = _firestore.collection('fairs');
    QuerySnapshot feriaSnapshot =
        await ferias.where('id', isEqualTo: feriaId).get();

    if (feriaSnapshot.docs.isEmpty) return;

    var feriaDoc = feriaSnapshot.docs.first;

    CollectionReference stands = ferias.doc(feriaDoc.id).collection('stands');

    QuerySnapshot standSnapshot =
        await stands.where('id', isEqualTo: puestoId).get();

    if (standSnapshot.docs.isEmpty) return;

    var standDoc = standSnapshot.docs.first;

    CollectionReference payments =
        stands.doc(standDoc.id).collection('payments');

    QuerySnapshot paymentSnapshot = await payments
        .where('createdAt', isEqualTo: fecha.toIso8601String())
        .get();

    if (paymentSnapshot.docs.isEmpty) return;

    var paymentDoc = paymentSnapshot.docs.first;

    await payments.doc(paymentDoc.id).delete();
  }
}
