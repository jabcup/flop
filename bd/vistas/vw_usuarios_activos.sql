CREATE OR ALTER VIEW vw_usuarios_activos
AS
SELECT
    id,
    nombre,
    email,
    fechaRegistro
FROM tUsuarios
WHERE activo = 1;
GO
