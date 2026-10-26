import 'package:flutter/material.dart';
import '../models/erp_models.dart';
import '../services/erp_database_service.dart';
import 'flota_equipos_screen.dart';
import 'parte_diario_screen.dart';
import 'taller_mantenimiento_screen.dart';
import 'gerencia_costos_obras_screen.dart';
import 'super_usuario_sistema_screen.dart';

class _NavTabItem {
  final String id;
  final String label;
  final IconData icon;
  final Widget widget;

  const _NavTabItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.widget,
  });
}

class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({super.key});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  String _activeTabId = '';
  EquipmentItem? _preselectedEquipoForParte;
  EquipmentItem? _preselectedEquipoForTaller;

  List<_NavTabItem> _buildTabsForRole(UserRole role) {
    final flotaTab = _NavTabItem(
      id: 'flota',
      label: 'Equipos y Despiece',
      icon: Icons.precision_manufacturing_rounded,
      widget: FlotaEquiposScreen(
        onGoToParteDiario: (eq) {
          setState(() {
            _preselectedEquipoForParte = eq;
            _activeTabId = 'parte';
          });
        },
        onGoToTaller: (eq) {
          setState(() {
            _preselectedEquipoForTaller = eq;
            _activeTabId = 'taller';
          });
        },
      ),
    );

    final parteTab = _NavTabItem(
      id: 'parte',
      label: 'Parte Diario',
      icon: Icons.assignment_turned_in_rounded,
      widget: ParteDiarioScreen(preselectedEquipo: _preselectedEquipoForParte),
    );

    final tallerTab = _NavTabItem(
      id: 'taller',
      label: 'Taller y Repuestos',
      icon: Icons.build_circle_rounded,
      widget: TallerMantenimientoScreen(preselectedEquipo: _preselectedEquipoForTaller),
    );

    const gerenciaTab = _NavTabItem(
      id: 'gerencia',
      label: 'Costos y Obras',
      icon: Icons.analytics_rounded,
      widget: GerenciaCostosObrasScreen(),
    );

    const superTab = _NavTabItem(
      id: 'super',
      label: 'Sistema / Server',
      icon: Icons.admin_panel_settings_rounded,
      widget: SuperUsuarioSistemaScreen(),
    );

    switch (role) {
      case UserRole.operario:
        // Operario: Solo carga de parte diario y consulta técnica del equipo
        return [parteTab, flotaTab];
      case UserRole.taller:
        // Taller: Crear/modificar/eliminar informes, stock, despiece y partes
        return [tallerTab, flotaTab, parteTab];
      case UserRole.administrador:
        // Administrador: Cargar equipos, gastos, consumos y partes diarios
        return [flotaTab, parteTab, gerenciaTab];
      case UserRole.gerencia:
        // Gerencia / Jefe de Obra: Todos los informes de costos/rendimientos, designar/retirar obras, supervisión
        return [gerenciaTab, flotaTab, tallerTab, parteTab];
      case UserRole.superUsuario:
        // Super Usuario: Acceso total + mantenimiento del sistema
        return [flotaTab, parteTab, tallerTab, gerenciaTab, superTab];
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ErpDatabaseService.instance;
    final user = db.currentUser!;
    final tabs = _buildTabsForRole(user.role);

    int currentIndex = tabs.indexWhere((t) => t.id == _activeTabId);
    if (currentIndex == -1) {
      currentIndex = 0;
      _activeTabId = tabs.first.id;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 820;

        return Scaffold(
          backgroundColor: const Color(0xFF0B1120),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0F172A),
            elevation: 0,
            titleSpacing: 14,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.engineering_rounded, color: Colors.black, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GESTIÓN VIAL & MAQUINARIA PESADA',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '${user.nombreCompleto} · Nivel ${user.role.dbPermisoValue}: ${user.role.label}',
                        style: TextStyle(
                          color: user.role.badgeColor,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              // Indicador / Botón Modo Offline Android vs Windows Server
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () async {
                    if (db.offlineMode && db.pendientesSincronizarCount > 0) {
                      final count = await db.sincronizarPendientesConServidor();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF10B981),
                          content: Text(
                            'Conectado a Windows Server: $count registros Offline sincronizados.',
                          ),
                        ),
                      );
                    } else {
                      await db.toggleOfflineMode(!db.offlineMode);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: db.offlineMode
                          ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
                          : const Color(0xFF10B981).withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: db.offlineMode ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          db.offlineMode ? Icons.cloud_off_rounded : Icons.cloud_done_rounded,
                          size: 16,
                          color: db.offlineMode ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          db.offlineMode
                              ? 'Offline (${db.pendientesSincronizarCount} en cola)'
                              : 'Server Online',
                          style: TextStyle(
                            color: db.offlineMode ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                            fontWeight: FontWeight.w800,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Selector rápido de Nivel de Usuario (para probar los 5 roles al instante)
              PopupMenuButton<UserRole>(
                tooltip: 'Cambiar Nivel de Usuario (Demo Rápida)',
                color: const Color(0xFF1E293B),
                onSelected: (role) {
                  setState(() {
                    _activeTabId = '';
                    db.loginQuickAsRole(role);
                  });
                },
                itemBuilder: (context) => UserRole.values
                    .map(
                      (r) => PopupMenuItem<UserRole>(
                        value: r,
                        child: Row(
                          children: [
                            Icon(r.icon, color: r.badgeColor, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Nivel ${r.dbPermisoValue}: ${r.label}',
                              style: TextStyle(
                                color: user.role == r ? r.badgeColor : Colors.white,
                                fontWeight: user.role == r ? FontWeight.w900 : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: user.role.badgeColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: user.role.badgeColor),
                  ),
                  child: Row(
                    children: [
                      Icon(user.role.icon, size: 16, color: user.role.badgeColor),
                      const SizedBox(width: 6),
                      Text(
                        user.role.shortLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),

              IconButton(
                tooltip: 'Cerrar Sesión',
                onPressed: () => db.logout(),
                icon: const Icon(Icons.logout_rounded, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
          body: Row(
            children: [
              if (isDesktop)
                NavigationRail(
                  backgroundColor: const Color(0xFF0F172A),
                  selectedIndex: currentIndex,
                  extended: constraints.maxWidth >= 1180,
                  onDestinationSelected: (idx) {
                    setState(() => _activeTabId = tabs[idx].id);
                  },
                  selectedIconTheme: const IconThemeData(color: Color(0xFFF59E0B)),
                  unselectedIconTheme: const IconThemeData(color: Color(0xFF64748B)),
                  selectedLabelTextStyle: const TextStyle(
                    color: Color(0xFFF59E0B),
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                  ),
                  unselectedLabelTextStyle: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                  destinations: tabs
                      .map(
                        (t) => NavigationRailDestination(
                          icon: Icon(t.icon),
                          label: Text(t.label),
                        ),
                      )
                      .toList(),
                ),
              if (isDesktop) const VerticalDivider(width: 1, color: Color(0xFF1E293B)),
              Expanded(
                child: tabs[currentIndex].widget,
              ),
            ],
          ),
          bottomNavigationBar: isDesktop
              ? null
              : NavigationBar(
                  backgroundColor: const Color(0xFF0F172A),
                  indicatorColor: const Color(0xFFF59E0B).withValues(alpha: 0.22),
                  selectedIndex: currentIndex,
                  onDestinationSelected: (idx) {
                    setState(() => _activeTabId = tabs[idx].id);
                  },
                  destinations: tabs
                      .map(
                        (t) => NavigationDestination(
                          icon: Icon(t.icon, color: const Color(0xFF94A3B8)),
                          selectedIcon: Icon(t.icon, color: const Color(0xFFF59E0B)),
                          label: t.label,
                        ),
                      )
                      .toList(),
                ),
        );
      },
    );
  }
}
