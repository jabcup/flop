from random import randint
from fastapi import APIRouter, HTTPException
from typing import Optional
from pydantic import BaseModel, Field
import pyodbc
from server.utils.conection import get_admin_connection as aconn
from server.utils.generador import generar_carta_unica
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

        # Verificar si hay un conjunto de resultados
        if cursor.description is None:
            # No hay resultados (mesa no existe o no tiene partidas)
            return {
                "resultado": [],
                "mensaje": "No se encontraron jugadores para esta mesa",
            }

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
    codigo = randint(10000000, 99999999)
    try:
        conn = aconn()
        cursor = conn.cursor()
        cursor.execute(
            "EXEC sp_crear_mesa @idUsuario=?, @codigo=?",
            payload.idUsuario,
            codigo,
        )
        conn.commit()
        cursor.close()
        return {"resultado": "ok", "codigo": codigo}
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
    try:
        conn = aconn()
        cursor = conn.cursor()
        cursor.execute("EXEC sp_verificar_partida_activa @idMesa=?", id_mesa)
        result = cursor.fetchone()
        cursor.close()
        if result:
            return {"existePartidaActiva": bool(result[0]), "idPartida": result[1]}
        else:
            raise HTTPException(status_code=404, detail="Mesa no encontrada")
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


@router.put("/partida/terminar/{id_partida}")
def terminar_partida(id_partida: int):
    try:
        conn = aconn()
        cursor = conn.cursor()
        cursor.execute("EXEC sp_terminar_partida @idPartida=?", id_partida)
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


@router.post("/partida/arrancar")
def arrancar_partida(payload: PartidaIniciar):
    try:
        conn = aconn()
        cursor = conn.cursor()

        # 1. Crear partida y conectar jugadores desde tEsperaMesa
        cursor.execute("EXEC sp_iniciar_partida @idMesa=?", payload.idMesa)
        result = cursor.fetchone()
        if not result:
            raise HTTPException(status_code=500, detail="No se pudo iniciar la partida")
        idPartida = result[0]
        conn.commit()

        # 2. Obtener los dos jugadores
        cursor.execute(
            "SELECT idUsuario FROM tUsuariosPartidas WHERE idPartida=? ORDER BY idUsuario",
            idPartida,
        )
        jugadores = [row[0] for row in cursor.fetchall()]
        if len(jugadores) != 2:
            raise HTTPException(
                status_code=500, detail="Número incorrecto de jugadores"
            )

        # 3. Generar 9 cartas únicas
        cartas = [generar_carta_unica(idPartida) for _ in range(9)]
        mano1 = cartas[0:2]
        mano2 = cartas[2:4]
        flop = cartas[4:7]
        turn = cartas[7]
        river = cartas[8]

        # 4. Asignar manos
        cursor.execute(
            "EXEC sp_asignar_mano_jugador @idPartida=?, @idUsuario=?, @carta1=?, @carta2=?",
            idPartida,
            jugadores[0],
            mano1[0],
            mano1[1],
        )
        cursor.execute(
            "EXEC sp_asignar_mano_jugador @idPartida=?, @idUsuario=?, @carta1=?, @carta2=?",
            idPartida,
            jugadores[1],
            mano2[0],
            mano2[1],
        )

        # 5. Guardar cartas comunitarias
        cursor.execute(
            "EXEC sp_guardar_comunitarias @idPartida=?, @flop1=?, @flop2=?, @flop3=?, @turn=?, @river=?",
            idPartida,
            flop[0],
            flop[1],
            flop[2],
            turn,
            river,
        )

        # 6. Establecer turno inicial (el primer jugador de la lista, por ejemplo)
        cursor.execute(
            "UPDATE tPartida SET turno=? WHERE id=?", jugadores[0], idPartida
        )

        conn.commit()
        cursor.close()
        return {"resultado": "ok", "idPartida": idPartida, "jugadores": jugadores}

    except pyodbc.Error as e:
        raise HTTPException(status_code=400, detail=f"error al arrancar partida: {e}")


@router.get("/partida/{id_partida}/estado")
def estado_partida(id_partida: int, usuario: int):
    try:
        conn = aconn()
        cursor = conn.cursor()
        cursor.execute(
            "EXEC sp_obtener_estado_partida2 @idPartida=?, @idUsuario=?",
            id_partida,
            usuario,
        )
        estado = cursor.fetchone()
        cursor.close()
        if not estado:
            raise HTTPException(status_code=404, detail="Partida no encontrada")
        # Convertir a diccionario para claridad
        claves = [
            "fase",
            "flop1",
            "flop2",
            "flop3",
            "turn",
            "river",
            "carta1",
            "carta2",
            "pozo",
            "apuesta_actual",
            "fichas",
            "fichas_oponente",
            "turno",
            "acciones",
            "ganador",
            "monto_ganado",
        ]
        return {"resultado": dict(zip(claves, estado))}
    except pyodbc.Error as e:
        raise HTTPException(status_code=400, detail=f"error en estado_partida: {e}")


class AccionRequest(BaseModel):
    idPartida: int
    idUsuario: int
    idTipoAccion: int
    monto: Optional[float] = None


@router.post("/partida/accion")
def ejecutar_accion(payload: AccionRequest):
    try:
        conn = aconn()
        cursor = conn.cursor()
        cursor.execute(
            "EXEC sp_ejecutar_accion @idPartida=?, @idUsuario=?, @idTipoAccion=?, @monto=?",
            payload.idPartida,
            payload.idUsuario,
            payload.idTipoAccion,
            payload.monto,
        )
        conn.commit()
        cursor.close()
        return {"resultado": "ok"}
    except pyodbc.Error as e:
        raise HTTPException(status_code=400, detail=f"error en accion: {e}")
