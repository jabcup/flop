from fastapi import APIRouter, HTTPException
import pyodbc
from server.utils.conection import get_admin_connection as aconn
from server.schemas.mesa_schemas import (
    MesaCrear,
    MesaUnirse,
    MesaSalir,
    PartidaIniciar,
    PartidaConectarUsuario,
    PartidaTerminar,
    TipoAccionCrear,
)

router = APIRouter(prefix="/juego", tags=["juego"])

# ------------------------------------------------------------
# Endpoints de Mesa
# ------------------------------------------------------------


@router.get("/mesa/buscar/{id_mesa}")
def buscar_mesa_id(id_mesa: int):
    try:
        conn = aconn()
        cursor = conn.cursor()
        cursor.execute("EXEC sp_codigo_mesa @idMesa=?", id_mesa)
        result = cursor.fetchone()
        cursor.close()
        if result:
            return {"resultado": list(result)}
        else:
            return {"result": "no se encontró nada che"}
    except pyodbc.Error as e:
        raise HTTPException(
            status_code=400, detail=f"error en el endpoint buscar_mesa_id: {e}"
        )


@router.get("/mesa/hora-inicio/{id_mesa}")
def hora_inicio_mesa(id_mesa: int):
    try:
        conn = aconn()
        cursor = conn.cursor()
        cursor.execute("EXEC sp_hora_inicio_mesa @idMesa=?", id_mesa)
        result = cursor.fetchone()
        cursor.close()
        if result:
            return {"resultado": list(result)}
        else:
            raise HTTPException(status_code=404, detail="Mesa no encontrada")
    except pyodbc.Error as e:
        raise HTTPException(status_code=400, detail=f"error en hora_inicio_mesa: {e}")


@router.get("/mesa/estado/{id_mesa}")
def estado_mesa(id_mesa: int):
    try:
        conn = aconn()
        cursor = conn.cursor()
        cursor.execute("EXEC sp_obtener_estado_mesa @idMesa=?", id_mesa)
        result = cursor.fetchone()
        cursor.close()
        if result:
            return {"resultado": list(result)}
        else:
            raise HTTPException(status_code=404, detail="Mesa no encontrada")
    except pyodbc.Error as e:
        raise HTTPException(status_code=400, detail=f"error en estado_mesa: {e}")


@router.get("/mesa/jugadores/{id_mesa}")
def jugadores_mesa(id_mesa: int):
    try:
        conn = aconn()
        cursor = conn.cursor()
        cursor.execute("EXEC sp_lista_jugadores_mesa @idMesa=?", id_mesa)
        jugadores = cursor.fetchall()
        cursor.close()
        return {"resultado": [list(j) for j in jugadores]}
    except pyodbc.Error as e:
        raise HTTPException(status_code=400, detail=f"error en jugadores_mesa: {e}")


@router.get("/mesa/validar-codigo/{codigo}")
def validar_codigo_mesa(codigo: str):
    try:
        conn = aconn()
        cursor = conn.cursor()
        cursor.execute("EXEC sp_verificar_validez_mesa @codigo=?", codigo)
        result = cursor.fetchone()
        cursor.close()
        if result:
            return {"resultado": list(result)}
        else:
            raise HTTPException(status_code=404, detail="Código de mesa no válido")
    except pyodbc.Error as e:
        raise HTTPException(
            status_code=400, detail=f"error en validar_codigo_mesa: {e}"
        )


@router.get("/mesa/activas")
def listar_mesas_activas():
    try:
        conn = aconn()
        cursor = conn.cursor()
        cursor.execute("EXEC sp_listar_mesas_activas")
        mesas = cursor.fetchall()
        cursor.close()
        return {"resultado": [list(m) for m in mesas]}
    except pyodbc.Error as e:
        raise HTTPException(
            status_code=400, detail=f"error en listar_mesas_activas: {e}"
        )


@router.post("/mesa/crear")
def crear_mesa(payload: MesaCrear):
    try:
        conn = aconn()
        cursor = conn.cursor()
        cursor.execute(
            "EXEC sp_crear_mesa @idUsuario=?, @codigo=?",
            payload.idUsuario,
            payload.codigo,
        )
        conn.commit()
        cursor.close()
        return {"resultado": "ok"}
    except pyodbc.Error as e:
        raise HTTPException(status_code=400, detail=f"error en crear_mesa: {e}")


@router.post("/mesa/unirse")
def unir_jugador_mesa(payload: MesaUnirse):
    try:
        conn = aconn()
        cursor = conn.cursor()
        cursor.execute(
            "EXEC sp_unir_jugador_mesa @idUsuario=?, @idMesa=?",
            payload.idUsuario,
            payload.idMesa,
        )
        conn.commit()
        cursor.close()
        return {"resultado": "ok"}
    except pyodbc.Error as e:
        raise HTTPException(status_code=400, detail=f"error en unir_jugador_mesa: {e}")


@router.post("/mesa/salir")
def jugador_salir_mesa(payload: MesaSalir):
    try:
        conn = aconn()
        cursor = conn.cursor()
        cursor.execute(
            "EXEC sp_jugador_salir_mesa @idUsuario=?, @idMesa=?",
            payload.idUsuario,
            payload.idMesa,
        )
        conn.commit()
        cursor.close()
        return {"resultado": "ok"}
    except pyodbc.Error as e:
        raise HTTPException(status_code=400, detail=f"error en jugador_salir_mesa: {e}")


@router.put("/mesa/terminar/{id_mesa}")
def terminar_mesa(id_mesa: int):
    try:
        conn = aconn()
        cursor = conn.cursor()
        cursor.execute("EXEC sp_terminar_mesa @idMesa=?", id_mesa)
        conn.commit()
        cursor.close()
        return {"resultado": "ok"}
    except pyodbc.Error as e:
        raise HTTPException(status_code=400, detail=f"error en terminar_mesa: {e}")


# ------------------------------------------------------------
# Endpoints de Partida
# ------------------------------------------------------------


@router.get("/partida/activa/{id_mesa}")
def verificar_partida_activa(id_mesa: int):
    """
    Atención: este SP solo imprime mensajes y no devuelve filas.
    Si no hay partida activa, Python no recibe datos y lanzará
    'No results'. Se recomienda modificar el SP para que devuelva
    un SELECT con el estado.
    """
    try:
        conn = aconn()
        cursor = conn.cursor()
        cursor.execute("EXEC sp_verificar_partida_activa @idMesa=?", id_mesa)
        # No intentamos fetch porque no hay SELECT,
        # simplemente asumimos éxito si no hubo excepción.
        cursor.close()
        return {"mensaje": "consulta ejecutada"}
    except pyodbc.Error as e:
        raise HTTPException(
            status_code=400, detail=f"error en verificar_partida_activa: {e}"
        )


@router.post("/partida/iniciar")
def iniciar_partida(payload: PartidaIniciar):
    try:
        conn = aconn()
        cursor = conn.cursor()
        cursor.execute("EXEC sp_iniciar_partida @idMesa=?", payload.idMesa)
        conn.commit()
        cursor.close()
        return {"resultado": "ok"}
    except pyodbc.Error as e:
        raise HTTPException(status_code=400, detail=f"error en iniciar_partida: {e}")


@router.post("/partida/conectar-usuario")
def conectar_usuario_partida(payload: PartidaConectarUsuario):
    try:
        conn = aconn()
        cursor = conn.cursor()
        cursor.execute(
            "EXEC sp_conectar_usuario_partida @idUsuario=?, @idPartida=?, @montoInicial=?",
            payload.idUsuario,
            payload.idPartida,
            payload.montoInicial,
        )
        conn.commit()
        cursor.close()
        return {"resultado": "ok"}
    except pyodbc.Error as e:
        raise HTTPException(
            status_code=400, detail=f"error en conectar_usuario_partida: {e}"
        )


@router.put("/partida/terminar")
def terminar_partida(payload: PartidaTerminar):
    try:
        conn = aconn()
        cursor = conn.cursor()
        cursor.execute(
            "EXEC sp_terminar_partida @idPartida=?, @montoFinal=?",
            payload.idPartida,
            payload.montoFinal,
        )
        conn.commit()
        cursor.close()
        return {"resultado": "ok"}
    except pyodbc.Error as e:
        raise HTTPException(status_code=400, detail=f"error en terminar_partida: {e}")


# ------------------------------------------------------------
# Endpoints de Acciones y Tipos
# ------------------------------------------------------------


@router.get("/accion/ultima/{id_partida}")
def consultar_ultima_accion(id_partida: int):
    try:
        conn = aconn()
        cursor = conn.cursor()
        cursor.execute("EXEC sp_consultar_ultima_accion @idPartida=?", id_partida)
        result = cursor.fetchone()
        cursor.close()
        if result:
            return {"resultado": list(result)}
        else:
            return {"resultado": []}
    except pyodbc.Error as e:
        raise HTTPException(
            status_code=400, detail=f"error en consultar_ultima_accion: {e}"
        )


@router.post("/tipo-accion/crear")
def crear_tipo_accion(payload: TipoAccionCrear):
    try:
        conn = aconn()
        cursor = conn.cursor()
        cursor.execute("EXEC sp_crear_tipo_accion @nombre=?", payload.nombre)
        conn.commit()
        cursor.close()
        return {"resultado": "ok"}
    except pyodbc.Error as e:
        raise HTTPException(status_code=400, detail=f"error en crear_tipo_accion: {e}")
