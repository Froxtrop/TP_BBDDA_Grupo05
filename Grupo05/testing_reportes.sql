/***********************************************************************
 * Enunciado: Entrega 6, reportes solicitados.
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

RAISERROR('Este script no está pensado para ejecutarse "de una" con F5. Seleccioná y ejecutá de a poco.', 16, 1);
GO

/* Archivo de testing para probar los reportes solicitados en la entrega 6 */

-- Usamos la base de datos del proyecto
USE Com2900G05
GO

/***********************************************************************
REPORTE 1
Reporte de los socios morosos, que hayan incumplido en más de dos
	oportunidades dado un rango de fechas a ingresar. El reporte debe
	contener los siguientes datos:
	- Nombre del reporte: Morosos Recurrentes
	- Período: rango de fechas
	- Nro de socio
	- Nombre y apellido.
	- Mes incumplido
	Ordenados de Mayor a menor por ranking de morosidad
***********************************************************************/

-- Prueba de validación de parámetros reporte 1
-- La fecha_desde no puede ser mayor a la fecha_hasta.
-- Seleccione desde acá
DECLARE @fecha_desde DATE = GETDATE() + 1, @fecha_hasta DATE = GETDATE();
EXEC reportes.reporte1 @fecha_desde, @fecha_hasta;
-- Hasta acá y ejecute

-- Prueba exitosa de ejecución del reporte 1
-- Seleccione desde acá
DECLARE @fecha_desde DATE = GETDATE() - 365, @fecha_hasta DATE = GETDATE();
EXEC reportes.reporte1 @fecha_desde, @fecha_hasta;
-- Hasta acá y ejecute

/***********************************************************************
REPORTE 2
Reporte acumulado mensual de ingresos por actividad deportiva al
	momento en que se saca el reporte tomando como inicio enero.
***********************************************************************/

-- Prueba exitosa de ejecución del reporte 2, ejecute la siguiente línea
EXEC reportes.reporte2;

/***********************************************************************
REPORTE 3
Reporte de la cantidad de socios que han realizado alguna actividad
	de forma alternada (inasistencias) por categoría de socios y
	actividad, ordenado según cantidad de inasistencias ordenadas de
	mayor a menor.
***********************************************************************/

-- Prueba exitosa de ejecución del reporte 3, ejecute la siguiente línea
EXEC reportes.reporte3;

/***********************************************************************
REPORTE 4
Reporte que contenga a los socios que no han asistido a alguna clase
	de la actividad que realizan. El reporte debe contener: Nombre,
	Apellido, edad, categoría y la actividad.
***********************************************************************/

-- Prueba exitosa de ejecución del reporte 4, ejecute la siguiente línea
EXEC reportes.reporte4;