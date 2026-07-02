CREATE OR ALTER VIEW vw_jugadores_partida
AS
SELECT
    UP.idPartida,
    P.estado,
    U.nombre AS Jugador,
    UP.montoInicial,
    UP.montoFinal
FROM tUsuariosPartidas UP
INNER JOIN tUsuarios U
    ON UP.idUsuario = U.id
INNER JOIN tPartida P
    ON UP.idPartida = P.id;
GO