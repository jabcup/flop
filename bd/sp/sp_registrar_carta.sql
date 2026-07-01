CREATE OR ALTER PROCEDURE sp_registrar_carta
(
    @valorMostrar NVARCHAR(10),
    @valor NVARCHAR(10)
)
AS
BEGIN

    SET NOCOUNT ON;

    -- Verificar si la carta ya existe
    IF EXISTS
    (
        SELECT 1
        FROM tCarta
        WHERE valor_mostrar = @valorMostrar
    )
    BEGIN
        RAISERROR('La carta ya existe.',16,1);
        RETURN;
    END;

    INSERT INTO tCarta
    (
        valor_mostrar,
        valor
    )
    VALUES
    (
        @valorMostrar,
        @valor
    );

    PRINT 'Carta registrada correctamente.';

END;
GO