setTimeout(() => {
  const splash = document.getElementById('splash');
  const dlg    = document.getElementById('dialogue');
  splash.classList.add('fade-out');
  setTimeout(() => {
    splash.style.display = 'none';
    dlg.style.display    = 'none';
    document.getElementById('main').style.display = 'flex';
  }, 800);
}, 4200);

document.getElementById('btn-login').addEventListener('click', async () => {
  const rol    = document.getElementById('role').value;
  const vet_id = parseInt(document.getElementById('vet_id').value) || 0;
  const errMsg = document.getElementById('error-msg');
  const btn    = document.getElementById('btn-login');

  if (!rol) {
    errMsg.textContent = 'Selecciona un rol para continuar';
    errMsg.style.display = 'block';
    return;
  }

  if (rol === 'rol_veterinario' && vet_id <= 0) {
    errMsg.textContent = 'El veterinario debe ingresar su ID';
    errMsg.style.display = 'block';
    return;
  }

  errMsg.style.display = 'none';
  btn.disabled = true;
  btn.textContent = 'CONECTANDO...';

  try {
    const res = await fetch(`${CONFIG.API_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ rol, vet_id })
    });

    if (!res.ok) throw new Error('Error al conectar');

    const data = await res.json();
    sessionStorage.setItem('rol', data.rol);
    sessionStorage.setItem('vet_id', data.vet_id);
    window.location.href = 'busqueda.html';

  } catch (e) {
    errMsg.textContent = 'No se pudo conectar con el servidor';
    errMsg.style.display = 'block';
    btn.disabled = false;
    btn.textContent = 'INGRESAR AL SISTEMA';
  }
});