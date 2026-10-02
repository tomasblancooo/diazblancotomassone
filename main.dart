import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/cliente_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CyberSecApp());
}

class CyberSecApp extends StatefulWidget {
  const CyberSecApp({super.key});

  @override
  State<CyberSecApp> createState() => _CyberSecAppState();
}

class _CyberSecAppState extends State<CyberSecApp> {
  final ClienteStore _store = ClienteStore();

  @override
  void initState() {
    super.initState();
    _store.cargar();
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CyberSec CRM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFDC2626),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0B0B0F),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B0B0F),
          centerTitle: false,
        ),
      ),
      home: HomeScreen(store: _store),
    );
  }
}
