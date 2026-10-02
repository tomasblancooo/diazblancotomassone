import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/cliente.dart';
import '../services/cliente_store.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/risk_chip.dart';

class ClienteFormScreen extends StatefulWidget {
  const ClienteFormScreen({super.key, required this.store, this.cliente});

  final ClienteStore store;
  final Cliente? cliente;

  @override
  State<ClienteFormScreen> createState() => _ClienteFormScreenState();
}

class _ClienteFormScreenState extends State<ClienteFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _codigo;
  late final TextEditingController _empresa;
  late final TextEditingController _dias;
  late final TextEditingController _vulns;
  bool _guardando = false;

  bool get _editando => widget.cliente != null;

  @override
  void initState() {
    super.initState();
    final c = widget.cliente;
    _codigo = TextEditingController(
      text: c?.codigo ?? widget.store.siguienteCodigo(),
    );
    _empresa = TextEditingController(text: c?.empresa ?? '');
    _dias = TextEditingController(text: '${c?.diasUltimaAuditoria ?? 0}');
    _vulns = TextEditingController(text: '${c?.vulnCriticas ?? 0}');
    _dias.addListener(_refrescar);
    _vulns.addListener(_refrescar);
  }

  void _refrescar() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _codigo.dispose();
    _empresa.dispose();
    _dias.dispose();
    _vulns.dispose();
    super.dispose();
  }

  Cliente _previa() {
    return Cliente(
      id: widget.cliente?.id ?? 'previa',
      codigo: _codigo.text.trim().toUpperCase(),
      empresa: _empresa.text.trim(),
      diasUltimaAuditoria: int.tryParse(_dias.text) ?? 0,
      vulnCriticas: int.tryParse(_vulns.text) ?? 0,
    );
  }

  String? _validarEntero(String? v, {required int max}) {
    final texto = (v ?? '').trim();
    if (texto.isEmpty) return 'Campo obligatorio';
    final n = int.tryParse(texto);
    if (n == null) return 'Ingresá un número entero';
    if (n < 0 || n > max) return 'Valor entre 0 y $max';
    return null;
  }

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _guardando = true);
    try {
      final base = _previa();
      final c = Cliente(
        id: widget.cliente?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        codigo: base.codigo,
        empresa: base.empresa,
        diasUltimaAuditoria: base.diasUltimaAuditoria,
        vulnCriticas: base.vulnCriticas,
      );
      if (_editando) {
        await widget.store.actualizar(c);
      } else {
        await widget.store.agregar(c);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar: $e')),
      );
    }
  }

  Future<void> _eliminar() async {
    final c = widget.cliente;
    if (c == null) return;
    final ok = await confirmar(
      context,
      titulo: 'Eliminar cliente',
      mensaje: '¿Eliminar a ${c.empresa}? Esta acción no se puede deshacer.',
    );
    if (!ok || !mounted) return;
    try {
      await widget.store.eliminar(c.id);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final previa = _previa();
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar cliente' : 'Nuevo cliente'),
        actions: <Widget>[
          if (_editando)
            IconButton(
              tooltip: 'Eliminar',
              icon: const Icon(Icons.delete_outline),
              onPressed: _guardando ? null : _eliminar,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _codigo,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Código de cliente',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return 'Campo obligatorio';
                    if (widget.store.existeCodigo(
                      t,
                      excluirId: widget.cliente?.id,
                    )) {
                      return 'Ya existe un cliente con ese código';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _empresa,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Empresa',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Campo obligatorio' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dias,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Días desde la última auditoría',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => _validarEntero(v, max: 36500),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _vulns,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Vulnerabilidades críticas detectadas',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => _validarEntero(v, max: 99999),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: previa.fondo,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: previa.color, width: 1.5),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text('Vista previa del riesgo'),
                            const SizedBox(height: 4),
                            Text(
                              '${previa.puntaje} puntos · ${previa.estadoTexto}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: previa.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RiskChip(cliente: previa),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _guardando ? null : _guardar,
                  icon: _guardando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_editando ? 'Guardar cambios' : 'Crear cliente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
