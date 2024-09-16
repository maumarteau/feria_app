// lib/pages/resumen_cobros_page.dart
import 'package:feria_app/models/concepto_transaccion.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this line
import '../providers/transaccion_provider.dart';
import '../models/transaccion.dart';
import '../models/puesto.dart';

class ResumenCobrosPage extends StatelessWidget {
  final int precioConcepto1 = 130;
  final int precioConcepto2 = 300;

  const ResumenCobrosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Resumen de Cobros', style: TextStyle(fontSize: 18.0)),
      ),
      body: FutureBuilder<List<Transaccion>>(
        future: _fetchAllTransacciones(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          List<Transaccion> transacciones = snapshot.data ?? [];

          if (transacciones.isEmpty) {
            return const Center(
              child: Text('No hay transacciones registradas.'),
            );
          }

          return ListView.builder(
            itemCount: transacciones.length,
            itemBuilder: (context, index) {
              final transaccion = transacciones[index];
              return ExpansionTile(
                title: Text(
                  'Feria ID: ${transaccion.feriaId} - ${transaccion.puesto.codigo}',
                ),
                subtitle: Text(
                  'Responsable: ${transaccion.puesto.nombreResponsable} ${transaccion.puesto.apellidoResponsable}',
                ),
                leading: Icon(
                  _getIconoTransaccion(transaccion),
                  color: _getColorTransaccion(transaccion),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_getEstadoTransaccion(transaccion)),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(
                        context,
                        transaccionProvider: Provider.of<TransaccionProvider>(
                            context,
                            listen: false),
                        feriaId: transaccion.feriaId,
                        puestoId: transaccion.puesto.id,
                        transactionId: transaccion.id,
                      ),
                    ),
                  ],
                ),
                children: [
                  if (transaccion.asistio)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Conceptos Pagados:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ListTile(
                              title: Text(
                                transaccion.concepto.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                'Fecha: ${_formatDate(transaccion.concepto.date)}',
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey,
                                ),
                              ),
                              trailing: Text(
                                '\$${transaccion.concepto.amount}',
                                style: const TextStyle(
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Total Pagado: \$${transaccion.totalPagado}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Transaccion>> _fetchAllTransacciones(BuildContext context) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    // Implement a method in provider to fetch all transactions
    // For simplicity, assuming there is a method getAllTransacciones
    // Otherwise, you need to implement it
    // Here, we'll fetch all transacciones by iterating through all fairs and stands
    // This is not optimal and should be optimized based on actual data structure
    List<Transaccion> allTransacciones = [];
    QuerySnapshot fairsSnapshot = await firestore.collection('fairs').get();

    for (var feriaDoc in fairsSnapshot.docs) {
      String feriaId = feriaDoc['id'];
      QuerySnapshot standsSnapshot = await firestore
          .collection('fairs')
          .doc(feriaDoc.id)
          .collection('stands')
          .get();

      for (var standDoc in standsSnapshot.docs) {
        Puesto puesto = Puesto(
          id: standDoc['id'],
          codigo: standDoc['code'],
          nombreResponsable: standDoc['responsibleName'],
          apellidoResponsable: standDoc['responsibleLastname'],
        );

        QuerySnapshot paymentsSnapshot = await firestore
            .collection('fairs')
            .doc(feriaDoc.id)
            .collection('stands')
            .doc(standDoc.id)
            .collection('payments')
            .orderBy('createdAt', descending: true)
            .get();

        for (var paymentDoc in paymentsSnapshot.docs) {
          Transaccion transaccion = Transaccion(
            id: paymentDoc.id,
            feriaId: feriaId,
            puesto: puesto,
            asistio: paymentDoc['isPaid'],
            concepto: ConceptoTransaccion(
              id: paymentDoc.id,
              name: paymentDoc['concept']['name'],
              isPaid: paymentDoc['concept']['isPaid'],
              amount: paymentDoc['concept']['amount'],
              date: paymentDoc['concept']['date'] != null
                  ? DateTime.parse(paymentDoc['concept']['date'])
                  : DateTime.parse(paymentDoc['createdAt']),
            ),
            totalPagado:
                paymentDoc['isPaid'] ? paymentDoc['concept']['amount'] : 0,
            fechaCreacion: DateTime.parse(paymentDoc['createdAt']),
          );
          allTransacciones.add(transaccion);
        }
      }
    }

    return allTransacciones;
  }

  String _getEstadoTransaccion(Transaccion transaccion) {
    if (!transaccion.asistio) return 'No Asistió';
    if (transaccion.totalPagado > 0) return 'Pagó \$${transaccion.totalPagado}';
    return 'No Pagó';
  }

  IconData _getIconoTransaccion(Transaccion transaccion) {
    if (!transaccion.asistio) return Icons.event_busy;
    return transaccion.totalPagado > 0 ? Icons.check_circle : Icons.error;
  }

  Color _getColorTransaccion(Transaccion transaccion) {
    if (!transaccion.asistio) return Colors.grey;
    return transaccion.totalPagado > 0 ? Colors.green : Colors.red;
  }

  void _confirmDelete(BuildContext context,
      {required TransaccionProvider transaccionProvider,
      required String feriaId,
      required String puestoId,
      required String transactionId}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Cobro'),
          content:
              const Text('¿Estás seguro de que deseas eliminar este cobro?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () async {
                await transaccionProvider.eliminarTransaccion(
                    feriaId, puestoId, transactionId);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cobro eliminado exitosamente.'),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }
}
