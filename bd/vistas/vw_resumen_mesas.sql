CREATE OR ALTER VIEW vw_resumen_mesas
AS
SELECT
    M.id,
    M.codigo,
    U.nombre AS Creador,
    M.tiempoApertura,
    CASE
        WHEN M.actividad = 1 THEN 'Activa'
        ELSE 'Inactiva'
    END AS EstadoMesa
FROM tMesa M
INNER JOIN tUsuarios U
    ON M.idUsuario = U.id;
GO