-- ============================================================================
-- PROYECTO FINAL - SISTEMA DE CONTROL ACADEMICO
-- Universidad Mariano Galvez de Guatemala
-- ----------------------------------------------------------------------------
-- ROL B - Especialista en SQL y Logica de Datos
-- Archivo: datos_prueba.sql
-- Base de datos: PlataformaEstudiantes (PostgreSQL 18)
-- ----------------------------------------------------------------------------
-- PARTE 1: Datos de prueba
-- Contiene: 3 facultades, 3 roles, 3 programas, 6 profesores, 12 materias,
--           15 estudiantes, 24 matriculas y 9 asignaciones.
-- NOTA: se usan subconsultas para obtener los ids (buscando por codigo o
-- identificacion) en lugar de numeros fijos, para que el script funcione
-- aunque los ids cambien en otra computadora.
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 1.1 FACULTADES
-- ----------------------------------------------------------------------------
INSERT INTO facultades (codigo_facultad, nombre_facultad) VALUES
('FAC-001', 'Ingenieria'),
('FAC-002', 'Ciencias Sociales'),
('FAC-003', 'Ciencias de la Salud');


-- ----------------------------------------------------------------------------
-- 1.2 ROLES
-- ----------------------------------------------------------------------------
INSERT INTO roles (nombre_rol, descripcion) VALUES
('admin', 'Administrador del sistema'),
('estudiante', 'Estudiante regular'),
('profesor', 'Profesor');


-- ----------------------------------------------------------------------------
-- 1.3 PROGRAMAS (cada uno apunta a su facultad via subconsulta)
-- ----------------------------------------------------------------------------
INSERT INTO programas (codigo_programa, nombre_programa, id_facultad, duracion_semestres) VALUES
('ING-SIS', 'Ingenieria de Sistemas', (SELECT id_facultad FROM facultades WHERE codigo_facultad = 'FAC-001'), 10),
('SOC-DER', 'Derecho',                (SELECT id_facultad FROM facultades WHERE codigo_facultad = 'FAC-002'), 10),
('SAL-MED', 'Medicina',               (SELECT id_facultad FROM facultades WHERE codigo_facultad = 'FAC-003'), 12);


-- ----------------------------------------------------------------------------
-- 1.4 PROFESORES (6)
-- ----------------------------------------------------------------------------
INSERT INTO profesores (numero_identificacion, nombres, apellidos, email_institucional, especialidad) VALUES
('1001', 'Ana Maria',      'Gomez Perez',    'ana.gomez@universidad.edu',     'Bases de Datos'),
('1002', 'Carlos Andres',  'Lopez Ruiz',     'carlos.lopez@universidad.edu',  'Redes'),
('1003', 'Maria Fernanda', 'Castillo Rojas', 'maria.castillo@universidad.edu','Programacion'),
('1004', 'Diana Carolina', 'Mejia Vargas',   'diana.mejia@universidad.edu',   'Derecho Penal'),
('1005', 'Roberto Carlos', 'Sanchez Diaz',   'roberto.sanchez@universidad.edu','Derecho Civil'),
('1006', 'Laura Patricia', 'Herrera Nunez',  'laura.herrera@universidad.edu', 'Anatomia');


-- ----------------------------------------------------------------------------
-- 1.5 MATERIAS (12: 4 por programa, ids de programa via subconsulta)
-- ----------------------------------------------------------------------------
INSERT INTO materias (codigo_materia, nombre_materia, creditos, horas_semanales, id_programa, semestre_recomendado) VALUES
-- Ingenieria de Sistemas
('SIS-101', 'Fundamentos de Programacion', 4, 6, (SELECT id_programa FROM programas WHERE codigo_programa = 'ING-SIS'), 1),
('SIS-102', 'Bases de Datos',              4, 5, (SELECT id_programa FROM programas WHERE codigo_programa = 'ING-SIS'), 3),
('SIS-103', 'Estructuras de Datos',        4, 6, (SELECT id_programa FROM programas WHERE codigo_programa = 'ING-SIS'), 2),
('SIS-104', 'Redes de Computadoras',       3, 4, (SELECT id_programa FROM programas WHERE codigo_programa = 'ING-SIS'), 4),
-- Derecho
('DER-101', 'Introduccion al Derecho',     3, 4, (SELECT id_programa FROM programas WHERE codigo_programa = 'SOC-DER'), 1),
('DER-102', 'Derecho Penal I',             4, 5, (SELECT id_programa FROM programas WHERE codigo_programa = 'SOC-DER'), 3),
('DER-103', 'Derecho Civil I',             4, 5, (SELECT id_programa FROM programas WHERE codigo_programa = 'SOC-DER'), 2),
('DER-104', 'Derecho Constitucional',      3, 4, (SELECT id_programa FROM programas WHERE codigo_programa = 'SOC-DER'), 2),
-- Medicina
('MED-101', 'Anatomia Humana',             5, 8, (SELECT id_programa FROM programas WHERE codigo_programa = 'SAL-MED'), 1),
('MED-102', 'Fisiologia',                  5, 7, (SELECT id_programa FROM programas WHERE codigo_programa = 'SAL-MED'), 2),
('MED-103', 'Bioquimica',                  4, 6, (SELECT id_programa FROM programas WHERE codigo_programa = 'SAL-MED'), 2),
('MED-104', 'Farmacologia',                4, 5, (SELECT id_programa FROM programas WHERE codigo_programa = 'SAL-MED'), 4);


-- ----------------------------------------------------------------------------
-- 1.6 ESTUDIANTES (15: 5 por programa)
-- ----------------------------------------------------------------------------
INSERT INTO estudiantes (numero_identificacion, nombres, apellidos, email_institucional, telefono, fecha_nacimiento, id_programa, semestre_actual) VALUES
('2001', 'Luis Alberto',   'Perez Gomez',     'luis.perez@est.universidad.edu',    '50212340001', '2003-03-12', (SELECT id_programa FROM programas WHERE codigo_programa = 'ING-SIS'), 3),
('2002', 'Andrea Sofia',   'Martinez Lopez',  'andrea.martinez@est.universidad.edu','50212340002', '2002-07-25', (SELECT id_programa FROM programas WHERE codigo_programa = 'ING-SIS'), 5),
('2003', 'Carlos Eduardo', 'Ramirez Solis',   'carlos.ramirez@est.universidad.edu','50212340003', '2004-01-30', (SELECT id_programa FROM programas WHERE codigo_programa = 'ING-SIS'), 1),
('2004', 'Maria Jose',     'Hernandez Cruz',  'maria.hernandez@est.universidad.edu','50212340004', '2003-11-08', (SELECT id_programa FROM programas WHERE codigo_programa = 'ING-SIS'), 3),
('2005', 'Diego Armando',  'Torres Mendoza',  'diego.torres@est.universidad.edu',  '50212340005', '2002-05-19', (SELECT id_programa FROM programas WHERE codigo_programa = 'ING-SIS'), 6),
('2006', 'Gabriela',       'Morales Reyes',   'gabriela.morales@est.universidad.edu','50212340006', '2003-09-14', (SELECT id_programa FROM programas WHERE codigo_programa = 'SOC-DER'), 2),
('2007', 'Jose Manuel',    'Castro Aguilar',  'jose.castro@est.universidad.edu',   '50212340007', '2001-12-03', (SELECT id_programa FROM programas WHERE codigo_programa = 'SOC-DER'), 6),
('2008', 'Valeria',        'Jimenez Ortega',  'valeria.jimenez@est.universidad.edu','50212340008', '2004-04-22', (SELECT id_programa FROM programas WHERE codigo_programa = 'SOC-DER'), 1),
('2009', 'Fernando',       'Vasquez Nunez',   'fernando.vasquez@est.universidad.edu','50212340009', '2002-02-17', (SELECT id_programa FROM programas WHERE codigo_programa = 'SOC-DER'), 4),
('2010', 'Lucia Isabel',   'Guerrero Paz',    'lucia.guerrero@est.universidad.edu','50212340010', '2003-06-28', (SELECT id_programa FROM programas WHERE codigo_programa = 'SOC-DER'), 2),
('2011', 'Ricardo',        'Mendizabal Leon', 'ricardo.mendizabal@est.universidad.edu','50212340011', '2001-08-09', (SELECT id_programa FROM programas WHERE codigo_programa = 'SAL-MED'), 5),
('2012', 'Paola Andrea',   'Estrada Fuentes', 'paola.estrada@est.universidad.edu', '50212340012', '2003-10-15', (SELECT id_programa FROM programas WHERE codigo_programa = 'SAL-MED'), 3),
('2013', 'Sergio',         'Ortiz Cabrera',   'sergio.ortiz@est.universidad.edu',  '50212340013', '2002-01-26', (SELECT id_programa FROM programas WHERE codigo_programa = 'SAL-MED'), 4),
('2014', 'Daniela',        'Rosales Pineda',  'daniela.rosales@est.universidad.edu','50212340014', '2004-03-07', (SELECT id_programa FROM programas WHERE codigo_programa = 'SAL-MED'), 1),
('2015', 'Andres Felipe',  'Cordon Maldonado','andres.cordon@est.universidad.edu', '50212340015', '2002-09-30', (SELECT id_programa FROM programas WHERE codigo_programa = 'SAL-MED'), 2);


-- ----------------------------------------------------------------------------
-- 1.7 MATRICULAS (24: mezcla de Aprobada, Reprobada y Cursando)
-- Nota: estado 'Cursando' lleva nota NULL porque aun no tiene calificacion.
-- ----------------------------------------------------------------------------
INSERT INTO matriculas (id_estudiante, id_materia, periodo_academico, nota_final, estado_matricula) VALUES
((SELECT id_estudiante FROM estudiantes WHERE numero_identificacion='2001'), (SELECT id_materia FROM materias WHERE codigo_materia='SIS-101'), '2024-2', 4.2, 'Aprobada'),
((SELECT id_estudiante FROM estudiantes WHERE numero_identificacion='2001'), (SELECT id_materia FROM materias WHERE codigo_materia='SIS-103'), '2025-1', 3.5, 'Aprobada'),
((SELECT id_estudiante FROM estudiantes WHERE numero_identificacion='2001'), (SELECT id_materia FROM materias WHERE codigo_materia='SIS-102'), '2025-1', NULL, 'Cursando'),
((SELECT id_estudiante FROM estudiantes WHERE numero_identificacion='2002'), (SELECT id_materia FROM materias WHERE codigo_materia='SIS-101'), '2024-2', 4.8, 'Aprobada'),
((SELECT id_estudiante FROM estudiantes WHERE numero_identificacion='2002'), (SELECT id_materia FROM materias WHERE codigo_materia='SIS-104'), '2025-1', 2.5, 'Reprobada'),
((SELECT id_estudiante FROM estudiantes WHERE numero_identificacion='2003'), (SELECT id_materia FROM materias WHERE codigo_materia='SIS-101'), '2025-1', NULL, 'Cursando'),
((SELECT id_estudiante FROM estudiantes WHERE numero_identificacion='2004'), (SELECT id_materia FROM materias WHERE codigo_materia='SIS-102'), '2024-2', 3.9, 'Aprobada'),
((SELECT id_estudiante FROM estudiantes WHERE numero_identificacion='2004'), (SELECT id_materia FROM materias WHERE codigo_materia='SIS-103'), '2025-1', 4.1, 'Aprobada'),
((SELECT id_estudiante FROM estudiantes WHERE numero_identificacion='2005'), (SELECT id_materia FROM materias WHERE codigo_materia='SIS-104'), '2024-2', 2.0, 'Reprobada'),
((SELECT id_estudiante FROM estudiantes WHERE numero_identificacion='2005'), (SELECT id_materia FROM materias WHERE codigo_materia='SIS-101'), '2025-1', 4.6, 'Aprobada'),
((SELECT id_estudiante FROM estudiantes WHERE numero_identificacion='2006'), (SELECT id_materia FROM materias WHERE codigo_materia='DER-101'), '2024-2', 4.0, 'Aprobada'),
((SELECT id_estudiante FROM estudiantes WHERE numero_identificacion='2006'), (SELECT id_materia FROM materias WHERE codigo_materia='DER-103'), '2025-1', 3.7, 'Aprobada'),
((SELECT id_estudiante FROM estudiantes WHERE numero_identificacion='2007'), (SELECT id_materia FROM materias WHERE codigo_materia='DER-102'), '2025-1', NULL, 'Cursando'),
((SELECT id_estudiante FROM estudiantes WHERE numero_identificacion='2008'), (SELECT id_materia FROM materias WHERE codigo_materia='DER-101'), '2025-1', 3.0, 'Aprobada'),
((SELECT id_estudiante FROM estudiantes WHERE numero_identificacion='2009'), (SELECT id_materia FROM materias WHERE codigo_materia='DER-101'), '2024-2', 1.8, 'Reprobada'),
((SELECT id_estudiante FROM estudiantes WHERE numero_identificacion='2009'), (SELECT id_materia FROM materias WHERE codigo_materia='DER-102'), '2025-1', 3.3, 'Aprobada'),
((SELECT id_estudiante FROM estudiantes WHERE numero_identificacion='2010'), (SELECT id_materia FROM materias WHERE codigo_materia='DER-101'), '2025-1', NULL, 'Cursando'),
((SELECT id_estudiante FROM estudiantes WHERE numero_identificacion='2011'), (SELECT id_materia FROM materias WHERE codigo_materia='MED-101'), '2024-2', 4.5, 'Aprobada'),
((SELECT id_estudiante FROM estudiantes WHERE numero_identificacion='2011'), (SELECT id_materia FROM materias WHERE codigo_materia='MED-102'), '2025-1', 3.8, 'Aprobada'),
((SELECT id_estudiante FROM estudiantes WHERE numero_identificacion='2012'), (SELECT id_materia FROM materias WHERE codigo_materia='MED-101'), '2024-2', 2.2, 'Reprobada'),
((SELECT id_estudiante FROM estudiantes WHERE numero_identificacion='2012'), (SELECT id_materia FROM materias WHERE codigo_materia='MED-103'), '2025-1', 4.0, 'Aprobada'),
((SELECT id_estudiante FROM estudiantes WHERE numero_identificacion='2013'), (SELECT id_materia FROM materias WHERE codigo_materia='MED-102'), '2025-1', NULL, 'Cursando'),
((SELECT id_estudiante FROM estudiantes WHERE numero_identificacion='2014'), (SELECT id_materia FROM materias WHERE codigo_materia='MED-101'), '2025-1', 4.7, 'Aprobada'),
((SELECT id_estudiante FROM estudiantes WHERE numero_identificacion='2015'), (SELECT id_materia FROM materias WHERE codigo_materia='MED-103'), '2025-1', 3.4, 'Aprobada');


-- ----------------------------------------------------------------------------
-- 1.8 ASIGNACIONES PROFESOR-MATERIA (9)
-- ----------------------------------------------------------------------------
INSERT INTO asignacionprofesormateria (id_profesor, id_materia, periodo_academico) VALUES
((SELECT id_profesor FROM profesores WHERE numero_identificacion='1003'), (SELECT id_materia FROM materias WHERE codigo_materia='SIS-101'), '2025-1'),
((SELECT id_profesor FROM profesores WHERE numero_identificacion='1001'), (SELECT id_materia FROM materias WHERE codigo_materia='SIS-102'), '2025-1'),
((SELECT id_profesor FROM profesores WHERE numero_identificacion='1003'), (SELECT id_materia FROM materias WHERE codigo_materia='SIS-103'), '2025-1'),
((SELECT id_profesor FROM profesores WHERE numero_identificacion='1002'), (SELECT id_materia FROM materias WHERE codigo_materia='SIS-104'), '2025-1'),
((SELECT id_profesor FROM profesores WHERE numero_identificacion='1004'), (SELECT id_materia FROM materias WHERE codigo_materia='DER-102'), '2025-1'),
((SELECT id_profesor FROM profesores WHERE numero_identificacion='1005'), (SELECT id_materia FROM materias WHERE codigo_materia='DER-103'), '2025-1'),
((SELECT id_profesor FROM profesores WHERE numero_identificacion='1005'), (SELECT id_materia FROM materias WHERE codigo_materia='DER-101'), '2025-1'),
((SELECT id_profesor FROM profesores WHERE numero_identificacion='1006'), (SELECT id_materia FROM materias WHERE codigo_materia='MED-101'), '2025-1'),
((SELECT id_profesor FROM profesores WHERE numero_identificacion='1006'), (SELECT id_materia FROM materias WHERE codigo_materia='MED-102'), '2025-1');
