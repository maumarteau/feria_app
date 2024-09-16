// lib/pages/feria_list_page.dart
import 'package:feria_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/feria.dart';
import 'puestos_list_page.dart';
import '../widgets/input_field.dart';

class FeriaListPage extends StatefulWidget {
  const FeriaListPage({super.key});

  @override
  _FeriaListPageState createState() => _FeriaListPageState();
}

class _FeriaListPageState extends State<FeriaListPage> {
  List<Feria> ferias = [];
  List<Feria> feriasFiltradas = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchFerias();
    _searchController.addListener(_filterFerias);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchFerias() {
    FirebaseFirestore.instance
        .collection('fairs')
        .snapshots()
        .listen((snapshot) {
      List<Feria> fetchedFerias = snapshot.docs.map((doc) {
        print(doc);
        return Feria(
          id: doc['id'],
          nombre: doc['name'] ?? '',
          descripcion: doc['description'] ?? '',
          puestos: [], // To be fetched separately
        );
      }).toList();

      setState(() {
        ferias = fetchedFerias;
        feriasFiltradas = ferias;
      });
    });
  }

  void _filterFerias() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      feriasFiltradas = ferias.where((feria) {
        return feria.nombre.toLowerCase().contains(query) ||
            feria.descripcion.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    FocusScope.of(context).unfocus(); // Close the keyboard
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar feria',
            style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: appBarText)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: appBarBackground,
      ),
      body: Column(
        children: [
          Container(
            color: appBarBackground,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: InputField(
                hintText: 'Buscar ferias...',
                controller: _searchController,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                backgroundColor: Colors.white,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: _clearSearch,
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: feriasFiltradas.isNotEmpty
                ? ListView.builder(
                    itemCount: feriasFiltradas.length,
                    itemBuilder: (context, index) {
                      final feria = feriasFiltradas[index];
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
                                  feria.nombre,
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  feria.descripcion,
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
                                      builder: (_) =>
                                          PuestosListPage(feria: feria),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text(
                        'No se encontraron ferias para la búsqueda realizada.'),
                  ),
          ),
        ],
      ),
    );
  }
}
