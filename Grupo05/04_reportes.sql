/***********************************************************************
 * Enunciado: Entrega 6, reportes solicitados.
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

/* Creaci�n de esquema reportes */
IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = 'reportes')
BEGIN
    EXEC('CREATE SCHEMA reportes');
END
ELSE
	PRINT 'Ya existe el esquema "reportes"';
GO

/***********************************************************************
Nombre del procedimiento: reportes.reporte1
Descripci�n: Reporte 1
	Reporte de los socios morosos, que hayan incumplido en m�s de dos
	oportunidades dado un rango de fechas a ingresar. El reporte debe
	contener los siguientes datos:
	- Nombre del reporte: Morosos Recurrentes
	- Per�odo: rango de fechas
	- Nro de socio
	- Nombre y apellido.
	- Mes incumplido
	Ordenados de Mayor a menor por ranking de morosidad
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE reportes.reporte1
@fecha_desde DATE,
@fecha_hasta DATE
AS
BEGIN
    SET NOCOUNT ON;

	IF @fecha_desde > @fecha_hasta
	BEGIN;
        RAISERROR('La fecha_desde no puede ser mayor a la fecha_hasta.', 16, 1);
        RETURN;
    END;

	WITH MorososRecurrentes AS (
		 SELECT s.id_socio, p.nombre, p.apellido, MONTH(f.fecha_emision) as mes_incumplido,
			COUNT(nombre) OVER (PARTITION BY nombre, apellido) as recurrencias
		 FROM [socios].[Morosidad] m
			INNER JOIN [socios].[Factura] f ON m.id_factura = f.id_factura
			INNER JOIN [socios].[Socio] s ON m.id_socio = s.id_socio
			INNER JOIN [socios].[Persona] p ON p.id_persona = s.id_persona
			WHERE f.fecha_emision BETWEEN @fecha_desde AND @fecha_hasta
	)
	SELECT id_socio, nombre, apellido, mes_incumplido,
		RANK() OVER (PARTITION BY nombre, apellido ORDER BY recurrencias DESC) as ranking_morosidad
	FROM MorososRecurrentes
	WHERE recurrencias > 2 -- Deben haber incumplido en m�s de 2 oportunidades
	ORDER BY ranking_morosidad;
END
GO

/***********************************************************************
Nombre del procedimiento: reportes.reporte2
Descripci�n: Reporte 2
	Reporte acumulado mensual de ingresos por actividad deportiva al
	momento en que se saca el reporte tomando como inicio enero.
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE reportes.reporte2
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE @fecha_actual DATE = GETDATE();
	-- Generar la fecha del primero de enero en el a�o que se genera el reporte
	DECLARE @fecha_inicial DATE = DATEFROMPARTS(YEAR(@fecha_actual), 1, 1);
	SELECT 
		MONTH(f.fecha_emision) as mes, 
		ad.nombre as actividad_deportiva,
		SUM(dd.monto) OVER (PARTITION BY MONTH(f.fecha_emision), ad.nombre) as valor_acumulado
		FROM socios.DetalleDeportiva dd
		INNER JOIN socios.Membresia m ON m.id_membresia = dd.id_membresia
		INNER JOIN socios.Factura f ON f.id_factura = dd.id_membresia
		INNER JOIN socios.DetalleDePago ddp ON ddp.id_factura = f.id_factura -- Si se cumple este inner join es que est� pago
		INNER JOIN socios.InscripcionActividadDeportiva iad ON iad.id_inscripcion_dep = dd.id_inscripcion_dep
		INNER JOIN socios.ActividadDeportiva ad ON ad.id_actividad_dep = iad.id_actividad_dep
		WHERE f.fecha_emision <= @fecha_actual AND f.fecha_emision >= @fecha_inicial;
END
GO

/***********************************************************************
Nombre del procedimiento: reportes.reporte3
Descripci�n: Reporte 3
	Reporte de la cantidad de socios que han realizado alguna actividad
	de forma alternada (inasistencias) por categor�a de socios y
	actividad, ordenado seg�n cantidad de inasistencias ordenadas de
	mayor a menor.
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE reportes.reporte3
AS
BEGIN
    SET NOCOUNT ON;

	WITH AsistenciaAlternada AS (
		SELECT DISTINCT asis.id_socio, asis.id_actividad_dep
		FROM [socios].[AsistenciaActividadDeportiva] asis
		GROUP BY asis.id_socio, asis.id_actividad_dep
		HAVING SUM(CASE WHEN asis.asistencia = 'P' THEN 1 ELSE 0 END) > 0 -- asistencias
		AND SUM(CASE WHEN asis.asistencia = 'A' OR asis.asistencia = 'J' THEN 1 ELSE 0 END) > 0 -- inasistencias
	)
	SELECT c.nombre as categoria, ad.nombre as actividad_deportiva,
		COUNT(s.id_socio) OVER (PARTITION BY c.id_categoria, ad.id_actividad_dep)
		as cantidad_socios_asistencia_alternada
	FROM AsistenciaAlternada asis
		INNER JOIN [socios].[ActividadDeportiva] ad ON asis.id_actividad_dep = ad.id_actividad_dep
		INNER JOIN [socios].[Socio] s ON asis.id_socio = s.id_socio
		INNER JOIN [socios].[Categoria] c ON c.id_categoria = s.id_categoria
		ORDER BY categoria ASC, actividad_deportiva ASC, cantidad_socios_asistencia_alternada DESC;
END
GO

/***********************************************************************
Nombre del procedimiento: reportes.reporte4
Descripci�n: Reporte 4
	Reporte que contenga a los socios que no han asistido a alguna clase
	de la actividad que realizan. El reporte debe contener: Nombre,
	Apellido, edad, categor�a y la actividad.
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE reportes.reporte4
AS
BEGIN
    SET NOCOUNT ON;

	SELECT p.nombre, p.apellido, socios.fn_obtener_edad_por_fnac(p.fecha_de_nacimiento) as edad,
		c.nombre as categoria, ad.nombre as actividad_deportiva,
		COUNT(p.nombre) OVER (PARTITION BY s.id_socio) as ausencias
	FROM [socios].[InscripcionActividadDeportiva] i
		INNER JOIN [socios].[ActividadDeportiva] ad ON i.id_actividad_dep = ad.id_actividad_dep
		INNER JOIN [socios].[AsistenciaActividadDeportiva] asis ON i.id_socio = asis.id_socio 
			AND i.id_actividad_dep = asis.id_actividad_dep
		INNER JOIN [socios].[Socio] s ON i.id_socio = s.id_socio
		INNER JOIN [socios].[Persona] p ON s.id_persona = p.id_persona
		INNER JOIN [socios].[Categoria] c ON c.id_categoria = s.id_categoria
		WHERE i.fecha_baja IS NULL
			AND (asis.asistencia = 'A' OR asis.asistencia = 'J'); -- ausente o ausente justificado
END
GO

/***********************************************************************
Nombre del procedimiento: socios.registrar_morosos_sp
Descripci�n: Identifica las facturas de SOCIOS con una antig�edad mayor
    a 6 d�as que no tengan un pago asociado y las inserta en la tabla 
    de Morosidad. Este proceso excluye expl�citamente las facturas 
    generadas por invitados, ya que su pago es inmediato.
    El procedimiento evita duplicar registros si ya fueron procesados.
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE socios.registrar_morosos_sp
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;
    BEGIN TRY
        
        -- CTE para encontrar el id_socio asociado a cada factura de socio.
        -- Se excluyen las facturas de invitados.
        WITH FacturaSocioLink AS (
            -- V�nculo a trav�s de la membres�a (incluye cuota y actividades deportivas)
            SELECT 
                m.id_factura, 
                m.id_socio
            FROM socios.Membresia m

            UNION -- Usamos UNION para combinar y eliminar duplicados

            -- V�nculo a trav�s de actividades recreativas del propio socio
            SELECT 
                dr.id_factura, 
                iar.id_socio
            FROM socios.DetalleRecreativa dr
            INNER JOIN socios.InscripcionActividadRecreativa iar ON dr.id_inscripcion_rec = iar.id_inscripcion_rec
        )
        -- Insertamos en la tabla Morosidad los registros que cumplen las condiciones
        INSERT INTO socios.Morosidad (id_factura, id_socio, monto)
        SELECT
            f.id_factura,
            link.id_socio,
            f.total_neto
        FROM socios.Factura f
        -- Nos unimos a nuestro CTE para encontrar el socio que gener� la deuda
        INNER JOIN FacturaSocioLink link ON f.id_factura = link.id_factura
        WHERE
            -- Condici�n 1: Han pasado m�s de 6 d�as desde la emisi�n de la factura.
            DATEDIFF(DAY, f.fecha_emision, GETDATE()) > 6
            -- Condici�n 2: La factura NO tiene un pago asociado.
            AND NOT EXISTS (
                SELECT 1 
                FROM socios.DetalleDePago ddp 
                WHERE ddp.id_factura = f.id_factura
            )
            -- Condici�n 3 (Idempotencia): La factura NO ha sido registrada como morosa previamente.
            AND NOT EXISTS (
                SELECT 1 
                FROM socios.Morosidad m 
                WHERE m.id_factura = f.id_factura
            );
        
        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        -- Si ocurre un error, revertimos la transacci�n para no dejar datos a medio cargar.
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Mostramos el error original para facilitar la depuraci�n.
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO






