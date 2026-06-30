from fastapi import APIRouter, HTTPException
import pyodbc
from server.utils.conection import get_admin_connection as aconn
from server.schemas.usuarios_schemas import (
    UsuarioRegistrar,
    UsuarioAcceder,
    UsuarioActualizar,
    CambiarClave,
)
from typing import List

router = APIRouter(prefix="/usuarios", tags=["usuarios"])


@router.post("/registro")
def registrar_usuario(payload: UsuarioRegistrar):
    try:
        conn = aconn()
        cursor = conn.cursor()

        cursor.execute(
            "EXEC sp_registrar_usuario @nombre=?, @email=?, @clave=?",
            payload.nombre,
            payload.email,
            payload.clave,
        )

        conn.commit()
        cursor.close()
        return {"resultado": "ok"}
    except pyodbc.Error as e:
        raise HTTPException(
            status_code=400, detail=f"error en el endpoint de registrar usuario: {e}"
        )


@router.post("/acceder")
def acceder(payload: UsuarioAcceder):
    try:
        conn = aconn()
        cursor = conn.cursor()

        cursor.execute(
            "EXEC sp_validar_login @email=?, @clave=?",
            payload.email,
            payload.clave,
        )

        resultado = cursor.fetchone()
        cursor.close()

        if resultado:
            return {"resultado": list(resultado)}
        else:
            raise HTTPException(status_code=404, detail="No se encontró nada")
    except pyodbc.Error as e:
        raise HTTPException(
            status_code=400, detail=f"Error en el endpoint de validar login: {e}"
        )


@router.get("/")
def listar_usuarios():
    try:
        conn = aconn()
        cursor = conn.cursor()

        cursor.execute("EXEC sp_listar_usuarios")
        usuarios = cursor.fetchall()
        cursor.close()

        # Convertir cada Row a lista para serializar
        return {"resultado": [list(u) for u in usuarios]}
    except pyodbc.Error as e:
        raise HTTPException(status_code=400, detail=f"Error al listar usuarios: {e}")


@router.get("/{id_usuario}")
def obtener_usuario(id_usuario: int):
    try:
        conn = aconn()
        cursor = conn.cursor()

        cursor.execute("EXEC sp_obtener_usuario_id @id=?", id_usuario)
        usuario = cursor.fetchone()
        cursor.close()

        if usuario:
            return {"resultado": list(usuario)}
        else:
            raise HTTPException(status_code=404, detail="Usuario no encontrado")
    except pyodbc.Error as e:
        raise HTTPException(status_code=400, detail=f"Error al obtener usuario: {e}")


@router.put("/{id_usuario}")
def actualizar_datos(id_usuario: int, payload: UsuarioActualizar):
    try:
        conn = aconn()
        cursor = conn.cursor()

        cursor.execute(
            "EXEC sp_actualizar_datos_personales @id=?, @nombre=?, @email=?",
            id_usuario,
            payload.nombre,
            payload.email,
        )

        conn.commit()
        cursor.close()
        return {"resultado": "ok"}
    except pyodbc.Error as e:
        raise HTTPException(status_code=400, detail=f"Error al actualizar datos: {e}")


@router.put("/{id_usuario}/cambiar-clave")
def cambiar_clave(id_usuario: int, payload: CambiarClave):
    try:
        conn = aconn()
        cursor = conn.cursor()

        cursor.execute(
            "EXEC sp_cambiar_clave @id=?, @clave_actual=?, @clave_nueva=?",
            id_usuario,
            payload.clave_actual,
            payload.clave_nueva,
        )

        conn.commit()
        cursor.close()
        return {"resultado": "ok"}
    except pyodbc.Error as e:
        raise HTTPException(status_code=400, detail=f"Error al cambiar clave: {e}")


@router.put("/{id_usuario}/activar")
def activar_usuario(id_usuario: int):
    try:
        conn = aconn()
        cursor = conn.cursor()

        cursor.execute("EXEC sp_activar_usuario @id=?", id_usuario)
        conn.commit()
        cursor.close()
        return {"resultado": "ok"}
    except pyodbc.Error as e:
        raise HTTPException(status_code=400, detail=f"Error al activar usuario: {e}")


@router.put("/{id_usuario}/desactivar")
def desactivar_usuario(id_usuario: int):
    try:
        conn = aconn()
        cursor = conn.cursor()

        cursor.execute("EXEC sp_desactivar_usuario @id=?", id_usuario)
        conn.commit()
        cursor.close()
        return {"resultado": "ok"}
    except pyodbc.Error as e:
        raise HTTPException(status_code=400, detail=f"Error al desactivar usuario: {e}")
