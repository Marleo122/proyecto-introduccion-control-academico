-- ============================================================================
-- PROYECTO FINAL - SISTEMA DE CONTROL ACADEMICO
-- Universidad Mariano Galvez de Guatemala
-- Ingenieria en Sistemas - Introduccion a los Sistemas de Computo
-- ----------------------------------------------------------------------------
-- ROL B - Especialista en SQL y Logica de Datos
-- Archivo: consultas.sql
-- Base de datos: PlataformaEstudiantes (PostgreSQL 18)
-- ============================================================================
-- Este archivo contiene:
--   PARTE 1: Datos de prueba (insertados por separado en datos.sql)
--   PARTE 2: 15 consultas SQL variadas (WHERE, JOIN, GROUP BY, HAVING,
--            ORDER BY, subconsultas)
--   PARTE 3: Vistas (VIEWS)
--   PARTE 4: Procedimientos almacenados
--   PARTE 5: Trigger
-- ============================================================================


-- ############################################################################
-- PARTE 2 - CONSULTAS SQL
-- ############################################################################

-- ----------------------------------------------------------------------------
-- CONSULTA 1: Estudiantes en semestre avanzado (uso de WHERE y ORDER BY)
-- ----------------------------------------------------------------------------
-- Muestra los estudiantes que van en un semestre mayor a 3, ordenados del
-- semestre mas alto al mas bajo. WHERE filtra las filas que cumplen la
-- condicion; ORDER BY ... DESC ordena de mayor a menor.
SELECT nombres, apellidos, semestre_actual
FROM estudiantes
WHERE semestre_actual > 3
ORDER BY semestre_actual DESC;


-- ----------------------------------------------------------------------------
-- CONSULTA 2: Profesores por area de especialidad (WHERE con LIKE)
-- ----------------------------------------------------------------------------
-- Busca los profesores cuya especialidad empieza con la palabra "Derecho".
-- El operador LIKE permite buscar coincidencias parciales de texto; el
-- comodin % significa "cualquier texto despues".
SELECT nombres, apellidos, especialidad
FROM profesores
WHERE especialidad LIKE 'Derecho%'
ORDER BY apellidos;


-- ----------------------------------------------------------------------------
-- CONSULTA 3: Materias por rango de creditos (WHERE con BETWEEN)
-- ----------------------------------------------------------------------------
-- Lista las materias cuyos creditos estan entre 4 y 5 (ambos incluidos).
-- BETWEEN ... AND ... filtra por un rango de valores. El ORDER BY ordena
-- primero por creditos (mayor a menor) y desempata por nombre de materia.
SELECT codigo_materia, nombre_materia, creditos
FROM materias
WHERE creditos BETWEEN 4 AND 5
ORDER BY creditos DESC, nombre_materia;


-- ----------------------------------------------------------------------------
-- CONSULTA 4: Estudiantes con su programa (JOIN de dos tablas)
-- ----------------------------------------------------------------------------
-- Muestra cada estudiante junto al nombre de su programa academico. La tabla
-- estudiantes solo guarda el id_programa (un numero); el JOIN une esa tabla
-- con programas para mostrar el nombre real. Las letras e y p son alias.
SELECT e.nombres, e.apellidos, e.semestre_actual, p.nombre_programa
FROM estudiantes e
JOIN programas p ON e.id_programa = p.id_programa
ORDER BY p.nombre_programa, e.apellidos;


-- ----------------------------------------------------------------------------
-- CONSULTA 5: Notas con nombres reales (JOIN de TRES tablas)
-- ----------------------------------------------------------------------------
-- Convierte la tabla matriculas (que solo tiene numeros) en informacion
-- legible: nombre del estudiante, nombre de la materia, nota y estado. Se
-- encadenan dos JOIN: matriculas con estudiantes y matriculas con materias.
SELECT e.nombres, e.apellidos, m.nombre_materia, mat.nota_final, mat.estado_matricula
FROM matriculas mat
JOIN estudiantes e ON mat.id_estudiante = e.id_estudiante
JOIN materias m ON mat.id_materia = m.id_materia
ORDER BY e.apellidos, m.nombre_materia;


-- ----------------------------------------------------------------------------
-- CONSULTA 6: Promedio de notas por estudiante (GROUP BY + AVG + ROUND)
-- ----------------------------------------------------------------------------
-- Calcula el promedio de notas de cada estudiante, contando solo las materias
-- que ya tienen nota (IS NOT NULL deja fuera las que estan en curso).
-- AVG promedia, ROUND redondea a 2 decimales, GROUP BY agrupa por estudiante
-- para que el promedio se calcule por persona y no de todos juntos.
SELECT e.nombres, e.apellidos,
       ROUND(AVG(mat.nota_final), 2) AS promedio,
       COUNT(mat.nota_final) AS materias_con_nota
FROM matriculas mat
JOIN estudiantes e ON mat.id_estudiante = e.id_estudiante
WHERE mat.nota_final IS NOT NULL
GROUP BY e.id_estudiante, e.nombres, e.apellidos
ORDER BY promedio DESC;


-- ----------------------------------------------------------------------------
-- CONSULTA 7: Total de estudiantes por programa (GROUP BY + COUNT)
-- ----------------------------------------------------------------------------
-- Cuenta cuantos estudiantes hay inscritos en cada programa academico.
-- COUNT cuenta filas y GROUP BY las agrupa por programa.
SELECT p.nombre_programa, COUNT(e.id_estudiante) AS total_estudiantes
FROM estudiantes e
JOIN programas p ON e.id_programa = p.id_programa
GROUP BY p.nombre_programa
ORDER BY total_estudiantes DESC;


-- ----------------------------------------------------------------------------
-- CONSULTA 8: Estudiantes de buen rendimiento (HAVING sobre un promedio)
-- ----------------------------------------------------------------------------
-- Muestra solo los estudiantes cuyo promedio es mayor o igual a 4.0.
-- IMPORTANTE: el filtro del promedio va en HAVING y no en WHERE, porque el
-- promedio (AVG) se calcula DESPUES de agrupar. Regla: WHERE filtra filas,
-- HAVING filtra grupos. Aqui se usan ambos: WHERE quita las notas NULL y
-- HAVING quita los estudiantes con promedio bajo.
SELECT e.nombres, e.apellidos,
       ROUND(AVG(mat.nota_final), 2) AS promedio
FROM matriculas mat
JOIN estudiantes e ON mat.id_estudiante = e.id_estudiante
WHERE mat.nota_final IS NOT NULL
GROUP BY e.id_estudiante, e.nombres, e.apellidos
HAVING AVG(mat.nota_final) >= 4.0
ORDER BY promedio DESC;


-- ----------------------------------------------------------------------------
-- CONSULTA 9: Materias con 2 o mas inscritos (HAVING con COUNT)
-- ----------------------------------------------------------------------------
-- Lista las materias que tienen al menos 2 estudiantes matriculados.
-- El HAVING filtra los grupos (materias) segun el resultado del COUNT.
SELECT m.nombre_materia, COUNT(mat.id_matricula) AS total_inscritos
FROM matriculas mat
JOIN materias m ON mat.id_materia = m.id_materia
GROUP BY m.id_materia, m.nombre_materia
HAVING COUNT(mat.id_matricula) >= 2
ORDER BY total_inscritos DESC;


-- ----------------------------------------------------------------------------
-- CONSULTA 10: Estudiantes por encima del promedio general (SUBCONSULTA)
-- ----------------------------------------------------------------------------
-- Muestra los estudiantes cuyo promedio supera el promedio general de toda la
-- universidad. La subconsulta entre parentesis calcula ese promedio general
-- (un solo numero) y la consulta principal compara contra el. La gran ventaja
-- es que no hay que saber el promedio de antemano: SQL lo calcula solo.
SELECT e.nombres, e.apellidos,
       ROUND(AVG(mat.nota_final), 2) AS promedio
FROM matriculas mat
JOIN estudiantes e ON mat.id_estudiante = e.id_estudiante
WHERE mat.nota_final IS NOT NULL
GROUP BY e.id_estudiante, e.nombres, e.apellidos
HAVING AVG(mat.nota_final) > (SELECT AVG(nota_final) FROM matriculas WHERE nota_final IS NOT NULL)
ORDER BY promedio DESC;


-- ----------------------------------------------------------------------------
-- CONSULTA 11: Estudiantes con alguna materia reprobada (SUBCONSULTA con IN)
-- ----------------------------------------------------------------------------
-- Lista los estudiantes que han reprobado al menos una materia. La subconsulta
-- devuelve la lista de ids de estudiantes con estado 'Reprobada', y el
-- operador IN trae solo los estudiantes que estan en esa lista.
SELECT nombres, apellidos, numero_identificacion
FROM estudiantes
WHERE id_estudiante IN (
    SELECT id_estudiante
    FROM matriculas
    WHERE estado_matricula = 'Reprobada'
)
ORDER BY apellidos;


-- ----------------------------------------------------------------------------
-- CONSULTA 12: Asignaciones de profesores (JOIN de CUATRO tablas)
-- ----------------------------------------------------------------------------
-- Muestra que profesor imparte que materia, de que programa y en que periodo.
-- Encadena cuatro tablas: asignacionprofesormateria con profesores, con
-- materias y con programas, siguiendo las relaciones (claves foraneas).
SELECT pr.nombres, pr.apellidos, m.nombre_materia, prog.nombre_programa, a.periodo_academico
FROM asignacionprofesormateria a
JOIN profesores pr ON a.id_profesor = pr.id_profesor
JOIN materias m ON a.id_materia = m.id_materia
JOIN programas prog ON m.id_programa = prog.id_programa
ORDER BY pr.apellidos, m.nombre_materia;


-- ----------------------------------------------------------------------------
-- CONSULTA 13: Inscritos por materia, incluyendo las vacias (LEFT JOIN)
-- ----------------------------------------------------------------------------
-- Cuenta los inscritos de cada materia, mostrando TODAS las materias aunque
-- no tengan inscritos. Un JOIN normal omitiria las materias sin matriculas;
-- el LEFT JOIN las conserva y muestra 0. Util para detectar materias vacias.
SELECT m.nombre_materia, COUNT(mat.id_matricula) AS total_inscritos
FROM materias m
LEFT JOIN matriculas mat ON m.id_materia = mat.id_materia
GROUP BY m.id_materia, m.nombre_materia
ORDER BY total_inscritos ASC, m.nombre_materia;


-- ----------------------------------------------------------------------------
-- CONSULTA 14: Edad de los estudiantes (funciones de fecha)
-- ----------------------------------------------------------------------------
-- Calcula la edad de cada estudiante a partir de su fecha de nacimiento.
-- AGE() calcula el tiempo transcurrido hasta hoy; DATE_PART('year', ...)
-- extrae solo los anios como numero entero.
SELECT nombres, apellidos, fecha_nacimiento,
       DATE_PART('year', AGE(fecha_nacimiento)) AS edad
FROM estudiantes
ORDER BY edad DESC;


-- ----------------------------------------------------------------------------
-- CONSULTA 15: Reporte resumen por programa (consulta integral)
-- ----------------------------------------------------------------------------
-- Por cada programa muestra: total de estudiantes, total de materias y el
-- promedio general de notas. Combina varias tecnicas: LEFT JOIN (incluye
-- programas aunque falten datos), COUNT(DISTINCT ...) para contar sin repetir,
-- AVG + ROUND para el promedio y GROUP BY para agrupar por programa.
SELECT prog.nombre_programa,
       COUNT(DISTINCT e.id_estudiante) AS total_estudiantes,
       COUNT(DISTINCT m.id_materia) AS total_materias,
       ROUND(AVG(mat.nota_final), 2) AS promedio_programa
FROM programas prog
LEFT JOIN estudiantes e ON e.id_programa = prog.id_programa
LEFT JOIN materias m ON m.id_programa = prog.id_programa
LEFT JOIN matriculas mat ON mat.id_estudiante = e.id_estudiante AND mat.nota_final IS NOT NULL
GROUP BY prog.id_programa, prog.nombre_programa
ORDER BY prog.nombre_programa;
