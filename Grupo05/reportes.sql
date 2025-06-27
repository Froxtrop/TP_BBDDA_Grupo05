/***********************************************************************
 * Enunciado: Entrega 6 reportes solicitados.
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

USE Com2900G05
GO

/* Reporte 1
Reporte de los socios morosos, que hayan incumplido en más de dos oportunidades dado un
rango de fechas a ingresar. El reporte debe contener los siguientes datos:
- Nombre del reporte: Morosos Recurrentes
- Período: rango de fechas
- Nro de socio
- Nombre y apellido.
- Mes incumplido
Ordenados de Mayor a menor por ranking de morosidad
*/
-- Rehacer este con socio.

DECLARE @fechaDesde date = GETDATE() - 365, @fechaHasta date = GETDATE();
WITH MorososRecurrentes AS (
	 SELECT p.id_persona, p.nombre, p.apellido, MONTH(f.fecha_emision) as mes_incumplido,
		COUNT(nombre) OVER (PARTITION BY nombre, apellido) as recurrencias
	 FROM [socios].[Morosidad] m
		INNER JOIN [socios].[Factura] f ON m.id_factura = f.id_factura
		INNER JOIN [socios].[Persona] p ON m.id_persona = p.id_persona
		WHERE f.fecha_emision BETWEEN @fechaDesde AND @fechaHasta
)
SELECT id_persona, nombre, apellido, mes_incumplido,
	RANK() OVER (PARTITION BY nombre, apellido ORDER BY recurrencias DESC) as ranking_morosidad
FROM MorososRecurrentes
ORDER BY ranking_morosidad;

/* Reporte 2
Reporte acumulado mensual de ingresos por actividad deportiva al momento en que se saca
el reporte tomando como inicio enero.
*/

DECLARE @fecha_actual DATE = GETDATE();
DECLARE @fecha_inicial DATE = DATEFROMPARTS(YEAR(@fecha_actual), 1, 1); -- Genera la fecha del primero de enero en el año que se genera el reporte
SELECT 
	MONTH(f.fecha_emision) as mes, 
	ad.nombre as actividad_deportiva,
	SUM(dd.monto) OVER (PARTITION BY MONTH(f.fecha_emision), ad.nombre) as valor_acumulado
	FROM socios.DetalleDeportiva dd
	INNER JOIN socios.Factura f ON f.id_factura = dd.id_factura
	INNER JOIN socios.DetalleDePago ddp ON ddp.id_factura = dd.id_factura -- Si se cumple este inner join es que está pago
	INNER JOIN socios.InscripcionActividadDeportiva iad ON iad.id_inscripcion_dep = dd.id_inscripcion_dep
	INNER JOIN socios.ActividadDeportiva ad ON ad.id_actividad_dep = iad.id_actividad_dep
	WHERE f.fecha_emision <= @fecha_actual AND f.fecha_emision >= @fecha_inicial

/* Reporte 3
Reporte de la cantidad de socios que han realizado alguna actividad de forma alternada
(inasistencias) por categoría de socios y actividad, ordenado según cantidad de inasistencias
ordenadas de mayor a menor.
*/

WITH AsistenciaAlternada AS (
	SELECT DISTINCT asis.id_socio, asis.id_actividad_dep
	FROM [socios].[AsistenciaActividadDeportiva] asis
	GROUP BY asis.id_socio, asis.id_actividad_dep
	HAVING SUM(CASE WHEN asis.asistencia = 'P' THEN 1 ELSE 0 END) > 0 -- asistencias
	AND SUM(CASE WHEN asis.asistencia = 'A' THEN 1 ELSE 0 END) > 0 -- inasistencias
)
SELECT c.nombre as categoria, ad.nombre as actividad_deportiva,
	COUNT(s.id_socio) OVER (PARTITION BY c.id_categoria, ad.id_actividad_dep)
	as cantidad_socios_asistencia_alternada
FROM AsistenciaAlternada asis
	INNER JOIN [socios].[ActividadDeportiva] ad ON asis.id_actividad_dep = ad.id_actividad_dep
	INNER JOIN [socios].[Socio] s ON asis.id_socio = s.id_socio
	INNER JOIN [socios].[Categoria] c ON c.id_categoria = s.id_categoria
	ORDER BY categoria ASC, actividad_deportiva ASC, cantidad_socios_asistencia_alternada DESC

/* Reporte 4
Reporte que contenga a los socios que no han asistido a alguna clase de la actividad que
realizan. El reporte debe contener: Nombre, Apellido, edad, categoría y la actividad
*/

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
		AND asis.asistencia = 'A' -- ausente