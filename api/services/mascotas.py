from fastapi import HTTPException
from database import get_pool
from schemas.mascotas import MascotaCreate

async def _set_context(conn, rol: str, vet_id: int):
    await conn.execute("SET LOCAL ROLE " + rol)
    await conn.execute("SELECT set_config('app.current_vet_id', $1, TRUE)", str(vet_id))

async def listar(rol: str, vet_id: int):
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.transaction():
            await _set_context(conn, rol, vet_id)
            rows = await conn.fetch("SELECT * FROM mascotas WHERE activo = TRUE")
    return [dict(r) for r in rows]

async def buscar(q: str, rol: str, vet_id: int):
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.transaction():
            await _set_context(conn, rol, vet_id)
            rows = await conn.fetch(
                "SELECT * FROM mascotas WHERE activo = TRUE AND nombre ILIKE $1",
                f"%{q}%"
            )
    return [dict(r) for r in rows]

async def registrar(body: MascotaCreate, rol: str, vet_id: int):
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.transaction():
            await _set_context(conn, rol, vet_id)
            try:
                row = await conn.fetchrow(
                    "CALL sp_registrar_mascota($1, $2, $3, $4, NULL)",
                    body.nombre, body.especie, body.fecha_nacimiento, body.dueno_id
                )
            except Exception as e:
                raise HTTPException(status_code=400, detail=str(e))
            mascota_id = row["p_mascota_id"]
            return await conn.fetchrow("SELECT * FROM mascotas WHERE id = $1", mascota_id)

async def dar_baja(mascota_id: int, rol: str, vet_id: int):
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.transaction():
            await _set_context(conn, rol, vet_id)
            try:
                await conn.execute("CALL sp_dar_baja_mascota($1)", mascota_id)
            except Exception as e:
                raise HTTPException(status_code=400, detail=str(e))
    return {"message": f"Mascota {mascota_id} dada de baja correctamente"}