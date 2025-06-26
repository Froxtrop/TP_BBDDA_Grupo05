USE Com2900G05;
GO
/*		 ____  _____ ____  ____   ___  _   _    _    
		|  _ \| ____|  _ \/ ___| / _ \| \ | |  / \   
		| |_) |  _| | |_) \___ \| | | |  \| | / ^ \  
		|  __/| |___|  _ < ___) | |_| | |\  |/ ___ \ 
		|_|   |_____|_| \_\____/ \___/|_| \_/_/   \_\
*/

-- CASOS EXITOSOS ----------------------------------------------------
-- 1) INSERT: Registrar una nueva persona
DECLARE @nuevo_id INT;
EXEC socios.registrar_persona_sp
    @nombre = 'Juan',
    @apellido = 'Pérez',
    @dni = 12345678,
    @email = 'juan.perez@example.com',
    @fecha_de_nacimiento = '1985-04-20',
    @telefono = '011-1234-5678',
    @saldo = 0,
    @id_persona = @nuevo_id OUTPUT;
PRINT 'ID de persona insertada: ' + CAST(@nuevo_id AS VARCHAR(10));
SELECT * FROM socios.Persona WHERE id_persona = @nuevo_id;


-- 2) UPDATE: Modificar los datos de la persona recién creada
EXEC socios.actualizar_persona_sp
    @id_persona = @nuevo_id,
    @nombre = 'Juan Carlos',
    @apellido = 'Pérez Gómez',
    @dni = 12345678,
    @email = 'jc.perez@example.com',
    @fecha_de_nacimiento = '1985-04-20',
    @telefono = '011-8765-4321',
    @saldo = 50.00;
SELECT * FROM socios.Persona WHERE id_persona = @nuevo_id;

-- 3) DELETE: Intentar eliminar la persona (debe fallar)
BEGIN TRY
    EXEC socios.eliminar_persona_sp @id_persona = @nuevo_id;
END TRY
BEGIN CATCH
    PRINT 'Error al eliminar: ' + ERROR_MESSAGE();
END CATCH;
SELECT * FROM socios.Persona WHERE id_persona = @nuevo_id;

-- CASOS DE ERROR -----------------------------------------------------
-- 4) INSERT ERROR: DNI duplicado
DECLARE @dup_id INT;
BEGIN TRY
    EXEC socios.registrar_persona_sp
        @nombre = 'Ana',
        @apellido = 'Gómez',
        @dni = 12345678,  -- DNI ya usado por Juan
        @email = 'ana.gomez@example.com',
        @fecha_de_nacimiento = '1990-01-15',
        @telefono = '011-2222-3333',
        @saldo = 10,
        @id_persona = @dup_id OUTPUT;
END TRY
BEGIN CATCH
    PRINT 'Error en inserción duplicada: ' + ERROR_MESSAGE();
END CATCH;

-- 5) INSERT ERROR: Fecha futura
BEGIN TRY
    EXEC socios.registrar_persona_sp
        @nombre = 'Mario',
        @apellido = 'Rossi',
        @dni = 87654321,
        @email = 'mario.rossi@example.com',
        @fecha_de_nacimiento = '2100-01-01',  -- Fecha futura
        @telefono = '011-4444-5555',
        @saldo = 0,
        @id_persona = @dup_id OUTPUT;
END TRY
BEGIN CATCH
    PRINT 'Error en inserción fecha futura: ' + ERROR_MESSAGE();
END CATCH;

-- 6) INSERT ERROR: Email inválido
BEGIN TRY
    EXEC socios.registrar_persona_sp
        @nombre = 'Lucía',
        @apellido = 'López',
        @dni = 33445566,
        @email = 'lucia.lopez',  -- Email sin @
        @fecha_de_nacimiento = '1992-07-10',
        @telefono = '011-6666-7777',
        @saldo = 0,
        @id_persona = @dup_id OUTPUT;
END TRY
BEGIN CATCH
    PRINT 'Error en inserción email inválido: ' + ERROR_MESSAGE();
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
        @saldo = -100,  -- Saldo negativo
        @id_persona = @dup_id OUTPUT;
END TRY
BEGIN CATCH
    PRINT 'Error en inserción saldo negativo: ' + ERROR_MESSAGE();
END CATCH;

-- 8) UPDATE ERROR: Persona inexistente
BEGIN TRY
    EXEC socios.actualizar_persona_sp
        @id_persona = 99999,  -- ID que no existe
        @nombre = 'Prueba',
        @apellido = 'NoExiste',
        @dni = 11223344,
        @email = 'no@existe.com',
        @fecha_de_nacimiento = '1990-01-01',
        @telefono = '011-0000-0000',
        @saldo = 0;
END TRY
BEGIN CATCH
    PRINT 'Error en actualización persona inexistente: ' + ERROR_MESSAGE();
END CATCH;

-- 9) UPDATE ERROR: DNI duplicado al actualizar
BEGIN TRY
    -- Suponemos que existe otra persona con dni 87654321
    EXEC socios.actualizar_persona_sp
        @id_persona = @nuevo_id,
        @nombre = 'Juan',
        @apellido = 'Pérez',
        @dni = 87654321,  -- DNI duplicado
        @email = 'juan.dup@example.com',
        @fecha_de_nacimiento = '1985-04-20',
        @telefono = '011-1234-5678',
        @saldo = 0;
END TRY
BEGIN CATCH
    PRINT 'Error en actualización DNI duplicado: ' + ERROR_MESSAGE();
END CATCH;

-- 10) UPDATE ERROR: Fecha futura
BEGIN TRY
    EXEC socios.actualizar_persona_sp
        @id_persona = @nuevo_id,
        @nombre = 'Juan',
        @apellido = 'Pérez',
        @dni = 12345678,
        @email = 'juan@example.com',
        @fecha_de_nacimiento = '2100-01-01',  -- Fecha futura
        @telefono = '011-1234-5678',
        @saldo = 0;
END TRY
BEGIN CATCH
    PRINT 'Error en actualización fecha futura: ' + ERROR_MESSAGE();
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
        @saldo = -50;  -- Saldo negativo
END TRY
BEGIN CATCH
    PRINT 'Error en actualización saldo negativo: ' + ERROR_MESSAGE();
END CATCH;

GO

/*				 ____   ___   ____ ___ ___  
				/ ___| / _ \ / ___|_ _/ _ \ 
				\___ \| | | | |    | | | | |
				 ___) | |_| | |___ | | |_| |
				|____/ \___/ \____|___\___/ 
*/

DECLARE @socio_id INT;
-- CASOS EXITOSOS ----------------------------------------------------
-- 1) INSERT: Registrar nuevo socio
EXEC socios.registrar_socio_sp
    @id_persona = 1,
    @id_categoria = 2,
    @obra_social = 'OSDE',
    @nro_obra_social = 123456,
    @telefono_emergencia = '011-9999-0000',
    @id_socio = @socio_id OUTPUT;
PRINT 'ID de socio insertado: ' + CAST(@socio_id AS VARCHAR(10));
SELECT * FROM socios.Socio WHERE id_socio = @socio_id;

-- 2) UPDATE: Modificar datos del socio
EXEC socios.actualizar_socio_sp
    @id_socio = @socio_id,
    @id_categoria = 3,
    @obra_social = 'Swiss Medical',
    @nro_obra_social = 654321,
    @telefono_emergencia = '011-1111-2222';
SELECT * FROM socios.Socio WHERE id_socio = @socio_id;

-- 3) DELETE: Desactivar socio
EXEC socios.eliminar_socio_sp @id_socio = @socio_id;
SELECT * FROM socios.Socio WHERE id_socio = @socio_id;

-- CASOS DE ERROR -----------------------------------------------------
BEGIN TRY
    -- 4) INSERT ERROR: Persona no existe
    EXEC socios.registrar_socio_sp
        @id_persona = 999,
        @id_categoria = 2,
        @id_socio = @socio_id OUTPUT;
END TRY
BEGIN CATCH
    PRINT 'Error inserción socio persona no existe: ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    -- 5) INSERT ERROR: Socio duplicado
    EXEC socios.registrar_socio_sp
        @id_persona = 1,
        @id_categoria = 2,
        @id_socio = @socio_id OUTPUT;
END TRY
BEGIN CATCH
    PRINT 'Error inserción socio duplicado: ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    -- 6) INSERT ERROR: Categoría inválida
    EXEC socios.registrar_socio_sp
        @id_persona = 1,
        @id_categoria = 999,
        @id_socio = @socio_id OUTPUT;
END TRY
BEGIN CATCH
    PRINT 'Error inserción categoría inválida: ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    -- 7) UPDATE ERROR: Socio inexistente o inactivo
    EXEC socios.actualizar_socio_sp
        @id_socio = 999,
        @id_categoria = 2;
END TRY
BEGIN CATCH
    PRINT 'Error actualización socio no existe/inactivo: ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    -- 8) UPDATE ERROR: Categoría inválida
    EXEC socios.actualizar_socio_sp
        @id_socio = @socio_id,
        @id_categoria = 999;
END TRY
BEGIN CATCH
    PRINT 'Error actualización categoría inválida: ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    -- 9) DELETE ERROR: Socio inexistente o ya desactivado
    EXEC socios.eliminar_socio_sp @id_socio = 999;
END TRY
BEGIN CATCH
    PRINT 'Error eliminación socio no existe/desactivado: ' + ERROR_MESSAGE();
END CATCH;

