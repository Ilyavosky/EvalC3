from pydantic import BaseModel, Field
from typing import Optional
from datetime import date

class VacunaAplicarCreate(BaseModel):
    mascota_id: int = Field(..., gt=0)
    vacuna_id: int = Field(..., gt=0)
    fecha_aplicacion: Optional[date] = None
    costo_cobrado: Optional[float] = None

class VacunaPendienteResponse(BaseModel):
    mascota_id: int
    mascota: str
    especie: str
    dueno: str
    telefono: Optional[str]
    ultima_vacuna: Optional[date]