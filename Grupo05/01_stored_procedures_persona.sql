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
/***********************************************************************
Nombre del procedimiento: socios.registrar_persona_sp
Descripción: Registra una persona en la tabla [Persona] validando datos.
Devuelve el id_persona insertado por parámetro OUTPUT.
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE socios.registrar_invitacion_sp
    @nombre_invitado VARCHAR(50) = NULL,
    @apellido_invitado VARCHAR(50) = NULL,
    @dni_invitado INT,
    @email_invitado VARCHAR(255) = NULL,
    @fecha_de_nacimiento_invitado DATE = NULL,
    @telefono_invitado VARCHAR(50) = NULL,
    @id_socio_invitador INT,
	@id_actividad_recreativa_invitada INT,
	@id_persona_invitada INT,
	@id_factura_invitacion INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validación: DNI único
    IF NOT EXISTS (SELECT 1 FROM socios.Persona WHERE dni = @dni_invitado)
    BEGIN
        EXEC socios.registrar_persona_sp
		 @nombre = @nombre_invitado,
		 @apellido = @apellido_invitado,
		 @dni = @dni_invitado,
		 @email = @email_invitado,
		 @fecha_de_nacimiento = @fecha_de_nacimiento_invitado,
		 @telefono = @telefono_invitado,
		 @saldo = 0,
		 @id_persona = @id_persona_invitada
    END
	
	EXEC socios.generar_factura_recreativa_invitado_sp 
		@id_persona = @id_persona_invitada,
		@id_inscripcion_rec = @id_actividad_recreativa_invitada,
		@id_factura = @id_factura_invitacion OUTPUT
END
GO