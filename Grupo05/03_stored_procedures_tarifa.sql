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
USE Com2900G05;
GO

/*
  _____          _  __       
 |_   _|_ _ _ __(_)/ _| __ _ 
   | |/ _` | '__| | |_ / _` |
   | | (_| | |  | |  _| (_| |
   |_|\__,_|_|  |_|_|  \__,_|
                             
*/

/***********************************************************************
Nombre del procedimiento: socios.cargar_tarifa_cat_sp
Descripción: Cargar tarifa categoria
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE socios.cargar_tarifa_cat_sp
	@id_categoria INT,
	@vigente_desde DATE = NULL,
	@vigente_hasta DATE = NULL,
	@valor DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

	-- Validamos el valor
	IF @valor IS NULL OR @valor < 0
	BEGIN
		RAISERROR('El valor de la tarifa debe ser positivo.', 16, 1);
		RETURN;
	END

	-- Validamos el valor
	IF NOT EXISTS(SELECT 1 FROM socios.Categoria WHERE id_categoria = @id_categoria)
	BEGIN
		RAISERROR('La Categoria no existe.', 16, 1);
		RETURN;
	END

	IF @vigente_desde IS NULL
        SET @vigente_desde = GETDATE();

	-- Validación de fechas
	IF @vigente_desde IS NOT NULL AND @vigente_hasta IS NOT NULL
	BEGIN
		IF @vigente_desde > @vigente_hasta
		BEGIN
		    RAISERROR('La fecha de inicio no puede ser mayor que la fecha de fin.', 16, 1);
			RETURN;
		END
	END

	DECLARE @fecha_null DATE = '9999-12-31';
	-- Validar que no exista una tarifa para esas fechas
    IF EXISTS (
        SELECT 1 
        FROM socios.TarifaCategoria
        WHERE id_categoria = @id_categoria
			AND (
				-- Condición de solapamiento:
				-- El inicio del nuevo rango (@vigente_desde) es menor o igual al fin del rango existente (o "sin limite").
				@vigente_desde <= ISNULL(vigencia_desde, @fecha_null)
				AND
				-- El inicio del rango existente (vigente_desde) es menor o igual al fin del nuevo rango (o "sin limite").
				vigencia_hasta <= ISNULL(@vigente_hasta, @fecha_null)
			)
    )
    BEGIN
        RAISERROR('Ya existe una tarifa vigente para las fechas dadas.', 16, 1);
		RETURN;
	END

	INSERT INTO socios.TarifaCategoria(
        id_categoria,
        vigencia_desde,
        vigencia_hasta,
        valor
    )
    VALUES (
        @id_categoria,
        @vigente_desde,
        @vigente_hasta,
        @valor
    );
END
GO

/***********************************************************************
Nombre del procedimiento: socios.cargar_tarifa_dep_sp
Descripción: Cargar tarifa deportiva
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE socios.cargar_tarifa_dep_sp
	@id_actividad_dep INT,
	@vigente_desde DATE = NULL,
	@vigente_hasta DATE = NULL,
	@valor DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

	-- Validamos el valor
	IF @valor IS NULL OR @valor < 0
	BEGIN
		RAISERROR('El valor de la tarifa debe ser positivo.', 16, 1);
		RETURN;
	END

	-- Validamos el valor
	IF NOT EXISTS(SELECT 1 FROM socios.ActividadDeportiva WHERE id_actividad_dep = @id_actividad_dep)
	BEGIN
		RAISERROR('La actividad deportiva no existe.', 16, 1);
		RETURN;
	END

	IF @vigente_desde IS NULL
        SET @vigente_desde = GETDATE();

	-- Validación de fechas
	IF @vigente_desde IS NOT NULL AND @vigente_hasta IS NOT NULL
	BEGIN
		IF @vigente_desde > @vigente_hasta
		BEGIN
		    RAISERROR('La fecha de inicio no puede ser mayor que la fecha de fin.', 16, 1);
			RETURN;
		END
	END

	DECLARE @fecha_null DATE = '9999-12-31';
	-- Validar que no exista una tarifa para esas fechas
    IF EXISTS (
        SELECT 1 
        FROM socios.TarifaActividadDeportiva
        WHERE id_actividad_dep = @id_actividad_dep
			AND (
				-- Condición de solapamiento:
				-- El inicio del nuevo rango (@vigente_desde) es menor o igual al fin del rango existente (o "sin limite").
				@vigente_desde <= ISNULL(vigente_hasta, @fecha_null)
				AND
				-- El inicio del rango existente (vigente_desde) es menor o igual al fin del nuevo rango (o "sin limite").
				vigente_desde <= ISNULL(@vigente_hasta, @fecha_null)
			)
    )
    BEGIN
        RAISERROR('Ya existe una tarifa vigente para las fechas dadas.', 16, 1);
		RETURN;
	END

	INSERT INTO socios.TarifaActividadDeportiva (
        id_actividad_dep,
        vigente_desde,
        vigente_hasta,
        valor
    )
    VALUES (
        @id_actividad_dep,
        @vigente_desde,
        @vigente_hasta,
        @valor
    );
END
GO

/***********************************************************************
Nombre del procedimiento: socios.cargar_tarifa_rec_sp
Descripción: Cargar tarifa recreativa
Autor: Grupo 05 - Com2900
***********************************************************************/

CREATE OR ALTER PROCEDURE socios.cargar_tarifa_rec_sp
	@id_actividad_rec INT,
	@vigente_desde DATE = NULL,
	@vigente_hasta DATE = NULL,
	@valor DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

	-- Validamos el valor
	IF @valor IS NULL OR @valor < 0
	BEGIN
		RAISERROR('El valor de la tarifa debe ser positivo.', 16, 1);
		RETURN;
	END

	-- Validamos el valor
	IF NOT EXISTS(SELECT 1 FROM socios.ActividadRecreativa WHERE id_actividad_rec = @id_actividad_rec)
	BEGIN
		RAISERROR('La actividad Recreativa no existe.', 16, 1);
		RETURN;
	END

	IF @vigente_desde IS NULL
        SET @vigente_desde = GETDATE();

	-- Validación de fechas
	IF @vigente_desde IS NOT NULL AND @vigente_hasta IS NOT NULL
	BEGIN
		IF @vigente_desde > @vigente_hasta
		BEGIN
		    RAISERROR('La fecha de inicio no puede ser mayor que la fecha de fin.', 16, 1);
			RETURN;
		END
	END

	DECLARE @fecha_null DATE = '9999-12-31';
	-- Validar que no exista una tarifa para esas fechas
    IF EXISTS (
        SELECT 1 
        FROM socios.TarifaActividadRecreativa
        WHERE id_actividad_rec = @id_actividad_rec
			AND (
				-- Condición de solapamiento:
				-- El inicio del nuevo rango (@vigente_desde) es menor o igual al fin del rango existente (o "sin limite").
				@vigente_desde <= ISNULL(vigente_hasta, @fecha_null)
				AND
				-- El inicio del rango existente (vigente_desde) es menor o igual al fin del nuevo rango (o "sin limite").
				vigente_desde <= ISNULL(@vigente_hasta, @fecha_null)
			)
    )
    BEGIN
        RAISERROR('Ya existe una tarifa vigente para las fechas dadas.', 16, 1);
		RETURN;
	END

	INSERT INTO socios.TarifaActividadRecreativa(
        id_actividad_rec,
        vigente_desde,
        vigente_hasta,
        valor
    )
    VALUES (
        @id_actividad_rec,
        @vigente_desde,
        @vigente_hasta,
        @valor
    );
END
GO