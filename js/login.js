/* ============================================================================
 * ROL C - Login y Seguridad (frontend)
 * js/login.js : envia las credenciales a backend/login.php y redirige segun
 * el rol del usuario (admin -> panel_admin, estudiante -> panel_estudiante).
 * ========================================================================== */

const form    = document.getElementById('formLogin');
const cajaErr = document.getElementById('error');
const boton   = document.getElementById('btnEntrar');

form.addEventListener('submit', async (e) => {
    e.preventDefault();
    cajaErr.style.display = 'none';
    boton.disabled = true;
    boton.textContent = 'Entrando...';

    const datos = {
        usuario:  document.getElementById('usuario').value.trim(),
        password: document.getElementById('password').value,
    };

    try {
        const resp = await fetch('backend/login.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(datos),
        });
        const r = await resp.json();

        if (r.success) {
            // Redirige al panel correspondiente segun el rol
            window.location.href = r.redirigir || 'panel_estudiante.html';
        } else {
            mostrarError(r.error || 'No se pudo iniciar sesion');
        }
    } catch (err) {
        mostrarError('No se pudo conectar con el servidor. Verifica que PHP y PostgreSQL esten corriendo.');
    } finally {
        boton.disabled = false;
        boton.textContent = 'Iniciar sesion';
    }
});

function mostrarError(msg) {
    cajaErr.textContent = msg;
    cajaErr.style.display = 'block';
}
