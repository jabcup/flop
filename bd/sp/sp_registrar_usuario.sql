CREATE PROCEDURE sp_RegistrarUsuario
    @nombre NVARCHAR(100),
    @email NVARCHAR(255),
    @clave NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (SELECT 1 FROM tUsuarios WHERE email = @email)
    BEGIN
        THROW 50001, 'El email ya esta registrado.', 1;
    END

    INSERT INTO tUsuarios (nombre, email, clave)
    VALUES (@nombre, @email, @clave);
END
