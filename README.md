# Proyecto Final - Sistema de Control Academico

Universidad Mariano Galvez de Guatemala
Ingenieria en Sistemas - Introduccion a los Sistemas de Computo

Base de datos: **PlataformaEstudiantes** (PostgreSQL 18)

## Estado del proyecto

| Rol | Encargado | Estado |
|-----|-----------|--------|
| A - Arquitecto de Base de Datos | (companero) | Estructura lista |
| B - Especialista en SQL y Logica de Datos | (yo) | COMPLETO |
| C - Login y Seguridad | (pendiente) | Por hacer |
| D - Modulos CRUD | (pendiente) | Por hacer |
| E - Academico y Reportes | (pendiente) | Por hacer |

## Avance del Rol B (COMPLETO)

- [x] Datos de prueba (15 estudiantes, 12 materias, 6 profesores, matriculas, asignaciones)
- [x] 15 consultas SQL variadas (WHERE, JOIN, GROUP BY, HAVING, subconsultas, etc.)
- [x] 3 Vistas (promedios, historial academico, cursos por docente)
- [x] 3 Procedimientos almacenados (calcular promedio, inscribir estudiante, contar aprobadas)
- [x] 1 Trigger (actualiza el estado de la matricula automaticamente segun la nota)

## Archivos (en orden de ejecucion)

- `01_estructura.sql` - Crea las 11 tablas con claves y restricciones
- `02_datos_prueba.sql` - Inserta todos los datos de prueba
- `03_consultas.sql` - Las 15 consultas documentadas
- `04_vistas.sql` - Las 3 vistas
- `05_procedimientos.sql` - Los 3 procedimientos almacenados
- `06_trigger.sql` - El trigger (funcion + trigger)

## Como usar

Desde la terminal de Windows (CMD/PowerShell):
```
createdb -U postgres PlataformaEstudiantes
psql -U postgres -d PlataformaEstudiantes -f 01_estructura.sql
psql -U postgres -d PlataformaEstudiantes -f 02_datos_prueba.sql
psql -U postgres -d PlataformaEstudiantes -f 03_consultas.sql
psql -U postgres -d PlataformaEstudiantes -f 04_vistas.sql
psql -U postgres -d PlataformaEstudiantes -f 05_procedimientos.sql
psql -U postgres -d PlataformaEstudiantes -f 06_trigger.sql
```

O desde psql, ya conectado a la base:
```
\i 01_estructura.sql
\i 02_datos_prueba.sql
\i 03_consultas.sql
\i 04_vistas.sql
\i 05_procedimientos.sql
\i 06_trigger.sql
```

## Notas para los companeros

- Las notas usan escala de 0 a 5 (definida por el Rol A en la tabla matriculas).
- Los estados de matricula validos son: Cursando, Aprobada, Reprobada, Cancelada.
- El trigger pone el estado en Aprobada si la nota es >= 3.0, o Reprobada si es menor.
- Vistas disponibles para reportes (Rol E): vista_promedios, vista_historial_academico, vista_cursos_por_docente.
- Procedimientos disponibles: calcular_promedio(id), inscribir_estudiante(id, codigo, periodo), contar_aprobadas(id).
