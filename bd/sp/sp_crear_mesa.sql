CREATE PROCEDURE sp_crear_mesa
(
    @idUsuario INT,
    @codigo NVARCHAR(8)
)
AS
BEGIN

    SET NOCOUNT ON;

    -- Verificar que exista el usuario
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.tUsuarios
        WHERE id = @idUsuario
    )
    BEGIN
        PRINT 'Error: El usuario no existe.';
        RETURN;
    END

    -- Verificar que el usuario esté activo
    IF EXISTS
    (
        SELECT 1
        FROM dbo.tUsuarios
        WHERE id = @idUsuario
          AND activo = 0
    )
    BEGIN
        PRINT 'Error: El usuario está inactivo.';
        RETURN;
    END

    -- Verificar que el código no exista
    IF EXISTS
    (
        SELECT 1
        FROM dbo.tMesa
        WHERE codigo = @codigo
    )
    BEGIN
        PRINT 'Error: El código de la mesa ya existe.';
        RETURN;
    END

    -- Crear la mesa
    INSERT INTO dbo.tMesa
    (
        idUsuario,
        codigo
    )
    VALUES
    (
        @idUsuario,
        @codigo
    );

    PRINT 'Mesa creada correctamente.';

END;
GO
