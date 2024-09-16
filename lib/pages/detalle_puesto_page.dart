// lib/pages/detalle_puesto_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/puesto.dart';
import '../models/transaccion.dart';
import '../models/concepto_transaccion.dart';
import '../providers/transaccion_provider.dart';
import 'editar_responsable_page.dart';
import 'historial_pagos_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetallePuestoPage extends StatefulWidget {
  final Puesto puesto;
  final String feriaId;

  const DetallePuestoPage({
    super.key,
    required this.puesto,
    required this.feriaId,
  });

  @override
  _DetallePuestoPageState createState() => _DetallePuestoPageState();
}

class _DetallePuestoPageState extends State<DetallePuestoPage> {
  List<Transaccion> transaccionesActuales = [];
  List<Transaccion> transaccionesAdeudadas = [];

  // Nueva lista para conceptos pagados
  List<ConceptoPagar> conceptosPagados = [];

  List<ConceptoPagar> conceptosAPagar = [];
  int total = 0;

  @override
  void initState() {
    super.initState();
    conceptosAPagar = [];
    conceptosPagados = [];
    _cargarTransaccionesImpagas();
    _cargarTransaccionesActuales();
  }

  Future<void> _cargarTransaccionesActuales() async {
    TransaccionProvider transaccionProvider =
        Provider.of<TransaccionProvider>(context, listen: false);
    transaccionesActuales = await transaccionProvider.getTransaccionesForToday(
        widget.feriaId, widget.puesto);

    if (transaccionesActuales.isNotEmpty) {
      for (var transaccion in transaccionesActuales) {
        if (transaccion.concepto.isPaid) {
          conceptosPagados.add(ConceptoPagar(
            id: transaccion.concepto.id,
            name: transaccion.concepto.name,
            amount: transaccion.concepto.amount,
            date: transaccion.fechaCreacion,
            selected: true,
            available: false,
          ));
        } else {
          conceptosAPagar.add(ConceptoPagar(
            id: transaccion.concepto.id,
            name: transaccion.concepto.name,
            amount: transaccion.concepto.amount,
            date: transaccion.fechaCreacion,
            selected: false,
            available: true,
          ));
        }
      }
    } else {
      // load conceptosAPagar from Firestore
      await FirebaseFirestore.instance
          .collection('fairs')
          .doc(widget.feriaId)
          .collection('concepts')
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          conceptosAPagar.add(ConceptoPagar(
            id: doc.id,
            name: doc['name'],
            amount: doc['amount'],
            date: DateTime.now(),
            selected: false,
            available: true,
          ));
        });
      });
    }

    _calcularTotal();
    setState(() {});
  }

  Future<void> _cargarTransaccionesImpagas() async {
    TransaccionProvider transaccionProvider =
        Provider.of<TransaccionProvider>(context, listen: false);
    transaccionesAdeudadas = await transaccionProvider
        .getTransaccionesUnpaidOld(widget.feriaId, widget.puesto);

    if (transaccionesAdeudadas.isNotEmpty) {
      for (var transaccion in transaccionesAdeudadas) {
        conceptosAPagar.add(ConceptoPagar(
          id: transaccion.concepto.id,
          name: transaccion.concepto.name,
          amount: transaccion.concepto.amount,
          date: transaccion.fechaCreacion,
          selected: false,
          available: true,
        ));
      }
    }

    _calcularTotal();
    setState(() {});
  }

  void _calcularTotal() {
    total = 0;
    for (var concepto in conceptosAPagar) {
      if (concepto.selected) {
        total += concepto.amount;
      }
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  int _calcularDeuda() {
    int deuda = 0;
    for (var concepto in conceptosAPagar) {
      if (!concepto.selected) {
        deuda += concepto.amount;
      }
    }
    return deuda;
  }

  String _formatDate(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.puesto.codigo, style: const TextStyle(fontSize: 18.0)),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'Editar') {
                final Puesto? puestoActualizado = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditarResponsablePage(puesto: widget.puesto),
                  ),
                );

                if (puestoActualizado != null) {
                  setState(() {
                    widget.puesto.nombreResponsable =
                        puestoActualizado.nombreResponsable;
                    widget.puesto.apellidoResponsable =
                        puestoActualizado.apellidoResponsable;
                  });
                }
              } else if (value == 'Historial') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistorialPagosPage(
                      feriaId: widget.feriaId,
                      puesto: widget.puesto,
                    ),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Editar',
                child: Text('Editar datos del responsable'),
              ),
              const PopupMenuItem(
                value: 'Historial',
                child: Text('Ver historial de pagos'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                '${widget.puesto.nombreResponsable} ${widget.puesto.apellidoResponsable}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView(
                children: [
                  if (conceptosAPagar.isNotEmpty) ...[
                    const Text(
                      'Conceptos a Pagar',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6.0),
                  ],
                  ...conceptosAPagar.map((concepto) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      decoration: BoxDecoration(
                        color: concepto.selected
                            ? Colors.green[100]
                            : !isSameDay(concepto.date, DateTime.now())
                                ? Colors.red[100]
                                : Colors.grey[200],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: CheckboxListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 8.0),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              concepto.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: concepto.selected
                                    ? const Color.fromARGB(255, 18, 74, 21)
                                    : Colors.black,
                              ),
                            ),
                            Text(
                              'Fecha: ${_formatDate(concepto.date)}',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: !isSameDay(concepto.date, DateTime.now())
                                    ? Colors.red[800]
                                    : Colors.grey[600],
                                fontWeight:
                                    !isSameDay(concepto.date, DateTime.now())
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        value: concepto.selected,
                        onChanged: concepto.available
                            ? (value) {
                                setState(() {
                                  concepto.selected = value ?? false;
                                  _calcularTotal();
                                });
                              }
                            : null,
                        secondary: Text(
                          '\$${concepto.amount}',
                          style: const TextStyle(
                            fontSize: 14.0,
                          ),
                        ),
                        activeColor: const Color.fromARGB(255, 8, 125, 14),
                        checkColor: Colors.white,
                        controlAffinity: ListTileControlAffinity.leading,
                        tileColor: Colors.transparent,
                      ),
                    );
                  }),
                  const SizedBox(height: 16.0),
                  if (conceptosPagados.isNotEmpty) ...[
                    const Text(
                      'Conceptos Pagados',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6.0),
                    ...conceptosPagados.map((concepto) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          title: Text(
                            concepto.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                            ),
                          ),
                          subtitle: Text(
                            'Fecha: ${_formatDate(concepto.date)}',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: Text(
                            '\$${concepto.amount}',
                            style: const TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16.0),
                  ],
                ],
              ),
            ),
            if (_calcularDeuda() > 0) ...[
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent[400],
                  borderRadius:
                      BorderRadius.circular(8.0), // Bordes redondeados
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.white),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        'Se generará una deuda de \$${_calcularDeuda()}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
            ],
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total a cobrar:',
                        style: TextStyle(fontSize: 14), // Texto más pequeño
                      ),
                      Text(
                        '\$$total',
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold), // Monto más grande
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 48.0),
                  ),
                  child: const Text(
                    'Confirmar',
                    style: TextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                  onPressed: () async {
                    if (total == 0 && _calcularDeuda() == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'No hay conceptos seleccionados para pagar.'),
                          behavior: SnackBarBehavior.floating,
                          margin:
                              EdgeInsets.only(bottom: 10, left: 10, right: 10),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    print("************************");
                    print("******** CONFIRMAR ********");
                    print("************************");

                    TransaccionProvider transaccionProvider =
                        Provider.of<TransaccionProvider>(context,
                            listen: false);

                    List<ConceptoPagar> conceptosSeleccionados =
                        conceptosAPagar.where((c) => c.selected).toList();

                    bool hayCambios = false;

                    print("******** SELECCIONADOS ********");

                    // print(
                    //     transaccionesActuales.map((t) => t.toJson()).toList());

                    for (var conceptoSeleccionado in conceptosSeleccionados) {
                      // check if exists in transaccionesActuales
                      bool exists = transaccionesActuales
                          .any((t) => t.concepto.id == conceptoSeleccionado.id);

                      // busco tambien si existe en transaccionesAdeudadas
                      if (!exists) {
                        exists = transaccionesAdeudadas.any(
                            (t) => t.concepto.id == conceptoSeleccionado.id);
                      }

                      print(conceptoSeleccionado.name);
                      if (exists) {
                        // Editar pago existente
                        print(" ***** EDITAR *****");
                        await transaccionProvider.actualizarTransaccion(
                            widget.feriaId,
                            widget.puesto.id,
                            conceptoSeleccionado.id,
                            true);
                        hayCambios = true;
                      } else {
                        // Crear pago nuevo como pagado
                        print(" ***** NUEVO *****");
                        await transaccionProvider.agregarTransaccion(
                          widget.feriaId,
                          widget.puesto.id,
                          conceptoSeleccionado.name,
                          conceptoSeleccionado.amount,
                          true,
                          conceptoSeleccionado.date,
                        );
                        hayCambios = true;
                      }
                    }

                    print("******** NOOOO SELECCIONADOS ********");
                    // Crear pagos nuevos como impagos para los no seleccionados
                    List<ConceptoPagar> conceptosNoSeleccionados =
                        conceptosAPagar.where((c) => !c.selected).toList();

                    for (var conceptoNoSeleccionado
                        in conceptosNoSeleccionados) {
                      print(conceptoNoSeleccionado.name);

                      bool exists = transaccionesActuales.any(
                          (t) => t.concepto.id == conceptoNoSeleccionado.id);

                      // busco tambien si existe en transaccionesAdeudadas
                      if (!exists) {
                        exists = transaccionesAdeudadas.any(
                            (t) => t.concepto.id == conceptoNoSeleccionado.id);
                      }

                      if (exists) {
                        print(" ***** EDITAR *****");
                        await transaccionProvider.actualizarTransaccion(
                            widget.feriaId,
                            widget.puesto.id,
                            conceptoNoSeleccionado.id,
                            false);
                      } else {
                        print(" ***** NUEVO *****");
                        await transaccionProvider.agregarTransaccion(
                          widget.feriaId,
                          widget.puesto.id,
                          conceptoNoSeleccionado.name,
                          conceptoNoSeleccionado.amount,
                          false,
                          conceptoNoSeleccionado.date,
                        );
                      }

                      hayCambios = true;
                    }

                    if (hayCambios) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Datos guardados exitosamente'),
                          behavior: SnackBarBehavior.floating,
                          margin:
                              EdgeInsets.only(bottom: 10, left: 10, right: 10),
                          duration: Duration(seconds: 1),
                        ),
                      );

                      Navigator.pop(context, true);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No hay cambios para actualizar.'),
                          behavior: SnackBarBehavior.floating,
                          margin:
                              EdgeInsets.only(bottom: 10, left: 10, right: 10),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ConceptoPagar {
  final String id;
  final String name;
  final int amount;
  final DateTime date;
  bool selected;
  bool available;

  ConceptoPagar({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    this.selected = false,
    this.available = true,
  });
}
