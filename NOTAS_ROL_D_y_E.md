# Notas para Rol D y Rol E

Hola companeros. Los **Roles A, B y C ya estan listos y unificados** en este repositorio.
Aqui les dejo lo que necesitan para montar sus partes sin romper nada.

## Lo que ya esta hecho

- **Rol A + B (base de datos):** scripts en `database/` (`01_estructura.sql` a `06_trigger.sql`)
  que crean toda la base **PlataformaEstudiantes** en PostgreSQL, mas `07_usuarios.sql`
  (usuarios del login).
- **Rol C (login y seguridad):** login funcional con sesiones y roles (admin / estudiante),
  contrasenas hasheadas con bcrypt. Esta en `backend/`, `login.html` y los paneles.

## Como dejarlo corriendo (resumen)

1. **Base de datos:** entra a `database/` y ejecuta (o doble clic en `instalar_bd.bat`):
   ```
   createdb -U postgres PlataformaEstudiantes
   psql -U postgres -d PlataformaEstudiantes -f instalar_todo.sql
   ```
2. **Configuracion:** copia `config/config.example.php` y renombralo a `config/config.php`,
   luego pon ahi la contrasena de TU PostgreSQL.
3. **PHP:** instala PHP (ver `README.md`) y arranca el servidor con doble clic en
   `iniciar_servidor.bat`, o con `php -S localhost:8000`.
4. Abre **http://localhost:8000/login.html**

## Usuarios de prueba

| Usuario     | Contrasena      | Rol           |
|-------------|-----------------|---------------|
| admin       | admin123        | administrador |
| admin2      | micontrasena123 | administrador |
| luis.perez  | password123     | estudiante    |

(Todos los estudiantes usan `password123`. Usuario = nombre.apellido.)

## Para el ROL D (CRUD - gestion de datos)

- Hagan las pantallas de **Estudiantes, Cursos, Docentes y Asignaciones**.
- Ya hay un backend de ejemplo: `backend/estudiantes.php` (listar / agregar / actualizar /
  eliminar) y `backend/listar_programas.php`. Copien ese mismo patron para las demas tablas.
- Monten las pantallas en el bloque marcado **ROL D** dentro de `panel_admin.html`.
- Protejan sus endpoints con `requerirRol('admin')` (ver `backend/auth.php`).

## Para el ROL E (Academico y Reportes)

- Pantallas: **inscripcion de cursos, ingreso de notas (0-100), historial academico,
  buscador con filtros y reporte exportable**.
- Apoyense en lo que ya hizo el Rol B:
  - Vistas: `vista_promedios`, `vista_historial_academico`, `vista_cursos_por_docente`
  - Procedimientos: `calcular_promedio(id)`, `inscribir_estudiante(id, codigo, periodo)`,
    `contar_aprobadas(id)`
- Monten las pantallas en los bloques **ROL E** de `panel_admin.html` y `panel_estudiante.html`.

## Importante

- La conexion a la base se configura en **un solo lugar:** `config/config.php`.
- No cambien la estructura de las tablas sin avisar (el login depende de `usuarios`,
  `roles`, `sesiones` e `intentoslogin`).

Cualquier duda me avisan. - Leo (Rol B)
