from fastapi import APIRouter, Header, HTTPException
from schemas.citas import CitaCreate, CitaResponse
from services import citas as svc

router = APIRouter()

@router.get("", response_model=list[CitaResponse])
async def listar_citas(
    x_rol: str = Header(...),
    x_vet_id: int = Header(0)
):
    return await svc.listar(x_rol, x_vet_id)

@router.post("", response_model=CitaResponse, status_code=201)
async def agendar_cita(
    body: CitaCreate,
    x_rol: str = Header(...),
    x_vet_id: int = Header(0)
):
    if x_rol not in ("rol_administrador", "rol_veterinario", "rol_recepcionista"):
        raise HTTPException(status_code=403, detail="Sin permiso para agendar citas")
    return await svc.agendar(body, x_rol, x_vet_id)