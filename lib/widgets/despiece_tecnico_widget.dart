import 'package:flutter/material.dart';
import '../models/erp_models.dart';

class DespieceSubsystem {
  final int id;
  final String code;
  final String title;
  final String subtitle;
  final Offset normalizedPos; // 0..1 on schematic canvas
  final IconData icon;
  final Color color;
  final List<String> specs;
  final String oemReference;

  const DespieceSubsystem({
    required this.id,
    required this.code,
    required this.title,
    required this.subtitle,
    required this.normalizedPos,
    required this.icon,
    required this.color,
    required this.specs,
    required this.oemReference,
  });
}

class DespieceTecnicoWidget extends StatefulWidget {
  final EquipmentItem equipo;
  final List<FiltroRepuestoItem> filtrosCompatibles;

  const DespieceTecnicoWidget({
    super.key,
    required this.equipo,
    required this.filtrosCompatibles,
  });

  @override
  State<DespieceTecnicoWidget> createState() => _DespieceTecnicoWidgetState();
}

class _DespieceTecnicoWidgetState extends State<DespieceTecnicoWidget> {
  int _selectedIndex = 0;

  List<DespieceSubsystem> _buildSubsystems(EquipmentItem eq) {
    return [
      DespieceSubsystem(
        id: 1,
        code: 'GRP-01',
        title: 'Motorización, Inyección y Filtrado',
        subtitle: 'Block Motor ${eq.marcaNombre} · Serie ${eq.nMotor.isEmpty ? "OEM Estándar" : eq.nMotor}',
        normalizedPos: const Offset(0.26, 0.42),
        icon: Icons.settings_input_component_rounded,
        color: const Color(0xFFF59E0B),
        oemReference: 'Lámina 01-04 · Conjunto Motor y Alimentación ${eq.tipoCombustible}',
        specs: [
          'Potencia Nominal: ${eq.potencia.toStringAsFixed(0)} ${eq.unidadPotencia}',
          'Combustible: ${eq.tipoCombustible} (Tanque: ${eq.capacidadTanqueLts.toStringAsFixed(0)} Lts)',
          'Lubricante Motor: ${eq.aceiteMotorSpec}',
          'Intervalo Preventivo: Cada ${eq.intervaloService.toStringAsFixed(0)} ${eq.categoria.meterUnit}',
        ],
      ),
      DespieceSubsystem(
        id: 2,
        code: 'GRP-02',
        title: 'Sistema Hidráulico de Potencia y Cilindros',
        subtitle: 'Bomba Principal, Banco de Válvulas y Líneas de Alta Presión',
        normalizedPos: const Offset(0.58, 0.34),
        icon: Icons.compress_rounded,
        color: const Color(0xFF0EA5E9),
        oemReference: 'Lámina 11-14 · Circuito Hidráulico y Actuadores',
        specs: [
          'Fluido Hidráulico: ${eq.aceiteHidraulicoSpec}',
          'Capacidad del Sistema: ${eq.capacidad > 0 ? "${eq.capacidad.toStringAsFixed(0)} ${eq.unidadCapacidad}" : "Según nivel de visor"}',
          'Mangueras de Trabajo: SAE 100R2AT / 4SP con terminales JIC',
          'Control de Fugas: Revisar vástagos, retenes y racores en cada turno',
        ],
      ),
      DespieceSubsystem(
        id: 3,
        code: 'GRP-03',
        title: 'Transmisión, Convertidor y Mandos Finales',
        subtitle: 'Tracción: ${eq.traccionNombre} · Chasis ${eq.nChasis.isEmpty ? "Reforzado" : eq.nChasis}',
        normalizedPos: const Offset(0.42, 0.68),
        icon: Icons.all_inclusive_rounded,
        color: const Color(0xFF10B981),
        oemReference: 'Lámina 08-10 · Tren de Fuerza y Reductores',
        specs: [
          'Especificación Lubricante: ${eq.aceiteTransmisionSpec}',
          'Tipo de Tracción: ${eq.traccionNombre}',
          'Inspección: Nivel en caliente, temperatura de convertidor y respiraderos',
          'Chasis / Bastidor: ${eq.nChasis.isEmpty ? "Sin número registrado" : eq.nChasis}',
        ],
      ),
      DespieceSubsystem(
        id: 4,
        code: 'GRP-04',
        title: 'Herramienta de Corte / Trabajo y Articulaciones',
        subtitle: 'Balde, Vertedera, Pluma, Pernos y Bujes de Desgaste',
        normalizedPos: const Offset(0.82, 0.54),
        icon: Icons.construction_rounded,
        color: const Color(0xFFEC4899),
        oemReference: 'Lámina 18-22 · Implemento Frontal / Trasero y Desgaste',
        specs: [
          'Lubricación de Pernos: Grasa de Litio EP2 con MoS2 cada 10 hs',
          'Elementos de Desgaste: Uñas/Dientes, Cuchillas reversibles y Cantoneras',
          'Holgura Axial: Controlar bujes de balancín y articulación central',
          'Notas Técnicas: ${eq.notasTecnicas}',
        ],
      ),
      DespieceSubsystem(
        id: 5,
        code: 'GRP-05',
        title: 'Cabina, Instrumental y Sistema Eléctrico 12V/24V',
        subtitle: 'Alternador, Arranque, Sensores de Horómetro y Seguridad',
        normalizedPos: const Offset(0.42, 0.24),
        icon: Icons.electrical_services_rounded,
        color: const Color(0xFFA855F7),
        oemReference: 'Lámina 25-28 · Instalación Eléctrica y Tablero',
        specs: [
          'Lectura Actual: ${eq.lecturaActual.toStringAsFixed(0)} ${eq.categoria.meterUnit}',
          'Próximo Service: ${eq.proximoServiceLectura.toStringAsFixed(0)} ${eq.categoria.meterUnit}',
          'Seguridad Operativa: Alarma de retroceso, baliza LED, corte de corriente',
          'Estado Actual: ${eq.estado}',
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final subsystems = _buildSubsystems(widget.equipo);
    final selected = subsystems[_selectedIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado del plano interactivo
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.schema_rounded, color: Color(0xFFF59E0B), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'PLANO DE DESPIECE INTERACTIVO — ${widget.equipo.codigo} (${widget.equipo.marcaNombre} ${widget.equipo.modeloNombre})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Toca un nodo (1-5)',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Lienzo CAD con puntos interactivos
              SizedBox(
                height: 210,
                width: double.infinity,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _BlueprintSchematicPainter(
                              categoria: widget.equipo.categoria,
                              selectedIndex: _selectedIndex,
                              subsystems: subsystems,
                            ),
                          ),
                        ),
                        for (int i = 0; i < subsystems.length; i++)
                          Positioned(
                            left: (subsystems[i].normalizedPos.dx * constraints.maxWidth) - 20,
                            top: (subsystems[i].normalizedPos.dy * constraints.maxHeight) - 20,
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedIndex = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: _selectedIndex == i ? 42 : 34,
                                height: _selectedIndex == i ? 42 : 34,
                                decoration: BoxDecoration(
                                  color: _selectedIndex == i
                                      ? subsystems[i].color
                                      : const Color(0xFF1E293B).withValues(alpha: 0.92),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _selectedIndex == i ? Colors.white : subsystems[i].color,
                                    width: _selectedIndex == i ? 2.5 : 1.8,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: subsystems[i].color.withValues(alpha: 0.45),
                                      blurRadius: _selectedIndex == i ? 12 : 4,
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: _selectedIndex == i ? 15 : 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              // Selector de subsistemas en chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(subsystems.length, (i) {
                    final s = subsystems[i];
                    final isSel = i == _selectedIndex;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        selected: isSel,
                        onSelected: (_) => setState(() => _selectedIndex = i),
                        selectedColor: s.color.withValues(alpha: 0.25),
                        backgroundColor: const Color(0xFF1E293B),
                        side: BorderSide(color: isSel ? s.color : const Color(0xFF334155)),
                        label: Text(
                          '${i + 1}. ${s.code}',
                          style: TextStyle(
                            color: isSel ? Colors.white : const Color(0xFF94A3B8),
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Detalle del Subsistema seleccionado
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected.color.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: selected.color.withValues(alpha: 0.2),
                    child: Icon(selected.icon, color: selected.color, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${selected.code} — ${selected.title}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          selected.oemReference,
                          style: TextStyle(color: selected.color, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(color: Color(0xFF334155), height: 20),
              ...selected.specs.map(
                (sp) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 16, color: selected.color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          sp,
                          style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BlueprintSchematicPainter extends CustomPainter {
  final AssetCategory categoria;
  final int selectedIndex;
  final List<DespieceSubsystem> subsystems;

  _BlueprintSchematicPainter({
    required this.categoria,
    required this.selectedIndex,
    required this.subsystems,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Grid blueprint
    final gridPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1;

    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final linePaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..color = const Color(0xFF0EA5E9).withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Dibujo técnico esquemático según categoría (Maquinaria Pesada / Vehículo / Herramienta)
    final bodyPath = Path();
    if (categoria == AssetCategory.maquinariaPesada) {
      // Silueta técnica de Retroexcavadora / Pala Cargadora
      // Oruga / Tren rodante inferior
      final trackRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.16, h * 0.62, w * 0.44, h * 0.20),
        const Radius.circular(14),
      );
      canvas.drawRRect(trackRect, fillPaint);
      canvas.drawRRect(trackRect, linePaint);

      // Ruedas dentadas / rodillos internos
      for (double rx = 0.22; rx <= 0.54; rx += 0.08) {
        canvas.drawCircle(Offset(w * rx, h * 0.72), 9, linePaint);
      }

      // Chasis / Compartimiento Motor y Cabina
      bodyPath.moveTo(w * 0.14, h * 0.60);
      bodyPath.lineTo(w * 0.14, h * 0.36);
      bodyPath.lineTo(w * 0.34, h * 0.36);
      bodyPath.lineTo(w * 0.36, h * 0.16);
      bodyPath.lineTo(w * 0.50, h * 0.16);
      bodyPath.lineTo(w * 0.54, h * 0.60);
      bodyPath.close();
      canvas.drawPath(bodyPath, fillPaint);
      canvas.drawPath(bodyPath, linePaint);

      // Pluma y Brazo Hidráulico (Boom & Stick)
      final armPath = Path()
        ..moveTo(w * 0.52, h * 0.46)
        ..lineTo(w * 0.68, h * 0.22)
        ..lineTo(w * 0.84, h * 0.46)
        ..lineTo(w * 0.78, h * 0.52)
        ..lineTo(w * 0.66, h * 0.32)
        ..lineTo(w * 0.52, h * 0.54)
        ..close();
      canvas.drawPath(armPath, fillPaint);
      canvas.drawPath(armPath, linePaint);

      // Balde excavador / cargador
      final bucketPath = Path()
        ..moveTo(w * 0.78, h * 0.48)
        ..lineTo(w * 0.90, h * 0.48)
        ..arcToPoint(Offset(w * 0.82, h * 0.68), radius: const Radius.circular(22))
        ..close();
      canvas.drawPath(bucketPath, fillPaint);
      canvas.drawPath(bucketPath, linePaint);
    } else {
      // Silueta técnica de Camión / Camioneta / Equipo Vial
      bodyPath.moveTo(w * 0.14, h * 0.65);
      bodyPath.lineTo(w * 0.14, h * 0.42);
      bodyPath.lineTo(w * 0.28, h * 0.42);
      bodyPath.lineTo(w * 0.34, h * 0.22);
      bodyPath.lineTo(w * 0.48, h * 0.22);
      bodyPath.lineTo(w * 0.48, h * 0.32);
      bodyPath.lineTo(w * 0.86, h * 0.32);
      bodyPath.lineTo(w * 0.86, h * 0.65);
      bodyPath.close();
      canvas.drawPath(bodyPath, fillPaint);
      canvas.drawPath(bodyPath, linePaint);

      canvas.drawCircle(Offset(w * 0.26, h * 0.70), 18, linePaint);
      canvas.drawCircle(Offset(w * 0.70, h * 0.70), 18, linePaint);
      canvas.drawCircle(Offset(w * 0.80, h * 0.70), 18, linePaint);
    }

    // Líneas de cota conectando los nodos de despiece
    final connPaint = Paint()
      ..color = const Color(0xFF64748B).withValues(alpha: 0.45)
      ..strokeWidth = 1.2;

    for (int i = 0; i < subsystems.length - 1; i++) {
      final p1 = Offset(subsystems[i].normalizedPos.dx * w, subsystems[i].normalizedPos.dy * h);
      final p2 = Offset(subsystems[i + 1].normalizedPos.dx * w, subsystems[i + 1].normalizedPos.dy * h);
      canvas.drawLine(p1, p2, connPaint);
    }

    // Halo pulsante en el nodo seleccionado
    if (selectedIndex >= 0 && selectedIndex < subsystems.length) {
      final sel = subsystems[selectedIndex];
      final center = Offset(sel.normalizedPos.dx * w, sel.normalizedPos.dy * h);
      final haloPaint = Paint()
        ..color = sel.color.withValues(alpha: 0.22)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, 32, haloPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BlueprintSchematicPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex || oldDelegate.categoria != categoria;
  }
}
