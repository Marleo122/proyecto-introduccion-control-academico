<?php
/* ============================================================================
 * CONFIGURACION CENTRAL - SISTEMA DE CONTROL ACADEMICO
 * Universidad Mariano Galvez de Guatemala
 * ----------------------------------------------------------------------------
 * Un SOLO archivo de conexion para todo el proyecto (Rol C, D y E).
 * Si cambias la contrasena de PostgreSQL, cambiala UNICAMENTE aqui.
 *
 * Base de datos unificada: PlataformaEstudiantes (la misma del Rol A y B).
 * ========================================================================== */

/* ----- Datos de conexion a PostgreSQL ----- */
define('DB_HOST', 'localhost');
define('DB_PORT', '5432');
define('DB_NAME', 'PlataformaEstudiantes');
define('DB_USER', 'postgres');
define('DB_PASS', 'admin00');   // <-- pon aqui la clave de tu PostgreSQL

/* ----------------------------------------------------------------------------
 * conectarBD(): devuelve una conexion PDO a PostgreSQL.
 * Se usa en todos los endpoints del backend.
 * -------------------------------------------------------------------------- */
function conectarBD() {
    try {
        $pdo = new PDO(
            "pgsql:host=" . DB_HOST . ";port=" . DB_PORT . ";dbname=" . DB_NAME,
            DB_USER,
            DB_PASS
        );
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
        return $pdo;
    } catch (PDOException $e) {
        http_response_code(500);
        die(json_encode(['success' => false, 'error' => 'Error de conexion: ' . $e->getMessage()]));
    }
}

/* ----------------------------------------------------------------------------
 * iniciarSesion(): arranca la sesion PHP si aun no esta iniciada.
 * Centraliza el control de sesion para Rol C, D y E.
 * -------------------------------------------------------------------------- */
function iniciarSesion() {
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }
}

/* ----------------------------------------------------------------------------
 * jsonHeaders(): cabeceras estandar para respuestas JSON del backend.
 * -------------------------------------------------------------------------- */
function jsonHeaders() {
    header('Content-Type: application/json; charset=utf-8');
}
