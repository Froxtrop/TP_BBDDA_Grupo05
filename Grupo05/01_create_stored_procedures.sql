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
 Nombre del procedimiento: inscripcion_socio_sp
 Descripción: Registra una persona como socio.
		Inserta en [Persona] y luego en [Socio].
 Autor: Grupo 05 - Com2900
 ***********************************************************************/

CREATE PROCEDURE socios.inscripcion_socio_sp
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

    -- Validación: DNI único
    IF EXISTS (SELECT 1 FROM socios.Persona WHERE dni = @dni)
    BEGIN
        RAISERROR('Ya existe una persona con ese DNI.', 16, 1);
        RETURN;
    END

    -- Validación: Fecha de nacimiento no previa al día de hoy
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

    -- Asignación de un saldo nulo
    DECLARE @saldo DECIMAL(10,2) = 0

    -- Cálculo de edad
    DECLARE @edad INT;
    SET @edad = DATEDIFF(YEAR, @fecha_de_nacimiento, GETDATE());
    IF (MONTH(@fecha_de_nacimiento) > MONTH(GETDATE())) OR 
       (MONTH(@fecha_de_nacimiento) = MONTH(GETDATE()) AND DAY(@fecha_de_nacimiento) > DAY(GETDATE()))
    BEGIN
        SET @edad = @edad - 1;
    END

	DECLARE @id_categoria SMALLINT = socios.fn_obtener_categoria_por_edad(@edad)

    -- Inserción en Persona
    INSERT INTO socios.Persona (nombre, apellido, dni, email, fecha_de_nacimiento, telefono, saldo)
    VALUES (@nombre, @apellido, @dni, @email, @fecha_de_nacimiento, @telefono, @saldo);

	-- Recupera el ID que acaba de insertar en Persona
    DECLARE @id_persona INT = SCOPE_IDENTITY();

    -- Inserción en Socio
    INSERT INTO socios.Socio (id_persona, id_categoria, fecha_de_alta, activo, obra_social, nro_obra_social, telefono_emergencia)
    VALUES (@id_persona, @id_categoria, GETDATE(), 1, @obra_social, @nro_obra_social, @telefono_emergencia);

	-- Recupera el ID que acaba de insertar en Socio
    DECLARE @id_socio INT = SCOPE_IDENTITY();

    -- Devolver los ID generados
    SELECT 
        @id_persona AS id_persona_insertada,
        @id_socio AS id_socio_insertado;
END
GO
