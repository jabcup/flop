CREATE PROCEDURE dbo.sp_listar_mesas_activas
AS
BEGIN

    SET NOCOUNT ON;

    SELECT
        id,
        idUsuario,
        tiempoApertura,
        codigo,
        actividad
    FROM tMesa
    WHERE actividad = 1
    ORDER BY tiempoApertura DESC;

END;
GO