<?php
/* ============================================================================
 * ROL C - Login y Seguridad
 * sesion_actual.php : dice si hay un usuario logueado y quien es.
 * ----------------------------------------------------------------------------
 * Lo usan las paginas protegidas (paneles) para saber si dejar entrar y
 * que mostrar segun el rol. Devuelve { autenticado: bool, usuario: {...} }.
 * ========================================================================== */

require_once __DIR__ . '/auth.php';
jsonHeaders();

echo json_encode([
    'autenticado' => estaLogueado(),
    'usuario'     => usuarioActual(),
]);
