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
  _____          _                        _             
 |  ___|_ _  ___| |_ _   _ _ __ __ _  ___(_) ___  _ __  
 | |_ / _` |/ __| __| | | | '__/ _` |/ __| |/ _ \| '_ \ 
 |  _| (_| | (__| |_| |_| | | | (_| | (__| | (_) | | | |
 |_|  \__,_|\___|\__|\__,_|_|  \__,_|\___|_|\___/|_| |_|
                                                        
*/

/***********************************************************************
Nombre del procedimiento: facturacion_membresia_socio_sp
Descripción: Realiza la facturación de la membresía de un socio.
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE socios.facturacion_membresia_socio_sp
    @id_socio INT,
	@id_factura INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
	
	-- Validamos si el socio existe
	IF NOT EXISTS (SELECT 1 FROM socios.Socio WHERE id_socio = @id_socio
		AND activo = 1)
	BEGIN
        RAISERROR('El socio proporcionado no existe.', 16, 1);
        RETURN;
    END

	DECLARE @fecha_actual DATE = GETDATE(),
			@id_membresia INT,
			@monto_categoria DECIMAL(10,2) = 0,
			@cantidad_act_dep INT = 0,
			@monto_deportiva DECIMAL(10,2) = 0,
			@monto_bruto DECIMAL(10,2) = 0,
			@monto_neto DECIMAL(10,2) = 0;

	-- Calculamos primer dia del mes
	DECLARE @primer_dia_mes DATE = DATEFROMPARTS(YEAR(@fecha_actual),MONTH(@fecha_actual), 1);

	BEGIN TRANSACTION Tran1
	BEGIN TRY
		-- Generamos el registro de factura inicial
		INSERT INTO socios.Factura (fecha_emision, total_bruto, total_neto)
			VALUES (@fecha_actual, 0, 0);
		SET @id_factura = SCOPE_IDENTITY();

		-- Generamos el registros de membresia inicial
		INSERT INTO socios.Membresia (id_socio, id_factura, total_bruto, total_neto)
			VALUES (@id_socio, @id_factura, 0, 0);
		SET @id_membresia = SCOPE_IDENTITY();

		-- Buscamos el valor de la categoría del socio
		SELECT @monto_categoria = tc.valor
		FROM socios.Socio s
		INNER JOIN socios.TarifaCategoria tc ON tc.id_categoria = s.id_categoria
			WHERE s.id_socio = @id_socio
			AND tc.vigencia_desde <= @fecha_actual AND
					(tc.vigencia_hasta >= @primer_dia_mes OR tc.vigencia_hasta IS NULL);

		SET @monto_bruto = @monto_bruto + @monto_categoria;

		/* Buscamos si el socio pertenece a un grupo familiar, de ser asi
		aplicamos un descuento del 15% en el total de la facturación de membresía*/
		IF EXISTS (

			SELECT 1
			FROM socios.Parentesco par
			JOIN socios.Socio s1 ON par.id_persona = s1.id_persona
			JOIN socios.Socio s2 ON par.id_persona_responsable = s2.id_persona
			WHERE (s1.id_socio = @id_socio OR s2.id_socio = @id_socio)
			  AND (par.fecha_hasta >= GETDATE() OR par.fecha_hasta IS NULL)

			UNION

		    SELECT 1
			FROM socios.Parentesco p1
			JOIN socios.Parentesco p2 
				ON p1.id_persona_responsable = p2.id_persona_responsable
			   AND p1.id_persona <> p2.id_persona
			   AND (
					(ISNULL(p1.fecha_hasta, GETDATE()) >= GETDATE() AND p1.fecha_desde <= GETDATE()) AND
					(ISNULL(p2.fecha_hasta, GETDATE()) >= GETDATE() AND p2.fecha_desde <= GETDATE())
			   )
			JOIN socios.Socio s1 ON s1.id_persona = p1.id_persona
			JOIN socios.Socio s2 ON s2.id_persona = p2.id_persona
			WHERE @id_socio IN (s1.id_socio, s2.id_socio)
		)
		BEGIN;
			SET @monto_categoria = @monto_categoria * 0.85;
		END;

		SET @monto_neto = @monto_neto + @monto_categoria;

		/* Nos traemos las actividades deportivas a las cuales está/estuvo
		inscripto el socio en el mes y las insertamos en DetalleDeportiva */
		INSERT INTO socios.DetalleDeportiva (
			id_inscripcion_dep, 
			id_membresia, 
			monto
		)
		SELECT 
			id_inscripcion_dep,
			@id_membresia,
			tad.valor
		FROM socios.InscripcionActividadDeportiva iad
		INNER JOIN socios.TarifaActividadDeportiva tad ON tad.id_actividad_dep = iad.id_actividad_dep
			WHERE iad.id_socio = @id_socio
				AND (iad.fecha_baja IS NULL OR iad.fecha_baja >= @primer_dia_mes)
				AND tad.vigente_desde <= @fecha_actual AND
					(tad.vigente_hasta >= @primer_dia_mes OR tad.vigente_hasta IS NULL)

		-- Guardamos el monto total de todas las actividades deportivas y la cantidad actividades.
		SELECT @monto_deportiva = SUM(tad.valor), @cantidad_act_dep = COUNT(1)
		FROM socios.InscripcionActividadDeportiva iad
		INNER JOIN socios.TarifaActividadDeportiva tad ON tad.id_actividad_dep = iad.id_actividad_dep
			WHERE iad.id_socio = @id_socio
				AND (iad.fecha_baja IS NULL OR iad.fecha_baja >= @primer_dia_mes)
				AND tad.vigente_desde <= @fecha_actual AND
					(tad.vigente_hasta >= @primer_dia_mes OR tad.vigente_hasta IS NULL)
		
		SET @monto_bruto = @monto_bruto + ISNULL(@monto_deportiva, 0);

		-- Aplicamos descuento del 10% sobre el total de las actividades deportivas si se realizan varias
		IF @cantidad_act_dep > 1
		BEGIN;
			SET @monto_deportiva = @monto_deportiva * 0.9;
		END;

		SET @monto_neto = @monto_neto + ISNULL(@monto_deportiva, 0);

		-- Finalmente actualizamos los registros
		UPDATE socios.Membresia 
			SET total_bruto = @monto_bruto, total_neto = @monto_neto
			WHERE id_membresia = @id_membresia;

		DECLARE @monto_moroso DECIMAL(10,2);
		IF EXISTS (
			SELECT 1 FROM socios.Morosidad M
				JOIN socios.Factura F 
					ON F.id_factura = M.id_factura
			WHERE MONTH(F.fecha_emision) < MONTH(GETDATE())
				AND M.ya_aplicada = 0
		)
		BEGIN
			DECLARE @id_morosidad INT;
			SELECT @monto_moroso = M.monto, @id_morosidad = M.id_morosidad FROM socios.Morosidad M
					JOIN socios.Factura F 
						ON F.id_factura = M.id_factura
				WHERE MONTH(F.fecha_emision) < MONTH(GETDATE())
					AND M.ya_aplicada = 0
			SET @monto_bruto += @monto_moroso;
			SET @monto_neto += @monto_moroso;
			UPDATE socios.Morosidad
				SET ya_aplicada = 1
				WHERE id_morosidad = @id_morosidad;
		END

		UPDATE socios.Factura 
			SET total_bruto = @monto_bruto, total_neto = @monto_neto
			WHERE id_factura = @id_factura;

		DECLARE @responsable INT = NULL;
		-- Buscamos el responsable de realizar el pago
		-- Si no está en la tabla parentesco entonces se pone al socio de la factura.
		SELECT @responsable = COALESCE(par.id_persona_responsable, s.id_persona)
		FROM socios.Socio s
		INNER JOIN socios.Persona p ON s.id_persona = p.id_persona
		LEFT JOIN socios.Parentesco par ON par.id_persona = s.id_persona
		WHERE s.id_socio = @id_socio
		AND (par.fecha_hasta >= @primer_dia_mes OR par.fecha_hasta IS NULL);

		INSERT INTO socios.FacturaResponsable(id_factura, id_persona)
			VALUES(@id_factura, @responsable);

		COMMIT TRANSACTION Tran1
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION Tran1

		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH
END
GO


/***********************************************************************
Nombre del procedimiento: socios.inscripcion_y_facturacion_completa_socio_sp
Descripción: Registra una persona y la convierte en socio, le genera una factura de la membresía
	y de la actividad deportiva a la que esté inscripto si es que lo está.
Autor: Grupo 05 - Com2900
***********************************************************************/

CREATE OR ALTER PROCEDURE socios.inscripcion_y_facturacion_completa_socio_sp
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @dni INT,
    @email VARCHAR(255) = NULL,
    @fecha_de_nacimiento DATE,
    @telefono VARCHAR(50) = NULL,
    @obra_social VARCHAR(100) = NULL,
    @nro_obra_social INT = NULL,
    @telefono_emergencia VARCHAR(50) = NULL,
	@id_act_dep INT,
	@fecha_alta_act_dep DATE = NULL,
    @id_persona INT OUTPUT,
    @id_socio INT OUTPUT,
	@id_factura INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

	BEGIN TRANSACTION tran1
	BEGIN TRY
		
		EXEC socios.inscripcion_socio_sp
			@nombre = @nombre,
			@apellido = @apellido,
			@dni = @dni,
			@email = @email,
			@fecha_de_nacimiento = @fecha_de_nacimiento,
			@telefono = @telefono,
			@obra_social = @obra_social,
			@nro_obra_social = @nro_obra_social,
			@telefono_emergencia = @telefono_emergencia,
			@id_persona = @id_persona OUTPUT,
			@id_socio = @id_socio OUTPUT;

		IF @id_socio IS NULL RETURN;

		IF @id_act_dep IS NOT NULL
		BEGIN
			-- Inscripcion actividad deportiva
			EXEC socios.inscribir_socio_a_actividad_dep_sp
				@id_socio = @id_socio,
				@id_actividad_deportiva = @id_act_dep,
				@fecha_alta = @fecha_alta_act_dep,
				@fecha_baja = NULL;
		END

		-- Facturacion de la inscripcion
		EXEC socios.facturacion_membresia_socio_sp
			@id_socio = @id_socio,
			@id_factura = @id_factura OUTPUT;

	COMMIT TRAN tran1
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION tran1

		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH

END;
GO

/***********************************************************************
Nombre del procedimiento: socios.inscripcion_y_facturacion_completa_socio_menor_sp
Descripción: Registra una persona menor de edad y la convierte en socio, le genera una factura de la membresía
	y de la actividad deportiva a la que esté inscripto si es que lo está.
Autor: Grupo 05 - Com2900
***********************************************************************/

CREATE OR ALTER PROCEDURE socios.inscripcion_y_facturacion_completa_socio_menor_sp
    -- Datos del menor
    @nombre_menor VARCHAR(50),
    @apellido_menor VARCHAR(50),
    @dni_menor INT,
    @email_menor VARCHAR(255) = NULL,
    @fecha_nac_menor DATE,
    @telefono_menor VARCHAR(50) = NULL,
    @obra_social VARCHAR(100) = NULL,
    @nro_obra_social INT = NULL,
    @telefono_emergencia VARCHAR(50) = NULL,
	@id_act_dep INT = NULL,
	@fecha_alta_act_dep DATE = NULL,

    -- Datos del responsable
    @nombre_resp VARCHAR(50) = NULL,
    @apellido_resp VARCHAR(50) = NULL,
    @dni_resp INT = NULL,
    @email_resp VARCHAR(255) = NULL,
    @fecha_nac_resp DATE = NULL,
    @telefono_resp VARCHAR(50) = NULL,
	@id_medio_de_pago_resp INT = NULL,

    -- Output
    @id_persona_menor INT OUTPUT,
    @id_socio_menor INT OUTPUT,
    @id_persona_resp INT OUTPUT,
	@id_factura INT OUTPUT,

    -- Parentesco
    @parentesco VARCHAR(10)  -- 'P', 'M' o 'T'

AS
BEGIN
    SET NOCOUNT ON;

	BEGIN TRANSACTION tran1
	BEGIN TRY
		
		EXEC socios.registrar_inscripcion_menor_sp
		    -- Datos del menor
			@nombre_menor = @nombre_menor,
			@apellido_menor = @apellido_menor,
			@dni_menor = @dni_menor,
			@email_menor = @email_menor,
			@fecha_nac_menor = @fecha_nac_menor,
			@telefono_menor = @telefono_menor,
			@obra_social = @obra_social,
			@nro_obra_social = @nro_obra_social,
			@telefono_emergencia = @telefono_emergencia,

			-- Datos del responsable
			@nombre_resp = @nombre_resp,
			@apellido_resp = @apellido_resp,
			@dni_resp = @dni_resp,
			@email_resp = @email_resp,
			@fecha_nac_resp = @fecha_nac_resp,
			@telefono_resp = @telefono_resp,
			@id_medio_de_pago_resp = @id_medio_de_pago_resp,

			-- Output
			@id_persona_menor = @id_persona_menor OUTPUT,
			@id_socio_menor = @id_socio_menor OUTPUT,
			@id_persona_resp = @id_persona_resp OUTPUT,

			-- Parentesco
			@parentesco = @parentesco  -- 'P', 'M' o 'T'
			
		IF @id_act_dep IS NOT NULL
		BEGIN
			-- Inscripcion actividad deportiva
			EXEC socios.inscribir_socio_a_actividad_dep_sp
				@id_socio = @id_socio_menor,
				@id_actividad_deportiva = @id_act_dep,
				@fecha_alta = @fecha_alta_act_dep,
				@fecha_baja = NULL;
		END

		-- Facturacion de la inscripcion
		EXEC socios.facturacion_membresia_socio_sp
			@id_socio = @id_socio_menor,
			@id_factura = @id_factura OUTPUT;

	COMMIT TRAN tran1
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION tran1

		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH

END;
GO


/***********************************************************************
Nombre del procedimiento: actualizar_datos_factura_sp
Descripción: Se actualiza la factura con el número de factura que
	devuelve AFIP / ARCA.
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE socios.actualizar_datos_factura_sp
    @id_factura INT,
	@numero_factura INT
AS
BEGIN
    SET NOCOUNT ON;
	-- Validamos si la factura existe
	IF NOT EXISTS (SELECT 1 FROM socios.Factura WHERE id_factura = @id_factura)
	BEGIN
        RAISERROR('La factura proporcionada no existe.', 16, 1);
        RETURN;
    END
	-- Validamos el numero_factura
	IF @numero_factura < 0
	BEGIN
        RAISERROR('El número de factura debe ser mayor que 0.', 16, 1);
        RETURN;
    END

	UPDATE socios.Factura SET numero_factura = @numero_factura
		WHERE id_factura = @id_factura;
END
GO

/***********************************************************************
Nombre del procedimiento: generar_factura_recreativa_sp
Descripción: Se realiza la creación de la factura con las actividades
	recreativas.
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE socios.generar_factura_recreativa_sp
    @id_socio INT
AS
BEGIN
    SET NOCOUNT ON;
	-- Validamos si el socio existe
	IF NOT EXISTS (SELECT 1 FROM socios.Socio WHERE id_socio = @id_socio
		AND activo = 1)
	BEGIN
        RAISERROR('El socio proporcionado no existe.', 16, 1);
        RETURN;
    END

	DECLARE @fecha_actual DATE = GETDATE(),
			@id_factura INT,
			@monto_recreativa DECIMAL(10,2) = 0;

	-- Calculamos primer dia del mes
	DECLARE @primer_dia_mes DATE = DATEFROMPARTS(YEAR(@fecha_actual),MONTH(@fecha_actual), 1);

	BEGIN TRANSACTION Tran1
	BEGIN TRY
		-- Generamos el registro de factura inicial
		INSERT INTO socios.Factura (fecha_emision, total_bruto, total_neto)
			VALUES (@fecha_actual, 0, 0);
		SET @id_factura = SCOPE_IDENTITY();

		-- Calculamos la edad del socio
		DECLARE @edad SMALLINT;
		SELECT @edad = socios.fn_obtener_edad_por_fnac(p.fecha_de_nacimiento)
			FROM socios.Socio s
			INNER JOIN socios.Persona p ON p.id_persona = s.id_persona
			WHERE s.id_socio = @id_socio;

		/* Nos traemos las actividades recreativas a las cuales está/estuvo
		inscripto el socio en el mes y las insertamos en DetalleRecreativa */
		INSERT INTO socios.DetalleRecreativa (
			id_inscripcion_rec, 
			id_factura, 
			monto
		)
		SELECT 
			iar.id_inscripcion_rec,
			@id_factura,
			tar.valor
		FROM socios.InscripcionActividadRecreativa iar
		INNER JOIN socios.TarifaActividadRecreativa tar ON tar.id_actividad_rec = iar.id_actividad_rec
			WHERE iar.id_socio = @id_socio
				AND NOT EXISTS (
					SELECT 1 FROM socios.DetalleRecreativa dr WHERE dr.id_inscripcion_rec = iar.id_inscripcion_rec
				) -- Si ya esta en la tabla de Detalles quiere decir que ya esta facturado entonces no lo tenemos en cuenta
				AND (iar.fecha_baja IS NULL OR iar.fecha_baja >= @primer_dia_mes)
				AND tar.vigente_desde <= @fecha_actual AND
					(tar.vigente_hasta >= @primer_dia_mes OR tar.vigente_hasta IS NULL)
				AND tar.modalidad = iar.modalidad
				AND tar.invitado = 0 -- La tarifa corresponde a socios
				AND (
					tar.edad_maxima >= @edad
					OR
					-- En caso de que la edad sea menor a una edad_maxima no debe traer 
					-- el registro con edad_maxima = NULL
					(tar.edad_maxima IS NULL AND NOT EXISTS (
						SELECT 1 
						FROM socios.TarifaActividadRecreativa tar2
						WHERE tar2.id_actividad_rec = tar.id_actividad_rec
							AND tar2.vigente_desde <= @fecha_actual
							AND (tar2.vigente_hasta >= @fecha_actual OR tar2.vigente_hasta IS NULL)
							AND tar2.modalidad = tar.modalidad
							AND tar2.invitado = tar.invitado
							AND tar2.edad_maxima >= @edad
						)
					)
				);

		-- Sumamos el monto todos los detalles facturados
		SELECT @monto_recreativa = SUM(monto) FROM socios.DetalleRecreativa WHERE id_factura = @id_factura
		
		-- Si no hay monto no hay factura para generar
		IF @monto_recreativa IS NULL OR @monto_recreativa = 0
		BEGIN
			ROLLBACK TRANSACTION Tran1
			RETURN;
		END

		-- Actualizamos la factura con los montos calculados
		UPDATE socios.Factura 
			SET total_bruto = @monto_recreativa, total_neto = @monto_recreativa
			WHERE id_factura = @id_factura;

		DECLARE @responsable INT = NULL;
		-- Buscamos el responsable de realizar el pago
		-- Si no está en la tabla parentesco entonces se pone al socio de la factura.
		SELECT @responsable = COALESCE(par.id_persona_responsable, s.id_persona)
		FROM socios.Socio s
		INNER JOIN socios.Persona p ON s.id_persona = p.id_persona
		LEFT JOIN socios.Parentesco par ON par.id_persona = s.id_persona
		WHERE s.id_socio = @id_socio
		AND (par.fecha_hasta >= @primer_dia_mes OR par.fecha_hasta IS NULL);

		INSERT INTO socios.FacturaResponsable(id_factura, id_persona)
			VALUES(@id_factura, @responsable);

		COMMIT TRANSACTION Tran1
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION Tran1

		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH
END
GO

/***********************************************************************
Nombre del procedimiento: generar_factura_recreativa_invitado_sp
Descripción: Se realiza la creación de la factura con la actividad
	recreativa a la que asistió el invitado.
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE socios.generar_factura_recreativa_invitado_sp
    @id_persona INT, -- Invitado
	@id_inscripcion_rec INT, -- Actividad a la cual el socio esta incripto y lo invito
	@id_factura INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
	-- Validamos si la persona existe. Los datos del invitado debieron ser registrados previamente
	IF NOT EXISTS (SELECT 1 FROM socios.Persona WHERE id_persona = @id_persona)
	BEGIN
        RAISERROR('El invitado proporcionado no existe.', 16, 1);
        RETURN;
    END

	-- Validamos si la inscripcion a la cual fue invitado existe
	IF NOT EXISTS (SELECT 1 FROM socios.InscripcionActividadRecreativa WHERE id_actividad_rec = @id_inscripcion_rec)
	BEGIN
        RAISERROR('No hay invitación por parte de un socio.', 16, 1);
        RETURN;
    END

	-- Si la invitacion existe, validamos si el socio que invitó está activo
	IF NOT EXISTS (
		SELECT 1 FROM socios.Socio S
			JOIN socios.InscripcionActividadRecreativa I
				ON S.id_socio = I.id_socio
		WHERE S.activo = 1
	)
	BEGIN
	    RAISERROR('El socio que invita no está activo.', 16, 1);
        RETURN;
	END

	DECLARE @fecha_actual DATE = GETDATE(),
			@monto_recreativa DECIMAL(10,2) = 0;

	BEGIN TRANSACTION Tran1
	BEGIN TRY
		-- Generamos el registro de factura inicial
		INSERT INTO socios.Factura (fecha_emision, total_bruto, total_neto)
			VALUES (@fecha_actual, 0, 0);
		SET @id_factura = SCOPE_IDENTITY();

		-- Calculamos la edad del invitado
		DECLARE @edad SMALLINT;
		SELECT @edad = socios.fn_obtener_edad_por_fnac(fecha_de_nacimiento)
			FROM socios.Persona WHERE id_persona = @id_persona;

		-- Buscamos la actividad recreativa a la que asiste
		DECLARE @id_actividad_rec INT;
		SELECT @id_actividad_rec = id_actividad_rec
			FROM socios.InscripcionActividadRecreativa
			WHERE id_inscripcion_rec = @id_inscripcion_rec;

		-- Obtenemos el valor de la entrada para invitado
		SELECT @monto_recreativa = valor 
			FROM socios.TarifaActividadRecreativa tar
			WHERE tar.id_actividad_rec = @id_actividad_rec
				AND tar.vigente_desde <= @fecha_actual
				AND (tar.vigente_hasta >= @fecha_actual OR tar.vigente_hasta IS NULL)
				AND tar.modalidad = 'Día'
				AND tar.invitado = 1 -- La tarifa corresponde a invitados
				AND (
					tar.edad_maxima >= @edad
					OR
					-- En caso de que la edad sea menor a una edad_maxima no debe traer 
					-- el registro con edad_maxima = NULL
					(tar.edad_maxima IS NULL AND NOT EXISTS (
						SELECT 1 
						FROM socios.TarifaActividadRecreativa tar2
						WHERE tar2.id_actividad_rec = tar.id_actividad_rec
							AND tar2.vigente_desde <= @fecha_actual
							AND (tar2.vigente_hasta >= @fecha_actual OR tar2.vigente_hasta IS NULL)
							AND tar2.modalidad = tar.modalidad
							AND tar2.invitado = tar.invitado
							AND tar2.edad_maxima >= @edad
						)
					)
				);

		/* Generamos el registro del Detalle de la Invitacion */
		INSERT INTO socios.DetalleInvitacion(
			id_inscripcion_rec,
			id_persona_invitada,
			id_factura,
			monto,
			fecha
		)
		VALUES (
			@id_inscripcion_rec,
			@id_persona,
			@id_factura,
			@monto_recreativa,
			@fecha_actual
		);

		-- Actualizamos la factura con el monto obtenido
		UPDATE socios.Factura 
			SET total_bruto = @monto_recreativa, total_neto = @monto_recreativa
			WHERE id_factura = @id_factura;

		DECLARE @responsable INT = NULL;
		-- Buscamos el responsable de realizar el pago
		-- Si no está en la tabla parentesco entonces se pone a la misma persona invitada.
		SELECT @responsable = COALESCE(par.id_persona_responsable, p.id_persona)
		FROM socios.Persona p
		LEFT JOIN socios.Parentesco par ON par.id_persona = p.id_persona
		WHERE p.id_persona = @id_persona
		AND (par.fecha_hasta >= @fecha_actual OR par.fecha_hasta IS NULL);

		INSERT INTO socios.FacturaResponsable(id_factura, id_persona)
			VALUES(@id_factura, @responsable);

		COMMIT TRANSACTION Tran1
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION Tran1

		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH
END
GO
