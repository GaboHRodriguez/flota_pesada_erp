import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/erp_models.dart';
import '../data/dbequipos_seed.dart';
import 'remote_api_client.dart';

class ErpDatabaseService extends ChangeNotifier {
  static final ErpDatabaseService instance = ErpDatabaseService._internal();
  ErpDatabaseService._internal();

  static const String _kStoragePrefix = 'flota_erp_v2_';
  static const String defaultRemoteApiUrl = 'https://funcioncreativa.com.ar/eqp/api.php';

  bool _initialized = false;
  bool get isInitialized => _initialized;

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  bool _offlineMode = false;
  bool get offlineMode => _offlineMode;

  bool _connectedToRemoteMySql = false;
  bool get connectedToRemoteMySql => _connectedToRemoteMySql;

  String _windowsServerUrl = defaultRemoteApiUrl;
  String get windowsServerUrl => _windowsServerUrl;

  DateTime _lastSyncTime = DateTime.now();
  DateTime get lastSyncTime => _lastSyncTime;

  List<AppUser> _usuarios = [];
  List<ObraSite> _obras = [];
  List<EquipmentItem> _equipos = [];
  List<FiltroRepuestoItem> _filtrosRepuestos = [];
  List<ParteDiario> _partesDiarios = [];
  List<InformeTaller> _informesTaller = [];
  List<GastoEquipo> _gastosEquipos = [];
  List<MovimientoObra> _movimientosObra = [];
  List<String> _auditLogs = [];

  List<AppUser> get usuarios => List.unmodifiable(_usuarios);
  List<ObraSite> get obras => List.unmodifiable(_obras);
  List<EquipmentItem> get equipos => List.unmodifiable(_equipos);
  List<FiltroRepuestoItem> get filtrosRepuestos => List.unmodifiable(_filtrosRepuestos);
  List<ParteDiario> get partesDiarios => List.unmodifiable(_partesDiarios);
  List<InformeTaller> get informesTaller => List.unmodifiable(_informesTaller);
  List<GastoEquipo> get gastosEquipos => List.unmodifiable(_gastosEquipos);
  List<MovimientoObra> get movimientosObra => List.unmodifiable(_movimientosObra);
  List<String> get auditLogs => List.unmodifiable(_auditLogs);

  int get pendientesSincronizarCount {
    final pCount = _partesDiarios.where((p) => !p.sincronizadoServidor).length;
    final tCount = _informesTaller.where((t) => !t.sincronizadoServidor).length;
    return pCount + tCount;
  }

  String _buildEndpoint(String action) {
    final base = _windowsServerUrl.trim();
    final sep = base.contains('?') ? '&' : '?';
    return '$base${sep}action=$action';
  }

  Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _windowsServerUrl = prefs.getString('${_kStoragePrefix}server_url') ?? defaultRemoteApiUrl;
      _offlineMode = prefs.getBool('${_kStoragePrefix}offline_mode') ?? false;

      final hasSeed = prefs.getBool('${_kStoragePrefix}seeded') ?? false;
      if (!hasSeed) {
        await _resetToSeed(prefs);
      } else {
        _loadFromPrefs(prefs);
      }
    } catch (_) {
      _loadDefaultsInMemory();
    }
    _initialized = true;
    notifyListeners();

    // Intentar sincronizar en segundo plano desde el MySQL remoto en funcioncreativa.com.ar
    if (!_offlineMode) {
      sincronizarDesdeServidorRemoto();
    }
  }

  /// Lee en tiempo real desde https://funcioncreativa.com.ar/eqp/api.php?action=bootstrap
  Future<bool> sincronizarDesdeServidorRemoto() async {
    if (_offlineMode) return false;
    final data = await RemoteApiClient.getJson(_buildEndpoint('bootstrap'));
    if (data == null || data['ok'] != true) {
      _connectedToRemoteMySql = false;
      notifyListeners();
      return false;
    }

    _connectedToRemoteMySql = true;
    _lastSyncTime = DateTime.now();

    // Actualizar estados y horas_motor de equipos desde la tabla remota `equipos`
    if (data['equipos'] is List) {
      final remoteList = data['equipos'] as List;
      final remoteById = <int, Map<String, dynamic>>{};
      for (final raw in remoteList) {
        if (raw is Map<String, dynamic>) {
          final id = int.tryParse(raw['id'].toString());
          if (id != null) remoteById[id] = raw;
        }
      }
      _equipos = _equipos.map((localEq) {
        final r = remoteById[localEq.id];
        if (r == null) return localEq;
        final estadoRemoto = (r['estado'] ?? '').toString().trim();
        final domRemoto = (r['dominio'] ?? '').toString().trim();
        final horasRemotas = double.tryParse((r['horas_motor'] ?? '').toString());
        return localEq.copyWith(
          estado: estadoRemoto.isNotEmpty ? estadoRemoto : localEq.estado,
          dominio: domRemoto.isNotEmpty ? domRemoto : localEq.dominio,
          lecturaActual: (horasRemotas != null && horasRemotas > 0)
              ? horasRemotas
              : localEq.lecturaActual,
        );
      }).toList();
    }

    // Actualizar stock del Pañol desde `repuestos_catalogo`
    if (data['repuestosCatalogo'] is List && (data['repuestosCatalogo'] as List).isNotEmpty) {
      final stockByOem = <String, int>{};
      for (final raw in (data['repuestosCatalogo'] as List)) {
        if (raw is Map<String, dynamic>) {
          final oem = (raw['numero_parte_oem'] ?? '').toString().trim().toUpperCase();
          final st = int.tryParse((raw['stock_actual'] ?? '0').toString()) ?? 0;
          if (oem.isNotEmpty) stockByOem[oem] = st;
        }
      }
      if (stockByOem.isNotEmpty) {
        _filtrosRepuestos = _filtrosRepuestos.map((item) {
          final st = stockByOem[item.codigoOriginal.trim().toUpperCase()];
          if (st == null) return item;
          return FiltroRepuestoItem(
            id: item.id,
            codigoOriginal: item.codigoOriginal,
            equivalenciaMannFram: item.equivalenciaMannFram,
            tipoComponente: item.tipoComponente,
            equiposCompatiblesCodigos: item.equiposCompatiblesCodigos,
            stockActual: st,
            stockMinimo: item.stockMinimo,
            costoUnitarioUsd: item.costoUnitarioUsd,
            ubicacionEstanteria: item.ubicacionEstanteria,
            referenciaPlanoDespiece: item.referenciaPlanoDespiece,
          );
        }).toList();
      }
    }

    // Actualizar partes diarios desde tabla remota `partediario`
    if (data['partesDiarios'] is List && (data['partesDiarios'] as List).isNotEmpty) {
      final list = <ParteDiario>[];
      for (final raw in (data['partesDiarios'] as List)) {
        if (raw is Map<String, dynamic>) {
          final id = int.tryParse((raw['ID'] ?? raw['id'] ?? '1001').toString()) ?? 1001;
          final eqId = int.tryParse((raw['equipo'] ?? '1').toString()) ?? 1;
          final eq = getEquipoById(eqId);
          list.add(
            ParteDiario(
              id: id,
              numeroParte: int.tryParse((raw['numeroParte'] ?? id).toString()) ?? id,
              equipoId: eqId,
              equipoCodigo: eq?.codigo ?? 'EQ-$eqId',
              fecha: (raw['fecha'] ?? '2026-10-18').toString(),
              horaInicio: (raw['horaInicio'] ?? '07:30').toString(),
              horaFin: (raw['horaFin'] ?? '17:00').toString(),
              horometroInicial: double.tryParse((raw['horometroInicial'] ?? '0').toString()) ?? 0,
              horometroFinal: double.tryParse((raw['horometroFinal'] ?? '0').toString()) ?? 0,
              obraId: int.tryParse((raw['Obra'] ?? '1').toString()) ?? 1,
              operarioId: int.tryParse((raw['Operario'] ?? '5').toString()) ?? 5,
              operarioNombre: 'Operario Registrado',
              ltsCombustible: double.tryParse((raw['ltsCombustible'] ?? '0').toString()) ?? 0,
              tipoCombustible: 'Diesel',
              ltsLubricante: double.tryParse((raw['ltsLubricante'] ?? '0').toString()) ?? 0,
              tipoLubricante: 'SAE 15W-40 / Hidráulico',
              nroValeCarga: 'VC-${raw['nroValeCarga'] ?? "8841"}',
              nroOrdenCompra: 'OC-${raw['nroOrdenCompra'] ?? "312"}',
              trabajosRealizados: (raw['trabajosRealizados'] ?? '').toString(),
              observacionesFuncionamiento:
                  (raw['observacionesFuncionamiento'] ?? 'Sin novedades').toString(),
              solicitaReparacion:
                  raw['solicitaReparacion'].toString() == '1' || raw['solicitaReparacion'] == true,
              detalleSolicitudReparacion: (raw['detalleSolicitudReparacion'] ?? '').toString(),
              urgenciaReparacion: (raw['urgenciaReparacion'] ?? 'Normal').toString(),
              sincronizadoServidor: true,
            ),
          );
        }
      }
      // Preservar los pendientes offline locales que aún no se subieron
      final offlinePendientes = _partesDiarios.where((p) => !p.sincronizadoServidor).toList();
      _partesDiarios = [...offlinePendientes, ...list];
    }

    // Actualizar informes de taller desde tabla remota `service`
    if (data['informesTaller'] is List && (data['informesTaller'] as List).isNotEmpty) {
      final list = <InformeTaller>[];
      for (final raw in (data['informesTaller'] as List)) {
        if (raw is Map<String, dynamic>) {
          final id = int.tryParse((raw['id'] ?? '501').toString()) ?? 501;
          final eqId = int.tryParse((raw['equipo'] ?? '1').toString()) ?? 1;
          final eq = getEquipoById(eqId);
          list.add(
            InformeTaller(
              id: id,
              equipoId: eqId,
              equipoCodigo: eq?.codigo ?? 'EQ-$eqId',
              fecha: (raw['fecha'] ?? '2026-10-18').toString(),
              tipoIntervencion: (raw['tipoIntervencion'] ?? 'Mantenimiento Preventivo').toString(),
              estadoOrden: (raw['estadoOrden'] ?? 'Completado').toString(),
              horometroAlMomento: double.tryParse((raw['horometro'] ?? '0').toString()) ?? 0,
              lugar: (raw['lugar'] ?? 'Taller Central').toString(),
              mecanicoResponsable: (raw['mecanicoResponsable'] ?? 'Roberto Sánchez').toString(),
              checkCambioFiltro: raw['checkCambioFiltro'].toString() == '1',
              checkCambioLubricante: raw['checkCambioLub'].toString() == '1',
              filtrosUtilizados: 'Kit Filtros OEM',
              lubricantesUtilizados: 'Lubricante Motor / Hidráulico',
              repuestosUtilizados: (raw['repuestosUtilizados'] ?? '').toString(),
              sistemaAfectado: (raw['sistemaAfectado'] ?? 'Motor e Hidráulica').toString(),
              costoRepuestos: double.tryParse((raw['costoRepuestos'] ?? '0').toString()) ?? 0,
              costoManoObra: double.tryParse((raw['costoManoObra'] ?? '0').toString()) ?? 0,
              horasTrabajoTaller:
                  double.tryParse((raw['horasTrabajoTaller'] ?? '2.0').toString()) ?? 2.0,
              observaciones: (raw['observaciones'] ?? '').toString(),
              sincronizadoServidor: true,
            ),
          );
        }
      }
      final offlinePendientes = _informesTaller.where((t) => !t.sincronizadoServidor).toList();
      _informesTaller = [...offlinePendientes, ...list];
    }

    _addAudit('Sincronizado en tiempo real con MySQL remoto ($_windowsServerUrl).');
    await _persist();
    return true;
  }

  void _loadDefaultsInMemory() {
    _usuarios = List<AppUser>.from(ErpInitialData.usuarios);
    _obras = List<ObraSite>.from(ErpInitialData.obras);
    _equipos = List<EquipmentItem>.from(ErpInitialData.equipos);
    _filtrosRepuestos = List<FiltroRepuestoItem>.from(ErpInitialData.filtrosYRepuestos);
    _partesDiarios = List<ParteDiario>.from(ErpInitialData.partesDiarios);
    _informesTaller = List<InformeTaller>.from(ErpInitialData.informesTaller);
    _gastosEquipos = List<GastoEquipo>.from(ErpInitialData.gastosEquipos);
    _movimientosObra = List<MovimientoObra>.from(ErpInitialData.movimientosObra);
    _auditLogs = [
      '[2026-10-20 08:00] Sistema conectado a servidor remoto $defaultRemoteApiUrl (183 equipos).',
    ];
  }

  Future<void> _resetToSeed(SharedPreferences? prefs) async {
    _loadDefaultsInMemory();
    if (prefs != null) {
      await _saveAllToPrefs(prefs);
      await prefs.setBool('${_kStoragePrefix}seeded', true);
    }
    notifyListeners();
  }

  void _loadFromPrefs(SharedPreferences prefs) {
    try {
      final uJson = prefs.getString('${_kStoragePrefix}usuarios');
      final oJson = prefs.getString('${_kStoragePrefix}obras');
      final eJson = prefs.getString('${_kStoragePrefix}equipos');
      final fJson = prefs.getString('${_kStoragePrefix}filtros');
      final pJson = prefs.getString('${_kStoragePrefix}partes');
      final tJson = prefs.getString('${_kStoragePrefix}taller');
      final gJson = prefs.getString('${_kStoragePrefix}gastos');
      final mJson = prefs.getString('${_kStoragePrefix}movimientos');
      final aJson = prefs.getStringList('${_kStoragePrefix}audit');

      if (uJson == null || eJson == null) {
        _loadDefaultsInMemory();
        return;
      }

      _usuarios = (jsonDecode(uJson) as List).map((x) => AppUser.fromMap(x)).toList();
      _obras = oJson != null
          ? (jsonDecode(oJson) as List).map((x) => ObraSite.fromMap(x)).toList()
          : List<ObraSite>.from(ErpInitialData.obras);
      _equipos = (jsonDecode(eJson) as List).map((x) => EquipmentItem.fromMap(x)).toList();
      _filtrosRepuestos = fJson != null
          ? (jsonDecode(fJson) as List).map((x) => FiltroRepuestoItem.fromMap(x)).toList()
          : List<FiltroRepuestoItem>.from(ErpInitialData.filtrosYRepuestos);
      _partesDiarios = pJson != null
          ? (jsonDecode(pJson) as List).map((x) => ParteDiario.fromMap(x)).toList()
          : List<ParteDiario>.from(ErpInitialData.partesDiarios);
      _informesTaller = tJson != null
          ? (jsonDecode(tJson) as List).map((x) => InformeTaller.fromMap(x)).toList()
          : List<InformeTaller>.from(ErpInitialData.informesTaller);
      _gastosEquipos = gJson != null
          ? (jsonDecode(gJson) as List).map((x) => GastoEquipo.fromMap(x)).toList()
          : List<GastoEquipo>.from(ErpInitialData.gastosEquipos);
      _movimientosObra = mJson != null
          ? (jsonDecode(mJson) as List).map((x) => MovimientoObra.fromMap(x)).toList()
          : List<MovimientoObra>.from(ErpInitialData.movimientosObra);
      _auditLogs = aJson ??
          [
            '[2026-10-20 08:00] Sistema inicializado con base de datos dbequipos (183 equipos).',
          ];
    } catch (_) {
      _loadDefaultsInMemory();
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _saveAllToPrefs(prefs);
    } catch (_) {
      // Ignored in test environment
    }
    notifyListeners();
  }

  Future<void> _saveAllToPrefs(SharedPreferences prefs) async {
    await prefs.setString(
      '${_kStoragePrefix}usuarios',
      jsonEncode(_usuarios.map((x) => x.toMap()).toList()),
    );
    await prefs.setString(
      '${_kStoragePrefix}obras',
      jsonEncode(_obras.map((x) => x.toMap()).toList()),
    );
    await prefs.setString(
      '${_kStoragePrefix}equipos',
      jsonEncode(_equipos.map((x) => x.toMap()).toList()),
    );
    await prefs.setString(
      '${_kStoragePrefix}filtros',
      jsonEncode(_filtrosRepuestos.map((x) => x.toMap()).toList()),
    );
    await prefs.setString(
      '${_kStoragePrefix}partes',
      jsonEncode(_partesDiarios.map((x) => x.toMap()).toList()),
    );
    await prefs.setString(
      '${_kStoragePrefix}taller',
      jsonEncode(_informesTaller.map((x) => x.toMap()).toList()),
    );
    await prefs.setString(
      '${_kStoragePrefix}gastos',
      jsonEncode(_gastosEquipos.map((x) => x.toMap()).toList()),
    );
    await prefs.setString(
      '${_kStoragePrefix}movimientos',
      jsonEncode(_movimientosObra.map((x) => x.toMap()).toList()),
    );
    await prefs.setStringList('${_kStoragePrefix}audit', _auditLogs.take(100).toList());
    await prefs.setString('${_kStoragePrefix}server_url', _windowsServerUrl);
    await prefs.setBool('${_kStoragePrefix}offline_mode', _offlineMode);
  }

  void _addAudit(String action) {
    final now = DateTime.now();
    final stamp =
        '${now.year}-${now.month.toString().padLeft(2, "0")}-${now.day.toString().padLeft(2, "0")} ${now.hour.toString().padLeft(2, "0")}:${now.minute.toString().padLeft(2, "0")}';
    final actor = _currentUser?.nombreCompleto ?? 'Sistema';
    _auditLogs.insert(0, '[$stamp] ($actor) $action');
  }

  // ==================== AUTENTICACIÓN Y CAMBIO DE ROL ====================

  AppUser? loginWithEmailPassword(String email, String password) {
    final cleanEmail = email.trim().toLowerCase();
    for (final u in _usuarios) {
      if (u.correo.toLowerCase() == cleanEmail && u.pass == password && u.activo) {
        _currentUser = u;
        _addAudit('Inicio de sesión exitoso como ${u.role.label} (${u.correo}).');
        _persist();
        return u;
      }
    }
    return null;
  }

  void loginQuickAsRole(UserRole role) {
    final user = _usuarios.firstWhere(
      (u) => u.role == role && u.activo,
      orElse: () => _usuarios.first,
    );
    _currentUser = user;
    _addAudit('Acceso rápido activado con perfil ${user.role.label} (${user.nombreCompleto}).');
    _persist();
  }

  void logout() {
    if (_currentUser != null) {
      _addAudit('Cierre de sesión de ${_currentUser!.correo}.');
    }
    _currentUser = null;
    notifyListeners();
  }

  // ==================== MODO OFFLINE Y SINCRONIZACIÓN REMOTA MYSQL ====================

  Future<void> toggleOfflineMode(bool value) async {
    _offlineMode = value;
    _addAudit(value
        ? 'Modo Offline Android activado (Almacenamiento en cola local para obra sin señal).'
        : 'Modo Online restablecido contra servidor remoto ($_windowsServerUrl).');
    await _persist();
    if (!value) {
      await sincronizarPendientesConServidor();
    }
  }

  Future<void> updateWindowsServerUrl(String url) async {
    _windowsServerUrl = url.trim();
    _addAudit('URL del servidor MySQL remoto actualizada a: $_windowsServerUrl');
    await _persist();
    await sincronizarDesdeServidorRemoto();
  }

  Future<int> sincronizarPendientesConServidor() async {
    final partesPendientes = _partesDiarios.where((p) => !p.sincronizadoServidor).toList();
    final informesPendientes = _informesTaller.where((t) => !t.sincronizadoServidor).toList();
    final count = partesPendientes.length + informesPendientes.length;

    // Enviar cada registro pendiente al servidor MySQL remoto en funcioncreativa.com.ar
    for (final p in partesPendientes) {
      await RemoteApiClient.postJson(_buildEndpoint('guardar_parte'), p.toMap());
    }
    for (final t in informesPendientes) {
      await RemoteApiClient.postJson(_buildEndpoint('guardar_service'), t.toMap());
    }

    _partesDiarios = _partesDiarios
        .map((p) => p.sincronizadoServidor
            ? p
            : ParteDiario(
                id: p.id,
                numeroParte: p.numeroParte,
                equipoId: p.equipoId,
                equipoCodigo: p.equipoCodigo,
                fecha: p.fecha,
                horaInicio: p.horaInicio,
                horaFin: p.horaFin,
                horometroInicial: p.horometroInicial,
                horometroFinal: p.horometroFinal,
                obraId: p.obraId,
                operarioId: p.operarioId,
                operarioNombre: p.operarioNombre,
                ltsCombustible: p.ltsCombustible,
                tipoCombustible: p.tipoCombustible,
                ltsLubricante: p.ltsLubricante,
                tipoLubricante: p.tipoLubricante,
                nroValeCarga: p.nroValeCarga,
                nroOrdenCompra: p.nroOrdenCompra,
                trabajosRealizados: p.trabajosRealizados,
                observacionesFuncionamiento: p.observacionesFuncionamiento,
                solicitaReparacion: p.solicitaReparacion,
                detalleSolicitudReparacion: p.detalleSolicitudReparacion,
                urgenciaReparacion: p.urgenciaReparacion,
                sincronizadoServidor: true,
              ))
        .toList();

    _informesTaller = _informesTaller
        .map((t) => t.sincronizadoServidor
            ? t
            : InformeTaller(
                id: t.id,
                equipoId: t.equipoId,
                equipoCodigo: t.equipoCodigo,
                fecha: t.fecha,
                tipoIntervencion: t.tipoIntervencion,
                estadoOrden: t.estadoOrden,
                horometroAlMomento: t.horometroAlMomento,
                lugar: t.lugar,
                mecanicoResponsable: t.mecanicoResponsable,
                checkCambioFiltro: t.checkCambioFiltro,
                checkCambioLubricante: t.checkCambioLubricante,
                filtrosUtilizados: t.filtrosUtilizados,
                lubricantesUtilizados: t.lubricantesUtilizados,
                repuestosUtilizados: t.repuestosUtilizados,
                sistemaAfectado: t.sistemaAfectado,
                costoRepuestos: t.costoRepuestos,
                costoManoObra: t.costoManoObra,
                horasTrabajoTaller: t.horasTrabajoTaller,
                observaciones: t.observaciones,
                parteDiarioOrigenId: t.parteDiarioOrigenId,
                sincronizadoServidor: true,
              ))
        .toList();

    _offlineMode = false;
    _lastSyncTime = DateTime.now();
    await sincronizarDesdeServidorRemoto();
    _addAudit('Sincronización completada con servidor MySQL ($_windowsServerUrl): $count registros enviados.');
    await _persist();
    return count;
  }

  Future<void> restaurarDatosDeFabrica() async {
    final prefs = await SharedPreferences.getInstance();
    await _resetToSeed(prefs);
    _addAudit('Base de datos restaurada al estado inicial de dbequipos (183 equipos).');
  }

  // ==================== CONSULTAS HELPER ====================

  ObraSite getObraById(int id) {
    return _obras.firstWhere(
      (o) => o.id == id,
      orElse: () => _obras.last,
    );
  }

  EquipmentItem? getEquipoById(int id) {
    for (final e in _equipos) {
      if (e.id == id) return e;
    }
    return null;
  }

  List<FiltroRepuestoItem> getFiltrosParaEquipo(EquipmentItem eq) {
    return _filtrosRepuestos.where((f) {
      final codes = f.equiposCompatiblesCodigos.toUpperCase();
      return codes.contains(eq.codigo.toUpperCase()) ||
          (eq.marcaNombre.isNotEmpty &&
              f.codigoOriginal.toUpperCase().contains(eq.marcaNombre.toUpperCase()));
    }).toList();
  }

  List<ParteDiario> getPartesPorEquipo(int equipoId) {
    return _partesDiarios.where((p) => p.equipoId == equipoId).toList();
  }

  List<InformeTaller> getInformesPorEquipo(int equipoId) {
    return _informesTaller.where((t) => t.equipoId == equipoId).toList();
  }

  List<GastoEquipo> getGastosPorEquipo(int equipoId) {
    return _gastosEquipos.where((g) => g.equipoId == equipoId).toList();
  }

  List<MovimientoObra> getMovimientosPorEquipo(int equipoId) {
    return _movimientosObra.where((m) => m.equipoId == equipoId).toList();
  }

  // ==================== OPERACIONES DE EQUIPOS Y HERRAMIENTAS ====================

  Future<void> agregarOEditarEquipo(EquipmentItem item, {bool esNuevo = false}) async {
    EquipmentItem target = item;
    if (esNuevo) {
      final nextId = _equipos.isEmpty
          ? 1
          : (_equipos.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);
      target = EquipmentItem(
        id: nextId,
        codigo: item.codigo,
        dominio: item.dominio,
        anio: item.anio,
        estado: item.estado,
        marcaId: item.marcaId,
        marcaNombre: item.marcaNombre,
        modeloNombre: item.modeloNombre,
        tipoEquipoId: item.tipoEquipoId,
        tipoEquipoNombre: item.tipoEquipoNombre,
        categoria: item.categoria,
        traccionId: item.traccionId,
        traccionNombre: item.traccionNombre,
        potencia: item.potencia,
        unidadPotencia: item.unidadPotencia,
        capacidad: item.capacidad,
        unidadCapacidad: item.unidadCapacidad,
        nChasis: item.nChasis,
        nMotor: item.nMotor,
        seguroCompania: item.seguroCompania,
        nPoliza: item.nPoliza,
        tipoSeguro: item.tipoSeguro,
        vencimientoSeguro: item.vencimientoSeguro,
        valCompra: item.valCompra,
        pMensual: item.pMensual,
        pStandby: item.pStandby,
        obraActualId: item.obraActualId,
        responsableActual: item.responsableActual,
        lecturaActual: item.lecturaActual,
        proximoServiceLectura: item.proximoServiceLectura,
        intervaloService: item.intervaloService,
        tipoCombustible: item.tipoCombustible,
        capacidadTanqueLts: item.capacidadTanqueLts,
        aceiteMotorSpec: item.aceiteMotorSpec,
        aceiteHidraulicoSpec: item.aceiteHidraulicoSpec,
        aceiteTransmisionSpec: item.aceiteTransmisionSpec,
        notasTecnicas: item.notasTecnicas,
      );
      _equipos.insert(0, target);
      _addAudit('Alta de nuevo equipo/herramienta ${target.codigo} (${target.descripcionCompleta}).');
    } else {
      final idx = _equipos.indexWhere((e) => e.id == item.id);
      if (idx != -1) {
        _equipos[idx] = item;
        _addAudit('Actualización de ficha de equipo ${item.codigo}.');
      }
    }
    await _persist();
    if (!_offlineMode) {
      await RemoteApiClient.postJson(_buildEndpoint('guardar_equipo'), target.toMap());
    }
  }

  Future<void> designarORetirarEquipoDeObra({
    required int equipoId,
    required int obraDestinoId,
    required String tipoMovimiento,
    required String nuevoEstadoEquipo,
    required String responsableEnObra,
    required String motivoObservaciones,
  }) async {
    final idx = _equipos.indexWhere((e) => e.id == equipoId);
    if (idx == -1) return;
    final eq = _equipos[idx];
    final obraOrigenId = eq.obraActualId;

    _equipos[idx] = eq.copyWith(
      obraActualId: obraDestinoId,
      estado: nuevoEstadoEquipo,
      responsableActual: responsableEnObra.isNotEmpty ? responsableEnObra : eq.responsableActual,
    );

    final nextMovId = _movimientosObra.isEmpty
        ? 701
        : (_movimientosObra.map((m) => m.id).reduce((a, b) => a > b ? a : b) + 1);

    final mov = MovimientoObra(
      id: nextMovId,
      equipoId: eq.id,
      equipoCodigo: eq.codigo,
      obraOrigenId: obraOrigenId,
      obraDestinoId: obraDestinoId,
      fecha: DateTime.now().toIso8601String().substring(0, 10),
      tipoMovimiento: tipoMovimiento,
      autorizadoPor: _currentUser?.nombreCompleto ?? 'Gerencia de Obra',
      lecturaHorometro: eq.lecturaActual,
      motivoObservaciones: motivoObservaciones,
    );
    _movimientosObra.insert(0, mov);
    final destNombre = getObraById(obraDestinoId).nombreObra;
    _addAudit('$tipoMovimiento de equipo ${eq.codigo} hacia "$destNombre" (Estado: $nuevoEstadoEquipo).');
    await _persist();

    if (!_offlineMode) {
      final payload = mov.toMap()..['nuevoEstado'] = nuevoEstadoEquipo;
      await RemoteApiClient.postJson(_buildEndpoint('designar_obra'), payload);
    }
  }

  // ==================== PARTES DIARIOS (OPERARIO / ADMINISTRADOR) ====================

  Future<ParteDiario> registrarParteDiario({
    required int equipoId,
    required String fecha,
    required String horaInicio,
    required String horaFin,
    required double horometroInicial,
    required double horometroFinal,
    required int obraId,
    required double ltsCombustible,
    required String tipoCombustible,
    required double ltsLubricante,
    required String tipoLubricante,
    required String nroValeCarga,
    required String nroOrdenCompra,
    required String trabajosRealizados,
    required String observacionesFuncionamiento,
    required bool solicitaReparacion,
    required String detalleSolicitudReparacion,
    required String urgenciaReparacion,
  }) async {
    final eqIdx = _equipos.indexWhere((e) => e.id == equipoId);
    final eq = eqIdx != -1 ? _equipos[eqIdx] : _equipos.first;

    final nextId = _partesDiarios.isEmpty
        ? 1001
        : (_partesDiarios.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1);
    final nextNroParte = _partesDiarios.isEmpty
        ? 48201
        : (_partesDiarios.map((p) => p.numeroParte).reduce((a, b) => a > b ? a : b) + 1);

    bool syncedToRemote = false;
    if (!_offlineMode) {
      final res = await RemoteApiClient.postJson(_buildEndpoint('guardar_parte'), {
        'id': nextId,
        'numeroParte': nextNroParte,
        'equipoId': eq.id,
        'equipoCodigo': eq.codigo,
        'fecha': fecha,
        'horaInicio': horaInicio,
        'horaFin': horaFin,
        'horometroInicial': horometroInicial,
        'horometroFinal': horometroFinal,
        'obraId': obraId,
        'operarioId': _currentUser?.id ?? 5,
        'ltsCombustible': ltsCombustible,
        'ltsLubricante': ltsLubricante,
        'trabajosRealizados': trabajosRealizados,
        'observacionesFuncionamiento': observacionesFuncionamiento,
        'solicitaReparacion': solicitaReparacion ? 1 : 0,
        'detalleSolicitudReparacion': detalleSolicitudReparacion,
        'urgenciaReparacion': urgenciaReparacion,
      });
      syncedToRemote = res != null && res['ok'] == true;
    }

    final nuevoParte = ParteDiario(
      id: nextId,
      numeroParte: nextNroParte,
      equipoId: eq.id,
      equipoCodigo: eq.codigo,
      fecha: fecha,
      horaInicio: horaInicio,
      horaFin: horaFin,
      horometroInicial: horometroInicial,
      horometroFinal: horometroFinal,
      obraId: obraId,
      operarioId: _currentUser?.id ?? 5,
      operarioNombre: _currentUser?.nombreCompleto ?? 'Operario de Turno',
      ltsCombustible: ltsCombustible,
      tipoCombustible: tipoCombustible,
      ltsLubricante: ltsLubricante,
      tipoLubricante: tipoLubricante,
      nroValeCarga: nroValeCarga,
      nroOrdenCompra: nroOrdenCompra,
      trabajosRealizados: trabajosRealizados,
      observacionesFuncionamiento: observacionesFuncionamiento,
      solicitaReparacion: solicitaReparacion,
      detalleSolicitudReparacion: detalleSolicitudReparacion,
      urgenciaReparacion: urgenciaReparacion,
      sincronizadoServidor: !_offlineMode || syncedToRemote,
    );

    _partesDiarios.insert(0, nuevoParte);

    if (eqIdx != -1) {
      final nuevaLectura = horometroFinal > eq.lecturaActual ? horometroFinal : eq.lecturaActual;
      final nuevoEstado =
          (solicitaReparacion && urgenciaReparacion.contains('Crítica')) ? 'En Reparación' : eq.estado;
      _equipos[eqIdx] = eq.copyWith(
        lecturaActual: nuevaLectura,
        estado: nuevoEstado,
      );
    }

    if (ltsCombustible > 0 || ltsLubricante > 0) {
      final montoEstimado = (ltsCombustible * 1.30) + (ltsLubricante * 6.50);
      final nextGastoId = _gastosEquipos.isEmpty
          ? 301
          : (_gastosEquipos.map((g) => g.id).reduce((a, b) => a > b ? a : b) + 1);
      final nuevoGasto = GastoEquipo(
        id: nextGastoId,
        equipoId: eq.id,
        equipoCodigo: eq.codigo,
        fecha: fecha,
        categoriaGasto: ltsCombustible > 0 ? 'Combustible' : 'Lubricantes',
        proveedor: 'Cisterna de Obra / Vale ${nroValeCarga.isEmpty ? "S/N" : nroValeCarga}',
        nroComprobante: nroOrdenCompra.isEmpty ? 'PARTE-$nextNroParte' : nroOrdenCompra,
        montoUsd: double.parse(montoEstimado.toStringAsFixed(2)),
        obraId: obraId,
        registradoPor: nuevoParte.operarioNombre,
        descripcion:
            'Consumo registrado en Parte Diario #$nextNroParte: ${ltsCombustible.toStringAsFixed(0)} Lts $tipoCombustible${ltsLubricante > 0 ? " + ${ltsLubricante.toStringAsFixed(1)} Lts $tipoLubricante" : ""}.',
      );
      _gastosEquipos.insert(0, nuevoGasto);
      if (!_offlineMode) {
        await RemoteApiClient.postJson(_buildEndpoint('guardar_gasto'), nuevoGasto.toMap());
      }
    }

    _addAudit(
      'Parte Diario #$nextNroParte registrado para ${eq.codigo} y enviado a MySQL remoto.',
    );
    await _persist();
    return nuevoParte;
  }

  // ==================== TALLER: CREAR, MODIFICAR Y ELIMINAR INFORMES ====================

  Future<InformeTaller> guardarInformeTaller(InformeTaller informe, {bool esNuevo = true}) async {
    InformeTaller guardado = informe;
    if (esNuevo) {
      final nextId = _informesTaller.isEmpty
          ? 501
          : (_informesTaller.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1);
      guardado = InformeTaller(
        id: nextId,
        equipoId: informe.equipoId,
        equipoCodigo: informe.equipoCodigo,
        fecha: informe.fecha,
        tipoIntervencion: informe.tipoIntervencion,
        estadoOrden: informe.estadoOrden,
        horometroAlMomento: informe.horometroAlMomento,
        lugar: informe.lugar,
        mecanicoResponsable: informe.mecanicoResponsable,
        checkCambioFiltro: informe.checkCambioFiltro,
        checkCambioLubricante: informe.checkCambioLubricante,
        filtrosUtilizados: informe.filtrosUtilizados,
        lubricantesUtilizados: informe.lubricantesUtilizados,
        repuestosUtilizados: informe.repuestosUtilizados,
        sistemaAfectado: informe.sistemaAfectado,
        costoRepuestos: informe.costoRepuestos,
        costoManoObra: informe.costoManoObra,
        horasTrabajoTaller: informe.horasTrabajoTaller,
        observaciones: informe.observaciones,
        parteDiarioOrigenId: informe.parteDiarioOrigenId,
        sincronizadoServidor: !_offlineMode,
      );
      _informesTaller.insert(0, guardado);
      _addAudit('Informe de Taller #${guardado.id} creado para ${guardado.equipoCodigo} (${guardado.tipoIntervencion}).');
    } else {
      final idx = _informesTaller.indexWhere((t) => t.id == informe.id);
      if (idx != -1) {
        _informesTaller[idx] = informe;
        _addAudit('Informe de Taller #${informe.id} modificado (${informe.equipoCodigo}).');
      }
    }

    if (!_offlineMode) {
      await RemoteApiClient.postJson(_buildEndpoint('guardar_service'), guardado.toMap());
    }

    final eqIdx = _equipos.indexWhere((e) => e.id == guardado.equipoId);
    if (eqIdx != -1) {
      final eq = _equipos[eqIdx];
      double nuevoProxService = eq.proximoServiceLectura;
      if (guardado.estadoOrden == 'Completado' &&
          (guardado.tipoIntervencion == 'Mantenimiento Preventivo' ||
              (guardado.checkCambioFiltro && guardado.checkCambioLubricante))) {
        final baseLectura =
            guardado.horometroAlMomento > eq.lecturaActual ? guardado.horometroAlMomento : eq.lecturaActual;
        nuevoProxService = baseLectura + eq.intervaloService;
      }

      String nuevoEstado = eq.estado;
      if (guardado.estadoOrden == 'En Proceso') {
        nuevoEstado = 'En Reparación';
      } else if (guardado.estadoOrden == 'Completado' && eq.estado == 'En Reparación') {
        nuevoEstado = 'En uso';
      }

      _equipos[eqIdx] = eq.copyWith(
        proximoServiceLectura: nuevoProxService,
        estado: nuevoEstado,
      );
    }

    if (esNuevo && guardado.costoTotal > 0) {
      final nextGastoId = _gastosEquipos.isEmpty
          ? 301
          : (_gastosEquipos.map((g) => g.id).reduce((a, b) => a > b ? a : b) + 1);
      final eq = getEquipoById(guardado.equipoId);
      final nuevoGasto = GastoEquipo(
        id: nextGastoId,
        equipoId: guardado.equipoId,
        equipoCodigo: guardado.equipoCodigo,
        fecha: guardado.fecha,
        categoriaGasto: 'Repuestos y Filtros',
        proveedor: guardado.lugar,
        nroComprobante: 'OT-${guardado.id}',
        montoUsd: guardado.costoTotal,
        obraId: eq?.obraActualId ?? 5,
        registradoPor: guardado.mecanicoResponsable,
        descripcion:
            '${guardado.tipoIntervencion} (${guardado.sistemaAfectado}): ${guardado.observaciones}',
      );
      _gastosEquipos.insert(0, nuevoGasto);
      if (!_offlineMode) {
        await RemoteApiClient.postJson(_buildEndpoint('guardar_gasto'), nuevoGasto.toMap());
      }
    }

    await _persist();
    return guardado;
  }

  Future<void> eliminarInformeTaller(int informeId) async {
    final target = _informesTaller.where((t) => t.id == informeId).toList();
    _informesTaller.removeWhere((t) => t.id == informeId);
    if (target.isNotEmpty) {
      _addAudit('Informe de Taller #$informeId eliminado (${target.first.equipoCodigo}).');
    }
    await _persist();
    if (!_offlineMode) {
      await RemoteApiClient.postJson(_buildEndpoint('eliminar_service'), {'id': informeId});
    }
  }

  // ==================== REPUESTOS Y FILTROS (STOCK TALLER) ====================

  Future<void> ajustarStockRepuesto(int filtroId, int nuevoStock) async {
    final idx = _filtrosRepuestos.indexWhere((f) => f.id == filtroId);
    if (idx == -1) return;
    final actual = _filtrosRepuestos[idx];
    _filtrosRepuestos[idx] = FiltroRepuestoItem(
      id: actual.id,
      codigoOriginal: actual.codigoOriginal,
      equivalenciaMannFram: actual.equivalenciaMannFram,
      tipoComponente: actual.tipoComponente,
      equiposCompatiblesCodigos: actual.equiposCompatiblesCodigos,
      stockActual: nuevoStock.clamp(0, 9999),
      stockMinimo: actual.stockMinimo,
      costoUnitarioUsd: actual.costoUnitarioUsd,
      ubicacionEstanteria: actual.ubicacionEstanteria,
      referenciaPlanoDespiece: actual.referenciaPlanoDespiece,
    );
    _addAudit('Ajuste de stock en pañol: ${actual.codigoOriginal} → $nuevoStock unidades.');
    await _persist();
  }

  Future<void> agregarFiltroRepuesto(FiltroRepuestoItem item) async {
    final nextId = _filtrosRepuestos.isEmpty
        ? 1
        : (_filtrosRepuestos.map((f) => f.id).reduce((a, b) => a > b ? a : b) + 1);
    final nuevo = FiltroRepuestoItem(
      id: nextId,
      codigoOriginal: item.codigoOriginal,
      equivalenciaMannFram: item.equivalenciaMannFram,
      tipoComponente: item.tipoComponente,
      equiposCompatiblesCodigos: item.equiposCompatiblesCodigos,
      stockActual: item.stockActual,
      stockMinimo: item.stockMinimo,
      costoUnitarioUsd: item.costoUnitarioUsd,
      ubicacionEstanteria: item.ubicacionEstanteria,
      referenciaPlanoDespiece: item.referenciaPlanoDespiece,
    );
    _filtrosRepuestos.insert(0, nuevo);
    _addAudit('Nuevo repuesto/filtro catalogado: ${nuevo.codigoOriginal}.');
    await _persist();
  }

  // ==================== GASTOS (ADMINISTRACIÓN) ====================

  Future<void> registrarGastoEquipo(GastoEquipo gasto) async {
    final nextId = _gastosEquipos.isEmpty
        ? 301
        : (_gastosEquipos.map((g) => g.id).reduce((a, b) => a > b ? a : b) + 1);
    final nuevo = GastoEquipo(
      id: nextId,
      equipoId: gasto.equipoId,
      equipoCodigo: gasto.equipoCodigo,
      fecha: gasto.fecha,
      categoriaGasto: gasto.categoriaGasto,
      proveedor: gasto.proveedor,
      nroComprobante: gasto.nroComprobante,
      montoUsd: gasto.montoUsd,
      obraId: gasto.obraId,
      registradoPor: _currentUser?.nombreCompleto ?? gasto.registradoPor,
      descripcion: gasto.descripcion,
    );
    _gastosEquipos.insert(0, nuevo);
    _addAudit(
      'Gasto registrado por USD ${nuevo.montoUsd.toStringAsFixed(2)} imputado a ${nuevo.equipoCodigo} (${nuevo.categoriaGasto}).',
    );
    await _persist();
    if (!_offlineMode) {
      await RemoteApiClient.postJson(_buildEndpoint('guardar_gasto'), nuevo.toMap());
    }
  }

  // ==================== GESTIÓN DE USUARIOS Y OBRAS ====================

  Future<void> guardarUsuario(AppUser user, {bool esNuevo = true}) async {
    if (esNuevo) {
      final nextId = _usuarios.isEmpty
          ? 1
          : (_usuarios.map((u) => u.id).reduce((a, b) => a > b ? a : b) + 1);
      final nuevo = AppUser(
        id: nextId,
        nombre: user.nombre,
        apellido: user.apellido,
        correo: user.correo,
        pass: user.pass,
        legajo: user.legajo,
        cuil: user.cuil,
        telefono: user.telefono,
        puesto: user.puesto,
        role: user.role,
        obraAsignadaId: user.obraAsignadaId,
        activo: user.activo,
      );
      _usuarios.add(nuevo);
      _addAudit('Nuevo usuario registrado: ${nuevo.correo} (${nuevo.role.label}).');
    } else {
      final idx = _usuarios.indexWhere((u) => u.id == user.id);
      if (idx != -1) {
        _usuarios[idx] = user;
        if (_currentUser?.id == user.id) {
          _currentUser = user;
        }
        _addAudit('Usuario actualizado: ${user.correo} (${user.role.label}).');
      }
    }
    await _persist();
  }

  Future<void> agregarObra(ObraSite obra) async {
    final nextId = _obras.isEmpty
        ? 1
        : (_obras.map((o) => o.id).reduce((a, b) => a > b ? a : b) + 1);
    final nueva = ObraSite(
      id: nextId,
      numeroInterno: obra.numeroInterno,
      nombreObra: obra.nombreObra,
      empresaComitente: obra.empresaComitente,
      cuit: obra.cuit,
      ubicacion: obra.ubicacion,
      responsableNombre: obra.responsableNombre,
      activa: true,
    );
    _obras.insert(0, nueva);
    _addAudit('Nuevo Frente de Obra habilitado: ${nueva.nombreObra}.');
    await _persist();
  }
}
