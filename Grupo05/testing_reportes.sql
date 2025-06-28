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

RAISERROR('Este script no est� pensado para ejecutarse "de una" con F5. Seleccion� y ejecut� de a poco.', 16, 1);
GO

/* Archivo de testing para probar los reportes solicitados en la entrega 6 */

-- Usamos la base de datos del proyecto
USE Com2900G05
GO

/***********************************************************************
REPORTE 1
Reporte de los socios morosos, que hayan incumplido en m�s de dos
	oportunidades dado un rango de fechas a ingresar. El reporte debe
	contener los siguientes datos:
	- Nombre del reporte: Morosos Recurrentes
	- Per�odo: rango de fechas
	- Nro de socio
	- Nombre y apellido.
	- Mes incumplido
	Ordenados de Mayor a menor por ranking de morosidad
***********************************************************************/

-- Prueba de validaci�n de par�metros reporte 1
-- La fecha_desde no puede ser mayor a la fecha_hasta.
-- Seleccione desde ac�
DECLARE @fecha_desde DATE = GETDATE() + 1, @fecha_hasta DATE = GETDATE();
EXEC reportes.reporte1 @fecha_desde, @fecha_hasta;
-- Hasta ac� y ejecute

-- Prueba exitosa de ejecuci�n del reporte 1
-- Seleccione desde ac�
DECLARE @fecha_desde DATE = GETDATE() - 365, @fecha_hasta DATE = GETDATE();
EXEC reportes.reporte1 @fecha_desde, @fecha_hasta;
-- Hasta ac� y ejecute

/***********************************************************************
REPORTE 2
Reporte acumulado mensual de ingresos por actividad deportiva al
	momento en que se saca el reporte tomando como inicio enero.
***********************************************************************/

-- Prueba exitosa de ejecuci�n del reporte 2, ejecute la siguiente l�nea
EXEC reportes.reporte2;

/***********************************************************************
REPORTE 3
Reporte de la cantidad de socios que han realizado alguna actividad
	de forma alternada (inasistencias) por categor�a de socios y
	actividad, ordenado seg�n cantidad de inasistencias ordenadas de
	mayor a menor.
***********************************************************************/

-- Prueba exitosa de ejecuci�n del reporte 3, ejecute la siguiente l�nea
EXEC reportes.reporte3;

/***********************************************************************
REPORTE 4
Reporte que contenga a los socios que no han asistido a alguna clase
	de la actividad que realizan. El reporte debe contener: Nombre,
	Apellido, edad, categor�a y la actividad.
***********************************************************************/

-- Prueba exitosa de ejecuci�n del reporte 4, ejecute la siguiente l�nea
EXEC reportes.reporte4;