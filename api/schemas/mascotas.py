from pydantic import BaseModel, Field
from typing import Optional
from datetime import date

class MascotaCreate(BaseModel):
    nombre: str = Field(..., min_length=1, max_length=50)
    especie: str = Field(..., min_length=1, max_length=30)
    fecha_nacimiento: Optional[date] = None
    dueno_id: int = Field(..., gt=0)

class MascotaResponse(BaseModel):
    id: int
    nombre: str
    especie: str
    fecha_nacimiento: Optional[date]
    dueno_id: int
    activo: bool