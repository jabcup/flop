CREATE OR ALTER PROCEDURE sp_obtener_historial_acciones
(
    @idPartida INT
)
AS
BEGIN

    SET NOCOUNT ON;

    -- Verificar que la partida exista
    IF NOT EXISTS
    (
        SELECT 1
        FROM tPartida
        WHERE id = @idPartida
    )
    BEGIN
        RAISERROR('La partida no existe.',16,1);
        RETURN;
    END;

    SELECT
        A.id,
        U.nombre AS Jugador,
        TA.nombre AS Accion,
        A.monto,
        A.montoRestante
    FROM tAcciones A
        INNER JOIN tUsuarios U
            ON A.idUsuario = U.id
        INNER JOIN tTipoAccion TA
            ON A.idTipoAccion = TA.id
    WHERE A.idPartida = @idPartida
    ORDER BY A.id;

END;
GO