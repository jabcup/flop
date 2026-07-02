CREATE OR ALTER VIEW vw_recargas_usuarios
AS
SELECT
    R.id,
    U.nombre AS Usuario,
    R.montoCreditos,
    R.montoBs,
    R.numeroTarjeta
FROM tRecarga R
INNER JOIN tUsuarios U
    ON R.idUsuario = U.id;
GO
