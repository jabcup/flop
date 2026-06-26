CREATE PROCEDURE sp_ActivarUsuario
    @id INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE tUsuarios
    SET activo = 1
    WHERE id = @id;
END
