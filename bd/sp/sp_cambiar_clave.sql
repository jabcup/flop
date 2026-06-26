CREATE PROCEDURE sp_CambiarClave
    @id INT,
    @claveActual NVARCHAR(255),
    @claveNueva NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM tUsuarios WHERE id = @id AND clave = @claveActual)
    BEGIN
        THROW 50003, 'La clave actual es incorrecta.', 1;
    END

    UPDATE tUsuarios
    SET clave = @claveNueva
    WHERE id = @id;
END
