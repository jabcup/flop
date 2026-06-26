CREATE PROCEDURE sp_ListarUsuarios
AS
BEGIN
    SET NOCOUNT ON;

    SELECT id, nombre, email, fechaRegistro, activo
    FROM tUsuarios
    ORDER BY fechaRegistro DESC;
END
