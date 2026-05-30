
        
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
        
       
        function mostrarTabla(programas, total) {
            const contenedor = document.getElementById('contenido');
            
            if (!programas || programas.length === 0) {
                contenedor.innerHTML = `
                    <div class="info">
                        📭 No hay programas registrados en la base de datos.
                        <br>Agrega programas usando pgAdmin o desde el panel de administración.
                    </div>
                `;
                return;
            }
            
            
            let html = `
                <div class="contador">
                    📊 Total de programas: <strong>${total}</strong>
                </div>
                
                <div class="tabla-container">
                    <table>
                        <thead>
                            <tr>
                                <th># ID</th>
                                <th>Código</th>
                                <th>📖 Nombre del Programa</th>
                                <th>🏛️ Facultad</th>
                                <th>📅 Duración</th>
                            </tr>
                        </thead>
                        <tbody>
            `;
            
            
            for (let programa of programas) {
                html += `
                    <tr>
                        <td><strong>${programa.id_programa}</strong></td>
                        <td>${programa.codigo_programa}</td>
                        <td>${programa.nombre_programa}</td>
                        <td>
                            ${programa.nombre_facultad}
                            <br><small style="color:#888">(${programa.codigo_facultad})</small>
                        </td>
                        <td><span class="badge badge-semestre">${programa.duracion_semestres} semestres</span></td>
                    </tr>
                `;
            }
            
            html += `
                        </tbody>
                    </table>
                </div>
                
                <div class="info" style="margin-top: 20px;">
                    💡 Los datos se obtienen en tiempo real desde PostgreSQL usando PHP
                </div>
            `;
            
            contenedor.innerHTML = html;
        }
        
       
        function mostrarError(mensaje) {
            const contenedor = document.getElementById('contenido');
            contenedor.innerHTML = `
                <div class="error">
                    ❌ <strong>Error al consultar la base de datos:</strong>
                    <br><br>
                    ${mensaje}
                    <br><br>
                    <small>Verifica que:
                        <br>1. PostgreSQL esté corriendo
                        <br>2. La base de datos "universidad" exista
                        <br>3. Las tablas "programas" y "facultades" estén creadas
                        <br>4. La contraseña en listar_programas.php sea correcta
                    </small>
                </div>
            `;
        }
        
        cargarProgramas();