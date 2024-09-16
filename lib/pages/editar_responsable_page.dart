// lib/pages/editar_responsable_page.dart
import 'package:flutter/material.dart';
import '../models/puesto.dart';
import '../widgets/input_field.dart';
import '../theme.dart';

class EditarResponsablePage extends StatefulWidget {
  final Puesto puesto;

  const EditarResponsablePage({super.key, required this.puesto});

  @override
  _EditarResponsablePageState createState() => _EditarResponsablePageState();
}

class _EditarResponsablePageState extends State<EditarResponsablePage> {
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;

  @override
  void initState() {
    super.initState();
    _nombreController =
        TextEditingController(text: widget.puesto.nombreResponsable);
    _apellidoController =
        TextEditingController(text: widget.puesto.apellidoResponsable);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Editar Responsable', style: TextStyle(fontSize: 18.0)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InputField(
              hintText: 'Nombre',
              controller: _nombreController,
            ),
            const SizedBox(height: 16.0),
            InputField(
              hintText: 'Apellido',
              controller: _apellidoController,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text('Guardar cambios'),
                onPressed: () {
                  // Guardar los cambios y volver a la pantalla anterior
                  Navigator.pop(
                    context,
                    Puesto(
                      id: widget.puesto.id,
                      codigo: widget.puesto.codigo,
                      nombreResponsable: _nombreController.text,
                      apellidoResponsable: _apellidoController.text,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
