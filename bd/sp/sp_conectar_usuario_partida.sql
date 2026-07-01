CREATE PROCEDURE dbo.sp_conectar_usuario_partida
(
    @idUsuario INT,
    @idPartida INT,
    @montoInicial DECIMAL(20,2)
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
        PRINT 'El usuario no existe.';
        RETURN;
    END

    -- Verificar partida
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

    -- Verificar que esté activa
    IF EXISTS
    (
        SELECT 1
        FROM tPartida
        WHERE id = @idPartida
        AND estado <> 'Activa'
    )
    BEGIN
        PRINT 'La partida no está activa.';
        RETURN;
    END

    -- Verificar si ya está conectado
    IF EXISTS
    (
        SELECT 1
        FROM tUsuariosPartidas
        WHERE idUsuario = @idUsuario
        AND idPartida = @idPartida
    )
    BEGIN
        PRINT 'El usuario ya está conectado a esta partida.';
        RETURN;
    END

    INSERT INTO tUsuariosPartidas
    (
        idUsuario,
        idPartida,
        montoInicial,
        montoFinal
    )
    VALUES
    (
        @idUsuario,
        @idPartida,
        @montoInicial,
        @montoInicial
    );

    PRINT 'Usuario conectado a la partida correctamente.';

END;
GO