CREATE PROCEDURE dbo.sp_terminar_mesa
(
    @idMesa INT
)
AS
BEGIN

    SET NOCOUNT ON;

    -- Verificar que exista la mesa
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.tMesa
        WHERE id = @idMesa
    )
    BEGIN
        PRINT 'Error: La mesa no existe.';
        RETURN;
    END

    -- Cambiar estado de la mesa
    UPDATE dbo.tMesa
    SET actividad = 0
    WHERE id = @idMesa;

    -- Finalizar todas las partidas activas de esa mesa
    UPDATE dbo.tPartida
    SET estado = 'FINALIZADA'
    WHERE idMesa = @idMesa
      AND estado = 'ACTIVA';

    PRINT 'La mesa ha sido cerrada correctamente.';

END;
GO