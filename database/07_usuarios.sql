-- ============================================================================
-- PROYECTO FINAL - SISTEMA DE CONTROL ACADEMICO
-- Universidad Mariano Galvez de Guatemala
-- ----------------------------------------------------------------------------
-- ROL C - Login y Seguridad
-- Archivo: 07_usuarios.sql
-- Base de datos: PlataformaEstudiantes (PostgreSQL 18)
-- ----------------------------------------------------------------------------
-- Crea los usuarios genericos del sistema (capa de login).
--
-- SEGURIDAD: las contrasenas NO se guardan en texto plano. Se hashean con
-- bcrypt usando la extension pgcrypto: crypt(clave, gen_salt('bf')).
-- El backend PHP las verifica con password_verify(), que es compatible con el
-- formato bcrypt ($2a$) que genera pgcrypto. Esto cumple (y mejora) el
-- requisito de "contrasenas hasheadas" del Rol C (bcrypt es mas fuerte que
-- SHA2 y es el estandar de PHP para contrasenas).
--
-- IMPORTANTE: ejecutar DESPUES de 02_datos_prueba.sql, porque los usuarios de
-- estudiante se enlazan con la tabla estudiantes por numero_identificacion.
--
-- ----------------------------------------------------------------------------
-- CREDENCIALES GENERICAS (usuario / contrasena):
--   admin              / admin123          (administrador)
--   admin2             / micontrasena123   (administrador)
--   luis.perez         / password123       (estudiante)  ... y los demas 14
--   (todos los estudiantes usan la contrasena: password123)
-- ============================================================================


-- Activa pgcrypto para poder hashear con bcrypt (crypt + gen_salt).
-- Viene incluida con la instalacion estandar de PostgreSQL.
CREATE EXTENSION IF NOT EXISTS pgcrypto;


-- ----------------------------------------------------------------------------
-- 1. ADMINISTRADORES (2). No se enlazan a estudiante ni profesor (ambos NULL,
--    permitido por la restriccion check_estudiante_profesor).
-- ----------------------------------------------------------------------------
INSERT INTO usuarios (nombre_usuario, nombre_completo, email, password_hash, id_rol) VALUES
('admin',  'Administrador General', 'admin@universidad.edu',
    crypt('admin123', gen_salt('bf')),
    (SELECT id_rol FROM roles WHERE nombre_rol = 'admin')),
('admin2', 'Administrador Secundario', 'admin2@universidad.edu',
    crypt('micontrasena123', gen_salt('bf')),
    (SELECT id_rol FROM roles WHERE nombre_rol = 'admin'));


-- ----------------------------------------------------------------------------
-- 2. ESTUDIANTES (15). Cada usuario se enlaza al estudiante correspondiente
--    buscando su numero_identificacion (igual patron que el Rol B). Todos usan
--    la contrasena generica 'password123'.
-- ----------------------------------------------------------------------------
INSERT INTO usuarios (nombre_usuario, nombre_completo, email, password_hash, id_rol, id_estudiante)
SELECT
    datos.nombre_usuario,
    e.nombres || ' ' || e.apellidos,
    e.email_institucional,
    crypt('password123', gen_salt('bf')),
    (SELECT id_rol FROM roles WHERE nombre_rol = 'estudiante'),
    e.id_estudiante
FROM estudiantes e
JOIN (VALUES
    ('2001', 'luis.perez'),
    ('2002', 'andrea.martinez'),
    ('2003', 'carlos.ramirez'),
    ('2004', 'maria.hernandez'),
    ('2005', 'diego.torres'),
    ('2006', 'gabriela.morales'),
    ('2007', 'jose.castro'),
    ('2008', 'valeria.jimenez'),
    ('2009', 'fernando.vasquez'),
    ('2010', 'lucia.guerrero'),
    ('2011', 'ricardo.mendizabal'),
    ('2012', 'paola.estrada'),
    ('2013', 'sergio.ortiz'),
    ('2014', 'daniela.rosales'),
    ('2015', 'andres.cordon')
) AS datos(identificacion, nombre_usuario)
  ON e.numero_identificacion = datos.identificacion;


-- ----------------------------------------------------------------------------
-- COMPROBACION (opcional): ver los usuarios creados con su rol.
-- ----------------------------------------------------------------------------
-- SELECT u.id_usuario, u.nombre_usuario, u.nombre_completo, r.nombre_rol
-- FROM usuarios u JOIN roles r ON u.id_rol = r.id_rol
-- ORDER BY r.nombre_rol, u.nombre_usuario;
