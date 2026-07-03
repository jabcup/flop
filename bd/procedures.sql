CREATE PROCEDURE dbo.sp_codigo_mesa
(
    @idMesa INT
)
AS
BEGIN

    SET NOCOUNT ON;

    -- Verificar existencia
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

    SELECT

        id AS IdMesa,
        codigo AS CodigoMesa

    FROM dbo.tMesa

    WHERE id=@idMesa;

END;

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

CREATE   PROCEDURE sp_consultar_ultima_accion
(
    @idPartida INT
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
        RAISERROR('La partida no existe.',16,1);
        RETURN;
    END;

    SELECT TOP 1
        U.nombre AS Jugador,
        TA.nombre AS Accion,
        A.monto AS Monto
    FROM tAcciones A
        INNER JOIN tUsuarios U
            ON A.idUsuario = U.id
        INNER JOIN tTipoAccion TA
            ON A.idTipoAccion = TA.id
    WHERE A.idPartida = @idPartida
    ORDER BY A.id DESC;

END;

CREATE PROCEDURE sp_crear_mesa
(
    @idUsuario INT,
    @codigo NVARCHAR(8)
)
AS
BEGIN

    SET NOCOUNT ON;

    -- Verificar que exista el usuario
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.tUsuarios
        WHERE id = @idUsuario
    )
    BEGIN
        PRINT 'Error: El usuario no existe.';
        RETURN;
    END

    -- Verificar que el usuario esté activo
    IF EXISTS
    (
        SELECT 1
        FROM dbo.tUsuarios
        WHERE id = @idUsuario
          AND activo = 0
    )
    BEGIN
        PRINT 'Error: El usuario está inactivo.';
        RETURN;
    END

    -- Verificar que el código no exista
    IF EXISTS
    (
        SELECT 1
        FROM dbo.tMesa
        WHERE codigo = @codigo
    )
    BEGIN
        PRINT 'Error: El código de la mesa ya existe.';
        RETURN;
    END

    -- Crear la mesa
    INSERT INTO dbo.tMesa
    (
        idUsuario,
        codigo
    )
    VALUES
    (
        @idUsuario,
        @codigo
    );

    PRINT 'Mesa creada correctamente.';
    SELECT SCOPE_IDENTITY() AS idMesa

END;

CREATE   PROCEDURE sp_crear_tipo_accion
(
    @nombre NVARCHAR(50)
)
AS
BEGIN

    SET NOCOUNT ON;

    -- Verificar si ya existe
    IF EXISTS
    (
        SELECT 1
        FROM tTipoAccion
        WHERE nombre = @nombre
    )
    BEGIN
        RAISERROR('El tipo de acción ya existe.',16,1);
        RETURN;
    END;

    INSERT INTO tTipoAccion
    (
        nombre
    )
    VALUES
    (
        @nombre
    );

    PRINT 'Tipo de acción registrado correctamente.';

END;

CREATE PROCEDURE sp_DesactivarUsuario
    @id INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE tUsuarios
    SET activo = 0
    WHERE id = @id;
END;

CREATE PROCEDURE dbo.sp_ejecutar_accion
    @idPartida INT,
    @idUsuario INT,
    @idTipoAccion INT,
    @monto DECIMAL(20,2) = NULL      -- opcional, para validar
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @fase NVARCHAR(20), @apuesta_actual DECIMAL(20,2),
            @turno INT, @estado NVARCHAR(20), @dealer INT;

    SELECT @fase = fase, @apuesta_actual = apuesta_actual, @turno = turno,
           @estado = estado, @dealer = dealer
    FROM tPartida WHERE id = @idPartida;

    IF @estado <> 'Activa'
    BEGIN
        RAISERROR('La partida no está activa.',16,1);
        RETURN;
    END
    IF @turno <> @idUsuario
    BEGIN
        RAISERROR('No es tu turno.',16,1);
        RETURN;
    END

    DECLARE @tipo NVARCHAR(50);
    SELECT @tipo = nombre FROM tTipoAccion WHERE id = @idTipoAccion;

    -- Oponente
    DECLARE @idOponente INT;
    SELECT @idOponente = idUsuario FROM tUsuariosPartidas
    WHERE idPartida = @idPartida AND idUsuario <> @idUsuario;

    -- Lo que este jugador ya ha puesto en la fase actual
    DECLARE @jugadorAportado DECIMAL(20,2);
    SELECT @jugadorAportado = ISNULL(SUM(monto),0)
    FROM tAcciones
    WHERE idPartida = @idPartida AND idUsuario = @idUsuario AND fase = @fase;

    -- Tamaño fijo de apuesta según fase
    DECLARE @betSize DECIMAL(20,2);
    IF @fase IN ('Preflop','Flop')
        SET @betSize = 2.00;
    ELSE
        SET @betSize = 4.00;

    DECLARE @montoAccion DECIMAL(20,2);

    IF @tipo = 'fold'
    BEGIN
        SET @montoAccion = 0;
        INSERT INTO tAcciones (idUsuario, idPartida, idTipoAccion, monto, montoRestante, fase)
        VALUES (@idUsuario, @idPartida, @idTipoAccion, 0, 0, @fase);

        -- El oponente gana
        DECLARE @pozo DECIMAL(20,2);
        SELECT @pozo = ISNULL(SUM(monto),0) FROM tAcciones WHERE idPartida = @idPartida;

        UPDATE tUsuariosPartidas
        SET montoFinal = montoFinal + @pozo
        WHERE idPartida = @idPartida AND idUsuario = @idOponente;

        UPDATE tPartida
        SET estado = 'Finalizada',
            montoFinal = @pozo,
            ganador = @idOponente
        WHERE id = @idPartida;

        RETURN;
    END

    IF @tipo = 'check'
    BEGIN
        IF @apuesta_actual > 0 AND @jugadorAportado < @apuesta_actual
        BEGIN
            RAISERROR('No puedes hacer check, hay una apuesta pendiente.',16,1);
            RETURN;
        END
        SET @montoAccion = 0;
        INSERT INTO tAcciones (idUsuario, idPartida, idTipoAccion, monto, montoRestante, fase)
        VALUES (@idUsuario, @idPartida, @idTipoAccion, 0, 0, @fase);

        -- Pasar turno al oponente (la ronda no termina)
        UPDATE tPartida SET turno = @idOponente WHERE id = @idPartida;
        RETURN;
    END

    IF @tipo = 'call'
    BEGIN
        IF @apuesta_actual = 0
        BEGIN
            RAISERROR('No hay apuesta que igualar.',16,1);
            RETURN;
        END
        SET @montoAccion = @apuesta_actual - @jugadorAportado;
        IF @montoAccion <= 0
        BEGIN
            RAISERROR('Ya has igualado la apuesta actual.',16,1);
            RETURN;
        END

        -- Verificar fichas
        DECLARE @fichasJugador DECIMAL(20,2);
        SELECT @fichasJugador = montoFinal FROM tUsuariosPartidas
        WHERE idPartida = @idPartida AND idUsuario = @idUsuario;

        IF @fichasJugador < @montoAccion
            RAISERROR('Fichas insuficientes.',16,1);

        INSERT INTO tAcciones (idUsuario, idPartida, idTipoAccion, monto, montoRestante, fase)
        VALUES (@idUsuario, @idPartida, @idTipoAccion, @montoAccion, @fichasJugador - @montoAccion, @fase);

        UPDATE tUsuariosPartidas
        SET montoFinal = montoFinal - @montoAccion
        WHERE idPartida = @idPartida AND idUsuario = @idUsuario;

        -- La ronda de apuestas termina
        -- Avanzar de fase y resetear apuesta_actual
        IF @fase = 'Preflop'
        BEGIN
            UPDATE tPartida SET fase = 'Flop', apuesta_actual = 0,
                   turno = CASE WHEN @dealer = @idUsuario THEN @idOponente ELSE @idUsuario END
            WHERE id = @idPartida;
        END
        ELSE IF @fase = 'Flop'
        BEGIN
            UPDATE tPartida SET fase = 'Turn', apuesta_actual = 0
            WHERE id = @idPartida;
            -- turno sigue igual (el mismo que empezó Flop)
        END
        ELSE IF @fase = 'Turn'
        BEGIN
            UPDATE tPartida SET fase = 'River', apuesta_actual = 0
            WHERE id = @idPartida;
        END
        ELSE IF @fase = 'River'
        BEGIN
            -- Showdown: no se determina ganador, lo hará Python
            UPDATE tPartida SET fase = 'Showdown', apuesta_actual = 0
            WHERE id = @idPartida;
        END
        RETURN;
    END

    IF @tipo = 'raise'
    BEGIN
        -- Calcular a cuánto subir la apuesta
        DECLARE @raiseTotal DECIMAL(20,2);
        IF @apuesta_actual = 0
            SET @raiseTotal = @betSize;
        ELSE
            SET @raiseTotal = @apuesta_actual + @betSize;

        SET @montoAccion = @raiseTotal - @jugadorAportado;
        IF @montoAccion <= 0
        BEGIN
            RAISERROR('Ya has alcanzado el límite de subida.',16,1);
            RETURN;
        END

        DECLARE @fichasRaise DECIMAL(20,2);
        SELECT @fichasRaise = montoFinal FROM tUsuariosPartidas
        WHERE idPartida = @idPartida AND idUsuario = @idUsuario;

        IF @fichasRaise < @montoAccion
            RAISERROR('Fichas insuficientes.',16,1);

        INSERT INTO tAcciones (idUsuario, idPartida, idTipoAccion, monto, montoRestante, fase)
        VALUES (@idUsuario, @idPartida, @idTipoAccion, @montoAccion, @fichasRaise - @montoAccion, @fase);

        UPDATE tUsuariosPartidas
        SET montoFinal = montoFinal - @montoAccion
        WHERE idPartida = @idPartida AND idUsuario = @idUsuario;

        UPDATE tPartida
        SET apuesta_actual = @raiseTotal,
            turno = @idOponente
        WHERE id = @idPartida;

        RETURN;
    END

    -- Si no era ninguna acción válida
    RAISERROR('Acción no reconocida.',16,1);
END;

CREATE PROCEDURE dbo.sp_guardar_comunitarias
    @idPartida INT,
    @flop1 NVARCHAR(3),
    @flop2 NVARCHAR(3),
    @flop3 NVARCHAR(3),
    @turn  NVARCHAR(3),
    @river NVARCHAR(3)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.tPartida
    SET flop1 = @flop1,
        flop2 = @flop2,
        flop3 = @flop3,
        turn  = @turn,
        river = @river
    WHERE id = @idPartida;
END;

CREATE PROCEDURE dbo.sp_hora_inicio_mesa
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

    -- Mostrar la hora de apertura
    SELECT
        id AS IdMesa,
        codigo AS CodigoMesa,
        tiempoApertura AS HoraInicio
    FROM dbo.tMesa
    WHERE id = @idMesa;

END;

CREATE PROCEDURE dbo.sp_iniciar_partida
    @idMesa INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones
    IF NOT EXISTS (SELECT 1 FROM tMesa WHERE id = @idMesa)
    BEGIN
        RAISERROR('La mesa no existe.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM tPartida WHERE idMesa = @idMesa AND estado = 'Activa')
    BEGIN
        RAISERROR('Ya hay una partida activa en esta mesa.', 16, 1);
        RETURN;
    END

    -- Crear partida
    INSERT INTO tPartida (idMesa, estado, fase, apuesta_actual)
    VALUES (@idMesa, 'Activa', 'Preflop', 0);

    DECLARE @idPartida INT = SCOPE_IDENTITY();

    -- Mover jugadores de la sala de espera a la partida
    INSERT INTO tUsuariosPartidas (idUsuario, idPartida, montoInicial, montoFinal)
    SELECT idUsuario, @idPartida, 100, 100
    FROM tEsperaMesa
    WHERE idMesa = @idMesa;

    IF @@ROWCOUNT < 2
    BEGIN
        RAISERROR('Se necesitan al menos 2 jugadores para iniciar.', 16, 1);
        RETURN;
    END

    -- Asignar el turno al primer jugador (el que no sea el creador de la mesa, como dealer)
    -- Suponemos que el creador es el botón y el otro paga la ciega grande. En heads-up,
    -- el botón paga la ciega pequeña. Para simplificar, elegimos al azar.
    DECLARE @turno INT;
    SELECT TOP 1 @turno = idUsuario
    FROM tEsperaMesa
    WHERE idMesa = @idMesa
    ORDER BY NEWID();

    UPDATE tPartida SET turno = @turno WHERE id = @idPartida;

    -- Limpiar la sala de espera de esa mesa
    DELETE FROM tEsperaMesa WHERE idMesa = @idMesa;

    -- Devolver la partida creada
    SELECT @idPartida AS idPartida;
END;

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

CREATE PROCEDURE sp_ListarUsuarios
AS
BEGIN
    SET NOCOUNT ON;

    SELECT id, nombre, email, fechaRegistro, activo
    FROM tUsuarios
    ORDER BY fechaRegistro DESC;
END;

CREATE PROCEDURE dbo.sp_obtener_estado_mesa
(
    @idMesa INT
)
AS
BEGIN

    SET NOCOUNT ON;

    -- Verificar existencia
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.tMesa
        WHERE id=@idMesa
    )
    BEGIN
        PRINT 'Error: La mesa no existe.';
        RETURN;
    END

    SELECT

        id AS IdMesa,

        codigo,

        CASE

            WHEN actividad=1 THEN 'ACTIVA'

            ELSE 'INACTIVA'

        END AS Estado

    FROM dbo.tMesa

    WHERE id=@idMesa

END;

CREATE PROCEDURE dbo.sp_obtener_estado_partida
(
    @idPartida INT
)
AS
BEGIN

    SET NOCOUNT ON;

    -- Verificar que exista la partida
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.tPartida
        WHERE id = @idPartida
    )
    BEGIN
        PRINT 'Error: La partida no existe.';
        RETURN;
    END

    SELECT

        id AS IdPartida,

        idMesa,

        estado,

        fechaInicio

    FROM dbo.tPartida

    WHERE id = @idPartida;

END;

CREATE PROCEDURE dbo.sp_obtener_estado_partida2
    @idPartida INT,
    @idUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM tPartida WHERE id = @idPartida)
    BEGIN
        RAISERROR('La partida no existe.',16,1);
        RETURN;
    END

    DECLARE @fase NVARCHAR(20),
            @apuesta_actual DECIMAL(20,2),
            @turno INT,
            @dealer INT,
            @estado NVARCHAR(20),
            @ganador INT,
            @montoFinal DECIMAL(20,2);

    SELECT @fase = fase, @apuesta_actual = apuesta_actual, @turno = turno,
           @estado = estado, @dealer = dealer, @ganador = ganador, @montoFinal = montoFinal
    FROM tPartida WHERE id = @idPartida;

    -- Cartas comunitarias visibles según la fase
    DECLARE @flop1 NVARCHAR(3), @flop2 NVARCHAR(3), @flop3 NVARCHAR(3),
            @turnC NVARCHAR(3), @river NVARCHAR(3);

    SELECT @flop1 = flop1, @flop2 = flop2, @flop3 = flop3, @turnC = turn, @river = river
    FROM tPartida WHERE id = @idPartida;

    IF @fase = 'Preflop'
        SELECT @flop1=NULL, @flop2=NULL, @flop3=NULL, @turnC=NULL, @river=NULL;
    ELSE IF @fase = 'Flop'
        SELECT @turnC=NULL, @river=NULL;
    ELSE IF @fase = 'Turn'
        SELECT @river=NULL;

    -- Mano del jugador
    DECLARE @carta1 NVARCHAR(3), @carta2 NVARCHAR(3);
    SELECT @carta1 = carta1, @carta2 = carta2
    FROM tUsuariosPartidas WHERE idPartida = @idPartida AND idUsuario = @idUsuario;

    -- Pozo
    DECLARE @pozo DECIMAL(20,2);
    SELECT @pozo = ISNULL(SUM(monto),0)
    FROM tAcciones WHERE idPartida = @idPartida;

    -- Fichas del jugador y del oponente
    DECLARE @fichasJugador DECIMAL(20,2), @fichasOponente DECIMAL(20,2),
            @idOponente INT;

    SELECT @fichasJugador = montoFinal
    FROM tUsuariosPartidas WHERE idPartida = @idPartida AND idUsuario = @idUsuario;

    SELECT TOP 1 @idOponente = idUsuario, @fichasOponente = montoFinal
    FROM tUsuariosPartidas
    WHERE idPartida = @idPartida AND idUsuario <> @idUsuario;

    -- Acciones válidas (solo si es tu turno y la partida está activa)
    DECLARE @acciones NVARCHAR(100);
    SET @acciones = '';
    IF @estado = 'Activa' AND @turno = @idUsuario AND @fase NOT IN ('Showdown','Finalizada')
    BEGIN
        -- Calcular lo que el jugador ya ha puesto en esta ronda
        DECLARE @jugadorAportado DECIMAL(20,2);
        SELECT @jugadorAportado = ISNULL(SUM(monto),0)
        FROM tAcciones
        WHERE idPartida = @idPartida AND idUsuario = @idUsuario AND fase = @fase;

        IF @apuesta_actual = 0
            SET @acciones = 'fold,check,raise';
        ELSE
        BEGIN
            IF @jugadorAportado < @apuesta_actual
                SET @acciones = 'fold,call,raise';
            ELSE
                SET @acciones = 'fold,check,raise'; -- ya igualó (caso raro)
        END
    END

    -- Resultado
    SELECT @fase AS fase,
           @flop1 AS flop1, @flop2 AS flop2, @flop3 AS flop3,
           @turnC AS turn, @river AS river,
           @carta1 AS carta1, @carta2 AS carta2,
           @pozo AS pozo,
           @apuesta_actual AS apuesta_actual,
           @fichasJugador AS fichas,
           @fichasOponente AS fichas_oponente,
           @turno AS turno,
           @acciones AS acciones,
           CASE WHEN @estado = 'Finalizada' THEN @ganador ELSE NULL END AS ganador,
           CASE WHEN @estado = 'Finalizada' THEN @montoFinal ELSE NULL END AS monto_ganado;
END;

CREATE   PROCEDURE sp_obtener_historial_acciones
(
    @idPartida INT
)
AS
BEGIN

    SET NOCOUNT ON;

    -- Verificar que la partida exista
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

    SELECT
        A.id,
        U.nombre AS Jugador,
        TA.nombre AS Accion,
        A.monto,
        A.montoRestante
    FROM tAcciones A
        INNER JOIN tUsuarios U
            ON A.idUsuario = U.id
        INNER JOIN tTipoAccion TA
            ON A.idTipoAccion = TA.id
    WHERE A.idPartida = @idPartida
    ORDER BY A.id;

END;

CREATE PROCEDURE sp_ObtenerUsuarioPorId
    @id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT id, nombre, email, fechaRegistro, activo
    FROM tUsuarios
    WHERE id = @id;
END;

CREATE   PROCEDURE sp_registrar_accion
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

CREATE   PROCEDURE sp_registrar_carta
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

CREATE PROCEDURE sp_RegistrarUsuario
    @nombre NVARCHAR(100),
    @email NVARCHAR(255),
    @clave NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (SELECT 1 FROM tUsuarios WHERE email = @email)
    BEGIN
        THROW 50001, 'El email ya esta registrado.', 1;
    END

    INSERT INTO tUsuarios (nombre, email, clave)
    VALUES (@nombre, @email, @clave);
END;

CREATE PROCEDURE dbo.sp_terminar_mesa
(
    @idMesa INT
)
AS
BEGIN

    SET NOCOUNT ON;

    -- Verificar que exista la mesa
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

    -- Cambiar estado de la mesa
    UPDATE dbo.tMesa
    SET actividad = 0
    WHERE id = @idMesa;

    -- Finalizar todas las partidas activas de esa mesa
    UPDATE dbo.tPartida
    SET estado = 'FINALIZADA'
    WHERE idMesa = @idMesa
      AND estado = 'ACTIVA';

    PRINT 'La mesa ha sido cerrada correctamente.';

END;

CREATE PROCEDURE dbo.sp_terminar_partida
    @idPartida INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM tPartida WHERE id = @idPartida)
    BEGIN
        RAISERROR('La partida no existe.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM tPartida WHERE id = @idPartida AND estado = 'Finalizada')
    BEGIN
        RAISERROR('La partida ya fue finalizada.', 16, 1);
        RETURN;
    END

    DECLARE @montoFinal DECIMAL(20,2);

    -- Calcular el monto total de las apuestas de la partida
    SELECT @montoFinal = ISNULL(SUM(monto), 0)
    FROM tAcciones
    WHERE idPartida = @idPartida;

    UPDATE tPartida
    SET montoFinal = @montoFinal,
        estado = 'Finalizada'
    WHERE id = @idPartida;

    PRINT 'Partida finalizada correctamente. Monto final: ' + CAST(@montoFinal AS NVARCHAR);
END;

CREATE PROCEDURE dbo.sp_unir_jugador_mesa
(
    @idUsuario INT,
    @idMesa INT
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar usuario
    IF NOT EXISTS (SELECT 1 FROM tUsuarios WHERE id = @idUsuario)
    BEGIN
        RAISERROR('El usuario no existe.', 16, 1);
        RETURN;
    END

    -- Verificar mesa
    IF NOT EXISTS (SELECT 1 FROM tMesa WHERE id = @idMesa)
    BEGIN
        RAISERROR('La mesa no existe.', 16, 1);
        RETURN;
    END

    -- Verificar que la mesa esté activa
    IF EXISTS (SELECT 1 FROM tMesa WHERE id = @idMesa AND actividad = 0)
    BEGIN
        RAISERROR('La mesa está inactiva.', 16, 1);
        RETURN;
    END

    -- Verificar si hay una partida activa en la mesa (no permitir unirse)
    IF EXISTS (
        SELECT 1 FROM tPartida
        WHERE idMesa = @idMesa AND estado = 'Activa'
    )
    BEGIN
        RAISERROR('La mesa ya tiene una partida activa. No se puede unir.', 16, 1);
        RETURN;
    END

    -- Verificar si el usuario ya está en la sala de espera de esta mesa
    IF EXISTS (
        SELECT 1 FROM tEsperaMesa
        WHERE idMesa = @idMesa AND idUsuario = @idUsuario
    )
    BEGIN
        RAISERROR('El usuario ya está en la sala de espera de esta mesa.', 16, 1);
        RETURN;
    END

    -- Insertar en la sala de espera
    INSERT INTO dbo.tEsperaMesa (idMesa, idUsuario)
    VALUES (@idMesa, @idUsuario);

    PRINT 'Usuario unido a la sala de espera correctamente.';
END;

CREATE PROCEDURE sp_ValidarLogin
    @email NVARCHAR(255),
    @clave NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT id, nombre, email, activo
    FROM tUsuarios
    WHERE email = @email
      AND clave = @clave
      AND activo = 1;
END;

CREATE PROCEDURE dbo.sp_verificar_carta_partida
    @idPartida INT,
    @carta NVARCHAR(3)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(1) AS existe
    FROM dbo.tCartasPartida
    WHERE idPartida = @idPartida AND carta = @carta;
END;

CREATE PROCEDURE dbo.sp_verificar_partida_activa
    @idMesa INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.tMesa WHERE id = @idMesa)
    BEGIN
        RAISERROR('La mesa no existe.', 16, 1);
        RETURN;
    END;

    SELECT
        CASE WHEN EXISTS (
            SELECT 1
            FROM dbo.tPartida
            WHERE idMesa = @idMesa AND estado = 'Activa'
        ) THEN 1 ELSE 0 END AS existePartidaActiva,
        (SELECT id FROM dbo.tPartida WHERE idMesa = @idMesa AND estado = 'Activa') AS idPartida;
END;

CREATE PROCEDURE sp_verificar_validez_mesa
(
    @codigo NVARCHAR(8)
)
AS
BEGIN

    SET NOCOUNT ON;

    -- Verificar si la mesa existe
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.tMesa
        WHERE codigo = @codigo
    )
    BEGIN
        PRINT 'Error: La mesa no existe.';
        RETURN;
    END

    -- Verificar si la mesa está activa
    IF EXISTS
    (
        SELECT 1
        FROM dbo.tMesa
        WHERE codigo = @codigo
          AND actividad = 0
    )
    BEGIN
        PRINT 'La mesa existe, pero está inactiva.';
        RETURN;
    END

    -- Mostrar información de la mesa
    SELECT
        id AS IdMesa,
        idUsuario AS Creador,
        codigo AS CodigoMesa,
        tiempoApertura AS FechaApertura,
        actividad AS Activa
    FROM dbo.tMesa
    WHERE codigo = @codigo;

END;