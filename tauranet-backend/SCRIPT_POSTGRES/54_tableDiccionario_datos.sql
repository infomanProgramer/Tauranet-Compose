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

---- Estados de tipo servicio
    INSERT INTO diccionario_datos (tabla, campo, codigo, descripcion, valor_extra, orden)
    VALUES
    ('pagos', 'tipo_servicio', '0', 'mesa', 'verde', 1),
    ('pagos', 'tipo_servicio', '1', 'delivery', 'rojo', 2),
    ('pagos', 'tipo_servicio', '2', 'take_away', 'amarillo', 3);

---- Estados de tipo pago
    INSERT INTO diccionario_datos (tabla, campo, codigo, descripcion, valor_extra, orden)
    VALUES
    ('pagos', 'tipo_pago', '0', 'efectivo', 'verde', 1),
    ('pagos', 'tipo_pago', '1', 'tarjeta', 'rojo', 2),
    ('pagos', 'tipo_pago', '2', 'pago_qr', 'amarillo', 3);







ALTER TABLE diccionario_datos
ALTER COLUMN codigo TYPE integer
USING codigo::integer;


ALTER TABLE venta_productos 
ALTER COLUMN estado_venta TYPE integer
USING estado_venta::integer;