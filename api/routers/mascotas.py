from fastapi import APIRouter, Header, HTTPException, Query
from typing import Optional
from schemas.mascotas import MascotaCreate, MascotaResponse
from services import mascotas as svc

router = APIRouter()

@router.get("", response_model=list[MascotaResponse])
async def listar_mascotas(
    x_rol: str = Header(...),
    x_vet_id: int = Header(0)
):
    return await svc.listar(x_rol, x_vet_id)

@router.get("/search", response_model=list[MascotaResponse])
async def buscar_mascotas(
    q: str = Query(..., min_length=1),
    x_rol: str = Header(...),
    x_vet_id: int = Header(0)
):
    return await svc.buscar(q, x_rol, x_vet_id)

@router.post("", response_model=MascotaResponse, status_code=201)
async def registrar_mascota(
    body: MascotaCreate,
    x_rol: str = Header(...),
    x_vet_id: int = Header(0)
):
    if x_rol not in ("rol_administrador", "rol_veterinario", "rol_recepcionista"):
        raise HTTPException(status_code=403, detail="Sin permiso para registrar mascotas")
    return await svc.registrar(body, x_rol, x_vet_id)

@router.delete("/{mascota_id}", status_code=200)
async def dar_baja_mascota(
    mascota_id: int,
    x_rol: str = Header(...),
    x_vet_id: int = Header(0)
):
    if x_rol != "rol_administrador":
        raise HTTPException(status_code=403, detail="Solo el administrador puede dar de baja mascotas")
    return await svc.dar_baja(mascota_id, x_rol, x_vet_id)