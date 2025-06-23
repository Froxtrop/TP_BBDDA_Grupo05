SELECT * FROM socios.Categoria

USE Com2900G05
GO

SELECT * FROM socios.Persona P
JOIN socios.Socio S ON S.id_persona=P.id_persona
SELECT * FROM socios.Persona
SELECT * FROM socios.Parentesco

USE Com2900G05
GO
EXEC socios.inscripcion_socio_sp
    @nombre = 'Ana',
    @apellido = 'Sosa',
    @dni = 44555666,
    @email = 'ana.sosa@mail.com',
    @fecha_de_nacimiento = '1992-03-25',
    @telefono = '1122334455',
    @obra_social = 'OSDE',
    @nro_obra_social = 789456,
    @telefono_emergencia = '1166778899';

EXEC socios.inscripcion_socio_menor_sp
    @nombre_menor = 'Lucas',
    @apellido_menor = 'González',
    @dni_menor = 45444777,
    @email_menor = 'lucas.g@email.com',
    @fecha_nac_menor = '2012-05-10',
    @telefono_menor = '1122334455',
    @obra_social = 'IOMA',
    @nro_obra_social = 123456,
    @telefono_emergencia = '1144556677',
    @nombre_resp = 'Carla',
    @apellido_resp = 'Gómez',
    @dni_resp = 33444555,
    @email_resp = 'carla.g@email.com',
    @fecha_nac_resp = '1980-07-21',
    @telefono_resp = '1155667788',
    @parentesco = 'M';
