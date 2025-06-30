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

 /***********************************************************************
Nombre de la función: socios.fn_obtener_edad_por_fnac
Descripción: Retorna la edad correspondiente a una fecha de nacimiento dada.
***********************************************************************/

CREATE OR ALTER FUNCTION socios.fn_obtener_edad_por_fnac(
	@fnac DATE
)
RETURNS SMALLINT
AS
BEGIN
	DECLARE @edad INT = DATEDIFF(YEAR, @fnac, GETDATE());
    IF (MONTH(@fnac) > MONTH(GETDATE())) OR 
       (MONTH(@fnac) = MONTH(GETDATE()) AND DAY(@fnac) > DAY(GETDATE()))
    BEGIN
        SET @edad = @edad - 1;
    END
	RETURN @edad;
END
GO

/***********************************************************************
Nombre de la función: socios.fn_obtener_categoria_por_edad
Descripción: Retorna el id_categoria correspondiente a una edad dada.
***********************************************************************/

CREATE OR ALTER FUNCTION socios.fn_obtener_categoria_por_edad (
    @edad SMALLINT
)
RETURNS SMALLINT
AS
BEGIN
    DECLARE @id_categoria SMALLINT;

    SELECT TOP 1 @id_categoria = id_categoria
    FROM socios.Categoria
    WHERE @edad >= edad_min AND (@edad <= edad_max OR edad_max IS NULL);

    RETURN @id_categoria;
END
GO

/*		 ____  _____ ____  ____   ___  _   _    _    
		|  _ \| ____|  _ \/ ___| / _ \| \ | |  / \   
		| |_) |  _| | |_) \___ \| | | |  \| | / ^ \  
		|  __/| |___|  _ < ___) | |_| | |\  |/ ___ \ 
		|_|   |_____|_| \_\____/ \___/|_| \_/_/   \_\
*/
USE Com2900G05;
GO

/***********************************************************************
Nombre del procedimiento: socios.registrar_persona_sp
Descripción: Registra una persona en la tabla [Persona] validando datos.
Devuelve el id_persona insertado por parámetro OUTPUT.
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE socios.registrar_persona_sp
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @dni INT,
    @email VARCHAR(255) = NULL,
    @fecha_de_nacimiento DATE,
    @telefono VARCHAR(50) = NULL,
    @saldo DECIMAL(10,2) = 0,
    @id_persona INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validación: DNI único
    IF EXISTS (SELECT 1 FROM socios.Persona WHERE dni = @dni)
    BEGIN
        RAISERROR('[Error] socios.registrar_persona_sp: Ya existe una persona con ese DNI.', 16, 1);
        RETURN;
    END

    -- Validación: Fecha de nacimiento no futura
    IF @fecha_de_nacimiento > CAST(GETDATE() AS DATE)
    BEGIN
        RAISERROR('[Error] socios.registrar_persona_sp: La fecha de nacimiento no puede ser futura.', 16, 1);
        RETURN;
    END

    -- Validación: Email básico
    IF @email IS NOT NULL AND @email NOT LIKE '%@%.%'
    BEGIN
        RAISERROR('[Error] socios.registrar_persona_sp: El email ingresado no es válido.', 16, 1);
        RETURN;
    END

    -- Validación: Saldo no negativo
    IF @saldo < 0
    BEGIN
        RAISERROR('[Error] socios.registrar_persona_sp: El saldo no puede ser negativo.', 16, 1);
        RETURN;
    END

    -- Inserción
    INSERT INTO socios.Persona (
        nombre, apellido, dni, email, fecha_de_nacimiento, telefono, saldo
    ) VALUES (
        @nombre, @apellido, @dni, @email, @fecha_de_nacimiento, @telefono, @saldo
    );

    -- Retorna el id de la persona que acaba de insertar
    SET @id_persona = SCOPE_IDENTITY();
END
GO

/***********************************************************************
Nombre del procedimiento: socios.actualizar_persona_sp
Descripción: Actualiza los datos de una persona existente validando cambios.
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE socios.actualizar_persona_sp
    @id_persona INT,
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @dni INT,
    @email VARCHAR(255) = NULL,
    @fecha_de_nacimiento DATE,
    @telefono VARCHAR(50) = NULL,
    @saldo DECIMAL(10,2) = 0
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar existencia de la persona
    IF NOT EXISTS (SELECT 1 FROM socios.Persona WHERE id_persona = @id_persona)
    BEGIN
        RAISERROR('[Error] socios.actualizar_persona_sp: La persona indicada no existe.', 16, 1);
        RETURN;
    END

    -- Validación: DNI único (excluyendo el propio registro)
    IF EXISTS (SELECT 1 FROM socios.Persona WHERE dni = @dni AND id_persona <> @id_persona)
    BEGIN
        RAISERROR('[Error] socios.actualizar_persona_sp: Otro registro ya tiene ese DNI.', 16, 1);
        RETURN;
    END

    -- Validación: Fecha de nacimiento no futura
    IF @fecha_de_nacimiento > CAST(GETDATE() AS DATE)
    BEGIN
        RAISERROR('[Error] socios.actualizar_persona_sp: La fecha de nacimiento no puede ser futura.', 16, 1);
        RETURN;
    END

    -- Validación: Email básico
    IF @email IS NOT NULL AND @email NOT LIKE '%@%.%'
    BEGIN
        RAISERROR('[Error] socios.actualizar_persona_sp: El email ingresado no es válido.', 16, 1);
        RETURN;
    END

    -- Validación: Saldo no negativo
    IF @saldo < 0
    BEGIN
        RAISERROR('[Error] socios.actualizar_persona_sp: El saldo no puede ser negativo.', 16, 1);
        RETURN;
    END

    -- Actualización
    UPDATE socios.Persona
    SET
        nombre = @nombre,
        apellido = @apellido,
        dni = @dni,
        email = @email,
        fecha_de_nacimiento = @fecha_de_nacimiento,
        telefono = @telefono,
        saldo = @saldo
    WHERE id_persona = @id_persona;
END
GO

/***********************************************************************
Nombre del procedimiento: socios.eliminar_persona_sp
Descripción: No permite eliminar físicamente una persona del sistema.
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE socios.eliminar_persona_sp
    @id_persona INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Intento de eliminación bloqueado
    RAISERROR('[Error] socios.eliminar_persona_sp: No se puede eliminar una persona del sistema.', 16, 1);
    RETURN;
END
GO


/*       		 ____   ___   ____ ___ ___  
				/ ___| / _ \ / ___|_ _/ _ \ 
				\___ \| | | | |    | | | | |
				 ___) | |_| | |___ | | |_| |
				|____/ \___/ \____|___\___/ 
*/
USE Com2900G05;
GO

/***********************************************************************
Nombre del procedimiento: socios.registrar_socio_sp
Descripción: Registra a una persona existente como socio.
Devuelve el id_socio insertado por parámetro OUTPUT.
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE socios.registrar_socio_sp
    @id_persona INT,
    @id_categoria SMALLINT,
    @obra_social VARCHAR(100) = NULL,
    @nro_obra_social INT = NULL,
    @telefono_emergencia VARCHAR(50) = NULL,
    @id_socio INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validación: Persona existe
    IF NOT EXISTS (SELECT 1 FROM socios.Persona WHERE id_persona = @id_persona)
    BEGIN
        RAISERROR('[Error] socios.registrar_socio_sp: La persona indicada no existe en el sistema.', 16, 1);
        RETURN;
    END

    -- Validación: No duplicar socio para misma persona
    IF EXISTS (SELECT 1 FROM socios.Socio WHERE id_persona = @id_persona AND activo = 1)
    BEGIN
        RAISERROR('[Error] socios.registrar_socio_sp: La persona ya es un socio activo.', 16, 1);
        RETURN;
    END

    -- Validación: Categoría válida
    IF NOT EXISTS (SELECT 1 FROM socios.Categoria WHERE id_categoria = @id_categoria)
    BEGIN
        RAISERROR('[Error] socios.registrar_socio_sp: Categoría no válida.', 16, 1);
        RETURN;
    END

    -- Inserción
    INSERT INTO socios.Socio (
        id_persona,
        id_categoria,
        fecha_de_alta,
        activo,
        obra_social,
        nro_obra_social,
        telefono_emergencia
    ) VALUES (
        @id_persona,
        @id_categoria,
        CAST(GETDATE() AS DATE),
        1,
        @obra_social,
        @nro_obra_social,
        @telefono_emergencia
    );

    SET @id_socio = SCOPE_IDENTITY();
END
GO

/***********************************************************************
Nombre del procedimiento: socios.actualizar_socio_sp
Descripción: Actualiza los datos de un socio existente.
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE socios.actualizar_socio_sp
    @id_socio INT,
    @id_categoria SMALLINT,
    @obra_social VARCHAR(100) = NULL,
    @nro_obra_social INT = NULL,
    @telefono_emergencia VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Validación: Socio existe y está activo
    IF NOT EXISTS (SELECT 1 FROM socios.Socio WHERE id_socio = @id_socio AND activo = 1)
    BEGIN
        RAISERROR('[Error] socios.actualizar_socio_sp: El socio indicado no existe o no está activo.', 16, 1);
        RETURN;
    END

    -- Validación: Categoría válida
    IF NOT EXISTS (SELECT 1 FROM socios.Categoria WHERE id_categoria = @id_categoria)
    BEGIN
        RAISERROR('[Error] socios.actualizar_socio_sp: Categoría no válida.', 16, 1);
        RETURN;
    END

    -- Actualización
    UPDATE socios.Socio
    SET
        id_categoria = @id_categoria,
        obra_social = @obra_social,
        nro_obra_social = @nro_obra_social,
        telefono_emergencia = @telefono_emergencia
    WHERE id_socio = @id_socio;
END
GO

/***********************************************************************
Nombre del procedimiento: socios.eliminar_socio_sp
Descripción: Desactiva lógicamente un socio (borrado lógico).
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE socios.eliminar_socio_sp
    @id_socio INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validación: Socio existe y está activo
    IF NOT EXISTS (SELECT 1 FROM socios.Socio WHERE id_socio = @id_socio AND activo = 1)
    BEGIN
        RAISERROR('[Error] socios.eliminar_socio_sp: El socio indicado no existe o ya está desactivado.', 16, 1);
        RETURN;
    END

    -- Desactivación lógica
    UPDATE socios.Socio
    SET activo = 0
    WHERE id_socio = @id_socio;
END
GO

/*
	 ___                     _            _                              _       
	|_ _|_ __  ___  ___ _ __(_)_ __   ___(_) ___  _ __    ___  ___   ___(_) ___  
	 | || '_ \/ __|/ __| '__| | '_ \ / __| |/ _ \| '_ \  / __|/ _ \ / __| |/ _ \ 
	 | || | | \__ \ (__| |  | | |_) | (__| | (_) | | | | \__ \ (_) | (__| | (_) |
	|___|_| |_|___/\___|_|  |_| .__/ \___|_|\___/|_| |_| |___/\___/ \___|_|\___/ 
                          |_|                                                
*/
USE Com2900G05;
GO

/***********************************************************************
Nombre del procedimiento: socios.inscripcion_socio_sp
Descripción: Registra una persona y la convierte en socio según su edad.
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE socios.inscripcion_socio_sp
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @dni INT,
    @email VARCHAR(255) = NULL,
    @fecha_de_nacimiento DATE,
    @telefono VARCHAR(50) = NULL,
    @obra_social VARCHAR(100) = NULL,
    @nro_obra_social INT = NULL,
    @telefono_emergencia VARCHAR(50) = NULL,
    @id_persona INT OUTPUT,
    @id_socio INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Registrar persona
    EXEC socios.registrar_persona_sp
        @nombre = @nombre,
        @apellido = @apellido,
        @dni = @dni,
        @email = @email,
        @fecha_de_nacimiento = @fecha_de_nacimiento,
        @telefono = @telefono,
        @saldo = 0,
        @id_persona = @id_persona OUTPUT;

    IF @id_persona IS NULL RETURN;

    -- Calcular edad
    DECLARE @edad SMALLINT = socios.fn_obtener_edad_por_fnac(@fecha_de_nacimiento);
    DECLARE @id_categoria SMALLINT = socios.fn_obtener_categoria_por_edad(@edad);

    -- Registrar socio
    EXEC socios.registrar_socio_sp
        @id_persona = @id_persona,
        @obra_social = @obra_social,
        @nro_obra_social = @nro_obra_social,
        @telefono_emergencia = @telefono_emergencia,
        @id_categoria = @id_categoria,
        @id_socio = @id_socio OUTPUT;
END;
GO

/***********************************************************************
Nombre del procedimiento: socios.actualizar_inscripcion_socio_sp
Descripción: Actualiza los datos de una inscripción de socio.
Autor: Grupo 05 - Com2900
***********************************************************************/
GO
CREATE OR ALTER PROCEDURE socios.actualizar_inscripcion_socio_sp
    @id_persona INT,
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @dni INT,
    @email VARCHAR(255) = NULL,
    @fecha_de_nacimiento DATE,
    @telefono VARCHAR(50) = NULL,
    @obra_social VARCHAR(100) = NULL,
    @nro_obra_social INT = NULL,
    @telefono_emergencia VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Actualizar persona
    EXEC socios.actualizar_persona_sp
        @id_persona = @id_persona,
        @nombre = @nombre,
        @apellido = @apellido,
        @dni = @dni,
        @email = @email,
        @fecha_de_nacimiento = @fecha_de_nacimiento,
        @telefono = @telefono,
        @saldo = 0;

    -- Obtener socio activo
    DECLARE @id_socio INT;
    SELECT @id_socio = id_socio FROM socios.Socio WHERE id_persona = @id_persona AND activo = 1;

    IF @id_socio IS NULL
    BEGIN
        RAISERROR('[Error] socios.actualizar_inscripcion_socio_sp: No se encontró un socio activo para esta persona.', 16, 1);
        RETURN;
    END

    -- Calcular edad y categoría
    DECLARE @edad SMALLINT = socios.fn_obtener_edad_por_fnac(@fecha_de_nacimiento);
    DECLARE @id_categoria SMALLINT = socios.fn_obtener_categoria_por_edad(@edad);

    -- Actualizar socio
    EXEC socios.actualizar_socio_sp
        @id_socio = @id_socio,
        @id_categoria = @id_categoria,
        @obra_social = @obra_social,
        @nro_obra_social = @nro_obra_social,
        @telefono_emergencia = @telefono_emergencia;
END;
GO

/***********************************************************************
Nombre del procedimiento: socios.baja_inscripcion_socio_sp
Descripción: Da de baja una inscripción de socio (borrado lógico del socio).
Autor: Grupo 05 - Com2900
***********************************************************************/
GO
CREATE OR ALTER PROCEDURE socios.baja_inscripcion_socio_sp
    @id_persona INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Obtener socio activo
    DECLARE @id_socio INT;
    SELECT @id_socio = id_socio FROM socios.Socio WHERE id_persona = @id_persona AND activo = 1;

    IF @id_socio IS NULL
    BEGIN
        RAISERROR('[Error] socios.baja_inscripcion_socio_sp: No se encontró un socio activo para esta persona.', 16, 1);
        RETURN;
    END

    -- Dar de baja el socio
    EXEC socios.eliminar_socio_sp @id_socio = @id_socio;
END;
GO

/*
		 ___                     _            _                              _       
		|_ _|_ __  ___  ___ _ __(_)_ __   ___(_) ___  _ __    ___  ___   ___(_) ___  
		 | || '_ \/ __|/ __| '__| | '_ \ / __| |/ _ \| '_ \  / __|/ _ \ / __| |/ _ \ 
		 | || | | \__ \ (__| |  | | |_) | (__| | (_) | | | | \__ \ (_) | (__| | (_) |
		|___|_| |_|___/\___|_|  |_| .__/ \___|_|\___/|_| |_| |___/\___/ \___|_|\___/ 
		 _ __ ___   ___ _ __   ___|_| __                                             
		| '_ ` _ \ / _ \ '_ \ / _ \| '__|                                            
		| | | | | |  __/ | | | (_) | |                                               
		|_| |_| |_|\___|_| |_|\___/|_|                                               
*/
USE Com2900G05;
GO

/***********************************************************************
Nombre del procedimiento: inscripcion_socio_menor_sp
Descripción: Registra a un menor como socio y crea el vínculo con su responsable.
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE socios.registrar_inscripcion_menor_sp
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

    -- Datos del responsable
    @nombre_resp VARCHAR(50),
    @apellido_resp VARCHAR(50),
    @dni_resp INT,
    @email_resp VARCHAR(255) = NULL,
    @fecha_nac_resp DATE,
    @telefono_resp VARCHAR(50) = NULL,

    -- Output
    @id_persona_menor INT OUTPUT,
    @id_socio_menor INT OUTPUT,
    @id_persona_resp INT OUTPUT,

    -- Parentesco
    @parentesco CHAR(1)  -- 'P', 'M' o 'T'
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar parentesco
    IF @parentesco NOT IN ('P','M','T')
    BEGIN
        RAISERROR('[Error] socios.registrar_inscripcion_menor_sp: Parentesco inválido.', 16, 1);
        RETURN;
    END

    -- Validar edad del menor
    DECLARE @edad_menor INT = socios.fn_obtener_edad_por_fnac(@fecha_nac_menor);

    IF @edad_menor >= 18
    BEGIN
        RAISERROR('[Error] socios.registrar_inscripcion_menor_sp: La persona ingresada no es menor de edad.', 16, 1);
        RETURN;
    END

    DECLARE @id_categoria SMALLINT = socios.fn_obtener_categoria_por_edad(@edad_menor);

    -- Registrar menor
    EXEC socios.registrar_persona_sp
        @nombre_menor, @apellido_menor, @dni_menor, @email_menor, @fecha_nac_menor, @telefono_menor, 0, @id_persona_menor OUTPUT;

    IF @id_persona_menor IS NULL RETURN;

    EXEC socios.registrar_socio_sp
        @id_persona_menor, @id_categoria, @obra_social, @nro_obra_social, @telefono_emergencia, @id_socio_menor OUTPUT;

    IF @id_socio_menor IS NULL RETURN;

    -- Registrar responsable
    EXEC socios.registrar_persona_sp
        @nombre_resp, @apellido_resp, @dni_resp, @email_resp, @fecha_nac_resp, @telefono_resp, 0, @id_persona_resp OUTPUT;

    IF @id_persona_resp IS NULL RETURN;

    INSERT INTO socios.Parentesco (id_persona, id_persona_responsable, parentesco, fecha_desde, fecha_hasta)
    VALUES (@id_persona_menor, @id_persona_resp, @parentesco, GETDATE(), DATEADD(YEAR, 18, @fecha_nac_menor));
END
GO

/***********************************************************************
Nombre del procedimiento: socios.actualizar_inscripcion_menor_sp
Descripción: Actualiza datos de menor y responsable.
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE socios.actualizar_inscripcion_menor_sp
    @id_persona_menor INT,
    @nombre_menor VARCHAR(50),
    @apellido_menor VARCHAR(50),
    @dni_menor INT,
    @email_menor VARCHAR(255) = NULL,
    @fecha_nac_menor DATE,
    @telefono_menor VARCHAR(50) = NULL,
    @obra_social VARCHAR(100) = NULL,
    @nro_obra_social INT = NULL,
    @telefono_emergencia VARCHAR(50) = NULL,
    @id_persona_resp INT,
    @nombre_resp VARCHAR(50),
    @apellido_resp VARCHAR(50),
    @dni_resp INT,
    @email_resp VARCHAR(255) = NULL,
    @fecha_nac_resp DATE,
    @telefono_resp VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Actualizar persona menor
    EXEC socios.actualizar_persona_sp
        @id_persona_menor, @nombre_menor, @apellido_menor, @dni_menor, @email_menor, @fecha_nac_menor, @telefono_menor, 0;

    -- Obtener socio menor
    DECLARE @id_socio INT;
    SELECT @id_socio = id_socio FROM socios.Socio WHERE id_persona = @id_persona_menor AND activo = 1;

    IF @id_socio IS NULL
    BEGIN
        RAISERROR('[Error] socios.actualizar_inscripcion_menor_sp: No se encontró un socio activo para el menor.', 16, 1);
        RETURN;
    END

    -- Actualizar socio menor
    DECLARE @edad SMALLINT = socios.fn_obtener_edad_por_fnac(@fecha_nac_menor);
    DECLARE @id_categoria SMALLINT = socios.fn_obtener_categoria_por_edad(@edad);

    EXEC socios.actualizar_socio_sp
        @id_socio, @id_categoria, @obra_social, @nro_obra_social, @telefono_emergencia;

    -- Actualizar responsable
    EXEC socios.actualizar_persona_sp
        @id_persona_resp, @nombre_resp, @apellido_resp, @dni_resp, @email_resp, @fecha_nac_resp, @telefono_resp, 0;
END
GO

/***********************************************************************
Nombre del procedimiento: socios.baja_inscripcion_menor_sp
Descripción: Da de baja al socio menor (borrado lógico), verificando el responsable.
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE socios.baja_inscripcion_menor_sp
    @id_socio_menor INT,
    @id_persona_responsable INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Declarar variable para almacenar el id_persona del menor
    DECLARE @id_persona_menor INT;

    -- Obtener el id_persona asociado al id_socio_menor
    SELECT @id_persona_menor = id_persona
    FROM socios.Socio
    WHERE id_socio = @id_socio_menor;

    -- Verificar si el socio menor existe
    IF @id_persona_menor IS NULL
    BEGIN
        RAISERROR('[Error] socios.baja_inscripcion_menor_sp: El socio menor no existe.', 16, 1);
        RETURN;
    END

    -- Verificar si el id_persona_responsable es el responsable de este menor
    IF NOT EXISTS (
        SELECT 1
        FROM socios.Parentesco
        WHERE id_persona = @id_persona_menor
          AND id_persona_responsable = @id_persona_responsable
    )
    BEGIN
        RAISERROR('[Error] socios.baja_inscripcion_menor_sp: El responsable no tiene al menor a cargo.', 16, 1);
        RETURN;
    END

    -- Si las validaciones pasan, proceder a dar de baja el socio (borrado lógico)
    EXEC socios.eliminar_socio_sp @id_socio = @id_socio_menor;
END
GO

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

	DECLARE @fecha_actual DATE = GETDATE();
    -- Validar que no esté ya inscrito
    IF EXISTS (
        SELECT 1 
        FROM socios.InscripcionActividadDeportiva
        WHERE id_socio = @id_socio
          AND id_actividad_dep = @id_actividad_deportiva
<<<<<<< Updated upstream
		  AND fecha_inscripcion <= @fecha_actual
				AND (fecha_baja >= @fecha_actual OR fecha_baja IS NULL)
=======
			AND fecha_baja IS NULL
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
        @fecha_actual,
		NULL
=======
        @fecha_alta,
		@fecha_baja
>>>>>>> Stashed changes
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
    @id_socio INT
AS
BEGIN
    SET NOCOUNT ON;
	
	-- Validamos si el socio existe
	IF NOT EXISTS (SELECT 1 FROM socios.Socio WHERE id_socio = @id_socio)
	BEGIN
        RAISERROR('El socio proporcionado no existe.', 16, 1);
        RETURN;
    END

	DECLARE @fecha_actual DATE = GETDATE(),
			@id_factura INT,
			@id_membresia INT,
			@monto_categoria DECIMAL(10,2) = 0,
			@cantidad_act_dep INT = 0,
			@monto_deportiva DECIMAL(10,2) = 0,
			@es_grupo_familiar BIT = 0,
			@monto_bruto DECIMAL(10,2) = 0,
			@monto_neto DECIMAL(10,2) = 0;

	-- Calculamos primer dia del mes
	DECLARE @primer_dia_mes DATE = DATEFROMPARTS(YEAR(@fecha_actual), 1, 1);

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
		
		SET @monto_bruto = @monto_bruto + @monto_deportiva;

		-- Aplicamos descuento del 10% sobre el total de las actividades deportivas si se realizan varias
		IF @cantidad_act_dep > 1
		BEGIN;
			SET @monto_deportiva = @monto_deportiva * 0.9;
		END;
		SET @monto_neto = @monto_neto + @monto_deportiva;

		/* Buscamos si el socio pertenece a un grupo familiar, de ser asi
		aplicamos un descuento del 15% en el total de la facturación de membresía*/
		IF EXISTS (
			SELECT 1 FROM socios.Parentesco par
			INNER JOIN socios.Socio s ON par.id_persona = s.id_persona 
				OR par.id_persona_responsable = s.id_persona
			WHERE s.id_socio = @id_socio
			AND (par.fecha_hasta >= @primer_dia_mes OR par.fecha_hasta IS NULL)
		)
		BEGIN;
			SET @monto_neto = @monto_neto * 0.85;
		END;

		-- Finalmente actualizamos los registros
		UPDATE socios.Membresia 
			SET total_bruto = @monto_bruto, total_neto = @monto_neto
			WHERE id_membresia = @id_membresia;

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
	IF NOT EXISTS (SELECT 1 FROM socios.Socio WHERE id_socio = @id_socio)
	BEGIN
        RAISERROR('El socio proporcionado no existe.', 16, 1);
        RETURN;
    END

	DECLARE @fecha_actual DATE = GETDATE(),
			@id_factura INT,
			@monto_recreativa DECIMAL(10,2) = 0;

	-- Calculamos primer dia del mes
	DECLARE @primer_dia_mes DATE = DATEFROMPARTS(YEAR(@fecha_actual), 1, 1);

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
	@id_inscripcion_rec INT -- Actividad a la cual el socio esta incripto y lo invito
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

	DECLARE @fecha_actual DATE = GETDATE(),
			@id_factura INT,
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

/*
  ____                   
 |  _ \ __ _  __ _  ___  
 | |_) / _` |/ _` |/ _ \ 
 |  __/ (_| | (_| | (_) |
 |_|   \__,_|\__, |\___/ 
             |___/       
*/

/***********************************************************************
Nombre del procedimiento: pagar_factura_sp
Descripción: Se pasa a paga la factura pasada por parámetro.
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE socios.pagar_factura_sp
    @id_factura INT,
	@id_medio INT,
	@codigo_de_referencia VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	-- Validamos si la factura existe
	IF NOT EXISTS (SELECT 1 FROM socios.Factura WHERE id_factura = @id_factura)
	BEGIN
        RAISERROR('La factura proporcionada no existe.', 16, 1);
        RETURN;
    END
	-- Validamos el medio de pago utilizado
	IF NOT EXISTS (SELECT 1 FROM socios.MedioDePago WHERE id_medio = @id_medio)
	BEGIN
        RAISERROR('El medio de pago proporcionada no existe.', 16, 1);
        RETURN;
    END
	
	BEGIN TRANSACTION Tran1
	BEGIN TRY
		DECLARE @id_pago INT;
		-- Insertamos en la tabla de Pago con los datos proporcionados
		INSERT INTO socios.Pago (id_medio, fecha_pago, codigo_de_referencia)
			VALUES (@id_medio, GETDATE(), @codigo_de_referencia);

		SET @id_pago = SCOPE_IDENTITY();
		-- Asociamos el pago a la factura
		INSERT INTO socios.DetalleDePago(id_factura, id_pago)
			VALUES (@id_factura, @id_pago);

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