from fastapi import APIRouter, Header, HTTPException
from schemas.vacunas import VacunaAplicarCreate, VacunaPendienteResponse
from services import vacunas as svc

router = APIRouter()

@router.get("/pendientes", response_model=list[VacunaPendienteResponse])
async def vacunacion_pendiente(
    x_rol: str = Header(...),
    x_vet_id: int = Header(0)
):
    return await svc.pendientes(x_rol, x_vet_id)

@router.post("/aplicar", status_code=201)
async def aplicar_vacuna(
    body: VacunaAplicarCreate,
    x_rol: str = Header(...),
    x_vet_id: int = Header(0)
):
    if x_rol not in ("rol_administrador", "rol_veterinario"):
        raise HTTPException(status_code=403, detail="Sin permiso para aplicar vacunas")
    return await svc.aplicar(body, x_rol, x_vet_id)