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

 /*
	ESTOS ERAN LOS TEST VIEJOS ANTES DE LA CORRECCIÓN DE QUE UN SOCIO AL MOMENTO DE INSCRIBIRSE COMO
	SOCIO, SE LE GENERE UNA FACTURA AUTOMÁTICA EN BASE A LA TARIFA DE LA CATEGORÍA CORRESPONDIENTE
	SEGÚN SU EDAD Y LA ACTIVIDAD A LA QUE ESTÉ INSCRIBIENDOSE.
	
	Las pruebas en base a esa corrección, están en testing_socios_inscripcion_facturacion_automatica
	Las pruebas en este script siguen funcionando, aunque puede que haya que renombrar o cambiar algunos parámetro
 */


RAISERROR('Este script no está pensado para ejecutarse "de una" con F5. Seleccioná y ejecutá de a poco.', 16, 1);
GO

USE Com2900G05
GO

-- EN CASO DE NO HABER EJECUTADO INSERCIÓN CON DATOS DE TARIFAS ACTUALES, REALIZAR ESTA EJECUCIÓN
-- Desde acá
INSERT INTO socios.TarifaCategoria (valor, vigencia_desde, vigencia_hasta, id_categoria)
VALUES (30500, '2025-06-01', '2025-12-31', 3),
	   (20500, '2025-06-01', '2025-12-31', 2),
	   (10500, '2025-06-01', '2025-12-31', 1);

INSERT INTO socios.TarifaActividadDeportiva(id_actividad_dep, vigente_desde, vigente_hasta, valor)
VALUES (1, '2025-07-01', '2025-12-31', 10000),
	   (2, '2025-07-01', '2025-12-31', 30000),
	   (3, '2025-07-01', '2025-12-31', 25000),
	   (4, '2025-07-01', '2025-12-31', 30000),
	   (5, '2025-07-01', '2025-12-31', 45000),
	   (6, '2025-07-01', '2025-12-31', 2000)

-- Hasta acá
SELECT * FROM socios.TarifaCategoria

DELETE FROM socios.Socio;
DELETE FROM socios.Parentesco;
DELETE FROM socios.Persona;

USE Com2900G05
GO
-- Desde acá
-- Socio menor con adulto responsable a cargo que no es socio:
DECLARE @id_persona_menor_solo INT,
		@id_socio_menor_solo INT,
		@id_persona_resp_menor_solo INT;

EXEC socios.registrar_inscripcion_menor_sp
    @nombre_menor = 'Lucio',
    @apellido_menor = 'Franco',
    @dni_menor = 44111222,
    @email_menor = 'luciofranco@example.com',
    @fecha_nac_menor = '2010-04-01',
    @telefono_menor = '011-9999-8888',
    @obra_social = 'Galeno',
    @nro_obra_social = 456789,
    @telefono_emergencia = '011-3344-5566',
    @nombre_resp = 'Mario',
    @apellido_resp = 'Franco',
    @dni_resp = 22333444,
    @email_resp = 'mariofranco@example.com',
    @fecha_nac_resp = '1980-05-01',
    @telefono_resp = '011-1234-5678',
    @parentesco = 'P',
    @id_persona_menor = @id_persona_menor_solo OUTPUT,
    @id_socio_menor = @id_socio_menor_solo OUTPUT,
    @id_persona_resp = @id_persona_resp_menor_solo OUTPUT;
PRINT '[Éxito] [registrar_inscripcion_menor_sp]: Menor registrado con ID = ' + CAST(@id_persona_menor_solo AS VARCHAR);
PRINT '[Éxito] [registrar_inscripcion_menor_sp]: Socio menor generado con ID = ' + CAST(@id_socio_menor_solo AS VARCHAR);
PRINT '[Éxito] [registrar_inscripcion_menor_sp]: Responsable registrado con ID = ' + CAST(@id_persona_resp_menor_solo AS VARCHAR);

DECLARE @id_factura_socio_menor INT;
EXEC socios.facturacion_membresia_socio_sp  
	@id_socio = @id_socio_menor_solo,
	@id_factura = @id_factura_socio_menor OUTPUT;
SELECT * FROM socios.Factura
-- Hasta acá


-- Socio mayor responsable de sí mismo:
-- Desde acá
DECLARE @id_persona_mayor_solo INT, @id_socio_mayor_solo INT;
EXEC socios.inscripcion_socio_sp
    @nombre = 'Carla',
    @apellido = 'Domínguez',
    @dni = 31234567,
    @email = 'carladom@example.com',
    @fecha_de_nacimiento = '2000-05-15',
    @telefono = '011-2233-4455',
    @obra_social = 'OSDE',
    @nro_obra_social = 556677,
    @telefono_emergencia = '011-8877-6655',
    @id_persona = @id_persona_mayor_solo OUTPUT,
    @id_socio = @id_socio_mayor_solo OUTPUT;
PRINT '[Éxito] [inscripcion_socio_sp]: Persona registrada con ID = ' + CAST(@id_persona_mayor_solo AS VARCHAR);
PRINT '[Éxito] [inscripcion_socio_sp]: Socio generado con ID = ' + CAST(@id_socio_mayor_solo AS VARCHAR);

DECLARE @id_factura_socio_mayor_solo INT;

EXEC socios.facturacion_membresia_socio_sp  
	@id_socio = @id_socio_mayor_solo,
	@id_factura = @id_factura_socio_mayor_solo OUTPUT;

SELECT * FROM socios.Factura
	WHERE id_factura = @id_factura_socio_mayor_solo
-- Hasta acá


-- Desde acá
-- Socio mayor a cargo de un socio menor
DECLARE @id_persona_mayor_resp_solo INT, -- id de la persona mayor resp de UN solo socio menor
		@id_socio_mayor_resp_solo INT, -- id de socio mayor resp de UN solo socio menor
		@id_persona_menor_de_resp_solo INT,  -- id de la persona menor a cargo de un resp
		@id_socio_menor_de_resp_solo INT; -- id de socio menor a cargo de un resp

EXEC socios.inscripcion_socio_sp -- PERSONA MAYOR
    @nombre = 'Christian',
    @apellido = 'Gray',
    @dni = 9122018,
    @email = 'soyprofe@example.com',
    @fecha_de_nacimiento = '2000-05-15',
    @telefono = '011-2233-4455',
    @obra_social = 'OSDE',
    @nro_obra_social = 556677,
    @telefono_emergencia = '011-8877-6655',
    @id_persona = @id_persona_mayor_resp_solo OUTPUT,
    @id_socio = @id_socio_mayor_resp_solo OUTPUT;
PRINT '[Éxito] [inscripcion_socio_sp]: Persona registrada con ID = ' + CAST(@id_persona_mayor_resp_solo AS VARCHAR);
PRINT '[Éxito] [inscripcion_socio_sp]: Socio generado con ID = ' + CAST(@id_socio_mayor_resp_solo AS VARCHAR);

EXEC socios.registrar_inscripcion_menor_sp
    @nombre_menor = 'Mateo',
    @apellido_menor = 'Morinigo',
    @dni_menor = 88653926,
    @email_menor = 'morimate@example.com',
    @fecha_nac_menor = '2010-04-01',
    @telefono_menor = '011-9999-8888',
    @obra_social = 'Galeno',
    @nro_obra_social = 456789,
    @telefono_emergencia = '011-3344-5566',
    @parentesco = 'P',
    @id_persona_menor = @id_persona_menor_de_resp_solo OUTPUT,
    @id_socio_menor = @id_socio_menor_de_resp_solo OUTPUT,
    @id_persona_resp = @id_persona_mayor_resp_solo OUTPUT;
PRINT '[Éxito] [registrar_inscripcion_menor_sp]: Menor registrado con ID = ' + CAST(@id_persona_menor_de_resp_solo AS VARCHAR);
PRINT '[Éxito] [registrar_inscripcion_menor_sp]: Socio menor generado con ID = ' + CAST(@id_socio_menor_de_resp_solo AS VARCHAR);

DECLARE @id_factura_socio_mayor_resp_solo INT, -- Factura de Socio Mayor
		@id_factura_socio_menor_de_resp_solo INT; -- Factura de Socio Menor

EXEC socios.facturacion_membresia_socio_sp -- Facturacion del Socio Menor
	@id_socio = @id_socio_menor_de_resp_solo,
	@id_factura = @id_factura_socio_menor_de_resp_solo OUTPUT;

EXEC socios.facturacion_membresia_socio_sp -- Facturacion del Socio Mayor
	@id_socio = @id_socio_mayor_resp_solo,
	@id_factura = @id_factura_socio_mayor_resp_solo OUTPUT;

-- Demostración
SELECT F.*, P.id_persona as ID_Resp, (P.nombre+' '+P.apellido) as Responsable FROM socios.Factura F
	JOIN socios.FacturaResponsable R
		ON F.id_factura = R.id_factura
	JOIN socios.Persona P
		ON P.id_persona = R.id_persona
WHERE F.id_factura = @id_factura_socio_menor_de_resp_solo
	OR F.id_factura = @id_factura_socio_mayor_resp_solo
-- Hasta acá


-- Desde acá
-- Tres socios menores y un responsable que no es socio
DECLARE @id_persona_mayor_resp_de_3 INT, -- id de la persona mayor resp de 3 socios menor
		@id_persona_menor_de_resp_1 INT,  -- id de la persona1 menor a cargo de un resp
		@id_socio_menor_de_resp_1 INT, -- id de socio1 menor a cargo de un resp
		@id_persona_menor_de_resp_2 INT,  -- id de la persona2 menor a cargo de un resp
		@id_socio_menor_de_resp_2 INT, -- id de socio2 menor a cargo de un resp
		@id_persona_menor_de_resp_3 INT,  -- id de la persona3 menor a cargo de un resp
		@id_socio_menor_de_resp_3 INT; -- id de socio3 menor a cargo de un resp

EXEC socios.registrar_persona_sp -- MAYOR
    @nombre = 'Valeria',
    @apellido = 'Pilar',
    @dni = 12345678,
    @email = 'valeriapilar@example.com',
    @fecha_de_nacimiento = '1985-04-20',
    @telefono = '011-1234-5678',
    @saldo = 0,
    @id_persona = @id_persona_mayor_resp_de_3 OUTPUT;
PRINT '[Éxito] [registrar_persona_sp]: ID de persona insertada = ' + CAST(@id_persona_mayor_resp_de_3 AS VARCHAR);

EXEC socios.registrar_inscripcion_menor_sp -- MENOR 1
    @nombre_menor = 'Valentina',
    @apellido_menor = 'Benitez',
    @dni_menor = 44999888,
    @email_menor = 'valentinapilar@example.com',
    @fecha_nac_menor = '2011-08-15',
    @telefono_menor = '011-2222-4444',
    @obra_social = 'Swiss Medical',
    @nro_obra_social = 112233,
    @telefono_emergencia = '011-7777-1234',
    @parentesco = 'M',
    @id_persona_menor = @id_persona_menor_de_resp_1 OUTPUT,
    @id_socio_menor = @id_socio_menor_de_resp_1 OUTPUT,
    @id_persona_resp = @id_persona_mayor_resp_de_3 OUTPUT;
PRINT '[Éxito] [registrar_inscripcion_menor_sp]: Menor registrado con ID = ' + CAST(@id_persona_menor_de_resp_1 AS VARCHAR);
PRINT '[Éxito] [registrar_inscripcion_menor_sp]: Socio menor generado con ID = ' + CAST(@id_socio_menor_de_resp_1 AS VARCHAR);

EXEC socios.registrar_inscripcion_menor_sp -- MENOR 2
    @nombre_menor = 'Agustina',
    @apellido_menor = 'Benitez',
    @dni_menor = 44999887,
    @email_menor = 'agustinapilar@example.com',
    @fecha_nac_menor = '2011-08-15',
    @telefono_menor = '011-2222-4444',
    @obra_social = 'Swiss Medical',
    @nro_obra_social = 112233,
    @telefono_emergencia = '011-7777-1234',
    @parentesco = 'M',
    @id_persona_menor = @id_persona_menor_de_resp_2 OUTPUT,
    @id_socio_menor = @id_socio_menor_de_resp_2 OUTPUT,
    @id_persona_resp = @id_persona_mayor_resp_de_3 OUTPUT;
PRINT '[Éxito] [registrar_inscripcion_menor_sp]: Menor registrado con ID = ' + CAST(@id_persona_menor_de_resp_2 AS VARCHAR);
PRINT '[Éxito] [registrar_inscripcion_menor_sp]: Socio menor generado con ID = ' + CAST(@id_socio_menor_de_resp_2 AS VARCHAR);

EXEC socios.registrar_inscripcion_menor_sp -- MENOR 3
    @nombre_menor = 'Tamara',
    @apellido_menor = 'Benitez',
    @dni_menor = 44999889,
    @email_menor = 'tamaraapilar@example.com',
    @fecha_nac_menor = '2011-08-15',
    @telefono_menor = '011-2222-4444',
    @obra_social = 'Swiss Medical',
    @nro_obra_social = 112233,
    @telefono_emergencia = '011-7777-1234',
    @parentesco = 'M',
    @id_persona_menor = @id_persona_menor_de_resp_3 OUTPUT,
    @id_socio_menor = @id_socio_menor_de_resp_3 OUTPUT,
    @id_persona_resp = @id_persona_mayor_resp_de_3 OUTPUT;
PRINT '[Éxito] [registrar_inscripcion_menor_sp]: Menor registrado con ID = ' + CAST(@id_persona_menor_de_resp_3 AS VARCHAR);
PRINT '[Éxito] [registrar_inscripcion_menor_sp]: Socio menor generado con ID = ' + CAST(@id_socio_menor_de_resp_3 AS VARCHAR);

DECLARE @id_factura_socio_menor_de_resp_1 INT,
		@id_factura_socio_menor_de_resp_2 INT,
		@id_factura_socio_menor_de_resp_3 INT;

EXEC socios.facturacion_membresia_socio_sp
	@id_socio = @id_socio_menor_de_resp_1,
	@id_factura = @id_factura_socio_menor_de_resp_1 OUTPUT;

EXEC socios.facturacion_membresia_socio_sp
	@id_socio = @id_socio_menor_de_resp_2,
	@id_factura = @id_factura_socio_menor_de_resp_2 OUTPUT;

EXEC socios.facturacion_membresia_socio_sp
	@id_socio = @id_socio_menor_de_resp_3,
	@id_factura = @id_factura_socio_menor_de_resp_3 OUTPUT;

-- Demostración
SELECT F.*, P.id_persona as ID_Resp, (P.nombre+' '+P.apellido) as Responsable FROM socios.Factura F
	JOIN socios.FacturaResponsable R
		ON F.id_factura = R.id_factura
	JOIN socios.Persona P
		ON P.id_persona = R.id_persona
WHERE F.id_factura in (@id_factura_socio_menor_de_resp_1, @id_factura_socio_menor_de_resp_2, @id_factura_socio_menor_de_resp_3);
-- Hasta acá

-- Desde acá
-- Tres socios menores y un responsable socio
DECLARE @id_persona_mayor_resp_de_3 INT, -- id de la persona mayor resp de 3 socios menor
		@id_socio_mayor_resp_de_3 INT, -- id de socio mayor resp de 3 socios menor
		@id_persona_menor_de_resp_1 INT,  -- id de la persona1 menor a cargo de un resp
		@id_socio_menor_de_resp_1 INT, -- id de socio1 menor a cargo de un resp
		@id_persona_menor_de_resp_2 INT,  -- id de la persona2 menor a cargo de un resp
		@id_socio_menor_de_resp_2 INT, -- id de socio2 menor a cargo de un resp
		@id_persona_menor_de_resp_3 INT,  -- id de la persona3 menor a cargo de un resp
		@id_socio_menor_de_resp_3 INT; -- id de socio3 menor a cargo de un resp
		
EXEC socios.inscripcion_socio_sp -- MAYOR
    @nombre = 'Marcelo',
    @apellido = 'Gallardo',
    @dni = 11111111,
    @email = 'madrid912@example.com',
    @fecha_de_nacimiento = '1989-05-15',
    @telefono = '011-2233-4455',
    @obra_social = 'OSDE',
    @nro_obra_social = 556677,
    @telefono_emergencia = '011-8877-6655',
    @id_persona = @id_persona_mayor_resp_de_3 OUTPUT,
    @id_socio = @id_socio_mayor_resp_de_3 OUTPUT;
PRINT '[Éxito] [inscripcion_socio_sp]: Persona registrada con ID = ' + CAST(@id_persona_mayor_resp_de_3 AS VARCHAR);
PRINT '[Éxito] [inscripcion_socio_sp]: Socio generado con ID = ' + CAST(@id_persona_mayor_resp_de_3 AS VARCHAR);

EXEC socios.registrar_inscripcion_menor_sp -- MENOR 1
    @nombre_menor = 'Carlos',
    @apellido_menor = 'Gallardo',
    @dni_menor = 45536297,
    @email_menor = 'tefuistealab@example.com',
    @fecha_nac_menor = '2015-08-15',
    @telefono_menor = '011-2222-4444',
    @obra_social = 'Swiss Medical',
    @nro_obra_social = 112233,
    @telefono_emergencia = '011-7777-1234',
    @parentesco = 'P',
    @id_persona_menor = @id_persona_menor_de_resp_1 OUTPUT,
    @id_socio_menor = @id_socio_menor_de_resp_1 OUTPUT,
    @id_persona_resp = @id_persona_mayor_resp_de_3 OUTPUT;
PRINT '[Éxito] [registrar_inscripcion_menor_sp]: Menor registrado con ID = ' + CAST(@id_persona_menor_de_resp_1 AS VARCHAR);
PRINT '[Éxito] [registrar_inscripcion_menor_sp]: Socio menor generado con ID = ' + CAST(@id_socio_menor_de_resp_1 AS VARCHAR);

EXEC socios.registrar_inscripcion_menor_sp -- MENOR 2
    @nombre_menor = 'Agustina',
    @apellido_menor = 'Gallardo',
    @dni_menor = 44586325,
    @email_menor = 'aguss@example.com',
    @fecha_nac_menor = '2011-08-15',
    @telefono_menor = '011-2222-4444',
    @obra_social = 'Swiss Medical',
    @nro_obra_social = 112233,
    @telefono_emergencia = '011-7777-1234',
    @parentesco = 'P',
    @id_persona_menor = @id_persona_menor_de_resp_2 OUTPUT,
    @id_socio_menor = @id_socio_menor_de_resp_2 OUTPUT,
    @id_persona_resp = @id_persona_mayor_resp_de_3 OUTPUT;
PRINT '[Éxito] [registrar_inscripcion_menor_sp]: Menor registrado con ID = ' + CAST(@id_persona_menor_de_resp_2 AS VARCHAR);
PRINT '[Éxito] [registrar_inscripcion_menor_sp]: Socio menor generado con ID = ' + CAST(@id_socio_menor_de_resp_2 AS VARCHAR);

EXEC socios.registrar_inscripcion_menor_sp -- MENOR 3
    @nombre_menor = 'Juan Roman',
    @apellido_menor = 'Gallardo',
    @dni_menor = 77777777,
    @email_menor = 'jjr@example.com',
    @fecha_nac_menor = '2012-08-15',
    @telefono_menor = '011-2222-4444',
    @obra_social = 'Swiss Medical',
    @nro_obra_social = 112233,
    @telefono_emergencia = '011-7777-1234',
    @parentesco = 'P',
    @id_persona_menor = @id_persona_menor_de_resp_3 OUTPUT,
    @id_socio_menor = @id_socio_menor_de_resp_3 OUTPUT,
    @id_persona_resp = @id_persona_mayor_resp_de_3 OUTPUT;
PRINT '[Éxito] [registrar_inscripcion_menor_sp]: Menor registrado con ID = ' + CAST(@id_persona_menor_de_resp_3 AS VARCHAR);
PRINT '[Éxito] [registrar_inscripcion_menor_sp]: Socio menor generado con ID = ' + CAST(@id_socio_menor_de_resp_3 AS VARCHAR);

DECLARE @id_factura_socio_mayor_resp_3 INT,
		@id_factura_socio_menor_de_resp_1 INT,
		@id_factura_socio_menor_de_resp_2 INT,
		@id_factura_socio_menor_de_resp_3 INT;

EXEC socios.facturacion_membresia_socio_sp -- Facturacion del Socio Mayor
	@id_socio = @id_socio_mayor_resp_de_3,
	@id_factura = @id_factura_socio_mayor_resp_3 OUTPUT;

EXEC socios.facturacion_membresia_socio_sp
	@id_socio = @id_socio_menor_de_resp_1,
	@id_factura = @id_factura_socio_menor_de_resp_1 OUTPUT;

EXEC socios.facturacion_membresia_socio_sp
	@id_socio = @id_socio_menor_de_resp_2,
	@id_factura = @id_factura_socio_menor_de_resp_2 OUTPUT;

EXEC socios.facturacion_membresia_socio_sp
	@id_socio = @id_socio_menor_de_resp_3,
	@id_factura = @id_factura_socio_menor_de_resp_3 OUTPUT;

-- Demostración
SELECT F.*, P.id_persona as ID_Resp, (P.nombre+' '+P.apellido) as Responsable FROM socios.Factura F
	JOIN socios.FacturaResponsable R
		ON F.id_factura = R.id_factura
	JOIN socios.Persona P
		ON P.id_persona = R.id_persona
WHERE F.id_factura in (@id_factura_socio_mayor_resp_3,
					   @id_factura_socio_menor_de_resp_1,
					   @id_factura_socio_menor_de_resp_2,
					   @id_factura_socio_menor_de_resp_3);
-- Hasta acá

-- SI ALGUNO DE LOS SOCIOS ESTA INSCRIPTO A ALGUNA ACTIVIDAD:
-- Desde acá
-- Tres socios menores, uno en una actividad y otro en más de una, y un responsable que no es socio
DECLARE @id_persona_mayor_resp_de_3 INT, -- id de la persona mayor resp de 3 socios menor
		@id_persona_menor_de_resp_1 INT,  -- id de la persona1 menor a cargo de un resp
		@id_socio_menor_de_resp_1 INT, -- id de socio1 menor a cargo de un resp
		@id_persona_menor_de_resp_2 INT,  -- id de la persona2 menor a cargo de un resp
		@id_socio_menor_de_resp_2 INT, -- id de socio2 menor a cargo de un resp
		@id_persona_menor_de_resp_3 INT,  -- id de la persona3 menor a cargo de un resp
		@id_socio_menor_de_resp_3 INT; -- id de socio3 menor a cargo de un resp

EXEC socios.registrar_persona_sp -- MAYOR
    @nombre = 'Valeria',
    @apellido = 'Pilar',
    @dni = 7898987,
    @email = 'valeriapilar@example.com',
    @fecha_de_nacimiento = '1985-04-20',
    @telefono = '011-1234-5678',
    @saldo = 0,
    @id_persona = @id_persona_mayor_resp_de_3 OUTPUT;
PRINT '[Éxito] [registrar_persona_sp]: ID de persona insertada = ' + CAST(@id_persona_mayor_resp_de_3 AS VARCHAR);

EXEC socios.registrar_inscripcion_menor_sp -- MENOR 1
    @nombre_menor = 'Valentina',
    @apellido_menor = 'Benitez',
    @dni_menor = 44999888,
    @email_menor = 'valentinapilar@example.com',
    @fecha_nac_menor = '2011-08-15',
    @telefono_menor = '011-2222-4444',
    @obra_social = 'Swiss Medical',
    @nro_obra_social = 112233,
    @telefono_emergencia = '011-7777-1234',
    @parentesco = 'M',
    @id_persona_menor = @id_persona_menor_de_resp_1 OUTPUT,
    @id_socio_menor = @id_socio_menor_de_resp_1 OUTPUT,
    @id_persona_resp = @id_persona_mayor_resp_de_3 OUTPUT;
PRINT '[Éxito] [registrar_inscripcion_menor_sp]: Menor registrado con ID = ' + CAST(@id_persona_menor_de_resp_1 AS VARCHAR);
PRINT '[Éxito] [registrar_inscripcion_menor_sp]: Socio menor generado con ID = ' + CAST(@id_socio_menor_de_resp_1 AS VARCHAR);

EXEC socios.registrar_inscripcion_menor_sp -- MENOR 2
    @nombre_menor = 'Agustina',
    @apellido_menor = 'Benitez',
    @dni_menor = 44999887,
    @email_menor = 'agustinapilar@example.com',
    @fecha_nac_menor = '2011-08-15',
    @telefono_menor = '011-2222-4444',
    @obra_social = 'Swiss Medical',
    @nro_obra_social = 112233,
    @telefono_emergencia = '011-7777-1234',
    @parentesco = 'M',
    @id_persona_menor = @id_persona_menor_de_resp_2 OUTPUT,
    @id_socio_menor = @id_socio_menor_de_resp_2 OUTPUT,
    @id_persona_resp = @id_persona_mayor_resp_de_3 OUTPUT;
PRINT '[Éxito] [registrar_inscripcion_menor_sp]: Menor registrado con ID = ' + CAST(@id_persona_menor_de_resp_2 AS VARCHAR);
PRINT '[Éxito] [registrar_inscripcion_menor_sp]: Socio menor generado con ID = ' + CAST(@id_socio_menor_de_resp_2 AS VARCHAR);

EXEC socios.registrar_inscripcion_menor_sp -- MENOR 3
    @nombre_menor = 'Tamara',
    @apellido_menor = 'Benitez',
    @dni_menor = 44999889,
    @email_menor = 'tamaraapilar@example.com',
    @fecha_nac_menor = '2011-08-15',
    @telefono_menor = '011-2222-4444',
    @obra_social = 'Swiss Medical',
    @nro_obra_social = 112233,
    @telefono_emergencia = '011-7777-1234',
    @parentesco = 'M',
    @id_persona_menor = @id_persona_menor_de_resp_3 OUTPUT,
    @id_socio_menor = @id_socio_menor_de_resp_3 OUTPUT,
    @id_persona_resp = @id_persona_mayor_resp_de_3 OUTPUT;
PRINT '[Éxito] [registrar_inscripcion_menor_sp]: Menor registrado con ID = ' + CAST(@id_persona_menor_de_resp_3 AS VARCHAR);
PRINT '[Éxito] [registrar_inscripcion_menor_sp]: Socio menor generado con ID = ' + CAST(@id_socio_menor_de_resp_3 AS VARCHAR);

-- EL HIJO 3 ESTÁ EN DOS ACTIVIDADES, DEBE TENER DESCUENTO DE CANTIDAD DE ACT DEP
EXEC socios.inscribir_socio_a_actividad_dep_sp  
	@id_socio = @id_socio_menor_de_resp_3,
	@id_actividad_deportiva = 2;

EXEC socios.inscribir_socio_a_actividad_dep_sp  
	@id_socio = @id_socio_menor_de_resp_3,
	@id_actividad_deportiva = 3;

-- EL HIJO 2 ESTÁ EN UNA ACTIVIDAD, NO TIENE DESCUENTO DE CANT ACT DEP
EXEC socios.inscribir_socio_a_actividad_dep_sp  
	@id_socio = @id_socio_menor_de_resp_2,
	@id_actividad_deportiva = 4;

DECLARE @id_factura_socio_menor_de_resp_1 INT,
		@id_factura_socio_menor_de_resp_2 INT,
		@id_factura_socio_menor_de_resp_3 INT;

EXEC socios.facturacion_membresia_socio_sp
	@id_socio = @id_socio_menor_de_resp_1,
	@id_factura = @id_factura_socio_menor_de_resp_1 OUTPUT;

EXEC socios.facturacion_membresia_socio_sp
	@id_socio = @id_socio_menor_de_resp_2,
	@id_factura = @id_factura_socio_menor_de_resp_2 OUTPUT;

EXEC socios.facturacion_membresia_socio_sp
	@id_socio = @id_socio_menor_de_resp_3,
	@id_factura = @id_factura_socio_menor_de_resp_3 OUTPUT;

-- Demostración
SELECT F.*, M.id_socio as CorrespondeA, P.id_persona as ID_Resp, (P.nombre+' '+P.apellido) as Responsable
FROM socios.Factura F
	JOIN socios.FacturaResponsable R
		ON F.id_factura = R.id_factura
	JOIN socios.Persona P
		ON P.id_persona = R.id_persona
	JOIN socios.Membresia M
		ON M.id_factura = F.id_factura
WHERE F.id_factura in (@id_factura_socio_menor_de_resp_1, @id_factura_socio_menor_de_resp_2, @id_factura_socio_menor_de_resp_3);
-- Hasta acá

-- Desde acá
-- Tres socios menores, uno en una actividad y otro en más de una, y un responsable que no es socio
DECLARE @id_persona_mayor_resp_de_3 INT, -- id de la persona mayor resp de 3 socios menor
		@id_persona_menor_de_resp_1 INT,  -- id de la persona1 menor a cargo de un resp
		@id_socio_menor_de_resp_1 INT; -- id de socio3 menor a cargo de un resp

EXEC socios.registrar_persona_sp -- MAYOR
    @nombre = 'Valeria',
    @apellido = 'Pilar',
    @dni = 12321231,
    @email = 'valeriapilar@example.com',
    @fecha_de_nacimiento = '1985-04-20',
    @telefono = '011-1234-5678',
    @saldo = 0,
    @id_persona = @id_persona_mayor_resp_de_3 OUTPUT;
PRINT '[Éxito] [registrar_persona_sp]: ID de persona insertada = ' + CAST(@id_persona_mayor_resp_de_3 AS VARCHAR);

EXEC socios.registrar_inscripcion_menor_sp -- MENOR 1
    @nombre_menor = 'Valentina',
    @apellido_menor = 'Benitez',
    @dni_menor = 32154261,
    @email_menor = 'valentinapilar@example.com',
    @fecha_nac_menor = '2011-08-15',
    @telefono_menor = '011-2222-4444',
    @obra_social = 'Swiss Medical',
    @nro_obra_social = 112233,
    @telefono_emergencia = '011-7777-1234',
    @parentesco = 'M',
    @id_persona_menor = @id_persona_menor_de_resp_1 OUTPUT,
    @id_socio_menor = @id_socio_menor_de_resp_1 OUTPUT,
    @id_persona_resp = @id_persona_mayor_resp_de_3 OUTPUT;
PRINT '[Éxito] [registrar_inscripcion_menor_sp]: Menor registrado con ID = ' + CAST(@id_persona_menor_de_resp_1 AS VARCHAR);
PRINT '[Éxito] [registrar_inscripcion_menor_sp]: Socio menor generado con ID = ' + CAST(@id_socio_menor_de_resp_1 AS VARCHAR);

-- EL HIJO 3 ESTÁ EN DOS ACTIVIDADES, DEBE TENER DESCUENTO DE CANTIDAD DE ACT DEP
EXEC socios.inscribir_socio_a_actividad_dep_sp  
	@id_socio = @id_socio_menor_de_resp_1,
	@id_actividad_deportiva = 2;

EXEC socios.inscribir_socio_a_actividad_dep_sp  
	@id_socio = @id_socio_menor_de_resp_1,
	@id_actividad_deportiva = 3;


DECLARE @id_factura_socio_menor_de_resp_1 INT;

EXEC socios.facturacion_membresia_socio_sp
	@id_socio = @id_socio_menor_de_resp_1,
	@id_factura = @id_factura_socio_menor_de_resp_1 OUTPUT;

-- Demostración
SELECT F.*, M.id_socio as CorrespondeA, P.id_persona as ID_Resp, (P.nombre+' '+P.apellido) as Responsable
FROM socios.Factura F
	JOIN socios.FacturaResponsable R
		ON F.id_factura = R.id_factura
	JOIN socios.Persona P
		ON P.id_persona = R.id_persona
	JOIN socios.Membresia M
		ON M.id_factura = F.id_factura
WHERE F.id_factura = @id_factura_socio_menor_de_resp_1;
-- Hasta acá


-- Socio mayor a cargo de un socio menor
DECLARE @id_persona_mayor_resp_solo INT, -- id de la persona mayor resp de UN solo socio menor
		@id_socio_mayor_resp_solo INT, -- id de socio mayor resp de UN solo socio menor
		@id_persona_menor_de_resp_solo INT,  -- id de la persona menor a cargo de un resp
		@id_socio_menor_de_resp_solo INT; -- id de socio menor a cargo de un resp

EXEC socios.inscripcion_socio_sp -- PERSONA MAYOR
    @nombre = 'Jair',
    @apellido = 'HASDFJ',
    @dni = 9999999,
    @email = 'soyprofe@example.com',
    @fecha_de_nacimiento = '1990-05-15',
    @telefono = '011-2233-4455',
    @obra_social = 'OSDE',
    @nro_obra_social = 556677,
    @telefono_emergencia = '011-8877-6655',
    @id_persona = @id_persona_mayor_resp_solo OUTPUT,
    @id_socio = @id_socio_mayor_resp_solo OUTPUT;
PRINT '[Éxito] [inscripcion_socio_sp]: Persona registrada con ID = ' + CAST(@id_persona_mayor_resp_solo AS VARCHAR);
PRINT '[Éxito] [inscripcion_socio_sp]: Socio generado con ID = ' + CAST(@id_socio_mayor_resp_solo AS VARCHAR);

SELECT @id_socio_mayor_resp_solo
SELECT * FROM socios.Socio WHERE id_socio =5012

DECLARE @id_persona_menor_de_resp_solo INT,  -- id de la persona menor a cargo de un resp
		@id_socio_menor_de_resp_solo INT,
		@id_persona_mayor_resp_solo INT = 158; 
EXEC socios.registrar_inscripcion_menor_sp
    @nombre_menor = 'Gonzalo',
    @apellido_menor = 'Casella',
    @dni_menor = 33333333,
    @email_menor = 'gonza@example.com',
    @fecha_nac_menor = '2010-04-01',
    @telefono_menor = '011-9999-8888',
    @obra_social = 'Galeno',
    @nro_obra_social = 456789,
    @telefono_emergencia = '011-3344-5566',
    @parentesco = 'P',
    @id_persona_menor = @id_persona_menor_de_resp_solo OUTPUT,
    @id_socio_menor = @id_socio_menor_de_resp_solo OUTPUT,
    @id_persona_resp = @id_persona_mayor_resp_solo OUTPUT;

SELECT @id_persona_menor_de_resp_solo, @id_socio_menor_de_resp_solo

DECLARE @id_factura_socio_mayor_resp_solo INT, -- Factura de Socio Mayor
		@id_factura_socio_menor_de_resp_solo INT; -- Factura de Socio Menor

EXEC socios.facturacion_membresia_socio_sp -- Facturacion del Socio Menor
	@id_socio = @id_socio_menor_de_resp_solo,
	@id_factura = @id_factura_socio_menor_de_resp_solo OUTPUT;

EXEC socios.facturacion_membresia_socio_sp -- Facturacion del Socio Mayor
	@id_socio = @id_socio_mayor_resp_solo,
	@id_factura = @id_factura_socio_mayor_resp_solo OUTPUT;

-- Demostración
SELECT F.*, P.id_persona as ID_Resp, (P.nombre+' '+P.apellido) as Responsable FROM socios.Factura F
	JOIN socios.FacturaResponsable R
		ON F.id_factura = R.id_factura
	JOIN socios.Persona P
		ON P.id_persona = R.id_persona
WHERE F.id_factura = @id_factura_socio_menor_de_resp_solo
	OR F.id_factura = @id_factura_socio_mayor_resp_solo
-- Hasta acá