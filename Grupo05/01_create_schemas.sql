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
USE Com2900G05;
GO

IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = 'socios')
BEGIN
    EXEC('CREATE SCHEMA socios');
END
ELSE
	PRINT 'Ya existe el esquema "socios"';
GO