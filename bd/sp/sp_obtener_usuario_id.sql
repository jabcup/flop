CREATE PROCEDURE sp_ObtenerUsuarioPorId
    @id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT id, nombre, email, fechaRegistro, activo
    FROM tUsuarios
    WHERE id = @id;
END
