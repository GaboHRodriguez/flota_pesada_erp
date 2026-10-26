import 'package:flutter/material.dart';
import '../models/erp_models.dart';
import '../services/erp_database_service.dart';

class TallerMantenimientoScreen extends StatefulWidget {
  final EquipmentItem? preselectedEquipo;

  const TallerMantenimientoScreen({
    super.key,
    this.preselectedEquipo,
  });

  @override
  State<TallerMantenimientoScreen> createState() => _TallerMantenimientoScreenState();
}

class _TallerMantenimientoScreenState extends State<TallerMantenimientoScreen> {
  String _filtroTipo = 'Todos';

  @override
  void initState() {
    super.initState();
    if (widget.preselectedEquipo != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showInformeTallerDialog(
          context,
          existing: null,
          initialEquipo: widget.preselectedEquipo,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ErpDatabaseService.instance;
    final user = db.currentUser;
    final canManageTaller =
        user?.role == UserRole.taller || user?.role == UserRole.superUsuario;

    final solicitudesOperarios =
        db.partesDiarios.where((p) => p.solicitaReparacion).toList();
    final equiposServiceVencido =
        db.equipos.where((e) => e.requiereServiceUrgente || e.requiereServiceProximo).toList();

    final informesFiltrados = db.informesTaller.where((inf) {
      if (_filtroTipo == 'Todos') return true;
      return inf.tipoIntervencion == _filtroTipo;
    }).toList();

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: const Color(0xFF1E293B),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.build_circle_rounded, color: Color(0xFFF59E0B), size: 24),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CENTRAL DE TALLER MECÁNICO, MANTENIMIENTO Y PAÑOL',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Sistema mixto (Móvil en Frentes de Obra + PC Oficina Taller) · Crear, modificar y eliminar informes',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    if (canManageTaller)
                      ElevatedButton.icon(
                        onPressed: () => _showInformeTallerDialog(context, existing: null),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        icon: const Icon(Icons.add_task_rounded, size: 18),
                        label: const Text(
                          'Nuevo Informe / OT',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                TabBar(
                  isScrollable: true,
                  indicatorColor: const Color(0xFFF59E0B),
                  labelColor: const Color(0xFFF59E0B),
                  unselectedLabelColor: const Color(0xFF94A3B8),
                  tabs: [
                    Tab(text: '1. Informes de Mantenimiento y Reparaciones (${db.informesTaller.length})'),
                    Tab(
                      text:
                          '2. Solicitudes de Operarios y Alertas Preventivas (${solicitudesOperarios.length + equiposServiceVencido.length})',
                    ),
                    Tab(text: '3. Stock de Filtros Equivalentes y Repuestos (${db.filtrosRepuestos.length})'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // TAB 1: ABM de Informes de Mantenimiento, Reparaciones y Partes Diarios de Trabajo
                _buildInformesTab(context, db, informesFiltrados, canManageTaller),

                // TAB 2: Solicitudes de Operarios y Alertas de Service por Horómetro/Odómetro
                _buildAlertasTab(
                  context,
                  db,
                  solicitudesOperarios,
                  equiposServiceVencido,
                  canManageTaller,
                ),

                // TAB 3: Catálogo y Stock de Filtros y Repuestos
                _buildRepuestosStockTab(context, db, canManageTaller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformesTab(
    BuildContext context,
    ErpDatabaseService db,
    List<InformeTaller> informes,
    bool canManageTaller,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              'Todos',
              'Mantenimiento Preventivo',
              'Reparación Correctiva',
              'Parte Diario Taller',
            ].map((tipo) {
              final sel = _filtroTipo == tipo;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  selected: sel,
                  onSelected: (_) => setState(() => _filtroTipo = tipo),
                  selectedColor: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                  backgroundColor: const Color(0xFF1E293B),
                  label: Text(
                    tipo,
                    style: TextStyle(
                      color: sel ? Colors.white : const Color(0xFF94A3B8),
                      fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        ...informes.map((inf) {
          final eq = db.getEquipoById(inf.equipoId);
          final estColor = inf.estadoOrden == 'Completado'
              ? const Color(0xFF10B981)
              : (inf.estadoOrden == 'En Proceso' ? const Color(0xFFF59E0B) : const Color(0xFFEF4444));

          return Card(
            color: const Color(0xFF1E293B),
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFF334155)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'OT #${inf.id} · ${inf.equipoCodigo}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${inf.tipoIntervencion} — ${eq?.descripcionCompleta ?? inf.equipoCodigo}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: estColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: estColor),
                        ),
                        child: Text(
                          inf.estadoOrden.toUpperCase(),
                          style: TextStyle(color: estColor, fontWeight: FontWeight.w800, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 14,
                    runSpacing: 4,
                    children: [
                      Text(
                        'Fecha: ${inf.fecha}',
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                      ),
                      Text(
                        'Lugar: ${inf.lugar}',
                        style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Mecánico: ${inf.mecanicoResponsable}',
                        style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12),
                      ),
                      Text(
                        'Lectura: ${inf.horometroAlMomento.toStringAsFixed(0)} ${eq?.categoria.meterUnit ?? "hs"}',
                        style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Horas Taller: ${inf.horasTrabajoTaller.toStringAsFixed(1)} hs',
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFF334155), height: 18),
                  Text(
                    'Sistema intervenido: ${inf.sistemaAfectado}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    inf.observaciones,
                    style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      if (inf.checkCambioFiltro)
                        _buildTagChip('✓ Cambio de Filtros: ${inf.filtrosUtilizados}', const Color(0xFF10B981)),
                      if (inf.checkCambioLubricante)
                        _buildTagChip('✓ Cambio de Lubricante: ${inf.lubricantesUtilizados}', const Color(0xFF38BDF8)),
                      if (inf.repuestosUtilizados.isNotEmpty)
                        _buildTagChip('Repuestos: ${inf.repuestosUtilizados}', const Color(0xFFF59E0B)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Costo Repuestos: USD ${inf.costoRepuestos.toStringAsFixed(0)}  |  Mano de Obra: USD ${inf.costoManoObra.toStringAsFixed(0)}  |  TOTAL: USD ${inf.costoTotal.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Color(0xFFF59E0B),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      if (canManageTaller) ...[
                        TextButton.icon(
                          onPressed: () => _showInformeTallerDialog(context, existing: inf),
                          icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF38BDF8)),
                          label: const Text('Modificar', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12)),
                        ),
                        TextButton.icon(
                          onPressed: () => _confirmarEliminarInforme(context, inf),
                          icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                          label: const Text('Eliminar', style: TextStyle(color: Color(0xFFEF4444), fontSize: 12)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTagChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildAlertasTab(
    BuildContext context,
    ErpDatabaseService db,
    List<ParteDiario> solicitudes,
    List<EquipmentItem> equiposService,
    bool canManageTaller,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'SOLICITUDES DE REPARACIÓN ENVIADAS POR OPERARIOS EN PARTES DIARIOS',
          style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w900, fontSize: 13),
        ),
        const SizedBox(height: 8),
        if (solicitudes.isEmpty)
          const Text(
            'No hay solicitudes de reparación pendientes.',
            style: TextStyle(color: Color(0xFF94A3B8)),
          ),
        ...solicitudes.map((sol) {
          final eq = db.getEquipoById(sol.equipoId);
          final obra = db.getObraById(sol.obraId);
          return Card(
            color: const Color(0xFF1E293B),
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFEF4444)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFEF4444),
                child: Icon(Icons.report_problem_rounded, color: Colors.white),
              ),
              title: Text(
                '${sol.equipoCodigo} (${eq?.descripcionCompleta ?? ""}) — Urgencia: ${sol.urgenciaReparacion}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Parte Diario #${sol.numeroParte} (${sol.fecha}) · Operario: ${sol.operarioNombre} · Obra: ${obra.nombreObra}\nFalla reportada: ${sol.detalleSolicitudReparacion}',
                  style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12.5),
                ),
              ),
              trailing: canManageTaller
                  ? ElevatedButton.icon(
                      onPressed: () {
                        if (eq != null) {
                          _showInformeTallerDialog(
                            context,
                            existing: null,
                            initialEquipo: eq,
                            initialObservaciones:
                                'Atención a Solicitud de Parte #${sol.numeroParte}: ${sol.detalleSolicitudReparacion}',
                            parteOrigenId: sol.id,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.black,
                      ),
                      icon: const Icon(Icons.build_rounded, size: 16),
                      label: const Text('Generar OT', style: TextStyle(fontWeight: FontWeight.w800)),
                    )
                  : null,
            ),
          );
        }),
        const SizedBox(height: 20),
        const Text(
          'ALERTAS DE MANTENIMIENTO PREVENTIVO POR HORÓMETRO / ODÓMETRO',
          style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w900, fontSize: 13),
        ),
        const SizedBox(height: 8),
        ...equiposService.map((eq) {
          final vencido = eq.requiereServiceUrgente;
          final obra = db.getObraById(eq.obraActualId);
          return Card(
            color: const Color(0xFF1E293B),
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(
                Icons.timer_rounded,
                color: vencido ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                size: 28,
              ),
              title: Text(
                '${eq.codigo} — ${eq.descripcionCompleta}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13.5),
              ),
              subtitle: Text(
                'Lectura Actual: ${eq.lecturaActual.toStringAsFixed(0)} ${eq.categoria.meterUnit} · Service Programado: ${eq.proximoServiceLectura.toStringAsFixed(0)} ${eq.categoria.meterUnit} · Ubicación: ${obra.nombreObra}',
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
              trailing: canManageTaller
                  ? OutlinedButton(
                      onPressed: () => _showInformeTallerDialog(
                        context,
                        existing: null,
                        initialEquipo: eq,
                        initialObservaciones:
                            'Service Preventivo Programado de ${eq.intervaloService.toStringAsFixed(0)} ${eq.categoria.meterUnit} (Cambio de aceite y filtros).',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF59E0B),
                        side: const BorderSide(color: Color(0xFFF59E0B)),
                      ),
                      child: const Text('Registrar Service'),
                    )
                  : null,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRepuestosStockTab(
    BuildContext context,
    ErpDatabaseService db,
    bool canManageTaller,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'CATÁLOGO DE FILTROS EQUIVALENTES, REPUESTOS Y PLANOS DE DESPIECE',
                style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w900, fontSize: 13),
              ),
            ),
            if (canManageTaller)
              ElevatedButton.icon(
                onPressed: () => _showNuevoRepuestoDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  foregroundColor: Colors.black,
                ),
                icon: const Icon(Icons.add_box_rounded, size: 16),
                label: const Text('Agregar Repuesto/Filtro', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ...db.filtrosRepuestos.map((f) {
          return Card(
            color: const Color(0xFF1E293B),
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: f.stockCritico ? const Color(0xFFEF4444) : const Color(0xFF334155),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              f.codigoOriginal,
                              style: const TextStyle(
                                color: Color(0xFFF59E0B),
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                f.tipoComponente,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Equivalencias: ${f.equivalenciaMannFram}',
                          style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12.5),
                        ),
                        Text(
                          'Equipos compatibles: ${f.equiposCompatiblesCodigos}',
                          style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12),
                        ),
                        Text(
                          'Despiece: ${f.referenciaPlanoDespiece}  ·  Ubicación: ${f.ubicacionEstanteria}  ·  Costo: USD ${f.costoUnitarioUsd.toStringAsFixed(2)}',
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      Text(
                        'Stock: ${f.stockActual}',
                        style: TextStyle(
                          color: f.stockCritico ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Mín: ${f.stockMinimo}',
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                      ),
                      if (canManageTaller)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => db.ajustarStockRepuesto(f.id, f.stockActual - 1),
                              icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFEF4444)),
                            ),
                            IconButton(
                              onPressed: () => db.ajustarStockRepuesto(f.id, f.stockActual + 1),
                              icon: const Icon(Icons.add_circle_outline, color: Color(0xFF10B981)),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  void _confirmarEliminarInforme(BuildContext context, InformeTaller inf) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          'Eliminar Informe de Taller #${inf.id}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        content: Text(
          '¿Confirmas la eliminación del informe de ${inf.tipoIntervencion} del equipo ${inf.equipoCodigo}?',
          style: const TextStyle(color: Color(0xFFE2E8F0)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ErpDatabaseService.instance.eliminarInformeTaller(inf.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar Informe'),
          ),
        ],
      ),
    );
  }

  void _showInformeTallerDialog(
    BuildContext context, {
    required InformeTaller? existing,
    EquipmentItem? initialEquipo,
    String? initialObservaciones,
    int? parteOrigenId,
  }) {
    final db = ErpDatabaseService.instance;
    final isNew = existing == null;
    EquipmentItem selectedEq = initialEquipo ??
        (existing != null ? db.getEquipoById(existing.equipoId) : null) ??
        db.equipos.firstWhere((e) => e.codigo == 'RE016', orElse: () => db.equipos.first);

    String tipoIntervencion = existing?.tipoIntervencion ?? 'Mantenimiento Preventivo';
    String estadoOrden = existing?.estadoOrden ?? 'Completado';
    String lugar = existing?.lugar ?? 'Taller Central';
    final lugarController = TextEditingController(text: lugar);
    final fechaCtrl = TextEditingController(text: existing?.fecha ?? '2026-10-18');
    final mecanicoCtrl = TextEditingController(
      text: existing?.mecanicoResponsable ?? (db.currentUser?.nombreCompleto ?? 'Roberto Sánchez'),
    );
    final horometroCtrl = TextEditingController(
      text: (existing?.horometroAlMomento ?? selectedEq.lecturaActual).toStringAsFixed(0),
    );
    bool checkFiltro = existing?.checkCambioFiltro ?? true;
    bool checkLub = existing?.checkCambioLubricante ?? true;
    final filtrosCtrl = TextEditingController(
      text: existing?.filtrosUtilizados ?? 'Kit Filtros Aceite y Combustible OEM',
    );
    final lubCtrl = TextEditingController(
      text: existing?.lubricantesUtilizados ?? selectedEq.aceiteMotorSpec,
    );
    final repuestosCtrl = TextEditingController(text: existing?.repuestosUtilizados ?? '');
    final sistemaCtrl = TextEditingController(text: existing?.sistemaAfectado ?? 'Motor e Hidráulica');
    final costoRepCtrl = TextEditingController(
      text: (existing?.costoRepuestos ?? 185).toStringAsFixed(0),
    );
    final costoMoCtrl = TextEditingController(
      text: (existing?.costoManoObra ?? 120).toStringAsFixed(0),
    );
    final horasCtrl = TextEditingController(
      text: (existing?.horasTrabajoTaller ?? 3.5).toStringAsFixed(1),
    );
    final obsCtrl = TextEditingController(
      text: existing?.observaciones ??
          initialObservaciones ??
          'Mantenimiento y control general de presiones, niveles y elementos de seguridad.',
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: Text(
            isNew ? 'Crear Informe de Mantenimiento / Reparación' : 'Modificar Informe #${existing.id}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
          ),
          content: SizedBox(
            width: 540,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: selectedEq.id,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      labelText: 'Equipo / Vehículo / Herramienta',
                      labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                    items: db.equipos
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.id,
                            child: Text('${e.codigo} — ${e.descripcionCompleta}'),
                          ),
                        )
                        .toList(),
                    onChanged: (id) {
                      if (id == null) return;
                      final eq = db.getEquipoById(id);
                      if (eq != null) {
                        setDialogState(() {
                          selectedEq = eq;
                          horometroCtrl.text = eq.lecturaActual.toStringAsFixed(0);
                          lubCtrl.text = eq.aceiteMotorSpec;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: tipoIntervencion,
                          dropdownColor: const Color(0xFF0F172A),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: const InputDecoration(
                            labelText: 'Tipo de Informe',
                            labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Mantenimiento Preventivo',
                              child: Text('Mantenimiento Preventivo'),
                            ),
                            DropdownMenuItem(
                              value: 'Reparación Correctiva',
                              child: Text('Reparación Correctiva'),
                            ),
                            DropdownMenuItem(
                              value: 'Parte Diario Taller',
                              child: Text('Parte Diario Taller'),
                            ),
                          ],
                          onChanged: (v) => setDialogState(() => tipoIntervencion = v!),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: estadoOrden,
                          dropdownColor: const Color(0xFF0F172A),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: const InputDecoration(
                            labelText: 'Estado de la Orden',
                            labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Pendiente', child: Text('Pendiente')),
                            DropdownMenuItem(value: 'En Proceso', child: Text('En Proceso')),
                            DropdownMenuItem(value: 'Completado', child: Text('Completado')),
                          ],
                          onChanged: (v) => setDialogState(() => estadoOrden = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: lugarController,
                          onChanged: (v) => lugar = v,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Lugar (Taller Central / Frente de Obra)',
                            labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: mecanicoCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Mecánico Responsable',
                            labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: fechaCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Fecha',
                            labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: horometroCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Horómetro / Odómetro',
                            labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: horasCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Horas de Trabajo',
                            labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: checkFiltro,
                    contentPadding: EdgeInsets.zero,
                    activeColor: const Color(0xFFF59E0B),
                    title: const Text(
                      'Incluyó Cambio de Filtros (checkCambioFiltro)',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    onChanged: (v) => setDialogState(() => checkFiltro = v ?? false),
                  ),
                  if (checkFiltro)
                    TextField(
                      controller: filtrosCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Códigos de Filtros Utilizados',
                        labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                      ),
                    ),
                  CheckboxListTile(
                    value: checkLub,
                    contentPadding: EdgeInsets.zero,
                    activeColor: const Color(0xFF38BDF8),
                    title: const Text(
                      'Incluyó Cambio de Lubricantes (checkCambioLub)',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    onChanged: (v) => setDialogState(() => checkLub = v ?? false),
                  ),
                  if (checkLub)
                    TextField(
                      controller: lubCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Lubricantes y Litros Utilizados',
                        labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                      ),
                    ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: repuestosCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Otros Repuestos / Materiales Utilizados',
                      labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: sistemaCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Sistema Intervenido',
                            labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: costoRepCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Costo Repuestos (USD)',
                            labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: costoMoCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Mano de Obra (USD)',
                            labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: obsCtrl,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Informe Técnico / Trabajos Realizados y Observaciones',
                      labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final inf = InformeTaller(
                  id: existing?.id ?? 0,
                  equipoId: selectedEq.id,
                  equipoCodigo: selectedEq.codigo,
                  fecha: fechaCtrl.text.trim(),
                  tipoIntervencion: tipoIntervencion,
                  estadoOrden: estadoOrden,
                  horometroAlMomento: double.tryParse(horometroCtrl.text) ?? selectedEq.lecturaActual,
                  lugar: lugar,
                  mecanicoResponsable: mecanicoCtrl.text.trim(),
                  checkCambioFiltro: checkFiltro,
                  checkCambioLubricante: checkLub,
                  filtrosUtilizados: filtrosCtrl.text.trim(),
                  lubricantesUtilizados: lubCtrl.text.trim(),
                  repuestosUtilizados: repuestosCtrl.text.trim(),
                  sistemaAfectado: sistemaCtrl.text.trim(),
                  costoRepuestos: double.tryParse(costoRepCtrl.text) ?? 0,
                  costoManoObra: double.tryParse(costoMoCtrl.text) ?? 0,
                  horasTrabajoTaller: double.tryParse(horasCtrl.text) ?? 2.0,
                  observaciones: obsCtrl.text.trim(),
                  parteDiarioOrigenId: existing?.parteDiarioOrigenId ?? parteOrigenId,
                );
                await db.guardarInformeTaller(inf, esNuevo: isNew);
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.black,
              ),
              child: Text(
                isNew ? 'Guardar Informe' : 'Guardar Modificación',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextEditingController lugarCtrl(String val) => TextEditingController(text: val);

  void _showNuevoRepuestoDialog(BuildContext context) {
    final codCtrl = TextEditingController();
    final eqvCtrl = TextEditingController();
    final tipoCtrl = TextEditingController(text: 'Filtro de Aceite Motor');
    final compatCtrl = TextEditingController(text: 'PC008, RE016, MN004');
    final stockCtrl = TextEditingController(text: '6');
    final costoCtrl = TextEditingController(text: '45');
    final ubicCtrl = TextEditingController(text: 'Estante A-03');
    final planoCtrl = TextEditingController(text: 'Conjunto Motor — Lámina 03 — Pos. #10');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Catalogar Nuevo Filtro / Repuesto en Pañol',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
        ),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Código OEM Original (ej. CAT 1R-0751)',
                    labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: eqvCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Equivalencia Mann / Donaldson / Fleetguard',
                    labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: tipoCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Componente',
                    labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: compatCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Códigos de Equipos Compatibles',
                    labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: stockCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Stock Inicial',
                          labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: costoCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Costo Unit. (USD)',
                          labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: ubicCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Ubicación en Pañol',
                    labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: planoCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Referencia en Plano de Despiece',
                    labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await ErpDatabaseService.instance.agregarFiltroRepuesto(
                FiltroRepuestoItem(
                  id: 0,
                  codigoOriginal: codCtrl.text.trim().isEmpty ? 'OEM-GEN-001' : codCtrl.text.trim(),
                  equivalenciaMannFram: eqvCtrl.text.trim(),
                  tipoComponente: tipoCtrl.text.trim(),
                  equiposCompatiblesCodigos: compatCtrl.text.trim(),
                  stockActual: int.tryParse(stockCtrl.text) ?? 5,
                  stockMinimo: 2,
                  costoUnitarioUsd: double.tryParse(costoCtrl.text) ?? 40,
                  ubicacionEstanteria: ubicCtrl.text.trim(),
                  referenciaPlanoDespiece: planoCtrl.text.trim(),
                ),
              );
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.black,
            ),
            child: const Text('Guardar en Pañol'),
          ),
        ],
      ),
    );
  }
}
