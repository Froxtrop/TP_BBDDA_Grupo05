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
  ___                     _            _                  _        _   _       _     _           _ 
 |_ _|_ __  ___  ___ _ __(_)_ __   ___(_) ___  _ __      / \   ___| |_(_)_   _(_) __| | __ _  __| |
  | || '_ \/ __|/ __| '__| | '_ \ / __| |/ _ \| '_ \    / _ \ / __| __| \ \ / / |/ _` |/ _` |/ _` |
  | || | | \__ \ (__| |  | | |_) | (__| | (_) | | | |  / ___ \ (__| |_| |\ V /| | (_| | (_| | (_| |
 |___|_| |_|___/\___|_|  |_| .__/ \___|_|\___/|_| |_| /_/   \_\___|\__|_| \_/ |_|\__,_|\__,_|\__,_|
                           |_|                                                                     
*/

/***********************************************************************
Nombre del procedimiento: inscribir_socio_a_actividad_dep_sp
Descripción: Inscribe a un socio en una actividad deportiva.
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE socios.inscribir_socio_a_actividad_dep_sp
    @id_socio INT,
    @id_actividad_deportiva INT,
	@fecha_alta DATE = NULL,
	@fecha_baja DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
	IF @fecha_alta IS NULL
        SET @fecha_alta = GETDATE();

	IF @fecha_alta IS NOT NULL AND @fecha_baja IS NOT NULL
	BEGIN
		IF @fecha_alta > @fecha_baja
			BEGIN
			    RAISERROR('La fecha de inicio no puede ser mayor que la fecha de fin.', 16, 1);
				RETURN;
			END
	END

    -- Validar que el socio exista
    IF NOT EXISTS (SELECT 1 FROM socios.Socio WHERE id_socio = @id_socio)
    BEGIN
        RAISERROR('El socio no existe.', 16, 1);
        RETURN;
    END

    -- Validar que la actividad deportiva exista
    IF NOT EXISTS (SELECT 1 FROM socios.ActividadDeportiva WHERE id_actividad_dep = @id_actividad_deportiva)
    BEGIN
        RAISERROR('La actividad deportiva no existe.', 16, 1);
        RETURN;
    END

    -- Validar que no esté ya inscrito
    IF EXISTS (
        SELECT 1 
        FROM socios.InscripcionActividadDeportiva
        WHERE id_socio = @id_socio
          AND id_actividad_dep = @id_actividad_deportiva
		  AND fecha_inscripcion <= @fecha_alta
				AND (fecha_baja >= @fecha_alta OR fecha_baja IS NULL)
    )
    BEGIN
        RAISERROR('El socio ya está inscrito en esta actividad.', 16, 1);
        RETURN;
    END

    -- Insertar la inscripción
    INSERT INTO socios.InscripcionActividadDeportiva (
        id_socio,
        id_actividad_dep,
        fecha_inscripcion,
        fecha_baja
    )
    VALUES (
        @id_socio,
        @id_actividad_deportiva,
        @fecha_alta,
		@fecha_baja
		);
END
GO

/***********************************************************************
Nombre del procedimiento: baja_inscripcion_actividad_dep_sp
Descripción: Da de baja una inscripción de una actividad deportiva.
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE socios.baja_inscripcion_actividad_dep_sp
    @id_inscripcion_dep INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar que la inscripcion deportiva exista y que no este dada de baja
    IF NOT EXISTS (
		SELECT 1 FROM socios.InscripcionActividadDeportiva 
			WHERE id_inscripcion_dep = @id_inscripcion_dep
			AND fecha_baja IS NULL
	)
    BEGIN
        RAISERROR('La inscripcion no existe o ya fue dada de baja.', 16, 1);
        RETURN;
    END

    -- Actualizar la inscripción con la fecha de baja
    UPDATE socios.InscripcionActividadDeportiva SET
        fecha_baja = GETDATE()
		WHERE id_inscripcion_dep = @id_inscripcion_dep;
END
GO

/***********************************************************************
Nombre del procedimiento: inscribir_socio_a_actividad_rec_sp
Descripción: Inscribe a un socio en una actividad recreativa.
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE socios.inscribir_socio_a_actividad_rec_sp
    @id_socio INT,
    @id_actividad_recreativa INT,
	@modalidad VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar que el socio exista
    IF NOT EXISTS (SELECT 1 FROM socios.Socio WHERE id_socio = @id_socio)
    BEGIN
        RAISERROR('El socio no existe.', 16, 1);
        RETURN;
    END

    -- Validar que la actividad recreativa exista
    IF NOT EXISTS (SELECT 1 FROM socios.ActividadRecreativa WHERE id_actividad_rec = @id_actividad_recreativa)
    BEGIN
        RAISERROR('La actividad recreativa no existe.', 16, 1);
        RETURN;
    END

	-- Validar que la modalidad exista
    IF NOT EXISTS (
		SELECT 1 FROM socios.TarifaActividadRecreativa
			WHERE id_actividad_rec = @id_actividad_recreativa
				AND modalidad = @modalidad
		)
    BEGIN
        RAISERROR('La modalidad no existe para la actividad recreativa.', 16, 1);
        RETURN;
    END

	DECLARE @fecha_actual DATE = GETDATE();
    -- Validar que no esté ya inscrito
    IF EXISTS (
        SELECT 1
          FROM socios.InscripcionActividadRecreativa
         WHERE id_socio         = @id_socio
           AND id_actividad_rec = @id_actividad_recreativa
		   AND modalidad = @modalidad
		   AND fecha_inscripcion <= @fecha_actual
				AND (fecha_baja >= @fecha_actual OR fecha_baja IS NULL)
    )
    BEGIN
        RAISERROR('El socio ya está inscrito en esta actividad recreativa.', 16, 1);
        RETURN;
    END

    -- Insertar la inscripción
    INSERT INTO socios.InscripcionActividadRecreativa (
        id_actividad_rec,
        id_socio,
        fecha_inscripcion,
        fecha_baja,
		modalidad
    )
    VALUES (
        @id_actividad_recreativa,
        @id_socio,
        @fecha_actual,
        NULL,
		@modalidad
    );

    PRINT 'Inscripción a actividad recreativa realizada correctamente.';
END
GO

/***********************************************************************
Nombre del procedimiento: baja_inscripcion_actividad_rec_sp
Descripción: Da de baja una inscripción de una actividad recreativa.
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE socios.baja_inscripcion_actividad_rec_sp
    @id_inscripcion_rec INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar que la inscripcion recreativa exista y que no este dada de baja
    IF NOT EXISTS (
		SELECT 1 FROM socios.InscripcionActividadRecreativa
			WHERE id_inscripcion_rec = @id_inscripcion_rec
			AND fecha_baja IS NULL
	)
    BEGIN
        RAISERROR('La inscripcion no existe o ya tiene fecha de baja.', 16, 1);
        RETURN;
    END

    -- Actualizar la inscripción con la fecha de baja
    UPDATE socios.InscripcionActividadRecreativa SET
        fecha_baja = GETDATE()
		WHERE id_inscripcion_rec = @id_inscripcion_rec;
END
GO
