CREATE PROCEDURE dbo.sp_hora_inicio_mesa
(
    @idMesa INT
)
AS
BEGIN

    SET NOCOUNT ON;

    -- Verificar que la mesa exista
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

    -- Mostrar la hora de apertura
    SELECT
        id AS IdMesa,
        codigo AS CodigoMesa,
        tiempoApertura AS HoraInicio
    FROM dbo.tMesa
    WHERE id = @idMesa;

END;
GO
