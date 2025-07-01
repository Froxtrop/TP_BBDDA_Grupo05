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
INSERT INTO socios.Categoria (nombre, edad_min, edad_max)
VALUES ('Menor', 0, 12),
       ('Cadete', 13, 17),
       ('Mayor', 18, NULL);
SELECT * FROM socios.Categoria

-- Carga de datos en la tabla tarifa categoría
INSERT INTO socios.TarifaCategoria (valor, vigencia_desde, vigencia_hasta, id_categoria)
VALUES (25000, '2025-01-01', '2025-05-31', 3),
	   (15000, '2025-01-01', '2025-05-31', 2),
	   (10000, '2025-01-01', '2025-05-31', 1)
SELECT * FROM socios.TarifaCategoria

-- Carga de datos en la tabla actividad deportiva
INSERT INTO socios.ActividadDeportiva(nombre)
VALUES ('Futsal'),('Vóley'),('Taekwondo'),('Baile artístico'),('Natación'),('Ajedrez')
SELECT * FROM socios.ActividadDeportiva

-- Carga de datos en la tabla tarifa actividad deportiva
INSERT INTO socios.TarifaActividadDeportiva(id_actividad_dep, vigente_desde, vigente_hasta, valor)
VALUES (1, '2025-01-01', '2025-05-31', 25000),
(2, '2025-01-01', '2025-05-31', 30000),
(3, '2025-01-01', '2025-05-31', 25000),
(4, '2025-01-01', '2025-05-31', 30000),
(5, '2025-01-01', '2025-05-31', 45000),
(6, '2025-01-01', '2025-05-31', 2000)
SELECT * FROM socios.TarifaActividadDeportiva

-- Carga de datos en la tabla actividad recreativa
INSERT INTO socios.ActividadRecreativa(nombre)
VALUES ('Sum'),('Pileta'),('Colonia de verano')
SELECT * FROM socios.ActividadRecreativa

-- Carga de tarifas en socios.TarifaActividadRecreativa
INSERT INTO socios.TarifaActividadRecreativa
(id_actividad_rec, vigente_desde, vigente_hasta, valor, modalidad, edad_maxima, invitado)
VALUES
-- Precios de Sum (id_actividad_rec 1) por Adultos, Menores, siendo socios o invitados, por día, mes y temporada
-- Valor del día
(1, '2025-01-01', '2025-02-28', 25000.00, 'Día', NULL, 0),         -- Socios Adultos
(1, '2025-01-01', '2025-02-28', 15000.00, 'Día', 12, 0),           -- Socios Menores
(1, '2025-01-01', '2025-02-28', 30000.00, 'Día', NULL, 1),         -- Invitados Adultos
(1, '2025-01-01', '2025-02-28', 2000.00,  'Día', 12, 1),           -- Invitados Menores

-- Valor de temporada
(1, '2025-01-01', '2025-02-28', 2000000.00, 'Temporada', NULL, 0), -- Socios Adultos
(1, '2025-01-01', '2025-02-28', 1200000.00, 'Temporada', 12, 0),   -- Socios Menores

-- Valor del mes
(1, '2025-01-01', '2025-02-28', 625000.00, 'Mes', NULL, 0),        -- Socios Adultos
(1, '2025-01-01', '2025-02-28', 375000.00, 'Mes', 12, 0);          -- Socios Menores


-- Precios de Pileta (id_actividad_rec 2) por Adultos, Menores, siendo socios o invitados, por día, mes y temporada
INSERT INTO socios.TarifaActividadRecreativa
(id_actividad_rec, vigente_desde, vigente_hasta, valor, modalidad, edad_maxima, invitado)
VALUES
-- Valor del día
(2, '2025-01-01', '2025-02-28', 25000, 'Día', NULL, 0),           -- Socio adulto
(2, '2025-01-01', '2025-02-28', 15000, 'Día', 11, 0),             -- Socio menor
(2, '2025-01-01', '2025-02-28', 30000, 'Día', NULL, 1),           -- Invitado adulto
(2, '2025-01-01', '2025-02-28',  2000, 'Día', 11, 1),             -- Invitado menor

-- Valor de temporada
(2, '2025-01-01', '2025-02-28', 2000000, 'Temporada', NULL, 0),   -- Socio adulto
(2, '2025-01-01', '2025-02-28', 1200000, 'Temporada', 11, 0),     -- Socio menor

-- Valor del mes
(2, '2025-01-01', '2025-02-28', 625000, 'Mes', NULL, 0),          -- Socio adulto
(2, '2025-01-01', '2025-02-28', 375000, 'Mes', 11, 0);            -- Socio menor


-- Precios de Colonia de verano (id_actividad_rec 3) por Adultos, Menores, siendo socios o invitados, por día, mes y temporada
INSERT INTO socios.TarifaActividadRecreativa
(id_actividad_rec, vigente_desde, vigente_hasta, valor, modalidad, edad_maxima, invitado)
VALUES
-- Valor del día
(3, '2025-01-01', '2025-02-28', 25000, 'Día', NULL, 0),				-- Socio adulto
(3, '2025-01-01', '2025-02-28', 15000, 'Día', 11, 0),				-- Socio menor
(3, '2025-01-01', '2025-02-28', 30000, 'Día', NULL, 1),				-- Invitado adulto
(3, '2025-01-01', '2025-02-28',  2000, 'Día', 11, 1),				-- Invitado menor

-- Valor de temporada
(3, '2025-01-01', '2025-02-28', 2000000, 'Temporada', NULL, 0),		-- Socio adulto
(3, '2025-01-01', '2025-02-28', 1200000, 'Temporada', 11, 0),		-- Socio menor

-- Valor del mes
(3, '2025-01-01', '2025-02-28', 625000, 'Mes', NULL, 0),			-- Socio adulto
(3, '2025-01-01', '2025-02-28', 375000, 'Mes', 11, 0);				-- Socio menor

SELECT * FROM socios.TarifaActividadRecreativa

INSERT INTO socios.MedioDePago
(nombre)
VALUES
('Visa'),
('MasterCard'),
('Tarjeta Naranja'),
('Pago Fácil'),
('Rapipago'),
('Transferencia Mercado Pago');

SELECT * FROM socios.MedioDePago

/*	 ___                     _            _                              _       
	|_ _|_ __  ___  ___ _ __(_)_ __   ___(_) ___  _ __    ___  ___   ___(_) ___  
	 | || '_ \/ __|/ __| '__| | '_ \ / __| |/ _ \| '_ \  / __|/ _ \ / __| |/ _ \ 
	 | || | | \__ \ (__| |  | | |_) | (__| | (_) | | | | \__ \ (_) | (__| | (_) |
	|___|_| |_|___/\___|_|  |_| .__/ \___|_|\___/|_| |_| |___/\___/ \___|_|\___/ 
                          |_|                                                
*/
EXEC socios.cargar_responsables_de_pago_csv_sp
     @ruta_archivo = 'Z:\UNLAM\2DO\Base de Datos Aplicada\Responsables-de-Pago.csv'; 
GO
SELECT * FROM socios.socio

/*		 ___                     _            _                              _       
		|_ _|_ __  ___  ___ _ __(_)_ __   ___(_) ___  _ __    ___  ___   ___(_) ___  
		 | || '_ \/ __|/ __| '__| | '_ \ / __| |/ _ \| '_ \  / __|/ _ \ / __| |/ _ \ 
		 | || | | \__ \ (__| |  | | |_) | (__| | (_) | | | | \__ \ (_) | (__| | (_) |
		|___|_| |_|___/\___|_|  |_| .__/ \___|_|\___/|_| |_| |___/\___/ \___|_|\___/ 
		 _ __ ___   ___ _ __   ___|_| __                                             
		| '_ ` _ \ / _ \ '_ \ / _ \| '__|                                            
		| | | | | |  __/ | | | (_) | |                                               
		|_| |_| |_|\___|_| |_|\___/|_|                                               
*/

EXEC socios.cargar_grupo_familiar_csv_sp
     @ruta_archivo = 'Z:\UNLAM\2DO\Base de Datos Aplicada\Grupo-Familiar.csv'; 
GO
SELECT * FROM socios.Parentesco;

/*
     _        _     _                  _       
    / \   ___(_)___| |_ ___ _ __   ___(_) __ _ 
   / _ \ / __| / __| __/ _ \ '_ \ / __| |/ _` |
  / ___ \\__ \ \__ \ ||  __/ | | | (__| | (_| |
 /_/   \_\___/_|___/\__\___|_| |_|\___|_|\__,_|
                                               
*/
EXEC socios.cargar_asistencia_actividad_csv_sp
	@ruta_archivo = 'Z:\UNLAM\2DO\Base de Datos Aplicada\presentismo-actividades.csv';
GO
SELECT * FROM socios.AsistenciaActividadDeportiva;