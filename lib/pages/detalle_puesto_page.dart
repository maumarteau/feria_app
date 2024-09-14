import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/puesto.dart';
import '../models/transaccion.dart';
import '../providers/transaccion_provider.dart';
import 'editar_responsable_page.dart'; // Importa la nueva página

class DetallePuestoPage extends StatefulWidget {
  final Puesto puesto;

  const DetallePuestoPage({super.key, required this.puesto});

  @override
  _DetallePuestoPageState createState() => _DetallePuestoPageState();
}

class _DetallePuestoPageState extends State<DetallePuestoPage> {
  bool concepto1 = true; // Concepto 1 inicializado en true
  bool concepto2 = true; // Concepto 2 inicializado en true
  int total = 0;

  final int precioConcepto1 = 130; // Boleto baños químicos
  final int precioConcepto2 = 300; // Boleto de servicios

  @override
  void initState() {
    super.initState();
    _calcularTotal(); // Calcular el total desde el inicio
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.puesto.nombre, style: const TextStyle(fontSize: 18.0)),
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
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Editar',
                child: Text('Editar datos del responsable'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(
            16.0), // Padding para que el botón no quede pegado a los bordes
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.puesto.nombreResponsable} ${widget.puesto.apellidoResponsable}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            CheckboxListTile(
              title: Text('Boleto baños químicos    \$$precioConcepto1'),
              value: concepto1,
              onChanged: (value) {
                setState(() {
                  concepto1 = value ?? false;
                  _calcularTotal();
                });
              },
            ),
            CheckboxListTile(
              title: Text('Boleto de servicios           \$$precioConcepto2'),
              value: concepto2,
              onChanged: (value) {
                setState(() {
                  concepto2 = value ?? false;
                  _calcularTotal();
                });
              },
            ),
            const SizedBox(height: 16.0),
            Text(
              'Total a cobrar: \$$total',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (!concepto1 || !concepto2) ...[
              const SizedBox(height: 16.0),
              Container(
                color: Colors.orangeAccent[400],
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.white),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        'Se generará una deuda de \$${_calcularDeuda()}',
                        style: const TextStyle(
                            color: Color(0xFFFFFFFF), fontSize: 14.0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity, // El botón ocupa todo el ancho disponible
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Color verde para el botón
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8.0), // Bordes redondeados
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0), // Padding vertical
                ),
                child: const Text(
                  'Confirmar',
                  style: TextStyle(fontSize: 16.0, color: Color(0xFFFFFFFF)),
                ),
                onPressed: () {
                  Transaccion nuevaTransaccion = Transaccion(
                    puesto: widget.puesto,
                    asistio: true,
                    conceptosPagados: {
                      'Baños químicos': concepto1,
                      'Servicios': concepto2,
                    },
                    totalPagado: total,
                  );

                  Provider.of<TransaccionProvider>(context, listen: false)
                      .agregarTransaccion(nuevaTransaccion);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Datos guardados exitosamente')),
                  );

                  Navigator.pop(context, true);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para calcular el total a pagar
  void _calcularTotal() {
    total = 0;
    if (concepto1) total += precioConcepto1;
    if (concepto2) total += precioConcepto2;
  }

  // Método para calcular la deuda en caso de que no se seleccionen los conceptos
  int _calcularDeuda() {
    int deuda = 0;
    if (!concepto1) deuda += precioConcepto1;
    if (!concepto2) deuda += precioConcepto2;
    return deuda;
  }
}
