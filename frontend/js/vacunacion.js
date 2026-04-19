const rol    = sessionStorage.getItem('rol') || 'rol_administrador';
  const vet_id = parseInt(sessionStorage.getItem('vet_id')) || 0;

  document.getElementById('session-badge').textContent = rol.replace('rol_', '').toUpperCase() + (vet_id ? ` #${vet_id}` : '');

  function renderRows(data) {
    const tbody = document.getElementById('vac-table-body');
    let sinVacuna = 0, vencidas = 0;

    if (data.length === 0) {
      tbody.innerHTML = `<tr><td colspan="6"><div class="empty-state"><div class="pb">💉</div><p>No hay pacientes<br>pendientes</p></div></td></tr>`;
    } else {
      tbody.innerHTML = data.map(m => {
        const sinVac = !m.ultima_vacuna;
        if (sinVac) sinVacuna++; else vencidas++;
        const badge = sinVac
          ? `<span class="badge badge-sin-vacuna">Sin vacuna</span>`
          : `<span class="badge badge-vencida">Vencida</span>`;
        const ultima = m.ultima_vacuna || '—';
        return `
          <tr>
            <td class="muted">#${String(m.mascota_id).padStart(4,'0')}</td>
            <td><strong>${m.mascota}</strong><br><span class="muted">${m.especie}</span></td>
            <td class="muted">${m.dueno}</td>
            <td class="muted">${m.telefono || '—'}</td>
            <td>${badge}</td>
            <td class="muted">${ultima}</td>
          </tr>`;
      }).join('');
    }

    document.getElementById('stat-total').textContent    = data.length;
    document.getElementById('stat-sin').textContent      = sinVacuna;
    document.getElementById('stat-vencidas').textContent = vencidas;
  }

  async function cargarPendientes(showToast = false) {
    const cacheBadge   = document.getElementById('cache-badge');
    const latencyLabel = document.getElementById('latency-label');

    cacheBadge.textContent = 'CARGANDO...';
    cacheBadge.className   = 'cache-badge loading';
    latencyLabel.textContent = '';

    const t0 = performance.now();
    try {
      const res = await fetch(`${CONFIG.API_URL}/vacunas/pendientes`, {
        headers: { 'x-rol': rol, 'x-vet-id': String(vet_id) }
      });
      const elapsed = Math.round(performance.now() - t0);

      if (!res.ok) throw new Error(`Error ${res.status}`);
      const data = await res.json();

      const isHit = elapsed < 50;
      cacheBadge.textContent = isHit ? '⚡ CACHE HIT' : '🔄 CACHE MISS';
      cacheBadge.className   = `cache-badge ${isHit ? 'hit' : 'miss'}`;
      latencyLabel.textContent = `${elapsed}ms`;

      renderRows(data);

      if (showToast) {
        const toast = document.getElementById('toast');
        toast.classList.add('show');
        setTimeout(() => toast.classList.remove('show'), 2800);
      }
    } catch (e) {
      cacheBadge.textContent = 'ERROR';
      cacheBadge.className   = 'cache-badge miss';
      document.getElementById('vac-table-body').innerHTML =
        `<tr><td colspan="6" style="text-align:center;padding:32px;color:var(--red);font-weight:700;">Error al conectar con la API</td></tr>`;
    }
  }

  document.getElementById('btn-refresh').addEventListener('click', () => cargarPendientes(true));

  cargarPendientes();