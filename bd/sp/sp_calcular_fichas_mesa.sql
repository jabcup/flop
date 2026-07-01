CREATE OR ALTER PROCEDURE sp_calcular_fichas_mesa
(
    @idMesa INT
)
AS
BEGIN

    SET NOCOUNT ON;

    -- Verificar que la mesa exista
    IF NOT EXISTS
    (
        SELECT 1
        FROM tMesa
        WHERE id = @idMesa
    )
    BEGIN
        RAISERROR('La mesa no existe.',16,1);
        RETURN;
    END;

    SELECT
        M.id AS Mesa,
        ISNULL(SUM(A.monto),0) AS TotalFichas
    FROM tMesa M
        LEFT JOIN tPartida P
            ON M.id = P.idMesa
        LEFT JOIN tAcciones A
            ON P.id = A.idPartida
    WHERE M.id = @idMesa
    GROUP BY M.id;

END;
GO

