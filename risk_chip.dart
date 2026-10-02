import 'package:flutter/material.dart';

import '../models/cliente.dart';

class RiskChip extends StatelessWidget {
  const RiskChip({super.key, required this.cliente});

  final Cliente cliente;

  @override
  Widget build(BuildContext context) {
    final textColor =
        cliente.nivel == NivelRiesgo.medio ? Colors.black : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cliente.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        cliente.nivelTexto,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
