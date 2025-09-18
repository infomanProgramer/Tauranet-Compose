--Creación de la tabla

CREATE TABLE diccionario_datos (
    id_diccionario SERIAL PRIMARY KEY,        -- identificador único
    tabla VARCHAR(100) NOT NULL,              -- tabla relacionada (ej: 'pedidos', 'usuarios')
    campo VARCHAR(50) NOT NULL,               -- campo relacionado (ej: 'estado_pedido', 'estado_usuario')
    codigo VARCHAR(20) NOT NULL,              -- código corto (ej: 'PEND', 'ACT')
    descripcion VARCHAR(100) NOT NULL,        -- descripción legible (ej: 'Pendiente de aprobación')
    valor_extra VARCHAR(100),                 -- opcional: color, ícono, etiqueta corta
    orden INT,                                -- orden de visualización
    activo BOOLEAN NOT NULL DEFAULT TRUE,     -- estado vigente o no
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Índice único para evitar códigos duplicados dentro de una tabla/campo
CREATE UNIQUE INDEX ux_diccionario_tabla_campo_codigo
ON diccionario_datos (tabla, campo, codigo);



-- Inserción de campos

---- Estados de pedido
    INSERT INTO diccionario_datos (tabla, campo, codigo, descripcion, valor_extra, orden)
    VALUES
    ('venta_productos', 'estado_venta', 'P', 'Pagado', 'verde', 1),
    ('venta_productos', 'estado_venta', 'C', 'Cancelado', 'rojo', 2),
    ('venta_productos', 'estado_venta', 'E', 'Pendiente', 'amarillo', 3);