import 'package:flutter/material.dart';
import '../models/erp_models.dart';

class EquipmentHotspotSpec {
  final int id;
  final String label;
  final double x;
  final double y;

  const EquipmentHotspotSpec({
    required this.id,
    required this.label,
    required this.x,
    required this.y,
  });

  Offset get normalizedPos => Offset(x / 400.0, y / 200.0);
}

class EquipmentSchematicSpec {
  final String key;
  final String nombre;
  final String svgPaths;
  final List<EquipmentHotspotSpec> hotspots;

  const EquipmentSchematicSpec({
    required this.key,
    required this.nombre,
    required this.svgPaths,
    required this.hotspots,
  });
}

class EquipmentSchematicsCatalog {
  static const Size viewBoxSize = Size(400, 200);
  static const Color strokeColor = Color(0xFF38BDF8);
  static const double strokeWidth = 2.5;

  static const Map<String, EquipmentSchematicSpec> equipos = {
    'acoplado_camion': EquipmentSchematicSpec(
      key: 'acoplado_camion',
      nombre: 'Acoplado de camión',
      svgPaths:
          "<path d='M 20 135 L 80 135 M 80 135 L 80 65 L 360 65 L 360 135 Z M 80 95 L 360 95 M 150 65 L 150 135 M 220 65 L 220 135 M 290 65 L 290 135'/><circle cx='120' cy='150' r='18'/><circle cx='280' cy='150' r='18'/><circle cx='325' cy='150' r='18'/>",
      hotspots: [
        EquipmentHotspotSpec(id: 1, label: 'Lanza / Enganche', x: 50, y: 135),
        EquipmentHotspotSpec(id: 2, label: 'Caja / Barandas', x: 220, y: 80),
        EquipmentHotspotSpec(id: 3, label: 'Chasis / Elásticos', x: 200, y: 135),
        EquipmentHotspotSpec(id: 4, label: 'Ejes / Frenos', x: 302, y: 150),
        EquipmentHotspotSpec(id: 5, label: 'Sistema Eléctrico / Luces', x: 355, y: 115),
      ],
    ),
    'aplanadora_asfalto': EquipmentSchematicSpec(
      key: 'aplanadora_asfalto',
      nombre: 'Aplanadora de Asfalto',
      svgPaths:
          "<path d='M 110 110 L 110 55 L 175 55 L 185 110 M 185 75 L 290 75 L 300 120 L 100 120 Z M 85 135 L 125 110 M 280 135 L 250 110'/><circle cx='95' cy='142' r='26'/><circle cx='285' cy='142' r='26'/>",
      hotspots: [
        EquipmentHotspotSpec(id: 1, label: 'Motor / Transmisión', x: 235, y: 95),
        EquipmentHotspotSpec(id: 2, label: 'Sistema Hidráulico / Vibración', x: 180, y: 115),
        EquipmentHotspotSpec(id: 3, label: 'Rodillo Delantero', x: 95, y: 142),
        EquipmentHotspotSpec(id: 4, label: 'Rodillo Trasero / Riego', x: 285, y: 142),
        EquipmentHotspotSpec(id: 5, label: 'Cabina / Mandos', x: 145, y: 80),
      ],
    ),
    'aserradora_juntas': EquipmentSchematicSpec(
      key: 'aserradora_juntas',
      nombre: 'Aserradora de juntas',
      svgPaths:
          "<path d='M 80 55 L 130 55 L 150 95 L 260 95 L 270 135 L 130 135 L 130 95 M 160 95 L 160 65 L 230 65 L 230 95 M 245 120 A 32 32 0 1 1 305 145 Z'/><circle cx='155' cy='148' r='14'/><circle cx='225' cy='148' r='14'/>",
      hotspots: [
        EquipmentHotspotSpec(id: 1, label: 'Motor Explosión', x: 195, y: 80),
        EquipmentHotspotSpec(id: 2, label: 'Tanque de Agua', x: 150, y: 115),
        EquipmentHotspotSpec(id: 3, label: 'Chasis / Ruedas', x: 190, y: 148),
        EquipmentHotspotSpec(id: 4, label: 'Disco de Corte / Eje', x: 275, y: 135),
        EquipmentHotspotSpec(id: 5, label: 'Manillar / Profundidad', x: 105, y: 55),
      ],
    ),
    'bateas_camiones': EquipmentSchematicSpec(
      key: 'bateas_camiones',
      nombre: 'Bateas de camiones',
      svgPaths:
          "<path d='M 60 135 L 350 135 M 70 135 L 60 55 L 355 55 L 340 135 Z M 130 55 L 135 135 M 200 55 L 205 135 M 270 55 L 275 135 M 110 135 L 130 70'/><circle cx='90' cy='152' r='14'/><circle cx='255' cy='152' r='16'/><circle cx='295' cy='152' r='16'/><circle cx='335' cy='152' r='16'/>",
      hotspots: [
        EquipmentHotspotSpec(id: 1, label: 'Cilindro Hidráulico Volteo', x: 115, y: 95),
        EquipmentHotspotSpec(id: 2, label: 'Caja Batea / Compuerta', x: 230, y: 85),
        EquipmentHotspotSpec(id: 3, label: 'Perno Rey / Patas Apoyo', x: 90, y: 135),
        EquipmentHotspotSpec(id: 4, label: 'Tren Rodante / Suspensión', x: 295, y: 152),
        EquipmentHotspotSpec(id: 5, label: 'Lona / Cobertura', x: 200, y: 55),
      ],
    ),
    'camiones': EquipmentSchematicSpec(
      key: 'camiones',
      nombre: 'Camiones',
      svgPaths:
          "<path d='M 65 135 L 65 95 L 115 95 L 135 50 L 185 50 L 185 135 Z M 195 75 L 340 75 L 340 135 L 185 135'/><circle cx='115' cy='145' r='20'/><circle cx='275' cy='145' r='20'/><circle cx='320' cy='145' r='20'/>",
      hotspots: [
        EquipmentHotspotSpec(id: 1, label: 'Motor', x: 110, y: 110),
        EquipmentHotspotSpec(id: 2, label: 'Caja / Carrocería', x: 250, y: 95),
        EquipmentHotspotSpec(id: 3, label: 'Transmisión / Cardán', x: 195, y: 135),
        EquipmentHotspotSpec(id: 4, label: 'Diferencial / Neumáticos', x: 298, y: 145),
        EquipmentHotspotSpec(id: 5, label: 'Cabina', x: 160, y: 72),
      ],
    ),
    'contenedores': EquipmentSchematicSpec(
      key: 'contenedores',
      nombre: 'Contenedores',
      svgPaths:
          "<rect x='60' y='50' width='280' height='110'/><path d='M 95 50 L 95 160 M 130 50 L 130 160 M 165 50 L 165 160 M 200 50 L 200 160 M 235 50 L 235 160 M 270 50 L 270 160 M 305 50 L 305 160'/>",
      hotspots: [
        EquipmentHotspotSpec(id: 1, label: 'Estructura / Esquinero', x: 70, y: 60),
        EquipmentHotspotSpec(id: 2, label: 'Paneles Laterales / Chapa', x: 200, y: 105),
        EquipmentHotspotSpec(id: 3, label: 'Piso / Travesaños', x: 200, y: 155),
        EquipmentHotspotSpec(id: 4, label: 'Puertas / Cierres', x: 330, y: 105),
        EquipmentHotspotSpec(id: 5, label: 'Techo / Sellado', x: 200, y: 52),
      ],
    ),
    'casillas': EquipmentSchematicSpec(
      key: 'casillas',
      nombre: 'Casillas',
      svgPaths:
          "<path d='M 40 135 L 90 135 M 90 135 L 90 55 L 330 55 L 330 135 Z M 130 75 L 170 75 L 170 100 L 130 100 Z M 250 75 L 290 75 L 290 100 L 250 100 Z M 195 75 L 225 75 L 225 135 L 195 135 Z'/><circle cx='180' cy='150' r='16'/><circle cx='230' cy='150' r='16'/>",
      hotspots: [
        EquipmentHotspotSpec(id: 1, label: 'Lanza de Tiro', x: 65, y: 135),
        EquipmentHotspotSpec(id: 2, label: 'Aberturas / Aislación', x: 150, y: 88),
        EquipmentHotspotSpec(id: 3, label: 'Ejes / Ruedas', x: 205, y: 150),
        EquipmentHotspotSpec(id: 4, label: 'Instalación Eléctrica / Gas', x: 295, y: 115),
        EquipmentHotspotSpec(id: 5, label: 'Techo / Filtraciones', x: 210, y: 55),
      ],
    ),
    'compresores_sullair': EquipmentSchematicSpec(
      key: 'compresores_sullair',
      nombre: 'Compresores tipo Sullair',
      svgPaths:
          "<path d='M 50 130 L 110 130 M 110 130 L 110 65 L 290 65 L 290 130 Z M 140 80 L 180 80 L 180 115 L 140 115 Z M 210 80 L 265 80 L 265 115 L 210 115 Z'/><circle cx='200' cy='145' r='20'/>",
      hotspots: [
        EquipmentHotspotSpec(id: 1, label: 'Motor Diésel', x: 160, y: 98),
        EquipmentHotspotSpec(id: 2, label: 'Unidad Compresora / Tornillo', x: 238, y: 98),
        EquipmentHotspotSpec(id: 3, label: 'Chasis / Eje / Lanza', x: 200, y: 145),
        EquipmentHotspotSpec(id: 4, label: 'Salidas de Aire / Válvulas', x: 290, y: 110),
        EquipmentHotspotSpec(id: 5, label: 'Tablero Control / Filtros', x: 120, y: 85),
      ],
    ),
    'carreton': EquipmentSchematicSpec(
      key: 'carreton',
      nombre: 'Carretón',
      svgPaths:
          "<path d='M 45 95 L 105 95 L 125 138 L 285 138 L 305 115 L 365 115 L 365 138 L 285 138'/><circle cx='295' cy='153' r='15'/><circle cx='330' cy='153' r='15'/><circle cx='360' cy='153' r='15'/>",
      hotspots: [
        EquipmentHotspotSpec(id: 1, label: 'Cuello de Cisne', x: 85, y: 95),
        EquipmentHotspotSpec(id: 2, label: 'Plataforma de Carga', x: 205, y: 135),
        EquipmentHotspotSpec(id: 3, label: 'Sistema Hidráulico / Rampas', x: 355, y: 115),
        EquipmentHotspotSpec(id: 4, label: 'Ejes Múltiples / Frenos', x: 328, y: 153),
        EquipmentHotspotSpec(id: 5, label: 'Piso Madera / Amarres', x: 165, y: 138),
      ],
    ),
    'fusoras_asfalto': EquipmentSchematicSpec(
      key: 'fusoras_asfalto',
      nombre: 'Fusoras de Asfalto',
      svgPaths:
          "<path d='M 45 135 L 100 135 M 100 135 L 100 70 L 270 70 L 270 135 Z M 130 70 L 130 45 L 150 45 L 150 70 M 270 105 L 315 105 L 315 125 L 270 125'/><circle cx='185' cy='148' r='18'/>",
      hotspots: [
        EquipmentHotspotSpec(id: 1, label: 'Quemador / Gasoil', x: 120, y: 110),
        EquipmentHotspotSpec(id: 2, label: 'Caldera / Agitador', x: 195, y: 95),
        EquipmentHotspotSpec(id: 3, label: 'Chasis / Eje', x: 185, y: 148),
        EquipmentHotspotSpec(id: 4, label: 'Bomba / Lanza Aplicación', x: 292, y: 115),
        EquipmentHotspotSpec(id: 5, label: 'Chimenea / Control Temp.', x: 140, y: 55),
      ],
    ),
    'grupos_electrogenos_bonus': EquipmentSchematicSpec(
      key: 'grupos_electrogenos_bonus',
      nombre: 'Grupos electrógenos tipo Bonus (Insonorizados)',
      svgPaths:
          "<rect x='65' y='55' width='270' height='100'/><path d='M 65 140 L 335 140 M 105 75 L 165 75 L 165 125 L 105 125 Z M 185 75 L 245 75 L 245 125 L 185 125 Z M 265 75 L 310 75 L 310 125 L 265 125 Z M 115 55 L 135 40 L 155 55'/>",
      hotspots: [
        EquipmentHotspotSpec(id: 1, label: 'Motor Diésel', x: 135, y: 100),
        EquipmentHotspotSpec(id: 2, label: 'Alternador / Generador', x: 215, y: 100),
        EquipmentHotspotSpec(id: 3, label: 'Tanque Base / Skid', x: 200, y: 148),
        EquipmentHotspotSpec(id: 4, label: 'Tablero Transferencia / Breaker', x: 288, y: 100),
        EquipmentHotspotSpec(id: 5, label: 'Cabina Insonorizada / Escape', x: 135, y: 55),
      ],
    ),
    'grupos_electrogenos_comunes': EquipmentSchematicSpec(
      key: 'grupos_electrogenos_comunes',
      nombre: 'Grupos electrógenos comunes (Abiertos)',
      svgPaths:
          "<path d='M 70 145 L 330 145 L 330 132 L 70 132 Z M 85 132 L 85 65 L 315 65 L 315 132 M 105 132 L 105 80 L 195 80 L 195 132 M 215 132 L 215 88 L 285 88 L 285 132 M 95 65 L 145 50 L 145 65'/>",
      hotspots: [
        EquipmentHotspotSpec(id: 1, label: 'Motor / Radiador', x: 150, y: 105),
        EquipmentHotspotSpec(id: 2, label: 'Generador / Bobinado', x: 250, y: 110),
        EquipmentHotspotSpec(id: 3, label: 'Bastidor / Tacos Goma', x: 200, y: 138),
        EquipmentHotspotSpec(id: 4, label: 'Caja Conexiones / Toma', x: 305, y: 95),
        EquipmentHotspotSpec(id: 5, label: 'Tanque Combustible Superior', x: 120, y: 60),
      ],
    ),
    'martillos_neumaticos': EquipmentSchematicSpec(
      key: 'martillos_neumaticos',
      nombre: 'Martillos neumáticos',
      svgPaths:
          "<path d='M 150 40 L 250 40 L 250 52 L 218 52 L 218 115 L 210 125 L 210 145 L 190 145 L 190 125 L 182 115 L 182 52 L 150 52 Z M 195 145 L 195 180 L 200 188 L 205 180 L 205 145 M 218 70 L 245 75'/>",
      hotspots: [
        EquipmentHotspotSpec(id: 1, label: 'Cilindro / Pistón Interno', x: 200, y: 85),
        EquipmentHotspotSpec(id: 2, label: 'Válvula / Acople Aire', x: 235, y: 72),
        EquipmentHotspotSpec(id: 3, label: 'Portaherramientas / Traba', x: 200, y: 135),
        EquipmentHotspotSpec(id: 4, label: 'Punta / Cincel', x: 200, y: 168),
        EquipmentHotspotSpec(id: 5, label: 'Empuñadura / Gatillo', x: 200, y: 46),
      ],
    ),
    'martillos_hidraulicos': EquipmentSchematicSpec(
      key: 'martillos_hidraulicos',
      nombre: 'Martillos Hidráulicos (Acople Excavadora)',
      svgPaths:
          "<path d='M 165 30 L 235 30 L 235 55 L 222 55 L 222 135 L 178 135 L 178 55 L 165 55 Z M 192 135 L 192 182 L 200 192 L 208 182 L 208 135 M 160 75 L 178 75 M 222 75 L 240 75'/>",
      hotspots: [
        EquipmentHotspotSpec(id: 1, label: 'Cuerpo Percutor / Nitrógeno', x: 200, y: 90),
        EquipmentHotspotSpec(id: 2, label: 'Mangueras Hidráulicas', x: 165, y: 75),
        EquipmentHotspotSpec(id: 3, label: 'Bujes / Pasadores', x: 200, y: 130),
        EquipmentHotspotSpec(id: 4, label: 'Puntero / Pica', x: 200, y: 165),
        EquipmentHotspotSpec(id: 5, label: 'Cabezal / Acople Máquina', x: 200, y: 42),
      ],
    ),
    'motoniveladora': EquipmentSchematicSpec(
      key: 'motoniveladora',
      nombre: 'Motoniveladora',
      svgPaths:
          "<path d='M 70 130 L 145 130 L 155 75 L 210 75 L 220 105 L 335 125 L 335 140 M 195 100 L 220 148 L 255 148 L 240 120'/><circle cx='90' cy='145' r='20'/><circle cx='138' cy='145' r='20'/><circle cx='335' cy='148' r='18'/>",
      hotspots: [
        EquipmentHotspotSpec(id: 1, label: 'Motor Trasero', x: 105, y: 105),
        EquipmentHotspotSpec(id: 2, label: 'Sistema Hidráulico / Tornamesa', x: 225, y: 115),
        EquipmentHotspotSpec(id: 3, label: 'Tandem Trasero / Neumáticos', x: 114, y: 145),
        EquipmentHotspotSpec(id: 4, label: 'Vertedera / Cuchilla', x: 238, y: 145),
        EquipmentHotspotSpec(id: 5, label: 'Cabina', x: 182, y: 85),
      ],
    ),
    'motosoldadora': EquipmentSchematicSpec(
      key: 'motosoldadora',
      nombre: 'Motosoldadora',
      svgPaths:
          "<path d='M 85 135 L 315 135 L 315 65 L 85 65 Z M 115 65 L 115 45 L 285 45 L 285 65 M 245 80 L 295 80 L 295 120 L 245 120 Z'/><circle cx='140' cy='150' r='15'/><circle cx='260' cy='150' r='15'/>",
      hotspots: [
        EquipmentHotspotSpec(id: 1, label: 'Motor Combustión', x: 150, y: 100),
        EquipmentHotspotSpec(id: 2, label: 'Generador Soldadura', x: 215, y: 100),
        EquipmentHotspotSpec(id: 3, label: 'Chasis / Ruedas', x: 200, y: 145),
        EquipmentHotspotSpec(id: 4, label: 'Bornes / Pinzas / Cables', x: 270, y: 100),
        EquipmentHotspotSpec(id: 5, label: 'Jaula Protección / Tablero', x: 200, y: 55),
      ],
    ),
    'palas_cargadoras': EquipmentSchematicSpec(
      key: 'palas_cargadoras',
      nombre: 'Palas Cargadoras',
      svgPaths:
          "<path d='M 85 125 L 85 75 L 145 75 L 155 45 L 205 45 L 210 125 Z M 210 85 L 295 125 L 285 140 L 210 105 M 295 110 L 345 110 L 355 155 L 285 155 Z'/><circle cx='120' cy='142' r='24'/><circle cx='235' cy='142' r='24'/>",
      hotspots: [
        EquipmentHotspotSpec(id: 1, label: 'Motor', x: 115, y: 100),
        EquipmentHotspotSpec(id: 2, label: 'Brazos / Cilindros Levante', x: 250, y: 105),
        EquipmentHotspotSpec(id: 3, label: 'Articulación Central / Ejes', x: 178, y: 135),
        EquipmentHotspotSpec(id: 4, label: 'Balde / Uñas / Cuchilla', x: 320, y: 135),
        EquipmentHotspotSpec(id: 5, label: 'Cabina', x: 180, y: 65),
      ],
    ),
    'palas_retroexcavadoras_ruedas': EquipmentSchematicSpec(
      key: 'palas_retroexcavadoras_ruedas',
      nombre: 'Palas Retroexcavadoras (Con ruedas)',
      svgPaths:
          "<path d='M 135 125 L 145 55 L 205 55 L 215 125 Z M 135 90 L 75 125 L 85 135 L 135 110 M 75 115 L 40 115 L 35 150 L 80 150 Z M 215 105 L 265 45 L 325 115 L 315 125 L 265 65 L 220 120 M 325 115 L 350 115 L 345 145 L 315 135 Z'/><circle cx='120' cy='142' r='16'/><circle cx='200' cy='138' r='24'/>",
      hotspots: [
        EquipmentHotspotSpec(id: 1, label: 'Motor Delantero', x: 120, y: 105),
        EquipmentHotspotSpec(id: 2, label: 'Brazo Retroexcavador', x: 265, y: 55),
        EquipmentHotspotSpec(id: 3, label: 'Transmisión / Estabilizadores', x: 200, y: 138),
        EquipmentHotspotSpec(id: 4, label: 'Pala Cargadora / Baldes', x: 60, y: 132),
        EquipmentHotspotSpec(id: 5, label: 'Cabina', x: 175, y: 78),
      ],
    ),
    'retroexcavadoras_orugas': EquipmentSchematicSpec(
      key: 'retroexcavadoras_orugas',
      nombre: 'Retroexcavadoras (Orugas)',
      svgPaths:
          "<path d='M 80 115 L 80 75 L 145 75 L 155 40 L 205 40 L 215 115 Z M 215 95 L 270 50 L 330 115 L 315 122 L 268 70 L 218 112 M 330 115 L 360 115 L 350 150 L 315 135 Z'/><rect x='75' y='125' width='150' height='36' rx='18'/><circle cx='100' cy='143' r='11'/><circle cx='133' cy='143' r='11'/><circle cx='167' cy='143' r='11'/><circle cx='200' cy='143' r='11'/>",
      hotspots: [
        EquipmentHotspotSpec(id: 1, label: 'Motor / Bomba Hidráulica', x: 115, y: 95),
        EquipmentHotspotSpec(id: 2, label: 'Pluma / Brazo', x: 268, y: 60),
        EquipmentHotspotSpec(id: 3, label: 'Tren de Rodaje / Orugas', x: 150, y: 143),
        EquipmentHotspotSpec(id: 4, label: 'Balde / Dientes', x: 335, y: 130),
        EquipmentHotspotSpec(id: 5, label: 'Cabina', x: 180, y: 62),
      ],
    ),
    'rodillos_neumaticos': EquipmentSchematicSpec(
      key: 'rodillos_neumaticos',
      nombre: 'Rodillos Neumáticos',
      svgPaths:
          "<path d='M 95 115 L 95 60 L 160 60 L 175 115 M 175 80 L 295 80 L 305 120 L 90 120 Z'/><circle cx='105' cy='145' r='18'/><circle cx='145' cy='145' r='18'/><circle cx='245' cy='145' r='18'/><circle cx='285' cy='145' r='18'/>",
      hotspots: [
        EquipmentHotspotSpec(id: 1, label: 'Motor / Convertidor', x: 235, y: 100),
        EquipmentHotspotSpec(id: 2, label: 'Lastre / Tanque Agua', x: 190, y: 105),
        EquipmentHotspotSpec(id: 3, label: 'Tren Delantero (Neumáticos)', x: 265, y: 145),
        EquipmentHotspotSpec(id: 4, label: 'Tren Trasero / Rociadores', x: 125, y: 145),
        EquipmentHotspotSpec(id: 5, label: 'Cabina', x: 130, y: 82),
      ],
    ),
    'rodillos_pata_cabra': EquipmentSchematicSpec(
      key: 'rodillos_pata_cabra',
      nombre: 'Rodillos pata de cabra',
      svgPaths:
          "<path d='M 95 115 L 95 55 L 165 55 L 175 115 M 175 80 L 265 80 L 270 115 L 175 115 M 255 135 L 235 105'/><circle cx='115' cy='142' r='24'/><circle cx='275' cy='142' r='26'/><path d='M 275 112 L 275 116 M 296 121 L 293 124 M 305 142 L 301 142 M 296 163 L 293 160 M 275 172 L 275 168 M 254 163 L 257 160 M 245 142 L 249 142 M 254 121 L 257 124'/>",
      hotspots: [
        EquipmentHotspotSpec(id: 1, label: 'Motor', x: 215, y: 98),
        EquipmentHotspotSpec(id: 2, label: 'Articulación / Hidráulica', x: 185, y: 115),
        EquipmentHotspotSpec(id: 3, label: 'Neumáticos Tracción', x: 115, y: 142),
        EquipmentHotspotSpec(id: 4, label: 'Tambor Pata de Cabra / Vibrador', x: 275, y: 142),
        EquipmentHotspotSpec(id: 5, label: 'Cabina', x: 132, y: 78),
      ],
    ),
    'terminadora_asfalto': EquipmentSchematicSpec(
      key: 'terminadora_asfalto',
      nombre: 'Terminadora de Asfalto',
      svgPaths:
          "<path d='M 60 115 L 125 115 L 125 148 L 60 148 Z M 125 125 L 255 125 L 255 75 L 145 75 L 145 125 M 165 75 L 165 45 L 225 45 L 225 75 M 255 85 L 340 85 L 330 125 L 255 125'/><rect x='135' y='132' width='115' height='26' rx='13'/>",
      hotspots: [
        EquipmentHotspotSpec(id: 1, label: 'Motor / Bomba Hidráulica', x: 200, y: 98),
        EquipmentHotspotSpec(id: 2, label: 'Tolva Recepción / Cintas', x: 295, y: 105),
        EquipmentHotspotSpec(id: 3, label: 'Orugas / Tren Rodaje', x: 192, y: 145),
        EquipmentHotspotSpec(id: 4, label: 'Regla / Plancha Calefactora', x: 92, y: 132),
        EquipmentHotspotSpec(id: 5, label: 'Puesto Operador / Sensores', x: 195, y: 60),
      ],
    ),
    'tuneleras': EquipmentSchematicSpec(
      key: 'tuneleras',
      nombre: 'Tuneleras (Topo / TBM)',
      svgPaths:
          "<path d='M 60 65 L 305 65 L 305 145 L 60 145 Z M 305 60 L 330 70 L 330 140 L 305 150 Z M 330 75 L 342 75 M 330 95 L 342 95 M 330 115 L 342 115 M 330 135 L 342 135 M 110 105 L 260 105'/>",
      hotspots: [
        EquipmentHotspotSpec(id: 1, label: 'Grupo Hidráulico / Motores', x: 120, y: 85),
        EquipmentHotspotSpec(id: 2, label: 'Tornillo Sinfin / Cinta Extracción', x: 210, y: 105),
        EquipmentHotspotSpec(id: 3, label: 'Cilindros Empuje / Gatos', x: 160, y: 132),
        EquipmentHotspotSpec(id: 4, label: 'Cabeza de Corte / Cortadores', x: 325, y: 105),
        EquipmentHotspotSpec(id: 5, label: 'Cabina Control / Láser Guía', x: 85, y: 105),
      ],
    ),
    'autos': EquipmentSchematicSpec(
      key: 'autos',
      nombre: 'Autos',
      svgPaths:
          "<path d='M 65 135 L 65 105 L 115 95 L 155 62 L 245 62 L 285 95 L 335 102 L 335 135 Z'/><circle cx='120' cy='140' r='20'/><circle cx='280' cy='140' r='20'/>",
      hotspots: [
        EquipmentHotspotSpec(id: 1, label: 'Motor', x: 100, y: 112),
        EquipmentHotspotSpec(id: 2, label: 'Carrocería / Baúl', x: 305, y: 108),
        EquipmentHotspotSpec(id: 3, label: 'Tren Delantero / Frenos', x: 120, y: 140),
        EquipmentHotspotSpec(id: 4, label: 'Tren Trasero / Neumáticos', x: 280, y: 140),
        EquipmentHotspotSpec(id: 5, label: 'Habitáculo / Electrónica', x: 200, y: 82),
      ],
    ),
    'camionetas': EquipmentSchematicSpec(
      key: 'camionetas',
      nombre: 'Camionetas (Pick-up)',
      svgPaths:
          "<path d='M 55 135 L 55 95 L 115 90 L 145 55 L 215 55 L 215 135 Z M 215 90 L 345 90 L 345 135 L 215 135'/><circle cx='110' cy='142' r='22'/><circle cx='290' cy='142' r='22'/>",
      hotspots: [
        EquipmentHotspotSpec(id: 1, label: 'Motor', x: 95, y: 108),
        EquipmentHotspotSpec(id: 2, label: 'Caja de Carga', x: 280, y: 108),
        EquipmentHotspotSpec(id: 3, label: 'Caja Cambios / 4x4', x: 185, y: 135),
        EquipmentHotspotSpec(id: 4, label: 'Diferencial / Suspensión', x: 290, y: 142),
        EquipmentHotspotSpec(id: 5, label: 'Cabina', x: 180, y: 75),
      ],
    ),
    'vibroapisonadoras': EquipmentSchematicSpec(
      key: 'vibroapisonadoras',
      nombre: 'Vibroapisonadoras (Saltarín)',
      svgPaths:
          "<path d='M 165 40 L 235 40 L 235 55 L 215 55 L 215 95 L 185 95 L 185 55 L 165 55 Z M 190 95 L 190 155 L 210 155 L 210 95 M 165 155 L 235 155 L 242 175 L 158 175 Z M 185 110 L 215 110 M 185 125 L 215 125 M 185 140 L 215 140'/>",
      hotspots: [
        EquipmentHotspotSpec(id: 1, label: 'Motor 4T / 2T', x: 200, y: 75),
        EquipmentHotspotSpec(id: 2, label: 'Carburador / Filtro Aire', x: 225, y: 75),
        EquipmentHotspotSpec(id: 3, label: 'Fuelle / Sistema Percusión', x: 200, y: 125),
        EquipmentHotspotSpec(id: 4, label: 'Zapata / Base Impacto', x: 200, y: 165),
        EquipmentHotspotSpec(id: 5, label: 'Manillar / Tanque Combustible', x: 200, y: 46),
      ],
    ),
  };

  /// Resuelve el esquema técnico correspondiente a cualquier equipo de la flota
  /// a partir de su `tipoEquipoId`, `tipoEquipoNombre`, `marcaNombre` y `modeloNombre`.
  static EquipmentSchematicSpec forEquipment(EquipmentItem eq) {
    final key = resolveKeyForEquipment(eq);
    return equipos[key] ?? equipos['retroexcavadoras_orugas']!;
  }

  static String resolveKeyForEquipment(EquipmentItem eq) {
    final id = eq.tipoEquipoId;
    final tipo = eq.tipoEquipoNombre.toLowerCase();
    final marca = eq.marcaNombre.toLowerCase();
    final modelo = eq.modeloNombre.toLowerCase();
    final codigo = eq.codigo.toUpperCase();

    // Mapeo directo por ID de catálogo de Tipos de Equipo (1..46)
    switch (id) {
      case 1: // Acoplados
      case 11: // Carros
      case 37: // Semi Remolques
      case 40: // Tanques
        return 'acoplado_camion';
      case 3: // Aplanadoras
        return 'aplanadora_asfalto';
      case 2: // Amoladoras
      case 4: // Aserradoras de juntas
      case 15: // Desmalezadoras
      case 18: // Extractores de testigos
      case 25: // Motoguadañas
        return 'aserradora_juntas';
      case 5: // Autos
        return 'autos';
      case 6: // Bateas
        return 'bateas_camiones';
      case 8: // Camiones
        return 'camiones';
      case 9: // Camionetas
      case 44: // Utilitarios
        return 'camionetas';
      case 10: // Carretones
        return 'carreton';
      case 12: // Casillas Rodantes
        return 'casillas';
      case 13: // Compresores
        return 'compresores_sullair';
      case 14: // Contenedores
      case 16: // Detector de Gases
      case 17: // Estaciones Totales
      case 28: // Niveles Ópticos
      case 41: // Tanques Subterráneos
        return 'contenedores';
      case 19: // Fusoras de Asfalto
      case 21: // Hormigonera
      case 32: // Plantas de Asfalto
        return 'fusoras_asfalto';
      case 20: // Grupos Electrógenos
      case 7: // Bomba
        final isInsonorizado = marca.contains('kipor') ||
            marca.contains('bounous') ||
            marca.contains('bonus') ||
            modelo.contains('sta') ||
            modelo.contains('kva') ||
            modelo.contains('yanmar') ||
            modelo.contains('odb') ||
            eq.potencia >= 15 ||
            codigo == 'GRE001' ||
            codigo == 'GRE003' ||
            codigo == 'GRE011' ||
            codigo == 'GRE012';
        return isInsonorizado
            ? 'grupos_electrogenos_bonus'
            : 'grupos_electrogenos_comunes';
      case 22: // Martillo Demoledor
      case 24: // Martillos Neumáticos
      case 39: // Taladros
        return 'martillos_neumaticos';
      case 23: // Martillos Hidráulicos
      case 31: // Perforadoras
        return 'martillos_hidraulicos';
      case 26: // Motoniveladoras
        return 'motoniveladora';
      case 27: // Motosoldadoras
      case 38: // Soldadora
        return 'motosoldadora';
      case 29: // Pala Cargadoras
      case 33: // Plantas Móviles de clasificación
        return 'palas_cargadoras';
      case 30: // Pala Retroexcavadoras (con ruedas)
        return 'palas_retroexcavadoras_ruedas';
      case 34: // Retroexcavadoras (Orugas)
        return 'retroexcavadoras_orugas';
      case 35: // Rodillos Neumáticos
        return 'rodillos_neumaticos';
      case 36: // Rodillos Pata de Cabra
        return 'rodillos_pata_cabra';
      case 42: // Terminadoras de Asfalto
        return 'terminadora_asfalto';
      case 43: // Tuneleras
        return 'tuneleras';
      case 45: // Vibradores de inmersión
      case 46: // Vibroapisonadores
        return 'vibroapisonadoras';
    }

    // Respaldo por texto de categoría / nombre de tipo de equipo
    if (tipo.contains('acoplado') || tipo.contains('remolque')) return 'acoplado_camion';
    if (tipo.contains('aplanadora')) return 'aplanadora_asfalto';
    if (tipo.contains('aserradora') || tipo.contains('junta')) return 'aserradora_juntas';
    if (tipo.contains('batea')) return 'bateas_camiones';
    if (tipo.contains('camioneta') || tipo.contains('utilitario') || tipo.contains('pick')) {
      return 'camionetas';
    }
    if (tipo.contains('cami')) return 'camiones';
    if (tipo.contains('contenedor')) return 'contenedores';
    if (tipo.contains('casilla')) return 'casillas';
    if (tipo.contains('compresor') || marca.contains('sullair')) return 'compresores_sullair';
    if (tipo.contains('carret')) return 'carreton';
    if (tipo.contains('fusora')) return 'fusoras_asfalto';
    if (tipo.contains('electrogeno') || tipo.contains('electrógeno') || tipo.contains('generador')) {
      return marca.contains('bonus') || marca.contains('kipor') || marca.contains('bounous')
          ? 'grupos_electrogenos_bonus'
          : 'grupos_electrogenos_comunes';
    }
    if (tipo.contains('martillo') && tipo.contains('hidr')) return 'martillos_hidraulicos';
    if (tipo.contains('martillo')) return 'martillos_neumaticos';
    if (tipo.contains('motoniveladora')) return 'motoniveladora';
    if (tipo.contains('soldadora')) return 'motosoldadora';
    if (tipo.contains('pala') && tipo.contains('retro')) return 'palas_retroexcavadoras_ruedas';
    if (tipo.contains('pala') && tipo.contains('cargadora')) return 'palas_cargadoras';
    if (tipo.contains('retroexcavadora')) return 'retroexcavadoras_orugas';
    if (tipo.contains('rodillo') && tipo.contains('pata')) return 'rodillos_pata_cabra';
    if (tipo.contains('rodillo')) return 'rodillos_neumaticos';
    if (tipo.contains('terminadora')) return 'terminadora_asfalto';
    if (tipo.contains('tunelera') || tipo.contains('topo')) return 'tuneleras';
    if (tipo.contains('auto')) return 'autos';
    if (tipo.contains('vibro') || tipo.contains('apisonador')) return 'vibroapisonadoras';

    if (eq.categoria == AssetCategory.vehiculo) return 'camiones';
    if (eq.categoria == AssetCategory.herramienta) return 'vibroapisonadoras';
    return 'retroexcavadoras_orugas';
  }
}
