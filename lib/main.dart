import 'package:flutter/material.dart';
import 'services/erp_database_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_shell_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ErpDatabaseService.instance.init();
  runApp(const FlotaPesadaErpApp());
}

class FlotaPesadaErpApp extends StatelessWidget {
  const FlotaPesadaErpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ErpDatabaseService.instance,
      builder: (context, _) {
        final db = ErpDatabaseService.instance;
        return MaterialApp(
          title: 'Maquinaria & Flota ERP — dbequipos',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0B1120),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFF59E0B),
              secondary: Color(0xFF38BDF8),
              surface: Color(0xFF1E293B),
            ),
          ),
          home: db.currentUser == null ? const LoginScreen() : const HomeShellScreen(),
        );
      },
    );
  }
}
