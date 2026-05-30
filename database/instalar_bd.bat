@echo off
REM ============================================================================
REM  Instalador de la base de datos PlataformaEstudiantes (PostgreSQL 18)
REM  Doble clic para crear la base y cargar TODO (tablas, datos, vistas,
REM  procedimientos, trigger y usuarios del login).
REM ============================================================================
setlocal

REM Ruta a psql (ajusta la version si no es la 18)
set PSQL="C:\Program Files\PostgreSQL\18\bin\psql.exe"
set CREATEDB="C:\Program Files\PostgreSQL\18\bin\createdb.exe"
set DB=PlataformaEstudiantes
set PGUSER=postgres

cd /d "%~dp0"

echo.
echo  Se creara la base de datos "%DB%" con el usuario "%PGUSER%".
echo  Te pedira la contrasena de PostgreSQL varias veces.
echo.

%CREATEDB% -U %PGUSER% %DB%
%PSQL% -U %PGUSER% -d %DB% -f instalar_todo.sql

echo.
echo  ============================================================
echo   LISTO. Usuarios de prueba:
echo     admin   / admin123          (administrador)
echo     admin2  / micontrasena123   (administrador)
echo     (estudiantes)  ej: luis.perez / password123
echo  ============================================================
echo.
pause
