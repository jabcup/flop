CREATE OR ALTER PROCEDURE sp_crear_tipo_accion
(
    @nombre NVARCHAR(50)
)
AS
BEGIN

    SET NOCOUNT ON;

    -- Verificar si ya existe
    IF EXISTS
    (
        SELECT 1
        FROM tTipoAccion
        WHERE nombre = @nombre
    )
    BEGIN
        RAISERROR('El tipo de acción ya existe.',16,1);
        RETURN;
    END;

    INSERT INTO tTipoAccion
    (
        nombre
    )
    VALUES
    (
        @nombre
    );

    PRINT 'Tipo de acción registrado correctamente.';

END;
GO

