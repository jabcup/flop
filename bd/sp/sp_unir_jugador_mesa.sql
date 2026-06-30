CREATE PROCEDURE dbo.sp_unir_jugador_mesa
(
    @idUsuario INT,
    @idMesa INT
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

    -- Verificar mesa
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

    -- Verificar que la mesa esté activa
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

    -- Verificar si el usuario ya está en una partida activa de esa mesa
    IF EXISTS
    (
        SELECT 1
        FROM tUsuariosPartidas up
        INNER JOIN tPartida p
            ON up.idPartida = p.id
        WHERE up.idUsuario = @idUsuario
          AND p.idMesa = @idMesa
          AND p.estado = 'Activa'
    )
    BEGIN
        PRINT 'El usuario ya pertenece a una partida activa de esta mesa.';
        RETURN;
    END

    PRINT 'El usuario puede unirse a la mesa.';

END;
GO

