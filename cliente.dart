import 'package:flutter/material.dart';

enum NivelRiesgo { critico, medio, bajo }

/// Cliente corporativo con su estado de seguridad.
///
/// Reglas de riesgo (equivalentes a la fórmula de la planilla):
///  - 5 o más vulnerabilidades críticas -> 95 puntos
///  - 2 a 4 -> 40 puntos
///  - 0 a 1 -> 0 puntos
///  - Si la última auditoría tiene más de 90 días -> +15 (tope 100)
///  - Nivel: >= 80 Crítico, >= 40 Medio, resto Bajo
///  - Estado: "En riesgo" si el nivel es Crítico, si no "Seguro"
class Cliente {
  const Cliente({
    required this.id,
    required this.codigo,
    required this.empresa,
    required this.diasUltimaAuditoria,
    required this.vulnCriticas,
  });

  final String id;
  final String codigo;
  final String empresa;
  final int diasUltimaAuditoria;
  final int vulnCriticas;

  static const int umbralAuditoriaDias = 90;

  static const Color rojo = Color(0xFFDC2626);
  static const Color ambar = Color(0xFFF59E0B);
  static const Color verde = Color(0xFF22C55E);

  int get puntaje {
    int base;
    if (vulnCriticas >= 5) {
      base = 95;
    } else if (vulnCriticas >= 2) {
      base = 40;
    } else {
      base = 0;
    }
    if (diasUltimaAuditoria > umbralAuditoriaDias) {
      base += 15;
    }
    return base > 100 ? 100 : base;
  }

  NivelRiesgo get nivel {
    final p = puntaje;
    if (p >= 80) return NivelRiesgo.critico;
    if (p >= 40) return NivelRiesgo.medio;
    return NivelRiesgo.bajo;
  }

  bool get enRiesgo => nivel == NivelRiesgo.critico;

  bool get auditoriaVencida => diasUltimaAuditoria > umbralAuditoriaDias;

  String get nivelTexto {
    switch (nivel) {
      case NivelRiesgo.critico:
        return 'Crítico';
      case NivelRiesgo.medio:
        return 'Medio';
      case NivelRiesgo.bajo:
        return 'Bajo';
    }
  }

  String get estadoTexto => enRiesgo ? 'En riesgo' : 'Seguro';

  Color get color {
    switch (nivel) {
      case NivelRiesgo.critico:
        return rojo;
      case NivelRiesgo.medio:
        return ambar;
      case NivelRiesgo.bajo:
        return verde;
    }
  }

  Color get fondo {
    switch (nivel) {
      case NivelRiesgo.critico:
        return const Color.fromRGBO(220, 38, 38, 0.18);
      case NivelRiesgo.medio:
        return const Color.fromRGBO(245, 158, 11, 0.16);
      case NivelRiesgo.bajo:
        return const Color.fromRGBO(34, 197, 94, 0.14);
    }
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'codigo': codigo,
      'empresa': empresa,
      'dias': diasUltimaAuditoria,
      'vulnerabilidades': vulnCriticas,
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> m) {
    return Cliente(
      id: m['id'] as String,
      codigo: m['codigo'] as String,
      empresa: m['empresa'] as String,
      diasUltimaAuditoria: (m['dias'] as num).toInt(),
      vulnCriticas: (m['vulnerabilidades'] as num).toInt(),
    );
  }

  static List<Cliente> demo() {
    return const <Cliente>[
      Cliente(
        id: 'demo-1',
        codigo: 'CLT-001',
        empresa: 'Quantum Solutions',
        diasUltimaAuditoria: 30,
        vulnCriticas: 2,
      ),
      Cliente(
        id: 'demo-2',
        codigo: 'CLT-002',
        empresa: 'SecureNet Inc.',
        diasUltimaAuditoria: 15,
        vulnCriticas: 0,
      ),
      Cliente(
        id: 'demo-3',
        codigo: 'CLT-003',
        empresa: 'DataGuard Systems',
        diasUltimaAuditoria: 60,
        vulnCriticas: 5,
      ),
      Cliente(
        id: 'demo-4',
        codigo: 'CLT-004',
        empresa: 'Innovatech Solutions',
        diasUltimaAuditoria: 45,
        vulnCriticas: 1,
      ),
    ];
  }
}
