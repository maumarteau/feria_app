import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'detalle_puesto_page.dart';
import '../models/puesto.dart';
import 'recorrido_page.dart';
import 'resumen_cobros_page.dart'; // Importamos la página de Resumen de Cobros

class PuestosListPage extends StatefulWidget {
  const PuestosListPage({super.key});

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
    _initializePuestos();
    _loadRecorridoStatus(); // Cargar el estado del recorrido al inicio
    _searchController.addListener(_filterPuestos);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializePuestos() {
    puestos = List.generate(
      20,
      (index) => Puesto(
        id: index + 1,
        nombre: 'Puesto ${index + 1}',
        nombreResponsable: 'Nombre${index + 1}',
        apellidoResponsable: 'Apellido${index + 1}',
      ),
    );
    puestosFiltrados = puestos;
  }

  void _filterPuestos() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      puestosFiltrados = puestos.where((puesto) {
        String nombreCompletoResponsable =
            '${puesto.nombreResponsable ?? ''} ${puesto.apellidoResponsable ?? ''}'
                .toLowerCase();
        return puesto.nombre.toLowerCase().contains(query) ||
            nombreCompletoResponsable.contains(query);
      }).toList();
    });
  }

  Future<void> _loadRecorridoStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // Si hay un índice de recorrido guardado, significa que está iniciado
      recorridoIniciado = prefs.containsKey('recorridoIndex');
    });
  }

  Future<void> _reiniciarRecorrido() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('recorridoIndex'); // Eliminar el progreso del recorrido
    setState(() {
      recorridoIniciado = false; // Reiniciamos el estado
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recorrido reiniciado exitosamente.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Puestos', style: TextStyle(fontSize: 18.0)),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Recorrido') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecorridoPage(puestos: puestos),
                  ),
                ).then(
                    (_) => _loadRecorridoStatus()); // Recargar estado al volver
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar puestos...',
                border: InputBorder.none,
                fillColor: Colors.white,
                filled: true,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
      body: puestosFiltrados.isEmpty
          ? const Center(
              child:
                  Text('No se encontraron puestos para la búsqueda realizada.'),
            )
          : ListView.builder(
              itemCount: puestosFiltrados.length,
              itemBuilder: (context, index) {
                final puesto = puestosFiltrados[index];
                return ListTile(
                  title: Text(puesto.nombre),
                  subtitle: Text(
                    '${puesto.nombreResponsable ?? ''} ${puesto.apellidoResponsable ?? ''}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetallePuestoPage(puesto: puesto),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
