<?php
/* ============================================================================
 * ROL C - Login y Seguridad
 * auth.php : helpers de autenticacion y control de roles.
 * ----------------------------------------------------------------------------
 * Incluye este archivo al inicio de cualquier endpoint que requiera que el
 * usuario haya iniciado sesion. Rol D y Rol E pueden reutilizar requerirRol()
 * para proteger sus modulos (ej: solo 'admin' puede usar el CRUD).
 * ========================================================================== */

require_once __DIR__ . '/../config/config.php';
iniciarSesion();

/* usuarioActual(): devuelve los datos del usuario logueado (o null). */
function usuarioActual() {
    return $_SESSION['usuario'] ?? null;
}

/* estaLogueado(): true si hay una sesion activa. */
function estaLogueado() {
    return isset($_SESSION['usuario']);
}

/* requerirLogin(): corta la ejecucion con 401 si no hay sesion. */
function requerirLogin() {
    if (!estaLogueado()) {
        jsonHeaders();
        http_response_code(401);
        echo json_encode(['success' => false, 'error' => 'Debes iniciar sesion']);
        exit;
    }
}

/* requerirRol(...$roles): corta con 403 si el rol del usuario no esta permitido.
   Uso: requerirRol('admin');  o  requerirRol('admin', 'profesor'); */
function requerirRol(...$roles) {
    requerirLogin();
    $u = usuarioActual();
    if (!in_array($u['rol'], $roles, true)) {
        jsonHeaders();
        http_response_code(403);
        echo json_encode(['success' => false, 'error' => 'No tienes permiso para esta accion']);
        exit;
    }
}
