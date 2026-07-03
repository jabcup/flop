-- DROP SCHEMA dbo;

CREATE SCHEMA dbo;
-- flop.dbo.tCarta definition

-- Drop table

-- DROP TABLE flop.dbo.tCarta;

CREATE TABLE flop.dbo.tCarta (
	id int IDENTITY(1,1) NOT NULL,
	valor_mostrar nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	valor nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	CONSTRAINT PK__tCarta__3213E83F0E8FCEDD PRIMARY KEY (id)
);


-- flop.dbo.tTipoAccion definition

-- Drop table

-- DROP TABLE flop.dbo.tTipoAccion;

CREATE TABLE flop.dbo.tTipoAccion (
	id int IDENTITY(1,1) NOT NULL,
	nombre nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	CONSTRAINT PK__tTipoAcc__3213E83FD5800ABD PRIMARY KEY (id)
);


-- flop.dbo.tUsuarios definition

-- Drop table

-- DROP TABLE flop.dbo.tUsuarios;

CREATE TABLE flop.dbo.tUsuarios (
	id int IDENTITY(1,1) NOT NULL,
	nombre nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	email nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	clave nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	fechaRegistro datetime2 DEFAULT getdate() NULL,
	activo bit DEFAULT 1 NULL,
	CONSTRAINT PK__tUsuario__3213E83FDD3BBEF8 PRIMARY KEY (id),
	CONSTRAINT UQ__tUsuario__AB6E616408657DD2 UNIQUE (email)
);


-- flop.dbo.tMesa definition

-- Drop table

-- DROP TABLE flop.dbo.tMesa;

CREATE TABLE flop.dbo.tMesa (
	id int IDENTITY(1,1) NOT NULL,
	idUsuario int NOT NULL,
	tiempoApertura datetime2 DEFAULT getdate() NULL,
	codigo nvarchar(8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	actividad bit DEFAULT 1 NULL,
	CONSTRAINT PK__tMesa__3213E83FF7273864 PRIMARY KEY (id),
	CONSTRAINT FK__tMesa__idUsuario__44FF419A FOREIGN KEY (idUsuario) REFERENCES flop.dbo.tUsuarios(id)
);


-- flop.dbo.tPartida definition

-- Drop table

-- DROP TABLE flop.dbo.tPartida;

CREATE TABLE flop.dbo.tPartida (
	id int IDENTITY(1,1) NOT NULL,
	idMesa int NOT NULL,
	fechaInicio datetime2 DEFAULT getdate() NULL,
	montoFinal decimal(20,2) NULL,
	flop1 nvarchar(3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	flop2 nvarchar(3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	flop3 nvarchar(3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	turn nvarchar(3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	river nvarchar(3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	estado varchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS DEFAULT 'Activa' NOT NULL,
	fase nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS DEFAULT 'Preflop' NOT NULL,
	apuesta_actual decimal(20,2) DEFAULT 0 NOT NULL,
	turno int NULL,
	dealer int NULL,
	ganador int NULL,
	CONSTRAINT PK__tPartida__3213E83FC4A773D4 PRIMARY KEY (id),
	CONSTRAINT FK__tPartida__idMesa__48CFD27E FOREIGN KEY (idMesa) REFERENCES flop.dbo.tMesa(id)
);


-- flop.dbo.tRecarga definition

-- Drop table

-- DROP TABLE flop.dbo.tRecarga;

CREATE TABLE flop.dbo.tRecarga (
	id int IDENTITY(1,1) NOT NULL,
	idUsuario int NOT NULL,
	montoCreditos int NOT NULL,
	montoBs int NOT NULL,
	numeroTarjeta nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	CONSTRAINT PK__tRecarga__3213E83F925F40FA PRIMARY KEY (id),
	CONSTRAINT FK__tRecarga__idUsua__403A8C7D FOREIGN KEY (idUsuario) REFERENCES flop.dbo.tUsuarios(id)
);


-- flop.dbo.tUsuariosPartidas definition

-- Drop table

-- DROP TABLE flop.dbo.tUsuariosPartidas;

CREATE TABLE flop.dbo.tUsuariosPartidas (
	id int IDENTITY(1,1) NOT NULL,
	idUsuario int NOT NULL,
	idPartida int NOT NULL,
	montoInicial decimal(20,2) NOT NULL,
	montoFinal decimal(20,2) NOT NULL,
	carta1 nvarchar(3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	carta2 nvarchar(3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	CONSTRAINT PK__tUsuario__3213E83F898B8B17 PRIMARY KEY (id),
	CONSTRAINT FK__tUsuarios__idPar__5165187F FOREIGN KEY (idPartida) REFERENCES flop.dbo.tPartida(id),
	CONSTRAINT FK__tUsuarios__idUsu__5070F446 FOREIGN KEY (idUsuario) REFERENCES flop.dbo.tUsuarios(id)
);


-- flop.dbo.tAcciones definition

-- Drop table

-- DROP TABLE flop.dbo.tAcciones;

CREATE TABLE flop.dbo.tAcciones (
	id int IDENTITY(1,1) NOT NULL,
	idUsuario int NOT NULL,
	idPartida int NOT NULL,
	idTipoAccion int NOT NULL,
	monto decimal(20,2) NULL,
	montoRestante decimal(20,2) NOT NULL,
	fase nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	CONSTRAINT PK__tAccione__3213E83F9E01C850 PRIMARY KEY (id),
	CONSTRAINT FK__tAcciones__idPar__4CA06362 FOREIGN KEY (idPartida) REFERENCES flop.dbo.tPartida(id),
	CONSTRAINT FK__tAcciones__idTip__4D94879B FOREIGN KEY (idTipoAccion) REFERENCES flop.dbo.tTipoAccion(id),
	CONSTRAINT FK__tAcciones__idUsu__4BAC3F29 FOREIGN KEY (idUsuario) REFERENCES flop.dbo.tUsuarios(id)
);


-- flop.dbo.tCartasPartida definition

-- Drop table

-- DROP TABLE flop.dbo.tCartasPartida;

CREATE TABLE flop.dbo.tCartasPartida (
	id int IDENTITY(1,1) NOT NULL,
	idPartida int NOT NULL,
	carta nvarchar(3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	CONSTRAINT PK__tCartasP__3213E83FC45B615D PRIMARY KEY (id),
	CONSTRAINT UQ_CartaPartida UNIQUE (idPartida,carta),
	CONSTRAINT FK__tCartasPa__idPar__09746778 FOREIGN KEY (idPartida) REFERENCES flop.dbo.tPartida(id)
);


-- flop.dbo.tEsperaMesa definition

-- Drop table

-- DROP TABLE flop.dbo.tEsperaMesa;

CREATE TABLE flop.dbo.tEsperaMesa (
	idMesa int NOT NULL,
	idUsuario int NOT NULL,
	fechaUnion datetime2 DEFAULT getdate() NULL,
	CONSTRAINT PK__tEsperaM__B4286FC5E60515F9 PRIMARY KEY (idMesa,idUsuario),
	CONSTRAINT FK__tEsperaMe__idMes__3C34F16F FOREIGN KEY (idMesa) REFERENCES flop.dbo.tMesa(id),
	CONSTRAINT FK__tEsperaMe__idUsu__3D2915A8 FOREIGN KEY (idUsuario) REFERENCES flop.dbo.tUsuarios(id)
);


