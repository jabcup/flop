CREATE PROCEDURE dbo.sp_lista_jugadores_mesa
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
        FROM dbo.tMesa
        WHERE id = @idMesa
    )
    BEGIN
        PRINT 'Error: La mesa no existe.';
        RETURN;
    END

    -- Verificar que exista una partida para esa mesa
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.tPartida
        WHERE idMesa = @idMesa
    )
    BEGIN
        PRINT 'La mesa aún no tiene partidas registradas.';
        RETURN;
    END

    -- Mostrar los jugadores de la mesa
    SELECT
        U.id AS IdUsuario,
        U.nombre AS Jugador,
        U.email,
        UP.montoInicial,
        UP.montoFinal
    FROM dbo.tUsuariosPartidas UP
    INNER JOIN dbo.tUsuarios U
        ON UP.idUsuario = U.id
    INNER JOIN dbo.tPartida P
        ON UP.idPartida = P.id
    WHERE P.idMesa = @idMesa
    ORDER BY U.nombre;

END;
GO