from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

# --- Operaciones de mesa ---


class MesaCrear(BaseModel):
    idUsuario: int
    codigo: str = Field(max_length=8)


class MesaUnirse(BaseModel):
    idUsuario: int
    idMesa: int


class MesaSalir(BaseModel):
    idUsuario: int
    idMesa: int


# --- Operaciones de partida ---


class PartidaIniciar(BaseModel):
    idMesa: int


class PartidaConectarUsuario(BaseModel):
    idUsuario: int
    idPartida: int
    montoInicial: float


class PartidaTerminar(BaseModel):
    idPartida: int
    montoFinal: float


# --- Acciones ---


class TipoAccionCrear(BaseModel):
    nombre: str = Field(max_length=50)
