CREATE PROCEDURE dbo.sp_obtener_estado_partida
(
    @idPartida INT
)
AS
BEGIN

    SET NOCOUNT ON;

    -- Verificar que exista la partida
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.tPartida
        WHERE id = @idPartida
    )
    BEGIN
        PRINT 'Error: La partida no existe.';
        RETURN;
    END

    SELECT

        id AS IdPartida,

        idMesa,

        estado,

        fechaInicio

    FROM dbo.tPartida

    WHERE id = @idPartida;

END;
GO