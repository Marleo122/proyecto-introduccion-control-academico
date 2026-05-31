<?php
/* ============================================================================
 * ROL C - Login y Seguridad
 * login.php : valida credenciales y abre la sesion del usuario.
 * ----------------------------------------------------------------------------
 * Recibe (POST JSON): { "usuario": "...", "password": "..." }
 * Devuelve JSON con el resultado y, si es exitoso, los datos del usuario.
 *
 * Seguridad aplicada:
 *  - Contrasenas verificadas con password_verify() contra el hash bcrypt
 *    guardado en la BD (nunca se compara texto plano).
 *  - Se registran los intentos (exitosos y fallidos) en la tabla intentoslogin.
 *  - Se actualiza ultimo_login al entrar.
 *  - Mensaje de error generico (no revela si fallo el usuario o la clave).
 * ========================================================================== */

require_once __DIR__ . '/auth.php';
jsonHeaders();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Metodo no permitido']);
    exit;
}

$entrada   = json_decode(file_get_contents('php://input'), true) ?? [];
$usuario   = trim($entrada['usuario'] ?? '');
$password  = $entrada['password'] ?? '';
$ip        = $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';

/* Validacion de campos vacios */
if ($usuario === '' || $password === '') {
    echo json_encode(['success' => false, 'error' => 'Usuario y contrasena son obligatorios']);
    exit;
}

$pdo = conectarBD();

/* Busca el usuario por nombre_usuario o por email, junto con su rol */
$sql = "SELECT u.id_usuario, u.nombre_usuario, u.nombre_completo, u.email,
               u.password_hash, u.activo, r.nombre_rol,
               u.id_estudiante, u.id_profesor
        FROM usuarios u
        JOIN roles r ON u.id_rol = r.id_rol
        WHERE u.nombre_usuario = :u OR u.email = :u
        LIMIT 1";
$stmt = $pdo->prepare($sql);
$stmt->execute([':u' => $usuario]);
$fila = $stmt->fetch();

/* Funcion interna para registrar el intento de login */
$registrarIntento = function ($exitoso) use ($pdo, $usuario, $ip) {
    $q = $pdo->prepare("INSERT INTO intentoslogin (nombre_usuario, ip_address, fue_exitoso)
                        VALUES (:u, :ip, :ok)");
    $q->execute([':u' => $usuario, ':ip' => $ip, ':ok' => $exitoso ? 'true' : 'false']);
};

/* PDO de PostgreSQL devuelve los BOOLEAN como 't'/'f' (texto): interpretarlo bien */
$estaActivo = $fila && in_array($fila['activo'], [true, 't', '1', 1], true);

/* Credenciales invalidas o usuario inactivo -> error generico */
if (!$fila || !$estaActivo || !password_verify($password, $fila['password_hash'])) {
    $registrarIntento(false);
    http_response_code(401);
    echo json_encode(['success' => false, 'error' => 'Usuario o contrasena incorrectos']);
    exit;
}

/* Login correcto: guarda el usuario en la sesion */
$_SESSION['usuario'] = [
    'id'             => (int) $fila['id_usuario'],
    'nombre_usuario' => $fila['nombre_usuario'],
    'nombre_completo'=> $fila['nombre_completo'],
    'email'          => $fila['email'],
    'rol'            => $fila['nombre_rol'],
    'id_estudiante'  => $fila['id_estudiante'] !== null ? (int) $fila['id_estudiante'] : null,
    'id_profesor'    => $fila['id_profesor']   !== null ? (int) $fila['id_profesor']   : null,
];

/* Actualiza ultimo_login y registra el intento exitoso */
$pdo->prepare("UPDATE usuarios SET ultimo_login = CURRENT_TIMESTAMP WHERE id_usuario = :id")
    ->execute([':id' => $fila['id_usuario']]);
$registrarIntento(true);

/* Panel destino segun el rol */
$paneles = [
    'admin'      => 'panel_admin.html',
    'profesor'   => 'panel_profesor.html',
    'estudiante' => 'panel_estudiante.html',
];

echo json_encode([
    'success' => true,
    'usuario' => $_SESSION['usuario'],
    'redirigir' => $paneles[$fila['nombre_rol']] ?? 'panel_estudiante.html',
]);
