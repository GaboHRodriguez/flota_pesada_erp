-- =================================================================================
-- SCRIPT DE ACTUALIZACIÓN Y MIGRACIÓN PARA WINDOWS SERVER (MySQL / MariaDB)
-- Base de datos original: `dbequipos`
-- Agrega soporte para los 5 Niveles de Usuario, Horarios Inicio/Fin en Parte Diario,
-- Solicitudes de Reparación, Gastos por Equipo, Movimientos de Obra y Despiece.
-- =================================================================================

CREATE DATABASE IF NOT EXISTS `dbequipos` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `dbequipos`;

-- 1. Cargar los 5 niveles de permisos requeridos en la tabla `permisos`
REPLACE INTO `permisos` (`id`, `categoria`, `valor`) VALUES
(1, 'Super Usuario (Sistemas y Acceso Total)', 1),
(2, 'Usuario Gerencia / Jefe de Obra (Informes, Costos y Asignación Obras)', 2),
(3, 'Usuario Administrador (Equipos, Gastos, Consumos y Partes)', 3),
(4, 'Usuario Taller (ABM Informes Mantenimiento, Reparaciones y Stock)', 4),
(5, 'Usuario Operario (Carga de Parte Diario y Solicitud Reparación)', 5);

-- 2. Usuarios iniciales para los 5 niveles en la tabla `personal`
REPLACE INTO `personal` (`id`, `nombre`, `apellido`, `correo`, `pass`, `legajo`, `cuil`, `areatelefono`, `telefono`, `cargo`, `puesto`, `permisos`, `usuario`) VALUES
(1, 'Martín', 'Rodríguez', 'super@constructora.com', 'Super2026!', 'LEG-001', 2024891023, 11, 45891001, 1, 'Administrador General de Sistemas TI', 1, 'mrodriguez'),
(2, 'Carlos', 'Méndez', 'gerencia@constructora.com', 'Gerencia2026!', 'LEG-005', 2021456789, 11, 45891002, 2, 'Gerente de Operaciones y Jefe de Obra', 2, 'cmendez'),
(3, 'Laura', 'Gómez', 'admin@constructora.com', 'Admin2026!', 'LEG-012', 2729345612, 11, 45891003, 3, 'Administración de Flota y Costos', 3, 'lgomez'),
(4, 'Roberto', 'Sánchez', 'taller@constructora.com', 'Taller2026!', 'LEG-024', 2026789123, 11, 45891004, 4, 'Jefe de Taller Mecánico Vial', 4, 'rsanchez'),
(5, 'Juan', 'Pérez', 'operario@constructora.com', 'Operario2026!', 'LEG-108', 2032456781, 11, 56782201, 5, 'Operador Maquinaria Pesada', 5, 'jperez');

-- 3. Ampliación de la tabla `partediario` para incluir Hora de Inicio/Fin, Observaciones y Solicitud de Reparación
ALTER TABLE `partediario`
  ADD COLUMN IF NOT EXISTS `horaInicio` VARCHAR(10) NOT NULL DEFAULT '07:30',
  ADD COLUMN IF NOT EXISTS `horaFin` VARCHAR(10) NOT NULL DEFAULT '17:00',
  ADD COLUMN IF NOT EXISTS `observacionesFuncionamiento` TEXT NULL,
  ADD COLUMN IF NOT EXISTS `solicitaReparacion` TINYINT(1) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS `detalleSolicitudReparacion` TEXT NULL,
  ADD COLUMN IF NOT EXISTS `urgenciaReparacion` VARCHAR(40) NOT NULL DEFAULT 'Normal',
  ADD COLUMN IF NOT EXISTS `sincronizadoServidor` TINYINT(1) NOT NULL DEFAULT 1;

-- 4. Ampliación de la tabla `service` (Informes de Taller y Reparaciones)
ALTER TABLE `service`
  ADD COLUMN IF NOT EXISTS `tipoIntervencion` VARCHAR(50) NOT NULL DEFAULT 'Mantenimiento Preventivo',
  ADD COLUMN IF NOT EXISTS `estadoOrden` VARCHAR(30) NOT NULL DEFAULT 'Completado',
  ADD COLUMN IF NOT EXISTS `mecanicoResponsable` VARCHAR(80) NOT NULL DEFAULT 'Taller Central',
  ADD COLUMN IF NOT EXISTS `repuestosUtilizados` TEXT NULL,
  ADD COLUMN IF NOT EXISTS `sistemaAfectado` VARCHAR(80) NOT NULL DEFAULT 'Motor e Hidráulica',
  ADD COLUMN IF NOT EXISTS `costoRepuestos` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  ADD COLUMN IF NOT EXISTS `costoManoObra` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  ADD COLUMN IF NOT EXISTS `horasTrabajoTaller` DECIMAL(8,2) NOT NULL DEFAULT 2.00,
  ADD COLUMN IF NOT EXISTS `parteDiarioOrigenId` INT(11) NULL;

-- 5. Nueva tabla `gastos_equipos` (Para Administración y Gerencia)
CREATE TABLE IF NOT EXISTS `gastos_equipos` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `equipoId` INT(11) NOT NULL,
  `equipoCodigo` VARCHAR(50) NOT NULL,
  `fecha` DATE NOT NULL,
  `categoriaGasto` VARCHAR(60) NOT NULL,
  `proveedor` VARCHAR(120) NOT NULL,
  `nroComprobante` VARCHAR(60) NOT NULL,
  `montoUsd` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `obraId` INT(11) NOT NULL,
  `registradoPor` VARCHAR(80) NOT NULL,
  `descripcion` TEXT NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. Nueva tabla `movimientos_obra` (Designación y Retiro de Equipos por Gerencia / Jefe de Obra)
CREATE TABLE IF NOT EXISTS `movimientos_obra` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `equipoId` INT(11) NOT NULL,
  `equipoCodigo` VARCHAR(50) NOT NULL,
  `obraOrigenId` INT(11) NOT NULL,
  `obraDestinoId` INT(11) NOT NULL,
  `fecha` DATE NOT NULL,
  `tipoMovimiento` VARCHAR(60) NOT NULL,
  `autorizadoPor` VARCHAR(80) NOT NULL,
  `lecturaHorometro` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `motivoObservaciones` TEXT NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
