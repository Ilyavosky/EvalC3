from fastapi import HTTPException
from database import get_pool
from schemas.citas import CitaCreate

async def _set_context(conn, rol: str, vet_id: int):
    await conn.execute("SET LOCAL ROLE " + rol)
    await conn.execute("SELECT set_config('app.current_vet_id', $1, TRUE)", str(vet_id))

async def listar(rol: str, vet_id: int):
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.transaction():
            await _set_context(conn, rol, vet_id)
            rows = await conn.fetch("SELECT * FROM citas ORDER BY fecha_hora DESC")
    return [dict(r) for r in rows]

async def agendar(body: CitaCreate, rol: str, vet_id: int):
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.transaction():
            await _set_context(conn, rol, vet_id)
            try:
                row = await conn.fetchrow(
                    "CALL sp_agendar_cita($1, $2, $3, $4, NULL)",
                    body.mascota_id, body.veterinario_id, body.fecha_hora, body.motivo
                )
            except Exception as e:
                raise HTTPException(status_code=400, detail=str(e))
            cita_id = row["p_cita_id"]
            return await conn.fetchrow("SELECT * FROM citas WHERE id = $1", cita_id)