CREATE OR ALTER VIEW vw_mesas_activas
AS
SELECT
    M.id,
    M.codigo,
    U.nombre AS Creador,
    M.tiempoApertura
FROM tMesa M
INNER JOIN tUsuarios U
    ON M.idUsuario = U.id
WHERE M.actividad = 1;
GO

