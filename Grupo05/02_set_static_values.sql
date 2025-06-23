USE Com2900G05;
GO

-- Carga de datos en la tabla categoría
INSERT INTO socios.Categoria (nombre, edad_min, edad_max)
VALUES ('Menor', 0, 12),
       ('Cadete', 13, 17),
       ('Mayor', 18, NULL);
