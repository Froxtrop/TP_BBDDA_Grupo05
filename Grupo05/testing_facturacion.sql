/***********************************************************************
 * Enunciado: Testing Entrega 4.
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

/* Archivo de testing para probar facturacion */

-- Usamos la base de datos del proyecto
USE Com2900G05
GO

SELECT * FROM socios.Socio s
INNER JOIN socios.TarifaCategoria tc ON tc.id_categoria = s.id_categoria
	WHERE id_socio = 1

-- Si se necesita insertar datos de prueba con fechas actuales ejecutar
INSERT INTO socios.TarifaCategoria (valor, vigencia_desde, vigencia_hasta, id_categoria)
VALUES (30000, '2025-05-31', '2025-12-31', 3),
	   (20000, '2025-05-31', '2025-12-31', 2),
	   (15000, '2025-05-31', '2025-12-31', 1);
/*
SELECT * FROM socios.TarifaCategoria tc 
INNER JOIN socios.Categoria c ON c.id_categoria = tc.id_categoria
*/
/*
SELECT * FROM socios.TarifaActividadDeportiva tad 
INNER JOIN socios.ActividadDeportiva ad ON ad.id_actividad_dep = tad.id_actividad_dep
*/
-- Si se necesita insertar un grupo familiar actualizar datos y ejecutar
INSERT INTO socios.Parentesco (
    id_persona_responsable,
    id_persona,
    parentesco,
    fecha_desde,
    fecha_hasta
)
VALUES (
    2,              -- ID del socio
    1,              -- ID de la persona relacionada
    'P',      -- Tipo de parentesco
    GETDATE(),      -- Fecha de alta (actual)
    GETDATE() +364              -- Activo
);

/* Prueba de facturacion_membresia_socio_sp */
-- Se hara de cuenta que ya se poseen datos
-- Reemplazar @id_socio con el socio a probar
-- Seleccionar de acá
DECLARE @id_socio INT = 1;
EXEC socios.facturacion_membresia_socio_sp @id_socio;
-- Hasta acá y ejecutar

-- Revisamos las tablas afectadas
SELECT * FROM socios.DetalleDeportiva
SELECT * FROM socios.Membresia
SELECT * FROM socios.Factura
SELECT * FROM socios.FacturaResponsable
--SELECT * FROM socios.InscripcionActividadDeportiva

/* Prueba de actualizar_datos_factura_sp */
DECLARE @id_factura INT = 10, @numero_factura INT = 19220381
EXEC socios.actualizar_datos_factura_sp @id_factura, @numero_factura;

--SELECT * FROM socios.InscripcionActividadRecreativa

/* Preuba generar factura recreativa socio */
DECLARE @id_socio INT = 1;
EXEC socios.generar_factura_recreativa_sp @id_socio
-- SELECT * FROM socios.DetalleRecreativa

/* Pago factura */
EXEC socios.pagar_factura_sp
3, -- id_factura
1, -- id_medio_de_pago
10238231 -- codigo de referencia

SELECT * FROM socios.Pago
SELECT * FROM socios.DetalleDePago

/* Pago a cuenta */
EXEC socios.genarar_pago_a_cuenta_sp
1, -- id_detalle_de_pago
'Devolucion por lluvia', -- motivo
1500 -- monto

SELECT * FROM socios.PagoACuenta
SELECT * FROM socios.Persona


