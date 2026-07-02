CREATE OR ALTER VIEW vw_resumen_partidas
AS
SELECT
    P.id AS IdPartida,
    M.codigo AS CodigoMesa,
    P.fechaInicio,
    P.estado,
    P.montoFinal
FROM tPartida P
INNER JOIN tMesa M
    ON P.idMesa = M.id;
GO