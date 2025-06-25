USE Com2900G05;
GO

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
VALUES ('Futsal'),('Voley'),('Taekwondo'),('Baile artistico'),('Natacion'),('Ajedrez')
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

-- Carga de datos en la tabla tarifa actividad recreativa
INSERT INTO socios.TarifaActividadRecreativa(id_actividad_rec, vigente_desde, vigente_hasta, valor, modalidad, edad_maxima, invitado)
VALUES
(1, '2025-01-01', '2025-05-28', 25000),
(2, '2025-01-01', '2025-05-28', 30000),
(3, '2025-01-01', '2025-05-28', 25000),
SELECT * FROM socios.TarifaActividadDeportiva

