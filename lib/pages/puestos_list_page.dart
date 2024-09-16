// lib/pages/puestos_list_page.dart
import 'package:feria_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detalle_puesto_page.dart';
import '../models/puesto.dart';
import 'recorrido_page.dart';
import 'resumen_cobros_page.dart';
import '../models/feria.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/input_field.dart';

class PuestosListPage extends StatefulWidget {
  final Feria feria;

  const PuestosListPage({super.key, required this.feria});

  @override
  _PuestosListPageState createState() => _PuestosListPageState();
}

class _PuestosListPageState extends State<PuestosListPage> {
  List<Puesto> puestos = [];
  List<Puesto> puestosFiltrados = [];
  final TextEditingController _searchController = TextEditingController();
  bool recorridoIniciado = false;

  @override
  void initState() {
    super.initState();
    _fetchPuestos();
    _loadRecorridoStatus();
    _searchController.addListener(_filterPuestos);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchPuestos() {
    FirebaseFirestore.instance
        .collection('fairs')
        .doc(widget.feria.id.toString())
        .collection('stands')
        .snapshots()
        .listen((snapshot) {
      List<Puesto> fetchedPuestos = snapshot.docs.map((doc) {
        return Puesto(
          id: doc['id'],
          codigo: doc['code'] ?? '',
          nombreResponsable: doc['responsibleName'] ?? '',
          apellidoResponsable: doc['responsibleLastname'] ?? '',
        );
      }).toList();

      setState(() {
        puestos = fetchedPuestos;
        puestosFiltrados = puestos;
      });
    });
  }

  void _filterPuestos() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      puestosFiltrados = puestos.where((puesto) {
        String nombreCompletoResponsable =
            '${puesto.nombreResponsable} ${puesto.apellidoResponsable}'
                .toLowerCase();
        return puesto.codigo.toLowerCase().contains(query) ||
            nombreCompletoResponsable.contains(query);
      }).toList();
    });
  }

  Future<void> _loadRecorridoStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      recorridoIniciado =
          prefs.containsKey('recorridoIndex_${widget.feria.id}');
    });
  }

  Future<void> _reiniciarRecorrido() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('recorridoIndex_${widget.feria.id}');
    setState(() {
      recorridoIniciado = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recorrido reiniciado exitosamente.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Seleccionar puesto',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: appBarText,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: appBarBackground,
          iconTheme: const IconThemeData(color: appBarText),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: appBarText),
              onSelected: (value) {
                if (value == 'Recorrido') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecorridoPage(
                          puestos: puestos, feriaId: widget.feria.id),
                    ),
                  ).then((_) => _loadRecorridoStatus());
                } else if (value == 'Resumen') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ResumenCobrosPage(),
                    ),
                  );
                } else if (value == 'Reiniciar') {
                  _reiniciarRecorrido();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'Recorrido',
                  child: Text(recorridoIniciado
                      ? 'Retomar Recorrido'
                      : 'Iniciar Recorrido'),
                ),
                const PopupMenuItem(
                  value: 'Resumen',
                  child: Text('Resumen de Cobros'),
                ),
                if (recorridoIniciado)
                  const PopupMenuItem(
                    value: 'Reiniciar',
                    child: Text('Reiniciar Recorrido'),
                  ),
              ],
            ),
          ],
        ),
        body: puestosFiltrados.isEmpty
            ? const Center(
                child: Text(
                    'No se encontraron puestos para la búsqueda realizada.'),
              )
            : Column(
                children: [
                  Container(
                    color: appBarBackground,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: InputField(
                        hintText: 'Buscar puestos...',
                        controller: _searchController,
                        backgroundColor: Colors.white,
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: puestosFiltrados.length,
                      itemBuilder: (context, index) {
                        final puesto = puestosFiltrados[index];
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
                                  title: Text(
                                    puesto.codigo,
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${puesto.nombreResponsable} ${puesto.apellidoResponsable}',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      height: 1.5,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DetallePuestoPage(
                                          puesto: puesto,
                                          feriaId: widget.feria.id,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                ],
              ));
  }

  Widget _buildSearchBar() {
    // Removed since the search bar is now using InputField in the AppBar
    return Container();
  }
}
