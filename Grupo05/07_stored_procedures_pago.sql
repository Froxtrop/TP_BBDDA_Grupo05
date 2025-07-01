/***********************************************************************
 * Enunciado: Cree la base de datos, entidades y relaciones. Incluya
 *		restricciones y claves. Deberá entregar un archivo .sql con 
 *		el script completo de creación (debe funcionar si se lo ejecuta
 *		“tal cual” es entregado en una sola ejecución).
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
USE Com2900G05;
GO

/*
  ____                   
 |  _ \ __ _  __ _  ___  
 | |_) / _` |/ _` |/ _ \ 
 |  __/ (_| | (_| | (_) |
 |_|   \__,_|\__, |\___/ 
             |___/       
*/

/***********************************************************************
Nombre del procedimiento: pagar_factura_sp
Descripción: Se pasa a paga la factura pasada por parámetro.
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE socios.pagar_factura_sp
    @id_factura INT,
	@id_medio INT,
	@codigo_de_referencia VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	-- Validamos si la factura existe
	IF NOT EXISTS (SELECT 1 FROM socios.Factura WHERE id_factura = @id_factura)
	BEGIN
        RAISERROR('La factura proporcionada no existe.', 16, 1);
        RETURN;
    END
	-- Validamos el medio de pago utilizado
	IF NOT EXISTS (SELECT 1 FROM socios.MedioDePago WHERE id_medio = @id_medio)
	BEGIN
        RAISERROR('El medio de pago proporcionada no existe.', 16, 1);
        RETURN;
    END

	-- Obtenemos el monto de la factura
	DECLARE @monto DECIMAL(10,2);
	SELECT @monto = total_neto FROM socios.Factura WHERE id_factura = @id_factura;
	
	BEGIN TRANSACTION Tran1
	BEGIN TRY
		DECLARE @id_pago INT;
		-- Insertamos en la tabla de Pago con los datos proporcionados
		INSERT INTO socios.Pago (id_medio, fecha_pago, codigo_de_referencia, monto)
			VALUES (@id_medio, GETDATE(), @codigo_de_referencia, @monto);

		SET @id_pago = SCOPE_IDENTITY();
		-- Asociamos el pago a la factura
		INSERT INTO socios.DetalleDePago(id_factura, id_pago)
			VALUES (@id_factura, @id_pago);

		COMMIT TRANSACTION Tran1
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION Tran1

		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH
END
GO

/***********************************************************************
Nombre del procedimiento: genarar_nota_de_credito_sp
Descripción: Se hace una nota de crédito a una factura.
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE socios.genarar_nota_de_credito_sp
    @id_detalle_de_pago INT,
	@cuit VARCHAR(20),
	@razon_social VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
	-- Validamos si la factura existe
	IF NOT EXISTS (SELECT 1 FROM socios.DetalleDePago WHERE id_detalle_de_pago = @id_detalle_de_pago)
	BEGIN
        RAISERROR('El detalle de pago proporcionado no existe.', 16, 1);
        RETURN;
    END
	-- Validamos cuit
	IF @cuit IS NULL
	BEGIN
        RAISERROR('El cuit no puede ser nulo.', 16, 1);
        RETURN;
    END

	INSERT INTO socios.NotaDeCredito(id_detalle_de_pago, cuit, razon_social)
		VALUES (@id_detalle_de_pago, @cuit, @razon_social);
END
GO

/***********************************************************************
Nombre del procedimiento: genarar_pago_a_cuenta_sp
Descripción: Generación de un pago a cuenta.
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE socios.genarar_pago_a_cuenta_sp
    @id_detalle_de_pago INT,
	@motivo VARCHAR(100),
	@monto DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
	-- Validamos si el detalle de pago existe
	IF NOT EXISTS (SELECT 1 FROM socios.DetalleDePago WHERE id_detalle_de_pago = @id_detalle_de_pago)
	BEGIN
        RAISERROR('El detalle de pago proporcionado no existe.', 16, 1);
        RETURN;
    END
	-- Validamos motivo
	IF @motivo IS NULL
	BEGIN
        RAISERROR('El motivo no puede ser nulo.', 16, 1);
        RETURN;
    END
	-- Validamos monto
	IF @monto IS NULL OR @monto <= 0
	BEGIN
        RAISERROR('El monto debe ser positivo.', 16, 1);
        RETURN;
    END

	-- Buscamos el responsable del pago
	DECLARE @id_persona INT;

	SELECT @id_persona = fr.id_persona 
	FROM socios.DetalleDePago ddp
	INNER JOIN socios.Factura f ON ddp.id_factura = f.id_factura
	INNER JOIN socios.FacturaResponsable fr ON fr.id_factura = f.id_factura
		WHERE ddp.id_detalle_de_pago = @id_detalle_de_pago;

	BEGIN TRANSACTION Tran1;
    BEGIN TRY

	-- Insertamos el registro de pago a cuenta
	INSERT INTO socios.PagoACuenta(id_persona, id_detalle_de_pago, fecha, motivo, monto)
		VALUES (@id_persona, @id_detalle_de_pago, GETDATE(), @motivo, @monto);

	-- Le agregamos al saldo del socio el monto del pago a cuenta
	UPDATE socios.Persona SET saldo = saldo + @monto
		WHERE id_persona = @id_persona;

	COMMIT TRANSACTION Tran1;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION Tran1;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH
END
GO
/***********************************************************************
Nombre del procedimiento: socios.registrar_morosos_sp
Descripción: Identifica las facturas de SOCIOS con una antigüedad mayor
    a 6 días que no tengan un pago asociado y las inserta en la tabla 
    de Morosidad. Este proceso excluye explícitamente las facturas 
    generadas por invitados, ya que su pago es inmediato.
    El procedimiento evita duplicar registros si ya fueron procesados.
Autor: Grupo 05 - Com2900
***********************************************************************/
CREATE OR ALTER PROCEDURE socios.registrar_morosos_sp
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;
    BEGIN TRY

        -- CTE para encontrar el id_socio asociado a cada factura de socio.
        -- Se excluyen las facturas de invitados.
        WITH FacturaSocioLink AS (
            -- Vínculo a través de la membresía (incluye cuota y actividades deportivas)
            SELECT 
                m.id_factura, 
                m.id_socio
            FROM socios.Membresia m

            UNION -- Usamos UNION para combinar y eliminar duplicados

            -- Vínculo a través de actividades recreativas del propio socio
            SELECT 
                dr.id_factura, 
                iar.id_socio
            FROM socios.DetalleRecreativa dr
            INNER JOIN socios.InscripcionActividadRecreativa iar ON dr.id_inscripcion_rec = iar.id_inscripcion_rec
        )
        -- Insertamos en la tabla Morosidad los registros que cumplen las condiciones
        INSERT INTO socios.Morosidad (id_factura, id_socio, monto)
        SELECT
            f.id_factura,
            link.id_socio,
            f.total_neto
        FROM socios.Factura f
        -- Nos unimos a nuestro CTE para encontrar el socio que generó la deuda
        INNER JOIN FacturaSocioLink link ON f.id_factura = link.id_factura
        WHERE
            -- Condición 1: Han pasado más de 10 días desde la emisión de la factura.
            DATEDIFF(DAY, f.fecha_emision, GETDATE()) > 10
            -- Condición 2: La factura NO tiene un pago asociado.
            AND NOT EXISTS (
                SELECT 1 
                FROM socios.DetalleDePago ddp 
                WHERE ddp.id_factura = f.id_factura
            )
            -- Condición 3 (Idempotencia): La factura NO ha sido registrada como morosa previamente.
            AND NOT EXISTS (
                SELECT 1 
                FROM socios.Morosidad m 
                WHERE m.id_factura = f.id_factura
            );

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        -- Si ocurre un error, revertimos la transacción para no dejar datos a medio cargar.
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Mostramos el error original para facilitar la depuración.
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO
