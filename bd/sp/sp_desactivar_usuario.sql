CREATE PROCEDURE sp_DesactivarUsuario
    @id INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE tUsuarios
    SET activo = 0
    WHERE id = @id;
END
