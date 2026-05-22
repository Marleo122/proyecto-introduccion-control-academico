-- ============================================================================
-- PROYECTO FINAL - SISTEMA DE CONTROL ACADEMICO
-- Universidad Mariano Galvez de Guatemala
-- ----------------------------------------------------------------------------
-- ROL B - Especialista en SQL y Logica de Datos
-- Archivo: 06_trigger.sql
-- Base de datos: PlataformaEstudiantes (PostgreSQL 18)
-- ----------------------------------------------------------------------------
-- PARTE 5: Trigger (disparador automatico)
-- Un trigger ejecuta una accion automaticamente cuando ocurre un INSERT,
-- UPDATE o DELETE en una tabla, sin necesidad de llamarlo manualmente.
-- En PostgreSQL se crea en DOS pasos: 1) una funcion de trigger, 2) el trigger.
-- ============================================================================


-- ----------------------------------------------------------------------------
-- PASO 1: Funcion del trigger
-- ----------------------------------------------------------------------------
-- Define que hacer cuando se dispare: si la matricula tiene nota, ajusta el
-- estado automaticamente (Aprobada si nota >= 3.0, Reprobada si es menor).
-- NEW representa la fila que se esta insertando o actualizando.
CREATE FUNCTION actualizar_estado_nota()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.nota_final IS NOT NULL THEN
        IF NEW.nota_final >= 3.0 THEN
            NEW.estado_matricula := 'Aprobada';
        ELSE
            NEW.estado_matricula := 'Reprobada';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- ----------------------------------------------------------------------------
-- PASO 2: El trigger
-- ----------------------------------------------------------------------------
-- Conecta la funcion anterior a la tabla matriculas. Se dispara BEFORE (antes)
-- de cada INSERT o UPDATE, para cada fila, y ejecuta actualizar_estado_nota().
-- Se usa BEFORE para poder corregir el estado antes de que la fila se guarde.
CREATE TRIGGER trg_actualizar_estado
BEFORE INSERT OR UPDATE ON matriculas
FOR EACH ROW
EXECUTE FUNCTION actualizar_estado_nota();


-- ----------------------------------------------------------------------------
-- PRUEBA DEL TRIGGER (demostracion)
-- ----------------------------------------------------------------------------
-- Al actualizar SOLO la nota, el trigger ajusta el estado automaticamente.
-- UPDATE matriculas SET nota_final = 4.5
-- WHERE id_estudiante = (SELECT id_estudiante FROM estudiantes WHERE numero_identificacion = '2001')
--   AND id_materia = (SELECT id_materia FROM materias WHERE codigo_materia = 'SIS-102');
-- Resultado esperado: el estado pasa de 'Cursando' a 'Aprobada' solo.
