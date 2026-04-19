from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class CitaCreate(BaseModel):
    mascota_id: int = Field(..., gt=0)
    veterinario_id: int = Field(..., gt=0)
    fecha_hora: datetime
    motivo: Optional[str] = None

class CitaResponse(BaseModel):
    id: int
    mascota_id: int
    veterinario_id: int
    fecha_hora: datetime
    motivo: Optional[str]
    costo: Optional[float]
    estado: str