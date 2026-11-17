import 'package:flutter/material.dart';
import '../data/equipment_schematics_catalog.dart';
import '../models/erp_models.dart';

class DespieceSubsystem {
  final int id;
  final String code;
  final String label;
  final String title;
  final String subtitle;
  final Offset normalizedPos; // 0..1 on schematic canvas (x/400, y/200)
  final IconData icon;
  final Color color;
  final List<String> specs;
  final String oemReference;

  const DespieceSubsystem({
    required this.id,
    required this.code,
    required this.label,
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

  List<DespieceSubsystem> _buildSubsystems(
    EquipmentItem eq,
    EquipmentSchematicSpec schematic,
  ) {
    final baseSpecs = [
      (
        code: 'GRP-01',
        subtitle:
            'Conjunto Principal ${eq.marcaNombre} · Serie ${eq.nMotor.isEmpty ? "OEM Estándar" : eq.nMotor}',
        icon: Icons.settings_input_component_rounded,
        color: const Color(0xFFF59E0B),
        oemRef: 'Lámina 01-04 · ${schematic.nombre} — Nodo 1',
        specs: [
          'Potencia Nominal: ${eq.potencia > 0 ? "${eq.potencia.toStringAsFixed(0)} ${eq.unidadPotencia}" : "Según especificación de fábrica"}',
          'Alimentación / Energía: ${eq.tipoCombustible} (Capacidad: ${eq.capacidadTanqueLts.toStringAsFixed(0)} Lts)',
          'Lubricante / Fluido Primario: ${eq.aceiteMotorSpec}',
          'Intervalo Preventivo: Cada ${eq.intervaloService.toStringAsFixed(0)} ${eq.categoria.meterUnit}',
        ],
      ),
      (
        code: 'GRP-02',
        subtitle: 'Sistema Secundario, Cuerpo de Trabajo y Fluido de Potencia',
        icon: Icons.compress_rounded,
        color: const Color(0xFF0EA5E9),
        oemRef: 'Lámina 11-14 · ${schematic.nombre} — Nodo 2',
        specs: [
          'Fluido / Hidráulica: ${eq.aceiteHidraulicoSpec}',
          'Capacidad Operativa: ${eq.capacidad > 0 ? "${eq.capacidad.toStringAsFixed(0)} ${eq.unidadCapacidad}" : "Según nivel nominal"}',
          'Inspección Técnica: Control de estanqueidad, mangueras, uniones y estructura',
          'Filtros Compatibles Registrados: ${widget.filtrosCompatibles.length} códigos en catálogo',
        ],
      ),
      (
        code: 'GRP-03',
        subtitle:
            'Tren de Fuerza / Chasis (${eq.traccionNombre}) · Serie ${eq.nChasis.isEmpty ? "Reforzado" : eq.nChasis}',
        icon: Icons.all_inclusive_rounded,
        color: const Color(0xFF10B981),
        oemRef: 'Lámina 08-10 · ${schematic.nombre} — Nodo 3',
        specs: [
          'Especificación Transmisión / Ejes: ${eq.aceiteTransmisionSpec}',
          'Configuración de Rodaje: ${eq.traccionNombre}',
          'Chasis / Bastidor: ${eq.nChasis.isEmpty ? "Sin número registrado" : eq.nChasis}',
          'Control Preventivo: Revisar anclajes, rodamientos, bujes y desgaste estructural',
        ],
      ),
      (
        code: 'GRP-04',
        subtitle: 'Órgano de Trabajo, Desgaste, Frenos o Salida de Potencia',
        icon: Icons.construction_rounded,
        color: const Color(0xFFEC4899),
        oemRef: 'Lámina 18-22 · ${schematic.nombre} — Nodo 4',
        specs: [
          'Lubricación y Ajuste: Grasa de Litio EP2 / Control de torque y holguras en cada turno',
          'Elementos de Desgaste: Inspección visual de fatiga, fisuras y espesores útiles',
          'Dominio / Identificación: ${eq.dominio.isEmpty ? eq.codigo : eq.dominio}',
          'Notas Técnicas: ${eq.notasTecnicas}',
        ],
      ),
      (
        code: 'GRP-05',
        subtitle: 'Puesto de Mando, Instrumental, Seguridad y Protección',
        icon: Icons.electrical_services_rounded,
        color: const Color(0xFFA855F7),
        oemRef: 'Lámina 25-28 · ${schematic.nombre} — Nodo 5',
        specs: [
          'Lectura Actual: ${eq.lecturaActual.toStringAsFixed(0)} ${eq.categoria.meterUnit}',
          'Próximo Service Programado: ${eq.proximoServiceLectura.toStringAsFixed(0)} ${eq.categoria.meterUnit}',
          'Responsable Asignado: ${eq.responsableActual}',
          'Estado Operativo Actual: ${eq.estado}',
        ],
      ),
    ];

    return List.generate(schematic.hotspots.length, (i) {
      final h = schematic.hotspots[i];
      final b = baseSpecs[i % baseSpecs.length];
      return DespieceSubsystem(
        id: h.id,
        code: b.code,
        label: h.label,
        title: '${h.label} (${schematic.nombre})',
        subtitle: b.subtitle,
        normalizedPos: h.normalizedPos,
        icon: b.icon,
        color: b.color,
        oemReference: '${b.oemRef} · ${h.label}',
        specs: [
          'Punto de Inspección #${h.id}: ${h.label} (Coord. CAD: X=${h.x.toInt()}, Y=${h.y.toInt()})',
          ...b.specs,
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final schematic = EquipmentSchematicsCatalog.forEquipment(widget.equipo);
    final subsystems = _buildSubsystems(widget.equipo, schematic);
    final safeIndex = _selectedIndex.clamp(0, subsystems.length - 1);
    final selected = subsystems[safeIndex];

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PLANO DE DESPIECE INTERACTIVO — ${widget.equipo.codigo} (${widget.equipo.marcaNombre} ${widget.equipo.modeloNombre})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Categoría CAD: ${schematic.nombre} · Rubro: ${widget.equipo.tipoEquipoNombre}',
                          style: const TextStyle(
                            color: Color(0xFF38BDF8),
                            fontWeight: FontWeight.w600,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
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
              // Lienzo CAD con proporción 400x200 y puntos interactivos exactos
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: AspectRatio(
                    aspectRatio:
                        EquipmentSchematicsCatalog.viewBoxSize.width /
                        EquipmentSchematicsCatalog.viewBoxSize.height,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final w = constraints.maxWidth;
                        final h = constraints.maxHeight;
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _BlueprintSchematicPainter(
                                  schematic: schematic,
                                  selectedIndex: safeIndex,
                                  subsystems: subsystems,
                                ),
                              ),
                            ),
                            for (int i = 0; i < subsystems.length; i++)
                              Positioned(
                                left: (subsystems[i].normalizedPos.dx * w) -
                                    (safeIndex == i ? 19 : 15),
                                top: (subsystems[i].normalizedPos.dy * h) -
                                    (safeIndex == i ? 19 : 15),
                                child: Tooltip(
                                  message: '${subsystems[i].id}. ${subsystems[i].label}',
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedIndex = i),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: safeIndex == i ? 38 : 30,
                                      height: safeIndex == i ? 38 : 30,
                                      decoration: BoxDecoration(
                                        color: safeIndex == i
                                            ? subsystems[i].color
                                            : const Color(0xFF0F172A).withValues(alpha: 0.92),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: safeIndex == i
                                              ? Colors.white
                                              : subsystems[i].color,
                                          width: safeIndex == i ? 2.5 : 1.8,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: subsystems[i].color.withValues(alpha: 0.5),
                                            blurRadius: safeIndex == i ? 12 : 4,
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${subsystems[i].id}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: safeIndex == i ? 14 : 12,
                                        ),
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
                ),
              ),
              const SizedBox(height: 12),
              // Selector de hotspots en chips con los nombres específicos del JSON
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(subsystems.length, (i) {
                    final s = subsystems[i];
                    final isSel = i == safeIndex;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        selected: isSel,
                        onSelected: (_) => setState(() => _selectedIndex = i),
                        selectedColor: s.color.withValues(alpha: 0.25),
                        backgroundColor: const Color(0xFF1E293B),
                        side: BorderSide(color: isSel ? s.color : const Color(0xFF334155)),
                        label: Text(
                          '${s.id}. ${s.label}',
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
        // Detalle del Subsistema / Hotspot seleccionado
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
                          'Nodo #${selected.id} (${selected.code}) — ${selected.title}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          selected.oemReference,
                          style: TextStyle(
                            color: selected.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
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
  final EquipmentSchematicSpec schematic;
  final int selectedIndex;
  final List<DespieceSubsystem> subsystems;

  _BlueprintSchematicPainter({
    required this.schematic,
    required this.selectedIndex,
    required this.subsystems,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Fondo de cuadrícula blueprint
    final gridPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1;

    const step = 20.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final sx = size.width / EquipmentSchematicsCatalog.viewBoxSize.width;
    final sy = size.height / EquipmentSchematicsCatalog.viewBoxSize.height;

    final linePaint = Paint()
      ..color = EquipmentSchematicsCatalog.strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = EquipmentSchematicsCatalog.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = EquipmentSchematicsCatalog.strokeColor.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.scale(sx, sy);

    _renderSvgMarkup(canvas, schematic.svgPaths, linePaint, fillPaint);

    canvas.restore();

    // Líneas guía sutiles conectando los hotspots
    final connPaint = Paint()
      ..color = const Color(0xFF64748B).withValues(alpha: 0.35)
      ..strokeWidth = 1.1;

    for (int i = 0; i < subsystems.length - 1; i++) {
      final p1 = Offset(
        subsystems[i].normalizedPos.dx * size.width,
        subsystems[i].normalizedPos.dy * size.height,
      );
      final p2 = Offset(
        subsystems[i + 1].normalizedPos.dx * size.width,
        subsystems[i + 1].normalizedPos.dy * size.height,
      );
      canvas.drawLine(p1, p2, connPaint);
    }

    // Halo resaltado en el hotspot activo
    if (selectedIndex >= 0 && selectedIndex < subsystems.length) {
      final sel = subsystems[selectedIndex];
      final center = Offset(
        sel.normalizedPos.dx * size.width,
        sel.normalizedPos.dy * size.height,
      );
      final haloPaint = Paint()
        ..color = sel.color.withValues(alpha: 0.24)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, 28, haloPaint);
    }
  }

  void _renderSvgMarkup(
    Canvas canvas,
    String svgMarkup,
    Paint strokePaint,
    Paint fillPaint,
  ) {
    final tagRegex = RegExp(r'<(path|circle|rect)\s+([^>]+?)/?>', caseSensitive: false);
    for (final match in tagRegex.allMatches(svgMarkup)) {
      final tag = match.group(1)!.toLowerCase();
      final attrs = _parseAttrs(match.group(2)!);

      if (tag == 'path') {
        final d = attrs['d'];
        if (d != null && d.isNotEmpty) {
          final path = _parseSvgPathData(d);
          canvas.drawPath(path, fillPaint);
          canvas.drawPath(path, strokePaint);
        }
      } else if (tag == 'circle') {
        final cx = double.tryParse(attrs['cx'] ?? '') ?? 0;
        final cy = double.tryParse(attrs['cy'] ?? '') ?? 0;
        final r = double.tryParse(attrs['r'] ?? '') ?? 0;
        if (r > 0) {
          canvas.drawCircle(Offset(cx, cy), r, fillPaint);
          canvas.drawCircle(Offset(cx, cy), r, strokePaint);
        }
      } else if (tag == 'rect') {
        final x = double.tryParse(attrs['x'] ?? '') ?? 0;
        final y = double.tryParse(attrs['y'] ?? '') ?? 0;
        final w = double.tryParse(attrs['width'] ?? '') ?? 0;
        final h = double.tryParse(attrs['height'] ?? '') ?? 0;
        final rx = double.tryParse(attrs['rx'] ?? '') ?? 0;
        final rect = Rect.fromLTWH(x, y, w, h);
        if (rx > 0) {
          final rrect = RRect.fromRectAndRadius(rect, Radius.circular(rx));
          canvas.drawRRect(rrect, fillPaint);
          canvas.drawRRect(rrect, strokePaint);
        } else {
          canvas.drawRect(rect, fillPaint);
          canvas.drawRect(rect, strokePaint);
        }
      }
    }
  }

  Map<String, String> _parseAttrs(String raw) {
    final map = <String, String>{};
    final attrRegex = RegExp(r'''([a-zA-Z0-9_-]+)\s*=\s*['"]([^'"]*)['"]''');
    for (final m in attrRegex.allMatches(raw)) {
      map[m.group(1)!.toLowerCase()] = m.group(2)!;
    }
    return map;
  }

  Path _parseSvgPathData(String d) {
    final path = Path();
    final tokenRegex = RegExp(r'[MmLlAaZz]|[-+]?\d*\.?\d+');
    final tokens = tokenRegex.allMatches(d).map((m) => m.group(0)!).toList();

    int i = 0;
    String cmd = '';
    while (i < tokens.length) {
      final t = tokens[i];
      if (RegExp(r'^[MmLlAaZz]$').hasMatch(t)) {
        cmd = t;
        i++;
        if (cmd == 'Z' || cmd == 'z') {
          path.close();
          continue;
        }
      }

      if (cmd == 'M' && i + 1 < tokens.length) {
        final x = double.parse(tokens[i++]);
        final y = double.parse(tokens[i++]);
        path.moveTo(x, y);
        cmd = 'L';
      } else if (cmd == 'L' && i + 1 < tokens.length) {
        final x = double.parse(tokens[i++]);
        final y = double.parse(tokens[i++]);
        path.lineTo(x, y);
      } else if (cmd == 'A' && i + 6 < tokens.length) {
        final rx = double.parse(tokens[i++]);
        final ry = double.parse(tokens[i++]);
        final xAxisRot = double.parse(tokens[i++]);
        final largeArc = double.parse(tokens[i++]) != 0;
        final sweep = double.parse(tokens[i++]) != 0;
        final x = double.parse(tokens[i++]);
        final y = double.parse(tokens[i++]);
        path.arcToPoint(
          Offset(x, y),
          radius: Radius.elliptical(rx, ry),
          rotation: xAxisRot,
          largeArc: largeArc,
          clockwise: sweep,
        );
      } else {
        i++;
      }
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _BlueprintSchematicPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.schematic.key != schematic.key;
  }
}
