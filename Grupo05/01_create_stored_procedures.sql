/***********************************************************************
 * Enunciado: Cree la base de datos, entidades y relaciones. Incluya
 *		restricciones y claves. Deberá entregar un archivo .sql con 
 *		el script completo de creación (debe funcionar si se lo ejecuta
 *		“tal cual” es entregado en una sola ejecución).
 *
 * Fecha de entrega: 24/06/2025
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
Nombre de la función: socios.fn_obtener_categoria_por_edad
Descripción: Retorna el id_categoria correspondiente a una edad dada.
***********************************************************************/
CREATE OR ALTER FUNCTION socios.fn_obtener_categoria_por_edad (
    @edad INT
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

/***********************************************************************
Nombre del procedimiento: registrar_persona_sp
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
        RAISERROR('Ya existe una persona con ese DNI.', 16, 1);
        RETURN;
    END

    -- Validación: Fecha de nacimiento no futura
    IF @fecha_de_nacimiento > CAST(GETDATE() AS DATE)
    BEGIN
        RAISERROR('La fecha de nacimiento no puede ser futura.', 16, 1);
        RETURN;
    END

    -- Validación: Email básico
    IF @email IS NOT NULL AND @email NOT LIKE '%@%.%'
    BEGIN
        RAISERROR('El email ingresado no es válido.', 16, 1);
        RETURN;
    END

    -- Validación: Saldo no negativo
    IF @saldo < 0
    BEGIN
        RAISERROR('El saldo no puede ser negativo.', 16, 1);
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
Nombre del procedimiento: registrar_socio_sp
Descripción: Registra a una persona existente como socio.
Calcula la categoría en base a la edad.
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE socios.registrar_socio_sp
	@id_persona INT,
    @obra_social VARCHAR(100) = NULL,
    @nro_obra_social INT = NULL,
    @telefono_emergencia VARCHAR(50) = NULL,
    @id_socio INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar que la persona exista
    IF NOT EXISTS (SELECT 1 FROM socios.Persona WHERE id_persona = @id_persona)
    BEGIN
        RAISERROR('La persona indicada no existe en el sistema.', 16, 1);
        RETURN;
    END

    -- Obtener fecha de nacimiento
    DECLARE @fecha_nacimiento DATE;
    SELECT @fecha_nacimiento = fecha_de_nacimiento FROM socios.Persona WHERE id_persona = @id_persona;

    -- Calcular edad
    DECLARE @edad INT = DATEDIFF(YEAR, @fecha_nacimiento, GETDATE());
    IF (MONTH(@fecha_nacimiento) > MONTH(GETDATE())) OR 
       (MONTH(@fecha_nacimiento) = MONTH(GETDATE()) AND DAY(@fecha_nacimiento) > DAY(GETDATE()))
    BEGIN
        SET @edad = @edad - 1;
    END

    -- Obtener categoría
    DECLARE @id_categoria SMALLINT = socios.fn_obtener_categoria_por_edad(@edad);

    IF @id_categoria IS NULL
    BEGIN
        RAISERROR('No se encontró categoría para la edad.', 16, 1);
        RETURN;
    END

    -- Inserción
    INSERT INTO socios.Socio (
		id_persona, id_categoria, fecha_de_alta, activo, obra_social, nro_obra_social, telefono_emergencia
	) VALUES (
		@id_persona, @id_categoria, GETDATE(), 1, @obra_social, @nro_obra_social, @telefono_emergencia
	);

	-- Retorna el id del socio que acaba de insertar
    SET @id_socio = SCOPE_IDENTITY();
END
GO

/***********************************************************************
Nombre del procedimiento: inscripcion_socio_sp
Descripción: Registra una persona y la convierte en socio.
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
    @telefono_emergencia VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_persona INT;
    DECLARE @id_socio INT;

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

    -- Registrar socio
    EXEC socios.registrar_socio_sp
        @id_persona = @id_persona,
        @obra_social = @obra_social,
        @nro_obra_social = @nro_obra_social,
        @telefono_emergencia = @telefono_emergencia,
        @id_socio = @id_socio OUTPUT;

    IF @id_socio IS NULL RETURN;

    -- Retorno de los id que acaba de insertar
    SELECT 
        @id_persona AS id_persona_insertada,
        @id_socio AS id_socio_insertado;
END
GO

/***********************************************************************
Nombre del procedimiento: inscripcion_socio_menor_sp
Descripción: Registra a un menor como socio y crea el vínculo con su responsable.
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE socios.inscripcion_socio_menor_sp
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

    -- Parentesco
    @parentesco CHAR(1)  -- 'P', 'M' o 'T'
AS
BEGIN
    SET NOCOUNT ON;

    -- Validación del parentesco
    IF @parentesco NOT IN ('P','M','T')
    BEGIN
        RAISERROR('Parentesco inválido. Debe ser P, M o T.', 16, 1);
        RETURN;
    END

    -- Validación: menor de edad
    DECLARE @edad_menor INT = DATEDIFF(YEAR, @fecha_nac_menor, GETDATE());
    IF (MONTH(@fecha_nac_menor) > MONTH(GETDATE())) OR 
       (MONTH(@fecha_nac_menor) = MONTH(GETDATE()) AND DAY(@fecha_nac_menor) > DAY(GETDATE()))
    BEGIN
        SET @edad_menor = @edad_menor - 1;
    END

    IF @edad_menor >= 18
    BEGIN
        RAISERROR('La persona ingresada no es menor de edad.', 16, 1);
        RETURN;
    END

    DECLARE @id_persona_menor INT;
    DECLARE @id_socio_menor INT;
    DECLARE @id_persona_resp INT;

    -- Registrar menor como persona
    EXEC socios.registrar_persona_sp
        @nombre = @nombre_menor,
        @apellido = @apellido_menor,
        @dni = @dni_menor,
        @email = @email_menor,
        @fecha_de_nacimiento = @fecha_nac_menor,
        @telefono = @telefono_menor,
        @saldo = 0,
        @id_persona = @id_persona_menor OUTPUT;

    IF @id_persona_menor IS NULL RETURN;

    -- Hacer socio al menor
    EXEC socios.registrar_socio_sp
        @id_persona = @id_persona_menor,
        @obra_social = @obra_social,
        @nro_obra_social = @nro_obra_social,
        @telefono_emergencia = @telefono_emergencia,
        @id_socio = @id_socio_menor OUTPUT;

    IF @id_socio_menor IS NULL RETURN;

    -- Registrar responsable (como persona común)
    EXEC socios.registrar_persona_sp
        @nombre = @nombre_resp,
        @apellido = @apellido_resp,
        @dni = @dni_resp,
        @email = @email_resp,
        @fecha_de_nacimiento = @fecha_nac_resp,
        @telefono = @telefono_resp,
        @saldo = 0,
        @id_persona = @id_persona_resp OUTPUT;

    IF @id_persona_resp IS NULL RETURN;

    -- Crear vínculo en Parentesco
    INSERT INTO socios.Parentesco (
        id_persona, id_persona_responsable, parentesco, fecha_desde, fecha_hasta
    ) VALUES (
        @id_persona_menor, @id_persona_resp, @parentesco, GETDATE(), DATEADD(YEAR, 18, @fecha_nac_menor)
    );

    -- Devolver resultados
    SELECT 
        @id_persona_menor AS id_persona_menor,
        @id_socio_menor AS id_socio_menor,
        @id_persona_resp AS id_responsable;
END
GO
