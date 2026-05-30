-- ============================================================================
-- PROYECTO FINAL - SISTEMA DE CONTROL ACADEMICO
-- Universidad Mariano Galvez de Guatemala
-- ----------------------------------------------------------------------------
-- ROL B - Especialista en SQL y Logica de Datos
-- Archivo: 05_procedimientos.sql
-- Base de datos: PlataformaEstudiantes (PostgreSQL 18)
-- ----------------------------------------------------------------------------
-- PARTE 4: Procedimientos almacenados (funciones PL/pgSQL)
-- Un procedimiento es un mini programa guardado en la base de datos que se
-- ejecuta llamandolo por su nombre y pasandole datos (parametros).
-- ============================================================================


-- ----------------------------------------------------------------------------
-- PROCEDIMIENTO 1: Calcular el promedio de un estudiante
-- ----------------------------------------------------------------------------
-- Recibe el numero de identificacion de un estudiante y devuelve su promedio
-- (solo materias con nota). Uso: SELECT calcular_promedio('2014');
CREATE FUNCTION calcular_promedio(p_identificacion VARCHAR)
RETURNS NUMERIC AS $$
DECLARE
    v_promedio NUMERIC;   -- variable temporal donde se guarda el resultado
BEGIN
    SELECT ROUND(AVG(mat.nota_final), 2)
    INTO v_promedio
    FROM matriculas mat
    JOIN estudiantes e ON mat.id_estudiante = e.id_estudiante
    WHERE e.numero_identificacion = p_identificacion
      AND mat.nota_final IS NOT NULL;

    RETURN v_promedio;
END;
$$ LANGUAGE plpgsql;


-- ----------------------------------------------------------------------------
-- PROCEDIMIENTO 2: Inscribir un estudiante en una materia
-- ----------------------------------------------------------------------------
-- Recibe identificacion del estudiante, codigo de materia y periodo. Busca los
-- ids por dentro, valida que existan (con IF) y crea la matricula en estado
-- 'Cursando'. Devuelve un mensaje de texto indicando el resultado.
-- Uso: SELECT inscribir_estudiante('2003', 'SIS-103', '2025-2');
CREATE FUNCTION inscribir_estudiante(
    p_identificacion VARCHAR,
    p_codigo_materia VARCHAR,
    p_periodo VARCHAR
)
RETURNS TEXT AS $$
DECLARE
    v_id_estudiante INTEGER;
    v_id_materia INTEGER;
BEGIN
    -- Buscar el id del estudiante a partir de su identificacion
    SELECT id_estudiante INTO v_id_estudiante
    FROM estudiantes WHERE numero_identificacion = p_identificacion;

    -- Buscar el id de la materia a partir de su codigo
    SELECT id_materia INTO v_id_materia
    FROM materias WHERE codigo_materia = p_codigo_materia;

    -- Validar que el estudiante exista
    IF v_id_estudiante IS NULL THEN
        RETURN 'Error: no existe un estudiante con esa identificacion';
    END IF;

    -- Validar que la materia exista
    IF v_id_materia IS NULL THEN
        RETURN 'Error: no existe una materia con ese codigo';
    END IF;

    -- Crear la matricula (estado Cursando, sin nota todavia)
    INSERT INTO matriculas (id_estudiante, id_materia, periodo_academico, estado_matricula)
    VALUES (v_id_estudiante, v_id_materia, p_periodo, 'Cursando');

    RETURN 'Inscripcion exitosa';
END;
$$ LANGUAGE plpgsql;


-- ----------------------------------------------------------------------------
-- PROCEDIMIENTO 3: Contar materias aprobadas de un estudiante
-- ----------------------------------------------------------------------------
-- Recibe la identificacion de un estudiante y devuelve cuantas materias ha
-- aprobado (estado 'Aprobada'). Devuelve un entero.
-- Uso: SELECT contar_aprobadas('2001');
CREATE FUNCTION contar_aprobadas(p_identificacion VARCHAR)
RETURNS INTEGER AS $$
DECLARE
    v_total INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO v_total
    FROM matriculas mat
    JOIN estudiantes e ON mat.id_estudiante = e.id_estudiante
    WHERE e.numero_identificacion = p_identificacion
      AND mat.estado_matricula = 'Aprobada';

    RETURN v_total;
END;
$$ LANGUAGE plpgsql;
