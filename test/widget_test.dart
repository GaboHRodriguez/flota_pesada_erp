import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flota_pesada_erp/main.dart';
import 'package:flota_pesada_erp/models/erp_models.dart';
import 'package:flota_pesada_erp/services/erp_database_service.dart';

void main() {
  testWidgets('Carga de 183 equipos de dbequipos y los 5 niveles de usuario', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await ErpDatabaseService.instance.init();

    expect(ErpDatabaseService.instance.equipos.length, 183);
    expect(ErpDatabaseService.instance.usuarios.length, greaterThanOrEqualTo(5));

    await tester.pumpWidget(const FlotaPesadaErpApp());
    await tester.pumpAndSettle();

    expect(find.text('MAQUINARIA & FLOTA ERP'), findsOneWidget);

    // Probar ingreso como Gerencia
    final gerenciaUser = ErpDatabaseService.instance.loginWithEmailPassword(
      'gerencia@constructora.com',
      'Gerencia2026!',
    );
    expect(gerenciaUser?.role, UserRole.gerencia);
  });
}
