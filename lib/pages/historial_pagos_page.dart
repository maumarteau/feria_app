// lib/pages/historial_pagos_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/puesto.dart';
import '../models/transaccion.dart';
import '../providers/transaccion_provider.dart';

class HistorialPagosPage extends StatelessWidget {
  final String feriaId;
  final Puesto puesto;

  const HistorialPagosPage({
    super.key,
    required this.feriaId,
    required this.puesto,
  });

  String _formatDate(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Historial de Pagos', style: TextStyle(fontSize: 18.0)),
      ),
      body: FutureBuilder<List<Transaccion>>(
        future: Provider.of<TransaccionProvider>(context, listen: false)
            .getTransaccionesByStand(feriaId, puesto),
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
              child: Text('No hay pagos registrados para este puesto.'),
            );
          }

          return ListView.builder(
            itemCount: transacciones.length,
            itemBuilder: (context, index) {
              final transaccion = transacciones[index];
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[300]!,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListTile(
                        leading: Icon(
                          transaccion.asistio
                              ? Icons.check_circle
                              : Icons.error,
                          color:
                              transaccion.asistio ? Colors.green : Colors.red,
                        ),
                        title: Text(
                          transaccion.concepto.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Fecha: ${_formatDate(transaccion.fechaCreacion)}'),
                            Text(
                                'Fecha de pago: ${_formatDate(transaccion.concepto.date)}'),
                          ],
                        ),
                        trailing: Text(
                          '\$${transaccion.concepto.amount}',
                          style: const TextStyle(
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
