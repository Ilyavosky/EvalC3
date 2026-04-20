# Centro Pokémon — Veterinaria
**Base de Datos Avanzadas · Corte 3 del 5to Cuatrimestre · UP Chiapas · Abril 2026**
**Ilya Cortés Ruiz #243710**

Sistema full-stack de clínica veterinaria con temática Pokémon. Implementa seguridad de base de datos como eje central: roles y permisos, Row-Level Security, caché con Redis y hardening contra SQL Injection.

---

## Stack

- **Base de datos:** PostgreSQL 16
- **Caché:** Redis 7
- **Backend:** FastAPI (Python) + asyncpg
- **Frontend:** HTML + CSS + JS plano
- **Contenedores:** Docker + Docker Compose

---

## Estructura del proyecto

```
EvalC3/
├── migrations/          # SQL ejecutado en orden al iniciar Docker
│   ├── 01_schema.sql    # Tablas y datos de prueba
│   ├── 02_roles.sql     # Creación de roles PostgreSQL
│   ├── 03_procedures.sql# Procedures y funciones
│   ├── 04_triggers.sql  # Triggers de historial
│   ├── 05_views.sql     # Vista de vacunación pendiente
│   ├── 06_rls.sql       # Políticas Row-Level Security
│   └── 07_grants.sql    # Permisos por rol
├── api/                 # Backend FastAPI
│   ├── main.py          # App principal + CORS + lifespan
│   ├── database.py      # Pool de conexiones asyncpg
│   ├── cache.py         # Cliente Redis
│   ├── routers/         # Endpoints HTTP
│   ├── services/        # Lógica de negocio + queries
│   └── schemas/         # Contratos Pydantic entrada/salida
├── frontend/            # Tres pantallas HTML
├── screenshots/         # Evidencia de pruebas
├── cuaderno_ataques.md  # Demostración de ataques SQL Injection
└── docker-compose.yml   # PostgreSQL + Redis
```

---

## Instalación y ejecución

### Requisitos
- Docker Desktop
- Python 3.12+

### 1. Clonar el repositorio
```bash
git clone https://github.com/Ilyavosky/EvalC3.git
cd EvalC3
```

### 2. Crear el archivo `.env` en la raíz
```env
Credenciales acá
```

### 3. Crear el archivo `api/.env`
```env
Credenciales acá
```

### 4. Levantar la base de datos y Redis
```bash
docker compose up -d
```

### 5. Instalar dependencias de la API
```bash
cd api
python -m venv venv
source venv/Scripts/activate
pip install -r requirements.txt
```

### 6. Levantar la API
```bash
fastapi dev main.py
```

### 7. Levantar el frontend
```bash
cd frontend
python -m http.server 3000
```

### 8. Abrir en el browser
```
http://localhost:3000/login.html
```

---

## Endpoints principales

| Método | Endpoint | Descripción |
|---|---|---|
| POST | `/auth/login` | Iniciar sesión con rol y vet_id |
| GET | `/mascotas` | Listar mascotas (filtradas por RLS) |
| GET | `/mascotas/search?q=` | Buscar por nombre |
| POST | `/mascotas` | Registrar mascota |
| DELETE | `/mascotas/{id}` | Dar de baja mascota |
| GET | `/citas` | Listar citas |
| POST | `/citas` | Agendar cita |
| GET | `/vacunas/pendientes` | Vacunación pendiente (cacheada) |
| POST | `/vacunas/aplicar` | Aplicar vacuna + invalida caché |

Documentación interactiva disponible en `http://localhost:8000/docs`

---

## Roles del sistema

| Rol | Permisos |
|---|---|
| `rol_administrador` | Todo — CRUD completo sobre todas las tablas |
| `rol_veterinario` | SELECT en sus mascotas (RLS), INSERT en citas y vacunas |
| `rol_recepcionista` | SELECT en mascotas y citas, INSERT en citas y mascotas |

---

## Documento de decisiones de diseño
 
### Pregunta 1 — Política RLS sobre `mascotas`
 
```sql
CREATE POLICY pol_mascotas_vet ON mascotas
FOR SELECT TO rol_veterinario
USING (
    id IN (
        SELECT mascota_id FROM vet_atiende_mascota
        WHERE vet_id = current_setting('app.current_vet_id')::INT
    )
);
```
 
Cuando los usuarios con el rol de veterinario quieren consultar las `mascotas`, PostgreSQL se dedica a verificar fila por fila si esa mascota le pertenece a dicho veterinario. Solo pasan las que están asignadas a ese veterinario en `vet_atiende_mascota`. El backend le dice a PostgreSQL qué veterinario es al inicio de cada transacción usando `current_setting('app.current_vet_id')`.
 
---
 
### Pregunta 2 — Vector de ataque en la identificación del veterinario
 
El backend recibe el `vet_id` en el header `x-vet-id`. Si un atacante quiere vulnearar la app,  podría enviar un ID ajeno y ver mascotas de otro veterinario.
 
El sistema evita esto de dos formas: Pydantic valida que el valor sea un entero, rechazando cualquier otro tipo.
Aunque el atacante envíe un ID válido de otro veterinario, la política RLS solo le mostraría las mascotas de ese ID — nunca acceso total.
 
---
 
### Pregunta 3 — SECURITY DEFINER
 
No usé SECURITY DEFINER. Los procedures se ejecutan con los permisos del rol que los llama, y es suficiente porque cada rol tiene exactamente los permisos que necesita en `07_grants.sql`. 
Investigando también me enteré de que puede llevar a fallas de seguridad y de inyecciones SQL; https://www.cybertec-postgresql.com/en/abusing-security-definer-functions/

 
---
 
### Pregunta 4 — TTL del caché Redis
 
**TTL elegido: 300 segundos (5 minutos).**
 
La vista `v_mascotas_vacunacion_pendiente` recorre todas las mascotas y sus vacunas — es la consulta más complicada del MVP. Como esos datos no cambian cada segundo, 5 minutos es un balance razonable.
 
- TTL muy bajo (5s): el caché no sirve de nada, cada consulta va a la BD.
- TTL muy alto (1h): un paciente recién vacunado sigue apareciendo como pendiente.
Además, cuando se aplica una vacuna el sistema borra el caché inmediatamente.
 
---
 
### Pregunta 5 — Línea exacta que previene SQL Injection
 
**Archivo:** `api/services/mascotas.py` — función `buscar()`:
 
```python
rows = await conn.fetch(
    "SELECT * FROM mascotas WHERE activo = TRUE AND nombre ILIKE $1",
    f"%{q}%"
)
```
 
El `$1` separa la query del dato del usuario. PostgreSQL recibe la estructura del SQL primero y el valor del usuario después. Cualquier intento de inyección llega como texto a buscar, no como código a ejecutar.
 
---
 
### Pregunta 6 — Operaciones que se romperían sin permisos del veterinario
 
Si se revocan todos los permisos del `rol_veterinario` excepto `SELECT` en `mascotas`:
 
1. **Agendar citas** — requiere `INSERT` en `citas` y `EXECUTE` en `sp_agendar_cita`. El endpoint `POST /citas` fallaría con error de permisos.
2. **Aplicar vacunas** — requiere `INSERT` en `vacunas_aplicadas`. El endpoint `POST /vacunas/aplicar` fallaría y el caché nunca se invalidaría.
3. **Ver vacunación pendiente** — requiere `SELECT` en `v_mascotas_vacunacion_pendiente`. El endpoint `GET /vacunas/pendientes` fallaría aunque el caché tenga datos.
