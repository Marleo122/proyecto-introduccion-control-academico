<?php
/* ============================================================================
 * ROL C - Login y Seguridad
 * logout.php : cierra la sesion del usuario actual.
 * ========================================================================== */

require_once __DIR__ . '/auth.php';
jsonHeaders();

$_SESSION = [];
if (session_status() === PHP_SESSION_ACTIVE) {
    session_destroy();
}

echo json_encode(['success' => true, 'mensaje' => 'Sesion cerrada']);
