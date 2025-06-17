/******************************************************************
 * Enunciado:
 *
 * Fecha de entrega: dd/MM/yyyy
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
 ******************************************************************/
USE Com2900G05;
GO

IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = 'socios')
BEGIN
    EXEC('CREATE SCHEMA socios');
END
ELSE
	PRINT 'Ya existe el esquema "socios"';
GO