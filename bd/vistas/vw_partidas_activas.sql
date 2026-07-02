CREATE OR ALTER VIEW vw_partidas_activas
AS
SELECT
    P.id,
    M.codigo AS Mesa,
    P.fechaInicio,
    P.estado
FROM tPartida P
INNER JOIN tMesa M
    ON P.idMesa = M.id
WHERE P.estado = 'Activa';
GO
