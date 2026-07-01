CREATE PROCEDURE dbo.sp_verificar_partida_activa
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

    -- Verificar si existe una partida activa
    IF EXISTS
    (
        SELECT 1
        FROM dbo.tPartida
        WHERE idMesa = @idMesa
          AND estado = 'ACTIVA'
    )
    BEGIN
        PRINT 'La mesa tiene una partida activa.';
    END
    ELSE
    BEGIN
        PRINT 'La mesa no tiene partidas activas.';
    END

END;
GO
