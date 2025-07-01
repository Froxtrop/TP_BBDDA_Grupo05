/*		 ____  _____ ____  ____   ___  _   _    _    
		|  _ \| ____|  _ \/ ___| / _ \| \ | |  / \   
		| |_) |  _| | |_) \___ \| | | |  \| | / ^ \  
		|  __/| |___|  _ < ___) | |_| | |\  |/ ___ \ 
		|_|   |_____|_| \_\____/ \___/|_| \_/_/   \_\
*/
USE Com2900G05;
GO

DECLARE @nuevo_id INT;
-- CASOS EXITOSOS ----------------------------------------------------
-- 1) INSERT:
EXEC socios.registrar_persona_sp
    @nombre = 'Juan',
    @apellido = 'Pérez',
    @dni = 12345678,
    @email = 'juan.perez@example.com',
    @fecha_de_nacimiento = '1985-04-20',
    @telefono = '011-1234-5678',
    @saldo = 0,
    @id_persona = @nuevo_id OUTPUT;
PRINT '[Éxito] [registrar_persona_sp]: ID de persona insertada = ' + CAST(@nuevo_id AS VARCHAR);
SELECT * FROM socios.Persona WHERE id_persona = @nuevo_id;

-- 2) UPDATE:
EXEC socios.actualizar_persona_sp
    @id_persona = @nuevo_id,
    @nombre = 'Juan Carlos',
    @apellido = 'Pérez Gómez',
    @dni = 12345678,
    @email = 'jc.perez@example.com',
    @fecha_de_nacimiento = '1985-04-20',
    @telefono = '011-8765-4321',
    @saldo = 50.00;
PRINT '[Éxito] [actualizar_persona_sp]: Datos actualizados correctamente.';
SELECT * FROM socios.Persona WHERE id_persona = @nuevo_id;

-- 3) DELETE:
BEGIN TRY
    EXEC socios.eliminar_persona_sp @id_persona = @nuevo_id;
END TRY
BEGIN CATCH
    PRINT '[Error] [eliminar_persona_sp]: ' + ERROR_MESSAGE();
END CATCH;
SELECT * FROM socios.Persona WHERE id_persona = @nuevo_id;

-- CASOS DE ERROR -----------------------------------------------------
DECLARE @dup_id INT;

-- 4) INSERT ERROR: DNI duplicado
BEGIN TRY
    EXEC socios.registrar_persona_sp
        @nombre = 'Ana',
        @apellido = 'Gómez',
        @dni = 12345678,
        @email = 'ana.gomez@example.com',
        @fecha_de_nacimiento = '1990-01-15',
        @telefono = '011-2222-3333',
        @saldo = 10,
        @id_persona = @dup_id OUTPUT;
END TRY
BEGIN CATCH
    PRINT '[Error] [registrar_persona_sp]: ' + ERROR_MESSAGE();
END CATCH;

-- 5) INSERT ERROR: Fecha futura
BEGIN TRY
    EXEC socios.registrar_persona_sp
        @nombre = 'Mario',
        @apellido = 'Rossi',
        @dni = 87654321,
        @email = 'mario.rossi@example.com',
        @fecha_de_nacimiento = '2100-01-01',
        @telefono = '011-4444-5555',
        @saldo = 0,
        @id_persona = @dup_id OUTPUT;
END TRY
BEGIN CATCH
    PRINT '[Error] [registrar_persona_sp]: ' + ERROR_MESSAGE();
END CATCH;

-- 6) INSERT ERROR: Email inválido
BEGIN TRY
    EXEC socios.registrar_persona_sp
        @nombre = 'Lucía',
        @apellido = 'López',
        @dni = 33445566,
        @email = 'lucia.lopez',
        @fecha_de_nacimiento = '1992-07-10',
        @telefono = '011-6666-7777',
        @saldo = 0,
        @id_persona = @dup_id OUTPUT;
END TRY
BEGIN CATCH
    PRINT '[Error] [registrar_persona_sp]: ' + ERROR_MESSAGE();
END CATCH;

-- 7) INSERT ERROR: Saldo negativo
BEGIN TRY
    EXEC socios.registrar_persona_sp
        @nombre = 'Pedro',
        @apellido = 'Martínez',
        @dni = 99887766,
        @email = 'pedro.martinez@example.com',
        @fecha_de_nacimiento = '1980-05-05',
        @telefono = '011-8888-9999',
        @saldo = -100,
        @id_persona = @dup_id OUTPUT;
END TRY
BEGIN CATCH
    PRINT '[Error] [registrar_persona_sp]: ' + ERROR_MESSAGE();
END CATCH;

-- 8) UPDATE ERROR: Persona inexistente
BEGIN TRY
    EXEC socios.actualizar_persona_sp
        @id_persona = 99999,
        @nombre = 'Prueba',
        @apellido = 'NoExiste',
        @dni = 11223344,
        @email = 'no@existe.com',
        @fecha_de_nacimiento = '1990-01-01',
        @telefono = '011-0000-0000',
        @saldo = 0;
END TRY
BEGIN CATCH
    PRINT '[Error] [actualizar_persona_sp]: ' + ERROR_MESSAGE();
END CATCH;

-- 9) UPDATE ERROR: DNI duplicado
BEGIN TRY
    EXEC socios.actualizar_persona_sp
        @id_persona = @nuevo_id,
        @nombre = 'Juan',
        @apellido = 'Pérez',
        @dni = 87654321,
        @email = 'juan.dup@example.com',
        @fecha_de_nacimiento = '1985-04-20',
        @telefono = '011-1234-5678',
        @saldo = 0;
END TRY
BEGIN CATCH
    PRINT '[Error] [actualizar_persona_sp]: ' + ERROR_MESSAGE();
END CATCH;

-- 10) UPDATE ERROR: Fecha futura
BEGIN TRY
    EXEC socios.actualizar_persona_sp
        @id_persona = @nuevo_id,
        @nombre = 'Juan',
        @apellido = 'Pérez',
        @dni = 12345678,
        @email = 'juan@example.com',
        @fecha_de_nacimiento = '2100-01-01',
        @telefono = '011-1234-5678',
        @saldo = 0;
END TRY
BEGIN CATCH
    PRINT '[Error] [actualizar_persona_sp]: ' + ERROR_MESSAGE();
END CATCH;

-- 11) UPDATE ERROR: Saldo negativo
BEGIN TRY
    EXEC socios.actualizar_persona_sp
        @id_persona = @nuevo_id,
        @nombre = 'Juan',
        @apellido = 'Pérez',
        @dni = 12345678,
        @email = 'juan@example.com',
        @fecha_de_nacimiento = '1985-04-20',
        @telefono = '011-1234-5678',
        @saldo = -50;
END TRY
BEGIN CATCH
    PRINT '[Error] [actualizar_persona_sp]: ' + ERROR_MESSAGE();
END CATCH;
GO

/*				 ____   ___   ____ ___ ___  
				/ ___| / _ \ / ___|_ _/ _ \ 
				\___ \| | | | |    | | | | |
				 ___) | |_| | |___ | | |_| |
				|____/ \___/ \____|___\___/ 
*/
USE Com2900G05;
GO

DECLARE @socio_id INT;

-- CASOS EXITOSOS ----------------------------------------------------
-- 1) INSERT:
EXEC socios.registrar_socio_sp
    @id_persona = 1,
    @id_categoria = 2,
    @obra_social = 'OSDE',
    @nro_obra_social = 123456,
    @telefono_emergencia = '011-9999-0000',
    @id_socio = @socio_id OUTPUT;
PRINT '[Éxito] [registrar_socio_sp]: ID de socio insertado = ' + CAST(@socio_id AS VARCHAR);
SELECT * FROM socios.Socio WHERE id_socio = @socio_id;

-- 2) UPDATE:
EXEC socios.actualizar_socio_sp
    @id_socio = @socio_id,
    @id_categoria = 3,
    @obra_social = 'Swiss Medical',
    @nro_obra_social = 654321,
    @telefono_emergencia = '011-1111-2222';
PRINT '[Éxito] [actualizar_socio_sp]: Datos del socio actualizados correctamente.';
SELECT * FROM socios.Socio WHERE id_socio = @socio_id;

-- 3) DELETE:
EXEC socios.eliminar_socio_sp @id_socio = @socio_id;
PRINT '[Éxito] [eliminar_socio_sp]: Socio desactivado correctamente.';
SELECT * FROM socios.Socio WHERE id_socio = @socio_id;

-- CASOS DE ERROR -----------------------------------------------------
-- 4) INSERT ERROR: Persona no existe
BEGIN TRY
    EXEC socios.registrar_socio_sp
        @id_persona = 999,
        @id_categoria = 2,
        @id_socio = @socio_id OUTPUT;
END TRY
BEGIN CATCH
    PRINT '[Error] [registrar_socio_sp]: ' + ERROR_MESSAGE();
END CATCH;

-- 5) INSERT ERROR: Socio duplicado
BEGIN TRY
    EXEC socios.registrar_socio_sp
        @id_persona = 1,
        @id_categoria = 2,
        @id_socio = @socio_id OUTPUT;
END TRY
BEGIN CATCH
    PRINT '[Error] [registrar_socio_sp]: ' + ERROR_MESSAGE();
END CATCH;

-- 6) INSERT ERROR: Categor a inválida
BEGIN TRY
    EXEC socios.registrar_socio_sp
        @id_persona = 1,
        @id_categoria = 999,
        @id_socio = @socio_id OUTPUT;
END TRY
BEGIN CATCH
    PRINT '[Error] [registrar_socio_sp]: ' + ERROR_MESSAGE();
END CATCH;

-- 7) UPDATE ERROR: Socio inexistente o inactivo
BEGIN TRY
    EXEC socios.actualizar_socio_sp
        @id_socio = 999,
        @id_categoria = 2;
END TRY
BEGIN CATCH
    PRINT '[Error] [actualizar_socio_sp]: ' + ERROR_MESSAGE();
END CATCH;

-- 8) UPDATE ERROR: Categor a inv lida
BEGIN TRY
    EXEC socios.actualizar_socio_sp
        @id_socio = @socio_id,
        @id_categoria = 999;
END TRY
BEGIN CATCH
    PRINT '[Error] [actualizar_socio_sp]: ' + ERROR_MESSAGE();
END CATCH;

-- 9) DELETE ERROR: Socio inexistente o ya desactivado
BEGIN TRY
    EXEC socios.eliminar_socio_sp @id_socio = 999;
END TRY
BEGIN CATCH
    PRINT '[Error] [eliminar_socio_sp]: ' + ERROR_MESSAGE();
END CATCH;
GO

/*
 ___                     _            _                              _       
|_ _|_ __  ___  ___ _ __(_)_ __   ___(_) ___  _ __    ___  ___   ___(_) ___  
 | || '_ \/ __|/ __| '__| | '_ \ / __| |/ _ \| '_ \  / __|/ _ \ / __| |/ _ \ 
 | || | | \__ \ (__| |  | | |_) | (__| | (_) | | | | \__ \ (_) | (__| | (_) |
|___|_| |_|___/\___|_|  |_| .__/ \___|_|\___/|_| |_| |___/\___/ \___|_|\___/ 
                          |_|                                                
*/
USE Com2900G05;
GO

DECLARE @id_persona INT, @id_socio INT;

-- CASOS EXITOSOS ----------------------------------------------------
-- 1) INSERT:
EXEC socios.inscripcion_socio_sp
    @nombre = 'Carla',
    @apellido = 'Domínguez',
    @dni = 31234567,
    @email = 'carla.dom@example.com',
    @fecha_de_nacimiento = '2000-05-15',
    @telefono = '011-2233-4455',
    @obra_social = 'OSDE',
    @nro_obra_social = 556677,
    @telefono_emergencia = '011-8877-6655',
    @id_persona = @id_persona OUTPUT,
    @id_socio = @id_socio OUTPUT;
PRINT '[Éxito] [inscripcion_socio_sp]: Persona registrada con ID = ' + CAST(@id_persona AS VARCHAR);
PRINT '[Éxito] [inscripcion_socio_sp]: Socio generado con ID = ' + CAST(@id_socio AS VARCHAR);

-- 2) UPDATE:
EXEC socios.actualizar_inscripcion_socio_sp
    @id_persona = @id_persona,
    @nombre = 'Carla Eugenia',
    @apellido = 'Domínguez Torres',
    @dni = 31234567,
    @email = 'carla.eugenia@example.com',
    @fecha_de_nacimiento = '2000-05-15',
    @telefono = '011-3344-5566',
    @obra_social = 'Swiss Medical',
    @nro_obra_social = 998877,
    @telefono_emergencia = '011-0000-1111';
PRINT '[Éxito] [actualizar_inscripcion_socio_sp]: Persona y socio actualizados correctamente.';

-- 3) DELETE:
EXEC socios.baja_inscripcion_socio_sp @id_persona = @id_persona;
PRINT '[Éxito] [baja_inscripcion_socio_sp]: Socio dado de baja correctamente.';

-- CASOS DE ERROR -----------------------------------------------------
-- 4) INSERT ERROR: inscripci n con DNI duplicado
BEGIN TRY
    EXEC socios.inscripcion_socio_sp
        @nombre = 'Carla',
        @apellido = 'Domínguez',
        @dni = 31234567,
        @fecha_de_nacimiento = '2000-05-15',
        @id_persona = @id_persona OUTPUT,
        @id_socio = @id_socio OUTPUT;
END TRY
BEGIN CATCH
    PRINT '[Error] [inscripcion_socio_sp]: ' + ERROR_MESSAGE();
END CATCH;

-- 5) UPDATE ERROR: persona inexistente
BEGIN TRY
    EXEC socios.actualizar_inscripcion_socio_sp
        @id_persona = 9999,
        @nombre = 'Inexistente',
        @apellido = 'Ejemplo',
        @dni = 11111111,
        @email = 'fake@example.com',
        @fecha_de_nacimiento = '1990-01-01',
        @telefono = '000-0000',
        @obra_social = 'Ninguna',
        @nro_obra_social = NULL,
        @telefono_emergencia = NULL;
END TRY
BEGIN CATCH
    PRINT '[Error] [actualizar_inscripcion_socio_sp]: ' + ERROR_MESSAGE();
END CATCH;

-- 6) DELETE ERROR: intentar dar de baja nuevamente (ya inactivo)
BEGIN TRY
    EXEC socios.baja_inscripcion_socio_sp @id_persona = @id_persona;
END TRY
BEGIN CATCH
    PRINT '[Error] [baja_inscripcion_socio_sp]: ' + ERROR_MESSAGE();
END CATCH;

-- 7) DELETE ERROR: baja de persona inexistente
BEGIN TRY
    EXEC socios.baja_inscripcion_socio_sp @id_persona = 9999;
END TRY
BEGIN CATCH
    PRINT '[Error] [baja_inscripcion_socio_sp]: ' + ERROR_MESSAGE();
END CATCH;
GO

/*
		 ___                     _            _                              _       
		|_ _|_ __  ___  ___ _ __(_)_ __   ___(_) ___  _ __    ___  ___   ___(_) ___  
		 | || '_ \/ __|/ __| '__| | '_ \ / __| |/ _ \| '_ \  / __|/ _ \ / __| |/ _ \ 
		 | || | | \__ \ (__| |  | | |_) | (__| | (_) | | | | \__ \ (_) | (__| | (_) |
		|___|_| |_|___/\___|_|  |_| .__/ \___|_|\___/|_| |_| |___/\___/ \___|_|\___/ 
		 _ __ ___   ___ _ __   ___|_| __                                             
		| '_ ` _ \ / _ \ '_ \ / _ \| '__|                                            
		| | | | | |  __/ | | | (_) | |                                               
		|_| |_| |_|\___|_| |_|\___/|_|                                               
*/
USE Com2900G05;
GO

DECLARE @id_persona_menor INT, @id_socio_menor INT, @id_persona_resp INT;
-- CASOS EXITOSOS ----------------------------------------------------
-- 1) INSERT:
EXEC socios.registrar_inscripcion_menor_sp
    @nombre_menor = 'Lucía',
    @apellido_menor = 'Sánchez',
    @dni_menor = 44111222,
    @email_menor = 'lucia.sanchez@example.com',
    @fecha_nac_menor = '2010-04-01',
    @telefono_menor = '011-9999-8888',
    @obra_social = 'Galeno',
    @nro_obra_social = 456789,
    @telefono_emergencia = '011-3344-5566',
    @nombre_resp = 'Mario',
    @apellido_resp = 'Sánchez',
    @dni_resp = 22333444,
    @email_resp = 'mario.sanchez@example.com',
    @fecha_nac_resp = '1980-05-01',
    @telefono_resp = '011-1234-5678',
    @parentesco = 'P',
    @id_persona_menor = @id_persona_menor OUTPUT,
    @id_socio_menor = @id_socio_menor OUTPUT,
    @id_persona_resp = @id_persona_resp OUTPUT;
PRINT '[Éxito] [registrar_inscripcion_menor_sp]: Menor registrado con ID = ' + CAST(@id_persona_menor AS VARCHAR);
PRINT '[Éxito] [registrar_inscripcion_menor_sp]: Socio menor generado con ID = ' + CAST(@id_socio_menor AS VARCHAR);
PRINT '[Éxito] [registrar_inscripcion_menor_sp]: Responsable registrado con ID = ' + CAST(@id_persona_resp AS VARCHAR);

-- 2) UPDATE:
EXEC socios.actualizar_inscripcion_menor_sp
    @id_persona_menor = @id_persona_menor,
    @nombre_menor = 'Lucía Fernanda',
    @apellido_menor = 'Sánchez Torres',
    @dni_menor = 44111222,
    @email_menor = 'lucia.ft@example.com',
    @fecha_nac_menor = '2010-04-01',
    @telefono_menor = '011-1111-2222',
    @obra_social = 'OSDE',
    @nro_obra_social = 777888,
    @telefono_emergencia = '011-2222-3333',
    @id_persona_resp = @id_persona_resp,
    @nombre_resp = 'Mario Alberto',
    @apellido_resp = 'Sánchez',
    @dni_resp = 22333444,
    @email_resp = 'mario.a.sanchez@example.com',
    @fecha_nac_resp = '1980-05-01',
    @telefono_resp = '011-5555-6666';
PRINT '[Éxito] [actualizar_inscripcion_menor_sp]: Datos de menor y responsable actualizados correctamente.';

-- 3) DELETE:
EXEC socios.baja_inscripcion_menor_sp @id_persona_menor = @id_persona_menor;
PRINT '[Éxito] [baja_inscripcion_menor_sp]: Baja lógica del socio menor realizada correctamente.';

-- CASOS DE ERROR -----------------------------------------------------
-- 4) INSERT ERROR: Menor no es menor
BEGIN TRY
    EXEC socios.registrar_inscripcion_menor_sp
        @nombre_menor = 'Pedro',
        @apellido_menor = 'González',
        @dni_menor = 40987654,
        @fecha_nac_menor = '1990-01-01',
        @nombre_resp = 'Laura',
        @apellido_resp = 'González',
        @dni_resp = 20123456,
        @fecha_nac_resp = '1960-01-01',
        @parentesco = 'P',
        @id_persona_menor = @id_persona_menor OUTPUT,
        @id_socio_menor = @id_socio_menor OUTPUT,
        @id_persona_resp = @id_persona_resp OUTPUT;
END TRY
BEGIN CATCH
    PRINT '[Error] [registrar_inscripcion_menor_sp]: ' + ERROR_MESSAGE();
END CATCH;

-- 5) UPDATE ERROR: Persona menor inexistente
BEGIN TRY
    EXEC socios.actualizar_inscripcion_menor_sp
        @id_persona_menor = 9999,
        @nombre_menor = 'Inexistente',
        @apellido_menor = 'Prueba',
        @dni_menor = 10000000,
        @email_menor = NULL,
        @fecha_nac_menor = '2011-01-01',
        @telefono_menor = NULL,
        @obra_social = NULL,
        @nro_obra_social = NULL,
        @telefono_emergencia = NULL,
        @id_persona_resp = 9998,
        @nombre_resp = 'Fake',
        @apellido_resp = 'Responsable',
        @dni_resp = 88888888,
        @email_resp = NULL,
        @fecha_nac_resp = '1980-01-01',
        @telefono_resp = NULL;
END TRY
BEGIN CATCH
    PRINT '[Error] [actualizar_inscripcion_menor_sp]: ' + ERROR_MESSAGE();
END CATCH;

-- 6) DELETE ERROR: socio menor ya dado de baja
BEGIN TRY
    EXEC socios.baja_inscripcion_menor_sp @id_persona_menor = @id_persona_menor;
END TRY
BEGIN CATCH
    PRINT '[Error] [baja_inscripcion_menor_sp]: ' + ERROR_MESSAGE();
END CATCH;

-- 7) DELETE ERROR: persona menor inexistente
BEGIN TRY
    EXEC socios.baja_inscripcion_menor_sp @id_persona_menor = 9999;
END TRY
BEGIN CATCH
    PRINT '[Error] [baja_inscripcion_menor_sp]: ' + ERROR_MESSAGE();
END CATCH;
GO

DECLARE @id_persona_menor INT, @id_socio_menor INT, @id_persona_resp INT;
-- 8) INSERT ERROR: Parensco inválido
BEGIN TRY
    EXEC socios.registrar_inscripcion_menor_sp
        @nombre_menor = 'Pedro',
        @apellido_menor = 'González',
        @dni_menor = 40987654,
        @fecha_nac_menor = '2018-01-01',
        @nombre_resp = 'Laura',
        @apellido_resp = 'González',
        @dni_resp = 20123456,
        @fecha_nac_resp = '1960-01-01',
        @parentesco = 'Y',
        @id_persona_menor = @id_persona_menor OUTPUT,
        @id_socio_menor = @id_socio_menor OUTPUT,
        @id_persona_resp = @id_persona_resp OUTPUT;
END TRY
BEGIN CATCH
    PRINT '[Error] [registrar_inscripcion_menor_sp]: ' + ERROR_MESSAGE();
END CATCH;


USE Com2900G05
GO

SELECT * FROM socios.Parentesco;

-- Lista parentescos
WITH Parientes AS (
    SELECT 
        Pa.id_persona AS IdMenor,
        Pa.id_persona_responsable AS IdResponsable
    FROM socios.Parentesco Pa
),
DatosMenor AS (
    SELECT 
        p.id_persona,
        s.id_socio AS IdSocioMenor,
        p.nombre AS NombreMenor,
        p.apellido AS ApellidoMenor
    FROM socios.Persona p
    JOIN socios.Socio s ON p.id_persona = s.id_persona
),
DatosResponsable AS (
    SELECT 
        p.id_persona,
        s.id_socio AS IdSocioResponsable,
        p.nombre AS NombreResponsable,
        p.apellido AS ApellidoResponsable
    FROM socios.Persona p
    JOIN socios.Socio s ON p.id_persona = s.id_persona
)
SELECT 
    dm.IdSocioMenor,
    dm.NombreMenor,
    dm.ApellidoMenor,
    dr.IdSocioResponsable,
    dr.NombreResponsable,
    dr.ApellidoResponsable
FROM Parientes p
JOIN DatosMenor dm ON p.IdMenor = dm.id_persona
JOIN DatosResponsable dr ON p.IdResponsable = dr.id_persona;

-- Lista nombre actividad, socio, nombre de socio y fecha de inscripcion
SELECT a.nombre, i.id_socio, p.nombre, i.fecha_inscripcion
FROM socios.InscripcionActividadDeportiva i
	JOIN socios.ActividadDeportiva a
		ON a.id_actividad_dep = i.id_actividad_dep
	JOIN socios.Socio s
		ON s.id_socio = i.id_socio
	JOIN socios.Persona p
		ON p.id_persona = s.id_persona
ORDER BY i.fecha_inscripcion, i.id_socio