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

/*       		 ____   ___   ____ ___ ___  
				/ ___| / _ \ / ___|_ _/ _ \ 
				\___ \| | | | |    | | | | |
				 ___) | |_| | |___ | | |_| |
				|____/ \___/ \____|___\___/ 
*/

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