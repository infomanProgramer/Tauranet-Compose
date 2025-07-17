-- Pagos

alter table pagos
DROP COLUMN efectivo;

alter table pagos
DROP COLUMN total_pagar;

alter table pagos
DROP COLUMN visa;

alter table pagos
DROP COLUMN mastercard;

ALTER TABLE pagos 
ADD COLUMN tipo_pago INTEGER;

ALTER TABLE pagos RENAME COLUMN total TO importe;

alter table pagos add column efectivo numeric(9,2);

ALTER TABLE pagos
ALTER COLUMN efectivo TYPE numeric(9,2)
USING ROUND(efectivo, 2);


-- Venta Productos
ALTER TABLE venta_productos 
DROP COLUMN descuento;

ALTER TABLE venta_productos 
DROP COLUMN tipo_pago;

ALTER TABLE venta_productos 
DROP COLUMN total;

ALTER TABLE venta_productos 
DROP COLUMN importe;

ALTER TABLE clientes
ALTER COLUMN dni TYPE INTEGER
USING dni::INTEGER;

--1. Añadir los campos precio_base e importe_base en la tabla producto_vendidos
alter table producto_vendidos add column precio_base numeric(9,2);
alter table producto_vendidos add column importe_base numeric(9,2);

--2. Añadir el campo precio_base en tabla de productos
alter table productos add column precio_base numeric(9,2);

--3. Añadir el campo importe_base en pagos
alter table pagos add column importe_base numeric(9,2);








