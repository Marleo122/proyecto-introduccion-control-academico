-- ============================================================================
-- PROYECTO FINAL - SISTEMA DE CONTROL ACADEMICO
-- Universidad Mariano Galvez de Guatemala
-- ----------------------------------------------------------------------------
-- ROL B - Especialista en SQL y Logica de Datos
-- Archivo: 04_vistas.sql
-- Base de datos: PlataformaEstudiantes (PostgreSQL 18)
-- ----------------------------------------------------------------------------
-- PARTE 3: Vistas (VIEWS)
-- Una vista es una consulta guardada con nombre. Permite reutilizar consultas
-- complejas escribiendo solo "SELECT * FROM nombre_vista".
-- ============================================================================


-- ----------------------------------------------------------------------------
-- VISTA 1: Promedios por estudiante
-- ----------------------------------------------------------------------------
-- Guarda el promedio de notas de cada estudiante junto a su programa.
-- Solo cuenta materias con nota (IS NOT NULL). Uso: SELECT * FROM vista_promedios;
CREATE VIEW vista_promedios AS
SELECT e.id_estudiante,
       e.nombres,
       e.apellidos,
       p.nombre_programa,
       ROUND(AVG(mat.nota_final), 2) AS promedio,
       COUNT(mat.nota_final) AS materias_con_nota
FROM matriculas mat
JOIN estudiantes e ON mat.id_estudiante = e.id_estudiante
JOIN programas p ON e.id_programa = p.id_programa
WHERE mat.nota_final IS NOT NULL
GROUP BY e.id_estudiante, e.nombres, e.apellidos, p.nombre_programa;


-- ----------------------------------------------------------------------------
-- VISTA 2: Historial academico
-- ----------------------------------------------------------------------------
-- Boletin completo: por cada matricula muestra estudiante, programa, materia,
-- creditos, periodo, nota y estado. Une cuatro tablas. Se puede filtrar por
-- estudiante con WHERE, igual que una tabla.
CREATE VIEW vista_historial_academico AS
SELECT e.id_estudiante,
       e.nombres,
       e.apellidos,
       p.nombre_programa,
       m.codigo_materia,
       m.nombre_materia,
       m.creditos,
       mat.periodo_academico,
       mat.nota_final,
       mat.estado_matricula
FROM matriculas mat
JOIN estudiantes e ON mat.id_estudiante = e.id_estudiante
JOIN materias m ON mat.id_materia = m.id_materia
JOIN programas p ON e.id_programa = p.id_programa;


-- ----------------------------------------------------------------------------
-- VISTA 3: Cursos por docente
-- ----------------------------------------------------------------------------
-- Horario de cada profesor: que materias imparte, de que programa y periodo.
-- Une cuatro tablas (asignaciones, profesores, materias, programas).
CREATE VIEW vista_cursos_por_docente AS
SELECT pr.id_profesor,
       pr.nombres,
       pr.apellidos,
       pr.especialidad,
       m.codigo_materia,
       m.nombre_materia,
       prog.nombre_programa,
       a.periodo_academico
FROM asignacionprofesormateria a
JOIN profesores pr ON a.id_profesor = pr.id_profesor
JOIN materias m ON a.id_materia = m.id_materia
JOIN programas prog ON m.id_programa = prog.id_programa;


-- ----------------------------------------------------------------------------
-- EJEMPLOS DE USO DE LAS VISTAS (no son obligatorios, solo para demostrar)
-- ----------------------------------------------------------------------------
-- Promedios ordenados de mayor a menor:
-- SELECT * FROM vista_promedios ORDER BY promedio DESC;
--
-- Historial de un estudiante especifico:
-- SELECT nombre_materia, periodo_academico, nota_final, estado_matricula
-- FROM vista_historial_academico WHERE nombres = 'Luis Alberto';
--
-- Cuantas materias imparte cada docente:
-- SELECT nombres, apellidos, COUNT(*) AS total_materias
-- FROM vista_cursos_por_docente GROUP BY nombres, apellidos ORDER BY total_materias DESC;
