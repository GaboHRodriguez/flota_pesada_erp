<?php
/**
 * CONFIGURACIÓN DE BASE DE DATOS MYSQL PARA SERVIDOR FTP / HOSTING / WINDOWS SERVER
 * Edita estos 5 valores con los datos que te da tu proveedor de Hosting (cPanel / Plesk / XAMPP)
 */

$DB_CONFIG = [
    'host'     => 'localhost',   // En el 99% de los hostings FTP es 'localhost' o '127.0.0.1'
    'user'     => 'root',        // Usuario MySQL de tu servidor de prueba (ej. 'u123456_admin')
    'pass'     => '',            // Contraseña del usuario MySQL en tu servidor de prueba
    'database' => 'dbequipos',   // Nombre de la base de datos en phpMyAdmin (ej. 'u123456_dbequipos')
    'port'     => 3306,          // En hosting FTP estándar es 3306 (en tu XAMPP local usa 3307)
];
