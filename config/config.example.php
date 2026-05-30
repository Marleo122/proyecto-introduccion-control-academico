<?php
/* ============================================================================
 * PLANTILLA DE CONFIGURACION  (config.example.php)
 * ----------------------------------------------------------------------------
 * Copia este archivo y renombralo a  config.php  (en la misma carpeta config/).
 * Luego cambia DB_PASS por la contrasena de TU PostgreSQL.
 *
 * El archivo real config.php NO se sube a GitHub (esta en .gitignore) para no
 * exponer la contrasena. Cada integrante crea el suyo a partir de esta plantilla.
 * ========================================================================== */

/* ----- Datos de conexion a PostgreSQL ----- */
define('DB_HOST', 'localhost');
define('DB_PORT', '5432');
define('DB_NAME', 'PlataformaEstudiantes');
define('DB_USER', 'postgres');
define('DB_PASS', 'PON_AQUI_TU_CONTRASENA');   // <-- la clave de tu PostgreSQL

/* ----------------------------------------------------------------------------
 * conectarBD(): devuelve una conexion PDO a PostgreSQL.
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

/* iniciarSesion(): arranca la sesion PHP si aun no esta iniciada. */
function iniciarSesion() {
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }
}

/* jsonHeaders(): cabeceras estandar para respuestas JSON del backend. */
function jsonHeaders() {
    header('Content-Type: application/json; charset=utf-8');
}
