import 'package:flutter/material.dart';

import '../models/cliente.dart';
import '../services/cliente_store.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/risk_chip.dart';
import 'cliente_form_screen.dart';

enum _Filtro { todos, enRiesgo, seguros, vencidas }

class ListaScreen extends StatefulWidget {
  const ListaScreen({super.key, required this.store});

  final ClienteStore store;

  @override
  State<ListaScreen> createState() => _ListaScreenState();
}

class _ListaScreenState extends State<ListaScreen> {
  String _query = '';
  _Filtro _filtro = _Filtro.todos;

  String _etiqueta(_Filtro f) {
    if (f == _Filtro.enRiesgo) return 'En riesgo';
    if (f == _Filtro.seguros) return 'Seguros';
    if (f == _Filtro.vencidas) return 'Auditoría vencida';
    return 'Todos';
  }

  List<Cliente> _filtrar() {
    final q = _query.trim().toLowerCase();
    final lista = widget.store.items.where((c) {
      if (q.isNotEmpty &&
          !c.empresa.toLowerCase().contains(q) &&
          !c.codigo.toLowerCase().contains(q)) {
        return false;
      }
      if (_filtro == _Filtro.enRiesgo) return c.enRiesgo;
      if (_filtro == _Filtro.seguros) return !c.enRiesgo;
      if (_filtro == _Filtro.vencidas) return c.auditoriaVencida;
      return true;
    }).toList();
    lista.sort((a, b) => b.puntaje.compareTo(a.puntaje));
    return lista;
  }

  Future<void> _editar(Cliente c) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ClienteFormScreen(store: widget.store, cliente: c),
      ),
    );
  }

  Future<void> _eliminar(Cliente c) async {
    try {
      await widget.store.eliminar(c.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar: $e')),
      );
    }
  }

  Widget _bannerError() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x33DC2626),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(widget.store.error ?? ''),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => widget.store.restablecer(),
            child: const Text('Restablecer datos de ejemplo'),
          ),
        ],
      ),
    );
  }

  Widget _tarjeta(Cliente c) {
    return Dismissible(
      key: ValueKey<String>(c.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFB91C1C),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        final ok = await confirmar(
          context,
          titulo: 'Eliminar cliente',
          mensaje: '¿Eliminar a ${c.empresa}? Esta acción no se puede deshacer.',
        );
        if (ok) {
          await _eliminar(c);
        }
        return false;
      },
      child: Card(
        color: c.fondo,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: c.color, width: 1.5),
        ),
        child: InkWell(
          onTap: () => _editar(c),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: <Widget>[
                Icon(
                  c.enRiesgo ? Icons.warning_amber_rounded : Icons.verified_user,
                  color: c.color,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        c.empresa,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${c.codigo} · ${c.vulnCriticas} vulnerabilidades críticas',
                        style: const TextStyle(fontSize: 12.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        c.auditoriaVencida
                            ? 'Auditoría vencida: ${c.diasUltimaAuditoria} días'
                            : 'Última auditoría: ${c.diasUltimaAuditoria} días',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: c.auditoriaVencida
                              ? const Color(0xFFFCA5A5)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      '${c.puntaje}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: c.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RiskChip(cliente: c),
                    const SizedBox(height: 4),
                    Text(c.estadoTexto, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lista = _filtrar();
    return Column(
      children: <Widget>[
        if (widget.store.error != null) _bannerError(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Buscar por empresa o código',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Row(
            children: <Widget>[
              for (final f in _Filtro.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_etiqueta(f)),
                    selected: _filtro == f,
                    onSelected: (_) => setState(() => _filtro = f),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: lista.isEmpty
              ? const Center(child: Text('No hay clientes para mostrar'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  itemCount: lista.length,
                  itemBuilder: (context, i) => _tarjeta(lista[i]),
                ),
        ),
      ],
    );
  }
}
