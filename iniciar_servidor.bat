@echo off
REM ============================================================================
REM  Iniciar el Sistema de Control Academico
REM  Doble clic para arrancar el servidor PHP y abrir la pagina de login.
REM  Para apagarlo: cierra esta ventana negra (o presiona Ctrl + C).
REM ============================================================================
title Servidor - Control Academico (NO cerrar mientras usas la pagina)

REM Ubicarse en la carpeta del proyecto (donde esta este .bat)
cd /d "%~dp0"

REM Buscar PHP: primero en el PATH, si no, en C:\php
where php >nul 2>nul
if %errorlevel%==0 (
    set "PHP=php"
) else (
    set "PHP=C:\php\php.exe"
)

if not exist "%PHP%" if "%PHP%"=="C:\php\php.exe" (
    echo.
    echo  [ERROR] No se encontro PHP. Instalalo o ajusta la ruta en este .bat.
    echo.
    pause
    exit /b 1
)

echo.
echo  ============================================================
echo   Servidor iniciado en:  http://localhost:8000/login.html
echo.
echo   Usuarios de prueba:
echo     admin       / admin123        (administrador)
echo     luis.perez  / password123      (estudiante)
echo.
echo   NO cierres esta ventana mientras uses la pagina.
echo   Para apagar el servidor: cierra esta ventana.
echo  ============================================================
echo.

REM Abrir el navegador en la pagina de login (espera 1 seg a que arranque)
timeout /t 1 /nobreak >nul
start "" http://localhost:8000/login.html

REM Arrancar el servidor PHP (esto deja la ventana ocupada a proposito)
"%PHP%" -S localhost:8000
