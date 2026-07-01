CREATE OR ALTER PROCEDURE sp_banear_usuario
(
    @idUsuario INT
)
AS
BEGIN

    SET NOCOUNT ON;

    -- Verificar que el usuario exista
    IF NOT EXISTS
    (
        SELECT 1
        FROM tUsuarios
        WHERE id = @idUsuario
    )
    BEGIN
        RAISERROR('El usuario no existe.',16,1);
        RETURN;
    END;

    -- Verificar que no esté baneado
    IF EXISTS
    (
        SELECT 1
        FROM tUsuarios
        WHERE id = @idUsuario
        AND activo = 0
    )
    BEGIN
        RAISERROR('El usuario ya está baneado.',16,1);
        RETURN;
    END;

    UPDATE tUsuarios
    SET activo = 0
    WHERE id = @idUsuario;

    PRINT 'Usuario baneado correctamente.';

END;
GO