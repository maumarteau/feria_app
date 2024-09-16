import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import '../models/puesto.dart';
import 'detalle_puesto_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecorridoPage extends StatefulWidget {
  final List<Puesto> puestos;
  final String feriaId;

  const RecorridoPage(
      {super.key, required this.puestos, required this.feriaId});

  @override
  _RecorridoPageState createState() => _RecorridoPageState();
}

class _RecorridoPageState extends State<RecorridoPage> {
  late MatchEngine _matchEngine;
  int _currentPuestoIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadRecorrido();
    _initializeCards();
  }

  void _initializeCards() {
    List<SwipeItem> swipeItems = widget.puestos.map((puesto) {
      return SwipeItem(
        content: puesto,
      );
    }).toList();

    _matchEngine = MatchEngine(swipeItems: swipeItems);
  }

  void _loadRecorrido() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentPuestoIndex =
          prefs.getInt('recorridoIndex_${widget.feriaId}') ?? 0;
    });
  }

  void _saveRecorrido(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('recorridoIndex_${widget.feriaId}', index);
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPuestoIndex >= widget.puestos.length) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Realizar Recorrido',
              style: TextStyle(fontSize: 18.0)),
        ),
        body: const Center(
          child: Text('Has completado el recorrido.'),
        ),
      );
    }

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
                elevation: 0,
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'PUESTO',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        widget.puestos[_currentPuestoIndex].codigo,
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          height: 0.8,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                        '${widget.puestos[_currentPuestoIndex].nombreResponsable} ${widget.puestos[_currentPuestoIndex].apellidoResponsable}',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 34.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(200, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                            ),
                            onPressed: () {
                              _avanzarPuesto();
                            },
                            child: const Text('Ausente',
                                style: TextStyle(fontSize: 18)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(200, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetallePuestoPage(
                                    puesto: widget.puestos[_currentPuestoIndex],
                                    feriaId: widget.feriaId,
                                  ),
                                ),
                              ).then((result) {
                                if (result == true) {
                                  _avanzarPuesto();
                                }
                              });
                            },
                            child: const Text('Cobrar',
                                style: TextStyle(fontSize: 18)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 100.0),
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

  void _avanzarPuesto() {
    setState(() {
      if (_currentPuestoIndex < widget.puestos.length - 1) {
        _currentPuestoIndex++;
        _saveRecorrido(_currentPuestoIndex);
      } else {
        _currentPuestoIndex++;
        _saveRecorrido(_currentPuestoIndex);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Has completado el recorrido.')),
        );
      }
    });
  }
}
