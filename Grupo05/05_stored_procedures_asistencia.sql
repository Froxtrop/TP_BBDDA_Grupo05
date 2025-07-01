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
     _        _     _                  _       
    / \   ___(_)___| |_ ___ _ __   ___(_) __ _ 
   / _ \ / __| / __| __/ _ \ '_ \ / __| |/ _` |
  / ___ \\__ \ \__ \ ||  __/ | | | (__| | (_| |
 /_/   \_\___/_|___/\__\___|_| |_|\___|_|\__,_|
                                               
*/

/***********************************************************************
Nombre del procedimiento: asistencia_socio_a_actividad_dep_sp
Descripción: Marca la asistencia de un socio a una actividad deportiva.
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE socios.asistencia_socio_a_actividad_dep_sp
    @id_socio INT,
    @id_actividad_deportiva INT,
	@fecha_asistencia DATE = NULL,
	@asistencia CHAR(1), -- P, A, J
	@profesor VARCHAR(50),
	@email_profesor VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

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

	-- Validar que asistencia sea Presente (P) / Ausente (A) / Ausente Justificado (J)
	IF @asistencia NOT IN ('P', 'A', 'J')
	BEGIN
        RAISERROR('El tipo de asistencia debe ser P (Presente), A (Ausente) o J (Ausente Justificado).', 16, 1);
        RETURN;
    END

	-- Si la fecha de asistencia viene nula le ponemos la fecha de hoy.
	IF @fecha_asistencia IS NULL
	BEGIN
		SET @fecha_asistencia = GETDATE();
	END

	-- Validar que el socio este inscripto a la actividad deportiva
    IF NOT EXISTS (
		SELECT 1 FROM socios.InscripcionActividadDeportiva
			WHERE id_actividad_dep = @id_actividad_deportiva
				AND fecha_inscripcion <= @fecha_asistencia
				AND (fecha_baja >= @fecha_asistencia OR fecha_baja IS NULL)
		)
    BEGIN
        RAISERROR('El socio no se encuentra/encontraba inscripto en la actividad deportiva.', 16, 1);
        RETURN;
    END

    -- Insertar registro en la tabla de asitencia
    INSERT INTO socios.AsistenciaActividadDeportiva (
        id_actividad_dep,
        id_socio,
        fecha,
		asistencia,
		profesor,
		email_profesor
    )
    VALUES (
        @id_actividad_deportiva,
        @id_socio,
        @fecha_asistencia,
		@asistencia,
		@profesor,
		@email_profesor
    );
END
GO

/***********************************************************************
Nombre del procedimiento: asistencia_socio_a_actividad_rec_sp
Descripción: Marca la asistencia de un socio a una actividad recreativa.
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE socios.asistencia_socio_a_actividad_rec_sp
    @id_socio INT,
    @id_actividad_recreativa INT,
	@fecha_asistencia DATE = NULL
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

	-- Si la fecha de asistencia viene nula le ponemos la fecha de hoy.
	IF @fecha_asistencia IS NULL
	BEGIN
		SET @fecha_asistencia = GETDATE();
	END

	-- Validar que el socio este inscripto a la actividad recreativa
    IF NOT EXISTS (
		SELECT 1 FROM socios.InscripcionActividadRecreativa
			WHERE id_actividad_rec = @id_actividad_recreativa
				AND fecha_inscripcion <= @fecha_asistencia
				AND (fecha_baja >= @fecha_asistencia OR fecha_baja IS NULL)
		)
    BEGIN
        RAISERROR('El socio no se encuentra/encontraba inscripto en la actividad recreativa.', 16, 1);
        RETURN;
    END

    -- Insertar registro en la tabla de asitencia
    INSERT INTO socios.AsistenciaActividadRecreativa (
        id_actividad_rec,
        id_socio,
        fecha_asistencia
    )
    VALUES (
        @id_actividad_recreativa,
        @id_socio,
        @fecha_asistencia
    );
END
GO