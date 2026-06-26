CREATE PROCEDURE sp_ValidarLogin
    @email NVARCHAR(255),
    @clave NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT id, nombre, email, activo
    FROM tUsuarios
    WHERE email = @email
      AND clave = @clave
      AND activo = 1;
END
