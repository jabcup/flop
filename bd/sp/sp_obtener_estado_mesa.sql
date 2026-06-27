CREATE PROCEDURE dbo.sp_obtener_estado_mesa
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
        WHERE id=@idMesa
    )
    BEGIN
        PRINT 'Error: La mesa no existe.';
        RETURN;
    END

    SELECT

        id AS IdMesa,

        codigo,

        CASE

            WHEN actividad=1 THEN 'ACTIVA'

            ELSE 'INACTIVA'

        END AS Estado

    FROM dbo.tMesa

    WHERE id=@idMesa;

END;
GO
