/* ============================================================================
 * ROL C - Control de sesion en los paneles (frontend)
 * js/panel.js : protege las paginas de panel. Si no hay sesion, redirige al
 * login. Si el rol no coincide con el panel, tambien. Muestra el nombre del
 * usuario y conecta el boton de cerrar sesion.
 *
 * Uso en cada panel:  <body data-rol="admin">  o  data-rol="estudiante"
 * ========================================================================== */

(async function protegerPanel() {
    const rolRequerido = document.body.dataset.rol;   // 'admin' o 'estudiante'

    try {
        const resp = await fetch('backend/sesion_actual.php');
        const r = await resp.json();

        if (!r.autenticado) {
            window.location.href = 'login.html';
            return;
        }

        // Si el rol no corresponde a este panel, mandar al panel correcto
        if (rolRequerido && r.usuario.rol !== rolRequerido) {
            window.location.href = (r.usuario.rol === 'admin')
                ? 'panel_admin.html' : 'panel_estudiante.html';
            return;
        }

        // Mostrar el nombre del usuario en la barra
        const span = document.getElementById('nombreUsuario');
        if (span) span.textContent = r.usuario.nombre_completo + ' (' + r.usuario.rol + ')';

        // Dejar disponibles los datos del usuario para Rol D y Rol E
        window.USUARIO = r.usuario;
        document.body.classList.add('listo');
    } catch (err) {
        window.location.href = 'login.html';
    }
})();

async function cerrarSesion() {
    try { await fetch('backend/logout.php'); } catch (e) {}
    window.location.href = 'login.html';
}
