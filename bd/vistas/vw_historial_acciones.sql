CREATE OR ALTER VIEW vw_historial_acciones
AS
SELECT
    A.id,
    U.nombre AS Jugador,
    TA.nombre AS Accion,
    A.idPartida,
    A.monto,
    A.montoRestante
FROM tAcciones A
INNER JOIN tUsuarios U
    ON A.idUsuario = U.id
INNER JOIN tTipoAccion TA
    ON A.idTipoAccion = TA.id;
GO
