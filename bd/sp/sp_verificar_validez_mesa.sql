CREATE PROCEDURE sp_verificar_validez_mesa
(
    @codigo NVARCHAR(8)
)
AS
BEGIN

    SET NOCOUNT ON;

    -- Verificar si la mesa existe
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.tMesa
        WHERE codigo = @codigo
    )
    BEGIN
        PRINT 'Error: La mesa no existe.';
        RETURN;
    END

    -- Verificar si la mesa está activa
    IF EXISTS
    (
        SELECT 1
        FROM dbo.tMesa
        WHERE codigo = @codigo
          AND actividad = 0
    )
    BEGIN
        PRINT 'La mesa existe, pero está inactiva.';
        RETURN;
    END

    -- Mostrar información de la mesa
    SELECT
        id AS IdMesa,
        idUsuario AS Creador,
        codigo AS CodigoMesa,
        tiempoApertura AS FechaApertura,
        actividad AS Activa
    FROM dbo.tMesa
    WHERE codigo = @codigo;

END;
GO
