CREATE PROCEDURE dbo.sp_jugador_salir_mesa
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

    -- Verificar que el usuario esté en una partida activa
    IF NOT EXISTS
    (
        SELECT 1
        FROM tUsuariosPartidas UP
        INNER JOIN tPartida P
            ON UP.idPartida = P.id
        WHERE UP.idUsuario = @idUsuario
          AND P.idMesa = @idMesa
          AND P.estado = 'Activa'
    )
    BEGIN
        PRINT 'El usuario no pertenece a una partida activa de esta mesa.';
        RETURN;
    END

    -- Eliminar al usuario de la partida activa
    DELETE UP
    FROM tUsuariosPartidas UP
    INNER JOIN tPartida P
        ON UP.idPartida = P.id
    WHERE UP.idUsuario = @idUsuario
      AND P.idMesa = @idMesa
      AND P.estado = 'Activa';

    PRINT 'El jugador salió de la mesa correctamente.';

END;
GO