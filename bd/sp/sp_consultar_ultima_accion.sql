CREATE OR ALTER PROCEDURE sp_consultar_ultima_accion
(
    @idPartida INT
)
AS
BEGIN

    SET NOCOUNT ON;

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

    SELECT TOP 1
        U.nombre AS Jugador,
        TA.nombre AS Accion,
        A.monto AS Monto
    FROM tAcciones A
        INNER JOIN tUsuarios U
            ON A.idUsuario = U.id
        INNER JOIN tTipoAccion TA
            ON A.idTipoAccion = TA.id
    WHERE A.idPartida = @idPartida
    ORDER BY A.id DESC;

END;
GO

EXEC sp_consultar_ultima_accion
    @idPartida = 2;