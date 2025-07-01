/***********************************************************************
 * Enunciado: Entrega 4, archivo de testeo de funcionalidades requeridas.
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

-- Usamos la base de datos del proyecto
USE Com2900G05
GO

/* Isertar persona */
-- Seleccionar desde acá
DECLARE @id_persona_res INT;
EXEC socios.registrar_persona_sp
	'Juansito', -- nombre
	'Perez', -- apellido
	24710888, -- DNI
	'juanperez@prueba.com', -- email
	'1974-03-04', -- fecha_de_nacimiento
	'1144445555', -- telefono
	0, -- saldo
	@id_persona = @id_persona_res OUTPUT
SELECT @id_persona_res as id_persona;
-- Hasta acá

-- Revisamos la tabla
SELECT * FROM socios.Persona

/* Registrar socio */

-- Ejecutar desde acá
DECLARE @id_socio_res INT;
DECLARE @id_categoria SMALLINT = 
	socios.fn_obtener_categoria_por_edad(socios.fn_obtener_edad_por_fnac('1974-03-04'));
EXEC socios.registrar_socio_sp
	3, -- id_persona INT
    @id_categoria, --id_categoria SMALLINT,
    'PAMI', --@obra_social VARCHAR(100) = NULL,
    141451, -- @nro_obra_social INT = NULL,
    '1139834893', --@telefono_emergencia VARCHAR(50) = NULL,
    @id_socio = @id_socio_res OUTPUT;
SELECT @id_socio_res as id_socio;
-- Hasta acá

SELECT * FROM socios.Socio

/** Inscripcion a actividades deportivas **/
SELECT * FROM socios.ActividadDeportiva

EXEC socios.inscribir_socio_a_actividad_dep_sp
	1, -- id_socio
	2 -- id_actividad_deportiva

SELECT * FROM socios.InscripcionActividadDeportiva

/** Cargar asistencia a actividades deportivas **/
EXEC socios.asistencia_socio_a_actividad_dep_sp
	1, -- id_socio
	2, -- id_actividad_rec
	'2025-07-08', -- fecha clase
	'A', -- asistencia
	'Ramiro Gomez', -- profesor
	'ramirogomez@prueba.com' -- email profesor

SELECT * FROM socios.AsistenciaActividadDeportiva

/** Baja Inscripcion a actividades deportivas **/
EXEC socios.baja_inscripcion_actividad_dep_sp
	1 -- id_inscripcion_deportiva
	

SELECT * FROM socios.InscripcionActividadDeportiva

/** Inscripcion a actividades recreativas **/
SELECT * FROM socios.ActividadRecreativa

EXEC socios.inscribir_socio_a_actividad_rec_sp
	1, -- id_socio
	2, -- id_actividad_rec
	'Día' -- modalidad

SELECT * FROM socios.InscripcionActividadRecreativa

/** Cargar asistencia actividad recreativva **/
EXEC socios.asistencia_socio_a_actividad_rec_sp
	1, -- id_socio
	2, -- id_actividad_rec
	'2025-06-29' -- fecha de asistencia

-- Actividad a la que no se inscribió prueba de validacion
EXEC socios.asistencia_socio_a_actividad_rec_sp
	1, -- id_socio
	1, -- id_actividad_rec
	'2025-06-29' -- fecha de asistencia

-- Actividad que no existe
EXEC socios.asistencia_socio_a_actividad_rec_sp
	1, -- id_socio
	20, -- id_actividad_rec
	'2025-06-29' -- fecha de asistencia

-- Socio inexistente
EXEC socios.asistencia_socio_a_actividad_rec_sp
	1912389, -- id_socio
	2, -- id_actividad_rec
	'2025-06-29' -- fecha de asistencia

SELECT * FROM socios.AsistenciaActividadRecreativa

/** Baja Inscripcion a actividades recreativas **/
EXEC socios.baja_inscripcion_actividad_rec_sp
	4 -- id_inscripcion_recreativa
	
SELECT * FROM socios.InscripcionActividadRecreativa