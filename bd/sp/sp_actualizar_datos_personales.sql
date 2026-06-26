CREATE PROCEDURE sp_ActualizarDatosPersonales
    @id INT,
    @nombre NVARCHAR(100),
    @email NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM tUsuarios WHERE email = @email AND id != @id)
    BEGIN
        THROW 50002, 'El email ya esta en uso por otro usuario.', 1;
    END

    UPDATE tUsuarios
    SET nombre = @nombre,
        email = @email
    WHERE id = @id;
END
