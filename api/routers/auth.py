from fastapi import APIRouter
from schemas.auth import LoginRequest, LoginResponse

router = APIRouter()

@router.post("/login", response_model=LoginResponse)
async def login(body: LoginRequest):
    return LoginResponse(
        rol=body.rol,
        vet_id=body.vet_id,
        message=f"Sesión iniciada como {body.rol}"
    )