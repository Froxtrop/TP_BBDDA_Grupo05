/******************************************************************
 * Enunciado:
 *
 * Fecha de entrega: dd/MM/yyyy
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
 ******************************************************************/

IF DB_ID('Com2900G05') IS NULL
BEGIN
    CREATE DATABASE Com2900G05;
END
ELSE
	PRINT 'Ya existe la Base de Datos Com2900G05';
GO