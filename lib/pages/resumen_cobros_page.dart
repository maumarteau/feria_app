import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaccion_provider.dart';
import '../models/transaccion.dart';

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
      body: Consumer<TransaccionProvider>(
        builder: (context, transaccionProvider, child) {
          List<Transaccion> transacciones = transaccionProvider.transacciones;

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
                        transaccionProvider,
                        transaccion.feriaId,
                        transaccion.puesto.id,
                        transaccion.fechaCreacion,
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
                          ...transaccion.conceptos.map((concepto) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ListTile(
                                title: Text(
                                  concepto.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  'Fecha: ${_formatDate(concepto.date)}',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.grey,
                                  ),
                                ),
                                trailing: Text(
                                  '\$${concepto.amount}',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                            );
                          }),
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

  void _confirmDelete(BuildContext context, TransaccionProvider provider,
      String feriaId, String puestoId, DateTime fecha) {
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
              onPressed: () {
                provider.eliminarTransaccion(feriaId, puestoId, fecha);
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
