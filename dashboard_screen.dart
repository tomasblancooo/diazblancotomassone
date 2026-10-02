import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/cliente.dart';
import '../services/cliente_store.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.store});

  final ClienteStore store;

  @override
  Widget build(BuildContext context) {
    final items = List<Cliente>.of(store.items)
      ..sort((a, b) => b.puntaje.compareTo(a.puntaje));

    if (items.isEmpty) {
      return const Center(child: Text('Todavía no hay datos para mostrar'));
    }

    final total = items.length;
    final enRiesgo = items.where((c) => c.enRiesgo).length;
    final vencidas = items.where((c) => c.auditoriaVencida).length;
    final suma = items.fold<int>(0, (a, c) => a + c.puntaje);
    final promedio = (suma / total).round();

    final nCritico =
        items.where((c) => c.nivel == NivelRiesgo.critico).length;
    final nMedio = items.where((c) => c.nivel == NivelRiesgo.medio).length;
    final nBajo = items.where((c) => c.nivel == NivelRiesgo.bajo).length;

    final alertasCriticas = items.where((c) => c.enRiesgo).toList();
    final alertasVencidas =
        items.where((c) => c.auditoriaVencida && !c.enRiesgo).toList();

    final titulo = Theme.of(context).textTheme.titleMedium;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _Stat(
                icono: Icons.business,
                valor: '$total',
                etiqueta: 'Clientes',
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Stat(
                icono: Icons.warning_amber_rounded,
                valor: '$enRiesgo',
                etiqueta: 'En riesgo',
                color: Cliente.rojo,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _Stat(
                icono: Icons.event_busy,
                valor: '$vencidas',
                etiqueta: 'Auditorías vencidas',
                color: Cliente.ambar,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Stat(
                icono: Icons.speed,
                valor: '$promedio',
                etiqueta: 'Puntaje medio',
                color: Cliente.verde,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Puntaje de riesgo por empresa', style: titulo),
        const SizedBox(height: 12),
        for (final c in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 112,
                  child: Text(
                    c.empresa,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: c.puntaje / 100,
                      minHeight: 14,
                      color: c.color,
                      backgroundColor: const Color(0x22FFFFFF),
                    ),
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    '${c.puntaje}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),
        Text('Distribución de riesgo', style: titulo),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            SizedBox(
              width: 140,
              height: 140,
              child: CustomPaint(
                painter: _PiePainter(
                  valores: <double>[
                    nCritico.toDouble(),
                    nMedio.toDouble(),
                    nBajo.toDouble(),
                  ],
                  colores: const <Color>[
                    Cliente.rojo,
                    Cliente.ambar,
                    Cliente.verde,
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _Leyenda(color: Cliente.rojo, texto: 'Crítico: $nCritico'),
                  _Leyenda(color: Cliente.ambar, texto: 'Medio: $nMedio'),
                  _Leyenda(color: Cliente.verde, texto: 'Bajo: $nBajo'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Alertas recientes', style: titulo),
        const SizedBox(height: 8),
        if (alertasCriticas.isEmpty && alertasVencidas.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Sin alertas: todos los clientes están al día.'),
          ),
        for (final c in alertasCriticas)
          _Alerta(
            icono: Icons.error,
            color: Cliente.rojo,
            titulo: 'Riesgo crítico',
            detalle: '${c.empresa} (${c.vulnCriticas} vulnerabilidades críticas)',
          ),
        for (final c in alertasVencidas)
          _Alerta(
            icono: Icons.info,
            color: Cliente.ambar,
            titulo: 'Auditoría vencida',
            detalle: '${c.empresa} (${c.diasUltimaAuditoria} días sin auditar)',
          ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icono,
    required this.valor,
    required this.etiqueta,
    required this.color,
  });

  final IconData icono;
  final String valor;
  final String etiqueta;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icono, color: color),
            const SizedBox(height: 8),
            Text(
              valor,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(etiqueta, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _Leyenda extends StatelessWidget {
  const _Leyenda({required this.color, required this.texto});

  final Color color;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(texto),
        ],
      ),
    );
  }
}

class _Alerta extends StatelessWidget {
  const _Alerta({
    required this.icono,
    required this.color,
    required this.titulo,
    required this.detalle,
  });

  final IconData icono;
  final Color color;
  final String titulo;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icono, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  titulo,
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
                Text(detalle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  _PiePainter({required this.valores, required this.colores});

  final List<double> valores;
  final List<Color> colores;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final total = valores.fold<double>(0, (a, b) => a + b);
    if (total <= 0) {
      final paintVacio = Paint()
        ..color = const Color(0x33FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawOval(rect.deflate(2), paintVacio);
      return;
    }
    double inicio = -math.pi / 2;
    for (int i = 0; i < valores.length; i++) {
      final barrido = valores[i] / total * 2 * math.pi;
      if (barrido > 0) {
        canvas.drawArc(rect, inicio, barrido, true, Paint()..color = colores[i]);
        inicio += barrido;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) => true;
}
