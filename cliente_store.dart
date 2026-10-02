import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cliente.dart';

/// Guarda los clientes en el almacenamiento local del teléfono.
class ClienteStore extends ChangeNotifier {
  static const String _key = 'clientes_v1';

  final List<Cliente> _items = <Cliente>[];
  bool cargando = true;
  String? error;

  List<Cliente> get items => List<Cliente>.unmodifiable(_items);

  Future<void> cargar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) {
        await _commit(Cliente.demo());
      } else {
        final lista = jsonDecode(raw) as List<dynamic>;
        final cargados = lista
            .map((e) => Cliente.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
        _items
          ..clear()
          ..addAll(cargados);
      }
      error = null;
    } catch (e) {
      _items.clear();
      error = 'No se pudieron leer los datos guardados ($e).';
    }
    cargando = false;
    notifyListeners();
  }

  Future<void> _commit(List<Cliente> nueva) async {
    final prefs = await SharedPreferences.getInstance();
    final ok = await prefs.setString(
      _key,
      jsonEncode(nueva.map((c) => c.toMap()).toList()),
    );
    if (!ok) {
      throw Exception('El almacenamiento rechazó la escritura');
    }
    _items
      ..clear()
      ..addAll(nueva);
    notifyListeners();
  }

  bool existeCodigo(String codigo, {String? excluirId}) {
    final buscado = codigo.trim().toUpperCase();
    for (final c in _items) {
      if (c.id != excluirId && c.codigo.toUpperCase() == buscado) {
        return true;
      }
    }
    return false;
  }

  String siguienteCodigo() {
    int max = 0;
    final re = RegExp(r'^CLT-(\d+)$');
    for (final c in _items) {
      final m = re.firstMatch(c.codigo.toUpperCase());
      if (m != null) {
        final n = int.tryParse(m.group(1)!) ?? 0;
        if (n > max) max = n;
      }
    }
    return 'CLT-${(max + 1).toString().padLeft(3, '0')}';
  }

  Future<void> agregar(Cliente c) => _commit(<Cliente>[..._items, c]);

  Future<void> actualizar(Cliente c) =>
      _commit(_items.map((x) => x.id == c.id ? c : x).toList());

  Future<void> eliminar(String id) =>
      _commit(_items.where((x) => x.id != id).toList());

  Future<void> restablecer() async {
    await _commit(Cliente.demo());
    error = null;
    notifyListeners();
  }
}
