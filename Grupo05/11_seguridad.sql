
-- 1. Crear SCHEMAS
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Tesoreria')
    EXEC('CREATE SCHEMA Tesoreria');
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Socio')
    EXEC('CREATE SCHEMA Socio');
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Autoridades')
    EXEC('CREATE SCHEMA Autoridades');

-- 2. Crear ROLES si no existen
-- Tesorería
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'JefeTesoreria')
    CREATE ROLE JefeTesoreria;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'AdministrativoCobranza')
    CREATE ROLE AdministrativoCobranza;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'AdministrativoMorosidad')
    CREATE ROLE AdministrativoMorosidad;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'AdministrativoFacturacion')
    CREATE ROLE AdministrativoFacturacion;

-- Socios
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'AdministrativoSocio')
    CREATE ROLE AdministrativoSocio;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'SociosWeb')
    CREATE ROLE SociosWeb;

-- Autoridades
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Presidente')
    CREATE ROLE Presidente;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Vicepresidente')
    CREATE ROLE Vicepresidente;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Secretario')
    CREATE ROLE Secretario;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Vocales')
    CREATE ROLE Vocales;

-- 3. Asignar permisos a los SCHEMAS
-- Tesorería: todos los roles de Tesorería
GRANT CONTROL ON SCHEMA::Tesoreria TO JefeTesoreria;
GRANT CONTROL ON SCHEMA::Tesoreria TO AdministrativoCobranza;
GRANT CONTROL ON SCHEMA::Tesoreria TO AdministrativoMorosidad;
GRANT CONTROL ON SCHEMA::Tesoreria TO AdministrativoFacturacion;

-- Socios: roles de Socios
GRANT CONTROL ON SCHEMA::Socio TO AdministrativoSocio;
GRANT CONTROL ON SCHEMA::Socio TO SociosWeb;

-- Autoridades: roles de Autoridades
GRANT CONTROL ON SCHEMA::Autoridades TO Presidente;
GRANT CONTROL ON SCHEMA::Autoridades TO Vicepresidente;
GRANT CONTROL ON SCHEMA::Autoridades TO Secretario;
GRANT CONTROL ON SCHEMA::Autoridades TO Vocales;
