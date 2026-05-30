async function cargarEstudiantes() {
            try {
                let respuesta = await fetch('backend/estudiantes.php?accion=listar');
                let estudiantes = await respuesta.json();
                
                let tbody = document.getElementById('cuerpoTabla');
                tbody.innerHTML = '';
                
                if(estudiantes.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="8">No hay estudiantes registrados</td></tr>';
                    return;
                }
                
                for(let est of estudiantes) {
                    tbody.innerHTML += `
                        <tr>
                            <td>${est.id_estudiante}</td>
                            <td>${est.numero_identificacion}</td>
                            <td>${est.nombres}</td>
                            <td>${est.apellidos}</td>
                            <td>${est.email_institucional}</td>
                            <td>${est.nombre_programa || 'N/A'}</td>
                            <td>${est.semestre_actual}</td>
                            <td>
                                <button class="btn btn-primary" onclick="editarEstudiante(${est.id_estudiante})">✏️</button>
                                <button class="btn btn-danger" onclick="eliminarEstudiante(${est.id_estudiante})">🗑️</button>
                            </td>
                        </tr>
                    `;
                }
            } catch(error) {
                console.error('Error:', error);
                document.getElementById('cuerpoTabla').innerHTML = '<tr><td colspan="8">Error al cargar datos</td></tr>';
            }
        }
        
        function mostrarFormularioAgregar() {
            document.getElementById('formularioAgregar').style.display = 'block';
        }
        
        function ocultarFormulario() {
            document.getElementById('formularioAgregar').style.display = 'none';
            document.getElementById('mensaje').innerHTML = '';
        }
        
        async function agregarEstudiante() {
            let datos = {
                numero_identificacion: document.getElementById('numIdentificacion').value,
                nombres: document.getElementById('nombres').value,
                apellidos: document.getElementById('apellidos').value,
                email_institucional: document.getElementById('emailInstitucional').value,
                fecha_nacimiento: document.getElementById('fechaNacimiento').value,
                id_programa: document.getElementById('idPrograma').value,
                semestre_actual: document.getElementById('semestreActual').value
            };
            
            try {
                let respuesta = await fetch('backend/estudiantes.php?accion=agregar', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify(datos)
                });
                
                let resultado = await respuesta.json();
                
                if(resultado.exito) {
                    document.getElementById('mensaje').innerHTML = '<div class="mensaje exito">✅ Estudiante agregado correctamente</div>';
                    ocultarFormulario();
                    cargarEstudiantes();
                 
                    document.getElementById('numIdentificacion').value = '';
                    document.getElementById('nombres').value = '';
                    document.getElementById('apellidos').value = '';
                    document.getElementById('emailInstitucional').value = '';
                    document.getElementById('fechaNacimiento').value = '';
                    document.getElementById('semestreActual').value = '';
                } else {
                    document.getElementById('mensaje').innerHTML = `<div class="mensaje error">❌ ${resultado.error}</div>`;
                }
            } catch(error) {
                document.getElementById('mensaje').innerHTML = '<div class="mensaje error">❌ Error al conectar con el servidor</div>';
            }
        }
        
        async function eliminarEstudiante(id) {
            if(confirm('¿Estás seguro de eliminar este estudiante?')) {
                try {
                    let respuesta = await fetch(`backend/estudiantes.php?accion=eliminar&id=${id}`, {
                        method: 'DELETE'
                    });
                    let resultado = await respuesta.json();
                    
                    if(resultado.exito) {
                        cargarEstudiantes();
                    } else {
                        alert('Error: ' + resultado.error);
                    }
                } catch(error) {
                    alert('Error al eliminar');
                }
            }
        }
         async function cargarProgramas() {
            const contenedor = document.getElementById('contenido');
            
           
            contenedor.innerHTML = '<div class="loading">Cargando programas desde la base de datos...</div>';
            
            try {
               
                const respuesta = await fetch('backend/listar_programas.php');
                const resultado = await respuesta.json();
                
                if (!respuesta.ok) {
                    throw new Error(`Error HTTP: ${respuesta.status}`);
                }
                
                if (resultado.success) {
                    mostrarTabla(resultado.data, resultado.total);
                } else {
                    mostrarError(resultado.error);
                }
                
            } catch(error) {
                console.error('Error:', error);
                mostrarError('No se pudo conectar con el servidor. Verifica que Apache y PostgreSQL estén corriendo.');
            }
        }
        
  
        cargarEstudiantes();
   