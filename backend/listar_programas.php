<?php
/* ============================================================================
 * API de Programas Academicos  (consulta, base para ROL D / E)
 * ----------------------------------------------------------------------------
 * GET: devuelve los programas activos con su facultad.
 * Conectado a la base unificada PlataformaEstudiantes mediante config.php.
 * ========================================================================== */

require_once __DIR__ . '/auth.php';
jsonHeaders();

requerirLogin();
$pdo = conectarBD();

try {
    $sql = "SELECT p.id_programa, p.codigo_programa, p.nombre_programa,
                   p.duracion_semestres, f.nombre_facultad, f.codigo_facultad
            FROM programas p
            INNER JOIN facultades f ON p.id_facultad = f.id_facultad
            WHERE p.estado = true
            ORDER BY p.id_programa";
    $programas = $pdo->query($sql)->fetchAll();

    echo json_encode([
        'success' => true,
        'data'    => $programas,
        'total'   => count($programas),
    ]);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
