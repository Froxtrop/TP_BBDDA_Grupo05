USE master
GO
DROP DATABASE if exists Com2900G05 --cerrar las pestañas para borrar la bdd
GO
/***********************************************************************
 * Enunciado: Cree la base de datos, entidades y relaciones. Incluya
 *		restricciones y claves. Deberá entregar un archivo .sql con 
 *		el script completo de creación (debe funcionar si se lo ejecuta
 *		“tal cual” es entregado en una sola ejecución).
 *
 * Fecha de entrega: 01/07/2025
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
 ***********************************************************************/

/* Creacion de la base de datos */

IF DB_ID('Com2900G05') IS NULL
BEGIN
    CREATE DATABASE Com2900G05;
END
ELSE
	PRINT 'Ya existe la Base de Datos Com2900G05';
GO

USE Com2900G05;
GO

/* Creacion de los esquemas */
IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = 'socios')
BEGIN
    EXEC('CREATE SCHEMA socios');
END
ELSE
	PRINT 'Ya existe el esquema "socios"';
GO

/* Creacion de las tablas */
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
		CONSTRAINT ck_parentesco CHECK (parentesco IN ('P', 'M', 'T')) -- Padre / Madre / Tutor
	);
END
ELSE
	PRINT 'Ya existe la tabla [socios].[Parentesco]';
GO
-- Índices Parentesco
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_Parentesco_id_persona' AND object_id = OBJECT_ID(N'[socios].[Parentesco]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_Parentesco_id_persona ON socios.Parentesco(id_persona);
END;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_Parentesco_id_persona_responsable' AND object_id = OBJECT_ID(N'[socios].[Parentesco]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_Parentesco_id_persona_responsable ON socios.Parentesco(id_persona_responsable);
END;
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
		id_tarifa_categoria INT IDENTITY(1,1) PRIMARY KEY,
		id_categoria SMALLINT NOT NULL,
		valor DECIMAL(10,2) NOT NULL,
		vigencia_desde DATE NOT NULL,
		vigencia_hasta DATE NULL,
		CONSTRAINT fk_TarifaCategoria_categoria FOREIGN KEY (id_categoria) REFERENCES socios.Categoria(id_categoria)
	);
END
ELSE
	PRINT 'Ya existe la tabla [socios].[TarifaCategoria]';
GO
-- Índices TarifaCategoria
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_TarifaCategoria_id_categoria' AND object_id = OBJECT_ID(N'[socios].[TarifaCategoria]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_TarifaCategoria_id_categoria ON socios.TarifaCategoria(id_categoria);
END;
GO

IF OBJECT_ID(N'[socios].[Socio]', N'U') IS NULL
BEGIN
	CREATE TABLE socios.Socio (
		id_socio INT IDENTITY(5000,1) PRIMARY KEY,
		id_persona INT NOT NULL,
		id_categoria SMALLINT NOT NULL,
		fecha_de_alta DATE NOT NULL,
		activo BIT NOT NULL DEFAULT 1,
		obra_social VARCHAR(100),
		nro_obra_social INT,
		telefono_emergencia VARCHAR(50),
		CONSTRAINT fk_Socio_id_persona FOREIGN KEY (id_persona) REFERENCES socios.Persona(id_persona),
		CONSTRAINT fk_Socio_categoria FOREIGN KEY (id_categoria) REFERENCES socios.Categoria(id_categoria)
	);
END
ELSE
	PRINT 'Ya existe la tabla [socios].[Socio]';
GO
-- Índices Socio
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_Socio_id_persona' AND object_id = OBJECT_ID(N'[socios].[Socio]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_Socio_id_persona ON socios.Socio(id_persona);
END;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_Socio_id_categoria' AND object_id = OBJECT_ID(N'[socios].[Socio]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_Socio_id_categoria ON socios.Socio(id_categoria);
END;
GO

IF OBJECT_ID(N'[socios].[ActividadDeportiva]', N'U') IS NULL
BEGIN
	CREATE TABLE socios.ActividadDeportiva (
		id_actividad_dep INT IDENTITY(1,1) PRIMARY KEY,
		nombre VARCHAR(20) NOT NULL
	);
END
ELSE
	PRINT 'Ya existe la tabla [socios].[ActividadDeportiva]';
GO

IF OBJECT_ID(N'[socios].[ActividadRecreativa]', N'U') IS NULL
BEGIN
	CREATE TABLE socios.ActividadRecreativa (
		id_actividad_rec INT IDENTITY(1,1) PRIMARY KEY,
		nombre VARCHAR(20) NOT NULL
	);
END
ELSE
	PRINT 'Ya existe la tabla [socios].[ActividadRecreativa]';
GO

IF OBJECT_ID(N'[socios].[TarifaActividadDeportiva]', N'U') IS NULL
BEGIN
	CREATE TABLE socios.TarifaActividadDeportiva (
		id_tarifa_dep INT IDENTITY(1,1) PRIMARY KEY,
		id_actividad_dep INT NOT NULL,
		vigente_desde DATE NOT NULL,
		vigente_hasta DATE,
		valor DECIMAL(10,2) NOT NULL,
		CONSTRAINT fk_TarifaActividadDeportiva_id_actividad_dep FOREIGN KEY (id_actividad_dep) REFERENCES socios.ActividadDeportiva(id_actividad_dep)
	);
END
ELSE
	PRINT 'Ya existe la tabla [socios].[TarifaActividadDeportiva]';
GO
-- Índices TarifaActividadDeportiva
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_TarifaActividadDeportiva_id_actividad_dep' AND object_id = OBJECT_ID(N'[socios].[TarifaActividadDeportiva]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_TarifaActividadDeportiva_id_actividad_dep ON socios.TarifaActividadDeportiva(id_actividad_dep);
END;
GO

IF OBJECT_ID(N'[socios].[TarifaActividadRecreativa]', N'U') IS NULL
BEGIN
	CREATE TABLE socios.TarifaActividadRecreativa (
		id_tarifa_rec INT IDENTITY(1,1) PRIMARY KEY,
		id_actividad_rec INT NOT NULL,
		vigente_desde DATE NOT NULL,
		vigente_hasta DATE NULL,
		valor DECIMAL(10,2) NOT NULL,
		modalidad VARCHAR(10) NOT NULL,
		edad_maxima INT NULL,
		invitado BIT NOT NULL,
		CONSTRAINT fk_TarifaActividadRecreativa_id_actividad_rec FOREIGN KEY (id_actividad_rec) REFERENCES socios.ActividadRecreativa(id_actividad_rec)
	);
END
ELSE
	PRINT 'Ya existe la tabla [socios].[TarifaActividadRecreativa]';
GO
-- Índices TarifaActividadRecreativa
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_TarifaActividadRecreativa_id_actividad_rec' AND object_id = OBJECT_ID(N'[socios].[TarifaActividadRecreativa]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_TarifaActividadRecreativa_id_actividad_rec ON socios.TarifaActividadRecreativa(id_actividad_rec);
END;
GO

IF OBJECT_ID(N'[socios].[InscripcionActividadDeportiva]', N'U') IS NULL
BEGIN
	CREATE TABLE socios.InscripcionActividadDeportiva (
		id_inscripcion_dep INT IDENTITY(1,1) PRIMARY KEY,
		id_actividad_dep INT NOT NULL,
		id_socio INT NOT NULL,
		fecha_inscripcion DATE NOT NULL,
		fecha_baja DATE NULL,
		CONSTRAINT fk_InscripcionActividadDeportiva_id_actividad_dep FOREIGN KEY (id_actividad_dep) REFERENCES socios.ActividadDeportiva(id_actividad_dep),
		CONSTRAINT fk_InscripcionActividadDeportiva_id_socio FOREIGN KEY (id_socio) REFERENCES socios.Socio(id_socio)
	);
END
ELSE
	PRINT 'Ya existe la tabla [socios].[InscripcionActividadDeportiva]';
GO
-- Índices InscripcionActividadDeportiva
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_InscripcionActividadDeportiva_id_actividad_dep' AND object_id = OBJECT_ID(N'[socios].[InscripcionActividadDeportiva]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_InscripcionActividadDeportiva_id_actividad_dep ON socios.InscripcionActividadDeportiva(id_actividad_dep);
END;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_InscripcionActividadDeportiva_id_socio' AND object_id = OBJECT_ID(N'[socios].[InscripcionActividadDeportiva]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_InscripcionActividadDeportiva_id_socio ON socios.InscripcionActividadDeportiva(id_socio);
END;
GO

IF OBJECT_ID(N'[socios].[InscripcionActividadRecreativa]', N'U') IS NULL
BEGIN
	CREATE TABLE socios.InscripcionActividadRecreativa (
		id_inscripcion_rec INT IDENTITY(1,1) PRIMARY KEY,
		id_actividad_rec INT NOT NULL,
		id_socio INT NOT NULL,
		fecha_inscripcion DATE NOT NULL,
		fecha_baja DATE NULL,
		modalidad VARCHAR(10) NOT NULL,
		CONSTRAINT fk_InscripcionActividadRecreativa_id_actividad_rec FOREIGN KEY (id_actividad_rec) REFERENCES socios.ActividadRecreativa(id_actividad_rec),
		CONSTRAINT fk_InscripcionActividadRecreativa_id_socio FOREIGN KEY (id_socio) REFERENCES socios.Socio(id_socio)
	);
END
ELSE
	PRINT 'Ya existe la tabla [socios].[InscripcionActividadRecreativa]';
GO
-- Índices InscripcionActividadRecreativa
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_InscripcionActividadRecreativa_id_actividad_rec' AND object_id = OBJECT_ID(N'[socios].[InscripcionActividadRecreativa]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_InscripcionActividadRecreativa_id_actividad_rec ON socios.InscripcionActividadRecreativa(id_actividad_rec);
END;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_InscripcionActividadRecreativa_id_socio' AND object_id = OBJECT_ID(N'[socios].[InscripcionActividadRecreativa]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_InscripcionActividadRecreativa_id_socio ON socios.InscripcionActividadRecreativa(id_socio);
END;
GO

IF OBJECT_ID(N'[socios].[AsistenciaActividadDeportiva]', N'U') IS NULL
BEGIN
	CREATE TABLE socios.AsistenciaActividadDeportiva (
		id_asistencia_dep INT IDENTITY(1,1) PRIMARY KEY,
		id_socio INT NOT NULL,
		id_actividad_dep INT NOT NULL,
		fecha DATE NOT NULL,
		asistencia CHAR(1) NOT NULL,
		profesor VARCHAR(50) NOT NULL,
		email_profesor VARCHAR(255) NOT NULL,
		CONSTRAINT fk_AsistenciaActividadDeportiva_id_socio FOREIGN KEY (id_socio) REFERENCES socios.Socio(id_socio),
		CONSTRAINT fk_AsistenciaActividadDeportiva_id_actividad_dep FOREIGN KEY (id_actividad_dep) REFERENCES socios.ActividadDeportiva(id_actividad_dep)
	);
END
ELSE
	PRINT 'Ya existe la tabla [socios].[AsistenciaActividadDeportiva]';
GO
-- Índices AsistenciaActividadDeportiva
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_AsistenciaActividadDeportiva_id_socio' AND object_id = OBJECT_ID(N'[socios].[AsistenciaActividadDeportiva]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_AsistenciaActividadDeportiva_id_socio ON socios.AsistenciaActividadDeportiva(id_socio);
END;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_AsistenciaActividadDeportiva_id_actividad_dep' AND object_id = OBJECT_ID(N'[socios].[AsistenciaActividadDeportiva]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_AsistenciaActividadDeportiva_id_actividad_dep ON socios.AsistenciaActividadDeportiva(id_actividad_dep);
END;
GO

IF OBJECT_ID(N'[socios].[AsistenciaActividadRecreativa]', N'U') IS NULL
BEGIN
	CREATE TABLE socios.AsistenciaActividadRecreativa (
		id_asistencia_rec INT IDENTITY(1,1) PRIMARY KEY,
		id_socio INT NOT NULL,
		id_actividad_rec INT NOT NULL,
		fecha_asistencia DATE NOT NULL,
		CONSTRAINT fk_AsistenciaActividadRecreativa_id_socio FOREIGN KEY (id_socio) REFERENCES socios.Socio(id_socio),
		CONSTRAINT fk_AsistenciaActividadRecreativa_id_actividad_rec FOREIGN KEY (id_actividad_rec) REFERENCES socios.ActividadRecreativa(id_actividad_rec)
	);
END
ELSE
	PRINT 'Ya existe la tabla [socios].[AsistenciaActividadRecreativa]';
GO
-- Índices AsistenciaActividadRecreativa
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_AsistenciaActividadRecreativa_id_socio' AND object_id = OBJECT_ID(N'[socios].[AsistenciaActividadRecreativa]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_AsistenciaActividadRecreativa_id_socio ON socios.AsistenciaActividadRecreativa(id_socio);
END;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_AsistenciaActividadRecreativa_id_actividad_rec' AND object_id = OBJECT_ID(N'[socios].[AsistenciaActividadRecreativa]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_AsistenciaActividadRecreativa_id_actividad_rec ON socios.AsistenciaActividadRecreativa(id_actividad_rec);
END;
GO

IF OBJECT_ID(N'[socios].[Factura]', N'U') IS NULL
BEGIN
	CREATE TABLE socios.Factura (
		id_factura INT IDENTITY(1,1) PRIMARY KEY,
		fecha_emision DATE NOT NULL,
		numero_factura INT,
		total_bruto DECIMAL(10,2) NOT NULL,
		total_neto DECIMAL(10,2) NOT NULL
	);
END
ELSE
	PRINT 'Ya existe la tabla [socios].[Factura]';
GO

IF OBJECT_ID(N'[socios].[Membresia]', N'U') IS NULL
BEGIN
	CREATE TABLE socios.Membresia (
		id_membresia INT IDENTITY(1,1) PRIMARY KEY,
		id_socio int NOT NULL,
		id_factura INT NOT NULL,
		total_bruto DECIMAL(10,2) NOT NULL,
		total_neto DECIMAL(10,2) NOT NULL,
		CONSTRAINT fk_Membresia_id_socio FOREIGN KEY (id_socio) REFERENCES socios.Socio (id_socio),
		CONSTRAINT fk_Membresia_id_factura FOREIGN KEY (id_factura) REFERENCES socios.Factura (id_factura)
	);
END
ELSE
	PRINT 'Ya existe la tabla [socios].[Membresia]';
GO
-- Índices Membresia
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_Membresia_id_socio' AND object_id = OBJECT_ID(N'[socios].[Membresia]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_Membresia_id_socio ON socios.Membresia(id_socio);
END;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_Membresia_id_factura' AND object_id = OBJECT_ID(N'[socios].[Membresia]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_Membresia_id_factura ON socios.Membresia(id_factura);
END;
GO

IF OBJECT_ID(N'[socios].[FacturaResponsable]', N'U') IS NULL
BEGIN
	CREATE TABLE socios.FacturaResponsable (
		id_factura INT NOT NULL,
		id_persona INT NOT NULL,
		CONSTRAINT pk_FacturaResponsable PRIMARY KEY (id_factura, id_persona),
		CONSTRAINT fk_FacturaResponsable_id_factura FOREIGN KEY (id_factura) REFERENCES socios.Factura(id_factura),
		CONSTRAINT fk_FacturaResponsable_id_persona FOREIGN KEY (id_persona) REFERENCES socios.Persona(id_persona)
	);
END
ELSE
	PRINT 'Ya existe la tabla [socios].[FacturaResponsable]';
GO

IF OBJECT_ID(N'[socios].[DetalleInvitacion]', N'U') IS NULL
BEGIN
	CREATE TABLE socios.DetalleInvitacion (
		id_detalle_invitacion INT IDENTITY(1,1) PRIMARY KEY,
		id_inscripcion_rec INT NOT NULL,
		id_persona_invitada INT NOT NULL,
		id_factura INT NOT NULL,
		monto DECIMAL(10,2) NOT NULL,
		fecha DATE NOT NULL,
		CONSTRAINT fk_DetalleInvitacion_id_inscripcion_rec FOREIGN KEY (id_inscripcion_rec) REFERENCES socios.InscripcionActividadRecreativa(id_inscripcion_rec),
		CONSTRAINT fk_DetalleInvitacion_id_persona_invitada FOREIGN KEY (id_persona_invitada) REFERENCES socios.Persona(id_persona),
		CONSTRAINT fk_DetalleInvitacion_id_factura FOREIGN KEY (id_factura) REFERENCES socios.Factura(id_factura)
	);
END
ELSE
	PRINT 'Ya existe la tabla [socios].[DetalleInvitacion]';
GO
-- Índices DetalleInvitacion
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_DetalleInvitacion_id_inscripcion_rec' AND object_id = OBJECT_ID(N'[socios].[DetalleInvitacion]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_DetalleInvitacion_id_inscripcion_rec ON socios.DetalleInvitacion(id_inscripcion_rec);
END;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_DetalleInvitacion_id_persona_invitada' AND object_id = OBJECT_ID(N'[socios].[DetalleInvitacion]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_DetalleInvitacion_id_persona_invitada ON socios.DetalleInvitacion(id_persona_invitada);
END;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_DetalleInvitacion_id_factura' AND object_id = OBJECT_ID(N'[socios].[DetalleInvitacion]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_DetalleInvitacion_id_factura ON socios.DetalleInvitacion(id_factura);
END;
GO

IF OBJECT_ID(N'[socios].[DetalleRecreativa]', N'U') IS NULL
BEGIN
	CREATE TABLE socios.DetalleRecreativa (
		id_detalle_recreativa INT IDENTITY(1,1) PRIMARY KEY,
		id_inscripcion_rec INT NOT NULL,
		id_factura INT NOT NULL,
		monto DECIMAL(10,2) NOT NULL,
		CONSTRAINT fk_DetalleRecreativa_id_inscripcion_rec FOREIGN KEY (id_inscripcion_rec) REFERENCES socios.InscripcionActividadRecreativa(id_inscripcion_rec),
		CONSTRAINT fk_DetalleRecreativa_id_factura FOREIGN KEY (id_factura) REFERENCES socios.Factura(id_factura)
	);
END
ELSE
	PRINT 'Ya existe la tabla [socios].[DetalleRecreativa]';
GO
-- Índices DetalleRecreativa
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_DetalleRecreativa_id_inscripcion_rec' AND object_id = OBJECT_ID(N'[socios].[DetalleRecreativa]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_DetalleRecreativa_id_inscripcion_rec ON socios.DetalleRecreativa(id_inscripcion_rec);
END;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_DetalleRecreativa_id_factura' AND object_id = OBJECT_ID(N'[socios].[DetalleRecreativa]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_DetalleRecreativa_id_factura ON socios.DetalleRecreativa(id_factura);
END;
GO

IF OBJECT_ID(N'[socios].[DetalleDeportiva]', N'U') IS NULL
BEGIN
	CREATE TABLE socios.DetalleDeportiva (
		id_detalle_deportiva INT IDENTITY(1,1) PRIMARY KEY,
		id_inscripcion_dep INT NOT NULL,
		id_membresia INT NOT NULL,
		monto DECIMAL(10,2) NOT NULL,
		CONSTRAINT fk_DetalleDeportiva_id_inscripcion_dep FOREIGN KEY (id_inscripcion_dep) REFERENCES socios.InscripcionActividadDeportiva (id_inscripcion_dep),
		CONSTRAINT fk_DetalleDeportiva_id_membresia FOREIGN KEY (id_membresia) REFERENCES socios.Membresia (id_membresia)
	);
END
ELSE
	PRINT 'Ya existe la tabla [socios].[DetalleDeportiva]';
GO
-- Índices DetalleDeportiva
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_DetalleDeportiva_id_inscripcion_dep' AND object_id = OBJECT_ID(N'[socios].[DetalleDeportiva]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_DetalleDeportiva_id_inscripcion_dep ON socios.DetalleDeportiva(id_inscripcion_dep);
END;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_DetalleDeportiva_id_membresia' AND object_id = OBJECT_ID(N'[socios].[DetalleDeportiva]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_DetalleDeportiva_id_membresia ON socios.DetalleDeportiva(id_membresia);
END;
GO

IF OBJECT_ID(N'[socios].[MedioDePago]', N'U') IS NULL
BEGIN
	CREATE TABLE socios.MedioDePago (
		id_medio INT IDENTITY(1,1) PRIMARY KEY,
		nombre VARCHAR(100) NOT NULL
	);
END
ELSE
	PRINT 'Ya existe la tabla [socios].[MedioDePago]';
GO

IF OBJECT_ID(N'[socios].[Pago]', N'U') IS NULL
BEGIN
	CREATE TABLE socios.Pago (
		id_pago INT IDENTITY(1,1) PRIMARY KEY,
		id_medio INT NOT NULL,
		monto DECIMAL(10,2) NOT NULL,
		fecha_pago DATE NOT NULL,
		codigo_de_referencia varchar(50),
		CONSTRAINT fk_Pago_id_medio FOREIGN KEY (id_medio) REFERENCES socios.MedioDePago(id_medio)
	);
END
ELSE
	PRINT 'Ya existe la tabla [socios].[Pago]';
GO
-- Índices Pago
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_Pago_id_medio' AND object_id = OBJECT_ID(N'[socios].[Pago]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_Pago_id_medio ON socios.Pago(id_medio);
END;
GO

IF OBJECT_ID(N'[socios].[DetalleDePago]', N'U') IS NULL
BEGIN
	CREATE TABLE socios.DetalleDePago (
		id_detalle_de_pago INT IDENTITY(1,1) PRIMARY KEY,
		id_factura INT NOT NULL,
		id_pago INT NOT NULL,
		CONSTRAINT fk_DetalleDePago_id_factura FOREIGN KEY (id_factura) REFERENCES socios.Factura(id_factura),
		CONSTRAINT fk_DetalleDePago_id_pago FOREIGN KEY (id_pago) REFERENCES socios.Pago(id_pago)
	);
END
ELSE
	PRINT 'Ya existe la tabla [socios].[DetalleDePago]';
GO
-- Índices DetalleDePago
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_DetalleDePago_id_factura' AND object_id = OBJECT_ID(N'[socios].[DetalleDePago]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_DetalleDePago_id_factura ON socios.DetalleDePago(id_factura);
END;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_DetalleDePago_id_pago' AND object_id = OBJECT_ID(N'[socios].[DetalleDePago]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_DetalleDePago_id_pago ON socios.DetalleDePago(id_pago);
END;
GO

IF OBJECT_ID(N'[socios].[NotaDeCredito]', N'U') IS NULL
BEGIN
	CREATE TABLE socios.NotaDeCredito (
		id_nota_credito INT IDENTITY(1,1) PRIMARY KEY,
		id_detalle_de_pago INT NOT NULL,
		cuit VARCHAR(20) NOT NULL,
		razon_social VARCHAR(100),
		CONSTRAINT fk_NotaDeCredito_id_detalle_de_pago FOREIGN KEY (id_detalle_de_pago) REFERENCES socios.DetalleDePago(id_detalle_de_pago)
	);
END
ELSE
	PRINT 'Ya existe la tabla [socios].[NotaDeCredito]';
GO
-- Índices NotaDeCredito
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_NotaDeCredito_id_detalle_de_pago' AND object_id = OBJECT_ID(N'[socios].[NotaDeCredito]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_NotaDeCredito_id_detalle_de_pago ON socios.NotaDeCredito(id_detalle_de_pago);
END;
GO

IF OBJECT_ID(N'[socios].[PagoACuenta]', N'U') IS NULL
BEGIN
	CREATE TABLE socios.PagoACuenta (
		id_pago_a_cuenta INT IDENTITY(1,1) PRIMARY KEY,
		id_persona INT NOT NULL,
		id_detalle_de_pago INT NOT NULL,
		fecha DATE NOT NULL,
		motivo VARCHAR(100) NOT NULL,
		monto DECIMAL(10,2) NOT NULL,
		CONSTRAINT fk_PagoACuenta_id_persona FOREIGN KEY (id_persona) REFERENCES socios.Persona(id_persona),
		CONSTRAINT fk_PagoACuenta_id_detalle_de_pago FOREIGN KEY (id_detalle_de_pago) REFERENCES socios.DetalleDePago(id_detalle_de_pago)
	);
END
ELSE
	PRINT 'Ya existe la tabla [socios].[PagoACuenta]';
GO
-- Índices PagoACuenta
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_PagoACuenta_id_persona' AND object_id = OBJECT_ID(N'[socios].[PagoACuenta]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_PagoACuenta_id_persona ON socios.PagoACuenta(id_persona);
END;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_PagoACuenta_id_detalle_de_pago' AND object_id = OBJECT_ID(N'[socios].[PagoACuenta]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_PagoACuenta_id_detalle_de_pago ON socios.PagoACuenta(id_detalle_de_pago);
END;
GO

IF OBJECT_ID(N'[socios].[Morosidad]', N'U') IS NULL
BEGIN
	CREATE TABLE socios.Morosidad (
		id_morosidad INT IDENTITY(1,1) PRIMARY KEY,
		id_socio INT NOT NULL,
		id_factura INT NOT NULL,
		monto DECIMAL(10,2) NOT NULL,
		ya_aplicada BIT DEFAULT 0,
		CONSTRAINT fk_Morosidad_id_socio FOREIGN KEY (id_socio) REFERENCES socios.Socio(id_socio),
		CONSTRAINT fk_Morosidad_id_factura FOREIGN KEY (id_factura) REFERENCES socios.Factura(id_factura)
	);
END
ELSE
	PRINT 'Ya existe la tabla [socios].[Morosidad]';
GO
-- Índices Morosidad
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_Morosidad_id_socio' AND object_id = OBJECT_ID(N'[socios].[Morosidad]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_Morosidad_id_socio ON socios.Morosidad(id_socio);
END;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_Morosidad_id_factura' AND object_id = OBJECT_ID(N'[socios].[Morosidad]', N'U'))
BEGIN
    CREATE NONCLUSTERED INDEX ix_Morosidad_id_factura ON socios.Morosidad(id_factura);
END;
GO
