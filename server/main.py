from fastapi import FastAPI, APIRouter
from server.routers.usuarios import router as usuarios_router
from server.routers.juego import router as juego_router
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(usuarios_router)
app.include_router(juego_router)
