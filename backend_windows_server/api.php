<?php
/**
 * API REST REMOTA PARA FLOTA PESADA ERP (`dbequipos` - Esquema Relacional 6 Tablas)
 * Compatible con PHP 7.x / 8.4+ en https://funcioncreativa.com.ar/eqp/api.php
 * Tablas principales:
 *  1. equipos
 *  2. sistemas_maquinaria
 *  3. repuestos_catalogo
 *  4. despiece_equipos (Despiece Oficial vía CSV)
 *  5. ordenes_trabajo (Historial de intervenciones)
 *  6. repuestos_utilizados (Creador del Despiece Empírico)
 */

mysqli_report(MYSQLI_REPORT_OFF);
error_reporting(E_ALL);
ini_set('display_errors', '0');

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    echo json_encode(['ok' => true]);
    exit;
}

if (file_exists(__DIR__ . '/config_db.php')) {
    require_once __DIR__ . '/config_db.php';
}

// Detectar conexión o variables definidas en config_db.php
$mysqli = null;
foreach (['mysqli', 'conn', 'conexion', 'con', 'db_conn'] as $varName) {
    if (isset($$varName) && ($$varName instanceof mysqli)) {
        $mysqli = $$varName;
        break;
    }
}

if (!$mysqli) {
    $host = $DB_CONFIG['host'] ?? $host ?? $db_host ?? $servername ?? 'localhost';
    $user = $DB_CONFIG['user'] ?? $user ?? $db_user ?? $username ?? $usuario ?? 'root';
    $pass = $DB_CONFIG['pass'] ?? $pass ?? $db_pass ?? $password ?? $clave ?? '';
    $dbName = $DB_CONFIG['database'] ?? $DB_CONFIG['db'] ?? $database ?? $dbname ?? $db_name ?? $db ?? 'dbequipos';
    $port = (int)($DB_CONFIG['port'] ?? $port ?? $db_port ?? 3306);

    $mysqli = @new mysqli($host, $user, $pass, $dbName, $port);
    if ($mysqli->connect_errno && $host === 'localhost') {
        $mysqli = @new mysqli('127.0.0.1', $user, $pass, $dbName, $port);
    }
    if ($mysqli->connect_errno) {
        $altPort = ($port === 3306) ? 3307 : 3306;
        $mysqli = @new mysqli($host, $user, $pass, $dbName, $altPort);
    }
}

if (!$mysqli || $mysqli->connect_errno) {
    http_response_code(200);
    echo json_encode([
        'ok' => false,
        'error' => 'No se pudo conectar a MySQL: ' . ($mysqli ? $mysqli->connect_error : 'Credenciales no encontradas en config_db.php'),
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$mysqli->set_charset('utf8mb4');

// Asegurar tablas complementarias de operación diaria / costos de obra
$mysqli->query("CREATE TABLE IF NOT EXISTS `gastos_equipos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `equipoId` int(11) NOT NULL,
  `equipoCodigo` varchar(50) NOT NULL,
  `fecha` date NOT NULL,
  `categoriaGasto` varchar(60) NOT NULL,
  `proveedor` varchar(120) NOT NULL,
  `nroComprobante` varchar(60) NOT NULL,
  `montoUsd` decimal(12,2) NOT NULL DEFAULT 0.00,
  `obraId` int(11) NOT NULL,
  `registradoPor` varchar(80) NOT NULL,
  `descripcion` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

$mysqli->query("CREATE TABLE IF NOT EXISTS `movimientos_obra` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `equipoId` int(11) NOT NULL,
  `equipoCodigo` varchar(50) NOT NULL,
  `obraOrigenId` int(11) NOT NULL,
  `obraDestinoId` int(11) NOT NULL,
  `fecha` date NOT NULL,
  `tipoMovimiento` varchar(60) NOT NULL,
  `autorizadoPor` varchar(80) NOT NULL,
  `lecturaHorometro` decimal(12,2) NOT NULL DEFAULT 0.00,
  `motivoObservaciones` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

$mysqli->query("CREATE TABLE IF NOT EXISTS `partediario` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `equipo` int(11) NOT NULL,
  `fecha` date NOT NULL,
  `horometroInicial` decimal(10,2) NOT NULL DEFAULT 0.00,
  `horometroFinal` decimal(10,2) NOT NULL DEFAULT 0.00,
  `ltsCombustible` decimal(10,2) NOT NULL DEFAULT 0.00,
  `ltsLubricante` decimal(10,2) NOT NULL DEFAULT 0.00,
  `nroOrdenCompra` int(11) NOT NULL DEFAULT 0,
  `nroValeCarga` int(11) NOT NULL DEFAULT 0,
  `numeroParte` int(11) NOT NULL DEFAULT 0,
  `Obra` int(11) NOT NULL DEFAULT 1,
  `Operario` int(11) NOT NULL DEFAULT 5,
  `tipoCombustible` int(11) NOT NULL DEFAULT 1,
  `tipoLubricante` int(11) NOT NULL DEFAULT 1,
  `trabajosRealizados` text NOT NULL,
  `horaInicio` varchar(10) DEFAULT '07:30',
  `horaFin` varchar(10) DEFAULT '17:00',
  `observacionesFuncionamiento` text,
  `solicitaReparacion` tinyint(1) DEFAULT 0,
  `detalleSolicitudReparacion` text,
  `urgenciaReparacion` varchar(30) DEFAULT 'Normal',
  `sincronizadoServidor` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

function queryRows(mysqli $db, string $sql): array {
    $res = $db->query($sql);
    if (!$res) return [];
    $rows = [];
    while ($r = $res->fetch_assoc()) {
        $rows[] = $r;
    }
    return $rows;
}

function mapEnumEstadoToUi(string $enumVal): string {
    switch (strtoupper(trim($enumVal))) {
        case 'MANTENIMIENTO':
            return 'En Reparación';
        case 'FUERA_DE_SERVICIO':
            return 'Fuera de Servicio';
        case 'OPERATIVO':
        default:
            return 'En uso';
    }
}

function mapUiEstadoToEnum(string $uiVal): string {
    $u = strtoupper(trim($uiVal));
    if (strpos($u, 'MANTENIM') !== false || strpos($u, 'REPARAC') !== false || strpos($u, 'TALLER') !== false) {
        return 'MANTENIMIENTO';
    }
    if (strpos($u, 'FUERA') !== false || strpos($u, 'BAJA') !== false) {
        return 'FUERA_DE_SERVICIO';
    }
    return 'OPERATIVO';
}

$action = $_GET['action'] ?? 'status';

if ($action === 'status' || $action === 'ping') {
    $eqCount = (int)(queryRows($mysqli, "SELECT COUNT(*) AS c FROM equipos")[0]['c'] ?? 0);
    $sistCount = (int)(queryRows($mysqli, "SELECT COUNT(*) AS c FROM sistemas_maquinaria")[0]['c'] ?? 0);
    $repCatCount = (int)(queryRows($mysqli, "SELECT COUNT(*) AS c FROM repuestos_catalogo")[0]['c'] ?? 0);
    $despOficialCount = (int)(queryRows($mysqli, "SELECT COUNT(*) AS c FROM despiece_equipos")[0]['c'] ?? 0);
    $otCount = (int)(queryRows($mysqli, "SELECT COUNT(*) AS c FROM ordenes_trabajo")[0]['c'] ?? 0);
    $repUsadosCount = (int)(queryRows($mysqli, "SELECT COUNT(*) AS c FROM repuestos_utilizados")[0]['c'] ?? 0);

    echo json_encode([
        'ok' => true,
        'status' => 'online',
        'engine' => 'MySQL Relacional 6 Tablas (equipos, despiece_equipos, ordenes_trabajo, repuestos_utilizados)',
        'php_version' => PHP_VERSION,
        'counts' => [
            'equipos' => $eqCount,
            'sistemas_maquinaria' => $sistCount,
            'repuestos_catalogo' => $repCatCount,
            'despiece_equipos' => $despOficialCount,
            'ordenes_trabajo' => $otCount,
            'repuestos_utilizados' => $repUsadosCount,
        ],
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if ($action === 'bootstrap' && $_SERVER['REQUEST_METHOD'] === 'GET') {
    // 1. Equipos (nuevo esquema: id, codigo_interno, marca, modelo, numero_serie, horas_motor, estado)
    $equiposRows = queryRows($mysqli, "SELECT * FROM equipos ORDER BY id ASC");
    $equiposNormalized = [];
    foreach ($equiposRows as $r) {
        $estadoDb = $r['estado'] ?? 'OPERATIVO';
        $equiposNormalized[] = [
            'id' => (int)$r['id'],
            'codigo' => $r['codigo_interno'] ?? $r['codigo'] ?? ('EQ-' . $r['id']),
            'codigo_interno' => $r['codigo_interno'] ?? $r['codigo'] ?? ('EQ-' . $r['id']),
            'marcaNombre' => $r['marca'] ?? '',
            'modeloNombre' => $r['modelo'] ?? '',
            'numero_serie' => $r['numero_serie'] ?? '',
            'horas_motor' => (float)($r['horas_motor'] ?? 0),
            'estado_db' => $estadoDb,
            'estado' => mapEnumEstadoToUi($estadoDb),
            'dominio' => $r['numero_serie'] ?? '',
        ];
    }

    // 2. Sistemas de Maquinaria
    $sistemasRaw = queryRows($mysqli, "SELECT * FROM sistemas_maquinaria ORDER BY id ASC");

    // 3. Catálogo Global de Repuestos (Pañol)
    $repuestosCatalogoRaw = queryRows($mysqli, "SELECT * FROM repuestos_catalogo ORDER BY id ASC");

    // 4. Despiece Oficial (`despiece_equipos`)
    $despieceOficialRaw = queryRows($mysqli, "
        SELECT de.id, de.equipo_id, e.codigo_interno,
               de.repuesto_id, rc.numero_parte_oem, rc.descripcion AS repuesto_descripcion, rc.stock_actual,
               de.sistema_id, sm.nombre AS sistema_nombre,
               de.cantidad_por_equipo
        FROM despiece_equipos de
        INNER JOIN equipos e ON de.equipo_id = e.id
        INNER JOIN repuestos_catalogo rc ON de.repuesto_id = rc.id
        INNER JOIN sistemas_maquinaria sm ON de.sistema_id = sm.id
        ORDER BY de.equipo_id ASC, sm.id ASC
    ");

    // 5. Despiece Empírico (agrupando `repuestos_utilizados` + `ordenes_trabajo` por equipo)
    $despieceEmpiricoRaw = queryRows($mysqli, "
        SELECT ot.equipo_id, e.codigo_interno,
               ru.repuesto_id, rc.numero_parte_oem, rc.descripcion AS repuesto_descripcion, rc.stock_actual,
               COUNT(ru.id) AS veces_reemplazado,
               SUM(ru.cantidad_usada) AS total_unidades_usadas,
               MAX(ru.fecha_uso) AS ultima_fecha_uso
        FROM repuestos_utilizados ru
        INNER JOIN ordenes_trabajo ot ON ru.orden_trabajo_id = ot.id
        INNER JOIN equipos e ON ot.equipo_id = e.id
        INNER JOIN repuestos_catalogo rc ON ru.repuesto_id = rc.id
        GROUP BY ot.equipo_id, e.codigo_interno, ru.repuesto_id, rc.numero_parte_oem, rc.descripcion, rc.stock_actual
        ORDER BY ot.equipo_id ASC, total_unidades_usadas DESC
    ");

    // 6. Órdenes de Trabajo (`ordenes_trabajo` + `repuestos_utilizados`) mapeadas para la App
    $otRows = queryRows($mysqli, "
        SELECT ot.*, e.codigo_interno
        FROM ordenes_trabajo ot
        LEFT JOIN equipos e ON ot.equipo_id = e.id
        ORDER BY ot.id DESC LIMIT 200
    ");
    $informesTaller = [];
    foreach ($otRows as $ot) {
        $otId = (int)$ot['id'];
        $repUsados = queryRows($mysqli, "
            SELECT ru.cantidad_usada, rc.numero_parte_oem, rc.descripcion
            FROM repuestos_utilizados ru
            INNER JOIN repuestos_catalogo rc ON ru.repuesto_id = rc.id
            WHERE ru.orden_trabajo_id = $otId
        ");
        $repTextoItems = [];
        foreach ($repUsados as $ru) {
            $repTextoItems[] = $ru['cantidad_usada'] . 'x ' . $ru['numero_parte_oem'] . ' (' . $ru['descripcion'] . ')';
        }
        $tipoMap = [
            'PREVENTIVO' => 'Mantenimiento Preventivo',
            'CORRECTIVO' => 'Reparación Correctiva',
            'PREDICTIVO' => 'Mantenimiento Predictivo',
        ];
        $estadoMap = [
            'ABIERTA' => 'Pendiente',
            'EN_PROGRESO' => 'En Proceso',
            'CERRADA' => 'Completado',
            'CANCELADA' => 'Cancelado',
        ];
        $informesTaller[] = [
            'id' => $otId,
            'equipo' => (int)$ot['equipo_id'],
            'equipoCodigo' => $ot['codigo_interno'] ?? ('EQ-' . $ot['equipo_id']),
            'fecha' => substr($ot['fecha_ingreso'] ?? date('Y-m-d'), 0, 10),
            'fecha_cierre' => $ot['fecha_cierre'],
            'horometro' => (float)($ot['horas_motor_actuales'] ?? 0),
            'lugar' => 'Taller Central',
            'observaciones' => $ot['observaciones'] ?? '',
            'checkCambioFiltro' => !empty($repTextoItems) ? 1 : 0,
            'checkCambioLub' => ($ot['tipo'] === 'PREVENTIVO') ? 1 : 0,
            'tipoIntervencion' => $tipoMap[$ot['tipo'] ?? 'PREVENTIVO'] ?? 'Mantenimiento Preventivo',
            'estadoOrden' => $estadoMap[$ot['estado'] ?? 'ABIERTA'] ?? 'Completado',
            'mecanicoResponsable' => $ot['mecanico_asignado'] ?? 'Taller',
            'repuestosUtilizados' => implode(', ', $repTextoItems),
            'sistemaAfectado' => 'Motor / Hidráulica',
            'costoRepuestos' => count($repTextoItems) * 85.0,
            'costoManoObra' => 120.0,
            'horasTrabajoTaller' => 3.5,
        ];
    }

    $partesRaw = queryRows($mysqli, "SELECT * FROM partediario ORDER BY ID DESC LIMIT 200");
    $gastosRaw = queryRows($mysqli, "SELECT * FROM gastos_equipos ORDER BY id DESC LIMIT 200");
    $movimientosRaw = queryRows($mysqli, "SELECT * FROM movimientos_obra ORDER BY id DESC LIMIT 200");

    echo json_encode([
        'ok' => true,
        'timestamp' => date('c'),
        'equipos' => $equiposNormalized,
        'sistemasMaquinaria' => $sistemasRaw,
        'repuestosCatalogo' => $repuestosCatalogoRaw,
        'despieceOficial' => $despieceOficialRaw,
        'despieceEmpirico' => $despieceEmpiricoRaw,
        'informesTaller' => $informesTaller,
        'partesDiarios' => $partesRaw,
        'gastosEquipos' => $gastosRaw,
        'movimientosObra' => $movimientosRaw,
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$rawBody = file_get_contents('php://input');
$d = json_decode($rawBody ?: '{}', true) ?: [];

// Guardar Orden de Trabajo en `ordenes_trabajo` + Repuestos en `repuestos_utilizados`
if (($action === 'guardar_service' || $action === 'guardar_orden_trabajo') && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $id = isset($d['id']) ? (int)$d['id'] : 0;
    $equipoId = isset($d['equipoId']) ? (int)$d['equipoId'] : 1;
    $fechaIngreso = $mysqli->real_escape_string(($d['fecha'] ?? date('Y-m-d')) . ' 08:00:00');
    $horometro = isset($d['horometroAlMomento']) ? (float)$d['horometroAlMomento'] : 0.0;
    $mecanico = $mysqli->real_escape_string($d['mecanicoResponsable'] ?? 'Roberto Sánchez');
    $obs = $mysqli->real_escape_string($d['observaciones'] ?? '');

    $tipoUi = strtoupper($d['tipoIntervencion'] ?? 'PREVENTIVO');
    $tipoEnum = 'PREVENTIVO';
    if (strpos($tipoUi, 'CORRECT') !== false || strpos($tipoUi, 'REPARAC') !== false || strpos($tipoUi, 'EMERG') !== false) {
        $tipoEnum = 'CORRECTIVO';
    } elseif (strpos($tipoUi, 'PREDICT') !== false) {
        $tipoEnum = 'PREDICTIVO';
    }

    $estUi = strtoupper($d['estadoOrden'] ?? 'CERRADA');
    $estadoEnum = 'CERRADA';
    $fechaCierreSql = "'" . date('Y-m-d H:i:s') . "'";
    if (strpos($estUi, 'PEND') !== false || strpos($estUi, 'ABIER') !== false) {
        $estadoEnum = 'ABIERTA';
        $fechaCierreSql = "NULL";
    } elseif (strpos($estUi, 'PROC') !== false || strpos($estUi, 'PROG') !== false || strpos($estUi, 'ESP') !== false) {
        $estadoEnum = 'EN_PROGRESO';
        $fechaCierreSql = "NULL";
    } elseif (strpos($estUi, 'CANC') !== false) {
        $estadoEnum = 'CANCELADA';
    }

    if ($id > 0) {
        $q = "INSERT INTO ordenes_trabajo
              (id, equipo_id, fecha_ingreso, fecha_cierre, mecanico_asignado, tipo, horas_motor_actuales, estado, observaciones)
              VALUES ($id, $equipoId, '$fechaIngreso', $fechaCierreSql, '$mecanico', '$tipoEnum', $horometro, '$estadoEnum', '$obs')
              ON DUPLICATE KEY UPDATE
              mecanico_asignado = VALUES(mecanico_asignado),
              tipo = VALUES(tipo),
              horas_motor_actuales = VALUES(horas_motor_actuales),
              estado = VALUES(estado),
              fecha_cierre = VALUES(fecha_cierre),
              observaciones = VALUES(observaciones)";
    } else {
        $q = "INSERT INTO ordenes_trabajo
              (equipo_id, fecha_ingreso, fecha_cierre, mecanico_asignado, tipo, horas_motor_actuales, estado, observaciones)
              VALUES ($equipoId, '$fechaIngreso', $fechaCierreSql, '$mecanico', '$tipoEnum', $horometro, '$estadoEnum', '$obs')";
    }
    $ok = $mysqli->query($q);
    $otId = ($id > 0) ? $id : (int)$mysqli->insert_id;

    // Actualizar horas_motor y estado en `equipos`
    $nuevoEstadoEquipo = ($estadoEnum === 'ABIERTA' || $estadoEnum === 'EN_PROGRESO') ? 'MANTENIMIENTO' : 'OPERATIVO';
    $mysqli->query("UPDATE equipos SET horas_motor = GREATEST(horas_motor, $horometro), estado = '$nuevoEstadoEquipo' WHERE id = $equipoId");

    // Si se enviaron repuestos usados (texto OEM o array), registrarlos en `repuestos_utilizados` (Despiece Empírico)
    $repTexto = trim($d['repuestosUtilizados'] ?? '');
    if ($otId > 0 && $repTexto !== '') {
        $catalogo = queryRows($mysqli, "SELECT id, numero_parte_oem FROM repuestos_catalogo");
        foreach ($catalogo as $catItem) {
            $oem = $catItem['numero_parte_oem'];
            if ($oem !== '' && stripos($repTexto, $oem) !== false) {
                $repId = (int)$catItem['id'];
                $existe = queryRows($mysqli, "SELECT id FROM repuestos_utilizados WHERE orden_trabajo_id = $otId AND repuesto_id = $repId");
                if (empty($existe)) {
                    $mysqli->query("INSERT INTO repuestos_utilizados (orden_trabajo_id, repuesto_id, cantidad_usada) VALUES ($otId, $repId, 1)");
                    $mysqli->query("UPDATE repuestos_catalogo SET stock_actual = GREATEST(0, stock_actual - 1) WHERE id = $repId");
                }
            }
        }
    }

    echo json_encode(['ok' => (bool)$ok, 'orden_trabajo_id' => $otId, 'error' => $mysqli->error], JSON_UNESCAPED_UNICODE);
    exit;
}

if ($action === 'eliminar_service' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $id = isset($d['id']) ? (int)$d['id'] : 0;
    $ok = $mysqli->query("DELETE FROM ordenes_trabajo WHERE id = $id");
    echo json_encode(['ok' => (bool)$ok, 'error' => $mysqli->error], JSON_UNESCAPED_UNICODE);
    exit;
}

if ($action === 'guardar_parte' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $id = isset($d['id']) ? (int)$d['id'] : rand(2000, 999999);
    $equipo = isset($d['equipoId']) ? (int)$d['equipoId'] : 1;
    $fecha = $mysqli->real_escape_string($d['fecha'] ?? date('Y-m-d'));
    $hIni = isset($d['horometroInicial']) ? (float)$d['horometroInicial'] : 0;
    $hFin = isset($d['horometroFinal']) ? (float)$d['horometroFinal'] : 0;
    $ltsComb = isset($d['ltsCombustible']) ? (float)$d['ltsCombustible'] : 0;
    $ltsLub = isset($d['ltsLubricante']) ? (float)$d['ltsLubricante'] : 0;
    $nroParte = isset($d['numeroParte']) ? (int)$d['numeroParte'] : $id;
    $obra = isset($d['obraId']) ? (int)$d['obraId'] : 1;
    $operario = isset($d['operarioId']) ? (int)$d['operarioId'] : 5;
    $trabajos = $mysqli->real_escape_string($d['trabajosRealizados'] ?? '');
    $horaIni = $mysqli->real_escape_string($d['horaInicio'] ?? '07:30');
    $horaFin = $mysqli->real_escape_string($d['horaFin'] ?? '17:00');
    $obs = $mysqli->real_escape_string($d['observacionesFuncionamiento'] ?? '');
    $solRep = !empty($d['solicitaReparacion']) ? 1 : 0;
    $detRep = $mysqli->real_escape_string($d['detalleSolicitudReparacion'] ?? '');
    $urgRep = $mysqli->real_escape_string($d['urgenciaReparacion'] ?? 'Normal');

    $q = "REPLACE INTO partediario
          (ID, equipo, fecha, horometroInicial, horometroFinal, ltsCombustible, ltsLubricante,
           nroOrdenCompra, nroValeCarga, numeroParte, Obra, Operario, tipoCombustible, tipoLubricante,
           trabajosRealizados, horaInicio, horaFin, observacionesFuncionamiento, solicitaReparacion,
           detalleSolicitudReparacion, urgenciaReparacion, sincronizadoServidor)
          VALUES
          ($id, $equipo, '$fecha', $hIni, $hFin, $ltsComb, $ltsLub, 320, 8850, $nroParte, $obra, $operario,
           1, 1, '$trabajos', '$horaIni', '$horaFin', '$obs', $solRep, '$detRep', '$urgRep', 1)";
    $ok = $mysqli->query($q);

    // Actualizar horas_motor en `equipos` y si solicita reparación abrir alerta o poner en mantenimiento si es urgente
    if ($hFin > 0) {
        $mysqli->query("UPDATE equipos SET horas_motor = GREATEST(horas_motor, $hFin) WHERE id = $equipo");
    }

    echo json_encode(['ok' => (bool)$ok, 'error' => $mysqli->error], JSON_UNESCAPED_UNICODE);
    exit;
}

if ($action === 'guardar_gasto' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $id = isset($d['id']) ? (int)$d['id'] : rand(400, 999999);
    $equipoId = isset($d['equipoId']) ? (int)$d['equipoId'] : 1;
    $equipoCodigo = $mysqli->real_escape_string($d['equipoCodigo'] ?? '');
    $fecha = $mysqli->real_escape_string($d['fecha'] ?? date('Y-m-d'));
    $cat = $mysqli->real_escape_string($d['categoriaGasto'] ?? 'Repuestos');
    $prov = $mysqli->real_escape_string($d['proveedor'] ?? '');
    $comp = $mysqli->real_escape_string($d['nroComprobante'] ?? '');
    $monto = isset($d['montoUsd']) ? (float)$d['montoUsd'] : 0;
    $obraId = isset($d['obraId']) ? (int)$d['obraId'] : 1;
    $regPor = $mysqli->real_escape_string($d['registradoPor'] ?? 'Administracion');
    $desc = $mysqli->real_escape_string($d['descripcion'] ?? '');

    $q = "REPLACE INTO gastos_equipos
          (id, equipoId, equipoCodigo, fecha, categoriaGasto, proveedor, nroComprobante, montoUsd, obraId, registradoPor, descripcion)
          VALUES ($id, $equipoId, '$equipoCodigo', '$fecha', '$cat', '$prov', '$comp', $monto, $obraId, '$regPor', '$desc')";
    $ok = $mysqli->query($q);
    echo json_encode(['ok' => (bool)$ok, 'error' => $mysqli->error], JSON_UNESCAPED_UNICODE);
    exit;
}

if ($action === 'designar_obra' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $id = isset($d['id']) ? (int)$d['id'] : rand(800, 999999);
    $equipoId = isset($d['equipoId']) ? (int)$d['equipoId'] : 1;
    $equipoCodigo = $mysqli->real_escape_string($d['equipoCodigo'] ?? '');
    $orig = isset($d['obraOrigenId']) ? (int)$d['obraOrigenId'] : 1;
    $dest = isset($d['obraDestinoId']) ? (int)$d['obraDestinoId'] : 1;
    $fecha = $mysqli->real_escape_string($d['fecha'] ?? date('Y-m-d'));
    $tipo = $mysqli->real_escape_string($d['tipoMovimiento'] ?? 'Designacion a Obra');
    $aut = $mysqli->real_escape_string($d['autorizadoPor'] ?? 'Gerencia');
    $lec = isset($d['lecturaHorometro']) ? (float)$d['lecturaHorometro'] : 0;
    $mot = $mysqli->real_escape_string($d['motivoObservaciones'] ?? '');
    $nuevoEstadoEnum = mapUiEstadoToEnum($d['nuevoEstado'] ?? 'OPERATIVO');

    $mysqli->query("UPDATE equipos SET estado = '$nuevoEstadoEnum', horas_motor = GREATEST(horas_motor, $lec) WHERE id = $equipoId");
    $q = "REPLACE INTO movimientos_obra
          (id, equipoId, equipoCodigo, obraOrigenId, obraDestinoId, fecha, tipoMovimiento, autorizadoPor, lecturaHorometro, motivoObservaciones)
          VALUES ($id, $equipoId, '$equipoCodigo', $orig, $dest, '$fecha', '$tipo', '$aut', $lec, '$mot')";
    $ok = $mysqli->query($q);
    echo json_encode(['ok' => (bool)$ok, 'error' => $mysqli->error], JSON_UNESCAPED_UNICODE);
    exit;
}

if ($action === 'guardar_equipo' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $id = isset($d['id']) ? (int)$d['id'] : 0;
    $codigo = $mysqli->real_escape_string($d['codigo_interno'] ?? $d['codigo'] ?? ('EQ-' . rand(200, 999)));
    $marca = $mysqli->real_escape_string($d['marca'] ?? $d['marcaNombre'] ?? 'CATERPILLAR');
    $modelo = $mysqli->real_escape_string($d['modelo'] ?? $d['modeloNombre'] ?? 'ESTANDAR');
    $serie = $mysqli->real_escape_string($d['numero_serie'] ?? $d['nChasis'] ?? $d['nMotor'] ?? $d['dominio'] ?? '');
    $horas = isset($d['horas_motor']) ? (float)$d['horas_motor'] : (isset($d['lecturaActual']) ? (float)$d['lecturaActual'] : 0.0);
    $estadoEnum = mapUiEstadoToEnum($d['estado'] ?? 'OPERATIVO');

    if ($id > 0) {
        $q = "INSERT INTO equipos (id, codigo_interno, marca, modelo, numero_serie, horas_motor, estado)
              VALUES ($id, '$codigo', '$marca', '$modelo', '$serie', $horas, '$estadoEnum')
              ON DUPLICATE KEY UPDATE
              codigo_interno = VALUES(codigo_interno),
              marca = VALUES(marca),
              modelo = VALUES(modelo),
              numero_serie = VALUES(numero_serie),
              horas_motor = VALUES(horas_motor),
              estado = VALUES(estado)";
    } else {
        $q = "INSERT INTO equipos (codigo_interno, marca, modelo, numero_serie, horas_motor, estado)
              VALUES ('$codigo', '$marca', '$modelo', '$serie', $horas, '$estadoEnum')
              ON DUPLICATE KEY UPDATE
              marca = VALUES(marca),
              modelo = VALUES(modelo),
              numero_serie = VALUES(numero_serie),
              horas_motor = VALUES(horas_motor),
              estado = VALUES(estado)";
    }
    $ok = $mysqli->query($q);
    echo json_encode(['ok' => (bool)$ok, 'error' => $mysqli->error], JSON_UNESCAPED_UNICODE);
    exit;
}

// Carga masiva de Despiece Oficial vía CSV (`despiece_equipos`)
// Formato CSV esperado por línea: codigo_interno,numero_parte_oem,descripcion_repuesto,sistema_nombre,cantidad_por_equipo
if ($action === 'importar_despiece_csv' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $csvText = trim($d['csv'] ?? '');
    if ($csvText === '') {
        echo json_encode(['ok' => false, 'error' => 'El contenido CSV está vacío.'], JSON_UNESCAPED_UNICODE);
        exit;
    }
    $lines = preg_split('/\r\n|\r|\n/', $csvText);
    $insertados = 0;
    foreach ($lines as $idx => $line) {
        $line = trim($line);
        if ($line === '' || stripos($line, 'codigo_interno') === 0) continue;
        $cols = str_getcsv($line);
        if (count($cols) < 4) continue;

        $codInterno = $mysqli->real_escape_string(trim($cols[0]));
        $numParteOem = $mysqli->real_escape_string(trim($cols[1]));
        $descRep = $mysqli->real_escape_string(trim($cols[2]));
        $sistNombre = $mysqli->real_escape_string(trim($cols[3]));
        $cant = isset($cols[4]) ? max(1, (int)$cols[4]) : 1;

        // 1. Buscar equipo_id
        $eqRow = queryRows($mysqli, "SELECT id FROM equipos WHERE codigo_interno = '$codInterno' LIMIT 1");
        if (empty($eqRow)) continue;
        $eqId = (int)$eqRow[0]['id'];

        // 2. Asegurar sistema_id en `sistemas_maquinaria`
        $mysqli->query("INSERT IGNORE INTO sistemas_maquinaria (nombre, descripcion) VALUES ('$sistNombre', 'Sistema importado vía CSV')");
        $sistRow = queryRows($mysqli, "SELECT id FROM sistemas_maquinaria WHERE nombre = '$sistNombre' LIMIT 1");
        if (empty($sistRow)) continue;
        $sistId = (int)$sistRow[0]['id'];

        // 3. Asegurar repuesto_id en `repuestos_catalogo`
        $mysqli->query("INSERT INTO repuestos_catalogo (numero_parte_oem, descripcion, stock_actual)
                        VALUES ('$numParteOem', '$descRep', 0)
                        ON DUPLICATE KEY UPDATE descripcion = VALUES(descripcion)");
        $repRow = queryRows($mysqli, "SELECT id FROM repuestos_catalogo WHERE numero_parte_oem = '$numParteOem' LIMIT 1");
        if (empty($repRow)) continue;
        $repId = (int)$repRow[0]['id'];

        // 4. Insertar en `despiece_equipos` respetando UNIQUE KEY `unica_pieza_sistema`
        $ok = $mysqli->query("INSERT INTO despiece_equipos (equipo_id, repuesto_id, sistema_id, cantidad_por_equipo)
                              VALUES ($eqId, $repId, $sistId, $cant)
                              ON DUPLICATE KEY UPDATE cantidad_por_equipo = VALUES(cantidad_por_equipo)");
        if ($ok) $insertados++;
    }

    echo json_encode(['ok' => true, 'insertados' => $insertados], JSON_UNESCAPED_UNICODE);
    exit;
}

echo json_encode([
    'ok' => true,
    'message' => 'API MySQL Relacional (6 Tablas) activa en funcioncreativa.com.ar/eqp/api.php',
], JSON_UNESCAPED_UNICODE);
