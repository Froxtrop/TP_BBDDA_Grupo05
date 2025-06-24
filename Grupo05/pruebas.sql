USE Com2900G05;
GO

-- =============================================================
-- 1) ÉXITO: inscripcion_socio_sp (socio mayor)
-- =============================================================
BEGIN
    PRINT '1) ÉXITO: inscripcion_socio_sp (socio mayor)';
    EXEC socios.inscripcion_socio_sp
        @nombre              = 'María',
        @apellido            = 'López',
        @dni                 = 40111222,
        @email               = 'maria.lopez@mail.com',
        @fecha_de_nacimiento = '1980-05-20',
        @telefono            = '1111222233',
        @obra_social         = 'OSDE',
        @nro_obra_social     = 543210,
        @telefono_emergencia = '1199001122';
END
GO

-- Errores para inscripcion_socio_sp:
-- a) DNI duplicado
BEGIN
    PRINT '   ERROR a) DNI duplicado';
    EXEC socios.inscripcion_socio_sp
        @nombre              = 'Duplicado',
        @apellido            = 'DNI',
        @dni                 = 40111222,
        @fecha_de_nacimiento = '1990-01-01';
END
GO

-- b) Fecha de nacimiento futura
BEGIN
    PRINT '   ERROR b) Fecha futura';
    EXEC socios.inscripcion_socio_sp
        @nombre              = 'Futura',
        @apellido            = 'Persona',
        @dni                 = 45555666,
        @fecha_de_nacimiento = '2099-01-01';
END
GO

-- =============================================================
-- 2) ÉXITO: inscripcion_socio_menor_sp (menor + responsable)
-- =============================================================
BEGIN
    PRINT '2) ÉXITO: inscripcion_socio_menor_sp (menor + responsable)';
    EXEC socios.inscripcion_socio_menor_sp
        @nombre_menor        = 'Lucas',
        @apellido_menor      = 'García',
        @dni_menor           = 45222333,
        @email_menor         = 'lucas.garcia@mail.com',
        @fecha_nac_menor     = '2012-08-10',
        @telefono_menor      = '1122334455',
        @obra_social         = 'IOMA',
        @nro_obra_social     = 678901,
        @telefono_emergencia = '1177889900',
        @nombre_resp         = 'Ana',
        @apellido_resp       = 'García',
        @dni_resp            = 30111222,
        @email_resp          = 'ana.garcia@mail.com',
        @fecha_nac_resp      = '1975-03-15',
        @telefono_resp       = '1133445566',
        @parentesco          = 'M';
END
GO

-- Errores para inscripcion_socio_menor_sp:
-- a) Intentar inscribir un adulto como menor
BEGIN
    PRINT '   ERROR a) Adulto como menor';
    EXEC socios.inscripcion_socio_menor_sp
        @nombre_menor    = 'Adulto',
        @apellido_menor  = 'Falso',
        @dni_menor       = 47777888,
        @fecha_nac_menor = '1990-01-01',
        @nombre_resp     = 'Resp',
        @apellido_resp   = 'Test',
        @dni_resp        = 48888999,
        @fecha_nac_resp  = '1980-01-01',
        @parentesco      = 'P';
END
GO

-- b) Parentesco inválido
BEGIN
    PRINT '   ERROR b) Parentesco inválido';
    EXEC socios.inscripcion_socio_menor_sp
        @nombre_menor    = 'Valen',
        @apellido_menor  = 'Test',
        @dni_menor       = 49999000,
        @fecha_nac_menor = '2010-06-01',
        @nombre_resp     = 'Resp',
        @apellido_resp   = 'Test',
        @dni_resp        = 51111111,
        @fecha_nac_resp  = '1980-01-01',
        @parentesco      = 'X';
END
GO

-- =============================================================
-- 3) ÉXITO: registrar_socio_sp sobre persona existente
-- =============================================================
BEGIN
    PRINT '3) ÉXITO: registrar_socio_sp (persona existente)';
    DECLARE @id_p INT, @id_s INT, @edad INT, @cat SMALLINT;

    -- Primero crear persona de prueba
    EXEC socios.registrar_persona_sp
        @nombre              = 'Pedro',
        @apellido            = 'Pérez',
        @dni                 = 43333444,
        @email               = 'pedro.perez@mail.com',
        @fecha_de_nacimiento = '1990-02-28',
        @telefono            = '1144556677',
        @saldo               = 0,
        @id_persona          = @id_p OUTPUT;

    -- Calcular categoría
    SET @edad = DATEDIFF(YEAR, '1990-02-28', GETDATE());
    IF (MONTH('1990-02-28') > MONTH(GETDATE())
        OR (MONTH('1990-02-28') = MONTH(GETDATE())
            AND DAY('1990-02-28') > DAY(GETDATE())))
        SET @edad -= 1;
    SET @cat = socios.fn_obtener_categoria_por_edad(@edad);

    -- Inscribir como socio
    EXEC socios.registrar_socio_sp
        @id_persona          = @id_p,
        @id_categoria        = @cat,
        @obra_social         = 'Swiss Medical',
        @nro_obra_social     = 112233,
        @telefono_emergencia = '1199554433',
        @id_socio            = @id_s OUTPUT;
END
GO

-- Errores para registrar_socio_sp:
-- a) Persona inexistente
BEGIN
    PRINT '   ERROR a) registrar_socio_sp con persona inexistente';
    DECLARE @fake_s INT;
    EXEC socios.registrar_socio_sp
        @id_persona   = 999999,
        @id_categoria = 1,
        @id_socio     = @fake_s OUTPUT;
END
GO

-- b) Categoría inválida
BEGIN
    PRINT '   ERROR b) registrar_socio_sp con categoría inválida';
    EXEC socios.registrar_socio_sp
        @id_persona   = @id_p,
        @id_categoria = 999,
        @id_socio     = @fake_s OUTPUT;
END
GO

-- =============================================================
-- 4) ÉXITO: inscribir_socio_a_actividad_sp
-- =============================================================
BEGIN
    PRINT '4) ÉXITO: inscribir_socio_a_actividad_sp';
    -- Asegurarse que exista @id_s desde caso 3 y actividad 1
    EXEC socios.inscribir_socio_a_actividad_dep_sp
        @id_socio                = @id_s,
        @id_actividad_deportiva  = 1;
END
GO

-- Errores para inscribir_socio_a_actividad_sp:
-- a) Socio inexistente
BEGIN
    PRINT '   ERROR a) socio inexistente';
    EXEC socios.inscribir_socio_a_actividad_dep_sp
        @id_socio               = 999999,
        @id_actividad_deportiva = 1;
END
GO

-- b) Actividad inexistente
BEGIN
    PRINT '   ERROR b) actividad inexistente';
    EXEC socios.inscribir_socio_a_actividad_dep_sp
        @id_socio               = @id_s,
        @id_actividad_deportiva = 999999;
END
GO

-- c) Doble inscripción
BEGIN
    PRINT '   ERROR c) doble inscripción';
    EXEC socios.inscribir_socio_a_actividad_dep_sp
        @id_socio               = @id_s,
        @id_actividad_deportiva = 1;
END
GO
