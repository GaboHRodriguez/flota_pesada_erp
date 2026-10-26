<?php
/**
 * API REST REMOTA PARA FLOTA PESADA ERP (`dbequipos`)
 * Compatible con PHP 7.x / 8.4+ en https://funcioncreativa.com.ar/eqp/api.php
 * Lee automáticamente las credenciales desde `config_db.php`.
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

// Detectar conexión o variables definidas en config_db.php (soporta cualquier formato)
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
    // Devolver HTTP 200 con ok:false para que Apache no reemplace la respuesta JSON por su ErrorDocument HTML
    http_response_code(200);
    echo json_encode([
        'ok' => false,
        'error' => 'No se pudo conectar a MySQL: ' . ($mysqli ? $mysqli->connect_error : 'Credenciales no encontradas en config_db.php'),
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$mysqli->set_charset('utf8mb4');

// Asegurar tablas complementarias para que nunca falle una consulta
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

$action = $_GET['action'] ?? 'status';

function queryRows(mysqli $db, string $sql): array {
    $res = $db->query($sql);
    if (!$res) return [];
    $rows = [];
    while ($r = $res->fetch_assoc()) {
        $rows[] = $r;
    }
    return $rows;
}

if ($action === 'status') {
    $eqCount = (int)(queryRows($mysqli, "SELECT COUNT(*) AS c FROM equipos")[0]['c'] ?? 0);
    $marcasCount = (int)(queryRows($mysqli, "SELECT COUNT(*) AS c FROM marcas")[0]['c'] ?? 0);
    $partesCount = (int)(queryRows($mysqli, "SELECT COUNT(*) AS c FROM partediario")[0]['c'] ?? 0);
    $serviceCount = (int)(queryRows($mysqli, "SELECT COUNT(*) AS c FROM service")[0]['c'] ?? 0);
    $personalCount = (int)(queryRows($mysqli, "SELECT COUNT(*) AS c FROM personal")[0]['c'] ?? 0);
    $gastosCount = (int)(queryRows($mysqli, "SELECT COUNT(*) AS c FROM gastos_equipos")[0]['c'] ?? 0);

    echo json_encode([
        'ok' => true,
        'server' => 'Servidor Remoto MySQL Activo (funcioncreativa.com.ar)',
        'php_version' => PHP_VERSION,
        'counts' => [
            'equipos' => $eqCount,
            'marcas' => $marcasCount,
            'partediario' => $partesCount,
            'service' => $serviceCount,
            'personal' => $personalCount,
            'gastos_equipos' => $gastosCount,
        ],
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// Endpoint completo que descarga toda la base de datos en tiempo real hacia la App (Android y PC)
if ($action === 'bootstrap' && $_SERVER['REQUEST_METHOD'] === 'GET') {
    $equiposRaw = queryRows($mysqli, "
        SELECT e.*, m.marca AS marcaNombre, m.modelo AS modeloNombre, m.potencia, m.capacidad,
               m.tipoEquipo AS tipoEquipoId, m.traccion AS traccionId,
               t.tipo AS tipoEquipoNombre, tr.tipoTraccion AS traccionNombre
        FROM equipos e
        LEFT JOIN marcas m ON e.marca = m.id
        LEFT JOIN tipoequipos t ON m.tipoEquipo = t.id
        LEFT JOIN traccion tr ON m.traccion = tr.id
        ORDER BY e.id ASC
    ");

    $partesRaw = queryRows($mysqli, "SELECT * FROM partediario ORDER BY ID DESC LIMIT 200");
    $serviceRaw = queryRows($mysqli, "SELECT * FROM service ORDER BY id DESC LIMIT 200");
    $gastosRaw = queryRows($mysqli, "SELECT * FROM gastos_equipos ORDER BY id DESC LIMIT 200");
    $movimientosRaw = queryRows($mysqli, "SELECT * FROM movimientos_obra ORDER BY id DESC LIMIT 200");
    $personalRaw = queryRows($mysqli, "SELECT * FROM personal ORDER BY id ASC");

    echo json_encode([
        'ok' => true,
        'timestamp' => date('c'),
        'equipos' => $equiposRaw,
        'partesDiarios' => $partesRaw,
        'informesTaller' => $serviceRaw,
        'gastosEquipos' => $gastosRaw,
        'movimientosObra' => $movimientosRaw,
        'personal' => $personalRaw,
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$rawBody = file_get_contents('php://input');
$d = json_decode($rawBody ?: '{}', true) ?: [];

if ($action === 'guardar_parte' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $id = isset($d['id']) ? (int)$d['id'] : rand(2000, 999999);
    $equipo = isset($d['equipoId']) ? (int)$d['equipoId'] : 1;
    $fecha = $mysqli->real_escape_string($d['fecha'] ?? date('Y-m-d'));
    $hIni = isset($d['horometroInicial']) ? (int)$d['horometroInicial'] : 0;
    $hFin = isset($d['horometroFinal']) ? (int)$d['horometroFinal'] : 0;
    $ltsComb = isset($d['ltsCombustible']) ? (int)$d['ltsCombustible'] : 0;
    $ltsLub = isset($d['ltsLubricante']) ? (int)$d['ltsLubricante'] : 0;
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

    // Intentar primero con columnas extendidas y fallback al esquema clásico de partediario
    $q = "REPLACE INTO partediario
          (ID, equipo, fecha, horometroInicial, horometroFinal, ltsCombustible, ltsLubricante,
           nroOrdenCompra, nroValeCarga, numeroParte, Obra, Operario, tipoCombustible, tipoLubricante,
           trabajosRealizados, horaInicio, horaFin, observacionesFuncionamiento, solicitaReparacion,
           detalleSolicitudReparacion, urgenciaReparacion, sincronizadoServidor)
          VALUES
          ($id, $equipo, '$fecha', $hIni, $hFin, $ltsComb, $ltsLub, 320, 8850, $nroParte, $obra, $operario,
           1, 1, '$trabajos', '$horaIni', '$horaFin', '$obs', $solRep, '$detRep', '$urgRep', 1)";
    $ok = $mysqli->query($q);
    if (!$ok) {
        $qFallback = "REPLACE INTO partediario
          (ID, equipo, fecha, horometroInicial, horometroFinal, ltsCombustible, ltsLubricante,
           nroOrdenCompra, nroValeCarga, numeroParte, Obra, Operario, tipoCombustible, tipoLubricante, trabajosRealizados)
          VALUES
          ($id, $equipo, '$fecha', $hIni, $hFin, $ltsComb, $ltsLub, 320, 8850, $nroParte, $obra, $operario, 1, 1, '$trabajos')";
        $ok = $mysqli->query($qFallback);
    }
    echo json_encode(['ok' => (bool)$ok, 'error' => $mysqli->error], JSON_UNESCAPED_UNICODE);
    exit;
}

if ($action === 'guardar_service' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $id = isset($d['id']) ? (int)$d['id'] : rand(600, 999999);
    $equipo = isset($d['equipoId']) ? (int)$d['equipoId'] : 1;
    $fecha = $mysqli->real_escape_string($d['fecha'] ?? date('Y-m-d'));
    $horometro = isset($d['horometroAlMomento']) ? (int)$d['horometroAlMomento'] : 0;
    $lugar = $mysqli->real_escape_string($d['lugar'] ?? 'Taller Central');
    $obs = $mysqli->real_escape_string($d['observaciones'] ?? '');
    $chkFiltro = !empty($d['checkCambioFiltro']) ? 1 : 0;
    $chkLub = !empty($d['checkCambioLubricante']) ? 1 : 0;
    $tipoInt = $mysqli->real_escape_string($d['tipoIntervencion'] ?? 'Mantenimiento Preventivo');
    $estadoOrd = $mysqli->real_escape_string($d['estadoOrden'] ?? 'Completado');
    $mecanico = $mysqli->real_escape_string($d['mecanicoResponsable'] ?? 'Roberto Sanchez');
    $repuestos = $mysqli->real_escape_string($d['repuestosUtilizados'] ?? '');
    $sistema = $mysqli->real_escape_string($d['sistemaAfectado'] ?? 'Motor');
    $cRep = isset($d['costoRepuestos']) ? (float)$d['costoRepuestos'] : 0;
    $cMo = isset($d['costoManoObra']) ? (float)$d['costoManoObra'] : 0;
    $hs = isset($d['horasTrabajoTaller']) ? (float)$d['horasTrabajoTaller'] : 2;

    $q = "REPLACE INTO service
          (id, equipo, fecha, horometro, lugar, observaciones, checkCambioFiltro, checkCambioLub,
           filtro, parteLubricante, tipoIntervencion, estadoOrden, mecanicoResponsable,
           repuestosUtilizados, sistemaAfectado, costoRepuestos, costoManoObra, horasTrabajoTaller)
          VALUES
          ($id, $equipo, '$fecha', $horometro, '$lugar', '$obs', $chkFiltro, $chkLub,
           1, 1, '$tipoInt', '$estadoOrd', '$mecanico', '$repuestos', '$sistema', $cRep, $cMo, $hs)";
    $ok = $mysqli->query($q);
    if (!$ok) {
        $qFallback = "REPLACE INTO service
          (id, equipo, fecha, horometro, lugar, observaciones, checkCambioFiltro, checkCambioLub, filtro, parteLubricante)
          VALUES ($id, $equipo, '$fecha', $horometro, '$lugar', '$obs', $chkFiltro, $chkLub, 1, 1)";
        $ok = $mysqli->query($qFallback);
    }
    echo json_encode(['ok' => (bool)$ok, 'error' => $mysqli->error], JSON_UNESCAPED_UNICODE);
    exit;
}

if ($action === 'eliminar_service' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $id = isset($d['id']) ? (int)$d['id'] : 0;
    $ok = $mysqli->query("DELETE FROM service WHERE id = $id");
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
    $nuevoEstado = $mysqli->real_escape_string($d['nuevoEstado'] ?? 'En uso');

    $mysqli->query("UPDATE equipos SET estado = '$nuevoEstado' WHERE id = $equipoId");
    $q = "REPLACE INTO movimientos_obra
          (id, equipoId, equipoCodigo, obraOrigenId, obraDestinoId, fecha, tipoMovimiento, autorizadoPor, lecturaHorometro, motivoObservaciones)
          VALUES ($id, $equipoId, '$equipoCodigo', $orig, $dest, '$fecha', '$tipo', '$aut', $lec, '$mot')";
    $ok = $mysqli->query($q);
    echo json_encode(['ok' => (bool)$ok, 'error' => $mysqli->error], JSON_UNESCAPED_UNICODE);
    exit;
}

if ($action === 'guardar_equipo' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $id = isset($d['id']) ? (int)$d['id'] : rand(200, 999999);
    $anio = isset($d['anio']) ? (int)$d['anio'] : 2024;
    $codigo = $mysqli->real_escape_string($d['codigo'] ?? '');
    $dominio = $mysqli->real_escape_string($d['dominio'] ?? '');
    $estado = $mysqli->real_escape_string($d['estado'] ?? 'En uso');
    $marcaId = isset($d['marcaId']) ? (int)$d['marcaId'] : 10;
    $nchasis = $mysqli->real_escape_string($d['nChasis'] ?? '');
    $nmotor = $mysqli->real_escape_string($d['nMotor'] ?? '');
    $pmensual = isset($d['pMensual']) ? (float)$d['pMensual'] : 0;
    $pstandby = isset($d['pStandby']) ? (float)$d['pStandby'] : 0;
    $valCompra = isset($d['valCompra']) ? (float)$d['valCompra'] : 0;

    $q = "REPLACE INTO equipos
          (id, anio, codigo, dominio, estado, fechaCompra, marca, nchasis, nmotor, npoliza, origen, pmensual, pstandby, seguro, tseguro, valCompra, vencimiento)
          VALUES ($id, $anio, '$codigo', '$dominio', '$estado', '2024-01-01', $marcaId, '$nchasis', '$nmotor', '', 0, $pmensual, $pstandby, '', '', $valCompra, '2026-12-31')";
    $ok = $mysqli->query($q);
    echo json_encode(['ok' => (bool)$ok, 'error' => $mysqli->error], JSON_UNESCAPED_UNICODE);
    exit;
}

echo json_encode([
    'ok' => true,
    'message' => 'API MySQL Remota activa en funcioncreativa.com.ar/eqp/api.php',
], JSON_UNESCAPED_UNICODE);
