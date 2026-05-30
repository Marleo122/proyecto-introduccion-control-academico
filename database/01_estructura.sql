-- ============================================================================
-- PROYECTO FINAL - SISTEMA DE CONTROL ACADEMICO
-- Universidad Mariano Galvez de Guatemala
-- ----------------------------------------------------------------------------
-- Archivo: 01_estructura.sql
-- Base de datos: PlataformaEstudiantes (PostgreSQL 18)
-- ----------------------------------------------------------------------------
-- Crea la estructura completa de las 11 tablas con sus claves primarias,
-- claves foraneas y restricciones (NOT NULL, UNIQUE, CHECK, DEFAULT).
-- ORDEN: de tablas independientes a dependientes (por las claves foraneas).
--
-- COMO USAR (desde la terminal de Windows, no desde psql):
--   1. createdb -U postgres PlataformaEstudiantes
--   2. psql -U postgres -d PlataformaEstudiantes -f 01_estructura.sql
--   3. psql -U postgres -d PlataformaEstudiantes -f datos_prueba.sql
--   4. psql -U postgres -d PlataformaEstudiantes -f consultas.sql
-- ============================================================================


-- 1. FACULTADES
CREATE TABLE facultades (
    id_facultad SERIAL PRIMARY KEY,
    codigo_facultad VARCHAR(10) NOT NULL UNIQUE,
    nombre_facultad VARCHAR(100) NOT NULL UNIQUE,
    estado BOOLEAN NOT NULL DEFAULT true,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2. ROLES
CREATE TABLE roles (
    id_rol SERIAL PRIMARY KEY,
    nombre_rol VARCHAR(20) NOT NULL UNIQUE,
    descripcion VARCHAR(100)
);

-- 3. PROGRAMAS (depende de facultades)
CREATE TABLE programas (
    id_programa SERIAL PRIMARY KEY,
    codigo_programa VARCHAR(10) NOT NULL UNIQUE,
    nombre_programa VARCHAR(100) NOT NULL UNIQUE,
    id_facultad INTEGER NOT NULL,
    duracion_semestres INTEGER NOT NULL,
    estado BOOLEAN NOT NULL DEFAULT true,
    CONSTRAINT programas_id_facultad_fkey FOREIGN KEY (id_facultad) REFERENCES facultades(id_facultad),
    CONSTRAINT programas_duracion_semestres_check CHECK (duracion_semestres >= 4 AND duracion_semestres <= 12)
);

-- 4. ESTUDIANTES (depende de programas)
CREATE TABLE estudiantes (
    id_estudiante SERIAL PRIMARY KEY,
    numero_identificacion VARCHAR(20) NOT NULL UNIQUE,
    nombres VARCHAR(50) NOT NULL,
    apellidos VARCHAR(50) NOT NULL,
    email_institucional VARCHAR(100) NOT NULL UNIQUE,
    email_personal VARCHAR(100),
    telefono VARCHAR(15),
    fecha_nacimiento DATE NOT NULL,
    id_programa INTEGER NOT NULL,
    semestre_actual INTEGER NOT NULL,
    fecha_ingreso DATE NOT NULL DEFAULT CURRENT_DATE,
    activo BOOLEAN NOT NULL DEFAULT true,
    CONSTRAINT estudiantes_id_programa_fkey FOREIGN KEY (id_programa) REFERENCES programas(id_programa),
    CONSTRAINT estudiantes_fecha_nacimiento_check CHECK (fecha_nacimiento <= (CURRENT_DATE - INTERVAL '15 years')),
    CONSTRAINT estudiantes_semestre_actual_check CHECK (semestre_actual >= 1 AND semestre_actual <= 12)
);

-- 5. PROFESORES (tabla independiente)
CREATE TABLE profesores (
    id_profesor SERIAL PRIMARY KEY,
    numero_identificacion VARCHAR(20) NOT NULL UNIQUE,
    nombres VARCHAR(50) NOT NULL,
    apellidos VARCHAR(50) NOT NULL,
    email_institucional VARCHAR(100) NOT NULL UNIQUE,
    especialidad VARCHAR(100),
    fecha_contratacion DATE NOT NULL DEFAULT CURRENT_DATE,
    activo BOOLEAN NOT NULL DEFAULT true
);

-- 6. MATERIAS (depende de programas)
CREATE TABLE materias (
    id_materia SERIAL PRIMARY KEY,
    codigo_materia VARCHAR(10) NOT NULL UNIQUE,
    nombre_materia VARCHAR(100) NOT NULL UNIQUE,
    creditos INTEGER NOT NULL,
    horas_semanales INTEGER NOT NULL,
    id_programa INTEGER NOT NULL,
    semestre_recomendado INTEGER NOT NULL,
    CONSTRAINT materias_id_programa_fkey FOREIGN KEY (id_programa) REFERENCES programas(id_programa),
    CONSTRAINT materias_creditos_check CHECK (creditos >= 1 AND creditos <= 6),
    CONSTRAINT materias_horas_semanales_check CHECK (horas_semanales >= 1 AND horas_semanales <= 10),
    CONSTRAINT materias_semestre_recomendado_check CHECK (semestre_recomendado >= 1 AND semestre_recomendado <= 12)
);

-- 7. MATRICULAS (tabla N:M entre estudiantes y materias; guarda la nota)
CREATE TABLE matriculas (
    id_matricula SERIAL PRIMARY KEY,
    id_estudiante INTEGER NOT NULL,
    id_materia INTEGER NOT NULL,
    periodo_academico VARCHAR(10) NOT NULL,
    fecha_matricula TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    nota_final NUMERIC(4,2),
    estado_matricula VARCHAR(20) NOT NULL DEFAULT 'Cursando',
    CONSTRAINT matriculas_id_estudiante_fkey FOREIGN KEY (id_estudiante) REFERENCES estudiantes(id_estudiante),
    CONSTRAINT matriculas_id_materia_fkey FOREIGN KEY (id_materia) REFERENCES materias(id_materia),
    CONSTRAINT matriculas_nota_final_check CHECK (nota_final >= 0 AND nota_final <= 5),
    CONSTRAINT matriculas_estado_matricula_check CHECK (estado_matricula IN ('Cursando', 'Aprobada', 'Reprobada', 'Cancelada')),
    CONSTRAINT uq_matricula_estudiante_materia_periodo UNIQUE (id_estudiante, id_materia, periodo_academico)
);

-- 8. ASIGNACIONPROFESORMATERIA (tabla N:M entre profesores y materias)
CREATE TABLE asignacionprofesormateria (
    id_asignacion SERIAL PRIMARY KEY,
    id_profesor INTEGER NOT NULL,
    id_materia INTEGER NOT NULL,
    periodo_academico VARCHAR(10) NOT NULL,
    fecha_asignacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT asignacionprofesormateria_id_profesor_fkey FOREIGN KEY (id_profesor) REFERENCES profesores(id_profesor),
    CONSTRAINT asignacionprofesormateria_id_materia_fkey FOREIGN KEY (id_materia) REFERENCES materias(id_materia),
    CONSTRAINT uq_profesormateria_periodo UNIQUE (id_profesor, id_materia, periodo_academico)
);

-- 9. USUARIOS (capa de seguridad; depende de roles, estudiantes y profesores)
CREATE TABLE usuarios (
    id_usuario SERIAL PRIMARY KEY,
    nombre_usuario VARCHAR(50) NOT NULL UNIQUE,
    nombre_completo VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    id_rol INTEGER NOT NULL,
    id_estudiante INTEGER,
    id_profesor INTEGER,
    activo BOOLEAN NOT NULL DEFAULT true,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ultimo_login TIMESTAMP,
    CONSTRAINT usuarios_id_rol_fkey FOREIGN KEY (id_rol) REFERENCES roles(id_rol),
    CONSTRAINT usuarios_id_estudiante_fkey FOREIGN KEY (id_estudiante) REFERENCES estudiantes(id_estudiante),
    CONSTRAINT usuarios_id_profesor_fkey FOREIGN KEY (id_profesor) REFERENCES profesores(id_profesor),
    CONSTRAINT check_estudiante_profesor CHECK (
        (id_estudiante IS NOT NULL AND id_profesor IS NULL) OR
        (id_estudiante IS NULL AND id_profesor IS NOT NULL) OR
        (id_estudiante IS NULL AND id_profesor IS NULL)
    )
);

-- 10. SESIONES (depende de usuarios)
CREATE TABLE sesiones (
    id_sesion SERIAL PRIMARY KEY,
    id_usuario INTEGER NOT NULL,
    token VARCHAR(500) NOT NULL UNIQUE,
    ip_address VARCHAR(45),
    user_agent TEXT,
    fecha_inicio TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion TIMESTAMP NOT NULL,
    CONSTRAINT sesiones_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
);

-- 11. INTENTOSLOGIN (tabla independiente; registro de seguridad)
CREATE TABLE intentoslogin (
    id_intento SERIAL PRIMARY KEY,
    nombre_usuario VARCHAR(50) NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    fue_exitoso BOOLEAN NOT NULL,
    fecha_intento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
