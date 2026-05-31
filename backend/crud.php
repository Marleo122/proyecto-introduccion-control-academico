<?php
/* ============================================================================
 * ROL D - Modulos CRUD
 * crud.php : API para gestion de Cursos (materias), Docentes (profesores)
 *            y Asignaciones (docente <-> curso).
 * ----------------------------------------------------------------------------
 * Acciones via ?tabla=&accion=
 *
 * tabla=cursos   accion= listar | agregar | actualizar | eliminar
 * tabla=docentes accion= listar | agregar | actualizar | eliminar
 * tabla=asignaciones accion= listar | agregar | eliminar
 * ========================================================================== */

require_once __DIR__ . '/auth.php';
jsonHeaders();
requerirLogin();

$pdo    = conectarBD();
$tabla  = $_GET['tabla']  ?? '';
$accion = $_GET['accion'] ?? '';

/* ======================================================================== */
/*  CURSOS (materias)                                                         */
/* ======================================================================== */
if ($tabla === 'cursos') {

    switch ($accion) {

        case 'listar':
            $sql = "SELECT m.id_materia, m.codigo_materia, m.nombre_materia,
                           m.creditos, m.horas_semanales, m.semestre_recomendado,
                           p.nombre_programa, m.id_programa
                    FROM materias m
                    JOIN programas p ON m.id_programa = p.id_programa
                    ORDER BY p.nombre_programa, m.semestre_recomendado, m.nombre_materia";
            echo json_encode($pdo->query($sql)->fetchAll());
            break;

        case 'agregar':
            requerirRol('admin');
            $d = json_decode(file_get_contents('php://input'), true) ?? [];
            $sql = "INSERT INTO materias
                      (codigo_materia, nombre_materia, creditos, horas_semanales, id_programa, semestre_recomendado)
                    VALUES (:codigo, :nombre, :creditos, :horas, :programa, :semestre)";
            try {
                $ok = $pdo->prepare($sql)->execute([
                    ':codigo'   => $d['codigo_materia'] ?? null,
                    ':nombre'   => $d['nombre_materia'] ?? null,
                    ':creditos' => $d['creditos'] ?? null,
                    ':horas'    => $d['horas_semanales'] ?? null,
                    ':programa' => $d['id_programa'] ?? null,
                    ':semestre' => $d['semestre_recomendado'] ?? null,
                ]);
                echo json_encode(['exito' => $ok]);
            } catch (PDOException $e) {
                echo json_encode(['exito' => false, 'error' => $e->getMessage()]);
            }
            break;

        case 'actualizar':
            requerirRol('admin');
            $d = json_decode(file_get_contents('php://input'), true) ?? [];
            $sql = "UPDATE materias SET
                        codigo_materia = :codigo,
                        nombre_materia = :nombre,
                        creditos = :creditos,
                        horas_semanales = :horas,
                        id_programa = :programa,
                        semestre_recomendado = :semestre
                    WHERE id_materia = :id";
            try {
                $ok = $pdo->prepare($sql)->execute([
                    ':codigo'   => $d['codigo_materia'] ?? null,
                    ':nombre'   => $d['nombre_materia'] ?? null,
                    ':creditos' => $d['creditos'] ?? null,
                    ':horas'    => $d['horas_semanales'] ?? null,
                    ':programa' => $d['id_programa'] ?? null,
                    ':semestre' => $d['semestre_recomendado'] ?? null,
                    ':id'       => $d['id_materia'] ?? null,
                ]);
                echo json_encode(['exito' => $ok]);
            } catch (PDOException $e) {
                echo json_encode(['exito' => false, 'error' => $e->getMessage()]);
            }
            break;

        case 'eliminar':
            requerirRol('admin');
            $id = $_GET['id'] ?? 0;
            // Validar que no tenga estudiantes inscritos activos
            $st = $pdo->prepare("SELECT COUNT(*) FROM matriculas
                                  WHERE id_materia = :id AND estado_matricula = 'Cursando'");
            $st->execute([':id' => $id]);
            if ($st->fetchColumn() > 0) {
                echo json_encode(['exito' => false,
                    'error' => 'No se puede eliminar: hay estudiantes cursando esta materia.']);
                break;
            }
            try {
                $ok = $pdo->prepare("DELETE FROM materias WHERE id_materia = :id")
                          ->execute([':id' => $id]);
                echo json_encode(['exito' => $ok]);
            } catch (PDOException $e) {
                echo json_encode(['exito' => false, 'error' => $e->getMessage()]);
            }
            break;

        default:
            http_response_code(400);
            echo json_encode(['error' => 'Accion no valida']);
    }

/* ======================================================================== */
/*  DOCENTES (profesores)                                                     */
/* ======================================================================== */
} elseif ($tabla === 'docentes') {

    switch ($accion) {

        case 'listar':
            $sql = "SELECT id_profesor, numero_identificacion, nombres, apellidos,
                           email_institucional, especialidad, fecha_contratacion, activo
                    FROM profesores
                    WHERE activo = true
                    ORDER BY apellidos, nombres";
            echo json_encode($pdo->query($sql)->fetchAll());
            break;

        case 'agregar':
            requerirRol('admin');
            $d = json_decode(file_get_contents('php://input'), true) ?? [];
            $sql = "INSERT INTO profesores
                      (numero_identificacion, nombres, apellidos, email_institucional, especialidad)
                    VALUES (:id, :nombres, :apellidos, :email, :especialidad)";
            try {
                $ok = $pdo->prepare($sql)->execute([
                    ':id'          => $d['numero_identificacion'] ?? null,
                    ':nombres'     => $d['nombres'] ?? null,
                    ':apellidos'   => $d['apellidos'] ?? null,
                    ':email'       => $d['email_institucional'] ?? null,
                    ':especialidad'=> $d['especialidad'] ?? null,
                ]);
                echo json_encode(['exito' => $ok]);
            } catch (PDOException $e) {
                echo json_encode(['exito' => false, 'error' => $e->getMessage()]);
            }
            break;

        case 'actualizar':
            requerirRol('admin');
            $d = json_decode(file_get_contents('php://input'), true) ?? [];
            $sql = "UPDATE profesores SET
                        nombres = :nombres,
                        apellidos = :apellidos,
                        email_institucional = :email,
                        especialidad = :especialidad
                    WHERE id_profesor = :id";
            try {
                $ok = $pdo->prepare($sql)->execute([
                    ':nombres'     => $d['nombres'] ?? null,
                    ':apellidos'   => $d['apellidos'] ?? null,
                    ':email'       => $d['email_institucional'] ?? null,
                    ':especialidad'=> $d['especialidad'] ?? null,
                    ':id'          => $d['id_profesor'] ?? null,
                ]);
                echo json_encode(['exito' => $ok]);
            } catch (PDOException $e) {
                echo json_encode(['exito' => false, 'error' => $e->getMessage()]);
            }
            break;

        case 'eliminar':
            requerirRol('admin');
            $id  = $_GET['id'] ?? 0;
            $sql = "UPDATE profesores SET activo = false WHERE id_profesor = :id";
            $ok  = $pdo->prepare($sql)->execute([':id' => $id]);
            echo json_encode(['exito' => $ok]);
            break;

        default:
            http_response_code(400);
            echo json_encode(['error' => 'Accion no valida']);
    }

/* ======================================================================== */
/*  ASIGNACIONES (docente <-> curso por periodo)                              */
/* ======================================================================== */
} elseif ($tabla === 'asignaciones') {

    switch ($accion) {

        case 'listar':
            $periodo = $_GET['periodo'] ?? '';
            $where   = $periodo ? "WHERE a.periodo_academico = :periodo" : '';
            $sql = "SELECT a.id_asignacion, a.periodo_academico,
                           pr.nombres || ' ' || pr.apellidos AS docente,
                           pr.id_profesor,
                           m.codigo_materia, m.nombre_materia, m.id_materia,
                           p.nombre_programa
                    FROM asignacionprofesormateria a
                    JOIN profesores pr ON a.id_profesor = pr.id_profesor
                    JOIN materias m ON a.id_materia = m.id_materia
                    JOIN programas p ON m.id_programa = p.id_programa
                    $where
                    ORDER BY a.periodo_academico DESC, pr.apellidos";
            $st = $pdo->prepare($sql);
            if ($periodo) $st->execute([':periodo' => $periodo]);
            else $st->execute();
            echo json_encode($st->fetchAll());
            break;

        case 'agregar':
            requerirRol('admin');
            $d = json_decode(file_get_contents('php://input'), true) ?? [];
            $sql = "INSERT INTO asignacionprofesormateria
                      (id_profesor, id_materia, periodo_academico)
                    VALUES (:profesor, :materia, :periodo)";
            try {
                $ok = $pdo->prepare($sql)->execute([
                    ':profesor' => $d['id_profesor'] ?? null,
                    ':materia'  => $d['id_materia']  ?? null,
                    ':periodo'  => $d['periodo_academico'] ?? null,
                ]);
                echo json_encode(['exito' => $ok]);
            } catch (PDOException $e) {
                echo json_encode(['exito' => false, 'error' => $e->getMessage()]);
            }
            break;

        case 'eliminar':
            requerirRol('admin');
            $id = $_GET['id'] ?? 0;
            $ok = $pdo->prepare("DELETE FROM asignacionprofesormateria WHERE id_asignacion = :id")
                      ->execute([':id' => $id]);
            echo json_encode(['exito' => $ok]);
            break;

        default:
            http_response_code(400);
            echo json_encode(['error' => 'Accion no valida']);
    }

} else {
    http_response_code(400);
    echo json_encode(['error' => 'Tabla no valida']);
}
