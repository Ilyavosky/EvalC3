from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from database import get_pool, close_pool
from cache import close_redis
from routers import mascotas, citas, vacunas, auth

@asynccontextmanager
async def lifespan(app: FastAPI):
    await get_pool()
    yield
    await close_pool()
    await close_redis()

app = FastAPI(
    title="Centro Pokémon, la Veterinaria para tus mascotas",
    description="API para el sistema de clínica veterinaria con temática Pokémon",
    version="1.0.0",
    lifespan=lifespan
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://127.0.0.1:5500"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router,     prefix="/auth",     tags=["Auth"])
app.include_router(mascotas.router, prefix="/mascotas", tags=["Mascotas"])
app.include_router(citas.router,    prefix="/citas",    tags=["Citas"])
app.include_router(vacunas.router,  prefix="/vacunas",  tags=["Vacunas"])

@app.get("/health", tags=["Health"])
async def health():
    return {"status": "ok"}