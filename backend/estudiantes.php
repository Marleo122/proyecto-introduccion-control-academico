<?php
/* ============================================================================
 * API de Estudiantes  (base para el ROL D - Modulos CRUD)
 * ----------------------------------------------------------------------------
 * Acciones (via ?accion=):
 *   listar      (GET)    - lista estudiantes activos con su programa
 *   agregar     (POST)   - crea un estudiante              [solo admin]
 *   actualizar  (POST)   - edita un estudiante por id      [solo admin]
 *   eliminar    (DELETE) - baja logica (activo = false)    [solo admin]
 *
 * Conectado a la base unificada PlataformaEstudiantes mediante config.php.
 * El Rol D puede ampliar este archivo (validaciones, paginacion, etc.).
 * ========================================================================== */

require_once __DIR__ . '/auth.php';
jsonHeaders();

requerirLogin();                 // hay que estar logueado para todo
$pdo    = conectarBD();
$accion = $_GET['accion'] ?? '';

switch ($accion) {

    case 'listar':
        $sql = "SELECT e.id_estudiante, e.numero_identificacion, e.nombres, e.apellidos,
                       e.email_institucional, e.semestre_actual, e.id_programa,
                       p.nombre_programa
                FROM estudiantes e
                LEFT JOIN programas p ON e.id_programa = p.id_programa
                WHERE e.activo = true
                ORDER BY e.id_estudiante";
        echo json_encode($pdo->query($sql)->fetchAll());
        break;

    case 'agregar':
        requerirRol('admin');
        $d = json_decode(file_get_contents('php://input'), true) ?? [];
        $sql = "INSERT INTO estudiantes
                  (numero_identificacion, nombres, apellidos, email_institucional,
                   fecha_nacimiento, id_programa, semestre_actual)
                VALUES (:id, :nombres, :apellidos, :email, :fecha, :programa, :semestre)";
        try {
            $ok = $pdo->prepare($sql)->execute([
                ':id'       => $d['numero_identificacion'] ?? null,
                ':nombres'  => $d['nombres'] ?? null,
                ':apellidos'=> $d['apellidos'] ?? null,
                ':email'    => $d['email_institucional'] ?? null,
                ':fecha'    => $d['fecha_nacimiento'] ?? null,
                ':programa' => $d['id_programa'] ?? null,
                ':semestre' => $d['semestre_actual'] ?? null,
            ]);
            echo json_encode(['exito' => $ok]);
        } catch (PDOException $e) {
            echo json_encode(['exito' => false, 'error' => $e->getMessage()]);
        }
        break;

    case 'actualizar':
        requerirRol('admin');
        $d = json_decode(file_get_contents('php://input'), true) ?? [];
        $sql = "UPDATE estudiantes SET
                    nombres = :nombres,
                    apellidos = :apellidos,
                    email_institucional = :email,
                    id_programa = :programa,
                    semestre_actual = :semestre
                WHERE id_estudiante = :id";
        try {
            $ok = $pdo->prepare($sql)->execute([
                ':nombres'  => $d['nombres'] ?? null,
                ':apellidos'=> $d['apellidos'] ?? null,
                ':email'    => $d['email_institucional'] ?? null,
                ':programa' => $d['id_programa'] ?? null,
                ':semestre' => $d['semestre_actual'] ?? null,
                ':id'       => $d['id_estudiante'] ?? null,
            ]);
            echo json_encode(['exito' => $ok]);
        } catch (PDOException $e) {
            echo json_encode(['exito' => false, 'error' => $e->getMessage()]);
        }
        break;

    case 'eliminar':
        requerirRol('admin');
        $id  = $_GET['id'] ?? 0;
        $sql = "UPDATE estudiantes SET activo = false WHERE id_estudiante = :id";
        $ok  = $pdo->prepare($sql)->execute([':id' => $id]);
        echo json_encode(['exito' => $ok]);
        break;

    default:
        http_response_code(400);
        echo json_encode(['error' => 'Accion no valida']);
}
