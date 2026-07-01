CREATE OR ALTER PROCEDURE sp_registrar_accion
(
    @idUsuario INT,
    @idPartida INT,
    @idTipoAccion INT,
    @monto DECIMAL(20,2),
    @montoRestante DECIMAL(20,2)
)
AS
BEGIN

    SET NOCOUNT ON;

    -- Verificar usuario
    IF NOT EXISTS
    (
        SELECT 1
        FROM tUsuarios
        WHERE id = @idUsuario
    )
    BEGIN
        RAISERROR('El usuario no existe.',16,1);
        RETURN;
    END;

    -- Verificar partida
    IF NOT EXISTS
    (
        SELECT 1
        FROM tPartida
        WHERE id = @idPartida
    )
    BEGIN
        RAISERROR('La partida no existe.',16,1);
        RETURN;
    END;

    -- Verificar tipo de acción
    IF NOT EXISTS
    (
        SELECT 1
        FROM tTipoAccion
        WHERE id = @idTipoAccion
    )
    BEGIN
        RAISERROR('El tipo de acción no existe.',16,1);
        RETURN;
    END;

    INSERT INTO tAcciones
    (
        idUsuario,
        idPartida,
        idTipoAccion,
        monto,
        montoRestante
    )
    VALUES
    (
        @idUsuario,
        @idPartida,
        @idTipoAccion,
        @monto,
        @montoRestante
    );

    PRINT 'Acción registrada correctamente.';

END;
GO