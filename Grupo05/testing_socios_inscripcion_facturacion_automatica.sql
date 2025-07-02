/***********************************************************************
 * Enunciado: Entrega 4, archivo de testeo de funcionalidades requeridas.
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

USE Com2900G05
GO

-- EN CASO DE NO HABER EJECUTADO INSERCI�N CON DATOS DE TARIFAS ACTUALES, REALIZAR ESTA EJECUCI�N
-- Desde ac�
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

-- Hasta ac�

-- Desde ac�
-- Socio menor con adulto responsable a cargo que no es socio:
DECLARE @id_persona_menor_solo INT,
		@id_socio_menor_solo INT,
		@id_persona_resp_menor_solo INT,
		@fecha_actual DATE = GETDATE(),
		@id_factura INT;

EXEC socios.inscripcion_y_facturacion_completa_socio_menor_sp
        @nombre_menor = 'Thiago',
        @apellido_menor = 'Toledo',
        @dni_menor = 3,
        @email_menor = 'tatixit@example.com',
        @fecha_nac_menor = '2010-04-01', -- CATEGORIA Cadete (15 a�os)
        @telefono_menor = '011-9999-8888',
        @obra_social = 'Galeno',
        @nro_obra_social = 456789,
        @telefono_emergencia = '011-3344-5566',
        @nombre_resp = 'Mario',
        @apellido_resp = 'Franco',
        @dni_resp = 7,
        @email_resp = 'mariofranco@example.com',
        @fecha_nac_resp = '1980-05-01',
        @telefono_resp = '011-1234-5678',
        @parentesco = 'P',
		@id_act_dep = 1, -- ACTIVIDAD FUTSAL (PRECIO TARIFA 10.000)
		@fecha_alta_act_dep = @fecha_actual,
		@id_medio_de_pago_resp = 1,
        @id_persona_menor = @id_persona_menor_solo OUTPUT,
        @id_socio_menor = @id_socio_menor_solo OUTPUT,
        @id_persona_resp = @id_persona_resp_menor_solo OUTPUT,
		@id_factura = @id_factura OUTPUT;
PRINT '[�xito] [registrar_inscripcion_menor_sp]: Menor registrado con ID = ' + CAST(@id_persona_menor_solo AS VARCHAR);
PRINT '[�xito] [registrar_inscripcion_menor_sp]: Socio menor generado con ID = ' + CAST(@id_socio_menor_solo AS VARCHAR);
PRINT '[�xito] [registrar_inscripcion_menor_sp]: Responsable registrado con ID = ' + CAST(@id_persona_resp_menor_solo AS VARCHAR);

SELECT * FROM socios.Factura
	WHERE id_factura = @id_factura
-- Hasta ac�

SELECT * FROM socios.Persona