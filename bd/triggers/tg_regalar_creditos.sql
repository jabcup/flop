CREATE TRIGGER trg_RegalarCreditos
ON tUsuarios
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO tRecarga (idUsuario, montoCreditos, montoBs, numeroTarjeta)
    SELECT i.id, 1000, 0, 'BONO_BIENVENIDA'
    FROM inserted i;
END
GO
