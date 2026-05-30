# Sistema de Control Academico — Proyecto Final

Universidad Mariano Galvez de Guatemala · Ingenieria en Sistemas · Introduccion a los Sistemas de Computo

Proyecto **unificado**: junta el trabajo de la base de datos (Rol A + Rol B) con el
modulo de login y seguridad (Rol C), y deja todo listo para que el **Rol D** (CRUD) y
el **Rol E** (academico y reportes) agreguen sus pantallas.

- **Base de datos:** PostgreSQL 18 — base `PlataformaEstudiantes`
- **Backend:** PHP (PDO)
- **Frontend:** HTML + CSS + JavaScript
- **Editor:** Visual Studio Code

---

## Estructura del proyecto

```
Proyecto Introduccion/
├── database/                  ← Base de datos (Rol A + Rol B) + usuarios (Rol C)
│   ├── 01_estructura.sql        tablas, claves y restricciones (Rol A)
│   ├── 02_datos_prueba.sql      datos de prueba (Rol B)
│   ├── 03_consultas.sql         15 consultas (Rol B)
│   ├── 04_vistas.sql            vistas (Rol B)
│   ├── 05_procedimientos.sql    procedimientos almacenados (Rol B)
│   ├── 06_trigger.sql           trigger (Rol B)
│   ├── 07_usuarios.sql          usuarios del login, contrasenas hasheadas (Rol C)
│   ├── instalar_todo.sql        ejecuta TODO lo anterior en orden
│   └── instalar_bd.bat          instalador automatico (doble clic)
├── config/
│   └── config.php             ← conexion UNICA a la BD (cambia la clave aqui)
├── backend/                   ← API en PHP
│   ├── auth.php                 helpers de sesion y permisos
│   ├── login.php               (Rol C) iniciar sesion
│   ├── logout.php              (Rol C) cerrar sesion
│   ├── sesion_actual.php       (Rol C) saber quien esta logueado
│   ├── estudiantes.php         (base para Rol D) CRUD de estudiantes
│   └── listar_programas.php    (base para Rol D/E) consulta de programas
├── login.html                ← pantalla de inicio de sesion (Rol C)
├── panel_admin.html          ← panel del administrador (huecos para Rol D y E)
├── panel_estudiante.html     ← panel del estudiante (huecos para Rol E)
├── estilos_sistema.css       ← estilos del login y los paneles
├── js/
│   ├── login.js                logica del login
│   └── panel.js                control de sesion en los paneles
├── index tabla.html, consulta.html, ...   ← paginas previas del Rol C (decorativas/tabla)
└── _respaldo_rolC_original/  ← borradores PHP viejos (respaldo, ya no se usan)
```

---

## Paso 1 — Instalar la base de datos (PostgreSQL)

Ya tienes PostgreSQL 18 instalado en `C:\Program Files\PostgreSQL\18`.

**Opcion facil (recomendada):** entra a la carpeta `database` y haz **doble clic en
`instalar_bd.bat`**. Te pedira la contrasena de PostgreSQL (la del usuario `postgres`)
y creara todo automaticamente.

**Opcion manual (terminal):**
```powershell
cd "C:\Users\Marleo\Desktop\Proyecto Introduccion\database"
& "C:\Program Files\PostgreSQL\18\bin\createdb.exe" -U postgres PlataformaEstudiantes
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -d PlataformaEstudiantes -f instalar_todo.sql
```

> Nota: `07_usuarios.sql` usa la extension `pgcrypto` (incluida con PostgreSQL) para
> hashear las contrasenas con bcrypt. El script la activa solo con
> `CREATE EXTENSION IF NOT EXISTS pgcrypto;`.

---

## Paso 2 — Configurar la conexion

Abre `config/config.php` y cambia **solo** esta linea por la contrasena de tu PostgreSQL:

```php
define('DB_PASS', 'CAMBIA_ESTA_CONTRASENA');
```

Es el **unico** lugar donde se configura la conexion para todo el proyecto.

---

## Paso 3 — Instalar PHP (si aun no lo tienes)

El backend usa PHP y **todavia no esta instalado** en esta computadora. Dos opciones:

- **PHP solo:** descarga "PHP for Windows" (https://windows.php.net/download/),
  descomprime en `C:\php`, y agrega `C:\php` al PATH. Activa la extension de PostgreSQL
  editando `C:\php\php.ini` y quitando el `;` de la linea `;extension=pdo_pgsql`.
- **XAMPP:** instala XAMPP (trae PHP y Apache). Copia esta carpeta dentro de
  `C:\xampp\htdocs\` y abre `http://localhost/Proyecto Introduccion/login.html`.

Para comprobar que PHP quedo bien:
```powershell
php -v
php -m | findstr pdo_pgsql
```

---

## Paso 4 — Correr el proyecto desde VS Code

1. Abre la carpeta del proyecto en VS Code (`Archivo > Abrir carpeta`).
2. Acepta instalar las extensiones recomendadas (PHP, PostgreSQL).
3. Levanta el servidor PHP integrado. Dos formas:
   - Menu **Terminal > Ejecutar tarea... > "Servidor PHP (localhost:8000)"**, o
   - en la terminal de VS Code:
     ```powershell
     php -S localhost:8000
     ```
4. Abre en el navegador: **http://localhost:8000/login.html**

---

## Usuarios de prueba (credenciales genericas)

| Usuario             | Contrasena         | Rol           |
|---------------------|--------------------|---------------|
| `admin`             | `admin123`         | administrador |
| `admin2`            | `micontrasena123`  | administrador |
| `luis.perez`        | `password123`      | estudiante    |
| `andrea.martinez`   | `password123`      | estudiante    |
| `carlos.ramirez`    | `password123`      | estudiante    |
| `maria.hernandez`   | `password123`      | estudiante    |
| `diego.torres`      | `password123`      | estudiante    |
| `gabriela.morales`  | `password123`      | estudiante    |
| `jose.castro`       | `password123`      | estudiante    |
| `valeria.jimenez`   | `password123`      | estudiante    |
| `fernando.vasquez`  | `password123`      | estudiante    |
| `lucia.guerrero`    | `password123`      | estudiante    |
| `ricardo.mendizabal`| `password123`      | estudiante    |
| `paola.estrada`     | `password123`      | estudiante    |
| `sergio.ortiz`      | `password123`      | estudiante    |
| `daniela.rosales`   | `password123`      | estudiante    |
| `andres.cordon`     | `password123`      | estudiante    |

> Tambien puedes entrar usando el correo en vez del usuario (ej: `admin@universidad.edu`).
> El administrador entra al `panel_admin.html` y el estudiante al `panel_estudiante.html`.

---

## Para el Rol D (CRUD) y el Rol E (Academico y Reportes)

Todo queda "enchufable":

- **Rol D:** ya tienes `backend/estudiantes.php` (listar / agregar / actualizar / eliminar)
  y `backend/listar_programas.php`. Crea los endpoints equivalentes para cursos, docentes y
  asignaciones siguiendo el mismo patron, y monta las pantallas dentro del bloque
  marcado `ROL D` en `panel_admin.html`.
- **Rol E:** apoyate en las vistas y procedimientos del Rol B (`vista_promedios`,
  `vista_historial_academico`, `vista_cursos_por_docente`, `calcular_promedio()`,
  `inscribir_estudiante()`) y monta las pantallas en los bloques `ROL E` de los paneles.
- **Seguridad lista:** protege cualquier endpoint nuevo con `requerirLogin()` o
  `requerirRol('admin')` (ver `backend/auth.php`). En el frontend, `window.USUARIO`
  trae los datos del usuario logueado dentro de los paneles.

---

## Notas de seguridad (Rol C)

- Las contrasenas **nunca** se guardan en texto plano: se hashean con **bcrypt**
  (`pgcrypto` en la BD, `password_verify()` en PHP). Es el equivalente — mas fuerte —
  del requisito "contrasenas con SHA2" del enunciado, adaptado a PostgreSQL + PHP.
- Se registran los intentos de login (exitosos y fallidos) en la tabla `intentoslogin`.
- El control de sesion es por sesiones de PHP; cada panel verifica el rol antes de mostrarse.
