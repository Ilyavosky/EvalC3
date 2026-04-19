if (!sessionStorage.getItem('rol')) {
  window.location.replace('login.html');
  throw new Error('Sin sesión');
}

const rol    = sessionStorage.getItem('rol');
const vet_id = parseInt(sessionStorage.getItem('vet_id')) || 0;

document.getElementById('session-badge').textContent = rol.replace('rol_', '').toUpperCase() + (vet_id ? ` #${vet_id}` : '');

function especieBadge(especie) {
  const map = { perro: 'badge-perro', gato: 'badge-gato', conejo: 'badge-conejo' };
  const cls = map[especie.toLowerCase()] || 'badge-normal';
  return `<span class="badge ${cls}">${especie}</span>`;
}

function renderRows(mascotas) {
  const tbody = document.getElementById('results-body');
  document.getElementById('results-count').textContent = mascotas.length;

  if (mascotas.length === 0) {
    tbody.innerHTML = `<tr><td colspan="4"><div class="empty-state"><div class="pb">🔍</div><p>No se encontraron<br>resultados</p></div></td></tr>`;
    return;
  }

  tbody.innerHTML = mascotas.map(m => `
    <tr>
      <td class="muted">#${String(m.id).padStart(4, '0')}</td>
      <td>${m.nombre}</td>
      <td>${especieBadge(m.especie)}</td>
      <td><span class="status-dot ok">Activo</span></td>
    </tr>
  `).join('');
}

function showError(msg) {
  const banner = document.getElementById('error-banner');
  banner.textContent = msg;
  banner.style.display = 'block';
}

function hideError() {
  document.getElementById('error-banner').style.display = 'none';
}

async function cargarMascotas() {
  hideError();
  try {
    const res = await fetch(`${CONFIG.API_URL}/mascotas`, {
      headers: { 'x-rol': rol, 'x-vet-id': String(vet_id) }
    });
    if (!res.ok) throw new Error(`Error ${res.status}`);
    const data = await res.json();
    renderRows(data);
  } catch (e) {
    showError('Error al cargar mascotas. Verifica que la API esté corriendo.');
    document.getElementById('results-body').innerHTML = '';
  }
}

async function buscar() {
  const q = document.getElementById('search-input').value.trim();
  hideError();

  if (!q) {
    cargarMascotas();
    return;
  }

  try {
    const params = new URLSearchParams({ q });
    const res = await fetch(`${CONFIG.API_URL}/mascotas/search?${params}`, {
      headers: { 'x-rol': rol, 'x-vet-id': String(vet_id) }
    });
    if (!res.ok) throw new Error(`Error ${res.status}`);
    const data = await res.json();
    renderRows(data);
  } catch (e) {
    showError('Error en la búsqueda.');
  }
}

document.getElementById('btn-buscar').addEventListener('click', buscar);
document.getElementById('search-input').addEventListener('keydown', e => {
  if (e.key === 'Enter') buscar();
});

cargarMascotas();