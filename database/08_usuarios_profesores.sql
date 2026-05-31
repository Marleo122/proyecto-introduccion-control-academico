-- ============================================================================
-- PROYECTO FINAL - SISTEMA DE CONTROL ACADEMICO
-- Universidad Mariano Galvez de Guatemala
-- ----------------------------------------------------------------------------
-- ROL C - Login y Seguridad (complemento)
-- Archivo: 08_usuarios_profesores.sql
-- Base de datos: PlataformaEstudiantes (PostgreSQL 18)
-- ----------------------------------------------------------------------------
-- Crea las cuentas de los 6 profesores para que puedan iniciar sesion y usar
-- el modulo de "Ingreso de notas" (Rol E). Cada usuario se enlaza al profesor
-- correspondiente por su numero_identificacion.
--
-- Todos usan la contrasena generica: profesor123
--
-- Ejecutar DESPUES de 02_datos_prueba.sql (necesita la tabla profesores) y de
-- 07_usuarios.sql (necesita la extension pgcrypto ya activada).
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

INSERT INTO usuarios (nombre_usuario, nombre_completo, email, password_hash, id_rol, id_profesor)
SELECT
    datos.nombre_usuario,
    pr.nombres || ' ' || pr.apellidos,
    pr.email_institucional,
    crypt('profesor123', gen_salt('bf')),
    (SELECT id_rol FROM roles WHERE nombre_rol = 'profesor'),
    pr.id_profesor
FROM profesores pr
JOIN (VALUES
    ('1001', 'ana.gomez'),
    ('1002', 'carlos.lopez'),
    ('1003', 'maria.castillo'),
    ('1004', 'diana.mejia'),
    ('1005', 'roberto.sanchez'),
    ('1006', 'laura.herrera')
) AS datos(identificacion, nombre_usuario)
  ON pr.numero_identificacion = datos.identificacion;

-- Comprobacion:
-- SELECT u.nombre_usuario, u.nombre_completo, r.nombre_rol
-- FROM usuarios u JOIN roles r ON u.id_rol = r.id_rol
-- WHERE r.nombre_rol = 'profesor';
