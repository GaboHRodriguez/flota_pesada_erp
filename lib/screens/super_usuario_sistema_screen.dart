import 'package:flutter/material.dart';
import '../models/erp_models.dart';
import '../services/erp_database_service.dart';

class SuperUsuarioSistemaScreen extends StatefulWidget {
  const SuperUsuarioSistemaScreen({super.key});

  @override
  State<SuperUsuarioSistemaScreen> createState() => _SuperUsuarioSistemaScreenState();
}

class _SuperUsuarioSistemaScreenState extends State<SuperUsuarioSistemaScreen> {
  late TextEditingController _serverUrlCtrl;

  @override
  void initState() {
    super.initState();
    _serverUrlCtrl = TextEditingController(
      text: ErpDatabaseService.instance.windowsServerUrl,
    );
  }

  @override
  void dispose() {
    _serverUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = ErpDatabaseService.instance;

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: const Color(0xFF1E293B),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF9333EA), size: 26),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CONSOLA DE SUPER USUARIO — MANTENIMIENTO Y REPARACIÓN DEL SISTEMA',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Gestión de los 5 niveles de usuarios, conexión a Windows Server, sincronización Offline Android y auditoría SQL',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showUserDialog(context, null),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9333EA),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                      label: const Text(
                        'Registrar Usuario',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const TabBar(
                  isScrollable: true,
                  indicatorColor: Color(0xFF9333EA),
                  labelColor: Color(0xFFC084FC),
                  unselectedLabelColor: Color(0xFF94A3B8),
                  tabs: [
                    Tab(text: '1. Usuarios y 5 Niveles de Permisos'),
                    Tab(text: '2. Windows Server, Diagnóstico SQL y Sincronización Android'),
                    Tab(text: '3. Bitácora de Auditoría del Sistema'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildUsuariosTab(context, db),
                _buildWindowsServerTab(context, db),
                _buildAuditoriaTab(context, db),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsuariosTab(BuildContext context, ErpDatabaseService db) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'PERSONAL REGISTRADO EN EL SISTEMA (TABLA PERSONAL Y PERMISOS)',
          style: TextStyle(color: Color(0xFFC084FC), fontWeight: FontWeight.w900, fontSize: 13.5),
        ),
        const SizedBox(height: 10),
        ...db.usuarios.map((u) {
          final color = u.role.badgeColor;
          final obra = u.obraAsignadaId != null ? db.getObraById(u.obraAsignadaId!) : null;
          return Card(
            color: const Color(0xFF1E293B),
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: color.withValues(alpha: 0.5)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.2),
                child: Icon(u.role.icon, color: color),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'NIVEL ${u.role.dbPermisoValue} · ${u.role.label.toUpperCase()}',
                      style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10.5),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${u.nombreCompleto} (${u.legajo})',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Correo: ${u.correo}  |  Clave: ${u.pass}  |  Puesto: ${u.puesto}\nCUIL: ${u.cuil}  |  Tel: ${u.telefono}  |  Base/Obra: ${obra?.nombreObra ?? "General"}',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    onPressed: () => _showUserDialog(context, u),
                    icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF38BDF8)),
                    label: const Text('Editar', style: TextStyle(color: Color(0xFF38BDF8))),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWindowsServerTab(BuildContext context, ErpDatabaseService db) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.dns_rounded, color: Color(0xFF38BDF8), size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'ARQUITECTURA WINDOWS SERVER + CLIENTES WINDOWS / MAC / ANDROID OFFLINE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _serverUrlCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Endpoint API en Windows Server (IP Local o Pública)',
                        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await db.updateWindowsServerUrl(_serverUrlCtrl.text);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Color(0xFF10B981),
                          content: Text('Dirección del Windows Server guardada correctamente.'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38BDF8),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Guardar IP/URL', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final synced = await db.sincronizarPendientesConServidor();
                      if (!context.mounted) return;
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF10B981),
                          content: Text(
                            'Sincronización completada: $synced registros pendientes enviados al Windows Server.',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.sync_rounded),
                    label: Text(
                      'Sincronizar Cola Offline (${db.pendientesSincronizarCount} pendientes)',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => db.toggleOfflineMode(!db.offlineMode).then((_) => setState(() {})),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFF59E0B),
                      side: const BorderSide(color: Color(0xFFF59E0B)),
                    ),
                    icon: Icon(db.offlineMode ? Icons.wifi_off_rounded : Icons.wifi_rounded),
                    label: Text(
                      db.offlineMode
                          ? 'Desactivar Simulación Sin Señal (Volver Online)'
                          : 'Simular Modo Obra Sin Señal (Offline Android)',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await db.restaurarDatosDeFabrica();
                      if (!context.mounted) return;
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Base de datos reparada y restaurada al estado original dbequipos.'),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                    ),
                    icon: const Icon(Icons.restore_page_rounded),
                    label: const Text('Reparar / Restaurar Base dbequipos'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ESTADO DE TABLAS SQL (`dbequipos`) EN MEMORIA Y SERVIDOR:',
                      style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '• Tabla `equipos` + `marcas` + `tipoequipos`: ${db.equipos.length} equipos activos en 46 rubros\n'
                      '• Tabla `personal` + `permisos`: ${db.usuarios.length} usuarios en 5 niveles de acceso\n'
                      '• Tabla `obras`: ${db.obras.length} frentes de obra y base operativa\n'
                      '• Tabla `partediario`: ${db.partesDiarios.length} partes registrados\n'
                      '• Tabla `service` + `partemecanica`: ${db.informesTaller.length} informes de taller\n'
                      '• Tabla `filtros` + `lubricantes`: ${db.filtrosRepuestos.length} familias de filtros y repuestos',
                      style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12.5, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuditoriaTab(BuildContext context, ErpDatabaseService db) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: db.auditLogs.length,
      itemBuilder: (context, index) {
        final log = db.auditLogs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Row(
            children: [
              const Icon(Icons.terminal_rounded, color: Color(0xFFC084FC), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  log,
                  style: const TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 12.5,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUserDialog(BuildContext context, AppUser? existing) {
    final db = ErpDatabaseService.instance;
    final isNew = existing == null;
    final nombreCtrl = TextEditingController(text: existing?.nombre ?? '');
    final apellidoCtrl = TextEditingController(text: existing?.apellido ?? '');
    final correoCtrl = TextEditingController(text: existing?.correo ?? '');
    final passCtrl = TextEditingController(text: existing?.pass ?? 'Obra2026!');
    final legajoCtrl = TextEditingController(text: existing?.legajo ?? 'LEG-201');
    final puestoCtrl = TextEditingController(text: existing?.puesto ?? 'Operador de Maquinaria');
    UserRole selectedRole = existing?.role ?? UserRole.operario;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: Text(
            isNew ? 'Registrar Nuevo Usuario' : 'Editar Usuario ${existing.nombreCompleto}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
          ),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<UserRole>(
                    initialValue: selectedRole,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Nivel de Usuario / Permisos',
                      labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                    items: UserRole.values
                        .map(
                          (r) => DropdownMenuItem(
                            value: r,
                            child: Text('Nivel ${r.dbPermisoValue}: ${r.label}'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setDialogState(() => selectedRole = v!),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: nombreCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                            labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: apellidoCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Apellido',
                            labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: correoCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Correo Electrónico (Login)',
                      labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: legajoCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Legajo',
                            labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: puestoCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Puesto / Cargo',
                            labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                await db.guardarUsuario(
                  AppUser(
                    id: existing?.id ?? 0,
                    nombre: nombreCtrl.text.trim(),
                    apellido: apellidoCtrl.text.trim(),
                    correo: correoCtrl.text.trim(),
                    pass: passCtrl.text.trim(),
                    legajo: legajoCtrl.text.trim(),
                    puesto: puestoCtrl.text.trim(),
                    role: selectedRole,
                    obraAsignadaId: 1,
                  ),
                  esNuevo: isNew,
                );
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9333EA),
                foregroundColor: Colors.white,
              ),
              child: const Text('Guardar Usuario'),
            ),
          ],
        ),
      ),
    );
  }
}
