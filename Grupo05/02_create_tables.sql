/******************************************************************
 * Enunciado:
 *
 * Fecha de entrega: dd/MM/yyyy
 *
 * Número de comisión: 2900
 * Número de grupo: 05
 * Materia: Bases de datos aplicada
 *
 * Integrantes:
 *		- 44689109 | Crego, Agustina
 *		- 44510837 | Crotti, Tomás
 *		- 44792728 | Hoffmann, Francisco Gabriel
 *
 ******************************************************************/
USE Com2900G05;
GO

IF OBJECT_ID(N'[socios].[Persona]', N'U') IS NULL
BEGIN
	CREATE TABLE socios.Persona (
		id_persona INT IDENTITY(1,1) PRIMARY KEY,
		nombre VARCHAR(50) NOT NULL,
		apellido VARCHAR(50) NOT NULL,
		dni INT NOT NULL,
		email VARCHAR(255),
		fecha_de_nacimiento DATE NOT NULL,
		telefono VARCHAR(50),
		saldo DECIMAL(10,2) NOT NULL DEFAULT 0
	);
END
ELSE
	PRINT 'Ya existe la tabla [socios].[Persona]';
GO

IF OBJECT_ID(N'[socios].[Parentesco]', N'U') IS NULL
BEGIN
	CREATE TABLE socios.Parentesco (
		id_relacion INT IDENTITY(1,1) PRIMARY KEY,
		id_persona INT NOT NULL,
		id_persona_responsable INT NOT NULL,
		parentesco CHAR(1) NOT NULL,
		fecha_desde DATE NOT NULL,
		fecha_hasta DATE NOT NULL,
		CONSTRAINT fk_persona_menor FOREIGN KEY (id_persona) REFERENCES socios.Persona(id_persona),
		CONSTRAINT fk_persona_responsable FOREIGN KEY (id_persona_responsable) REFERENCES socios.Persona(id_persona),
		CONSTRAINT ck_parentesco CHECK (parentesco IN ('P', 'M', 'T'))
	);
END
ELSE
	PRINT 'Ya existe la tabla [socios].[Parentesco]';
GO

IF OBJECT_ID(N'[socios].[Categoria]', N'U') IS NULL
BEGIN
	CREATE TABLE socios.Categoria (
		id_categoria SMALLINT IDENTITY(1,1) PRIMARY KEY,
		nombre VARCHAR(20) NOT NULL,
		edad_min TINYINT NOT NULL,
		edad_max TINYINT NULL
	);
END
ELSE
	PRINT 'Ya existe la tabla [socios].[Categoria]';
GO

IF OBJECT_ID(N'[socios].[TarifaCategoria]', N'U') IS NULL
BEGIN
	CREATE TABLE socios.TarifaCategoria (
		id_tarifa_categorria INT IDENTITY(1,1) PRIMARY KEY,
		id_categoria SMALLINT NOT NULL,
		valor DECIMAL(10,2) NOT NULL,
		vigencia_desde DATE NOT NULL,
		vigencia_hasta DATE NOT NULL
	);
END
ELSE
	PRINT 'Ya existe la tabla [socios].[TarifaCategoria]';
GO
