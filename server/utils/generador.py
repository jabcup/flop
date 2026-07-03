import random
from server.utils.conection import get_admin_connection as aconn

# Baraja completa en formato treys ('2c','2d','2h','2s',..., 'As')
PALOS = ["c", "d", "h", "s"]
VALORES = ["2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"]
BARAJATREYS = [v + p for v in VALORES for p in PALOS]  # 52 cartas


def generar_carta_unica(idPartida):
    conn = aconn()
    cursor = conn.cursor()
    try:
        while True:
            carta = random.choice(BARAJATREYS)
            cursor.execute(
                "EXEC sp_verificar_carta_partida @idPartida=?, @carta=?",
                idPartida,
                carta,
            )
            row = cursor.fetchone()
            if row and not row[0]:
                cursor.execute(
                    "EXEC sp_agregar_carta_partida @idPartida=?, @carta=?",
                    idPartida,
                    carta,
                )
                conn.commit()
                return carta
    finally:
        cursor.close()
        # No cierres conn si la reutilizas desde un pool, solo si es una conexión nueva
        # conn.close()
