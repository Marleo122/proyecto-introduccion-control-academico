-- ============================================================================
-- INSTALADOR COMPLETO - SISTEMA DE CONTROL ACADEMICO
-- Universidad Mariano Galvez de Guatemala  |  PostgreSQL 18
-- ----------------------------------------------------------------------------
-- Ejecuta TODOS los scripts en el orden correcto desde una sola llamada.
--
-- USO (desde la terminal de Windows, ya con la base creada):
--   createdb -U postgres PlataformaEstudiantes
--   psql -U postgres -d PlataformaEstudiantes -f instalar_todo.sql
--
-- O desde psql ya conectado a PlataformaEstudiantes:
--   \i instalar_todo.sql
-- ============================================================================

\echo '== 1/7  Creando estructura de tablas =='
\i 01_estructura.sql

\echo '== 2/7  Insertando datos de prueba =='
\i 02_datos_prueba.sql

\echo '== 3/7  Consultas de demostracion (Rol B) =='
\i 03_consultas.sql

\echo '== 4/7  Creando vistas =='
\i 04_vistas.sql

\echo '== 5/7  Creando procedimientos almacenados =='
\i 05_procedimientos.sql

\echo '== 6/7  Creando trigger =='
\i 06_trigger.sql

\echo '== 7/8  Creando usuarios del login (Rol C) =='
\i 07_usuarios.sql

\echo '== 8/8  Creando usuarios de profesores (Rol C) =='
\i 08_usuarios_profesores.sql

\echo '== LISTO: base de datos PlataformaEstudiantes instalada por completo =='
