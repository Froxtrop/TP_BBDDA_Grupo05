USE Com2900G05;
GO

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

