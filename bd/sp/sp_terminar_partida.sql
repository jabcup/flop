CREATE PROCEDURE dbo.sp_terminar_partida
(
    @idPartida INT,
    @montoFinal DECIMAL(20,2)
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM tPartida
        WHERE id = @idPartida
    )
    BEGIN
        PRINT 'La partida no existe.';
        RETURN;
    END

    IF EXISTS
    (
        SELECT 1
        FROM tPartida
        WHERE id = @idPartida
        AND estado = 'Finalizada'
    )
    BEGIN
        PRINT 'La partida ya fue finalizada.';
        RETURN;
    END

    UPDATE tPartida
    SET
        montoFinal = @montoFinal,
        estado = 'Finalizada'
    WHERE id = @idPartida;

    PRINT 'Partida finalizada correctamente.';

END;
GO
