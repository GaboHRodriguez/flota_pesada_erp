import 'package:flutter/material.dart';

/// Los 5 niveles de usuario definidos en los requerimientos
enum UserRole {
  superUsuario, // Nivel 1: Acceso total y mantenimiento del sistema
  gerencia, // Nivel 2: Informes, costos, rendimientos, asignar/retirar equipos de obras
  administrador, // Nivel 3: Cargar equipos, gastos, consumos, partes diarios
  taller, // Nivel 4: Crear, modificar y eliminar informes de mantenimiento, reparaciones y partes de trabajo
  operario, // Nivel 5: Cargar parte diario (horas, trabajos, consumos, observaciones, solicitud de reparación)
}

extension UserRoleExtension on UserRole {
  String get label {
    switch (this) {
      case UserRole.superUsuario:
        return 'Super Usuario';
      case UserRole.gerencia:
        return 'Gerencia / Jefe de Obra';
      case UserRole.administrador:
        return 'Administrador';
      case UserRole.taller:
        return 'Taller Mecánico';
      case UserRole.operario:
        return 'Operario';
    }
  }

  String get shortLabel {
    switch (this) {
      case UserRole.superUsuario:
        return 'SuperAdmin';
      case UserRole.gerencia:
        return 'Gerencia';
      case UserRole.administrador:
        return 'Administración';
      case UserRole.taller:
        return 'Taller';
      case UserRole.operario:
        return 'Operario';
    }
  }

  String get description {
    switch (this) {
      case UserRole.superUsuario:
        return 'Acceso total al sistema, auditoría, configuración de servidor Windows, respaldos y gestión de usuarios.';
      case UserRole.gerencia:
        return 'Informes ejecutivos, estadísticas de costos y rendimientos de flota, asignación y retiro de equipos en frentes de obra.';
      case UserRole.administrador:
        return 'Alta y administración de equipos, registro de gastos, seguros, consumos y carga/supervisión de partes diarios.';
      case UserRole.taller:
        return 'Crear, modificar y eliminar informes de mantenimiento, reparaciones, stock de filtros/repuestos, fichas técnicas y despieces.';
      case UserRole.operario:
        return 'Carga de partes diarios de equipos (hora inicio/fin, horómetro/odómetro, trabajos, combustible, lubricantes, observaciones y solicitud de reparación).';
    }
  }

  int get dbPermisoValue {
    switch (this) {
      case UserRole.superUsuario:
        return 1;
      case UserRole.gerencia:
        return 2;
      case UserRole.administrador:
        return 3;
      case UserRole.taller:
        return 4;
      case UserRole.operario:
        return 5;
    }
  }

  static UserRole fromDbValue(int val) {
    switch (val) {
      case 1:
        return UserRole.superUsuario;
      case 2:
        return UserRole.gerencia;
      case 3:
        return UserRole.administrador;
      case 4:
        return UserRole.taller;
      default:
        return UserRole.operario;
    }
  }

  Color get badgeColor {
    switch (this) {
      case UserRole.superUsuario:
        return const Color(0xFF9333EA); // Púrpura
      case UserRole.gerencia:
        return const Color(0xFF0284C7); // Azul ejecutivo
      case UserRole.administrador:
        return const Color(0xFF059669); // Esmeralda
      case UserRole.taller:
        return const Color(0xFFD97706); // Ámbar industrial
      case UserRole.operario:
        return const Color(0xFF2563EB); // Azul operativo
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.superUsuario:
        return Icons.admin_panel_settings_rounded;
      case UserRole.gerencia:
        return Icons.analytics_rounded;
      case UserRole.administrador:
        return Icons.account_balance_wallet_rounded;
      case UserRole.taller:
        return Icons.build_circle_rounded;
      case UserRole.operario:
        return Icons.engineering_rounded;
    }
  }
}

/// Categoría macro para distinguir Maquinaria Pesada, Vehículos y Herramientas
enum AssetCategory {
  maquinariaPesada,
  vehiculo,
  herramienta,
}

extension AssetCategoryExtension on AssetCategory {
  String get label {
    switch (this) {
      case AssetCategory.maquinariaPesada:
        return 'Maquinaria Pesada';
      case AssetCategory.vehiculo:
        return 'Vehículos y Rodados';
      case AssetCategory.herramienta:
        return 'Herramientas y Eq. Menores';
    }
  }

  String get meterUnit {
    switch (this) {
      case AssetCategory.maquinariaPesada:
        return 'hs';
      case AssetCategory.vehiculo:
        return 'km';
      case AssetCategory.herramienta:
        return 'uso';
    }
  }

  String get meterLabel {
    switch (this) {
      case AssetCategory.maquinariaPesada:
        return 'Horómetro (hs)';
      case AssetCategory.vehiculo:
        return 'Odómetro (km)';
      case AssetCategory.herramienta:
        return 'Control por Asignación';
    }
  }
}

class AppUser {
  final int id;
  final String nombre;
  final String apellido;
  final String correo;
  final String pass;
  final String legajo;
  final String cuil;
  final String telefono;
  final String puesto;
  final UserRole role;
  final int? obraAsignadaId;
  final bool activo;

  const AppUser({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.pass,
    required this.legajo,
    this.cuil = '',
    this.telefono = '',
    required this.puesto,
    required this.role,
    this.obraAsignadaId,
    this.activo = true,
  });

  String get nombreCompleto => '$nombre $apellido'.trim();

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'apellido': apellido,
        'correo': correo,
        'pass': pass,
        'legajo': legajo,
        'cuil': cuil,
        'telefono': telefono,
        'puesto': puesto,
        'permisos': role.dbPermisoValue,
        'obraAsignadaId': obraAsignadaId,
        'activo': activo ? 1 : 0,
      };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        id: (map['id'] as num).toInt(),
        nombre: (map['nombre'] ?? '') as String,
        apellido: (map['apellido'] ?? '') as String,
        correo: (map['correo'] ?? '') as String,
        pass: (map['pass'] ?? '') as String,
        legajo: (map['legajo'] ?? '') as String,
        cuil: (map['cuil'] ?? '').toString(),
        telefono: (map['telefono'] ?? '').toString(),
        puesto: (map['puesto'] ?? '') as String,
        role: UserRoleExtension.fromDbValue(((map['permisos'] ?? 5) as num).toInt()),
        obraAsignadaId: map['obraAsignadaId'] != null ? (map['obraAsignadaId'] as num).toInt() : null,
        activo: (map['activo'] ?? 1) == 1 || map['activo'] == true,
      );
}

class ObraSite {
  final int id;
  final int numeroInterno;
  final String nombreObra;
  final String empresaComitente;
  final String cuit;
  final String ubicacion;
  final String responsableNombre;
  final bool activa;

  const ObraSite({
    required this.id,
    required this.numeroInterno,
    required this.nombreObra,
    required this.empresaComitente,
    required this.cuit,
    required this.ubicacion,
    required this.responsableNombre,
    this.activa = true,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'numeroInterno': numeroInterno,
        'nombreObra': nombreObra,
        'empresaComitente': empresaComitente,
        'cuit': cuit,
        'ubicacion': ubicacion,
        'responsableNombre': responsableNombre,
        'activa': activa ? 1 : 0,
      };

  factory ObraSite.fromMap(Map<String, dynamic> map) => ObraSite(
        id: (map['id'] as num).toInt(),
        numeroInterno: ((map['numeroInterno'] ?? 0) as num).toInt(),
        nombreObra: (map['nombreObra'] ?? '') as String,
        empresaComitente: (map['empresaComitente'] ?? '') as String,
        cuit: (map['cuit'] ?? '') as String,
        ubicacion: (map['ubicacion'] ?? '') as String,
        responsableNombre: (map['responsableNombre'] ?? '') as String,
        activa: (map['activa'] ?? 1) == 1 || map['activa'] == true,
      );
}

class EquipmentItem {
  final int id;
  final String codigo; // ej. PC008, RE016, MN004, CA020, UM032, AM001
  final String dominio; // Patente o serie corta
  final int anio;
  final String estado; // 'En uso', 'Disponible', 'En Reparación', 'Alquilada', 'Baja', 'Robado'
  final int marcaId;
  final String marcaNombre;
  final String modeloNombre;
  final int tipoEquipoId;
  final String tipoEquipoNombre;
  final AssetCategory categoria;
  final int traccionId;
  final String traccionNombre;
  final double potencia;
  final String unidadPotencia; // HP, CV, kVA, W
  final double capacidad;
  final String unidadCapacidad; // Lts, m3, Tn
  final String nChasis;
  final String nMotor;
  final String seguroCompania;
  final String nPoliza;
  final String tipoSeguro;
  final String vencimientoSeguro; // YYYY-MM-DD
  final double valCompra; // USD
  final double pMensual; // Costo / canon mensual operativo
  final double pStandby; // Costo stand-by mensual
  final int obraActualId;
  final String responsableActual; // Para herramientas o chofer/operador asignado
  final double lecturaActual; // Horómetro (hs) u Odómetro (km)
  final double proximoServiceLectura; // Próximo service preventivo (hs o km)
  final double intervaloService; // Ej. 250 hs o 10000 km
  final String tipoCombustible; // Diesel, Nafta, Electricidad
  final double capacidadTanqueLts;
  final String aceiteMotorSpec; // Ej. SAE 15W-40 CI-4 (22 Lts)
  final String aceiteHidraulicoSpec; // Ej. ISO VG 46 / 68 (115 Lts)
  final String aceiteTransmisionSpec; // Ej. SAE 80W-90 / ATF
  final String notasTecnicas;

  const EquipmentItem({
    required this.id,
    required this.codigo,
    required this.dominio,
    required this.anio,
    required this.estado,
    required this.marcaId,
    required this.marcaNombre,
    required this.modeloNombre,
    required this.tipoEquipoId,
    required this.tipoEquipoNombre,
    required this.categoria,
    required this.traccionId,
    required this.traccionNombre,
    required this.potencia,
    this.unidadPotencia = 'HP',
    this.capacidad = 0,
    this.unidadCapacidad = 'Lts',
    required this.nChasis,
    required this.nMotor,
    this.seguroCompania = '',
    this.nPoliza = '',
    this.tipoSeguro = '',
    this.vencimientoSeguro = '',
    this.valCompra = 0,
    this.pMensual = 0,
    this.pStandby = 0,
    this.obraActualId = 1,
    this.responsableActual = '',
    this.lecturaActual = 0,
    this.proximoServiceLectura = 250,
    this.intervaloService = 250,
    this.tipoCombustible = 'Diesel',
    this.capacidadTanqueLts = 180,
    this.aceiteMotorSpec = 'SAE 15W-40 API CI-4',
    this.aceiteHidraulicoSpec = 'Hidráulico ISO VG 68',
    this.aceiteTransmisionSpec = 'SAE 80W-90 / Servotransmisión',
    this.notasTecnicas = '',
  });

  String get tituloCorto {
    final m = [marcaNombre, modeloNombre].where((s) => s.trim().isNotEmpty).join(' ');
    return m.isEmpty ? '$codigo · $tipoEquipoNombre' : '$codigo · $m';
  }

  String get descripcionCompleta {
    final m = [marcaNombre, modeloNombre].where((s) => s.trim().isNotEmpty).join(' ');
    return m.isEmpty ? tipoEquipoNombre : '$tipoEquipoNombre — $m';
  }

  double get restanteParaService => proximoServiceLectura - lecturaActual;

  bool get requiereServiceUrgente =>
      categoria != AssetCategory.herramienta && restanteParaService <= 0;

  bool get requiereServiceProximo =>
      categoria != AssetCategory.herramienta &&
      restanteParaService > 0 &&
      restanteParaService <= (categoria == AssetCategory.vehiculo ? 1000 : 35);

  EquipmentItem copyWith({
    String? codigo,
    String? dominio,
    int? anio,
    String? estado,
    String? marcaNombre,
    String? modeloNombre,
    String? tipoEquipoNombre,
    AssetCategory? categoria,
    String? traccionNombre,
    double? potencia,
    String? unidadPotencia,
    double? capacidad,
    String? nChasis,
    String? nMotor,
    String? seguroCompania,
    String? nPoliza,
    String? tipoSeguro,
    String? vencimientoSeguro,
    double? valCompra,
    double? pMensual,
    double? pStandby,
    int? obraActualId,
    String? responsableActual,
    double? lecturaActual,
    double? proximoServiceLectura,
    double? intervaloService,
    String? tipoCombustible,
    double? capacidadTanqueLts,
    String? aceiteMotorSpec,
    String? aceiteHidraulicoSpec,
    String? aceiteTransmisionSpec,
    String? notasTecnicas,
  }) {
    return EquipmentItem(
      id: id,
      codigo: codigo ?? this.codigo,
      dominio: dominio ?? this.dominio,
      anio: anio ?? this.anio,
      estado: estado ?? this.estado,
      marcaId: marcaId,
      marcaNombre: marcaNombre ?? this.marcaNombre,
      modeloNombre: modeloNombre ?? this.modeloNombre,
      tipoEquipoId: tipoEquipoId,
      tipoEquipoNombre: tipoEquipoNombre ?? this.tipoEquipoNombre,
      categoria: categoria ?? this.categoria,
      traccionId: traccionId,
      traccionNombre: traccionNombre ?? this.traccionNombre,
      potencia: potencia ?? this.potencia,
      unidadPotencia: unidadPotencia ?? this.unidadPotencia,
      capacidad: capacidad ?? this.capacidad,
      unidadCapacidad: unidadCapacidad,
      nChasis: nChasis ?? this.nChasis,
      nMotor: nMotor ?? this.nMotor,
      seguroCompania: seguroCompania ?? this.seguroCompania,
      nPoliza: nPoliza ?? this.nPoliza,
      tipoSeguro: tipoSeguro ?? this.tipoSeguro,
      vencimientoSeguro: vencimientoSeguro ?? this.vencimientoSeguro,
      valCompra: valCompra ?? this.valCompra,
      pMensual: pMensual ?? this.pMensual,
      pStandby: pStandby ?? this.pStandby,
      obraActualId: obraActualId ?? this.obraActualId,
      responsableActual: responsableActual ?? this.responsableActual,
      lecturaActual: lecturaActual ?? this.lecturaActual,
      proximoServiceLectura: proximoServiceLectura ?? this.proximoServiceLectura,
      intervaloService: intervaloService ?? this.intervaloService,
      tipoCombustible: tipoCombustible ?? this.tipoCombustible,
      capacidadTanqueLts: capacidadTanqueLts ?? this.capacidadTanqueLts,
      aceiteMotorSpec: aceiteMotorSpec ?? this.aceiteMotorSpec,
      aceiteHidraulicoSpec: aceiteHidraulicoSpec ?? this.aceiteHidraulicoSpec,
      aceiteTransmisionSpec: aceiteTransmisionSpec ?? this.aceiteTransmisionSpec,
      notasTecnicas: notasTecnicas ?? this.notasTecnicas,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'codigo': codigo,
        'dominio': dominio,
        'anio': anio,
        'estado': estado,
        'marcaId': marcaId,
        'marcaNombre': marcaNombre,
        'modeloNombre': modeloNombre,
        'tipoEquipoId': tipoEquipoId,
        'tipoEquipoNombre': tipoEquipoNombre,
        'categoria': categoria.index,
        'traccionId': traccionId,
        'traccionNombre': traccionNombre,
        'potencia': potencia,
        'unidadPotencia': unidadPotencia,
        'capacidad': capacidad,
        'unidadCapacidad': unidadCapacidad,
        'nChasis': nChasis,
        'nMotor': nMotor,
        'seguroCompania': seguroCompania,
        'nPoliza': nPoliza,
        'tipoSeguro': tipoSeguro,
        'vencimientoSeguro': vencimientoSeguro,
        'valCompra': valCompra,
        'pMensual': pMensual,
        'pStandby': pStandby,
        'obraActualId': obraActualId,
        'responsableActual': responsableActual,
        'lecturaActual': lecturaActual,
        'proximoServiceLectura': proximoServiceLectura,
        'intervaloService': intervaloService,
        'tipoCombustible': tipoCombustible,
        'capacidadTanqueLts': capacidadTanqueLts,
        'aceiteMotorSpec': aceiteMotorSpec,
        'aceiteHidraulicoSpec': aceiteHidraulicoSpec,
        'aceiteTransmisionSpec': aceiteTransmisionSpec,
        'notasTecnicas': notasTecnicas,
      };

  factory EquipmentItem.fromMap(Map<String, dynamic> map) => EquipmentItem(
        id: (map['id'] as num).toInt(),
        codigo: (map['codigo'] ?? '') as String,
        dominio: (map['dominio'] ?? '') as String,
        anio: ((map['anio'] ?? 0) as num).toInt(),
        estado: (map['estado'] ?? 'En uso') as String,
        marcaId: ((map['marcaId'] ?? 0) as num).toInt(),
        marcaNombre: (map['marcaNombre'] ?? '') as String,
        modeloNombre: (map['modeloNombre'] ?? '') as String,
        tipoEquipoId: ((map['tipoEquipoId'] ?? 0) as num).toInt(),
        tipoEquipoNombre: (map['tipoEquipoNombre'] ?? '') as String,
        categoria: AssetCategory.values[((map['categoria'] ?? 0) as num).toInt().clamp(0, 2)],
        traccionId: ((map['traccionId'] ?? 1) as num).toInt(),
        traccionNombre: (map['traccionNombre'] ?? 'Neumaticos') as String,
        potencia: ((map['potencia'] ?? 0) as num).toDouble(),
        unidadPotencia: (map['unidadPotencia'] ?? 'HP') as String,
        capacidad: ((map['capacidad'] ?? 0) as num).toDouble(),
        unidadCapacidad: (map['unidadCapacidad'] ?? 'Lts') as String,
        nChasis: (map['nChasis'] ?? '') as String,
        nMotor: (map['nMotor'] ?? '') as String,
        seguroCompania: (map['seguroCompania'] ?? '') as String,
        nPoliza: (map['nPoliza'] ?? '') as String,
        tipoSeguro: (map['tipoSeguro'] ?? '') as String,
        vencimientoSeguro: (map['vencimientoSeguro'] ?? '') as String,
        valCompra: ((map['valCompra'] ?? 0) as num).toDouble(),
        pMensual: ((map['pMensual'] ?? 0) as num).toDouble(),
        pStandby: ((map['pStandby'] ?? 0) as num).toDouble(),
        obraActualId: ((map['obraActualId'] ?? 1) as num).toInt(),
        responsableActual: (map['responsableActual'] ?? '') as String,
        lecturaActual: ((map['lecturaActual'] ?? 0) as num).toDouble(),
        proximoServiceLectura: ((map['proximoServiceLectura'] ?? 250) as num).toDouble(),
        intervaloService: ((map['intervaloService'] ?? 250) as num).toDouble(),
        tipoCombustible: (map['tipoCombustible'] ?? 'Diesel') as String,
        capacidadTanqueLts: ((map['capacidadTanqueLts'] ?? 180) as num).toDouble(),
        aceiteMotorSpec: (map['aceiteMotorSpec'] ?? 'SAE 15W-40') as String,
        aceiteHidraulicoSpec: (map['aceiteHidraulicoSpec'] ?? 'ISO VG 68') as String,
        aceiteTransmisionSpec: (map['aceiteTransmisionSpec'] ?? 'SAE 80W-90') as String,
        notasTecnicas: (map['notasTecnicas'] ?? '') as String,
      );
}

/// Parte Diario (Tabla `partediario` ampliada con Hora de Inicio/Fin, Observaciones y Solicitud de Reparación)
class ParteDiario {
  final int id;
  final int numeroParte;
  final int equipoId;
  final String equipoCodigo;
  final String fecha; // YYYY-MM-DD
  final String horaInicio; // HH:mm
  final String horaFin; // HH:mm
  final double horometroInicial; // hs o km
  final double horometroFinal; // hs o km
  final int obraId;
  final int operarioId;
  final String operarioNombre;
  final double ltsCombustible;
  final String tipoCombustible;
  final double ltsLubricante;
  final String tipoLubricante; // Motor, Hidráulico, Transmisión, Grasa
  final String nroValeCarga;
  final String nroOrdenCompra;
  final String trabajosRealizados;
  final String observacionesFuncionamiento;
  final bool solicitaReparacion;
  final String detalleSolicitudReparacion;
  final String urgenciaReparacion; // 'Normal', 'Alta', 'Crítica - Equipo Detenido'
  final bool sincronizadoServidor; // Para modo Offline en Android

  const ParteDiario({
    required this.id,
    required this.numeroParte,
    required this.equipoId,
    required this.equipoCodigo,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.horometroInicial,
    required this.horometroFinal,
    required this.obraId,
    required this.operarioId,
    required this.operarioNombre,
    required this.ltsCombustible,
    required this.tipoCombustible,
    required this.ltsLubricante,
    required this.tipoLubricante,
    required this.nroValeCarga,
    required this.nroOrdenCompra,
    required this.trabajosRealizados,
    required this.observacionesFuncionamiento,
    required this.solicitaReparacion,
    this.detalleSolicitudReparacion = '',
    this.urgenciaReparacion = 'Normal',
    this.sincronizadoServidor = true,
  });

  double get usoRegistrado => (horometroFinal - horometroInicial).clamp(0, 999999);

  Map<String, dynamic> toMap() => {
        'id': id,
        'numeroParte': numeroParte,
        'equipoId': equipoId,
        'equipoCodigo': equipoCodigo,
        'fecha': fecha,
        'horaInicio': horaInicio,
        'horaFin': horaFin,
        'horometroInicial': horometroInicial,
        'horometroFinal': horometroFinal,
        'obraId': obraId,
        'operarioId': operarioId,
        'operarioNombre': operarioNombre,
        'ltsCombustible': ltsCombustible,
        'tipoCombustible': tipoCombustible,
        'ltsLubricante': ltsLubricante,
        'tipoLubricante': tipoLubricante,
        'nroValeCarga': nroValeCarga,
        'nroOrdenCompra': nroOrdenCompra,
        'trabajosRealizados': trabajosRealizados,
        'observacionesFuncionamiento': observacionesFuncionamiento,
        'solicitaReparacion': solicitaReparacion ? 1 : 0,
        'detalleSolicitudReparacion': detalleSolicitudReparacion,
        'urgenciaReparacion': urgenciaReparacion,
        'sincronizadoServidor': sincronizadoServidor ? 1 : 0,
      };

  factory ParteDiario.fromMap(Map<String, dynamic> map) => ParteDiario(
        id: (map['id'] as num).toInt(),
        numeroParte: ((map['numeroParte'] ?? 0) as num).toInt(),
        equipoId: ((map['equipoId'] ?? 0) as num).toInt(),
        equipoCodigo: (map['equipoCodigo'] ?? '') as String,
        fecha: (map['fecha'] ?? '') as String,
        horaInicio: (map['horaInicio'] ?? '07:30') as String,
        horaFin: (map['horaFin'] ?? '17:00') as String,
        horometroInicial: ((map['horometroInicial'] ?? 0) as num).toDouble(),
        horometroFinal: ((map['horometroFinal'] ?? 0) as num).toDouble(),
        obraId: ((map['obraId'] ?? 1) as num).toInt(),
        operarioId: ((map['operarioId'] ?? 5) as num).toInt(),
        operarioNombre: (map['operarioNombre'] ?? '') as String,
        ltsCombustible: ((map['ltsCombustible'] ?? 0) as num).toDouble(),
        tipoCombustible: (map['tipoCombustible'] ?? 'Diesel') as String,
        ltsLubricante: ((map['ltsLubricante'] ?? 0) as num).toDouble(),
        tipoLubricante: (map['tipoLubricante'] ?? 'Sin agregado') as String,
        nroValeCarga: (map['nroValeCarga'] ?? '') as String,
        nroOrdenCompra: (map['nroOrdenCompra'] ?? '') as String,
        trabajosRealizados: (map['trabajosRealizados'] ?? '') as String,
        observacionesFuncionamiento: (map['observacionesFuncionamiento'] ?? '') as String,
        solicitaReparacion: (map['solicitaReparacion'] ?? 0) == 1 || map['solicitaReparacion'] == true,
        detalleSolicitudReparacion: (map['detalleSolicitudReparacion'] ?? '') as String,
        urgenciaReparacion: (map['urgenciaReparacion'] ?? 'Normal') as String,
        sincronizadoServidor: (map['sincronizadoServidor'] ?? 1) == 1 || map['sincronizadoServidor'] == true,
      );
}

/// Informe de Taller: Mantenimiento Preventivo, Reparación Correctiva o Parte Diario de Trabajo Mecánico
/// Basado en las tablas `service` y `partemecanica` de dbequipos
class InformeTaller {
  final int id;
  final int equipoId;
  final String equipoCodigo;
  final String fecha;
  final String tipoIntervencion; // 'Mantenimiento Preventivo', 'Reparación Correctiva', 'Parte Diario Taller'
  final String estadoOrden; // 'Pendiente', 'En Proceso', 'Completado'
  final double horometroAlMomento;
  final String lugar; // 'Taller Central', 'Frente de Obra', 'Proveedor Externo'
  final String mecanicoResponsable;
  final bool checkCambioFiltro;
  final bool checkCambioLubricante;
  final String filtrosUtilizados;
  final String lubricantesUtilizados;
  final String repuestosUtilizados;
  final String sistemaAfectado; // Motor, Hidráulico, Transmisión, Eléctrico, Tren Rodante, Chapa/Chasis
  final double costoRepuestos; // USD / ARS
  final double costoManoObra;
  final double horasTrabajoTaller;
  final String observaciones;
  final int? parteDiarioOrigenId; // Si nació de una solicitud de reparación de un operario
  final bool sincronizadoServidor;

  const InformeTaller({
    required this.id,
    required this.equipoId,
    required this.equipoCodigo,
    required this.fecha,
    required this.tipoIntervencion,
    required this.estadoOrden,
    required this.horometroAlMomento,
    required this.lugar,
    required this.mecanicoResponsable,
    required this.checkCambioFiltro,
    required this.checkCambioLubricante,
    this.filtrosUtilizados = '',
    this.lubricantesUtilizados = '',
    this.repuestosUtilizados = '',
    this.sistemaAfectado = 'Motor y Filtros',
    this.costoRepuestos = 0,
    this.costoManoObra = 0,
    this.horasTrabajoTaller = 2.0,
    required this.observaciones,
    this.parteDiarioOrigenId,
    this.sincronizadoServidor = true,
  });

  double get costoTotal => costoRepuestos + costoManoObra;

  Map<String, dynamic> toMap() => {
        'id': id,
        'equipoId': equipoId,
        'equipoCodigo': equipoCodigo,
        'fecha': fecha,
        'tipoIntervencion': tipoIntervencion,
        'estadoOrden': estadoOrden,
        'horometroAlMomento': horometroAlMomento,
        'lugar': lugar,
        'mecanicoResponsable': mecanicoResponsable,
        'checkCambioFiltro': checkCambioFiltro ? 1 : 0,
        'checkCambioLubricante': checkCambioLubricante ? 1 : 0,
        'filtrosUtilizados': filtrosUtilizados,
        'lubricantesUtilizados': lubricantesUtilizados,
        'repuestosUtilizados': repuestosUtilizados,
        'sistemaAfectado': sistemaAfectado,
        'costoRepuestos': costoRepuestos,
        'costoManoObra': costoManoObra,
        'horasTrabajoTaller': horasTrabajoTaller,
        'observaciones': observaciones,
        'parteDiarioOrigenId': parteDiarioOrigenId,
        'sincronizadoServidor': sincronizadoServidor ? 1 : 0,
      };

  factory InformeTaller.fromMap(Map<String, dynamic> map) => InformeTaller(
        id: (map['id'] as num).toInt(),
        equipoId: ((map['equipoId'] ?? 0) as num).toInt(),
        equipoCodigo: (map['equipoCodigo'] ?? '') as String,
        fecha: (map['fecha'] ?? '') as String,
        tipoIntervencion: (map['tipoIntervencion'] ?? 'Mantenimiento Preventivo') as String,
        estadoOrden: (map['estadoOrden'] ?? 'Completado') as String,
        horometroAlMomento: ((map['horometroAlMomento'] ?? 0) as num).toDouble(),
        lugar: (map['lugar'] ?? 'Taller Central') as String,
        mecanicoResponsable: (map['mecanicoResponsable'] ?? 'Roberto Sánchez') as String,
        checkCambioFiltro: (map['checkCambioFiltro'] ?? 0) == 1 || map['checkCambioFiltro'] == true,
        checkCambioLubricante: (map['checkCambioLubricante'] ?? 0) == 1 || map['checkCambioLubricante'] == true,
        filtrosUtilizados: (map['filtrosUtilizados'] ?? '') as String,
        lubricantesUtilizados: (map['lubricantesUtilizados'] ?? '') as String,
        repuestosUtilizados: (map['repuestosUtilizados'] ?? '') as String,
        sistemaAfectado: (map['sistemaAfectado'] ?? 'Motor') as String,
        costoRepuestos: ((map['costoRepuestos'] ?? 0) as num).toDouble(),
        costoManoObra: ((map['costoManoObra'] ?? 0) as num).toDouble(),
        horasTrabajoTaller: ((map['horasTrabajoTaller'] ?? 2.0) as num).toDouble(),
        observaciones: (map['observaciones'] ?? '') as String,
        parteDiarioOrigenId:
            map['parteDiarioOrigenId'] != null ? (map['parteDiarioOrigenId'] as num).toInt() : null,
        sincronizadoServidor: (map['sincronizadoServidor'] ?? 1) == 1 || map['sincronizadoServidor'] == true,
      );
}

/// Repuestos y Filtros vinculados a Equipos (Tabla `filtros` y catálogo de despiece)
class FiltroRepuestoItem {
  final int id;
  final String codigoOriginal;
  final String equivalenciaMannFram; // Ej. Mann WP 12121 / Donaldson P550388 / Fleetguard LF3349
  final String tipoComponente; // 'Filtro de Aceite Motor', 'Filtro Combustible Primario', 'Filtro Aire Primario', 'Filtro Hidráulico', 'Correa / Repuesto', 'Diente / Cuchilla'
  final String equiposCompatiblesCodigos; // Ej. 'PC008, PC009' o 'RE012, RE016, RE017'
  final int stockActual;
  final int stockMinimo;
  final double costoUnitarioUsd;
  final String ubicacionEstanteria; // Ej. 'Estante A-04'
  final String referenciaPlanoDespiece; // Ej. 'Conjunto Motor - Pos. #14'

  const FiltroRepuestoItem({
    required this.id,
    required this.codigoOriginal,
    required this.equivalenciaMannFram,
    required this.tipoComponente,
    required this.equiposCompatiblesCodigos,
    required this.stockActual,
    required this.stockMinimo,
    required this.costoUnitarioUsd,
    required this.ubicacionEstanteria,
    this.referenciaPlanoDespiece = '',
  });

  bool get stockCritico => stockActual <= stockMinimo;

  Map<String, dynamic> toMap() => {
        'id': id,
        'codigoOriginal': codigoOriginal,
        'equivalenciaMannFram': equivalenciaMannFram,
        'tipoComponente': tipoComponente,
        'equiposCompatiblesCodigos': equiposCompatiblesCodigos,
        'stockActual': stockActual,
        'stockMinimo': stockMinimo,
        'costoUnitarioUsd': costoUnitarioUsd,
        'ubicacionEstanteria': ubicacionEstanteria,
        'referenciaPlanoDespiece': referenciaPlanoDespiece,
      };

  factory FiltroRepuestoItem.fromMap(Map<String, dynamic> map) => FiltroRepuestoItem(
        id: (map['id'] as num).toInt(),
        codigoOriginal: (map['codigoOriginal'] ?? '') as String,
        equivalenciaMannFram: (map['equivalenciaMannFram'] ?? '') as String,
        tipoComponente: (map['tipoComponente'] ?? '') as String,
        equiposCompatiblesCodigos: (map['equiposCompatiblesCodigos'] ?? '') as String,
        stockActual: ((map['stockActual'] ?? 0) as num).toInt(),
        stockMinimo: ((map['stockMinimo'] ?? 2) as num).toInt(),
        costoUnitarioUsd: ((map['costoUnitarioUsd'] ?? 0) as num).toDouble(),
        ubicacionEstanteria: (map['ubicacionEstanteria'] ?? 'Pañol Central') as String,
        referenciaPlanoDespiece: (map['referenciaPlanoDespiece'] ?? '') as String,
      );
}

/// Gastos ocasionados por los equipos (Cargados por Administración o generados por Taller/Combustible)
class GastoEquipo {
  final int id;
  final int equipoId;
  final String equipoCodigo;
  final String fecha;
  final String categoriaGasto; // 'Combustible', 'Lubricantes', 'Repuestos y Filtros', 'Reparación Externa', 'Seguro / Patente', 'Neumáticos / Tren Rodante', 'Traslado / Carretón'
  final String proveedor;
  final String nroComprobante;
  final double montoUsd;
  final int obraId;
  final String registradoPor;
  final String descripcion;

  const GastoEquipo({
    required this.id,
    required this.equipoId,
    required this.equipoCodigo,
    required this.fecha,
    required this.categoriaGasto,
    required this.proveedor,
    required this.nroComprobante,
    required this.montoUsd,
    required this.obraId,
    required this.registradoPor,
    required this.descripcion,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'equipoId': equipoId,
        'equipoCodigo': equipoCodigo,
        'fecha': fecha,
        'categoriaGasto': categoriaGasto,
        'proveedor': proveedor,
        'nroComprobante': nroComprobante,
        'montoUsd': montoUsd,
        'obraId': obraId,
        'registradoPor': registradoPor,
        'descripcion': descripcion,
      };

  factory GastoEquipo.fromMap(Map<String, dynamic> map) => GastoEquipo(
        id: (map['id'] as num).toInt(),
        equipoId: ((map['equipoId'] ?? 0) as num).toInt(),
        equipoCodigo: (map['equipoCodigo'] ?? '') as String,
        fecha: (map['fecha'] ?? '') as String,
        categoriaGasto: (map['categoriaGasto'] ?? 'Repuestos y Filtros') as String,
        proveedor: (map['proveedor'] ?? '') as String,
        nroComprobante: (map['nroComprobante'] ?? '') as String,
        montoUsd: ((map['montoUsd'] ?? 0) as num).toDouble(),
        obraId: ((map['obraId'] ?? 1) as num).toInt(),
        registradoPor: (map['registradoPor'] ?? '') as String,
        descripcion: (map['descripcion'] ?? '') as String,
      );
}

/// Historial de Asignación y Retiro de Equipos a Frentes de Obra (Gerencia / Jefe de Obra)
class MovimientoObra {
  final int id;
  final int equipoId;
  final String equipoCodigo;
  final int obraOrigenId;
  final int obraDestinoId;
  final String fecha;
  final String tipoMovimiento; // 'Designación a Obra', 'Retiro a Taller/Depósito', 'Transferencia entre Obras'
  final String autorizadoPor;
  final double lecturaHorometro;
  final String motivoObservaciones;

  const MovimientoObra({
    required this.id,
    required this.equipoId,
    required this.equipoCodigo,
    required this.obraOrigenId,
    required this.obraDestinoId,
    required this.fecha,
    required this.tipoMovimiento,
    required this.autorizadoPor,
    required this.lecturaHorometro,
    required this.motivoObservaciones,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'equipoId': equipoId,
        'equipoCodigo': equipoCodigo,
        'obraOrigenId': obraOrigenId,
        'obraDestinoId': obraDestinoId,
        'fecha': fecha,
        'tipoMovimiento': tipoMovimiento,
        'autorizadoPor': autorizadoPor,
        'lecturaHorometro': lecturaHorometro,
        'motivoObservaciones': motivoObservaciones,
      };

  factory MovimientoObra.fromMap(Map<String, dynamic> map) => MovimientoObra(
        id: (map['id'] as num).toInt(),
        equipoId: ((map['equipoId'] ?? 0) as num).toInt(),
        equipoCodigo: (map['equipoCodigo'] ?? '') as String,
        obraOrigenId: ((map['obraOrigenId'] ?? 1) as num).toInt(),
        obraDestinoId: ((map['obraDestinoId'] ?? 1) as num).toInt(),
        fecha: (map['fecha'] ?? '') as String,
        tipoMovimiento: (map['tipoMovimiento'] ?? 'Designación a Obra') as String,
        autorizadoPor: (map['autorizadoPor'] ?? '') as String,
        lecturaHorometro: ((map['lecturaHorometro'] ?? 0) as num).toDouble(),
        motivoObservaciones: (map['motivoObservaciones'] ?? '') as String,
      );
}
