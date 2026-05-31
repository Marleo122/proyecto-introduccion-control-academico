<?php
/* ============================================================================
 * ROL E - Academico y Reportes
 * academico.php : backend para inscripcion, notas, historial, buscador.
 * ----------------------------------------------------------------------------
 * Acciones (via ?accion=):
 *   materias_disponibles  (GET)  - materias que el estudiante puede inscribir
 *   inscribir             (POST) - inscribe usando el procedimiento del Rol B
 *   historial             (GET)  - historial del estudiante logueado
 *   promedio              (GET)  - promedio y aprobadas del estudiante
 *   buscar                (GET)  - buscador con filtros combinables
 *   listar_matriculas     (GET)  - matriculas de un periodo (para ingreso notas)
 *   ingresar_nota         (POST) - el admin/profesor pone nota a una matricula
 *   reporte_promedios     (GET)  - datos para reporte: promedios por estudiante
 *   reporte_historial     (GET)  - datos para reporte: historial completo
 *   listar_programas_bd   (GET)  - programas para filtros del buscador
 * ========================================================================== */

require_once __DIR__ . '/auth.php';
jsonHeaders();
requerirLogin();

$pdo    = conectarBD();
$accion = $_GET['accion'] ?? '';
$u      = usuarioActual();

switch ($accion) {

    /* ------------------------------------------------------------------
     * Materias disponibles para inscribir (no inscritas en ese periodo)
     * ------------------------------------------------------------------ */
    case 'materias_disponibles':
        $periodo = $_GET['periodo'] ?? '2025-2';
        $id_est  = $u['id_estudiante'] ?? 0;

        if ($u['rol'] === 'estudiante') {
            $sql = "SELECT m.id_materia, m.codigo_materia, m.nombre_materia,
                           m.creditos, m.horas_semanales, m.semestre_recomendado,
                           p.nombre_programa
                    FROM materias m
                    JOIN programas p ON m.id_programa = p.id_programa
                    JOIN estudiantes e ON e.id_programa = m.id_programa
                    WHERE e.id_estudiante = :id
                      AND m.id_materia NOT IN (
                          SELECT id_materia FROM matriculas
                          WHERE id_estudiante = :id2
                            AND periodo_academico = :periodo
                            AND estado_matricula != 'Cancelada'
                      )
                    ORDER BY m.semestre_recomendado, m.nombre_materia";
            $st = $pdo->prepare($sql);
            $st->execute([':id' => $id_est, ':id2' => $id_est, ':periodo' => $periodo]);
        } else {
            // Admin ve todas
            $st = $pdo->query("SELECT m.id_materia, m.codigo_materia, m.nombre_materia,
                                      m.creditos, m.horas_semanales, m.semestre_recomendado,
                                      p.nombre_programa
                               FROM materias m
                               JOIN programas p ON m.id_programa = p.id_programa
                               ORDER BY p.nombre_programa, m.semestre_recomendado, m.nombre_materia");
        }
        echo json_encode($st->fetchAll());
        break;

    /* ------------------------------------------------------------------
     * Inscribir estudiante — llama al procedimiento almacenado del Rol B
     * ------------------------------------------------------------------ */
    case 'inscribir':
        if ($u['rol'] !== 'estudiante') {
            http_response_code(403);
            echo json_encode(['exito' => false, 'error' => 'Solo estudiantes pueden inscribirse']);
            exit;
        }
        $d       = json_decode(file_get_contents('php://input'), true) ?? [];
        $codigo  = $d['codigo_materia'] ?? '';
        $periodo = $d['periodo'] ?? '2025-2';

        $st = $pdo->prepare("SELECT numero_identificacion FROM estudiantes WHERE id_estudiante = :id");
        $st->execute([':id' => $u['id_estudiante']]);
        $est = $st->fetch();
        if (!$est) { echo json_encode(['exito' => false, 'error' => 'Estudiante no encontrado']); break; }

        $st = $pdo->prepare("SELECT inscribir_estudiante(:ident, :codigo, :periodo) AS resultado");
        $st->execute([':ident' => $est['numero_identificacion'], ':codigo' => $codigo, ':periodo' => $periodo]);
        $res = $st->fetch();
        $msg = $res['resultado'];

        echo json_encode(str_starts_with($msg, 'Error')
            ? ['exito' => false, 'error' => $msg]
            : ['exito' => true, 'mensaje' => $msg]);
        break;

    /* ------------------------------------------------------------------
     * Historial academico — usa la vista del Rol B
     * ------------------------------------------------------------------ */
    case 'historial':
        if ($u['rol'] === 'estudiante') {
            $sql = "SELECT codigo_materia, nombre_materia, creditos,
                           periodo_academico, nota_final, estado_matricula, nombre_programa
                    FROM vista_historial_academico
                    WHERE id_estudiante = :id
                    ORDER BY periodo_academico DESC, nombre_materia";
            $st = $pdo->prepare($sql);
            $st->execute([':id' => $u['id_estudiante']]);
        } else {
            $id  = $_GET['id_estudiante'] ?? 0;
            $sql = "SELECT nombres, apellidos, codigo_materia, nombre_materia, creditos,
                           periodo_academico, nota_final, estado_matricula, nombre_programa
                    FROM vista_historial_academico
                    WHERE id_estudiante = :id
                    ORDER BY periodo_academico DESC, nombre_materia";
            $st  = $pdo->prepare($sql);
            $st->execute([':id' => $id]);
        }
        echo json_encode($st->fetchAll());
        break;

    /* ------------------------------------------------------------------
     * Promedio y aprobadas — usa las funciones del Rol B
     * ------------------------------------------------------------------ */
    case 'promedio':
        if ($u['rol'] === 'estudiante') {
            $st = $pdo->prepare("SELECT numero_identificacion FROM estudiantes WHERE id_estudiante = :id");
            $st->execute([':id' => $u['id_estudiante']]);
            $est  = $st->fetch();
            $ident = $est['numero_identificacion'] ?? '';
        } else {
            $ident = $_GET['identificacion'] ?? '';
        }
        $st = $pdo->prepare("SELECT calcular_promedio(:a) AS promedio, contar_aprobadas(:b) AS aprobadas");
        $st->execute([':a' => $ident, ':b' => $ident]);
        echo json_encode($st->fetch());
        break;

    /* ------------------------------------------------------------------
     * Buscador con filtros combinables
     * ------------------------------------------------------------------ */
    case 'buscar':
        $where  = ['1=1'];
        $params = [];

        if (!empty($_GET['programa'])) {
            $where[] = 'p.id_programa = :programa';
            $params[':programa'] = $_GET['programa'];
        }
        if (!empty($_GET['semestre'])) {
            $where[] = 'm.semestre_recomendado = :semestre';
            $params[':semestre'] = (int)$_GET['semestre'];
        }
        if (!empty($_GET['materia'])) {
            $where[] = "(m.nombre_materia ILIKE :mat OR m.codigo_materia ILIKE :mat2)";
            $params[':mat']  = '%' . $_GET['materia'] . '%';
            $params[':mat2'] = '%' . $_GET['materia'] . '%';
        }
        if (isset($_GET['nota_min']) && $_GET['nota_min'] !== '') {
            $where[] = 'mat.nota_final >= :nota_min';
            $params[':nota_min'] = $_GET['nota_min'];
        }
        if (isset($_GET['nota_max']) && $_GET['nota_max'] !== '') {
            $where[] = 'mat.nota_final <= :nota_max';
            $params[':nota_max'] = $_GET['nota_max'];
        }
        if (!empty($_GET['docente'])) {
            $where[] = "(pr.nombres ILIKE :doc OR pr.apellidos ILIKE :doc2)";
            $params[':doc']  = '%' . $_GET['docente'] . '%';
            $params[':doc2'] = '%' . $_GET['docente'] . '%';
        }
        if (!empty($_GET['periodo'])) {
            $where[] = 'mat.periodo_academico = :periodo';
            $params[':periodo'] = $_GET['periodo'];
        }
        if (!empty($_GET['estado'])) {
            $where[] = 'mat.estado_matricula = :estado';
            $params[':estado'] = $_GET['estado'];
        }

        $sql = "SELECT e.nombres || ' ' || e.apellidos AS estudiante,
                       e.numero_identificacion,
                       m.codigo_materia, m.nombre_materia, m.creditos,
                       p.nombre_programa, m.semestre_recomendado,
                       mat.periodo_academico, mat.nota_final, mat.estado_matricula,
                       COALESCE(pr.nombres || ' ' || pr.apellidos, 'Sin asignar') AS docente
                FROM matriculas mat
                JOIN estudiantes e ON mat.id_estudiante = e.id_estudiante
                JOIN materias m ON mat.id_materia = m.id_materia
                JOIN programas p ON m.id_programa = p.id_programa
                LEFT JOIN asignacionprofesormateria a
                       ON a.id_materia = m.id_materia AND a.periodo_academico = mat.periodo_academico
                LEFT JOIN profesores pr ON a.id_profesor = pr.id_profesor
                WHERE " . implode(' AND ', $where) . "
                ORDER BY e.apellidos, m.nombre_materia
                LIMIT 300";

        $st = $pdo->prepare($sql);
        $st->execute($params);
        echo json_encode($st->fetchAll());
        break;

    /* ------------------------------------------------------------------
     * Listar matriculas de un periodo (para ingreso de notas)
     * ------------------------------------------------------------------ */
    case 'listar_matriculas':
        requerirRol('admin', 'profesor');
        $periodo = $_GET['periodo'] ?? '2025-2';
        $sql = "SELECT mat.id_matricula,
                       e.numero_identificacion,
                       e.nombres || ' ' || e.apellidos AS estudiante,
                       m.codigo_materia, m.nombre_materia,
                       mat.nota_final, mat.estado_matricula, mat.periodo_academico
                FROM matriculas mat
                JOIN estudiantes e ON mat.id_estudiante = e.id_estudiante
                JOIN materias m ON mat.id_materia = m.id_materia
                WHERE mat.periodo_academico = :periodo
                ORDER BY m.nombre_materia, e.apellidos";
        $st = $pdo->prepare($sql);
        $st->execute([':periodo' => $periodo]);
        echo json_encode($st->fetchAll());
        break;

    /* ------------------------------------------------------------------
     * Ingresar nota (0-5 segun la BD)
     * ------------------------------------------------------------------ */
    case 'ingresar_nota':
        requerirRol('admin', 'profesor');
        $d    = json_decode(file_get_contents('php://input'), true) ?? [];
        $id   = $d['id_matricula'] ?? null;
        $nota = $d['nota_final'] ?? null;

        if ($nota === null || (float)$nota < 0 || (float)$nota > 5) {
            echo json_encode(['exito' => false, 'error' => 'La nota debe estar entre 0 y 5']);
            break;
        }
        $estado = (float)$nota >= 3 ? 'Aprobada' : 'Reprobada';
        try {
            $ok = $pdo->prepare("UPDATE matriculas SET nota_final = :nota, estado_matricula = :estado
                                  WHERE id_matricula = :id")
                      ->execute([':nota' => $nota, ':estado' => $estado, ':id' => $id]);
            echo json_encode(['exito' => $ok, 'estado' => $estado]);
        } catch (PDOException $e) {
            echo json_encode(['exito' => false, 'error' => $e->getMessage()]);
        }
        break;

    /* ------------------------------------------------------------------
     * Reportes (datos JSON para exportar a CSV/imprimir)
     * ------------------------------------------------------------------ */
    case 'reporte_promedios':
        requerirRol('admin');
        $sql = "SELECT v.nombres, v.apellidos, v.nombre_programa,
                       v.promedio, v.materias_con_nota
                FROM vista_promedios v ORDER BY v.promedio DESC";
        echo json_encode($pdo->query($sql)->fetchAll());
        break;

    case 'reporte_historial':
        requerirRol('admin');
        $sql = "SELECT v.nombres || ' ' || v.apellidos AS estudiante,
                       v.nombre_programa, v.codigo_materia, v.nombre_materia,
                       v.creditos, v.periodo_academico, v.nota_final, v.estado_matricula
                FROM vista_historial_academico v
                ORDER BY v.nombres, v.periodo_academico";
        echo json_encode($pdo->query($sql)->fetchAll());
        break;

    /* Programas para filtros del buscador */
    case 'listar_programas_bd':
        $sql = "SELECT id_programa, nombre_programa FROM programas WHERE estado = true ORDER BY nombre_programa";
        echo json_encode($pdo->query($sql)->fetchAll());
        break;

    default:
        http_response_code(400);
        echo json_encode(['error' => 'Accion no valida']);
}
