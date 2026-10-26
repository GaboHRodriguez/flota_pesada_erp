import 'package:flutter/material.dart';
import '../models/erp_models.dart';
import '../services/erp_database_service.dart';

class ParteDiarioScreen extends StatefulWidget {
  final EquipmentItem? preselectedEquipo;

  const ParteDiarioScreen({
    super.key,
    this.preselectedEquipo,
  });

  @override
  State<ParteDiarioScreen> createState() => _ParteDiarioScreenState();
}

class _ParteDiarioScreenState extends State<ParteDiarioScreen> {
  late EquipmentItem _selectedEquipo;
  late int _selectedObraId;
  final _fechaCtrl = TextEditingController(text: '2026-10-18');
  final _horaInicioCtrl = TextEditingController(text: '07:30');
  final _horaFinCtrl = TextEditingController(text: '17:00');
  final _horometroInicialCtrl = TextEditingController();
  final _horometroFinalCtrl = TextEditingController();
  final _ltsCombustibleCtrl = TextEditingController(text: '0');
  String _tipoCombustible = 'Diesel';
  final _ltsLubricanteCtrl = TextEditingController(text: '0');
  String _tipoLubricante = 'Sin agregado';
  final _valeCargaCtrl = TextEditingController(text: 'VC-8850');
  final _ordenCompraCtrl = TextEditingController(text: 'OC-2026-320');
  final _trabajosCtrl = TextEditingController();
  final _observacionesCtrl = TextEditingController(
    text: 'Funcionamiento normal de motor, transmisión y sistema hidráulico.',
  );
  bool _solicitaReparacion = false;
  String _urgenciaReparacion = 'Alta';
  final _detalleReparacionCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final db = ErpDatabaseService.instance;
    final maquinasYVehiculos = db.equipos
        .where((e) => e.categoria != AssetCategory.herramienta)
        .toList();
    _selectedEquipo = widget.preselectedEquipo ??
        maquinasYVehiculos.firstWhere(
          (e) => e.codigo == 'RE016',
          orElse: () => maquinasYVehiculos.first,
        );
    _applySelectedEquipo(_selectedEquipo);
  }

  @override
  void didUpdateWidget(covariant ParteDiarioScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.preselectedEquipo != null &&
        widget.preselectedEquipo!.id != _selectedEquipo.id) {
      setState(() {
        _selectedEquipo = widget.preselectedEquipo!;
        _applySelectedEquipo(_selectedEquipo);
      });
    }
  }

  void _applySelectedEquipo(EquipmentItem eq) {
    _selectedObraId = eq.obraActualId;
    _tipoCombustible = eq.tipoCombustible;
    _horometroInicialCtrl.text = eq.lecturaActual.toStringAsFixed(0);
    final incrementoDefault = eq.categoria == AssetCategory.vehiculo ? 180.0 : 8.5;
    _horometroFinalCtrl.text = (eq.lecturaActual + incrementoDefault).toStringAsFixed(1);
    _ltsCombustibleCtrl.text = eq.categoria == AssetCategory.vehiculo ? '45' : '125';
  }

  @override
  void dispose() {
    _fechaCtrl.dispose();
    _horaInicioCtrl.dispose();
    _horaFinCtrl.dispose();
    _horometroInicialCtrl.dispose();
    _horometroFinalCtrl.dispose();
    _ltsCombustibleCtrl.dispose();
    _ltsLubricanteCtrl.dispose();
    _valeCargaCtrl.dispose();
    _ordenCompraCtrl.dispose();
    _trabajosCtrl.dispose();
    _observacionesCtrl.dispose();
    _detalleReparacionCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardarParte() async {
    final db = ErpDatabaseService.instance;
    final hIni = double.tryParse(_horometroInicialCtrl.text) ?? _selectedEquipo.lecturaActual;
    final hFin = double.tryParse(_horometroFinalCtrl.text) ?? (hIni + 8);
    if (hFin < hIni) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFEF4444),
          content: Text('La lectura final no puede ser menor que la lectura inicial.'),
        ),
      );
      return;
    }

    final trabajos = _trabajosCtrl.text.trim().isEmpty
        ? 'Movimiento de suelo, perfilado y apoyo operativo en frente de obra.'
        : _trabajosCtrl.text.trim();

    final parte = await db.registrarParteDiario(
      equipoId: _selectedEquipo.id,
      fecha: _fechaCtrl.text.trim(),
      horaInicio: _horaInicioCtrl.text.trim(),
      horaFin: _horaFinCtrl.text.trim(),
      horometroInicial: hIni,
      horometroFinal: hFin,
      obraId: _selectedObraId,
      ltsCombustible: double.tryParse(_ltsCombustibleCtrl.text) ?? 0,
      tipoCombustible: _tipoCombustible,
      ltsLubricante: double.tryParse(_ltsLubricanteCtrl.text) ?? 0,
      tipoLubricante: _tipoLubricante,
      nroValeCarga: _valeCargaCtrl.text.trim(),
      nroOrdenCompra: _ordenCompraCtrl.text.trim(),
      trabajosRealizados: trabajos,
      observacionesFuncionamiento: _observacionesCtrl.text.trim(),
      solicitaReparacion: _solicitaReparacion,
      detalleSolicitudReparacion: _detalleReparacionCtrl.text.trim(),
      urgenciaReparacion: _urgenciaReparacion,
    );

    final updatedEq = db.getEquipoById(_selectedEquipo.id);
    if (updatedEq != null) {
      setState(() {
        _selectedEquipo = updatedEq;
        _applySelectedEquipo(updatedEq);
        _trabajosCtrl.clear();
        _solicitaReparacion = false;
        _detalleReparacionCtrl.clear();
      });
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF10B981),
        content: Text(
          db.offlineMode
              ? 'Parte Diario #${parte.numeroParte} guardado en memoria Offline del celular. Se sincronizará al detectar señal.'
              : 'Parte Diario #${parte.numeroParte} registrado y sincronizado con Windows Server.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = ErpDatabaseService.instance;
    final equiposElegibles = db.equipos
        .where((e) => e.categoria != AssetCategory.herramienta)
        .toList();

    final hIni = double.tryParse(_horometroInicialCtrl.text) ?? 0;
    final hFin = double.tryParse(_horometroFinalCtrl.text) ?? 0;
    final usoCalculado = (hFin - hIni).clamp(0, 999999);
    final superaraService = hFin >= _selectedEquipo.proximoServiceLectura;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 860;
              final formPanel = _buildFormPanel(
                context,
                db,
                equiposElegibles,
                usoCalculado: usoCalculado.toDouble(),
                superaraService: superaraService,
              );
              final historyPanel = _buildHistoryPanel(context, db);

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: formPanel),
                    const SizedBox(width: 18),
                    Expanded(flex: 5, child: historyPanel),
                  ],
                );
              }
              return Column(
                children: [
                  formPanel,
                  const SizedBox(height: 18),
                  historyPanel,
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFormPanel(
    BuildContext context,
    ErpDatabaseService db,
    List<EquipmentItem> equiposElegibles, {
    required double usoCalculado,
    required bool superaraService,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_turned_in_rounded, color: Color(0xFFF59E0B), size: 24),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CARGA DE PARTE DIARIO DE MAQUINARIA Y VEHÍCULOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Registro de horarios, horómetro/odómetro, trabajos, consumos, observaciones y solicitud de reparación',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: db.offlineMode
                      ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
                      : const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  db.offlineMode ? 'MODO OFFLINE ACTIVO' : 'CONECTADO AL SERVIDOR',
                  style: TextStyle(
                    color: db.offlineMode ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xFF334155), height: 24),

          // 1. Selección de Equipo y Frente de Obra
          const Text(
            '1. EQUIPO Y FRENTE DE OBRA',
            style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w900, fontSize: 12),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            initialValue: _selectedEquipo.id,
            isExpanded: true,
            dropdownColor: const Color(0xFF0F172A),
            style: const TextStyle(color: Colors.white, fontSize: 13.5),
            decoration: InputDecoration(
              labelText: 'Seleccionar Maquinaria o Vehículo (${equiposElegibles.length} disponibles)',
              labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: equiposElegibles
                .map(
                  (e) => DropdownMenuItem<int>(
                    value: e.id,
                    child: Text(
                      '${e.codigo} — ${e.tipoEquipoNombre} ${e.marcaNombre} ${e.modeloNombre} (${e.lecturaActual.toStringAsFixed(0)} ${e.categoria.meterUnit})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (id) {
              if (id == null) return;
              final eq = db.getEquipoById(id);
              if (eq != null) {
                setState(() {
                  _selectedEquipo = eq;
                  _applySelectedEquipo(eq);
                });
              }
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<int>(
                  initialValue: _selectedObraId,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF0F172A),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Frente de Obra',
                    labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: db.obras
                      .map((o) => DropdownMenuItem(value: o.id, child: Text(o.nombreObra)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedObraId = v!),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _fechaCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Fecha (AAAA-MM-DD)',
                    labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Horarios y Lectura de Horómetro / Odómetro
          Text(
            '2. HORARIO DE JORNADA Y ${(_selectedEquipo.categoria.meterLabel).toUpperCase()}',
            style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w900, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _horaInicioCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Hora de Inicio',
                    prefixIcon: const Icon(Icons.play_circle_outline, color: Color(0xFF38BDF8)),
                    labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _horaFinCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Hora de Finalización',
                    prefixIcon: const Icon(Icons.stop_circle_outlined, color: Color(0xFF38BDF8)),
                    labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                  controller: _horometroInicialCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Lectura Inicial (${_selectedEquipo.categoria.meterUnit})',
                    labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _horometroFinalCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Lectura Final (${_selectedEquipo.categoria.meterUnit})',
                    labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'TOTAL JORNADA',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${usoCalculado.toStringAsFixed(1)} ${_selectedEquipo.categoria.meterUnit}',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (superaraService) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFEF4444)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ALERTA PREVENTIVA: Con esta lectura final el equipo supera el límite de Service Programado (${_selectedEquipo.proximoServiceLectura.toStringAsFixed(0)} ${_selectedEquipo.categoria.meterUnit}). Se notificará al Taller.',
                      style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),

          // 3. Trabajos realizados
          const Text(
            '3. TRABAJOS REALIZADOS EN EL FRENTE DE OBRA',
            style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w900, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              'Excavación de zanja y carga en batea',
              'Perfilado y nivelación de base granular',
              'Carga de áridos en planta / tolva',
              'Compactación de terraplén por capas',
              'Transporte de suelo y materiales de cantera',
            ]
                .map(
                  (preset) => ActionChip(
                    backgroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(color: Color(0xFF334155)),
                    label: Text(
                      '+ $preset',
                      style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11.5),
                    ),
                    onPressed: () {
                      setState(() {
                        if (_trabajosCtrl.text.isEmpty) {
                          _trabajosCtrl.text = preset;
                        } else {
                          _trabajosCtrl.text = '${_trabajosCtrl.text}. $preset';
                        }
                      });
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _trabajosCtrl,
            maxLines: 2,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Describe las tareas realizadas, progresivas o sector de obra...',
              hintStyle: const TextStyle(color: Color(0xFF64748B)),
              filled: true,
              fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),

          // 4. Consumos: Combustible y Lubricantes
          const Text(
            '4. CONSUMOS: CARGA DE COMBUSTIBLE Y LUBRICANTES',
            style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w900, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ltsCombustibleCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Combustible (Lts)',
                    prefixIcon: const Icon(Icons.local_gas_station_rounded, color: Color(0xFFF59E0B)),
                    labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _tipoCombustible,
                  dropdownColor: const Color(0xFF0F172A),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Tipo Combustible',
                    labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Diesel', child: Text('Diesel / Gasoil')),
                    DropdownMenuItem(value: 'Nafta', child: Text('Nafta')),
                    DropdownMenuItem(value: 'GNC', child: Text('GNC')),
                    DropdownMenuItem(value: 'Electricidad', child: Text('Electricidad')),
                  ],
                  onChanged: (v) => setState(() => _tipoCombustible = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ltsLubricanteCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Lubricante Agregado (Lts)',
                    prefixIcon: const Icon(Icons.opacity_rounded, color: Color(0xFF38BDF8)),
                    labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _tipoLubricante,
                  dropdownColor: const Color(0xFF0F172A),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Parte / Tipo de Lubricante',
                    labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Sin agregado', child: Text('Sin agregado')),
                    DropdownMenuItem(value: 'SAE 15W-40 Motor', child: Text('SAE 15W-40 Motor')),
                    DropdownMenuItem(value: 'Hidráulico ISO VG 68', child: Text('Hidráulico ISO VG 68')),
                    DropdownMenuItem(value: 'SAE 80W-90 Transmisión', child: Text('SAE 80W-90 Transmisión')),
                    DropdownMenuItem(value: 'Grasa Litio EP2 (Pernos)', child: Text('Grasa Litio EP2 (Pernos)')),
                  ],
                  onChanged: (v) => setState(() => _tipoLubricante = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _valeCargaCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'N° Vale de Carga',
                    labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _ordenCompraCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'N° Orden de Compra',
                    labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 5. Observaciones sobre funcionamiento y Solicitud de Reparación
          const Text(
            '5. OBSERVACIONES DE FUNCIONAMIENTO Y SOLICITUD DE REPARACIÓN',
            style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w900, fontSize: 12),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _observacionesCtrl,
            maxLines: 2,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Observaciones sobre el funcionamiento del equipo',
              labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _solicitaReparacion
                  ? const Color(0xFFEF4444).withValues(alpha: 0.14)
                  : const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _solicitaReparacion ? const Color(0xFFEF4444) : const Color(0xFF334155),
              ),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _solicitaReparacion,
                  activeThumbColor: const Color(0xFFEF4444),
                  onChanged: (v) => setState(() => _solicitaReparacion = v),
                  title: const Text(
                    '¿Solicitar Reparación / Revisión Mecánica al Taller?',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13.5),
                  ),
                  subtitle: const Text(
                    'Envía una alerta inmediata al Jefe de Taller y mecánicos de frente de obra.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                ),
                if (_solicitaReparacion) ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _urgenciaReparacion,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Nivel de Urgencia',
                      labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Normal', child: Text('Normal — Puede seguir operando')),
                      DropdownMenuItem(value: 'Alta', child: Text('Alta — Revisar en las próximas 24 hs')),
                      DropdownMenuItem(
                        value: 'Crítica - Equipo Detenido',
                        child: Text('Crítica — Equipo Detenido en Obra'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _urgenciaReparacion = v!),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _detalleReparacionCtrl,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Detalle de la falla o repuesto requerido',
                      hintText: 'Ej. Pérdida en manguera de cilindro de balde / ruido en bomba hidráulica...',
                      hintStyle: const TextStyle(color: Color(0xFF64748B)),
                      labelStyle: const TextStyle(color: Color(0xFFFCA5A5)),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _guardarParte,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.save_rounded),
              label: const Text(
                'REGISTRAR PARTE DIARIO',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryPanel(BuildContext context, ErpDatabaseService db) {
    final partes = db.partesDiarios;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_edu_rounded, color: Color(0xFF38BDF8), size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Últimos Partes Diarios Cargados (${partes.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...partes.map((p) {
            final obra = db.getObraById(p.obraId);
            final eq = db.getEquipoById(p.equipoId);
            final unit = eq?.categoria.meterUnit ?? 'hs';

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: p.solicitaReparacion
                      ? const Color(0xFFEF4444).withValues(alpha: 0.7)
                      : const Color(0xFF334155),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          p.equipoCodigo,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Parte #${p.numeroParte} · ${p.fecha}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: p.sincronizadoServidor
                              ? const Color(0xFF10B981).withValues(alpha: 0.15)
                              : const Color(0xFFF59E0B).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          p.sincronizadoServidor ? 'Sincronizado' : 'Cola Offline',
                          style: TextStyle(
                            color: p.sincronizadoServidor
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Horario: ${p.horaInicio} a ${p.horaFin} · Lectura: ${p.horometroInicial.toStringAsFixed(0)} → ${p.horometroFinal.toStringAsFixed(0)} (${p.usoRegistrado.toStringAsFixed(1)} $unit)',
                    style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Obra: ${obra.nombreObra} · Operario: ${p.operarioNombre}',
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.trabajosRealizados,
                    style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Consumos: ${p.ltsCombustible.toStringAsFixed(0)} Lts ${p.tipoCombustible} (Vale ${p.nroValeCarga}) · Lub.: ${p.ltsLubricante.toStringAsFixed(1)} Lts (${p.tipoLubricante})',
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5),
                  ),
                  if (p.solicitaReparacion) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.build_circle_rounded, color: Color(0xFFEF4444), size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'SOLICITUD DE REPARACIÓN (${p.urgenciaReparacion}): ${p.detalleSolicitudReparacion}',
                              style: const TextStyle(
                                color: Color(0xFFFCA5A5),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
