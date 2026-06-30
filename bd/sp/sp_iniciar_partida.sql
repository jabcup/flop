CREATE PROCEDURE dbo.sp_iniciar_partida
(
    @idMesa INT
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM tMesa
        WHERE id = @idMesa
    )
    BEGIN
        PRINT 'La mesa no existe.';
        RETURN;
    END

    IF EXISTS
    (
        SELECT 1
        FROM tMesa
        WHERE id = @idMesa
        AND actividad = 0
    )
    BEGIN
        PRINT 'La mesa está inactiva.';
        RETURN;
    END

    IF EXISTS
    (
        SELECT 1
        FROM tPartida
        WHERE idMesa = @idMesa
        AND estado = 'Activa'
    )
    BEGIN
        PRINT 'Ya existe una partida activa en esta mesa.';
        RETURN;
    END

    INSERT INTO tPartida
    (
        idMesa,
        montoFinal,
        flop1,
        flop2,
        flop3,
        turn,
        river,
        estado
    )
    VALUES
    (
        @idMesa,
        0,
        '',
        '',
        '',
        '',
        '',
        'Activa'
    );

    PRINT 'Partida iniciada correctamente.';

END;
GO