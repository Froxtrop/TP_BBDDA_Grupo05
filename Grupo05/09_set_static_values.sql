/***********************************************************************
 * Enunciado: Inserción de datos iniciales.
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
		  ____    _  _____ _____ ____  ___  ____  ___    _    
		 / ___|  / \|_   _| ____/ ___|/ _ \|  _ \|_ _|  / \   
		| |     / _ \ | | |  _|| |  _| | | | |_) || |  / _ \  
		| |___ / ___ \| | | |__| |_| | |_| |  _ < | | / ___ \ 
		 \____/_/   \_\_| |_____\____|\___/|_| \_\___/_/   \_\
*/

-- Carga de datos en la tabla categoría
IF NOT EXISTS (
	SELECT 1 FROM socios.Categoria
		WHERE id_categoria BETWEEN 1 AND 3
)
BEGIN
	SET IDENTITY_INSERT socios.Categoria ON;
	INSERT INTO socios.Categoria (id_categoria, nombre, edad_min, edad_max)
	VALUES (1, 'Menor', 0, 12),
		   (2, 'Cadete', 13, 17),
		   (3, 'Mayor', 18, NULL);
	SET IDENTITY_INSERT socios.Categoria OFF;
END
SELECT * FROM socios.Categoria

-- Carga de datos en la tabla tarifa categoría
IF NOT EXISTS (
	SELECT 1 FROM socios.TarifaCategoria
		WHERE id_tarifa_categoria BETWEEN 1 AND 3
)
BEGIN
	SET IDENTITY_INSERT socios.TarifaCategoria ON;
	INSERT INTO socios.TarifaCategoria (id_tarifa_categoria, valor, vigencia_desde, vigencia_hasta, id_categoria)
	VALUES(1, 10000, '2025-01-01', '2025-05-31', 1),
		  (2, 15000, '2025-01-01', '2025-05-31', 2),
		  (3, 25000, '2025-01-01', '2025-05-31', 3)
	SET IDENTITY_INSERT socios.TarifaCategoria OFF;
END
SELECT * FROM socios.TarifaCategoria


-- Carga de datos en la tabla actividad deportiva
IF NOT EXISTS (
	SELECT 1 FROM socios.ActividadDeportiva
		WHERE id_actividad_dep BETWEEN 1 AND 6
)
BEGIN
	SET IDENTITY_INSERT socios.ActividadDeportiva ON;
	INSERT INTO socios.ActividadDeportiva(id_actividad_dep, nombre)
	VALUES (1,'Futsal'),(2,'Vóley'),(3,'Taekwondo'),(4,'Baile artístico'),(5,'Natación'),(6,'Ajedrez')
	SET IDENTITY_INSERT socios.ActividadDeportiva OFF;
END
SELECT * FROM socios.ActividadDeportiva


-- Carga de datos en la tabla tarifa actividad deportiva
IF NOT EXISTS (
	SELECT 1 FROM socios.TarifaActividadDeportiva
		WHERE id_tarifa_dep BETWEEN 1 AND 6
)
BEGIN
	SET IDENTITY_INSERT socios.TarifaActividadDeportiva ON;
	INSERT INTO socios.TarifaActividadDeportiva(id_tarifa_dep, id_actividad_dep, vigente_desde, vigente_hasta, valor)
	VALUES (1, 1, '2025-01-01', '2025-05-31', 25000),
	(2, 2, '2025-01-01', '2025-05-31', 30000),
	(3, 3, '2025-01-01', '2025-05-31', 25000),
	(4, 4, '2025-01-01', '2025-05-31', 30000),
	(5, 5, '2025-01-01', '2025-05-31', 45000),
	(6, 6, '2025-01-01', '2025-05-31', 2000)
	SET IDENTITY_INSERT socios.TarifaActividadDeportiva OFF;
END
SELECT * FROM socios.TarifaActividadDeportiva


-- Carga de datos en la tabla actividad recreativa
IF NOT EXISTS (
	SELECT 1 FROM socios.ActividadRecreativa
		WHERE id_actividad_rec BETWEEN 1 AND 3
)
BEGIN
	SET IDENTITY_INSERT socios.ActividadRecreativa ON;
	INSERT INTO socios.ActividadRecreativa(id_actividad_rec, nombre)
	VALUES (1, 'Sum'),(2, 'Pileta'),(3, 'Colonia de verano')
	SET IDENTITY_INSERT socios.ActividadRecreativa OFF;
END
SELECT * FROM socios.ActividadRecreativa


-- Carga de tarifas en socios.TarifaActividadRecreativa
IF NOT EXISTS (
	SELECT 1 FROM socios.TarifaActividadRecreativa
		WHERE id_tarifa_rec BETWEEN 1 AND 20
)
BEGIN
	SET IDENTITY_INSERT socios.TarifaActividadRecreativa ON;
	INSERT INTO socios.TarifaActividadRecreativa (id_tarifa_rec, id_actividad_rec, vigente_desde, vigente_hasta, valor, modalidad, edad_maxima, invitado)
	VALUES
	-- Precios de Sum (id_actividad_rec 1) por Adultos, Menores, siendo socios, por día, mes y temporada
	-- Valor del día
	(1, 1, '2025-01-01', '2025-02-28', 25000.00, 'Día', NULL, 0),         -- Socios Adultos
	(2, 1, '2025-01-01', '2025-02-28', 15000.00, 'Día', 11, 0),           -- Socios Menores

	-- Valor de temporada
	(3, 1, '2025-01-01', '2025-02-28', 2000000.00, 'Temporada', NULL, 0), -- Socios Adultos
	(4, 1, '2025-01-01', '2025-02-28', 1200000.00, 'Temporada', 11, 0),   -- Socios Menores

	-- Valor del mes
	(5, 1, '2025-01-01', '2025-02-28', 625000.00, 'Mes', NULL, 0),        -- Socios Adultos
	(6, 1, '2025-01-01', '2025-02-28', 375000.00, 'Mes', 11, 0);          -- Socios Menores


	-- Precios de Pileta (id_actividad_rec 2) por Adultos, Menores, siendo socios o invitados, por día, mes y temporada
	INSERT INTO socios.TarifaActividadRecreativa (id_tarifa_rec, id_actividad_rec, vigente_desde, vigente_hasta, valor, modalidad, edad_maxima, invitado)
	VALUES
	-- Valor del día
	(7, 2, '2025-01-01', '2025-02-28', 25000, 'Día', NULL, 0),           -- Socio adulto
	(8, 2, '2025-01-01', '2025-02-28', 15000, 'Día', 11, 0),             -- Socio menor
	(9, 2, '2025-01-01', '2025-02-28', 30000, 'Día', NULL, 1),           -- Invitado adulto - Solo la pileta tiene invitados
	(10, 2, '2025-01-01', '2025-02-28',  2000, 'Día', 11, 1),            -- Invitado menor

	-- Valor de temporada
	(11, 2, '2025-01-01', '2025-02-28', 2000000, 'Temporada', NULL, 0),   -- Socio adulto
	(12, 2, '2025-01-01', '2025-02-28', 1200000, 'Temporada', 11, 0),     -- Socio menor

	-- Valor del mes
	(13, 2, '2025-01-01', '2025-02-28', 625000, 'Mes', NULL, 0),          -- Socio adulto
	(14, 2, '2025-01-01', '2025-02-28', 375000, 'Mes', 11, 0);            -- Socio menor


	-- Precios de Colonia de verano (id_actividad_rec 3) por Adultos, Menores, siendo socios, por día, mes y temporada
	INSERT INTO socios.TarifaActividadRecreativa (id_tarifa_rec, id_actividad_rec, vigente_desde, vigente_hasta, valor, modalidad, edad_maxima, invitado)
	VALUES
	-- Valor del día
	(15, 3, '2025-01-01', '2025-02-28', 25000, 'Día', NULL, 0),				-- Socio adulto
	(16, 3, '2025-01-01', '2025-02-28', 15000, 'Día', 11, 0),				-- Socio menor

	-- Valor de temporada
	(17, 3, '2025-01-01', '2025-02-28', 2000000, 'Temporada', NULL, 0),		-- Socio adulto
	(18, 3, '2025-01-01', '2025-02-28', 1200000, 'Temporada', 11, 0),		-- Socio menor

	-- Valor del mes
	(19, 3, '2025-01-01', '2025-02-28', 625000, 'Mes', NULL, 0),			-- Socio adulto
	(20, 3, '2025-01-01', '2025-02-28', 375000, 'Mes', 11, 0);				-- Socio menor
	SET IDENTITY_INSERT socios.TarifaActividadRecreativa OFF;
END
SELECT * FROM socios.TarifaActividadRecreativa


-- Carga de MedioDePago
IF NOT EXISTS (
	SELECT 1 FROM socios.MedioDePago
		WHERE id_medio_de_pago BETWEEN 1 AND 6
)
BEGIN
	SET IDENTITY_INSERT socios.MedioDePago ON;
	INSERT INTO socios.MedioDePago
	(id_medio_de_pago, nombre)
	VALUES
	(1, 'Visa'),
	(2, 'MasterCard'),
	(3, 'Tarjeta Naranja'),
	(4, 'Pago Fácil'),
	(5, 'Rapipago'),
	(6, 'Transferencia Mercado Pago');
	SET IDENTITY_INSERT socios.MedioDePago OFF;
END
SELECT * FROM socios.MedioDePago
