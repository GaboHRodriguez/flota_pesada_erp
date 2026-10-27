import 'package:flutter/material.dart';
import '../models/erp_models.dart';
import '../services/erp_database_service.dart';
import '../widgets/despiece_tecnico_widget.dart';

class FlotaEquiposScreen extends StatefulWidget {
  final void Function(EquipmentItem equipo)? onGoToParteDiario;
  final void Function(EquipmentItem equipo)? onGoToTaller;

  const FlotaEquiposScreen({
    super.key,
    this.onGoToParteDiario,
    this.onGoToTaller,
  });

  @override
  State<FlotaEquiposScreen> createState() => _FlotaEquiposScreenState();
}

class _FlotaEquiposScreenState extends State<FlotaEquiposScreen> {
  String _searchQuery = '';
  AssetCategory? _selectedCategory; // null = Todos
  int? _selectedObraId; // null = Todas las obras
  String _selectedEstado = 'Todos';
  bool _soloConAlertaService = false;

  @override
  Widget build(BuildContext context) {
    final db = ErpDatabaseService.instance;
    final user = db.currentUser;
    final canCreateOrEditEquipment =
        user?.role == UserRole.superUsuario || user?.role == UserRole.administrador;
    final canAssignObra =
        user?.role == UserRole.superUsuario || user?.role == UserRole.gerencia;

    final filtered = db.equipos.where((eq) {
      if (_selectedCategory != null && eq.categoria != _selectedCategory) {
        return false;
      }
      if (_selectedObraId != null && eq.obraActualId != _selectedObraId) {
        return false;
      }
      if (_selectedEstado != 'Todos' && eq.estado.toLowerCase() != _selectedEstado.toLowerCase()) {
        return false;
      }
      if (_soloConAlertaService && !(eq.requiereServiceUrgente || eq.requiereServiceProximo)) {
        return false;
      }
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = eq.codigo.toLowerCase().contains(q) ||
            eq.dominio.toLowerCase().contains(q) ||
            eq.marcaNombre.toLowerCase().contains(q) ||
            eq.modeloNombre.toLowerCase().contains(q) ||
            eq.tipoEquipoNombre.toLowerCase().contains(q) ||
            eq.nChasis.toLowerCase().contains(q);
        if (!match) return false;
      }
      return true;
    }).toList();

    final countMaquinaria =
        db.equipos.where((e) => e.categoria == AssetCategory.maquinariaPesada).length;
    final countVehiculos = db.equipos.where((e) => e.categoria == AssetCategory.vehiculo).length;
    final countHerramientas =
        db.equipos.where((e) => e.categoria == AssetCategory.herramienta).length;

    return Column(
      children: [
        // Barra superior de búsqueda, categorías y filtros
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          decoration: const BoxDecoration(
            color: Color(0xFF1E293B),
            border: Border(bottom: BorderSide(color: Color(0xFF334155))),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: const TextStyle(color: Colors.white, fontSize: 13.5),
                      decoration: InputDecoration(
                        hintText:
                            'Buscar por código (ej. PC008, RE016, MN004, CA020), patente, marca, modelo o rubro...',
                        hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFF59E0B)),
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF334155)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF334155)),
                        ),
                      ),
                    ),
                  ),
                  if (canCreateOrEditEquipment) ...[
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => _showEquipmentFormModal(context, null),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                      label: const Text(
                        'Nuevo Equipo',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              // Chips de categoría macro
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip(null, 'Toda la Flota (${db.equipos.length})', Icons.apps_rounded),
                    const SizedBox(width: 8),
                    _buildCategoryChip(
                      AssetCategory.maquinariaPesada,
                      'Maquinaria Pesada ($countMaquinaria)',
                      Icons.front_loader,
                    ),
                    const SizedBox(width: 8),
                    _buildCategoryChip(
                      AssetCategory.vehiculo,
                      'Vehículos y Rodados ($countVehiculos)',
                      Icons.local_shipping_rounded,
                    ),
                    const SizedBox(width: 8),
                    _buildCategoryChip(
                      AssetCategory.herramienta,
                      'Herramientas y Menores ($countHerramientas)',
                      Icons.handyman_rounded,
                    ),
                    const SizedBox(width: 12),
                    FilterChip(
                      selected: _soloConAlertaService,
                      onSelected: (v) => setState(() => _soloConAlertaService = v),
                      selectedColor: const Color(0xFFEF4444).withValues(alpha: 0.25),
                      backgroundColor: const Color(0xFF0F172A),
                      side: BorderSide(
                        color: _soloConAlertaService ? const Color(0xFFEF4444) : const Color(0xFF334155),
                      ),
                      avatar: const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 16),
                      label: Text(
                        'Service Vencido/Próximo',
                        style: TextStyle(
                          color: _soloConAlertaService ? Colors.white : const Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Filtros de Obra y Estado
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int?>(
                      initialValue: _selectedObraId,
                      dropdownColor: const Color(0xFF1E293B),
                      style: const TextStyle(color: Colors.white, fontSize: 12.5),
                      decoration: InputDecoration(
                        labelText: 'Filtrar por Frente de Obra',
                        labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Todas las Obras / Ubicaciones'),
                        ),
                        ...db.obras.map(
                          (o) => DropdownMenuItem<int?>(
                            value: o.id,
                            child: Text(
                              o.nombreObra,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => _selectedObraId = v),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 170,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedEstado,
                      dropdownColor: const Color(0xFF1E293B),
                      style: const TextStyle(color: Colors.white, fontSize: 12.5),
                      decoration: InputDecoration(
                        labelText: 'Estado Operativo',
                        labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Todos', child: Text('Todos los estados')),
                        DropdownMenuItem(value: 'En uso', child: Text('En uso')),
                        DropdownMenuItem(value: 'En Reparación', child: Text('En Reparación')),
                        DropdownMenuItem(value: 'Alquilada', child: Text('Alquilada')),
                        DropdownMenuItem(value: 'Baja', child: Text('Baja')),
                        DropdownMenuItem(value: 'Robado', child: Text('Robado')),
                      ],
                      onChanged: (v) => setState(() => _selectedEstado = v ?? 'Todos'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Listado de Equipos
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text(
                    'No se encontraron equipos con los filtros seleccionados.',
                    style: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final eq = filtered[index];
                    final obra = db.getObraById(eq.obraActualId);
                    return _buildEquipoCard(
                      context,
                      eq,
                      obra,
                      canCreateOrEditEquipment: canCreateOrEditEquipment,
                      canAssignObra: canAssignObra,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(AssetCategory? cat, String text, IconData icon) {
    final isSelected = _selectedCategory == cat;
    return ChoiceChip(
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedCategory = cat),
      selectedColor: const Color(0xFFF59E0B).withValues(alpha: 0.25),
      backgroundColor: const Color(0xFF0F172A),
      side: BorderSide(color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFF334155)),
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8),
      ),
      label: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF94A3B8),
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _estadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'en uso':
        return const Color(0xFF10B981);
      case 'en reparación':
        return const Color(0xFFF59E0B);
      case 'alquilada':
        return const Color(0xFF38BDF8);
      case 'baja':
      case 'robado':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  Widget _buildEquipoCard(
    BuildContext context,
    EquipmentItem eq,
    ObraSite obra, {
    required bool canCreateOrEditEquipment,
    required bool canAssignObra,
  }) {
    final estColor = _estadoColor(eq.estado);

    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: eq.requiereServiceUrgente
              ? const Color(0xFFEF4444).withValues(alpha: 0.7)
              : const Color(0xFF334155),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showFichaTecnicaIntegralModal(
          context,
          eq,
          canCreateOrEditEquipment: canCreateOrEditEquipment,
          canAssignObra: canAssignObra,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.6)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          eq.codigo,
                          style: const TextStyle(
                            color: Color(0xFFF59E0B),
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                        if (eq.dominio.isNotEmpty)
                          Text(
                            eq.dominio,
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10.5),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                eq.descripcionCompleta,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14.5,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: estColor.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: estColor.withValues(alpha: 0.6)),
                              ),
                              child: Text(
                                eq.estado.toUpperCase(),
                                style: TextStyle(
                                  color: estColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          children: [
                            _buildMetaItem(
                              Icons.location_on_outlined,
                              obra.nombreObra,
                              const Color(0xFF38BDF8),
                            ),
                            if (eq.potencia > 0)
                              _buildMetaItem(
                                Icons.bolt_rounded,
                                '${eq.potencia.toStringAsFixed(0)} ${eq.unidadPotencia}',
                                const Color(0xFFF59E0B),
                              ),
                            _buildMetaItem(
                              Icons.settings_suggest_rounded,
                              'Tracción: ${eq.traccionNombre}',
                              const Color(0xFF94A3B8),
                            ),
                            if (eq.anio > 0)
                              _buildMetaItem(
                                Icons.calendar_today_rounded,
                                'Año ${eq.anio}',
                                const Color(0xFF94A3B8),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    if (eq.categoria != AssetCategory.herramienta) ...[
                      Icon(
                        Icons.speed_rounded,
                        size: 16,
                        color: eq.requiereServiceUrgente
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF10B981),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${eq.categoria.meterLabel}: ${eq.lecturaActual.toStringAsFixed(0)} ${eq.categoria.meterUnit}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (eq.requiereServiceUrgente)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'SERVICE VENCIDO (${eq.restanteParaService.abs().toStringAsFixed(0)} ${eq.categoria.meterUnit} exc.)',
                            style: const TextStyle(
                              color: Color(0xFFFCA5A5),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        )
                      else
                        Text(
                          'Próx. Service: ${eq.proximoServiceLectura.toStringAsFixed(0)} ${eq.categoria.meterUnit}',
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5),
                        ),
                    ] else ...[
                      const Icon(Icons.person_pin_circle_rounded, size: 16, color: Color(0xFF38BDF8)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Asignada a: ${eq.responsableActual} · Control por Pañol y Frente de Obra',
                          style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    const Spacer(),
                    const Text(
                      'Ver Ficha, Despiece y Repuestos →',
                      style: TextStyle(
                        color: Color(0xFFF59E0B),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _showFichaTecnicaIntegralModal(
    BuildContext context,
    EquipmentItem eq, {
    required bool canCreateOrEditEquipment,
    required bool canAssignObra,
  }) {
    final db = ErpDatabaseService.instance;
    final obra = db.getObraById(eq.obraActualId);
    final filtros = db.getFiltrosParaEquipo(eq);
    final partes = db.getPartesPorEquipo(eq.id);
    final informes = db.getInformesPorEquipo(eq.id);
    final gastos = db.getGastosPorEquipo(eq.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.90,
          maxChildSize: 0.96,
          minChildSize: 0.60,
          builder: (_, scrollController) {
            return DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  // Cabecera del modal
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E293B),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                eq.codigo,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    eq.descripcionCompleta,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Dominio/Serie: ${eq.dominio.isEmpty ? "Interno" : eq.dominio} · Ubicación: ${obra.nombreObra}',
                                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(ctx),
                              icon: const Icon(Icons.close_rounded, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Botones de acción rápida según nivel de usuario
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (eq.categoria != AssetCategory.herramienta &&
                                widget.onGoToParteDiario != null)
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  widget.onGoToParteDiario!(eq);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                icon: const Icon(Icons.assignment_add, size: 16),
                                label: const Text('Cargar Parte Diario', style: TextStyle(fontSize: 12)),
                              ),
                            if (widget.onGoToTaller != null &&
                                (db.currentUser?.role == UserRole.taller ||
                                    db.currentUser?.role == UserRole.superUsuario))
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  widget.onGoToTaller!(eq);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD97706),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                icon: const Icon(Icons.build_rounded, size: 16),
                                label: const Text('Informe de Taller', style: TextStyle(fontSize: 12)),
                              ),
                            if (canAssignObra || eq.categoria == AssetCategory.herramienta)
                              OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  _showDesignarObraDialog(context, eq);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF38BDF8),
                                  side: const BorderSide(color: Color(0xFF38BDF8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                                label: Text(
                                  eq.categoria == AssetCategory.herramienta
                                      ? 'Asignar Obra / Responsable'
                                      : 'Designar / Retirar de Obra',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            if (canCreateOrEditEquipment)
                              OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  _showEquipmentFormModal(context, eq);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF10B981),
                                  side: const BorderSide(color: Color(0xFF10B981)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                icon: const Icon(Icons.edit_rounded, size: 16),
                                label: const Text('Editar Datos', style: TextStyle(fontSize: 12)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const TabBar(
                          isScrollable: true,
                          indicatorColor: Color(0xFFF59E0B),
                          labelColor: Color(0xFFF59E0B),
                          unselectedLabelColor: Color(0xFF94A3B8),
                          tabs: [
                            Tab(text: '1. Ficha Técnica y Fluidos'),
                            Tab(text: '2. Despiece Interactivo CAD'),
                            Tab(text: '3. Despiece Oficial vs. Empírico'),
                            Tab(text: '4. Historial Partes y Taller'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: TabBarView(
                      children: [
                        // TAB 1: Ficha Técnica
                        ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(18),
                          children: [
                            _buildSpecSectionTitle('Datos Técnicos y Motorización'),
                            _buildSpecGrid([
                              MapEntry('Código Interno', eq.codigo),
                              MapEntry('Rubro / Tipo', eq.tipoEquipoNombre),
                              MapEntry('Marca', eq.marcaNombre),
                              MapEntry('Modelo', eq.modeloNombre.isEmpty ? 'Estándar' : eq.modeloNombre),
                              MapEntry('Potencia Nominal', '${eq.potencia.toStringAsFixed(0)} ${eq.unidadPotencia}'),
                              MapEntry('Tipo de Tracción', eq.traccionNombre),
                              MapEntry('N° de Chasis / Serie', eq.nChasis.isEmpty ? 'S/N' : eq.nChasis),
                              MapEntry('N° de Motor', eq.nMotor.isEmpty ? 'S/N' : eq.nMotor),
                              MapEntry('Año de Fabricación', eq.anio > 0 ? '${eq.anio}' : 'S/D'),
                              MapEntry('Combustible', '${eq.tipoCombustible} (${eq.capacidadTanqueLts.toStringAsFixed(0)} Lts)'),
                            ]),
                            const SizedBox(height: 16),
                            _buildSpecSectionTitle('Lubricantes, Capacidades y Plan Preventivo'),
                            _buildSpecGrid([
                              MapEntry('Aceite de Motor', eq.aceiteMotorSpec),
                              MapEntry('Fluido Hidráulico', eq.aceiteHidraulicoSpec),
                              MapEntry('Transmisión / Reductor', eq.aceiteTransmisionSpec),
                              MapEntry(
                                'Lectura Actual',
                                '${eq.lecturaActual.toStringAsFixed(0)} ${eq.categoria.meterUnit}',
                              ),
                              MapEntry(
                                'Próximo Service',
                                '${eq.proximoServiceLectura.toStringAsFixed(0)} ${eq.categoria.meterUnit}',
                              ),
                              MapEntry(
                                'Intervalo Preventivo',
                                'Cada ${eq.intervaloService.toStringAsFixed(0)} ${eq.categoria.meterUnit}',
                              ),
                            ]),
                            const SizedBox(height: 16),
                            _buildSpecSectionTitle('Valuación, Costos Operativos y Seguro'),
                            _buildSpecGrid([
                              MapEntry('Valor de Compra', 'USD ${eq.valCompra.toStringAsFixed(0)}'),
                              MapEntry('Canon / Costo Mensual', 'USD ${eq.pMensual.toStringAsFixed(0)} / mes'),
                              MapEntry('Costo en Stand-By', 'USD ${eq.pStandby.toStringAsFixed(0)} / mes'),
                              MapEntry('Aseguradora', eq.seguroCompania.isEmpty ? 'Póliza Flota General' : eq.seguroCompania),
                              MapEntry('N° de Póliza', eq.nPoliza.isEmpty ? 'Flota Corporativa' : eq.nPoliza),
                              MapEntry('Vencimiento Póliza', eq.vencimientoSeguro.isEmpty ? 'Vigente' : eq.vencimientoSeguro),
                            ]),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Observaciones Técnicas: ${eq.notasTecnicas}',
                                style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 13),
                              ),
                            ),
                          ],
                        ),

                        // TAB 2: Despiece Interactivo CAD
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(18),
                          child: DespieceTecnicoWidget(
                            equipo: eq,
                            filtrosCompatibles: filtros,
                          ),
                        ),

                        // TAB 3: Despiece Oficial (CSV) vs. Despiece Empírico (Órdenes de Trabajo)
                        Builder(
                          builder: (tabCtx) {
                            final despieceOficial = db.getDespieceOficialForEquipo(eq);
                            final despieceEmpirico = db.getDespieceEmpiricoForEquipo(eq);
                            return ListView(
                              padding: const EdgeInsets.all(18),
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: _buildSpecSectionTitle(
                                        '1. Despiece Oficial (`despiece_equipos` — ${despieceOficial.length} piezas)',
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        await _showImportarDespieceCsvModal(context, eq);
                                        if (mounted) setState(() {});
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF10B981),
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                      icon: const Icon(Icons.upload_file_rounded, size: 16),
                                      label: const Text(
                                        'Importar Despiece CSV',
                                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                if (despieceOficial.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text(
                                      'Sin piezas cargadas aún en el Despiece Oficial. Usa el botón "Importar Despiece CSV" para cargar el manual.',
                                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5),
                                    ),
                                  ),
                                ...despieceOficial.map(
                                  (ofItem) => Card(
                                    color: const Color(0xFF1E293B),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      dense: true,
                                      leading: CircleAvatar(
                                        radius: 16,
                                        backgroundColor: const Color(0xFF38BDF8).withValues(alpha: 0.18),
                                        child: const Icon(
                                          Icons.verified_rounded,
                                          color: Color(0xFF38BDF8),
                                          size: 18,
                                        ),
                                      ),
                                      title: Text(
                                        '${ofItem['numero_parte_oem']} — ${ofItem['descripcion']}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Sistema: ${ofItem['sistema_nombre']} · Cant./Máquina: ${ofItem['cantidad_por_equipo']} · Origen: ${ofItem['origen']}',
                                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5),
                                      ),
                                      trailing: Text(
                                        'Pañol: ${ofItem['stock_actual']}',
                                        style: const TextStyle(
                                          color: Color(0xFF10B981),
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildSpecSectionTitle(
                                  '2. Despiece Empírico (`repuestos_utilizados` en Taller — ${despieceEmpirico.length} piezas)',
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    'Se construye automáticamente a partir de los repuestos realmente consumidos en Órdenes de Trabajo sobre este equipo.',
                                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                  ),
                                ),
                                if (despieceEmpirico.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text(
                                      'Aún no se registran repuestos consumidos en órdenes de trabajo para este equipo.',
                                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12.5),
                                    ),
                                  ),
                                ...despieceEmpirico.map((emp) {
                                  final enOficial = emp['estaEnOficial'] == true;
                                  return Card(
                                    color: const Color(0xFF1E293B),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      dense: true,
                                      leading: CircleAvatar(
                                        radius: 16,
                                        backgroundColor: (enOficial
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFFF59E0B))
                                            .withValues(alpha: 0.2),
                                        child: Icon(
                                          enOficial ? Icons.check_circle_rounded : Icons.auto_fix_high_rounded,
                                          color: enOficial
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFFF59E0B),
                                          size: 18,
                                        ),
                                      ),
                                      title: Text(
                                        '${emp['numero_parte_oem']} — ${emp['descripcion']}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Intervenciones: ${emp['veces_reemplazado']} · Total usado: ${emp['total_unidades_usadas']} u. · Último uso: ${emp['ultima_fecha_uso']}',
                                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5),
                                      ),
                                      trailing: enOficial
                                          ? Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                'En Manual Oficial',
                                                style: TextStyle(
                                                  color: Color(0xFF10B981),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            )
                                          : TextButton.icon(
                                              onPressed: () async {
                                                await db.promoverPiezaEmpiricaADespieceOficial(
                                                  equipo: eq,
                                                  numeroParteOem: emp['numero_parte_oem'].toString(),
                                                  descripcion: emp['descripcion'].toString(),
                                                  sistemaNombre: emp['sistema_nombre'].toString(),
                                                );
                                                if (mounted) setState(() {});
                                              },
                                              icon: const Icon(
                                                Icons.add_task_rounded,
                                                size: 15,
                                                color: Color(0xFFF59E0B),
                                              ),
                                              label: const Text(
                                                'Sumar al Oficial',
                                                style: TextStyle(
                                                  color: Color(0xFFF59E0B),
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                    ),
                                  );
                                }),
                                const SizedBox(height: 16),
                                _buildSpecSectionTitle(
                                  '3. Catálogo de Filtros Equivalentes y Ubicación en Pañol',
                                ),
                                ...filtros.map(
                                  (f) => Card(
                                    color: const Color(0xFF1E293B),
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                                        child: const Icon(
                                          Icons.filter_alt_rounded,
                                          color: Color(0xFFF59E0B),
                                        ),
                                      ),
                                      title: Text(
                                        '${f.tipoComponente} — ${f.codigoOriginal}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Equivalencia: ${f.equivalenciaMannFram}',
                                            style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12),
                                          ),
                                          Text(
                                            'Plano Despiece: ${f.referenciaPlanoDespiece} · Ubicación: ${f.ubicacionEstanteria}',
                                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5),
                                          ),
                                        ],
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Stock: ${f.stockActual}',
                                            style: TextStyle(
                                              color: f.stockCritico
                                                  ? const Color(0xFFEF4444)
                                                  : const Color(0xFF10B981),
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          Text(
                                            'USD ${f.costoUnitarioUsd.toStringAsFixed(0)}',
                                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        // TAB 4: Historial de Partes Diarios, Taller y Gastos
                        ListView(
                          padding: const EdgeInsets.all(18),
                          children: [
                            _buildSpecSectionTitle('Informes de Taller y Mantenimiento (${informes.length})'),
                            if (informes.isEmpty)
                              const Text(
                                'Sin intervenciones de taller registradas.',
                                style: TextStyle(color: Color(0xFF94A3B8)),
                              ),
                            ...informes.map(
                              (inf) => Card(
                                color: const Color(0xFF1E293B),
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(
                                    '${inf.fecha} · ${inf.tipoIntervencion} (${inf.estadoOrden})',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${inf.observaciones}\nMecánico: ${inf.mecanicoResponsable} · Costo Total: USD ${inf.costoTotal.toStringAsFixed(0)}',
                                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _buildSpecSectionTitle('Partes Diarios Registrados (${partes.length})'),
                            if (partes.isEmpty)
                              const Text(
                                'Sin partes diarios cargados recientemente.',
                                style: TextStyle(color: Color(0xFF94A3B8)),
                              ),
                            ...partes.map(
                              (p) => Card(
                                color: const Color(0xFF1E293B),
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(
                                    'Parte #${p.numeroParte} (${p.fecha}) · ${p.horaInicio} a ${p.horaFin}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Lectura: ${p.horometroInicial.toStringAsFixed(0)} → ${p.horometroFinal.toStringAsFixed(0)} (${p.usoRegistrado.toStringAsFixed(1)} ${eq.categoria.meterUnit})\nCombustible: ${p.ltsCombustible.toStringAsFixed(0)} Lts · Operario: ${p.operarioNombre}\n${p.trabajosRealizados}',
                                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _buildSpecSectionTitle('Gastos Imputados al Equipo (${gastos.length})'),
                            ...gastos.map(
                              (g) => ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  '${g.fecha} · ${g.categoriaGasto} — USD ${g.montoUsd.toStringAsFixed(2)}',
                                  style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w700),
                                ),
                                subtitle: Text(
                                  '${g.descripcion} (${g.proveedor})',
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSpecSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFFF59E0B),
          fontWeight: FontWeight.w900,
          fontSize: 12.5,
          letterSpacing: 0.7,
        ),
      ),
    );
  }

  Widget _buildSpecGrid(List<MapEntry<String, String>> items) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items
          .map(
            (e) => Container(
              width: 210,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.key,
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    e.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  void _showDesignarObraDialog(BuildContext context, EquipmentItem eq) {
    final db = ErpDatabaseService.instance;
    int selectedObraId = eq.obraActualId;
    String selectedTipoMov = 'Designación a Obra';
    String selectedEstado = eq.estado;
    final respCtrl = TextEditingController(text: eq.responsableActual);
    final motivoCtrl = TextEditingController(
      text: 'Asignación operativa autorizada para trabajos en frente de obra.',
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: Text(
            'Designar / Retirar Equipo ${eq.codigo}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedTipoMov,
                  dropdownColor: const Color(0xFF0F172A),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Movimiento',
                    labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Designación a Obra', child: Text('Designación a Frente de Obra')),
                    DropdownMenuItem(
                      value: 'Transferencia entre Obras',
                      child: Text('Transferencia entre Frentes de Obra'),
                    ),
                    DropdownMenuItem(
                      value: 'Retiro a Taller/Depósito',
                      child: Text('Retiro de Obra a Taller Central / Depósito'),
                    ),
                  ],
                  onChanged: (v) {
                    setDialogState(() {
                      selectedTipoMov = v!;
                      if (selectedTipoMov == 'Retiro a Taller/Depósito') {
                        selectedObraId = 5;
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: selectedObraId,
                  dropdownColor: const Color(0xFF0F172A),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Frente de Obra / Destino',
                    labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                  items: db.obras
                      .map((o) => DropdownMenuItem(value: o.id, child: Text(o.nombreObra)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedObraId = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedEstado,
                  dropdownColor: const Color(0xFF0F172A),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Nuevo Estado Operativo',
                    labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'En uso', child: Text('En uso')),
                    DropdownMenuItem(value: 'En Reparación', child: Text('En Reparación')),
                    DropdownMenuItem(value: 'Alquilada', child: Text('Alquilada')),
                    DropdownMenuItem(value: 'Baja', child: Text('Baja')),
                  ],
                  onChanged: (v) => setDialogState(() => selectedEstado = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: respCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Operario / Responsable Asignado',
                    labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: motivoCtrl,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Motivo / Observaciones de Traslado',
                    labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                await db.designarORetirarEquipoDeObra(
                  equipoId: eq.id,
                  obraDestinoId: selectedObraId,
                  tipoMovimiento: selectedTipoMov,
                  nuevoEstadoEquipo: selectedEstado,
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
              child: const Text('Confirmar Movimiento', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEquipmentFormModal(BuildContext context, EquipmentItem? existing) {
    final db = ErpDatabaseService.instance;
    final isNew = existing == null;
    final codigoCtrl = TextEditingController(text: existing?.codigo ?? 'PC014');
    final dominioCtrl = TextEditingController(text: existing?.dominio ?? 'AG 910 KL');
    final marcaCtrl = TextEditingController(text: existing?.marcaNombre ?? 'CATERPILLAR');
    final modeloCtrl = TextEditingController(text: existing?.modeloNombre ?? '924K');
    final tipoCtrl = TextEditingController(text: existing?.tipoEquipoNombre ?? 'Pala Cargadoras');
    final potenciaCtrl = TextEditingController(text: (existing?.potencia ?? 145).toStringAsFixed(0));
    final chasisCtrl = TextEditingController(text: existing?.nChasis ?? '');
    final motorCtrl = TextEditingController(text: existing?.nMotor ?? '');
    final valCompraCtrl = TextEditingController(text: (existing?.valCompra ?? 95000).toStringAsFixed(0));
    final pMensualCtrl = TextEditingController(text: (existing?.pMensual ?? 3800).toStringAsFixed(0));
    final lecturaCtrl = TextEditingController(text: (existing?.lecturaActual ?? 0).toStringAsFixed(0));
    AssetCategory selectedCat = existing?.categoria ?? AssetCategory.maquinariaPesada;
    int selectedObraId = existing?.obraActualId ?? 1;
    String selectedEstado = existing?.estado ?? 'En uso';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: Text(
            isNew ? 'Alta de Nuevo Equipo / Herramienta' : 'Editar Equipo ${existing.codigo}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<AssetCategory>(
                    initialValue: selectedCat,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Categoría Principal',
                      labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                    items: AssetCategory.values
                        .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => selectedCat = v!),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: codigoCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Código Interno (ej. PC014)',
                            labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: dominioCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Dominio / Patente',
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
                          controller: marcaCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Marca',
                            labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: modeloCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Modelo',
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
                          controller: tipoCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Tipo (ej. Retroexcavadoras)',
                            labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: potenciaCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Potencia (HP/W)',
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
                          controller: chasisCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'N° de Chasis',
                            labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: motorCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'N° de Motor',
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
                          controller: valCompraCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Valor Compra (USD)',
                            labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: pMensualCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Costo Mensual (USD)',
                            labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: lecturaCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Lectura Inicial (${selectedCat.meterLabel})',
                      labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    initialValue: selectedObraId,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Frente de Obra Asignado',
                      labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                    items: db.obras
                        .map((o) => DropdownMenuItem(value: o.id, child: Text(o.nombreObra)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => selectedObraId = v!),
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
                final pot = double.tryParse(potenciaCtrl.text) ?? 120;
                final vc = double.tryParse(valCompraCtrl.text) ?? 50000;
                final pm = double.tryParse(pMensualCtrl.text) ?? 2000;
                final lec = double.tryParse(lecturaCtrl.text) ?? 0;

                final item = (existing ??
                        EquipmentItem(
                          id: 0,
                          codigo: codigoCtrl.text.trim(),
                          dominio: dominioCtrl.text.trim(),
                          anio: 2024,
                          estado: selectedEstado,
                          marcaId: 10,
                          marcaNombre: marcaCtrl.text.trim(),
                          modeloNombre: modeloCtrl.text.trim(),
                          tipoEquipoId: 29,
                          tipoEquipoNombre: tipoCtrl.text.trim(),
                          categoria: selectedCat,
                          traccionId: 1,
                          traccionNombre: 'Neumáticos',
                          potencia: pot,
                          nChasis: chasisCtrl.text.trim(),
                          nMotor: motorCtrl.text.trim(),
                          valCompra: vc,
                          pMensual: pm,
                          pStandby: pm * 0.45,
                          obraActualId: selectedObraId,
                          lecturaActual: lec,
                          proximoServiceLectura:
                              lec + (selectedCat == AssetCategory.vehiculo ? 10000 : 250),
                          intervaloService: selectedCat == AssetCategory.vehiculo ? 10000 : 250,
                        ))
                    .copyWith(
                  codigo: codigoCtrl.text.trim(),
                  dominio: dominioCtrl.text.trim(),
                  marcaNombre: marcaCtrl.text.trim(),
                  modeloNombre: modeloCtrl.text.trim(),
                  tipoEquipoNombre: tipoCtrl.text.trim(),
                  categoria: selectedCat,
                  potencia: pot,
                  nChasis: chasisCtrl.text.trim(),
                  nMotor: motorCtrl.text.trim(),
                  valCompra: vc,
                  pMensual: pm,
                  obraActualId: selectedObraId,
                  lecturaActual: lec,
                );

                await db.agregarOEditarEquipo(item, esNuevo: isNew);
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.black,
              ),
              child: Text(isNew ? 'Guardar Equipo' : 'Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showImportarDespieceCsvModal(BuildContext context, EquipmentItem eq) async {
    final db = ErpDatabaseService.instance;
    final sampleCsv = 'codigo_interno,numero_parte_oem,descripcion_repuesto,sistema_nombre,cantidad_por_equipo\n'
        '${eq.codigo},1R-1808,Filtro de Aceite de Motor Alta Eficiencia,Motor,1\n'
        '${eq.codigo},1R-0749,Filtro de Combustible Secundario,Motor,1\n'
        '${eq.codigo},1G-8878,Filtro Hidraulico de Transmision,Hidraulica,2\n'
        '${eq.codigo},1U-3352,Diente / Una de Penetracion Serie J,Implementos y Corte,5';
    final csvCtrl = TextEditingController(text: sampleCsv);

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: Row(
          children: [
            const Icon(Icons.upload_file_rounded, color: Color(0xFF10B981)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Importar Despiece Oficial CSV (${eq.codigo})',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 640,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pega o edita las filas CSV para alimentar `despiece_equipos`, `repuestos_catalogo` y `sistemas_maquinaria` (respeta la restricción UNIQUE equipo_id + repuesto_id + sistema_id):',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: csvCtrl,
                maxLines: 9,
                style: const TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontFamily: 'monospace',
                  fontSize: 12.5,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final count = await db.importarDespieceOficialCsv(csvCtrl.text);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF065F46),
                    content: Text(
                      'Se importaron $count piezas al Despiece Oficial (`despiece_equipos`) y se sincronizaron con el servidor MySQL.',
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.black,
            ),
            icon: const Icon(Icons.cloud_upload_rounded, size: 17),
            label: const Text(
              'Importar a MySQL (`despiece_equipos`)',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
