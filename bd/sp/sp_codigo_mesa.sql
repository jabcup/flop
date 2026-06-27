CREATE PROCEDURE dbo.sp_codigo_mesa
(
    @idMesa INT
)
AS
BEGIN

    SET NOCOUNT ON;

    -- Verificar existencia
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

    SELECT

        id AS IdMesa,
        codigo AS CodigoMesa

    FROM dbo.tMesa

    WHERE id=@idMesa;

END;
GO