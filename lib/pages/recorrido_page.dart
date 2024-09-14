import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import '../models/puesto.dart';
import 'detalle_puesto_page.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Para guardar el progreso

class RecorridoPage extends StatefulWidget {
  final List<Puesto> puestos;

  const RecorridoPage({super.key, required this.puestos});

  @override
  _RecorridoPageState createState() => _RecorridoPageState();
}

class _RecorridoPageState extends State<RecorridoPage> {
  late MatchEngine _matchEngine;
  int _currentPuestoIndex = 0; // Variable para guardar el estado del recorrido

  @override
  void initState() {
    super.initState();
    _loadRecorrido(); // Cargar el progreso del recorrido guardado
    _initializeCards();
  }

  // Inicializar las tarjetas de los puestos
  void _initializeCards() {
    List<SwipeItem> swipeItems = widget.puestos.map((puesto) {
      return SwipeItem(
        content: puesto,
      );
    }).toList();

    _matchEngine = MatchEngine(swipeItems: swipeItems);
  }

  // Cargar el progreso del recorrido guardado
  void _loadRecorrido() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentPuestoIndex = prefs.getInt('recorridoIndex') ?? 0;
    });
  }

  // Guardar el progreso del recorrido cuando el usuario pase al siguiente puesto
  void _saveRecorrido(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('recorridoIndex', index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Realizar Recorrido', style: TextStyle(fontSize: 18.0)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Card(
                elevation: 5,
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Puesto ${widget.puestos[_currentPuestoIndex].id}',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        '${widget.puestos[_currentPuestoIndex].nombreResponsable} ${widget.puestos[_currentPuestoIndex].apellidoResponsable}',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _avanzarPuesto();
                            },
                            child: const Text('Ausente'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetallePuestoPage(
                                    puesto: widget.puestos[_currentPuestoIndex],
                                  ),
                                ),
                              ).then((result) {
                                if (result == true) {
                                  // Solo avanzar si el cobro fue confirmado
                                  _avanzarPuesto();
                                }
                              });
                            },
                            child: const Text('Cobrar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Método para avanzar al siguiente puesto
  void _avanzarPuesto() {
    setState(() {
      if (_currentPuestoIndex < widget.puestos.length - 1) {
        _currentPuestoIndex++;
        _saveRecorrido(_currentPuestoIndex); // Guardar el progreso
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Has completado el recorrido.')),
        );
      }
    });
  }
}
