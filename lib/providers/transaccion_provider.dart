import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/transaccion.dart';

class TransaccionProvider with ChangeNotifier {
  List<Transaccion> _transacciones = [];

  List<Transaccion> get transacciones => _transacciones;

  TransaccionProvider() {
    _loadFromPrefs();
  }

  void agregarTransaccion(Transaccion transaccion) {
    _transacciones.add(transaccion);
    _saveToPrefs();
    notifyListeners();
  }

  void _saveToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> transaccionesJson =
        _transacciones.map((t) => json.encode(t.toJson())).toList();
    prefs.setStringList('transacciones', transaccionesJson);
  }

  void _loadFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? transaccionesJson = prefs.getStringList('transacciones');
    if (transaccionesJson != null) {
      _transacciones = transaccionesJson
          .map((t) => Transaccion.fromJson(json.decode(t)))
          .toList();
      notifyListeners();
    }
  }

  void eliminarTransaccion(int index) {
    _transacciones.removeAt(index);
    notifyListeners();
  }
}
