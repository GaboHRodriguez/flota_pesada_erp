import 'package:flutter/material.dart';
import '../models/erp_models.dart';
import '../services/erp_database_service.dart';

class GerenciaCostosObrasScreen extends StatefulWidget {
  const GerenciaCostosObrasScreen({super.key});

  @override
  State<GerenciaCostosObrasScreen> createState() => _GerenciaCostosObrasScreenState();
}

class _GerenciaCostosObrasScreenState extends State<GerenciaCostosObrasScreen> {
  String _searchRendimiento = '';

  @override
  Widget build(BuildContext context) {
    final db = ErpDatabaseService.instance;
    final user = db.currentUser;
    final canAssignObras =
        user?.role == UserRole.gerencia || user?.role == UserRole.superUsuario;
    final canAddGastos =
        user?.role == UserRole.administrador ||
        user?.role == UserRole.gerencia ||
        user?.role == UserRole.superUsuario;

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
                    const Icon(Icons.analytics_rounded, color: Color(0xFF38BDF8), size: 24),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GERENCIA DE OBRA, RENDIMIENTOS DE FLOTA Y ADMINISTRACIÓN DE COSTOS',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Estadísticas ejecutivas de costos y rendimientos por equipo, designación a frentes de obra y registro de gastos',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    if (canAddGastos)
                      ElevatedButton.icon(
                        onPressed: () => _showRegistrarGastoDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.receipt_long_rounded, size: 18),
                        label: const Text(
                          'Cargar Gasto de Equipo',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                const TabBar(
                  isScrollable: true,
                  indicatorColor: Color(0xFF38BDF8),
                  labelColor: Color(0xFF38BDF8),
                  unselectedLabelColor: Color(0xFF94A3B8),
                  tabs: [
                    Tab(text: '1. Informes de Costos y Rendimiento por Equipo y Flota'),
                    Tab(text: '2. Designación y Retiro en Frentes de Obra'),
                    Tab(text: '3. Gastos Ocasionados, Consumos y Seguros'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildCostosYRendimientosTab(context, db),
                _buildFrentesDeObraTab(context, db, canAssignObras),
                _buildGastosYSegurosTab(context, db, canAddGastos),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostosYRendimientosTab(BuildContext context, ErpDatabaseService db) {
    final totalEquipos = db.equipos.length;
    final enUso = db.equipos.where((e) => e.estado == 'En uso').length;
    final enReparacion = db.equipos.where((e) => e.estado == 'En Reparación').length;
    final disponibilidadPct = totalEquipos > 0 ? (enUso / totalEquipos) * 100 : 0.0;

    final valorPatrimonialUsd =
        db.equipos.fold<double>(0, (sum, e) => sum + e.valCompra);
    final canonMensualActivoUsd = db.equipos
        .where((e) => e.estado == 'En uso')
        .fold<double>(0, (sum, e) => sum + e.pMensual);
    final costoStandbyMensualUsd = db.equipos
        .where((e) => e.estado != 'En uso' && e.estado != 'Baja')
        .fold<double>(0, (sum, e) => sum + e.pStandby);
    final totalGastosDirectosUsd =
        db.gastosEquipos.fold<double>(0, (sum, g) => sum + g.montoUsd);
    final totalCombustibleLts =
        db.partesDiarios.fold<double>(0, (sum, p) => sum + p.ltsCombustible);

    final maquinasPrincipales = db.equipos.where((e) {
      if (e.categoria == AssetCategory.herramienta) return false;
      if (_searchRendimiento.trim().isEmpty) return true;
      final q = _searchRendimiento.toLowerCase();
      return e.codigo.toLowerCase().contains(q) ||
          e.marcaNombre.toLowerCase().contains(q) ||
          e.modeloNombre.toLowerCase().contains(q) ||
          e.tipoEquipoNombre.toLowerCase().contains(q);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // KPIs Generales de Flota
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildKpiCard(
              title: 'DISPONIBILIDAD DE FLOTA',
              value: '${disponibilidadPct.toStringAsFixed(1)}% ($enUso / $totalEquipos)',
              subtitle: '$enReparacion equipos en reparación / taller',
              icon: Icons.check_circle_outline_rounded,
              color: const Color(0xFF10B981),
            ),
            _buildKpiCard(
              title: 'VALOR PATRIMONIAL FLOTA',
              value: 'USD ${(valorPatrimonialUsd / 1000000).toStringAsFixed(2)} M',
              subtitle: 'Valuación s/ tabla equipos (valCompra)',
              icon: Icons.account_balance_rounded,
              color: const Color(0xFF38BDF8),
            ),
            _buildKpiCard(
              title: 'COSTO OPERATIVO MENSUAL',
              value: 'USD ${canonMensualActivoUsd.toStringAsFixed(0)}',
              subtitle: 'Stand-By inactivo: USD ${costoStandbyMensualUsd.toStringAsFixed(0)}/mes',
              icon: Icons.request_quote_rounded,
              color: const Color(0xFFF59E0B),
            ),
            _buildKpiCard(
              title: 'GASTOS DIRECTOS IMPUTADOS',
              value: 'USD ${totalGastosDirectosUsd.toStringAsFixed(2)}',
              subtitle: 'Combustible registrado: ${totalCombustibleLts.toStringAsFixed(0)} Lts',
              icon: Icons.local_gas_station_rounded,
              color: const Color(0xFFA855F7),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Buscador y Tabla de Rendimiento y Costos por Equipo Individual
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'RENDIMIENTO TÉCNICO Y COSTO OPERATIVO POR EQUIPO (MAQUINARIA Y VEHÍCULOS)',
                      style: TextStyle(
                        color: Color(0xFFF59E0B),
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 280,
                    child: TextField(
                      onChanged: (v) => setState(() => _searchRendimiento = v),
                      style: const TextStyle(color: Colors.white, fontSize: 12.5),
                      decoration: InputDecoration(
                        hintText: 'Filtrar equipo (ej. RE016, PC008, MN004)...',
                        hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                        isDense: true,
                        prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF38BDF8)),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...maquinasPrincipales.take(35).map((eq) {
                final partesEq = db.getPartesPorEquipo(eq.id);
                final gastosEq = db.getGastosPorEquipo(eq.id);
                final hsTrabajadas = partesEq.fold<double>(0, (s, p) => s + p.usoRegistrado);
                final ltsConsumidos = partesEq.fold<double>(0, (s, p) => s + p.ltsCombustible);
                final gastoAcumUsd = gastosEq.fold<double>(0, (s, g) => s + g.montoUsd);
                final rendimientoLtsPorUnidad = hsTrabajadas > 0
                    ? (ltsConsumidos / hsTrabajadas)
                    : (eq.categoria == AssetCategory.maquinariaPesada ? (eq.potencia * 0.11) : 0.32);
                final costoHoraEstimado =
                    (eq.pMensual / 180.0) + (rendimientoLtsPorUnidad * 1.30);
                final obra = db.getObraById(eq.obraActualId);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 250,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${eq.codigo} · ${eq.marcaNombre} ${eq.modeloNombre}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                              ),
                            ),
                            Text(
                              '${eq.tipoEquipoNombre} · ${obra.nombreObra}',
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      _buildMiniStat(
                        'Lectura Actual',
                        '${eq.lecturaActual.toStringAsFixed(0)} ${eq.categoria.meterUnit}',
                        const Color(0xFFE2E8F0),
                      ),
                      _buildMiniStat(
                        'Rendimiento Comb.',
                        '${rendimientoLtsPorUnidad.toStringAsFixed(1)} Lts/${eq.categoria.meterUnit}',
                        const Color(0xFF38BDF8),
                      ),
                      _buildMiniStat(
                        'Canon Mensual / StandBy',
                        'USD ${eq.pMensual.toStringAsFixed(0)} / ${eq.pStandby.toStringAsFixed(0)}',
                        const Color(0xFFF59E0B),
                      ),
                      _buildMiniStat(
                        'Gastos Directos',
                        'USD ${gastoAcumUsd.toStringAsFixed(0)}',
                        const Color(0xFFA855F7),
                      ),
                      _buildMiniStat(
                        'Costo Operativo',
                        'USD ${costoHoraEstimado.toStringAsFixed(1)} / ${eq.categoria.meterUnit}',
                        const Color(0xFF10B981),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 255,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10.5)),
        Text(val, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12.5)),
      ],
    );
  }

  Widget _buildFrentesDeObraTab(
    BuildContext context,
    ErpDatabaseService db,
    bool canAssignObras,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'DESIGNACIÓN Y RETIRO DE EQUIPOS POR FRENTE DE OBRA',
                style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.w900, fontSize: 13.5),
              ),
            ),
            if (canAssignObras)
              ElevatedButton.icon(
                onPressed: () => _showMovimientoRapidoDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.black,
                ),
                icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                label: const Text(
                  'Designar o Retirar Equipo de Obra',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ...db.obras.map((obra) {
          final equiposEnObra = db.equipos.where((e) => e.obraActualId == obra.id).toList();
          final maqCount =
              equiposEnObra.where((e) => e.categoria == AssetCategory.maquinariaPesada).length;
          final vehCount =
              equiposEnObra.where((e) => e.categoria == AssetCategory.vehiculo).length;
          final herCount =
              equiposEnObra.where((e) => e.categoria == AssetCategory.herramienta).length;

          return Card(
            color: const Color(0xFF1E293B),
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFF334155)),
            ),
            child: ExpansionTile(
              collapsedIconColor: const Color(0xFFF59E0B),
              iconColor: const Color(0xFFF59E0B),
              title: Text(
                'Obra #${obra.numeroInterno}: ${obra.nombreObra}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14.5),
              ),
              subtitle: Text(
                'Comitente: ${obra.empresaComitente} (${obra.ubicacion}) · Responsable: ${obra.responsableNombre}\nEquipos asignados: ${equiposEnObra.length} ($maqCount Maquinarias, $vehCount Vehículos, $herCount Herramientas)',
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: equiposEnObra.take(30).map((eq) {
                      return Chip(
                        backgroundColor: const Color(0xFF0F172A),
                        side: const BorderSide(color: Color(0xFF334155)),
                        label: Text(
                          '${eq.codigo} (${eq.tipoEquipoNombre})',
                          style: const TextStyle(color: Colors.white, fontSize: 11.5),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        const Text(
          'BITÁCORA DE DESIGNACIONES, TRANSFERENCIAS Y RETIROS DE OBRA',
          style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w900, fontSize: 13),
        ),
        const SizedBox(height: 8),
        ...db.movimientosObra.map((m) {
          final orig = db.getObraById(m.obraOrigenId);
          final dest = db.getObraById(m.obraDestinoId);
          return Card(
            color: const Color(0xFF1E293B),
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.local_shipping_outlined, color: Color(0xFF38BDF8)),
              title: Text(
                '${m.fecha} · ${m.equipoCodigo} — ${m.tipoMovimiento}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13.5),
              ),
              subtitle: Text(
                'Origen: ${orig.nombreObra}  →  Destino: ${dest.nombreObra}\nAutorizó: ${m.autorizadoPor} · Motivo: ${m.motivoObservaciones}',
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGastosYSegurosTab(
    BuildContext context,
    ErpDatabaseService db,
    bool canAddGastos,
  ) {
    final equiposConSeguro = db.equipos.where((e) => e.nPoliza.isNotEmpty).take(20).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'REGISTRO CONTABLE DE GASTOS OCASIONADOS POR LOS EQUIPOS',
          style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 13.5),
        ),
        const SizedBox(height: 8),
        ...db.gastosEquipos.map((g) {
          final obra = db.getObraById(g.obraId);
          return Card(
            color: const Color(0xFF1E293B),
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.2),
                child: const Icon(Icons.attach_money_rounded, color: Color(0xFF10B981)),
              ),
              title: Text(
                '${g.equipoCodigo} · ${g.categoriaGasto} — USD ${g.montoUsd.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13.5),
              ),
              subtitle: Text(
                '${g.fecha} · Comprobante: ${g.nroComprobante} · Proveedor: ${g.proveedor}\nObra: ${obra.nombreObra} · Registró: ${g.registradoPor}\n${g.descripcion}',
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
            ),
          );
        }),
        const SizedBox(height: 18),
        const Text(
          'CONTROL DE PÓLIZAS DE SEGURO Y VENCIMIENTOS (TABLA EQUIPOS)',
          style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w900, fontSize: 13.5),
        ),
        const SizedBox(height: 8),
        ...equiposConSeguro.map(
          (eq) => Card(
            color: const Color(0xFF1E293B),
            margin: const EdgeInsets.only(bottom: 6),
            child: ListTile(
              dense: true,
              leading: const Icon(Icons.policy_rounded, color: Color(0xFFF59E0B)),
              title: Text(
                '${eq.codigo} (${eq.dominio}) — ${eq.descripcionCompleta}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                'Aseguradora: ${eq.seguroCompania} · Póliza: ${eq.nPoliza} · Cobertura: ${eq.tipoSeguro}',
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
              trailing: Text(
                'Vence: ${eq.vencimientoSeguro}',
                style: const TextStyle(
                  color: Color(0xFF38BDF8),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showMovimientoRapidoDialog(BuildContext context) {
    final db = ErpDatabaseService.instance;
    int selectedEqId = db.equipos.firstWhere((e) => e.codigo == 'PC008').id;
    int selectedObraId = 1;
    String tipoMov = 'Designación a Obra';
    String nuevoEstado = 'En uso';
    final respCtrl = TextEditingController(text: 'Juan Pérez');
    final motivoCtrl = TextEditingController(
      text: 'Designación de equipo a frente de obra por planificación semanal de Gerencia.',
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text(
            'Designar o Retirar Equipo de Frente de Obra',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: selectedEqId,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      labelText: 'Seleccionar Equipo de la Flota',
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
                    onChanged: (v) => setDialogState(() => selectedEqId = v!),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: tipoMov,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Acción',
                      labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Designación a Obra',
                        child: Text('Designar a Frente de Obra'),
                      ),
                      DropdownMenuItem(
                        value: 'Transferencia entre Obras',
                        child: Text('Transferir a otro Frente de Obra'),
                      ),
                      DropdownMenuItem(
                        value: 'Retiro a Taller/Depósito',
                        child: Text('Retirar Equipo de Obra a Taller/Depósito'),
                      ),
                    ],
                    onChanged: (v) {
                      setDialogState(() {
                        tipoMov = v!;
                        if (tipoMov == 'Retiro a Taller/Depósito') {
                          selectedObraId = 5;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    initialValue: selectedObraId,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      labelText: 'Frente de Obra Destino',
                      labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                    items: db.obras
                        .map((o) => DropdownMenuItem(value: o.id, child: Text(o.nombreObra)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => selectedObraId = v!),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: respCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Responsable / Operador Asignado',
                      labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: motivoCtrl,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Observaciones / Orden de Traslado',
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
                await db.designarORetirarEquipoDeObra(
                  equipoId: selectedEqId,
                  obraDestinoId: selectedObraId,
                  tipoMovimiento: tipoMov,
                  nuevoEstadoEquipo: nuevoEstado,
                  responsableEnObra: respCtrl.text.trim(),
                  motivoObservaciones: motivoCtrl.text.trim(),
                );
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.black,
              ),
              child: const Text('Confirmar Designación / Retiro'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRegistrarGastoDialog(BuildContext context) {
    final db = ErpDatabaseService.instance;
    EquipmentItem selectedEq = db.equipos.firstWhere((e) => e.codigo == 'RE016');
    String catGasto = 'Repuestos y Filtros';
    final provCtrl = TextEditingController(text: 'Vial Repuestos S.A.');
    final compCtrl = TextEditingController(text: 'FC-A-0005-00081920');
    final montoCtrl = TextEditingController(text: '350');
    final descCtrl = TextEditingController(text: 'Compra de insumos y repuestos operativos para equipo.');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text(
            'Cargar Gasto Ocasionado por Equipo',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
          ),
          content: SizedBox(
            width: 460,
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
                      labelText: 'Equipo al que se imputa el gasto',
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
                      if (eq != null) setDialogState(() => selectedEq = eq);
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: catGasto,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Rubro del Gasto',
                      labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Combustible', child: Text('Combustible')),
                      DropdownMenuItem(value: 'Lubricantes', child: Text('Lubricantes')),
                      DropdownMenuItem(value: 'Repuestos y Filtros', child: Text('Repuestos y Filtros')),
                      DropdownMenuItem(value: 'Reparación Externa', child: Text('Reparación Externa')),
                      DropdownMenuItem(
                        value: 'Neumáticos / Tren Rodante',
                        child: Text('Neumáticos / Tren Rodante'),
                      ),
                      DropdownMenuItem(value: 'Seguro / Patente', child: Text('Seguro / Patente')),
                      DropdownMenuItem(value: 'Traslado / Carretón', child: Text('Traslado / Carretón')),
                    ],
                    onChanged: (v) => setDialogState(() => catGasto = v!),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: provCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Proveedor',
                      labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: compCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'N° Factura / Comprobante',
                            labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: montoCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Monto (USD)',
                            labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Detalle del Gasto',
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
                await db.registrarGastoEquipo(
                  GastoEquipo(
                    id: 0,
                    equipoId: selectedEq.id,
                    equipoCodigo: selectedEq.codigo,
                    fecha: '2026-10-18',
                    categoriaGasto: catGasto,
                    proveedor: provCtrl.text.trim(),
                    nroComprobante: compCtrl.text.trim(),
                    montoUsd: double.tryParse(montoCtrl.text) ?? 100,
                    obraId: selectedEq.obraActualId,
                    registradoPor: db.currentUser?.nombreCompleto ?? 'Administración',
                    descripcion: descCtrl.text.trim(),
                  ),
                );
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
              ),
              child: const Text('Guardar Gasto'),
            ),
          ],
        ),
      ),
    );
  }
}
