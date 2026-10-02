import 'package:flutter/material.dart';

import '../services/cliente_store.dart';
import 'cliente_form_screen.dart';
import 'dashboard_screen.dart';
import 'lista_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.store});

  final ClienteStore store;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  Future<void> _nuevo() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ClienteFormScreen(store: widget.store),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        if (widget.store.cargando) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(_tab == 0 ? 'CyberSec CRM · Clientes' : 'Dashboard'),
          ),
          body: _tab == 0
              ? ListaScreen(store: widget.store)
              : DashboardScreen(store: widget.store),
          floatingActionButton: _tab == 0
              ? FloatingActionButton.extended(
                  onPressed: _nuevo,
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo cliente'),
                )
              : null,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            destinations: const <NavigationDestination>[
              NavigationDestination(
                icon: Icon(Icons.business_outlined),
                selectedIcon: Icon(Icons.business),
                label: 'Clientes',
              ),
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
            ],
          ),
        );
      },
    );
  }
}
