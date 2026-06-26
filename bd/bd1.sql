CREATE DATABASE flop;
GO

USE flop;

GO 

CREATE TABLE tUsuarios(
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    email NVARCHAR(255) NOT NULL UNIQUE,
    clave NVARCHAR(255) NOT NULL,
    fechaRegistro DATETIME2 DEFAULT GETDATE(),
    activo BIT DEFAULT 1
);

CREATE TABLE tTipoAccion(
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(50) NOT NULL
);

CREATE TABLE tCarta(
    id INT IDENTITY(1,1) PRIMARY KEY,
    valor_mostrar NVARCHAR(10),
    valor NVARCHAR(10)
);

CREATE TABLE tRecarga(
    id INT IDENTITY(1,1) PRIMARY KEY,
    idUsuario INT NOT NULL,
    montoCreditos INT NOT NULL,
    montoBs INT NOT NULL,
    numeroTarjeta NVARCHAR(30),
    FOREIGN KEY (idUsuario) REFERENCES tUsuarios(id)
);

CREATE TABLE tMesa(
    id INT IDENTITY(1,1) PRIMARY KEY,
    idUsuario INT NOT NULL,
    tiempoApertura DATETIME2 DEFAULT GETDATE(),
    codigo NVARCHAR(8) NOT NULL,
    actividad BIT DEFAULT 1,
    FOREIGN KEY (idUsuario) REFERENCES tUsuarios(id)
);

CREATE TABLE tPartida(
    id INT IDENTITY(1,1) PRIMARY KEY,
    idMesa INT NOT NULL,
    fechaInicio DATETIME2 DEFAULT GETDATE(),
    montoFinal DECIMAL(20,2),
    flop1 NVARCHAR(3) NOT NULL,
    flop2 NVARCHAR(3) NOT NULL,
    flop3 NVARCHAR(3) NOT NULL,
    turn NVARCHAR(3),
    river NVARCHAR(3),
    FOREIGN KEY (idMesa) REFERENCES tMesa(id)
);

CREATE TABLE tAcciones(
    id INT IDENTITY(1,1),
    idUsuario INT NOT NULL,
    idPartida INT NOT NULL,
    idTipoAccion INT NOT NULL,
    monto DECIMAL(20,2),
    montoRestante DECIMAL(20,2) NOT NULL,
    FOREIGN KEY (idUsuario) REFERENCES tUsuarios(id),
    FOREIGN KEY (idPartida) REFERENCES tPartida(id),
    FOREIGN KEY (idTipoAccion) REFERENCES tTipoAccion(id),
    PRIMARY KEY (id)
);

CREATE TABLE tUsuariosPartidas(
    id INT IDENTITY(1,1),
    idUsuario INT NOT NULL,
    idPartida INT NOT NULL,
    montoInicial DECIMAL(20,2) NOT NULL,
    montoFinal DECIMAL(20,2) NOT NULL,
    FOREIGN KEY (idUsuario) REFERENCES tUsuarios(id),
    FOREIGN KEY (idPartida) REFERENCES tPartida(id),
    PRIMARY KEY (id)
);
