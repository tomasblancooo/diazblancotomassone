import 'package:flutter/material.dart';

Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  String textoAccion = 'Eliminar',
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(textoAccion),
        ),
      ],
    ),
  );
  return r ?? false;
}
