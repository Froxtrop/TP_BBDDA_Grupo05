/***********************************************************************
 * Enunciado: Entrega 5, importaci�n de archivos maestros.
 *
 * Fecha de entrega: 01/07/2025
 *
 * N�mero de comisi�n: 2900
 * N�mero de grupo: 05
 * Materia: Bases de datos aplicada
 *
 * Integrantes:
 *		- 44689109 | Crego, Agustina
 *		- 44510837 | Crotti, Tom�s
 *		- 44792728 | Hoffmann, Francisco Gabriel
 *
 ***********************************************************************/
USE Com2900G05
GO

/*	 ___                     _            _                              _       
	|_ _|_ __  ___  ___ _ __(_)_ __   ___(_) ___  _ __    ___  ___   ___(_) ___  
	 | || '_ \/ __|/ __| '__| | '_ \ / __| |/ _ \| '_ \  / __|/ _ \ / __| |/ _ \ 
	 | || | | \__ \ (__| |  | | |_) | (__| | (_) | | | | \__ \ (_) | (__| | (_) |
	|___|_| |_|___/\___|_|  |_| .__/ \___|_|\___/|_| |_| |___/\___/ \___|_|\___/ 
                          |_|                                                
*/


/***********************************************************************
Nombre del procedimiento: socios.cargar_responsables_de_pago_csv_sp
Descripci�n: Carga los datos del archivo responsables-de-pago.csv a una tabla temporal y
	luego los inserta en las tablas correspondientes.
Autor: Grupo 05 - Com2900
***********************************************************************/

CREATE OR ALTER PROCEDURE socios.cargar_responsables_de_pago_csv_sp
    @ruta_archivo NVARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;

    -- Tabla de Staging para reflejar el CSV.
	IF OBJECT_ID('socios.Staging_ResponsablesPago', 'U') IS NOT NULL
        DROP TABLE socios.Staging_ResponsablesPago;

    CREATE TABLE socios.Staging_ResponsablesPago (
        Nro_Socio VARCHAR(100), Nombre VARCHAR(255), Apellido VARCHAR(255),
        DNI VARCHAR(100), Email VARCHAR(255), Fecha_Nacimiento VARCHAR(100),
        Telefono_Contacto VARCHAR(100), Telefono_Emergencia_1 VARCHAR(100),
        Obra_Social VARCHAR(255), Nro_Obra_Social VARCHAR(100),
        Telefono_Emergencia_2 VARCHAR(100)
    );

    BEGIN TRY
        -- Paso 1: Cargar el CSV a la tabla de staging.
        DECLARE @sql NVARCHAR(MAX);
        SET @sql = N'BULK INSERT socios.Staging_ResponsablesPago FROM '''
		           + @ruta_archivo + N''' WITH (
				   FIRSTROW = 2, 
				   FIELDTERMINATOR = '';'',
				   ROWTERMINATOR = ''0x0a'',
				   CODEPAGE = ''65001'');';

        PRINT 'Ejecutando BULK INSERT...';
        EXEC sp_executesql @sql;
        PRINT 'BULK INSERT exitoso.';

        IF NOT EXISTS (SELECT 1 FROM socios.Staging_ResponsablesPago)
        BEGIN
            RAISERROR('No se cargaron filas desde el archivo CSV.', 16, 1);
            RETURN;
        END

        -- >>>>>>>> CAMBIO 1: Habilitar la inserci�n expl�cita de identidad <<<<<<<<<<
        PRINT 'Habilitando IDENTITY_INSERT para socios.Socio...';
        SET IDENTITY_INSERT socios.Socio ON;

        -- Paso 2: Procesar los datos.
        SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS id_row, * INTO #TempProcess FROM socios.Staging_ResponsablesPago;
        DECLARE @max INT = @@ROWCOUNT, @i INT = 1;

        -- Variables
        DECLARE @nro_socio_csv VARCHAR(50), @id_socio_manual INT, @apellido_csv VARCHAR(50), @nombre_csv VARCHAR(50),
                @dni_csv BIGINT, @email_csv VARCHAR(255), @fecha_nac_csv DATE, @telefono_csv VARCHAR(50),
                @id_categoria SMALLINT, @obra_social_csv VARCHAR(100), @nro_obra_social_varchar VARCHAR(50),
                @telefono_emergencia_csv VARCHAR(50), @id_persona_out INT, @edad INT;

        WHILE @i <= @max
        BEGIN
            -- Resetear variables
            SELECT @fecha_nac_csv = NULL, @id_categoria = NULL, @id_socio_manual = NULL;

            -- Extraer datos de la fila
            SELECT
                @nro_socio_csv = TRIM(Nro_Socio), @nombre_csv = TRIM(Nombre), @apellido_csv = TRIM(Apellido),
                @dni_csv = TRY_CAST(DNI AS BIGINT), @email_csv = TRIM(LOWER(REPLACE(Email, ' ', ''))),
                @fecha_nac_csv = TRY_CONVERT(DATE, Fecha_Nacimiento, 103), @telefono_csv = TRIM(Telefono_Contacto),
                @obra_social_csv = TRIM(Obra_Social), @nro_obra_social_varchar = TRY_CAST(REPLACE(Nro_Obra_Social, '%-', '') AS INT),
                @telefono_emergencia_csv = TRIM(Telefono_Emergencia_1)
            FROM #TempProcess WHERE id_row = @i;

            -- >>>>>>>> CAMBIO 2: Extraer el ID num�rico del Nro de Socio <<<<<<<<<<
            SET @id_socio_manual = TRY_CAST(REPLACE(@nro_socio_csv, 'SN-', '') AS INT);

            -- Validaciones de datos cr�ticos
            IF @id_socio_manual IS NULL OR @fecha_nac_csv IS NULL
            BEGIN
                PRINT 'ADVERTENCIA: Fila ' + CAST(@i AS VARCHAR) + ' omitida. Motivo: Nro de Socio: ' + CAST(@id_socio_manual AS VARCHAR) + ' o Fecha de Nacimiento inv�lidos en el CSV.';
                SET @i += 1; CONTINUE;
            END

            -- B�squeda din�mica de Categor�a (usando tus funciones)
            SET @edad = socios.fn_obtener_edad_por_fnac(@fecha_nac_csv);
            SET @id_categoria = socios.fn_obtener_categoria_por_edad(@edad);
            IF @id_categoria IS NULL
            BEGIN
                PRINT 'ADVERTENCIA: Fila ' + CAST(@i AS VARCHAR) + ' (Socio ID: ' + CAST(@id_socio_manual AS VARCHAR) + ') omitida. Motivo: No se encontr� categor�a para la edad ' + CAST(@edad AS VARCHAR) + '.';
                SET @i += 1; CONTINUE;
            END

            BEGIN TRY
                BEGIN TRANSACTION;
                -- Se inserta la Persona usando tu SP, ya que su ID es autogenerado.
                EXEC socios.registrar_persona_sp
                    @nombre = @nombre_csv, @apellido = @apellido_csv, @dni = @dni_csv, @email = @email_csv,
                    @fecha_de_nacimiento = @fecha_nac_csv, @telefono = @telefono_csv, @saldo = 0,
					@id_medio_de_pago = NULL, @id_persona = @id_persona_out OUTPUT;

                -- >>>>>>>> CAMBIO 3: Insertar el Socio directamente con el ID manual <<<<<<<<<<
                -- No podemos usar 'registrar_socio_sp' porque necesitamos especificar el 'id_socio'.
                INSERT INTO socios.Socio (
                    id_socio, id_persona, id_categoria, fecha_de_alta, activo,
                    obra_social, nro_obra_social, telefono_emergencia
                )
                VALUES (
                    @id_socio_manual, @id_persona_out, @id_categoria, GETDATE(), 1,
                    @obra_social_csv, @nro_obra_social_varchar, -- La columna nro_obra_social ahora debe ser VARCHAR
                    @telefono_emergencia_csv
                );
                COMMIT TRANSACTION;
            END TRY
            BEGIN CATCH
                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
                PRINT 'ERROR: Fila ' + CAST(@i AS VARCHAR) + ' (Socio ID: ' + CAST(@id_socio_manual AS VARCHAR) + ') no se pudo procesar. Error: ' + ERROR_MESSAGE();
            END CATCH;

            SET @i += 1;
        END

        -- >>>>>>>> CAMBIO 4: Deshabilitar la inserci�n expl�cita y reajustar el contador <<<<<<<<<<
        PRINT 'Deshabilitando IDENTITY_INSERT para socios.Socio...';
        SET IDENTITY_INSERT socios.Socio OFF;

        DROP TABLE #TempProcess;
        PRINT 'Proceso de carga finalizado.';

    END TRY
    BEGIN CATCH
        -- Bloque de seguridad para asegurar que IDENTITY_INSERT siempre se apague.
        IF SESSIONPROPERTY('IDENTITY_INSERT') = OBJECT_ID('socios.Socio')
        BEGIN
            PRINT 'Error fatal, deshabilitando IDENTITY_INSERT por seguridad...';
            SET IDENTITY_INSERT socios.Socio OFF;
        END
        PRINT 'Error fatal en el procedimiento: ' + ERROR_MESSAGE();
        IF OBJECT_ID('tempdb..#TempProcess') IS NOT NULL
			DROP TABLE #TempProcess;
    END CATCH
END
GO

/*		 ___                     _            _                              _       
		|_ _|_ __  ___  ___ _ __(_)_ __   ___(_) ___  _ __    ___  ___   ___(_) ___  
		 | || '_ \/ __|/ __| '__| | '_ \ / __| |/ _ \| '_ \  / __|/ _ \ / __| |/ _ \ 
		 | || | | \__ \ (__| |  | | |_) | (__| | (_) | | | | \__ \ (_) | (__| | (_) |
		|___|_| |_|___/\___|_|  |_| .__/ \___|_|\___/|_| |_| |___/\___/ \___|_|\___/ 
		 _ __ ___   ___ _ __   ___|_| __                                             
		| '_ ` _ \ / _ \ '_ \ / _ \| '__|                                            
		| | | | | |  __/ | | | (_) | |                                               
		|_| |_| |_|\___|_| |_|\___/|_|                                               
*/


/***********************************************************************
Nombre del procedimiento: socios.cargar_grupo_familiar_csv_sp
Descripci�n: Carga los datos del archivo grupo-familiar.csv a una tabla temporal y
	luego los inserta en las tablas correspondientes.
Autor: Grupo 05 - Com2900
***********************************************************************/

CREATE OR ALTER PROCEDURE socios.cargar_grupo_familiar_csv_sp
    @ruta_archivo NVARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;

    -- Crear tabla de staging
    IF OBJECT_ID('socios.Staging_GrupoFamiliar', 'U') IS NOT NULL
        DROP TABLE socios.Staging_GrupoFamiliar;

    CREATE TABLE socios.Staging_GrupoFamiliar (
        Nro_Socio_Menor VARCHAR(100),
        Nro_Socio_Responsable VARCHAR(100),
        Nombre VARCHAR(255),
        Apellido VARCHAR(255),
        DNI VARCHAR(100),
        Email VARCHAR(255),
        Fecha_Nacimiento VARCHAR(100),
        Telefono_Contacto VARCHAR(100),
        Telefono_Emergencia VARCHAR(100),
        Obra_Social VARCHAR(255),
        Nro_Obra_Social VARCHAR(100)
    );

    BEGIN TRY
        -- Cargar el CSV a staging
        DECLARE @sql NVARCHAR(MAX);
        SET @sql = N'BULK INSERT socios.Staging_GrupoFamiliar FROM ''' 
                   + @ruta_archivo + N''' WITH (
                       FIRSTROW = 2,
                       FIELDTERMINATOR = '';'',
                       ROWTERMINATOR = ''0x0a'',
                       CODEPAGE = ''65001''
                   );';

        EXEC sp_executesql @sql;

        IF NOT EXISTS (SELECT 1 FROM socios.Staging_GrupoFamiliar)
        BEGIN
            RAISERROR('No se cargaron filas desde el archivo CSV.', 16, 1);
            RETURN;
        END;

        -- Crear tabla temporal
        CREATE TABLE #TempGrupo (
            id_row INT,
            Nro_Socio_Menor VARCHAR(100),
            Nro_Socio_Responsable VARCHAR(100),
            Nombre VARCHAR(255),
            Apellido VARCHAR(255),
            DNI VARCHAR(100),
            Email VARCHAR(255),
            Fecha_Nacimiento VARCHAR(100),
            Telefono_Contacto VARCHAR(100),
            Telefono_Emergencia VARCHAR(100),
            Obra_Social VARCHAR(255),
            Nro_Obra_Social VARCHAR(100)
        );
        INSERT INTO #TempGrupo
        SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS id_row, *
        FROM socios.Staging_GrupoFamiliar;

        DECLARE @max INT = @@ROWCOUNT, @i INT = 1;

        -- Variables
        DECLARE @nro_menor VARCHAR(50), @nro_responsable VARCHAR(50),
                @id_socio_menor INT, @id_socio_resp INT,
                @id_persona_resp INT, @id_persona_menor INT,
                @nombre VARCHAR(255), @apellido VARCHAR(255),
                @dni BIGINT, @email VARCHAR(255), @fecha_nac DATE,
                @telefono VARCHAR(50), @telefono_emergencia VARCHAR(50),
                @obra_social VARCHAR(100), @nro_obra_social VARCHAR(50),
                @edad INT, @id_categoria SMALLINT;

        SET IDENTITY_INSERT socios.Socio ON;

        WHILE @i <= @max
        BEGIN
            -- Reset
            SET @id_persona_resp = NULL;
            SET @id_persona_menor = NULL;
            SET @id_categoria = NULL;

            -- Obtener datos
            SELECT
                @nro_menor = TRIM(Nro_Socio_Menor),
                @nro_responsable = TRIM(Nro_Socio_Responsable),
                @nombre = TRIM(Nombre),
                @apellido = TRIM(Apellido),
                @dni = TRY_CAST(DNI AS BIGINT),
                @email = TRIM(LOWER(REPLACE(Email, ' ', ''))),
                @fecha_nac = TRY_CONVERT(DATE, Fecha_Nacimiento, 103),
                @telefono = TRIM(Telefono_Contacto),
                @telefono_emergencia = TRIM(Telefono_Emergencia),
                @obra_social = TRIM(Obra_Social),
                @nro_obra_social = TRY_CAST(REPLACE(Nro_Obra_Social, '%-', '') AS INT)
            FROM #TempGrupo WHERE id_row = @i;

            SET @id_socio_menor = TRY_CAST(REPLACE(@nro_menor, 'SN-', '') AS INT);
            SET @id_socio_resp = TRY_CAST(REPLACE(@nro_responsable, 'SN-', '') AS INT);

            IF @id_socio_menor IS NULL OR @id_socio_resp IS NULL OR @fecha_nac IS NULL
            BEGIN
                PRINT 'ADVERTENCIA: Fila ' + CAST(@i AS VARCHAR) + ' omitida. Datos faltantes.';
                SET @i += 1; CONTINUE;
            END

            -- Buscar id_persona del socio responsable
            SELECT @id_persona_resp = id_persona
            FROM socios.Socio
            WHERE id_socio = @id_socio_resp;

            IF @id_persona_resp IS NULL
            BEGIN
                PRINT 'ERROR: Fila ' + CAST(@i AS VARCHAR) + '. Socio responsable: ' + ISNULL(@id_socio_resp, 'NULL') + ' no encontrado.';
                SET @i += 1; CONTINUE;
            END

            -- Categor�a
            SET @edad = socios.fn_obtener_edad_por_fnac(@fecha_nac);
            SET @id_categoria = socios.fn_obtener_categoria_por_edad(@edad);

            IF @id_categoria IS NULL
            BEGIN
                PRINT 'ERROR fila ' + CAST(@i AS VARCHAR) + ': Categoria no encontrada.';
                SET @i += 1; CONTINUE;
            END

            BEGIN TRY
                BEGIN TRANSACTION;

                EXEC socios.registrar_persona_sp
                    @nombre = @nombre, @apellido = @apellido, @dni = @dni,
                    @email = @email, @fecha_de_nacimiento = @fecha_nac,
                    @telefono = @telefono, @saldo = 0,
					@id_medio_de_pago = NULL,
                    @id_persona = @id_persona_menor OUTPUT;

                -- Alta socio menor (ID expl�cito)
                INSERT INTO socios.Socio (
                    id_socio, id_persona, id_categoria, fecha_de_alta, activo,
                    obra_social, nro_obra_social, telefono_emergencia
                )
                VALUES (
                    @id_socio_menor, @id_persona_menor, @id_categoria, GETDATE(), 1,
                    @obra_social, @nro_obra_social, @telefono_emergencia
                );

                -- Parentesco
                INSERT INTO socios.Parentesco (id_persona, id_persona_responsable, parentesco, fecha_desde, fecha_hasta)
                VALUES (@id_persona_menor, @id_persona_resp, 'T', GETDATE(), DATEADD(YEAR, 18, @fecha_nac));

                COMMIT TRANSACTION;
            END TRY
            BEGIN CATCH
                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
                PRINT 'ERROR: Fila ' + CAST(@i AS VARCHAR) + '. Error: ' + ERROR_MESSAGE();
            END CATCH;

            SET @i += 1;
        END

        SET IDENTITY_INSERT socios.Socio OFF;

		DROP TABLE #TempGrupo;
        PRINT 'Carga de grupo familiar finalizada.';

    END TRY
    BEGIN CATCH
        IF SESSIONPROPERTY('IDENTITY_INSERT') = OBJECT_ID('socios.Socio')
        BEGIN
            PRINT 'Error fatal, deshabilitando IDENTITY_INSERT...';
            SET IDENTITY_INSERT socios.Socio OFF;
        END
    END CATCH
END
GO


/*
     _        _     _                  _       
    / \   ___(_)___| |_ ___ _ __   ___(_) __ _ 
   / _ \ / __| / __| __/ _ \ '_ \ / __| |/ _` |
  / ___ \\__ \ \__ \ ||  __/ | | | (__| | (_| |
 /_/   \_\___/_|___/\__\___|_| |_|\___|_|\__,_|
                                               
*/

/***********************************************************************
Nombre del procedimiento: socios.cargar_asistencia_actividad_csv_sp
Descripci�n: Carga los datos del archivo presentismo-actividades.csv a una tabla temporal y
	luego los inserta en las tablas correspondientes.
Autor: Grupo 05 - Com2900
***********************************************************************/

CREATE OR ALTER PROCEDURE socios.cargar_asistencia_actividad_csv_sp
    @ruta_archivo NVARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('socios.Staging_AsistenciaActividad', 'U') IS NOT NULL
        DROP TABLE socios.Staging_AsistenciaActividad;

    CREATE TABLE socios.Staging_AsistenciaActividad (
        Nro_Socio VARCHAR(100),
        Actividad VARCHAR(255),
        Fecha_Asistencia VARCHAR(100),
        Asistencia VARCHAR(10),
        Profesor VARCHAR(100)
    );

    BEGIN TRY
        DECLARE @sql NVARCHAR(MAX);
        SET @sql = N'
            BULK INSERT socios.Staging_AsistenciaActividad
            FROM ''' + @ruta_archivo + '''
            WITH (
                FIRSTROW = 2,
                FIELDTERMINATOR = '';'',
                ROWTERMINATOR = ''0x0a'',
                CODEPAGE = ''65001''
            );';
        EXEC sp_executesql @sql;

        IF NOT EXISTS (SELECT 1 FROM socios.Staging_AsistenciaActividad)
        BEGIN
            RAISERROR('No se cargaron filas desde el archivo.', 16, 1);
            RETURN;
        END

        -- Tabla temporal con flag de primera asistencia por socio+actividad
        SELECT 
            ROW_NUMBER() OVER (PARTITION BY TRIM(Nro_Socio), TRIM(Actividad) ORDER BY TRY_CONVERT(DATE, Fecha_Asistencia, 103)) AS orden_asistencia,
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS id_row,
            TRIM(Nro_Socio) AS Nro_Socio,
            TRIM(Actividad) AS Actividad,
            TRY_CONVERT(DATE, Fecha_Asistencia, 103) AS Fecha_Asistencia,
            TRIM(Asistencia) AS Asistencia,
            TRIM(REPLACE(Profesor, ';', '')) AS Profesor
        INTO #TempAsistencia
        FROM socios.Staging_AsistenciaActividad;

        DECLARE @max INT = @@ROWCOUNT, @i INT = 1;
        DECLARE @nro_socio VARCHAR(50), @id_socio INT, @actividad VARCHAR(255), @id_actividad INT,
                @fecha DATE, @asistencia VARCHAR(10), @profesor VARCHAR(50), @email_profesor VARCHAR(255),
                @orden INT;

        WHILE @i <= @max
        BEGIN
            SET @id_socio = NULL;
            SET @id_actividad = NULL;

            SELECT 
                @nro_socio = Nro_Socio,
                @actividad = Actividad,
                @fecha = Fecha_Asistencia,
                @asistencia = Asistencia,
                @profesor = Profesor,
                @orden = orden_asistencia
            FROM #TempAsistencia
            WHERE id_row = @i;

            SET @id_socio = TRY_CAST(REPLACE(@nro_socio, 'SN-', '') AS INT);

            IF @id_socio IS NULL
            BEGIN
                PRINT 'ERROR fila ' + CAST(@i AS VARCHAR) + ': Nro de socio inv�lido. -> "' + CAST(@id_socio AS VARCHAR) + '"';
                SET @i += 1; CONTINUE;
            END

            SELECT @id_actividad = id_actividad_dep
            FROM socios.ActividadDeportiva
            WHERE nombre = @actividad;

            IF @id_actividad IS NULL
            BEGIN
                PRINT 'ERROR fila ' + CAST(@i AS VARCHAR) + ': Actividad "' + ISNULL(@actividad, 'NULL') + '" no encontrada.';
                SET @i += 1; CONTINUE;
            END

            IF @fecha IS NULL
            BEGIN
                PRINT 'ERROR fila ' + CAST(@i AS VARCHAR) + ': Fecha de asistencia inv�lida. -> "' + CONVERT(VARCHAR, @fecha, 103) + '"';
                SET @i += 1; CONTINUE;
            END
			
			IF LEN(@asistencia) > 1
			BEGIN
				PRINT 'ERROR fila ' + CAST(@i AS VARCHAR) + ': Tipo de asistencia inv�lido -> "' + ISNULL(@asistencia, 'NULL') + '"';
				SET @i += 1; CONTINUE;
			END

            DECLARE @nombre_limpio NVARCHAR(100);
			-- Eliminar saltos de l�nea
			SET @profesor = REPLACE(@profesor, CHAR(13), '');
			SET @profesor = REPLACE(@profesor, CHAR(10), '');
			SET @nombre_limpio = REPLACE(TRIM(@profesor), ' ', '');
			SET @email_profesor = LOWER(@nombre_limpio + '@gmail.com');


            -- Si es la primera asistencia de ese socio en esa actividad, lo inscribimos
            IF @orden = 1
            BEGIN
                BEGIN TRY
                    EXEC socios.inscribir_socio_a_actividad_dep_sp
                        @id_socio = @id_socio,
                        @id_actividad_deportiva = @id_actividad,
						@fecha_alta = @fecha,
						@fecha_baja = NULL;
                END TRY
                BEGIN CATCH
                    PRINT 'ERROR inscripci�n fila ' + CAST(@i AS VARCHAR) + ': ' + ERROR_MESSAGE();
                    -- CONTINUE con asistencia de todas formas, por si ya estaba inscripto
                END CATCH
            END

            BEGIN TRY
                EXEC socios.asistencia_socio_a_actividad_dep_sp
                    @id_socio = @id_socio,
                    @id_actividad_deportiva = @id_actividad,
                    @fecha_asistencia = @fecha,
                    @asistencia = @asistencia,
                    @profesor = @profesor,
                    @email_profesor = @email_profesor;
            END TRY
            BEGIN CATCH
                PRINT 'ERROR asistencia fila ' + CAST(@i AS VARCHAR) + ': ' + ERROR_MESSAGE();
            END CATCH;

            SET @i += 1;
        END

        DROP TABLE #TempAsistencia;
        PRINT 'Proceso de carga de asistencias finalizado.';

    END TRY
    BEGIN CATCH
        IF OBJECT_ID('tempdb..#TempAsistencia') IS NOT NULL DROP TABLE #TempAsistencia;
        PRINT 'ERROR fatal en el procedimiento: ' + ERROR_MESSAGE();
    END CATCH
END
GO
