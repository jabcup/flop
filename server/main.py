from fastapi import FastAPI, APIRouter
from server.routers.usuarios import router as usuarios_router

app = FastAPI()


app.include_router(usuarios_router)
