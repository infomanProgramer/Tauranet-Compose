--
-- PostgreSQL database dump
--

-- Dumped from database version 16.4
-- Dumped by pg_dump version 16.4

-- Started on 2025-05-22 17:43:16

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 253 (class 1255 OID 33044)
-- Name: function_empleado_pedido(bigint, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.function_empleado_pedido(idrestaurante bigint, fechaini date, fechafin date) RETURNS TABLE(nombre_usuario character varying, perfil text, pedidos bigint)
    LANGUAGE plpgsql
    AS $$
begin
	return query 
		select c.nombre_usuario, 'Cajero' as perfil, count(*) as pedidos from cajeros as c
		inner join cajas as j on j.id_caja = c.id_caja
		inner join sucursals as s on s.id_sucursal = c.id_sucursal
		inner join venta_productos as v on v.id_cajero = c.id_cajero
		inner join historial_caja as h on h.id_historial_caja = v.id_historial_caja
		where s.id_restaurant = idRestaurante and c.deleted_at isNull and h.fecha between fechaIni and fechaFin
		group by c.nombre_usuario
		union
		select m.nombre_usuario, 'Mozo' as perfil, count(*) as pedidos from mozos as m
		inner join sucursals as s on s.id_sucursal = m.id_sucursal
		inner join venta_productos as v on v.id_mozo = m.id_mozo
		inner join historial_caja as h on h.id_historial_caja = v.id_historial_caja
		where s.id_restaurant = idRestaurante and m.deleted_at isNull and h.fecha between fechaIni and fechaFin
		group by m.nombre_usuario
		order by pedidos desc, perfil asc;
end;
$$;


ALTER FUNCTION public.function_empleado_pedido(idrestaurante bigint, fechaini date, fechafin date) OWNER TO postgres;

--
-- TOC entry 254 (class 1255 OID 33045)
-- Name: function_fecha_importe(bigint, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.function_fecha_importe(idrestaurante bigint, fechaini date, fechafin date) RETURNS TABLE(fecha date, importe numeric)
    LANGUAGE plpgsql
    AS $$
begin
	return query
	select h.fecha, sum(p.importe) from producto_vendidos as p
	inner join venta_productos as v on v.id_venta_producto = p.id_venta_producto
	inner join historial_caja as h on h.id_historial_caja = v.id_historial_caja
	inner join cajas as c on c.id_caja = h.id_caja
	inner join sucursals as s on s.id_sucursal = c.id_sucursal
	where s.id_restaurant = idRestaurante and h.fecha between fechaIni and fechaFin
	group by h.fecha
	order by h.fecha asc;
end;
$$;


ALTER FUNCTION public.function_fecha_importe(idrestaurante bigint, fechaini date, fechafin date) OWNER TO postgres;

--
-- TOC entry 255 (class 1255 OID 33046)
-- Name: function_fecha_pedidos(bigint, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.function_fecha_pedidos(idrestaurante bigint, fechaini date, fechafin date) RETURNS TABLE(fecha date, pedidos bigint)
    LANGUAGE plpgsql
    AS $$
begin
	return query
	select h.fecha, count(*) as pedidos from venta_productos as v
	inner join historial_caja as h on h.id_historial_caja = v.id_historial_caja
	inner join cajas as c on c.id_caja = h.id_caja
	inner join sucursals as s on s.id_sucursal = c.id_sucursal
	where s.id_restaurant = idRestaurante and h.fecha between fechaIni and fechaFin
	group by h.fecha
	order by h.fecha asc;
end;
$$;


ALTER FUNCTION public.function_fecha_pedidos(idrestaurante bigint, fechaini date, fechafin date) OWNER TO postgres;

--
-- TOC entry 256 (class 1255 OID 33047)
-- Name: function_personal(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.function_personal(idrestaurant integer) RETURNS TABLE(id_usuario bigint, nombre_usuario character varying, nombre_completo text, dni character varying, tipo_usuario character, perfil text, nombresucursal character varying, created_at timestamp without time zone, id_sucursal bigint, estado boolean)
    LANGUAGE plpgsql
    AS $$begin
	return query 
		select c.id_cajero as id_usuario,
				c.nombre_usuario as nombre_usuario, 
				concat(c.primer_nombre,' ', c.segundo_nombre,' ',c.paterno,' ',c.materno) as nombre_completo, 
				c.dni as dni, 
				c.tipo_usuario as tipo_usuario, 
				'Cajero' as perfil, 
				s.nombre as nombreSucursal, 
				c.created_at as created_at, 
				s.id_sucursal,
				c.estado
		from cajeros as c
		inner join sucursals as s on s.id_sucursal = c.id_sucursal
		where s.id_restaurant = idRestaurant and c.deleted_at is null
		union
		select m.id_mozo as id_usuario,
				m.nombre_usuario as nombre_usuario, 
				concat(m.primer_nombre,' ',m.segundo_nombre,' ',m.paterno,' ',m.materno) as nombre_completo, 
				m.dni as dni, 
				m.tipo_usuario as tipo_usuario, 
				'Mozo' as perfil, 
				s.nombre as nombreSucursal, 
				m.created_at as created_at, 
				s.id_sucursal,
				m.estado
		from mozos as m
		inner join sucursals as s on s.id_sucursal = m.id_sucursal
		where s.id_restaurant = idRestaurant and m.deleted_at is null
		union
		select n.id_cocinero as id_usuario, 
				n.nombre_usuario as nombre_usuario, 
				concat(n.primer_nombre,' ',n.segundo_nombre,' ',n.paterno,' ',n.materno) as nombre_completo, 
				n.dni as dni,
				n.tipo_usuario as tipo_usuario,
				'Cocinero' as perfil,
				s.nombre as nombreSucursal,
				n.created_at as created_at,
				s.id_sucursal,
				n.estado
		from cocineros as n
		inner join sucursals as s on s.id_sucursal = n.id_sucursal
		where s.id_restaurant = idRestaurant and n.deleted_at is null
		order by created_at desc;
end;
$$;


ALTER FUNCTION public.function_personal(idrestaurant integer) OWNER TO postgres;

--
-- TOC entry 268 (class 1255 OID 33048)
-- Name: function_producto_cantidad(bigint, bigint, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.function_producto_cantidad(idrestaurante bigint, idcategoria bigint, fechaini date, fechafin date) RETURNS TABLE(nom_producto character varying, nom_categoria character varying, cantidad bigint)
    LANGUAGE plpgsql
    AS $$
begin
	if idCategoria != -1 then
		return query 	
			select p.nombre as nom_producto, ct.nombre as nom_categoria, sum(pv.cantidad) as cantidad from productos as p
			inner join categoria_productos as ct on ct.id_categoria_producto = p.id_categoria_producto
			inner join producto_vendidos as pv on pv.id_producto = p.id_producto
			inner join venta_productos as v on v.id_venta_producto = pv.id_venta_producto
			inner join historial_caja as h on h.id_historial_caja = v.id_historial_caja
			inner join cajas as c on c.id_caja = h.id_caja
			inner join sucursals as s on s.id_sucursal = c.id_sucursal
			where s.id_restaurant = idRestaurante and ct.id_categoria_producto = idCategoria and h.fecha between fechaIni and fechaFin
			group by p.nombre, ct.nombre, ct.id_categoria_producto
			order by cantidad desc;
	else
		return query 	
			select p.nombre as nom_producto, ct.nombre as nom_categoria, sum(pv.cantidad) as cantidad from productos as p
			inner join categoria_productos as ct on ct.id_categoria_producto = p.id_categoria_producto
			inner join producto_vendidos as pv on pv.id_producto = p.id_producto
			inner join venta_productos as v on v.id_venta_producto = pv.id_venta_producto
			inner join historial_caja as h on h.id_historial_caja = v.id_historial_caja
			inner join cajas as c on c.id_caja = h.id_caja
			inner join sucursals as s on s.id_sucursal = c.id_sucursal
			where s.id_restaurant = idRestaurante and h.fecha between fechaIni and fechaFin
			group by p.nombre, ct.nombre, ct.id_categoria_producto
			order by cantidad desc;
	end if;
end;
$$;


ALTER FUNCTION public.function_producto_cantidad(idrestaurante bigint, idcategoria bigint, fechaini date, fechafin date) OWNER TO postgres;

--
-- TOC entry 269 (class 1255 OID 33049)
-- Name: function_producto_importe(bigint, bigint, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.function_producto_importe(idrestaurante bigint, idcategoria bigint, fechaini date, fechafin date) RETURNS TABLE(nom_producto character varying, nom_categoria character varying, importe numeric)
    LANGUAGE plpgsql
    AS $$
begin
	if idCategoria != -1 then
		return query 	
			select p.nombre as nom_producto, ct.nombre as nom_categoria, sum(pv.importe) as importe from productos as p
			inner join categoria_productos as ct on ct.id_categoria_producto = p.id_categoria_producto
			inner join producto_vendidos as pv on pv.id_producto = p.id_producto
			inner join venta_productos as v on v.id_venta_producto = pv.id_venta_producto
			inner join historial_caja as h on h.id_historial_caja = v.id_historial_caja
			inner join cajas as c on c.id_caja = h.id_caja
			inner join sucursals as s on s.id_sucursal = c.id_sucursal
			where s.id_restaurant = idRestaurante and ct.id_categoria_producto = idCategoria and h.fecha between fechaIni and fechaFin
			group by p.nombre, ct.nombre, ct.id_categoria_producto
			order by importe desc;
	else
		return query 	
			select p.nombre as nom_producto, ct.nombre as nom_categoria, sum(pv.importe) as importe from productos as p
			inner join categoria_productos as ct on ct.id_categoria_producto = p.id_categoria_producto
			inner join producto_vendidos as pv on pv.id_producto = p.id_producto
			inner join venta_productos as v on v.id_venta_producto = pv.id_venta_producto
			inner join historial_caja as h on h.id_historial_caja = v.id_historial_caja
			inner join cajas as c on c.id_caja = h.id_caja
			inner join sucursals as s on s.id_sucursal = c.id_sucursal
			where s.id_restaurant = idRestaurante and h.fecha between fechaIni and fechaFin
			group by p.nombre, ct.nombre, ct.id_categoria_producto
			order by importe desc;
	end if;
end;
$$;


ALTER FUNCTION public.function_producto_importe(idrestaurante bigint, idcategoria bigint, fechaini date, fechafin date) OWNER TO postgres;

--
-- TOC entry 270 (class 1255 OID 33050)
-- Name: registraproductosfunction(text, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.registraproductosfunction(cad text, id_venta_producto bigint) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
	nro_elementos integer;
	row_cad text;
	col_cad text;
	i integer;
	j integer;
	
BEGIN
	i = 1;
    nro_elementos = (select array_length(regexp_split_to_array(cad, ':'),1));
    WHILE i <= (select nro_elementos) LOOP
		row_cad = (SELECT split_part(cad, ':', i));
		raise notice '%',row_cad;
		raise notice '-> %', (SELECT split_part(row_cad, '|', 1));--cod
		raise notice '-> %', (SELECT split_part(row_cad, '|', 2));--cant
		raise notice '-> %', (SELECT split_part(row_cad, '|', 3));--p_unit
		raise notice '-> %', (SELECT split_part(row_cad, '|', 4));--importe
		raise notice '-> %', (SELECT split_part(row_cad, '|', 5));--nota
		insert into producto_vendidos
			(
				id_producto,
				cantidad,
				p_unit,
				importe,
				nota,
				id_venta_producto,
				created_at
			)
			values (
				CAST(split_part(row_cad, '|', 1) as bigint),--cod
				CAST(split_part(row_cad, '|', 2) as int),--cant
				CAST(split_part(row_cad, '|', 3) as numeric(9, 4)),--p_unit
				CAST(split_part(row_cad, '|', 4) as numeric(9, 4)),--importe
				(SELECT split_part(row_cad, '|', 5)),--nota
				id_venta_producto,
				now()
			);
		
		--raise notice '% %', suma, i;
		i = i+1;
	END LOOP;
    RETURN i-1;
END;          
$$;


ALTER FUNCTION public.registraproductosfunction(cad text, id_venta_producto bigint) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 215 (class 1259 OID 33051)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id_usuario bigint NOT NULL,
    primer_nombre character varying(100),
    paterno character varying(250),
    materno character varying(250),
    dni character varying(25),
    direccion text,
    nombre_usuario character varying(25),
    email character varying(250),
    password character varying(500),
    fecha_nac date,
    sexo boolean,
    nombre_fotoperfil character varying(150),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    tipo_usuario character(1),
    api_token character varying(60),
    segundo_nombre character varying(100),
    celular character varying(20),
    telefono character varying(20),
    deleted_at timestamp without time zone,
    estado boolean
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 33056)
-- Name: administradors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.administradors (
    id_administrador bigint NOT NULL,
    id_restaurant bigint NOT NULL,
    id_superadministrador bigint NOT NULL
)
INHERITS (public.users);


ALTER TABLE public.administradors OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 33061)
-- Name: administradors_id_administrador_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.administradors_id_administrador_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.administradors_id_administrador_seq OWNER TO postgres;

--
-- TOC entry 5032 (class 0 OID 0)
-- Dependencies: 217
-- Name: administradors_id_administrador_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.administradors_id_administrador_seq OWNED BY public.administradors.id_administrador;


--
-- TOC entry 218 (class 1259 OID 33062)
-- Name: cajas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cajas (
    id_caja bigint NOT NULL,
    nombre character varying(20) NOT NULL,
    descripcion text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_administrador bigint NOT NULL,
    id_sucursal bigint,
    deleted_at timestamp without time zone
);


ALTER TABLE public.cajas OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 33067)
-- Name: cajas_id_caja_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cajas_id_caja_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cajas_id_caja_seq OWNER TO postgres;

--
-- TOC entry 5033 (class 0 OID 0)
-- Dependencies: 219
-- Name: cajas_id_caja_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cajas_id_caja_seq OWNED BY public.cajas.id_caja;


--
-- TOC entry 220 (class 1259 OID 33068)
-- Name: cajeros; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cajeros (
    id_cajero bigint NOT NULL,
    sueldo numeric(9,2),
    fecha_inicio date,
    id_sucursal bigint NOT NULL,
    id_administrador bigint NOT NULL,
    id_caja bigint
)
INHERITS (public.users);


ALTER TABLE public.cajeros OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 33073)
-- Name: categoria_productos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categoria_productos (
    id_categoria_producto bigint NOT NULL,
    nombre character varying(50) NOT NULL,
    descripcion text,
    fecha_inicio date,
    id_restaurant bigint NOT NULL,
    id_administrador bigint NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);


ALTER TABLE public.categoria_productos OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 33078)
-- Name: categoria_productos_id_categoria_producto_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categoria_productos_id_categoria_producto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categoria_productos_id_categoria_producto_seq OWNER TO postgres;

--
-- TOC entry 5034 (class 0 OID 0)
-- Dependencies: 222
-- Name: categoria_productos_id_categoria_producto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categoria_productos_id_categoria_producto_seq OWNED BY public.categoria_productos.id_categoria_producto;


--
-- TOC entry 223 (class 1259 OID 33079)
-- Name: clientes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clientes (
    id_cliente bigint NOT NULL,
    nombre_completo character varying(100),
    dni character varying(50),
    id_cajero bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_mozo bigint,
    id_restaurant bigint
);


ALTER TABLE public.clientes OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 33082)
-- Name: clientes_id_cliente_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.clientes_id_cliente_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.clientes_id_cliente_seq OWNER TO postgres;

--
-- TOC entry 5035 (class 0 OID 0)
-- Dependencies: 224
-- Name: clientes_id_cliente_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.clientes_id_cliente_seq OWNED BY public.clientes.id_cliente;


--
-- TOC entry 225 (class 1259 OID 33083)
-- Name: cocineros; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cocineros (
    id_cocinero bigint NOT NULL,
    sueldo numeric(9,2),
    fecha_inicio date,
    id_sucursal bigint NOT NULL,
    id_administrador bigint NOT NULL
)
INHERITS (public.users);


ALTER TABLE public.cocineros OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 33088)
-- Name: cocineros_id_cocinero_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cocineros_id_cocinero_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cocineros_id_cocinero_seq OWNER TO postgres;

--
-- TOC entry 5036 (class 0 OID 0)
-- Dependencies: 226
-- Name: cocineros_id_cocinero_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cocineros_id_cocinero_seq OWNED BY public.cocineros.id_cocinero;


--
-- TOC entry 227 (class 1259 OID 33089)
-- Name: empleados_id_empleado_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.empleados_id_empleado_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.empleados_id_empleado_seq OWNER TO postgres;

--
-- TOC entry 5037 (class 0 OID 0)
-- Dependencies: 227
-- Name: empleados_id_empleado_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.empleados_id_empleado_seq OWNED BY public.cajeros.id_cajero;


--
-- TOC entry 228 (class 1259 OID 33090)
-- Name: historial_caja; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.historial_caja (
    id_historial_caja bigint NOT NULL,
    monto_inicial numeric(10,2) NOT NULL,
    monto numeric(10,2) NOT NULL,
    fecha date NOT NULL,
    estado boolean NOT NULL,
    id_caja bigint NOT NULL,
    id_administrador bigint,
    id_cajero bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.historial_caja OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 33093)
-- Name: historial_caja_id_historial_caja_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.historial_caja_id_historial_caja_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.historial_caja_id_historial_caja_seq OWNER TO postgres;

--
-- TOC entry 5038 (class 0 OID 0)
-- Dependencies: 229
-- Name: historial_caja_id_historial_caja_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.historial_caja_id_historial_caja_seq OWNED BY public.historial_caja.id_historial_caja;


--
-- TOC entry 230 (class 1259 OID 33094)
-- Name: mozos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mozos (
    id_mozo bigint NOT NULL,
    sueldo numeric(9,2),
    fecha_inicio date,
    id_sucursal bigint NOT NULL,
    id_administrador bigint NOT NULL
)
INHERITS (public.users);


ALTER TABLE public.mozos OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 33099)
-- Name: mozos_id_mozo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mozos_id_mozo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mozos_id_mozo_seq OWNER TO postgres;

--
-- TOC entry 5039 (class 0 OID 0)
-- Dependencies: 231
-- Name: mozos_id_mozo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mozos_id_mozo_seq OWNED BY public.mozos.id_mozo;


--
-- TOC entry 232 (class 1259 OID 33100)
-- Name: pagos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pagos (
    id_pago bigint NOT NULL,
    efectivo numeric(9,2),
    total numeric(9,2),
    total_pagar numeric(9,2),
    visa numeric(9,2),
    mastercard numeric(9,2),
    cambio numeric(9,2),
    id_venta_producto bigint NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_cajero bigint
);


ALTER TABLE public.pagos OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 33103)
-- Name: pagos_id_pago_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pagos_id_pago_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pagos_id_pago_seq OWNER TO postgres;

--
-- TOC entry 5040 (class 0 OID 0)
-- Dependencies: 233
-- Name: pagos_id_pago_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pagos_id_pago_seq OWNED BY public.pagos.id_pago;


--
-- TOC entry 234 (class 1259 OID 33104)
-- Name: perfilimagens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.perfilimagens (
    id_perfilimagen bigint NOT NULL,
    nombre character varying(250) NOT NULL,
    id_administrador bigint,
    id_mozo bigint,
    id_cajero bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.perfilimagens OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 33107)
-- Name: perfilimagens_id_perfilimagen_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.perfilimagens_id_perfilimagen_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.perfilimagens_id_perfilimagen_seq OWNER TO postgres;

--
-- TOC entry 5041 (class 0 OID 0)
-- Dependencies: 235
-- Name: perfilimagens_id_perfilimagen_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.perfilimagens_id_perfilimagen_seq OWNED BY public.perfilimagens.id_perfilimagen;


--
-- TOC entry 236 (class 1259 OID 33108)
-- Name: plan_de_pagos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.plan_de_pagos (
    id_planpago bigint NOT NULL,
    cant_pedidos integer,
    cant_mozos integer,
    cant_cajas integer,
    cant_cajeros integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_suscripcion bigint NOT NULL,
    cant_cocineros integer
);


ALTER TABLE public.plan_de_pagos OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 33111)
-- Name: plan_de_pagos_id_planpago_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.plan_de_pagos_id_planpago_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.plan_de_pagos_id_planpago_seq OWNER TO postgres;

--
-- TOC entry 5042 (class 0 OID 0)
-- Dependencies: 237
-- Name: plan_de_pagos_id_planpago_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.plan_de_pagos_id_planpago_seq OWNED BY public.plan_de_pagos.id_planpago;


--
-- TOC entry 238 (class 1259 OID 33112)
-- Name: producto_vendidos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.producto_vendidos (
    id_producto_vendido bigint NOT NULL,
    cantidad integer,
    importe numeric(9,2),
    id_producto bigint NOT NULL,
    id_venta_producto bigint NOT NULL,
    nota text,
    p_unit numeric(9,2),
    created_at timestamp without time zone
);


ALTER TABLE public.producto_vendidos OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 33117)
-- Name: producto_vendidos_id_producto_vendido_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.producto_vendidos_id_producto_vendido_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.producto_vendidos_id_producto_vendido_seq OWNER TO postgres;

--
-- TOC entry 5043 (class 0 OID 0)
-- Dependencies: 239
-- Name: producto_vendidos_id_producto_vendido_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.producto_vendidos_id_producto_vendido_seq OWNED BY public.producto_vendidos.id_producto_vendido;


--
-- TOC entry 240 (class 1259 OID 33118)
-- Name: productos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.productos (
    id_producto bigint NOT NULL,
    nombre character varying(50) NOT NULL,
    descripcion text,
    id_categoria_producto bigint NOT NULL,
    id_administrador bigint NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    precio numeric(9,2),
    deleted_at timestamp without time zone,
    producto_image character varying(250)
);


ALTER TABLE public.productos OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 33123)
-- Name: productos_id_producto_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.productos_id_producto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.productos_id_producto_seq OWNER TO postgres;

--
-- TOC entry 5044 (class 0 OID 0)
-- Dependencies: 241
-- Name: productos_id_producto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.productos_id_producto_seq OWNED BY public.productos.id_producto;


--
-- TOC entry 242 (class 1259 OID 33124)
-- Name: restaurants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.restaurants (
    id_restaurant bigint NOT NULL,
    nombre character varying(50) NOT NULL,
    estado boolean NOT NULL,
    descripcion text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_superadministrador bigint NOT NULL,
    observacion text,
    id_suscripcion bigint,
    tipo_moneda character varying(10),
    identificacion character varying(10)
);


ALTER TABLE public.restaurants OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 33129)
-- Name: restaurants_id_restaurant_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.restaurants_id_restaurant_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.restaurants_id_restaurant_seq OWNER TO postgres;

--
-- TOC entry 5045 (class 0 OID 0)
-- Dependencies: 243
-- Name: restaurants_id_restaurant_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.restaurants_id_restaurant_seq OWNED BY public.restaurants.id_restaurant;


--
-- TOC entry 244 (class 1259 OID 33130)
-- Name: sucursals; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sucursals (
    id_sucursal bigint NOT NULL,
    nombre character varying(20) NOT NULL,
    direccion text,
    descripcion text,
    id_restaurant bigint NOT NULL,
    id_superadministrador bigint NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    ciudad character varying(20),
    pais character varying(20),
    telefono character varying(20),
    celular character varying(20)
);


ALTER TABLE public.sucursals OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 33135)
-- Name: sucursals_id_sucursal_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sucursals_id_sucursal_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sucursals_id_sucursal_seq OWNER TO postgres;

--
-- TOC entry 5046 (class 0 OID 0)
-- Dependencies: 245
-- Name: sucursals_id_sucursal_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sucursals_id_sucursal_seq OWNED BY public.sucursals.id_sucursal;


--
-- TOC entry 246 (class 1259 OID 33136)
-- Name: superadministradors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.superadministradors (
    id_superadministrador bigint NOT NULL,
    nombre_usuario character varying(250) NOT NULL,
    password character varying(250) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.superadministradors OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 33141)
-- Name: superadministradors_id_superadministrador_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.superadministradors_id_superadministrador_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.superadministradors_id_superadministrador_seq OWNER TO postgres;

--
-- TOC entry 5047 (class 0 OID 0)
-- Dependencies: 247
-- Name: superadministradors_id_superadministrador_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.superadministradors_id_superadministrador_seq OWNED BY public.superadministradors.id_superadministrador;


--
-- TOC entry 248 (class 1259 OID 33142)
-- Name: suscripcions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suscripcions (
    id_suscripcion bigint NOT NULL,
    tipo_suscripcion character varying(20) NOT NULL,
    observacion text,
    precio_anual numeric(9,2),
    precio_mensual numeric(9,2),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_superadministrador bigint NOT NULL
);


ALTER TABLE public.suscripcions OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 33147)
-- Name: suscripcions_id_suscripcion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.suscripcions_id_suscripcion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.suscripcions_id_suscripcion_seq OWNER TO postgres;

--
-- TOC entry 5048 (class 0 OID 0)
-- Dependencies: 249
-- Name: suscripcions_id_suscripcion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.suscripcions_id_suscripcion_seq OWNED BY public.suscripcions.id_suscripcion;


--
-- TOC entry 250 (class 1259 OID 33148)
-- Name: users_id_usuario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_usuario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_usuario_seq OWNER TO postgres;

--
-- TOC entry 5049 (class 0 OID 0)
-- Dependencies: 250
-- Name: users_id_usuario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_usuario_seq OWNED BY public.users.id_usuario;


--
-- TOC entry 251 (class 1259 OID 33149)
-- Name: venta_productos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.venta_productos (
    id_venta_producto bigint NOT NULL,
    nro_venta integer,
    total numeric(9,2),
    descuento integer,
    estado_venta character(1),
    id_cliente bigint,
    id_cajero bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_sucursal bigint,
    id_mozo bigint,
    sub_total numeric(9,2),
    id_historial_caja bigint,
    estado_atendido boolean,
    id_cocinero bigint
);


ALTER TABLE public.venta_productos OWNER TO postgres;

--
-- TOC entry 252 (class 1259 OID 33152)
-- Name: venta_productos_id_venta_producto_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.venta_productos_id_venta_producto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.venta_productos_id_venta_producto_seq OWNER TO postgres;

--
-- TOC entry 5050 (class 0 OID 0)
-- Dependencies: 252
-- Name: venta_productos_id_venta_producto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.venta_productos_id_venta_producto_seq OWNED BY public.venta_productos.id_venta_producto;


--
-- TOC entry 4732 (class 2604 OID 33153)
-- Name: administradors id_usuario; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.administradors ALTER COLUMN id_usuario SET DEFAULT nextval('public.users_id_usuario_seq'::regclass);


--
-- TOC entry 4733 (class 2604 OID 33154)
-- Name: administradors id_administrador; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.administradors ALTER COLUMN id_administrador SET DEFAULT nextval('public.administradors_id_administrador_seq'::regclass);


--
-- TOC entry 4734 (class 2604 OID 33155)
-- Name: cajas id_caja; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cajas ALTER COLUMN id_caja SET DEFAULT nextval('public.cajas_id_caja_seq'::regclass);


--
-- TOC entry 4735 (class 2604 OID 33156)
-- Name: cajeros id_usuario; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cajeros ALTER COLUMN id_usuario SET DEFAULT nextval('public.users_id_usuario_seq'::regclass);


--
-- TOC entry 4736 (class 2604 OID 33157)
-- Name: cajeros id_cajero; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cajeros ALTER COLUMN id_cajero SET DEFAULT nextval('public.empleados_id_empleado_seq'::regclass);


--
-- TOC entry 4737 (class 2604 OID 33158)
-- Name: categoria_productos id_categoria_producto; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria_productos ALTER COLUMN id_categoria_producto SET DEFAULT nextval('public.categoria_productos_id_categoria_producto_seq'::regclass);


--
-- TOC entry 4738 (class 2604 OID 33159)
-- Name: clientes id_cliente; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes ALTER COLUMN id_cliente SET DEFAULT nextval('public.clientes_id_cliente_seq'::regclass);


--
-- TOC entry 4739 (class 2604 OID 33160)
-- Name: cocineros id_usuario; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cocineros ALTER COLUMN id_usuario SET DEFAULT nextval('public.users_id_usuario_seq'::regclass);


--
-- TOC entry 4740 (class 2604 OID 33161)
-- Name: cocineros id_cocinero; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cocineros ALTER COLUMN id_cocinero SET DEFAULT nextval('public.cocineros_id_cocinero_seq'::regclass);


--
-- TOC entry 4741 (class 2604 OID 33162)
-- Name: historial_caja id_historial_caja; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_caja ALTER COLUMN id_historial_caja SET DEFAULT nextval('public.historial_caja_id_historial_caja_seq'::regclass);


--
-- TOC entry 4742 (class 2604 OID 33163)
-- Name: mozos id_usuario; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mozos ALTER COLUMN id_usuario SET DEFAULT nextval('public.users_id_usuario_seq'::regclass);


--
-- TOC entry 4743 (class 2604 OID 33164)
-- Name: mozos id_mozo; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mozos ALTER COLUMN id_mozo SET DEFAULT nextval('public.mozos_id_mozo_seq'::regclass);


--
-- TOC entry 4744 (class 2604 OID 33165)
-- Name: pagos id_pago; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pagos ALTER COLUMN id_pago SET DEFAULT nextval('public.pagos_id_pago_seq'::regclass);


--
-- TOC entry 4745 (class 2604 OID 33166)
-- Name: perfilimagens id_perfilimagen; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.perfilimagens ALTER COLUMN id_perfilimagen SET DEFAULT nextval('public.perfilimagens_id_perfilimagen_seq'::regclass);


--
-- TOC entry 4746 (class 2604 OID 33167)
-- Name: plan_de_pagos id_planpago; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plan_de_pagos ALTER COLUMN id_planpago SET DEFAULT nextval('public.plan_de_pagos_id_planpago_seq'::regclass);


--
-- TOC entry 4747 (class 2604 OID 33168)
-- Name: producto_vendidos id_producto_vendido; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.producto_vendidos ALTER COLUMN id_producto_vendido SET DEFAULT nextval('public.producto_vendidos_id_producto_vendido_seq'::regclass);


--
-- TOC entry 4748 (class 2604 OID 33169)
-- Name: productos id_producto; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos ALTER COLUMN id_producto SET DEFAULT nextval('public.productos_id_producto_seq'::regclass);


--
-- TOC entry 4749 (class 2604 OID 33170)
-- Name: restaurants id_restaurant; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.restaurants ALTER COLUMN id_restaurant SET DEFAULT nextval('public.restaurants_id_restaurant_seq'::regclass);


--
-- TOC entry 4750 (class 2604 OID 33171)
-- Name: sucursals id_sucursal; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sucursals ALTER COLUMN id_sucursal SET DEFAULT nextval('public.sucursals_id_sucursal_seq'::regclass);


--
-- TOC entry 4751 (class 2604 OID 33172)
-- Name: superadministradors id_superadministrador; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.superadministradors ALTER COLUMN id_superadministrador SET DEFAULT nextval('public.superadministradors_id_superadministrador_seq'::regclass);


--
-- TOC entry 4752 (class 2604 OID 33173)
-- Name: suscripcions id_suscripcion; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suscripcions ALTER COLUMN id_suscripcion SET DEFAULT nextval('public.suscripcions_id_suscripcion_seq'::regclass);


--
-- TOC entry 4731 (class 2604 OID 33174)
-- Name: users id_usuario; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id_usuario SET DEFAULT nextval('public.users_id_usuario_seq'::regclass);


--
-- TOC entry 4753 (class 2604 OID 33175)
-- Name: venta_productos id_venta_producto; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venta_productos ALTER COLUMN id_venta_producto SET DEFAULT nextval('public.venta_productos_id_venta_producto_seq'::regclass);


--
-- TOC entry 4990 (class 0 OID 33056)
-- Dependencies: 216
-- Data for Name: administradors; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.administradors VALUES (61, 'Yesenia', 'Coyo', NULL, '6665552', 'asdfadsf', 'Yess', 'yess@mail.com', '$2y$10$AmsYnkTypLG5CFF4wfrCleo57tU6bc9ZJNDKtoK.4.AHgFsMxpLrm', '1988-12-12', false, 'ZrH1gxPzvP7jgpkzyp0WDhsiqP8Y8CAgP4uzAjmJ.jpeg', '2019-08-05 13:57:11', '2019-08-06 22:37:01', '2', NULL, NULL, '71202322', NULL, NULL, true, 55, 13, 1);
INSERT INTO public.administradors VALUES (63, 'Wendy', 'Fuentes', NULL, '98745623', 'asdfasdf', 'wen24', 'wen24@mail.com', '$2y$10$M9vMN0V8.CBnFgBJSFwmtepzy307eT5N0GpBe9KZb4TJazq8sfSOW', '1990-12-12', false, '6F0EBKaIr4xrNBERa9CZujVTc57pxZX6ylwsntcv.jpeg', '2019-08-06 22:31:13', '2019-08-07 08:32:55', '2', NULL, NULL, '71245623', NULL, NULL, true, 57, 14, 1);
INSERT INTO public.administradors VALUES (60, 'Chio', 'Torres', NULL, '9874562', 'sfasdsa', 'chio', 'chio@mail.com', '$2y$10$a0UfEJoygPT0znhg57tcjebAgUpst0kkyljxjeT61n6jqz0UDs9J.', '1980-12-12', false, '92MeGDwDnXlZ9GNdcdSl0MMdMDKNAYS0fNuF7jIB.jpeg', '2019-08-05 15:49:23', '2019-08-07 08:33:18', '2', NULL, NULL, '71245623', '2223171', NULL, true, 54, 14, 1);
INSERT INTO public.administradors VALUES (66, 'asdfasdf', 'asdfasdfa', 'sdfasdfa', '9871256489', 'asdfasdf', 'asdfadfa', 'asdfasdfad@mail.com', '$2y$10$KWwM3H8rALoJCp9ZBp3Ny.JyPtjV5wRfMygPaY48gDz0TfyEVeD6C', '1990-12-12', false, 'rkXyqgs8iGauty0LsfF4qRoh60bv6V2pzXNFAdRf.jpeg', '2019-08-15 15:09:36', '2019-08-15 15:09:36', '2', NULL, 'asdfasdfasdf', '71245823', NULL, NULL, true, 60, 1, 1);
INSERT INTO public.administradors VALUES (62, 'Linda', 'Vargas', NULL, '99666245', 'asdfasdfas', 'LindaB', 'lindab@mail.com', '$2y$10$w6fTbwLeGUO0tehQi2tVy.TfH9Vludo7ducmvAVDfwQId06x8nMJG', '1990-12-12', false, 'NwpWQDkvxshb5MiCM0zgIbx1AnfdLVNA758hTQOW.jpeg', '2019-08-06 22:26:39', '2019-08-15 15:11:55', '2', NULL, NULL, '71245623', NULL, NULL, true, 56, 14, 1);
INSERT INTO public.administradors VALUES (65, 'Israel', 'Vargas', 'Limachi', '9887745', 'asdfasdfa', 'Israel', 'israloco@mail.com', '$2y$10$On2eY8MfdbRI6b9b1Th/7Ol5.OCKjysnmuq15sUPWFabTesXK6Q7G', '1980-12-12', true, 'k8WArWa2CQOxdtcSOIO5BWXSV7E6N3PA6OhizLK6.jpeg', '2019-08-14 23:59:09', '2019-08-22 09:04:25', '2', NULL, NULL, '71245623', '2223171', NULL, true, 59, 1, 1);
INSERT INTO public.administradors VALUES (67, 'Ramiro', 'Vargas', 'Fuentes', '6669991', 'Av Sangines # 34', 'Ramero', 'ramero@mail.com', '$2y$10$J0D8l2FTP7d.RjIvc1dO8OgDeTBV/14tDNFU.kx3owUdW2lhkGV2K', '1991-08-08', true, 'HmreeUYv1iMcqvilE8i9zLuXvy0tSgwyP4ebcWgG.jpeg', '2019-08-25 21:14:15', '2019-08-25 21:14:15', '2', NULL, NULL, NULL, '2223171', NULL, true, 61, 8, 2);
INSERT INTO public.administradors VALUES (68, 'Rocio', 'Marengio', 'Rocio', '13254523', 'Av Sanchez # 67', 'La Colegiala', 'rocio_marengo@mail.com', '$2y$10$ZPB/KEBV8gsTYPPW6kZ6JuACL75EbY11jqd7MndoPx6qxMewLxGcu', '1990-12-12', false, '0WbDrp1xfYLgSSuc0rO0G3LUls194cIfTHetryGt.jpeg', '2019-08-27 18:15:12', '2019-08-27 18:17:34', '2', NULL, NULL, NULL, '2211362', NULL, true, 62, 31, 2);
INSERT INTO public.administradors VALUES (80, 'Daniela', 'Valverde', 'Ximenez', '69912398', 'Av San Paatricio # 45', 'DaniHola', 'dani_hola@mail.com', '$2y$10$O.3XU/jM.QiZSM7Edj1IluH4XNGmpM48iqv8I8SjUP1o9aR6KI9sG', '1987-08-15', false, 'TtEQLXfbG9NjRiTzpBh1AghU1S6Ys8XQB4DxPzDn.jpeg', '2019-09-02 18:09:22', '2019-09-02 18:10:52', '2', NULL, 'Lucero', '71245689', '2668899', NULL, true, 63, 30, 2);
INSERT INTO public.administradors VALUES (89, 'Boris', 'Velasco', NULL, '9874565', 'Av Santader 34', 'boris_velasco', 'boris_velasco@mail.com', '$2y$10$Zb59YBkEBpxFwNhbfVr7L.1a6PmcOjhF4uquqxLxmmAXsR38KrI9C', '1975-11-18', true, NULL, '2019-10-05 19:42:54', '2019-10-05 19:42:54', '2', NULL, NULL, '74589289', NULL, NULL, true, 64, 38, 2);
INSERT INTO public.administradors VALUES (92, 'Barbara', 'Rojas', NULL, '98745655', 'Escobar # 34', 'barba', 'barba@mail.com', '$2y$10$iSuPVlKU.obg4I3GRKo70uMPuySkWfz75ik86LbqmkTeA4fIz8Uhi', '1990-10-07', false, NULL, '2019-10-07 18:13:32', '2019-10-07 18:13:32', '2', NULL, NULL, '71245678', NULL, NULL, true, 65, 39, 2);
INSERT INTO public.administradors VALUES (64, 'Yesenia', 'Coyo', 'Rivas', '9988772', 'asdfasdfa', 'cyess', 'cyess@mail.com', '$2y$10$Nz.tR5pAtY2I6LA2Nk/UsOqdNcE.a8ZFiWTako5OfoiV48R6B3f1G', '1990-12-12', false, 'dV930hspAlPvyAAYWCvJCMtSDQbPpdwBsTpsKxfC.jpeg', '2019-08-07 08:48:50', '2019-10-10 17:34:14', '2', NULL, NULL, '71245623', NULL, NULL, true, 58, 31, 1);
INSERT INTO public.administradors VALUES (93, 'Alejandro', 'Ortiz', 'Ortiz', '1154687', 'Av. Cortez # 54', 'alejandro', 'alejandros1829@gmail.com', '$2y$10$lPExH8wPIg6.NGgES/ve6uyCtdwI3LYbNT50e.Odv04YCo2BLHuFu', '1979-10-20', true, NULL, '2019-10-18 09:20:10', '2019-10-18 09:20:10', '2', NULL, NULL, '71598726', NULL, NULL, true, 66, 41, 2);
INSERT INTO public.administradors VALUES (106, 'Ramiro', 'Velasco', 'Fuente', NULL, NULL, 'Ramiero1325', NULL, '$2y$10$PrOx9vKcwQQc3mr9613BlOw8R36C9gds/AFtw9l4/H5lM/i5MNfd2', NULL, true, NULL, '2019-10-24 10:34:17', '2019-10-24 10:34:17', '2', NULL, NULL, NULL, NULL, NULL, true, 68, 42, 2);
INSERT INTO public.administradors VALUES (96, 'Sergio', 'Sanchez', 'Lozada', '998789546', 'Pza Villarroel # 56', 'sergio21', 'sergio21@mail.com', '$2y$10$/Tr1pLL3sDIGqIDDEZzyV.l5Uq/xiwXG9b7I8irCOXpy6eqF40cMO', '2019-01-18', true, NULL, '2019-10-18 18:04:30', '2019-10-18 18:04:30', '2', NULL, NULL, NULL, '2457898', NULL, true, 67, 42, 2);
INSERT INTO public.administradors VALUES (112, 'Fernando', 'Calle', 'Vargas', '654787211', 'Av uno', 'cvargas', 'cvargas@mail.com', '$2y$10$71f8xxex0IcI4.7wa3IAteihgaBAsI./SNzaKHpSKoO45KVZpK4pi', '1987-11-16', true, NULL, '2019-11-26 09:24:11', '2019-11-26 09:24:11', '2', NULL, NULL, '71545689', NULL, NULL, true, 69, 44, 2);


--
-- TOC entry 4992 (class 0 OID 33062)
-- Dependencies: 218
-- Data for Name: cajas; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.cajas VALUES (11, 'Caja 04', NULL, '2019-08-26 17:47:08', '2019-08-26 17:47:08', 58, 3, NULL);
INSERT INTO public.cajas VALUES (14, 'Caja 04', NULL, '2019-08-26 22:16:09', '2019-08-26 22:16:09', 58, 9, NULL);
INSERT INTO public.cajas VALUES (15, 'Caja 05', NULL, '2019-08-26 22:20:20', '2019-08-26 22:20:20', 58, 9, NULL);
INSERT INTO public.cajas VALUES (17, 'Caja 07', NULL, '2019-08-27 11:34:22', '2019-08-27 11:34:22', 58, 3, NULL);
INSERT INTO public.cajas VALUES (12, 'Caja 1', NULL, '2019-08-26 22:13:51', '2019-08-27 11:57:12', 58, 9, NULL);
INSERT INTO public.cajas VALUES (9, 'Caja Dos', NULL, '2019-08-26 17:40:26', '2019-08-27 12:27:08', 58, 3, NULL);
INSERT INTO public.cajas VALUES (18, 'Caja 06', 'Ahora tiene', '2019-08-27 11:34:54', '2019-09-02 17:26:05', 58, 9, '2019-09-02 17:26:05');
INSERT INTO public.cajas VALUES (8, 'Caja 2', 'si tiene', '2019-08-26 13:58:08', '2019-09-02 17:26:59', 58, 9, '2019-09-02 17:26:59');
INSERT INTO public.cajas VALUES (7, 'Caja 1', 'Ahora si tiene', '2019-08-26 13:52:37', '2019-09-02 17:30:01', 58, 3, '2019-09-02 17:30:01');
INSERT INTO public.cajas VALUES (20, 'Caja Nueva', 'ya tiene', '2019-09-02 17:30:35', '2019-09-02 17:30:48', 58, 13, NULL);
INSERT INTO public.cajas VALUES (21, 'Caja Principal', NULL, '2019-09-02 17:31:14', '2019-09-02 17:31:14', 58, 12, NULL);
INSERT INTO public.cajas VALUES (22, 'Caja Unica', 'No tiene', '2019-09-02 17:31:34', '2019-09-02 17:31:34', 58, 14, NULL);
INSERT INTO public.cajas VALUES (16, 'Caja 06', NULL, '2019-08-27 10:23:12', '2019-09-17 09:27:47', 58, 3, '2019-09-17 09:27:47');
INSERT INTO public.cajas VALUES (13, 'Caja 3', NULL, '2019-08-26 22:15:35', '2019-09-17 09:29:30', 58, 9, '2019-09-17 09:29:30');
INSERT INTO public.cajas VALUES (23, 'Caja Universal', 'no tiene', '2019-09-17 10:28:12', '2019-09-17 10:28:26', 58, 9, '2019-09-17 10:28:26');
INSERT INTO public.cajas VALUES (26, 'Caja 90', NULL, '2019-10-04 11:37:26', '2019-10-04 11:37:26', 58, 12, NULL);
INSERT INTO public.cajas VALUES (19, 'Caja 08', 'caja principal', '2019-08-27 12:25:42', '2019-10-04 11:43:08', 58, 3, NULL);
INSERT INTO public.cajas VALUES (10, 'Caja 3', 'No tiene', '2019-08-26 17:44:42', '2019-10-04 11:48:14', 58, 9, NULL);
INSERT INTO public.cajas VALUES (25, 'Caja 56', NULL, '2019-10-04 11:36:53', '2019-10-04 11:51:45', 58, 3, '2019-10-04 11:51:45');
INSERT INTO public.cajas VALUES (24, 'Caja 23', 'no tiene', '2019-10-04 11:35:08', '2019-10-04 11:51:54', 58, 3, '2019-10-04 11:51:54');
INSERT INTO public.cajas VALUES (27, 'Caja Unica', NULL, '2019-10-05 19:46:04', '2019-10-05 19:46:04', 64, 15, NULL);
INSERT INTO public.cajas VALUES (28, 'Caja Unica', NULL, '2019-10-18 09:23:53', '2019-10-18 09:23:53', 66, 16, NULL);
INSERT INTO public.cajas VALUES (30, 'CajaDos', NULL, '2019-10-18 22:06:02', '2019-10-18 22:16:40', 67, 17, '2019-10-18 22:16:40');
INSERT INTO public.cajas VALUES (31, 'Cumbre', NULL, '2019-10-18 22:13:54', '2019-10-18 22:17:27', 67, 17, '2019-10-18 22:17:27');
INSERT INTO public.cajas VALUES (32, 'Secondary', NULL, '2019-10-18 22:16:08', '2019-10-18 22:17:31', 67, 17, '2019-10-18 22:17:31');
INSERT INTO public.cajas VALUES (33, 'asdfasdf', NULL, '2019-10-18 22:17:49', '2019-10-18 22:29:21', 67, 17, '2019-10-18 22:29:21');
INSERT INTO public.cajas VALUES (34, 'asdfasdf', NULL, '2019-10-18 22:21:00', '2019-10-18 22:29:24', 67, 17, '2019-10-18 22:29:24');
INSERT INTO public.cajas VALUES (36, 'Caja unica', NULL, '2019-11-26 09:25:15', '2019-11-26 09:25:15', 69, 21, NULL);
INSERT INTO public.cajas VALUES (37, 'Caja Unica 2', NULL, '2019-11-26 09:26:00', '2019-11-26 09:26:00', 69, 22, NULL);
INSERT INTO public.cajas VALUES (29, 'Caja - Sucursal Uno', NULL, '2019-10-18 18:05:40', '2020-01-24 09:50:55', 67, 17, NULL);
INSERT INTO public.cajas VALUES (35, 'Caja - Sucursal Dos', NULL, '2019-11-05 17:16:12', '2020-01-28 13:30:01', 67, 18, '2020-01-28 13:30:01');
INSERT INTO public.cajas VALUES (38, 'Caja principal', NULL, '2020-01-28 17:31:12', '2020-01-28 17:31:25', 67, 18, '2020-01-28 17:31:25');
INSERT INTO public.cajas VALUES (39, 'Caja principal', NULL, '2020-01-28 17:44:59', '2020-01-28 17:44:59', 67, 18, NULL);


--
-- TOC entry 4994 (class 0 OID 33068)
-- Dependencies: 220
-- Data for Name: cajeros; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.cajeros VALUES (104, 'Adamy', 'Nizeth', 'Huanca', NULL, NULL, 'adamy', NULL, '$2y$10$xpti7Q7zV.GNbmjgp4lb0ucJ7emHfYZnzKQ8v.OfXkslYQq03QBk2', '1980-01-24', false, NULL, '2019-10-22 16:21:03', '2020-01-24 18:21:15', '1', NULL, NULL, NULL, NULL, NULL, true, 24, 2500.00, NULL, 17, 67, 29);
INSERT INTO public.cajeros VALUES (71, 'Ramiro', 'Velasquez', NULL, '69978923', 'Av Zapata # 34', 'ramero1325', 'ramero1325@mail.com', '$2y$10$.wAfUm8NTUV7FDJYFlZ8pub8sNllXKWtXwaz09HEiiLgcEh3SOM7W', '1986-08-18', true, NULL, '2019-08-31 09:21:51', '2019-09-02 14:54:45', '1', NULL, NULL, '71245623', NULL, '2019-09-02 14:54:45', true, 6, 2500.00, NULL, 9, 58, 15);
INSERT INTO public.cajeros VALUES (77, 'Yesenia', 'Coyo', 'Fuentes', '966123510', 'Villa Dolores # 56', 'loca24', 'loca24@mail.com', '$2y$10$JUQbBSRH6/OGJ4afff3Oru1ckUvHQFGg3QNU5OzdPNPFJ0cEKJ76e', '1995-09-18', false, NULL, '2019-08-31 11:16:01', '2019-09-02 16:30:50', '1', NULL, NULL, '71245623', NULL, '2019-09-02 16:30:50', true, 9, 2600.00, NULL, 3, 58, 17);
INSERT INTO public.cajeros VALUES (78, 'Oscar', 'Cespedez1', 'Mamani1', '888777123', 'El Alto # 562', 'Osco322', 'osco242@mail.com', '$2y$10$t3Pwz9jRdX1QUudWjQYSZeKSGJqbNoTC3K4AfUp.s5jSVLJIqbs8i', '1987-06-06', true, NULL, '2019-08-31 22:59:21', '2019-09-02 16:33:37', '1', NULL, 'Santiago', '71145623', '2225489', '2019-09-02 16:33:37', true, 10, 2600.00, NULL, 3, 58, 10);
INSERT INTO public.cajeros VALUES (69, 'Yamil', 'Limachi', 'Llampas', '71142923', 'Av Montes # 34', 'Yamilo', 'yamil@mail.com', '$2y$10$q3Xxg1//QTgaKjsxVO42Tua.MI6IGq/IWzoIKtJzKjWEKBIHPHYcy', '1986-12-12', true, NULL, '2019-08-28 16:42:57', '2019-09-02 16:37:01', '1', NULL, NULL, '71245623', NULL, '2019-09-02 16:37:01', true, 5, 2000.00, '2019-08-18', 3, 58, 11);
INSERT INTO public.cajeros VALUES (79, 'Wendy', 'Vasquez', 'Fuentes', '99922213', 'Av Sao Paulo # 45', 'When', 'when24@mail.com', '$2y$10$9ip.LgnAF.smvXw/LyZ8jeCoqG.0TtVEyj70m1VetWGxKw5Ewz8D6', '1992-12-15', true, NULL, '2019-09-02 15:57:47', '2019-09-02 18:15:59', '1', NULL, 'Carla', '76212389', '22455621', NULL, true, 11, 2000.00, NULL, 9, 58, 12);
INSERT INTO public.cajeros VALUES (73, 'Rodrigo', 'Veldez', 'Oroza', '65412323', 'Villa Fatima # 34', 'rodro32', 'rodro32@mail.com', '$2y$10$7gEHkKZBMxSxrT8H7zupi.B8z/I5rgBain7VGQHtaM1nR5CPdRQY.', '1986-11-23', true, NULL, '2019-08-31 10:56:11', '2019-09-03 10:38:55', '1', NULL, 'Xavier', '71122345', NULL, NULL, true, 8, 2600.50, NULL, 9, 58, 14);
INSERT INTO public.cajeros VALUES (72, 'Juan', 'Velasquez', 'Fernandez', '66881123', 'Av. Vasques # 34', 'Javier22', 'javier_22@mail.com', '$2y$10$ElZ34m0oRlXja4k6fto5TO3w6jNDjoS/cfyjLKAuA7K1t3U.j6AUu', '1988-07-29', true, NULL, '2019-08-31 10:49:46', '2019-10-02 10:33:27', '1', NULL, 'Javier', '71245623', NULL, '2019-10-02 10:33:27', true, 7, 1500.00, NULL, 9, 58, 15);
INSERT INTO public.cajeros VALUES (85, 'Valentino', 'flores', 'gonzales', '65478922', 'tejada', 'valerio45', 'valerio45@mail.com', '$2y$10$mQmIEIyLZJEP0296LWouWOWMGfGjmJnTFCz2W76MU64iD3WbkVO76', '1970-08-12', true, NULL, '2019-10-04 12:34:38', '2019-10-04 12:40:09', '1', NULL, NULL, '71245623', '2456589', NULL, true, 15, 2000.00, NULL, 9, 58, 14);
INSERT INTO public.cajeros VALUES (81, 'Pato', 'Bolaños', 'Gomez', '9845235', 'Villa fatima # 46', 'Pato', 'pato@mail.com', '$2y$10$xlP9rzba1jtssivgfrVo8.tZmlwAv2niCFoQPf1LDsSa4krasQrT2', '1986-11-23', true, NULL, '2019-09-02 22:48:58', '2019-10-04 12:41:57', '1', NULL, NULL, '71245623', '2568912', '2019-10-04 12:41:57', true, 12, 3000.00, NULL, 14, 58, 22);
INSERT INTO public.cajeros VALUES (91, 'Boris', 'Velasco', NULL, '65478988', 'Av sagarnaga 54', 'boris_caja', 'boris_caja@mail.com', '$2y$10$PKMw5LSxKwQ7YUUj2k2lfO2EDS2OylhswZUO4OUh6J.Rb2c2VM1D.', '1975-11-12', false, NULL, '2019-10-05 19:48:50', '2019-10-05 19:48:50', '1', NULL, NULL, NULL, '2223171', NULL, true, 17, 2500.00, NULL, 15, 64, 27);
INSERT INTO public.cajeros VALUES (101, 'asdfasdf', 'asdfasdf', 'asdfasd', '9878745', 'asdfasdfa', 'asdfasdf88', 'asdfasdf88@mail.com', '$2y$10$CntcThmUbfvfcKuJPxAn1uErst3x8ikSmrcaRTeVUVi7Y/I2VK6Zy', '1990-12-12', true, NULL, '2019-10-18 23:35:17', '2019-10-19 20:49:31', '1', NULL, NULL, '78945623', NULL, '2019-10-19 20:49:31', true, 22, 1600.00, NULL, 17, 67, 29);
INSERT INTO public.cajeros VALUES (102, 'sdasdf', 'asdfasdf', 'asdfasdf', '98745629', 'asdfasdf', 'asdfads78985', 'asdfads78985@gmail.com', '$2y$10$/5go1.CeentRcrJd.r.ske0t7G/jxSye.zSgKkHQQoJ1zgZ8whWSa', '2019-10-10', true, NULL, '2019-10-19 20:50:47', '2019-10-22 16:15:41', '1', NULL, 'asdfas', '71245689', NULL, '2019-10-22 16:15:41', true, 23, 1600.00, NULL, 17, 67, 29);
INSERT INTO public.cajeros VALUES (100, 'asdfasdf', 'asdfasdf', NULL, '987854654', 'asdfasdf', 'asdfadsf45', 'asdfadsf45@mail.com', '$2y$10$dSiyXYsW63kE0Vpt4vrNDuf8fLupTqHn7pNjXjDLAFCeo00nVmugm', '1987-12-12', false, NULL, '2019-10-18 23:34:09', '2019-10-22 16:15:45', '1', NULL, NULL, '71264569', NULL, '2019-10-22 16:15:45', true, 21, 1500.00, NULL, 17, 67, 29);
INSERT INTO public.cajeros VALUES (82, 'Lenny', 'Ortiz', 'Rocha', '6661235', 'av monje # 25', 'leslie', 'leslie@mail.com', '$2y$10$3fapfavGA1Ic/ByLxwg1geoWioDKcgdYs9RhMOb5Zd.3EQYk8jM/6', '1988-07-29', false, NULL, '2019-09-17 12:17:57', '2019-10-10 17:35:08', '1', NULL, 'Claudia', '71245689', '2458923', NULL, true, 13, 2600.00, NULL, 3, 58, 11);
INSERT INTO public.cajeros VALUES (83, 'Yamil', 'Vargas', 'Limachi', '6547892', 'Av Sanchez 65', 'yami99', 'yami99@mail.com', '$2y$10$/0YklQikBFVTinKhV27cdeoEL7I5slTyF5d1sRppqzFX4lblaTSf6', '1990-12-12', true, NULL, '2019-10-02 17:51:27', '2019-10-17 18:02:16', '1', NULL, NULL, '71245689', NULL, '2019-10-17 18:02:16', true, 14, 2500.00, NULL, 3, 58, 19);
INSERT INTO public.cajeros VALUES (88, 'Ximena', 'Linares', NULL, '987882', 'asdfasdfa', 'soprano', 'soprano@mail.com', '$2y$10$nnIlgiRUQ0UY2U.blMwkA.7xBQBlU/frgyJeQnKJ4CPAXDk3lXnmm', '1992-12-12', false, NULL, '2019-10-05 12:29:08', '2019-10-17 18:02:36', '1', NULL, NULL, NULL, '2223171', NULL, true, 16, 2500.00, NULL, 3, 58, 11);
INSERT INTO public.cajeros VALUES (94, 'Adriana', 'Gamboa', 'Limachi', '97887895', 'Av Castro Gutierrez # 56', 'adri', 'adri@gmail.com', '$2y$10$roprgENhxcCb27RDUYo9.e6K2ImZdVzV3iiVRYPHfmoVLMCarIpgi', '1986-08-18', false, NULL, '2019-10-18 09:26:24', '2019-10-18 09:26:24', '1', NULL, NULL, '7892315', '71245632', NULL, true, 18, 1500.00, NULL, 16, 66, 28);
INSERT INTO public.cajeros VALUES (113, 'Rodrigo', 'Valdez', 'Oroza', '9874568', NULL, 'rvaldez', 'rvaldez@mail.com', '$2y$10$Mq9QdZSgfD39HmuiLR0jjuq6te.fH3NKoZO.p2noxXu8.kygIUzKW', '1987-12-15', true, NULL, '2019-11-26 09:53:20', '2019-11-26 09:53:20', '1', NULL, NULL, '71245689', NULL, NULL, true, 26, 2500.00, NULL, 21, 69, 36);
INSERT INTO public.cajeros VALUES (114, 'Edgar', 'Paza', 'Leyton', '9872226', NULL, 'epaz', 'epaz@mail.com', '$2y$10$/cUAdmPQJMGxiwUr7gujT.CjJr5DRPgGSbIQSJTPSnrTdBg64BkN2', '1987-10-11', true, NULL, '2019-11-26 09:55:19', '2019-11-26 09:55:19', '1', NULL, NULL, '71245689', NULL, NULL, true, 27, 2500.00, NULL, 22, 69, 37);
INSERT INTO public.cajeros VALUES (117, 'Juan', 'Vargas', 'Velasques', NULL, NULL, 'jvelasquez', 'jvelasquez@gmail.com', '$2y$10$qt3W7z.RvL./vgoxwenwQOfs7ri/rlHmDKF.MGlIczJcpAJSpk3SS', '1984-01-08', true, NULL, '2020-01-28 17:47:25', '2020-01-28 17:47:53', '1', NULL, NULL, NULL, NULL, NULL, false, 28, 1400.00, NULL, 18, 67, 39);
INSERT INTO public.cajeros VALUES (118, 'Juan', 'Vargas', 'Orozco', NULL, NULL, 'jcarlosv', NULL, '$2y$10$0UULo7PAaPQZWzdXPU6MLe3D2UVzwe.XuRHlFV7j.pEcZQVB4nGhi', '1980-01-14', true, NULL, '2020-01-28 19:58:55', '2020-01-28 19:58:55', '1', NULL, 'Carlos', NULL, NULL, NULL, true, 29, 2500.00, NULL, 17, 67, 29);
INSERT INTO public.cajeros VALUES (99, 'Yasmani', 'Velasque', NULL, '679878975', 'asdfasdf', 'yass', 'yasi@mail.com', '$2y$10$9PnBhRMV.vS8XGP6eaXBjedc4PrzIdJ62aDYGhxRqGNgNx8hBwOqu', '1990-12-12', true, NULL, '2019-10-18 23:32:23', '2019-12-05 18:39:50', '1', NULL, NULL, '71245699', NULL, NULL, false, 20, 1500.00, NULL, 17, 67, 29);
INSERT INTO public.cajeros VALUES (97, 'Jonathan', 'Gareca', 'Pacajes', '98745622', 'Av Las Americas', 'yonice', 'yonice@mail.com', '$2y$10$huJQb12nQqMACcR/GlBWruETorxU09W/ls97PYD9Ez0GVhC0Lvsdi', '1990-04-21', true, NULL, '2019-10-18 18:07:55', '2019-12-06 17:34:40', '1', NULL, NULL, '71238822', NULL, NULL, true, 19, 1500.00, NULL, 17, 67, 29);
INSERT INTO public.cajeros VALUES (107, 'Alberto', 'Cuevas', 'Monzon', '1245629', NULL, 'Beto', 'beto@mail.com', '$2y$10$j2m4ghMcAUVATEMYMLyUm.Fyv6KGb175SE8uJMCT9IZ83hKkJqGze', NULL, true, NULL, '2019-11-05 17:19:30', '2020-01-28 13:23:58', '1', NULL, 'Juan', '7124562', NULL, '2020-01-28 13:23:58', true, 25, 1600.00, NULL, 18, 67, 35);


--
-- TOC entry 4995 (class 0 OID 33073)
-- Dependencies: 221
-- Data for Name: categoria_productos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.categoria_productos VALUES (16, 'Diversidad de pollos', NULL, NULL, 31, 58, '2019-09-20 08:09:17', '2019-10-03 12:05:46', '2019-10-03 12:05:46');
INSERT INTO public.categoria_productos VALUES (10, 'Cocina Caliente', 'Platos tipicos del Peru', NULL, 31, 58, '2019-09-03 09:26:19', '2019-10-03 12:10:44', '2019-10-03 12:10:44');
INSERT INTO public.categoria_productos VALUES (22, 'salsas', NULL, NULL, 31, 58, '2019-10-04 13:07:28', '2019-10-04 13:07:34', '2019-10-04 13:07:34');
INSERT INTO public.categoria_productos VALUES (21, 'Comida rapida', 'no tiene', NULL, 31, 58, '2019-10-03 10:52:45', '2019-10-04 14:21:56', NULL);
INSERT INTO public.categoria_productos VALUES (20, 'Bebidas alcoholicas', 'solo sirven por las noches', NULL, 31, 58, '2019-10-03 10:50:39', '2019-10-04 14:22:15', NULL);
INSERT INTO public.categoria_productos VALUES (23, 'Ensalada', NULL, NULL, 31, 58, '2019-10-04 14:21:44', '2019-10-04 14:22:39', '2019-10-04 14:22:39');
INSERT INTO public.categoria_productos VALUES (24, 'Pollos', NULL, NULL, 38, 64, '2019-10-05 19:52:18', '2019-10-05 19:52:18', NULL);
INSERT INTO public.categoria_productos VALUES (25, 'Gaseosas', NULL, NULL, 38, 64, '2019-10-05 19:52:29', '2019-10-05 19:52:29', NULL);
INSERT INTO public.categoria_productos VALUES (26, 'Bebidas', NULL, NULL, 41, 66, '2019-10-18 09:29:59', '2019-10-18 09:29:59', NULL);
INSERT INTO public.categoria_productos VALUES (27, 'Platos', NULL, NULL, 41, 66, '2019-10-18 09:30:14', '2019-10-18 09:30:14', NULL);
INSERT INTO public.categoria_productos VALUES (9, 'Postres', 'tortas, gelatinas, etc, etc, etc', NULL, 31, 58, '2019-09-03 09:03:32', '2019-09-14 20:18:38', NULL);
INSERT INTO public.categoria_productos VALUES (11, 'Jugos', 'solo jugos naturales', NULL, 31, 58, '2019-09-03 09:26:55', '2019-09-17 06:57:17', NULL);
INSERT INTO public.categoria_productos VALUES (12, 'Desayunos', NULL, NULL, 31, 58, '2019-09-14 20:14:45', '2019-09-17 08:46:42', '2019-09-17 08:46:42');
INSERT INTO public.categoria_productos VALUES (6, 'Cocina Caliente', 'Solo platos al horno', NULL, 31, 58, '2019-09-03 08:27:48', '2019-09-17 08:47:08', '2019-09-17 08:47:08');
INSERT INTO public.categoria_productos VALUES (5, 'Bebidas', 'asdfadf', NULL, 31, 58, '2019-09-03 08:27:16', '2019-09-17 08:47:13', '2019-09-17 08:47:13');
INSERT INTO public.categoria_productos VALUES (4, 'Bebidas', 'bebidas calientes', NULL, 31, 58, '2019-09-02 22:52:05', '2019-09-17 08:47:18', '2019-09-17 08:47:18');
INSERT INTO public.categoria_productos VALUES (3, 'Bebidas', 'Bebidas Gaseosas y jugos', NULL, 31, 58, '2019-09-02 22:30:36', '2019-09-17 08:47:22', '2019-09-17 08:47:22');
INSERT INTO public.categoria_productos VALUES (13, 'Desayunos', NULL, NULL, 31, 58, '2019-09-20 08:08:29', '2019-09-20 08:08:29', NULL);
INSERT INTO public.categoria_productos VALUES (14, 'Platos tropicales', NULL, NULL, 31, 58, '2019-09-20 08:08:43', '2019-09-20 08:08:43', NULL);
INSERT INTO public.categoria_productos VALUES (17, 'Gaseosas', NULL, NULL, 31, 58, '2019-10-02 11:55:21', '2019-10-02 11:55:21', NULL);
INSERT INTO public.categoria_productos VALUES (18, 'Platos especiales', NULL, NULL, 31, 58, '2019-10-02 12:07:48', '2019-10-02 12:07:48', NULL);
INSERT INTO public.categoria_productos VALUES (19, 'Bebidas calientes', NULL, NULL, 31, 58, '2019-10-02 12:08:38', '2019-10-02 12:08:38', NULL);
INSERT INTO public.categoria_productos VALUES (8, 'Bar Abierto', 'Bebidas alcoholicas', NULL, 31, 58, '2019-09-03 08:30:02', '2019-10-03 10:48:15', '2019-10-03 10:48:15');
INSERT INTO public.categoria_productos VALUES (7, 'Cocina Fria', 'Postres y demas variedades', NULL, 31, 58, '2019-09-03 08:29:29', '2019-10-03 10:51:24', '2019-10-03 10:51:24');
INSERT INTO public.categoria_productos VALUES (15, 'Comida al vapor', NULL, NULL, 31, 58, '2019-09-20 08:09:00', '2019-10-03 10:52:05', '2019-10-03 10:52:05');
INSERT INTO public.categoria_productos VALUES (32, 'Jugos Naturales', NULL, NULL, 44, 69, '2019-11-26 10:03:44', '2019-11-26 10:03:44', NULL);
INSERT INTO public.categoria_productos VALUES (33, 'Platos especiales', NULL, NULL, 44, 69, '2019-11-26 10:03:53', '2019-11-26 10:03:53', NULL);
INSERT INTO public.categoria_productos VALUES (34, 'Gaseosas', NULL, NULL, 44, 69, '2019-11-26 10:04:00', '2019-11-26 10:04:00', NULL);
INSERT INTO public.categoria_productos VALUES (35, 'Postres', NULL, NULL, 44, 69, '2019-11-26 10:04:07', '2019-11-26 10:04:07', NULL);
INSERT INTO public.categoria_productos VALUES (36, 'Bebidas alcoholicas', NULL, NULL, 44, 69, '2019-11-26 10:04:28', '2019-11-26 10:04:28', NULL);
INSERT INTO public.categoria_productos VALUES (37, 'Almuerzos', NULL, NULL, 44, 69, '2019-11-26 10:04:45', '2019-11-26 10:04:45', NULL);
INSERT INTO public.categoria_productos VALUES (40, 'Bebidas alcoholicas', NULL, NULL, 42, 67, '2019-12-08 21:23:28', '2019-12-08 21:23:28', NULL);
INSERT INTO public.categoria_productos VALUES (29, 'Gaseosas', NULL, NULL, 42, 67, '2019-10-18 18:11:40', '2020-01-24 10:03:32', NULL);
INSERT INTO public.categoria_productos VALUES (41, 'Jugos naturales', NULL, NULL, 42, 67, '2020-01-24 10:04:32', '2020-01-24 10:04:32', NULL);
INSERT INTO public.categoria_productos VALUES (31, 'Comida rapida', NULL, NULL, 42, 67, '2019-11-17 23:47:22', '2020-01-24 10:05:41', '2020-01-24 10:05:41');
INSERT INTO public.categoria_productos VALUES (38, 'Almuerzos', NULL, NULL, 42, 67, '2019-11-29 12:33:22', '2020-01-24 10:06:40', '2020-01-24 10:06:40');
INSERT INTO public.categoria_productos VALUES (30, 'Postres', 'Solo se sirve por la tarde', NULL, 42, 67, '2019-10-22 15:23:40', '2020-01-24 10:06:44', '2020-01-24 10:06:44');
INSERT INTO public.categoria_productos VALUES (39, 'Parrilla', NULL, NULL, 42, 67, '2019-11-29 16:16:23', '2020-01-24 10:06:52', '2020-01-24 10:06:52');
INSERT INTO public.categoria_productos VALUES (28, 'Platos especiales', NULL, NULL, 42, 67, '2019-10-18 18:11:27', '2020-01-28 15:20:05', NULL);
INSERT INTO public.categoria_productos VALUES (42, 'Platos tradicionales', NULL, NULL, 42, 67, '2020-01-28 17:48:46', '2020-01-28 17:48:46', NULL);
INSERT INTO public.categoria_productos VALUES (43, 'Postres', 'solo se sirve por la tarde', NULL, 42, 67, '2020-01-28 19:59:54', '2020-01-28 20:00:22', NULL);


--
-- TOC entry 4997 (class 0 OID 33079)
-- Dependencies: 223
-- Data for Name: clientes; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.clientes VALUES (2, 'Maria nuñez', '4796512', NULL, '2019-09-23 15:42:33', '2019-09-23 15:42:33', NULL, 31);
INSERT INTO public.clientes VALUES (3, 'Fernanda Martinez', '4569826', NULL, '2019-09-23 15:44:16', '2019-09-23 15:44:16', NULL, 31);
INSERT INTO public.clientes VALUES (1, 'Juan Valdez', '4792527 LP', NULL, '2019-09-23 15:40:49', '2019-09-23 15:40:49', NULL, 31);
INSERT INTO public.clientes VALUES (4, 'pedro carlos', '9874562', 13, '2019-09-24 07:23:43', '2019-09-24 07:23:43', NULL, 31);
INSERT INTO public.clientes VALUES (5, '11155', 'asdfasdfasdfasdf', 13, '2019-09-24 07:53:43', '2019-09-24 07:53:43', NULL, 31);
INSERT INTO public.clientes VALUES (6, 'pedro fernandez', '9998882', 13, '2019-09-24 08:00:18', '2019-09-24 08:00:18', NULL, 31);
INSERT INTO public.clientes VALUES (7, 'Juan Valdez', '4792527 lp', 13, '2019-09-24 08:33:44', '2019-09-24 08:33:44', NULL, 31);
INSERT INTO public.clientes VALUES (8, 'Fuentes Velasquez', '132554', 13, '2019-09-24 09:34:01', '2019-09-24 09:34:01', NULL, 31);
INSERT INTO public.clientes VALUES (9, 'vargas johnny', '798556', 13, '2019-09-24 09:35:29', '2019-09-24 09:35:29', NULL, 31);
INSERT INTO public.clientes VALUES (10, 'Juan Valdez', '4792527 SC', 13, '2019-09-24 09:38:51', '2019-09-24 09:38:51', NULL, 31);
INSERT INTO public.clientes VALUES (11, 'pedro carlos', '98745627', 13, '2019-09-24 09:40:24', '2019-09-24 09:40:24', NULL, 31);
INSERT INTO public.clientes VALUES (12, 'pedro fernandez', '999888272', 13, '2019-09-24 09:40:51', '2019-09-24 09:40:51', NULL, 31);
INSERT INTO public.clientes VALUES (13, 'pedro carlos', '98745627123', 13, '2019-09-24 11:13:20', '2019-09-24 11:13:20', NULL, 31);
INSERT INTO public.clientes VALUES (14, 'pedro carlos', '98745621325', 13, '2019-09-24 12:16:21', '2019-09-24 12:16:21', NULL, 31);
INSERT INTO public.clientes VALUES (15, 'pedro carlos', '98745621325987', 13, '2019-09-24 12:20:28', '2019-09-24 12:20:28', NULL, 31);
INSERT INTO public.clientes VALUES (16, 'Juan Valdez', '4792527 TJA', 13, '2019-09-24 12:23:44', '2019-09-24 12:23:44', NULL, 31);
INSERT INTO public.clientes VALUES (17, 'pedro fernandez', '99988821325', 13, '2019-09-24 12:32:47', '2019-09-24 12:32:47', NULL, 31);
INSERT INTO public.clientes VALUES (18, 'Juan Valdez', '47925279 LP', 13, '2019-09-24 12:34:35', '2019-09-24 12:34:35', NULL, 31);
INSERT INTO public.clientes VALUES (19, 'Juan Valdez', '4792527889 LP', 13, '2019-09-24 16:34:44', '2019-09-24 16:34:44', NULL, 31);
INSERT INTO public.clientes VALUES (20, 'Juan Valdez', '47925278891231 LP', 13, '2019-09-24 16:37:56', '2019-09-24 16:37:56', NULL, 31);
INSERT INTO public.clientes VALUES (21, 'Juan Valdez', '47925278891231 aa', 13, '2019-09-24 16:40:34', '2019-09-24 16:40:34', NULL, 31);
INSERT INTO public.clientes VALUES (22, 'Fernanda Martinez', '45698261325', 13, '2019-09-24 16:41:11', '2019-09-24 16:41:11', NULL, 31);
INSERT INTO public.clientes VALUES (23, 'Juan Valdez', '4792527014 lp', 13, '2019-09-24 16:53:04', '2019-09-24 16:53:04', NULL, 31);
INSERT INTO public.clientes VALUES (24, 'vargas johnny', '798556 lp', 13, '2019-09-24 16:55:04', '2019-09-24 16:55:04', NULL, 31);
INSERT INTO public.clientes VALUES (25, 'Juan Valdez', '4792527224 LP', 13, '2019-09-24 17:14:17', '2019-09-24 17:14:17', NULL, 31);
INSERT INTO public.clientes VALUES (26, 'vargas johnny', '7985561325', 13, '2019-09-24 17:22:34', '2019-09-24 17:22:34', NULL, 31);
INSERT INTO public.clientes VALUES (27, 'pedro carlos', '98745627985', 13, '2019-09-24 17:27:02', '2019-09-24 17:27:02', NULL, 31);
INSERT INTO public.clientes VALUES (28, 'pedro carlos', '987456279851325', 13, '2019-09-24 17:28:43', '2019-09-24 17:28:43', NULL, 31);
INSERT INTO public.clientes VALUES (29, 'Juan Valdez', '4792527 TiA', 13, '2019-09-24 21:16:45', '2019-09-24 21:16:45', NULL, 31);
INSERT INTO public.clientes VALUES (30, 'pedro carlos', '987456279856', 13, '2019-09-24 21:21:19', '2019-09-24 21:21:19', NULL, 31);
INSERT INTO public.clientes VALUES (31, 'pedro carlos', '98745627985688', 13, '2019-09-24 21:23:36', '2019-09-24 21:23:36', NULL, 31);
INSERT INTO public.clientes VALUES (32, 'pedro carlos', '987456271237985', 13, '2019-09-24 21:29:25', '2019-09-24 21:29:25', NULL, 31);
INSERT INTO public.clientes VALUES (33, 'vargas johnny', '79855613257985', 13, '2019-09-24 21:42:32', '2019-09-24 21:42:32', NULL, 31);
INSERT INTO public.clientes VALUES (34, 'Fernanda Martinez', '456982613257985', 13, '2019-09-24 21:52:14', '2019-09-24 21:52:14', NULL, 31);
INSERT INTO public.clientes VALUES (35, 'pedro carlos', '98745627123798', 13, '2019-09-24 21:57:04', '2019-09-24 21:57:04', NULL, 31);
INSERT INTO public.clientes VALUES (36, 'Juan Valdez', '4792527 SCZ', 13, '2019-09-25 13:19:58', '2019-09-25 13:19:58', NULL, 31);
INSERT INTO public.clientes VALUES (37, 'pedro fernandez', '9998882132554', 13, '2019-09-25 18:08:50', '2019-09-25 18:08:50', NULL, 31);
INSERT INTO public.clientes VALUES (38, 'vargas johnny', '79855645678', 13, '2019-09-25 18:25:45', '2019-09-25 18:25:45', NULL, 31);
INSERT INTO public.clientes VALUES (39, 'vargas johnny', '7985567985', 13, '2019-09-25 18:33:20', '2019-09-25 18:33:20', NULL, 31);
INSERT INTO public.clientes VALUES (40, 'Juan Valdez', '4792527 LP-SCZ', 13, '2019-09-26 09:08:07', '2019-09-26 09:08:07', NULL, 31);
INSERT INTO public.clientes VALUES (41, 'Juan Valdez', '4792527 lp-cbba', 13, '2019-09-26 09:41:39', '2019-09-26 09:41:39', NULL, 31);
INSERT INTO public.clientes VALUES (42, 'Juan Valdez', '4792527014 lp-scz', 13, '2019-09-26 12:29:23', '2019-09-26 12:29:23', NULL, 31);
INSERT INTO public.clientes VALUES (43, 'pedro fernandez', '999888274562', 13, '2019-09-26 12:40:02', '2019-09-26 12:40:02', NULL, 31);
INSERT INTO public.clientes VALUES (44, 'pedro carlos', '987456271231325', 13, '2019-09-26 12:46:35', '2019-09-26 12:46:35', NULL, 31);
INSERT INTO public.clientes VALUES (45, 'Juan Valdez', '4792527 LP8797', 13, '2019-09-26 12:48:07', '2019-09-26 12:48:07', NULL, 31);
INSERT INTO public.clientes VALUES (46, 'vargas johnny', '798556132554', 13, '2019-09-26 12:51:09', '2019-09-26 12:51:09', NULL, 31);
INSERT INTO public.clientes VALUES (47, 'vargas johnny', '7985561325547', 13, '2019-09-26 13:04:46', '2019-09-26 13:04:46', NULL, 31);
INSERT INTO public.clientes VALUES (48, 'Vargas chila', '4792527487 lp', 13, '2019-09-26 13:07:53', '2019-09-26 13:07:53', NULL, 31);
INSERT INTO public.clientes VALUES (49, 'Vargas chila', '47925274871325 lp', 13, '2019-09-26 13:09:20', '2019-09-26 13:09:20', NULL, 31);
INSERT INTO public.clientes VALUES (50, 'Vargas chila', '4792527487132598 lp', 13, '2019-09-26 13:10:36', '2019-09-26 13:10:36', NULL, 31);
INSERT INTO public.clientes VALUES (51, 'Vargas chila', '479252748713259812 lp', 13, '2019-09-26 13:20:13', '2019-09-26 13:20:13', NULL, 31);
INSERT INTO public.clientes VALUES (52, 'Vargas chila', '47925274871325981122 lp', 13, '2019-09-26 13:21:16', '2019-09-26 13:21:16', NULL, 31);
INSERT INTO public.clientes VALUES (53, 'Vargas chila', '479252748713259811221231 lp', 13, '2019-09-26 13:23:03', '2019-09-26 13:23:03', NULL, 31);
INSERT INTO public.clientes VALUES (54, 'Vargas chila', '47921252748713259811221231 lp', 13, '2019-09-26 13:24:15', '2019-09-26 13:24:15', NULL, 31);
INSERT INTO public.clientes VALUES (55, 'vargas johnny', '79855679855', 13, '2019-09-26 15:36:58', '2019-09-26 15:36:58', NULL, 31);
INSERT INTO public.clientes VALUES (56, 'vargas johnny chila', '79855679855chila', 13, '2019-09-26 15:38:52', '2019-09-26 15:38:52', NULL, 31);
INSERT INTO public.clientes VALUES (57, 'pedro carlos', '98745627987', 13, '2019-09-26 15:40:18', '2019-09-26 15:40:18', NULL, 31);
INSERT INTO public.clientes VALUES (58, 'Juan Valdez', '4792527 SCasdfa', 13, '2019-09-26 15:43:33', '2019-09-26 15:43:33', NULL, 31);
INSERT INTO public.clientes VALUES (59, 'pedro carlos', '9874562asdasd', 13, '2019-09-26 16:10:27', '2019-09-26 16:10:27', NULL, 31);
INSERT INTO public.clientes VALUES (60, 'Fuentes Velasquez', '13255479921', 13, '2019-09-26 16:26:05', '2019-09-26 16:26:05', NULL, 31);
INSERT INTO public.clientes VALUES (61, 'Juan Valdez', '4792527 LPasdfasdfasd', 13, '2019-09-26 16:45:11', '2019-09-26 16:45:11', NULL, 31);
INSERT INTO public.clientes VALUES (62, 'Juan Valdez', '4792527 LPasdfasdfasdas', 13, '2019-09-26 16:45:52', '2019-09-26 16:45:52', NULL, 31);
INSERT INTO public.clientes VALUES (63, 'Juan Valdez', '4792527 LPasdfasdfasdasas', 13, '2019-09-26 17:20:50', '2019-09-26 17:20:50', NULL, 31);
INSERT INTO public.clientes VALUES (64, 'Juan Valdez', '4792527 LPasdfasdfasdasas1325', 13, '2019-09-26 17:21:37', '2019-09-26 17:21:37', NULL, 31);
INSERT INTO public.clientes VALUES (65, 'Juan Valdez', '13255479856', 13, '2019-09-26 17:22:05', '2019-09-26 17:22:05', NULL, 31);
INSERT INTO public.clientes VALUES (66, 'Juan Valdez', '13255479856 asdasd', 13, '2019-09-26 17:22:52', '2019-09-26 17:22:52', NULL, 31);
INSERT INTO public.clientes VALUES (67, 'Juan Valdez', '7775551112254984756', 13, '2019-09-26 17:23:28', '2019-09-26 17:23:28', NULL, 31);
INSERT INTO public.clientes VALUES (68, 'Juan Valdez', '7775551112254984756asdfasdfasdf', 13, '2019-09-26 17:23:50', '2019-09-26 17:23:50', NULL, 31);
INSERT INTO public.clientes VALUES (69, 'Fernanda Martinez', '45698261325hola', 13, '2019-09-26 17:29:11', '2019-09-26 17:29:11', NULL, 31);
INSERT INTO public.clientes VALUES (70, 'pedro carlos', '987456212341231423421', 13, '2019-09-26 17:32:17', '2019-09-26 17:32:17', NULL, 31);
INSERT INTO public.clientes VALUES (71, 'Fuentes Velasquez', '1325549875452', 13, '2019-09-26 17:34:28', '2019-09-26 17:34:28', NULL, 31);
INSERT INTO public.clientes VALUES (72, 'Juan Valdez', '4792527 LPasdfasdfasdasas1325 548', 13, '2019-09-26 17:40:17', '2019-09-26 17:40:17', NULL, 31);
INSERT INTO public.clientes VALUES (73, 'melania trum', '666132564', 13, '2019-09-26 18:14:00', '2019-09-26 18:14:00', NULL, 31);
INSERT INTO public.clientes VALUES (74, 'Vargas Yamil', '79814562', 13, '2019-09-26 18:18:02', '2019-09-26 18:18:02', NULL, 31);
INSERT INTO public.clientes VALUES (75, 'Vargas Yamil', '7981456212', 13, '2019-09-26 18:18:57', '2019-09-26 18:18:57', NULL, 31);
INSERT INTO public.clientes VALUES (76, 'Maria nuñez', '4796512lñ', 13, '2019-09-26 22:21:54', '2019-09-26 22:21:54', NULL, 31);
INSERT INTO public.clientes VALUES (77, 'vargas peres ramiro', '79612345aa', 13, '2019-09-26 22:23:46', '2019-09-26 22:23:46', NULL, 31);
INSERT INTO public.clientes VALUES (78, 'vargas vegas jordyu', '95412356', 13, '2019-09-26 22:38:20', '2019-09-26 22:38:20', NULL, 31);
INSERT INTO public.clientes VALUES (79, 'Donald Trum', '66666666666666', 13, '2019-09-26 22:43:13', '2019-09-26 22:43:13', NULL, 31);
INSERT INTO public.clientes VALUES (80, 'vargas fabii', '65498794987', 13, '2019-09-26 23:02:54', '2019-09-26 23:02:54', NULL, 31);
INSERT INTO public.clientes VALUES (81, 'vargas velasquez yamil', '789456123', 13, '2019-09-30 18:42:30', '2019-09-30 18:42:30', NULL, 31);
INSERT INTO public.clientes VALUES (82, 'yamil limachi', '69978923', 13, '2019-09-30 21:48:24', '2019-09-30 21:48:24', NULL, 31);
INSERT INTO public.clientes VALUES (83, 'velasquez limachi yamil', '644123554', 13, '2019-10-01 18:50:25', '2019-10-01 18:50:25', NULL, 31);
INSERT INTO public.clientes VALUES (84, 'sergio martinez', '4567895', 13, '2019-10-02 09:59:11', '2019-10-02 09:59:11', NULL, 31);
INSERT INTO public.clientes VALUES (85, 'Vargas Limachi', '6547892', 13, '2019-10-03 10:01:40', '2019-10-03 10:01:40', NULL, 31);
INSERT INTO public.clientes VALUES (86, 'Calderon Fabiola', '99978926', 13, '2019-10-03 10:31:07', '2019-10-03 10:31:07', NULL, 31);
INSERT INTO public.clientes VALUES (87, 'Isabel Paravicini', '68715689', 13, '2019-10-03 12:25:49', '2019-10-03 12:25:49', NULL, 31);
INSERT INTO public.clientes VALUES (88, 'Carmelo Antony', '1111456789', 13, '2019-10-03 12:27:59', '2019-10-03 12:27:59', NULL, 31);
INSERT INTO public.clientes VALUES (89, 'Vilar', '9874652', 13, '2019-10-03 12:33:26', '2019-10-03 12:33:26', NULL, 31);
INSERT INTO public.clientes VALUES (90, 'Tania Fuentes', '6547892 LP', 13, '2019-10-03 17:26:44', '2019-10-03 17:26:44', NULL, 31);
INSERT INTO public.clientes VALUES (91, 'ramos', '65478924', 13, '2019-10-03 18:06:29', '2019-10-03 18:06:29', NULL, 31);
INSERT INTO public.clientes VALUES (92, 'valasco boris', '98745629', 13, '2019-10-03 18:08:48', '2019-10-03 18:08:48', NULL, 31);
INSERT INTO public.clientes VALUES (93, 'linares ximena', '9991325', 13, '2019-10-04 09:53:43', '2019-10-04 09:53:43', NULL, 31);
INSERT INTO public.clientes VALUES (94, 'fuente daniel', '98745622', NULL, '2019-10-05 08:42:09', '2019-10-05 08:42:09', 8, 31);
INSERT INTO public.clientes VALUES (95, 'cespedez oscar', '67891234', 13, '2019-10-05 09:36:35', '2019-10-05 09:36:35', NULL, 31);
INSERT INTO public.clientes VALUES (96, 'valverde daniela', '612345678', NULL, '2019-10-05 09:37:30', '2019-10-05 09:37:30', 8, 31);
INSERT INTO public.clientes VALUES (97, 'Ramiro Flores', '78945245', 17, '2019-10-05 19:57:41', '2019-10-05 19:57:41', NULL, 38);
INSERT INTO public.clientes VALUES (98, 'Lorenzo', '999132554', NULL, '2019-10-05 19:58:50', '2019-10-05 19:58:50', 9, 38);
INSERT INTO public.clientes VALUES (99, 'Valverde Daniela', '6547895', 17, '2019-10-05 20:02:26', '2019-10-05 20:02:26', NULL, 38);
INSERT INTO public.clientes VALUES (100, 'valasco', '987456227', NULL, '2019-10-05 20:18:07', '2019-10-05 20:18:07', 9, 38);
INSERT INTO public.clientes VALUES (101, 'fabiola zalles', '7894562', NULL, '2019-10-12 10:41:45', '2019-10-12 10:41:45', 8, 31);
INSERT INTO public.clientes VALUES (102, 'hugo banzer suarez', '6987456', 13, '2019-10-14 09:44:31', '2019-10-14 09:44:31', NULL, 31);
INSERT INTO public.clientes VALUES (103, 'velasquez odon marcelo', '98745655', 13, '2019-10-14 13:03:07', '2019-10-14 13:03:07', NULL, 31);
INSERT INTO public.clientes VALUES (104, 'Fuente Vanina', '64879224', 18, '2019-10-18 09:36:33', '2019-10-18 09:36:33', NULL, 41);
INSERT INTO public.clientes VALUES (105, 'Yandira Limachi', '987897546', NULL, '2019-10-18 10:00:30', '2019-10-18 10:00:30', 10, 41);
INSERT INTO public.clientes VALUES (106, 'Alejandra Bolivar', '99878452', 18, '2019-10-18 17:47:26', '2019-10-18 17:47:26', NULL, 41);
INSERT INTO public.clientes VALUES (107, 'BERNAL', '98785522', 18, '2019-10-18 17:48:40', '2019-10-18 17:48:40', NULL, 41);
INSERT INTO public.clientes VALUES (108, 'elliot alarcon', '1154987', 18, '2019-10-18 17:49:32', '2019-10-18 17:49:32', NULL, 41);
INSERT INTO public.clientes VALUES (109, 'Illanes Marquez', '98789564', 18, '2019-10-18 17:52:31', '2019-10-18 17:52:31', NULL, 41);
INSERT INTO public.clientes VALUES (110, 'Vargas', '87987542', 19, '2019-10-18 18:16:07', '2019-10-18 18:16:07', NULL, 42);
INSERT INTO public.clientes VALUES (111, 'Geraman Fuentes', '98789456', 19, '2019-10-18 18:19:05', '2019-10-18 18:19:05', NULL, 42);
INSERT INTO public.clientes VALUES (112, 'sonia ortiz', '987897456', 19, '2019-10-18 18:20:37', '2019-10-18 18:20:37', NULL, 42);
INSERT INTO public.clientes VALUES (113, 'Lening Moreno', '9874421', 19, '2019-10-22 12:25:03', '2019-10-22 12:25:03', NULL, 42);
INSERT INTO public.clientes VALUES (114, 'Mario Luna', '666987452', 19, '2019-10-22 12:25:44', '2019-10-22 12:25:44', NULL, 42);
INSERT INTO public.clientes VALUES (115, 'velarde quiñones Nadir', '98745666', 19, '2019-10-22 18:19:32', '2019-10-22 18:19:32', NULL, 42);
INSERT INTO public.clientes VALUES (116, 'velasquez ramires Dionicio', '998785548', 19, '2019-10-22 18:55:04', '2019-10-22 18:55:04', NULL, 42);
INSERT INTO public.clientes VALUES (117, 'Sandalio Yacira', '7896545', 19, '2019-10-23 13:49:36', '2019-10-23 13:49:36', NULL, 42);
INSERT INTO public.clientes VALUES (121, 'VARGAS', '98741442', 19, '2019-10-23 14:04:05', '2019-10-23 14:04:05', NULL, 42);
INSERT INTO public.clientes VALUES (122, 'ADRIANA LIMA', '98755214', 19, '2019-10-23 14:46:41', '2019-10-23 14:46:41', NULL, 42);
INSERT INTO public.clientes VALUES (123, 'Limachi Yandira', '9874565', 19, '2019-10-23 14:55:58', '2019-10-23 14:55:58', NULL, 42);
INSERT INTO public.clientes VALUES (124, 'vargas fuentes Carine', '20', 19, '2019-10-23 17:49:20', '2019-10-23 17:49:20', NULL, 42);
INSERT INTO public.clientes VALUES (125, 'Velasco Ramigo', '64987987', 19, '2019-10-23 17:55:53', '2019-10-23 17:55:53', NULL, 42);
INSERT INTO public.clientes VALUES (126, 'Velasco Boris', '6574987', 19, '2019-10-23 17:58:45', '2019-10-23 17:58:45', NULL, 42);
INSERT INTO public.clientes VALUES (127, 'asdfa', '1238', 19, '2019-10-23 17:59:59', '2019-10-23 17:59:59', NULL, 42);
INSERT INTO public.clientes VALUES (128, 'Yandira Linares', '98745881', 13, '2019-10-25 10:06:37', '2019-10-25 10:06:37', NULL, 31);
INSERT INTO public.clientes VALUES (130, 'Pedro Salazar', '4569826', NULL, NULL, NULL, NULL, 42);
INSERT INTO public.clientes VALUES (134, 'Boris Velasco 2', '798545645', 19, '2019-12-06 18:12:09', '2019-12-06 18:12:09', NULL, 42);
INSERT INTO public.clientes VALUES (136, 'Jonathan Ortiz', '79875415', 25, '2019-12-08 21:45:08', '2019-12-08 21:45:08', NULL, 42);
INSERT INTO public.clientes VALUES (137, 'Juan Perez', '9875552', 19, '2019-12-10 18:35:13', '2019-12-10 18:35:13', NULL, 42);
INSERT INTO public.clientes VALUES (138, 'Fabi Martinez', '4796512', 19, '2019-12-11 16:42:25', '2019-12-11 16:42:25', NULL, 42);
INSERT INTO public.clientes VALUES (139, 'cespedez oscar', '67891234', 19, '2019-12-11 16:47:28', '2019-12-11 16:47:28', NULL, 42);
INSERT INTO public.clientes VALUES (140, 'JJ Perez', '4657899aa', 19, '2019-12-11 16:55:58', '2019-12-11 16:55:58', NULL, 42);
INSERT INTO public.clientes VALUES (141, 'juan ortiz', '9874562lñ', 19, '2019-12-11 16:57:23', '2019-12-11 16:57:23', NULL, 42);
INSERT INTO public.clientes VALUES (142, 'asdfadsfda', '12', 19, '2019-12-11 16:58:15', '2019-12-11 16:58:15', NULL, 42);
INSERT INTO public.clientes VALUES (143, 'Huascar Valdez', '98744422', 19, '2019-12-11 17:43:18', '2019-12-11 17:43:18', NULL, 42);
INSERT INTO public.clientes VALUES (144, 'Carlos Vilar', '9874652', 19, '2019-12-11 17:44:42', '2019-12-11 17:44:42', NULL, 42);
INSERT INTO public.clientes VALUES (145, 'Alejandro Vargas', '4335', 19, '2019-12-11 17:47:51', '2019-12-11 17:47:51', NULL, 42);
INSERT INTO public.clientes VALUES (146, 'Aduviri', '98745627', 19, '2019-12-11 17:51:47', '2019-12-11 17:51:47', NULL, 42);
INSERT INTO public.clientes VALUES (148, 'Juan Velasco', '4564', 19, '2019-12-11 17:55:14', '2019-12-11 17:55:14', NULL, 42);
INSERT INTO public.clientes VALUES (149, 'Marco Zeballos', '98745662', 19, '2019-12-17 18:25:22', '2019-12-17 18:25:22', NULL, 42);
INSERT INTO public.clientes VALUES (150, 'Juan Segalez', '98745678', 13, '2020-01-13 10:42:46', '2020-01-13 10:42:46', NULL, 31);
INSERT INTO public.clientes VALUES (151, 'Juan Vargas', '4792527', 13, '2020-01-14 16:46:00', '2020-01-14 16:46:00', NULL, 31);
INSERT INTO public.clientes VALUES (152, 'Juan Perez', '98712354', 19, '2020-01-24 15:16:09', '2020-01-24 15:16:09', NULL, 42);
INSERT INTO public.clientes VALUES (153, 'Pedro Vargas', '9871113', 19, '2020-01-24 15:35:27', '2020-01-24 15:35:27', NULL, 42);
INSERT INTO public.clientes VALUES (154, 'Pedro Fuentes', '78911154', 19, '2020-01-24 15:49:33', '2020-01-24 15:49:33', NULL, 42);
INSERT INTO public.clientes VALUES (155, 'Juan Velasquez León', '98755522', NULL, '2020-01-24 18:32:20', '2020-01-24 18:32:20', 11, NULL);
INSERT INTO public.clientes VALUES (156, 'Laura Cespedez', '45698755', 19, '2020-01-28 22:17:30', '2020-01-28 22:17:30', NULL, 42);
INSERT INTO public.clientes VALUES (157, 'Pedro Arenaz', '97855244', NULL, '2020-01-28 22:50:14', '2020-01-28 22:50:14', 11, NULL);


--
-- TOC entry 4999 (class 0 OID 33083)
-- Dependencies: 225
-- Data for Name: cocineros; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.cocineros VALUES (110, 'Vladimir', 'Fuentes', NULL, NULL, NULL, 'vfuentes', NULL, '$2y$10$wTDb0sizw/KvxeFl4HJDj.M5RtBXYpKsi5Yb2C9ec6twE6osNdyM.', NULL, true, NULL, '2019-11-18 17:54:35', '2019-11-18 18:01:54', '4', NULL, NULL, NULL, NULL, '2019-11-18 18:01:54', true, 2, 1600.00, NULL, 18, 67);
INSERT INTO public.cocineros VALUES (116, 'Miguel', 'Urquieta', 'Perez', '98778955', NULL, 'murquieta', 'murquieta@mail.com', '$2y$10$gZS.4rrpDRQkRu/mxzYWLO0cZoL7usRlLkrQWvEr4fMZGCoftviDy', '1986-08-11', true, NULL, '2019-11-26 17:20:28', '2019-11-27 09:43:08', '4', NULL, NULL, NULL, NULL, NULL, true, 4, 2600.00, NULL, 22, 69);
INSERT INTO public.cocineros VALUES (111, 'Lorena', 'Vergara', 'Santos', '9877852', 'Av Monje # 25', 'lvergara', 'lvergara@mail.com', '$2y$10$Z63Oywd.kSf7620EpGlS1.ZbKOJ4ryJIdrVSekPHaUI5q0xRlnwoq', '1988-11-12', false, NULL, '2019-11-18 18:02:52', '2019-12-08 21:21:05', '4', NULL, 'Abigail', '71245689', NULL, NULL, false, 3, 1650.00, NULL, 18, 67);
INSERT INTO public.cocineros VALUES (109, 'Ximena', 'Linares', 'Vargas', '9875524', 'Av Camacho # 1124', 'xlinares', 'xlinares@mail.com', '$2y$10$.61QTHy1Cd95nhXojghHZO/VkaADlHVUyPY8xgmfEEqKokoAtOm52', '1989-11-18', false, NULL, '2019-11-18 15:33:13', '2020-01-28 22:56:09', '4', NULL, 'Yesenia', '72087988', '22261850', NULL, true, 1, 1700.00, NULL, 17, 67);


--
-- TOC entry 5002 (class 0 OID 33090)
-- Dependencies: 228
-- Data for Name: historial_caja; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.historial_caja VALUES (4, 3600.00, 3600.00, '2019-09-18', false, 11, NULL, 13, '2019-09-18 16:27:19', '2019-09-18 22:36:44');
INSERT INTO public.historial_caja VALUES (3, 600.00, 600.00, '2019-09-18', false, 11, NULL, 13, '2019-09-18 16:14:46', '2019-09-18 22:36:49');
INSERT INTO public.historial_caja VALUES (2, 158000.50, 158000.50, '2019-09-18', false, 11, NULL, 13, '2019-09-18 15:48:35', '2019-09-18 22:36:55');
INSERT INTO public.historial_caja VALUES (1, 1600.42, 1600.42, '2019-09-18', false, 11, NULL, 13, '2019-09-18 15:32:41', '2019-09-18 22:36:58');
INSERT INTO public.historial_caja VALUES (5, 500.00, 500.00, '2019-09-18', false, 11, NULL, 13, '2019-09-18 18:11:55', '2019-09-18 22:37:03');
INSERT INTO public.historial_caja VALUES (6, 1600.00, 1600.00, '2019-09-19', false, 11, NULL, 13, '2019-09-18 22:37:14', '2019-09-18 22:43:31');
INSERT INTO public.historial_caja VALUES (7, 1650.00, 1650.00, '2019-09-20', false, 11, NULL, 13, '2019-09-18 22:43:48', '2019-09-18 22:44:41');
INSERT INTO public.historial_caja VALUES (8, 1650.00, 1650.00, '2019-09-21', false, 11, NULL, 13, '2019-09-18 22:45:09', '2019-09-18 22:47:43');
INSERT INTO public.historial_caja VALUES (10, 1500.00, 1500.00, '2019-09-19', false, 14, NULL, 8, '2019-09-19 06:58:34', '2019-09-19 07:05:30');
INSERT INTO public.historial_caja VALUES (11, 300.00, 300.00, '2019-09-20', false, 14, NULL, 8, '2019-09-19 07:05:42', '2019-09-19 07:14:48');
INSERT INTO public.historial_caja VALUES (12, 1700.00, 1700.00, '2019-09-21', true, 14, NULL, 8, '2019-09-19 07:15:22', '2019-09-19 07:15:22');
INSERT INTO public.historial_caja VALUES (9, 1700.00, 1700.00, '2019-09-22', false, 11, NULL, 13, '2019-09-18 22:48:04', '2019-09-30 18:34:29');
INSERT INTO public.historial_caja VALUES (20, 100.00, 400.00, '2019-10-05', true, 27, NULL, 17, '2019-10-05 19:56:49', '2019-10-05 20:38:27');
INSERT INTO public.historial_caja VALUES (29, 120.00, 2070.00, '2019-10-18', false, 29, NULL, 19, '2019-10-18 18:15:14', '2019-10-23 17:12:11');
INSERT INTO public.historial_caja VALUES (18, 1600.00, 1936.00, '2019-10-06', false, 11, NULL, 13, '2019-10-05 12:30:12', '2019-10-09 10:35:03');
INSERT INTO public.historial_caja VALUES (13, 200.00, 2127.73, '2019-09-30', false, 11, NULL, 13, '2019-09-30 18:41:51', '2019-10-02 08:42:49');
INSERT INTO public.historial_caja VALUES (19, 600.00, 964.50, '2019-10-06', false, 17, NULL, 16, '2019-10-05 12:30:32', '2019-10-09 11:34:22');
INSERT INTO public.historial_caja VALUES (30, 520.00, 2143.00, '2019-10-23', false, 29, NULL, 19, '2019-10-23 17:12:21', '2019-10-24 09:31:25');
INSERT INTO public.historial_caja VALUES (27, 922.50, 1166.50, '2019-10-18', false, 11, NULL, 13, '2019-10-18 17:00:37', '2019-10-25 09:18:51');
INSERT INTO public.historial_caja VALUES (21, 1500.00, 2416.00, '2019-10-09', false, 11, NULL, 13, '2019-10-09 10:35:27', '2019-10-14 09:43:29');
INSERT INTO public.historial_caja VALUES (14, 200.00, 1453.50, '2019-10-02', false, 11, NULL, 13, '2019-10-02 08:43:05', '2019-10-03 09:35:40');
INSERT INTO public.historial_caja VALUES (32, 520.00, 1886.30, '2019-10-25', true, 11, NULL, 13, '2019-10-25 09:19:16', '2019-11-05 16:52:28');
INSERT INTO public.historial_caja VALUES (23, 542.00, 6555.50, '2019-10-14', false, 11, NULL, 13, '2019-10-14 09:43:50', '2019-10-17 16:54:13');
INSERT INTO public.historial_caja VALUES (15, 350.00, 1768.90, '2019-10-03', false, 11, NULL, 13, '2019-10-03 10:00:39', '2019-10-04 09:48:47');
INSERT INTO public.historial_caja VALUES (22, 550.00, 1656.80, '2019-10-09', false, 17, NULL, 16, '2019-10-09 11:38:52', '2019-10-17 17:07:17');
INSERT INTO public.historial_caja VALUES (25, 123.00, 123.00, '2019-10-17', true, 17, NULL, 16, '2019-10-17 17:10:04', '2019-10-17 17:10:04');
INSERT INTO public.historial_caja VALUES (31, 150.00, 762.00, '2019-10-24', false, 29, NULL, 19, '2019-10-24 09:31:43', '2019-11-06 15:59:59');
INSERT INTO public.historial_caja VALUES (16, 300.00, 398.60, '2019-10-04', false, 11, NULL, 13, '2019-10-04 09:48:57', '2019-10-04 15:10:00');
INSERT INTO public.historial_caja VALUES (24, 120.00, 922.50, '2019-10-17', false, 11, NULL, 13, '2019-10-17 16:54:26', '2019-10-18 17:00:05');
INSERT INTO public.historial_caja VALUES (17, 60.70, 2341.10, '2019-10-05', false, 11, NULL, 13, '2019-10-04 15:10:53', '2019-10-05 12:26:21');
INSERT INTO public.historial_caja VALUES (26, 20.00, 319.50, '2019-10-18', false, 28, NULL, 18, '2019-10-18 09:35:48', '2019-10-18 17:42:13');
INSERT INTO public.historial_caja VALUES (28, 50.50, 50.50, '2019-10-19', true, 28, NULL, 18, '2019-10-18 17:42:29', '2019-10-18 17:46:37');
INSERT INTO public.historial_caja VALUES (33, 120.32, 847.32, '2019-11-05', false, 35, NULL, 25, '2019-11-05 17:20:31', '2019-12-08 21:35:09');
INSERT INTO public.historial_caja VALUES (35, 200.00, 342.00, '2019-12-08', true, 35, NULL, 25, '2019-12-08 21:35:34', '2019-12-08 21:48:01');
INSERT INTO public.historial_caja VALUES (34, 150.20, 1581.20, '2019-11-05', false, 29, NULL, 19, '2019-11-06 16:00:45', '2020-01-28 20:40:18');
INSERT INTO public.historial_caja VALUES (36, 850.00, 1126.00, '2020-01-28', false, 29, NULL, 19, '2020-01-28 22:13:59', '2020-01-28 22:32:46');
INSERT INTO public.historial_caja VALUES (37, 150.00, 522.00, '2020-01-29', true, 29, NULL, 19, '2020-01-28 22:41:37', '2020-01-29 12:25:41');


--
-- TOC entry 5004 (class 0 OID 33094)
-- Dependencies: 230
-- Data for Name: mozos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.mozos VALUES (108, 'wendy', 'Fuentes', 'Mamani', NULL, NULL, 'wendy24', NULL, '$2y$10$CLajV1x38S0zUgqDD1BXoO/UGjAynFrKZu.XOHMqeGzQ3FJYWcnnm', '1993-12-18', false, NULL, '2019-11-08 17:20:30', '2019-12-05 18:28:45', '0', NULL, NULL, '71245688', NULL, NULL, true, 14, 1500.00, NULL, 18, 67);
INSERT INTO public.mozos VALUES (76, 'Yesenia', 'Coyo', 'Fuentes', '96612359', 'Villa Dolores # 56', 'La loca', 'laloca@mail.com', '$2y$10$nhket0CsNRz9WqYawSffauL/zie6kQWj3tXFgljB.aEJLuxmdMRpq', '1995-09-18', false, NULL, '2019-08-31 11:13:39', '2019-08-31 11:13:39', '0', NULL, NULL, '71245623', NULL, NULL, true, 5, 2600.00, NULL, 14, 58);
INSERT INTO public.mozos VALUES (70, 'Daniela', NULL, 'Ximenes', '60176523', 'Av Brazil # 45', 'Dani1325', 'dani@mail.com', '$2y$10$YF4w4hIMjnyu7ZPyI0eEdOD58kUL0bzzGGqjPKRAjMokZpeyp/0Eu', '1992-11-12', false, NULL, '2019-08-28 18:09:33', '2019-09-02 16:37:17', '0', NULL, NULL, '76512356', NULL, '2019-09-02 16:37:17', true, 2, 1560.00, '2019-08-28', 9, 58);
INSERT INTO public.mozos VALUES (74, 'Carola', 'Garcia', 'Vasquez', '68812365', 'Av Santiago # 45', 'Carola', 'carola@mail.com', '$2y$10$xbv.7QEPPt5eEAYr0arOneCFjUKEET8bgEHI8IODcF32Ks8EdRjuS', '1988-11-23', true, NULL, '2019-08-31 10:58:50', '2019-09-02 16:43:40', '0', NULL, 'Sara', '712323', NULL, '2019-09-02 16:43:40', true, 3, 2600.00, NULL, 9, 58);
INSERT INTO public.mozos VALUES (84, 'Claudia', 'Beltran', NULL, '65789115', 'Av Vasquez 64', 'clau92', 'clau92@mail.com', '$2y$10$iiPO07XGKkhBWuPRBPj1Qet7KUQhGJPxiu5ARwt.t7ijYTqn.Tlmu', '1992-10-15', true, NULL, '2019-10-02 17:56:13', '2019-10-04 12:08:53', '0', NULL, NULL, '71545689', NULL, '2019-10-04 12:08:53', true, 6, 10000.00, NULL, 3, 58);
INSERT INTO public.mozos VALUES (86, 'viviana', 'Ximenez', 'teran', '654789299', 'tejada', 'vvi32', 'vivi32@mail.com', '$2y$10$YdaY0riBbLxKsM3Z3om6WeF6J4MApYTpk2br1RQfwG7HGfKo4B.2C', '1988-07-12', true, NULL, '2019-10-04 12:36:21', '2019-10-04 12:40:59', '0', NULL, NULL, NULL, '22223171', NULL, true, 7, 2000.00, NULL, 9, 58);
INSERT INTO public.mozos VALUES (75, 'Rocio', 'Torres', 'Fuentes', '96612352', 'Villa Dolores # 56', 'La Garza', 'lagarza@mail.com', '$2y$10$1wRZJK6yo0NwG5glubkvYeKP419AEGCRUdvT.ge66JNchtBvHL5yi', '1995-09-18', false, NULL, '2019-08-31 11:10:13', '2019-10-04 12:42:09', '0', NULL, 'Cruz', '71245623', '2568923', '2019-10-04 12:42:09', true, 4, 2600.00, NULL, 9, 58);
INSERT INTO public.mozos VALUES (90, 'Yamil', 'Fuentes', 'Vargas', '9991112', 'Av Ximenez 56', 'yamilete', 'yamilete65@mail.com', '$2y$10$ybur.xDEpYConWlreC7hmOgLKOKHDc2qHZmhfN.PZ0Qo2tbbQiypW', '1988-11-11', true, NULL, '2019-10-05 19:45:43', '2019-10-05 19:45:43', '0', NULL, NULL, '71245689', NULL, NULL, true, 9, 2500.00, NULL, 15, 64);
INSERT INTO public.mozos VALUES (87, 'Rocio', 'Torres', NULL, '65487955', 'rio seco', 'chio26', 'chio26@mail.com', '$2y$10$qB5rjy45/vO/DemdwqdHiuMQQUMzadhycMbaWnAjxZAFa91zLkFNK', '1992-11-08', false, NULL, '2019-10-05 06:50:15', '2019-10-10 17:35:46', '0', NULL, NULL, '71245623', NULL, NULL, true, 8, 2500.00, NULL, 3, 58);
INSERT INTO public.mozos VALUES (95, 'Pedro', 'Bustamante', 'Gutierrez', '9875527', 'Av Costanera # 454', 'pedrito', 'pedrura@hotmail.com', '$2y$10$Gk3QHtwxFeXQUjI/gk1T/uFXsY3RQGagSoh9NxvlY4xGkXjD3sC0G', '1989-04-15', true, NULL, '2019-10-18 09:28:44', '2019-10-18 09:28:44', '0', NULL, NULL, '71245698', '2895689', NULL, true, 10, 1300.00, NULL, 16, 66);
INSERT INTO public.mozos VALUES (103, 'asdfasdf', 'asdfasdf', 'asdfasd', '912345629', 'asdfasdf', 'asdfadsf9879', 'asdfadsf9879@mail.com', '$2y$10$LsnbjrlrCPsFId88BmCFUO06630nItc5hBHURtdHzsSYNveaeTCW2', '2019-10-19', false, NULL, '2019-10-19 21:02:12', '2019-10-22 16:15:35', '0', NULL, NULL, '71245632', NULL, '2019-10-22 16:15:35', true, 12, 1500.00, NULL, 17, 67);
INSERT INTO public.mozos VALUES (115, 'juan', 'velasco', 'fuentes', '65478945', NULL, 'jvelasco', 'jvelasco@mail.com', '$2y$10$GH0cn93T88vpH7CiuDbboeB6h.OHoQ3rgsHkiudh0bin.NGom91P6', '1989-11-11', true, NULL, '2019-11-26 16:01:30', '2019-11-26 16:01:30', '0', NULL, NULL, NULL, NULL, NULL, true, 15, 2500.00, NULL, 21, 69);
INSERT INTO public.mozos VALUES (105, 'Ramiro', 'Vargas', 'Moreno', NULL, NULL, 'ramiro24', NULL, '$2y$10$NX7EBssME.vd3zilaq40r.xP/9yrEjjat22Ip3vDBtUnBBCLnInQm', NULL, true, NULL, '2019-10-22 17:22:29', '2020-01-28 12:11:27', '0', NULL, NULL, NULL, NULL, NULL, true, 13, 2500.00, NULL, 17, 67);
INSERT INTO public.mozos VALUES (98, 'Gylda', 'Olmedo', 'Tinelli', '65478929', 'Av Sanchez Lima', 'gilda44', 'gilda44@yahoo.com.es', '$2y$10$TdX.yR4YfEKB0XQWlXLzbe2exXrj4odBlYwEYNGGVpQuo2Yj7r2Dy', '1979-11-15', false, NULL, '2019-10-18 18:10:49', '2020-01-28 22:47:24', '0', NULL, NULL, '71245623', '22557788', NULL, true, 11, 1300.00, NULL, 17, 67);


--
-- TOC entry 5006 (class 0 OID 33100)
-- Dependencies: 232
-- Data for Name: pagos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.pagos VALUES (1, 120.00, 112.05, 112.10, 0.00, 0.00, 7.90, 66, '2019-09-30 07:28:58', '2019-09-30 07:28:58', NULL);
INSERT INTO public.pagos VALUES (2, 120.00, 115.65, 115.70, 0.00, 0.00, 0.00, 65, '2019-09-30 10:48:01', '2019-09-30 10:48:01', NULL);
INSERT INTO public.pagos VALUES (3, 260.00, 253.42, 253.50, 0.00, 0.00, 6.50, 64, '2019-09-30 10:51:24', '2019-09-30 10:51:24', NULL);
INSERT INTO public.pagos VALUES (4, 205.00, 204.45, 204.50, 0.00, 0.00, 0.50, 60, '2019-09-30 10:53:05', '2019-09-30 10:53:05', NULL);
INSERT INTO public.pagos VALUES (5, 100.00, 83.40, 83.40, 0.00, 0.00, 16.60, 63, '2019-09-30 10:53:39', '2019-09-30 10:53:39', NULL);
INSERT INTO public.pagos VALUES (6, 100.00, 74.03, 74.10, 0.00, 0.00, 25.90, 51, '2019-09-30 10:54:25', '2019-09-30 10:54:25', NULL);
INSERT INTO public.pagos VALUES (7, 100.00, 97.73, 73.80, 0.00, 0.00, 26.20, 62, '2019-09-30 11:34:42', '2019-09-30 11:34:42', NULL);
INSERT INTO public.pagos VALUES (8, 150.00, 122.02, 122.10, 0.00, 0.00, 27.90, 61, '2019-09-30 15:07:33', '2019-09-30 15:07:33', NULL);
INSERT INTO public.pagos VALUES (9, 300.00, 224.55, 224.60, 0.00, 0.00, 75.40, 36, '2019-09-30 15:33:28', '2019-09-30 15:33:28', NULL);
INSERT INTO public.pagos VALUES (10, 150.00, 115.73, 116.00, 0.00, 0.00, 34.00, 59, '2019-09-30 15:41:08', '2019-09-30 15:41:08', NULL);
INSERT INTO public.pagos VALUES (11, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 53, '2019-09-30 15:55:49', '2019-09-30 15:55:49', NULL);
INSERT INTO public.pagos VALUES (12, 190.00, 182.32, 0.00, 0.00, 0.00, 190.00, 58, '2019-09-30 17:14:40', '2019-09-30 17:14:40', NULL);
INSERT INTO public.pagos VALUES (13, 70.00, 66.68, 66.70, 0.00, 0.00, 3.30, 55, '2019-09-30 17:29:10', '2019-09-30 17:29:10', NULL);
INSERT INTO public.pagos VALUES (14, 150.00, 132.45, 132.50, 0.00, 0.00, 17.50, 71, '2019-09-30 18:47:24', '2019-09-30 18:47:24', NULL);
INSERT INTO public.pagos VALUES (15, 100.00, 78.30, 0.00, 0.00, 0.00, 100.00, 72, '2019-10-01 06:58:26', '2019-10-01 06:58:26', NULL);
INSERT INTO public.pagos VALUES (16, 250.00, 208.50, 208.50, 0.00, 0.00, 41.50, 73, '2019-10-01 07:52:01', '2019-10-01 07:52:01', NULL);
INSERT INTO public.pagos VALUES (17, 120.00, 115.95, 116.00, 0.00, 0.00, 4.00, 74, '2019-10-01 11:25:38', '2019-10-01 11:25:38', NULL);
INSERT INTO public.pagos VALUES (18, 100.00, 91.65, 91.70, 0.00, 0.00, 8.30, 77, '2019-10-01 11:28:12', '2019-10-01 11:28:12', NULL);
INSERT INTO public.pagos VALUES (19, 60.00, 57.53, 57.53, 0.00, 0.00, 2.47, 78, '2019-10-01 12:03:20', '2019-10-01 12:03:20', NULL);
INSERT INTO public.pagos VALUES (20, 100.00, 74.03, 74.10, 0.00, 0.00, 25.90, 86, '2019-10-01 18:38:15', '2019-10-01 18:38:15', NULL);
INSERT INTO public.pagos VALUES (21, 50.00, 41.70, 41.70, 0.00, 0.00, 8.30, 87, '2019-10-01 18:40:59', '2019-10-01 18:40:59', NULL);
INSERT INTO public.pagos VALUES (22, 150.00, 132.38, 132.40, 0.00, 0.00, 17.60, 88, '2019-10-01 18:49:36', '2019-10-01 18:49:36', NULL);
INSERT INTO public.pagos VALUES (23, 66.90, 66.90, 66.90, 0.00, 0.00, 0.00, 89, '2019-10-01 18:52:18', '2019-10-01 18:52:18', NULL);
INSERT INTO public.pagos VALUES (24, 100.00, 99.90, 99.90, 0.00, 0.00, 0.10, 90, '2019-10-01 18:57:18', '2019-10-01 18:57:18', NULL);
INSERT INTO public.pagos VALUES (25, 100.00, 91.65, 91.70, 0.00, 0.00, 8.30, 91, '2019-10-01 18:58:30', '2019-10-01 18:58:30', NULL);
INSERT INTO public.pagos VALUES (26, 100.00, 98.93, 99.00, 0.00, 0.00, 1.00, 80, '2019-10-01 18:59:27', '2019-10-01 18:59:27', NULL);
INSERT INTO public.pagos VALUES (27, 60.00, 57.53, 57.60, 0.00, 0.00, 2.40, 79, '2019-10-01 22:00:51', '2019-10-01 22:00:51', NULL);
INSERT INTO public.pagos VALUES (28, 60.00, 57.22, 57.30, 0.00, 0.00, 2.70, 75, '2019-10-01 22:01:08', '2019-10-01 22:01:08', NULL);
INSERT INTO public.pagos VALUES (29, 70.00, 69.82, 69.90, 0.00, 0.00, 0.10, 76, '2019-10-01 22:01:22', '2019-10-01 22:01:22', NULL);
INSERT INTO public.pagos VALUES (30, 70.00, 66.68, 66.70, 0.00, 0.00, 3.30, 81, '2019-10-01 22:01:37', '2019-10-01 22:01:37', NULL);
INSERT INTO public.pagos VALUES (31, 150.00, 132.45, 132.50, 0.00, 0.00, 17.50, 82, '2019-10-01 22:01:51', '2019-10-01 22:01:51', NULL);
INSERT INTO public.pagos VALUES (32, 35.00, 33.22, 33.30, 0.00, 0.00, 1.70, 83, '2019-10-01 22:02:19', '2019-10-01 22:02:19', NULL);
INSERT INTO public.pagos VALUES (33, 100.00, 99.15, 99.20, 0.00, 0.00, 0.80, 84, '2019-10-01 22:02:29', '2019-10-01 22:02:29', NULL);
INSERT INTO public.pagos VALUES (34, 150.00, 132.45, 132.50, 0.00, 0.00, 17.50, 85, '2019-10-01 22:02:41', '2019-10-01 22:02:41', NULL);
INSERT INTO public.pagos VALUES (35, 100.00, 87.53, 87.60, 0.00, 0.00, 12.40, 92, '2019-10-01 23:25:02', '2019-10-01 23:25:02', NULL);
INSERT INTO public.pagos VALUES (36, 100.00, 8.25, 8.30, 0.00, 0.00, 91.70, 93, '2019-10-01 23:27:58', '2019-10-01 23:27:58', NULL);
INSERT INTO public.pagos VALUES (37, 100.00, 16.73, 16.80, 0.00, 0.00, 83.20, 94, '2019-10-01 23:32:32', '2019-10-01 23:32:32', NULL);
INSERT INTO public.pagos VALUES (38, 100.00, 49.95, 50.00, 0.00, 0.00, 50.00, 95, '2019-10-01 23:35:09', '2019-10-01 23:35:09', NULL);
INSERT INTO public.pagos VALUES (39, 200.00, 104.10, 104.10, 0.00, 0.00, 95.90, 96, '2019-10-01 23:38:04', '2019-10-01 23:38:04', NULL);
INSERT INTO public.pagos VALUES (40, 200.00, 165.68, 165.70, 0.00, 0.00, 34.30, 97, '2019-10-02 08:47:43', '2019-10-02 08:47:43', NULL);
INSERT INTO public.pagos VALUES (41, 200.00, 104.25, 104.30, 0.00, 0.00, 95.70, 98, '2019-10-02 08:55:18', '2019-10-02 08:55:18', NULL);
INSERT INTO public.pagos VALUES (42, 100.00, 70.80, 70.80, 0.00, 0.00, 29.20, 101, '2019-10-02 09:22:19', '2019-10-02 09:22:19', NULL);
INSERT INTO public.pagos VALUES (43, 150.00, 132.38, 132.40, 0.00, 0.00, 17.60, 103, '2019-10-02 09:57:28', '2019-10-02 09:57:28', NULL);
INSERT INTO public.pagos VALUES (44, 150.00, 112.50, 112.50, 0.00, 0.00, 37.50, 105, '2019-10-02 10:01:44', '2019-10-02 10:01:44', NULL);
INSERT INTO public.pagos VALUES (45, 100.00, 83.47, 83.50, 0.00, 0.00, 16.50, 107, '2019-10-02 10:10:00', '2019-10-02 10:10:00', NULL);
INSERT INTO public.pagos VALUES (46, 100.00, 87.53, 87.60, 0.00, 0.00, 12.40, 108, '2019-10-02 10:15:42', '2019-10-02 10:15:42', NULL);
INSERT INTO public.pagos VALUES (47, 150.00, 143.70, 143.70, 0.00, 0.00, 6.30, 110, '2019-10-02 11:51:34', '2019-10-02 11:51:34', NULL);
INSERT INTO public.pagos VALUES (48, 15.00, 13.50, 13.50, 0.00, 0.00, 1.50, 111, '2019-10-02 11:57:32', '2019-10-02 11:57:32', NULL);
INSERT INTO public.pagos VALUES (49, 100.00, 78.60, 78.60, 0.00, 0.00, 21.40, 112, '2019-10-02 12:14:08', '2019-10-02 12:14:08', NULL);
INSERT INTO public.pagos VALUES (50, 7.00, 6.38, 6.40, 0.00, 0.00, 0.60, 113, '2019-10-02 12:20:19', '2019-10-02 12:20:19', NULL);
INSERT INTO public.pagos VALUES (51, 30.00, 27.75, 27.80, 0.00, 0.00, 2.20, 114, '2019-10-02 18:19:02', '2019-10-02 18:19:02', NULL);
INSERT INTO public.pagos VALUES (52, 20.00, 17.63, 17.70, 0.00, 0.00, 2.30, 115, '2019-10-02 19:02:17', '2019-10-02 19:02:17', NULL);
INSERT INTO public.pagos VALUES (53, 10.00, 8.00, 8.00, 0.00, 0.00, 2.00, 116, '2019-10-03 07:13:34', '2019-10-03 07:13:34', NULL);
INSERT INTO public.pagos VALUES (54, 100.00, 57.50, 57.50, NULL, NULL, 42.50, 118, '2019-10-03 09:18:18', '2019-10-03 09:18:18', NULL);
INSERT INTO public.pagos VALUES (55, 100.00, 73.00, 73.00, 0.00, 0.00, 27.00, 119, '2019-10-03 09:27:11', '2019-10-03 09:27:11', NULL);
INSERT INTO public.pagos VALUES (56, 100.00, 70.50, 70.50, 0.00, 0.00, 29.50, 120, '2019-10-03 09:35:08', '2019-10-03 09:35:08', NULL);
INSERT INTO public.pagos VALUES (57, 150.00, 115.00, 115.00, 0.00, 0.00, 35.00, 121, '2019-10-03 10:01:41', '2019-10-03 10:01:41', NULL);
INSERT INTO public.pagos VALUES (58, 60.00, 59.00, 59.00, 0.00, 0.00, 1.00, 122, '2019-10-03 10:16:04', '2019-10-03 10:16:04', NULL);
INSERT INTO public.pagos VALUES (59, 60.00, 57.50, 57.50, 0.00, 0.00, 2.50, 123, '2019-10-03 10:21:55', '2019-10-03 10:21:55', NULL);
INSERT INTO public.pagos VALUES (60, 10.00, 7.00, 7.00, 0.00, 0.00, 3.00, 124, '2019-10-03 10:22:48', '2019-10-03 10:22:48', NULL);
INSERT INTO public.pagos VALUES (61, 4.00, 4.00, 4.00, 0.00, 0.00, 0.00, 125, '2019-10-03 10:24:45', '2019-10-03 10:24:45', NULL);
INSERT INTO public.pagos VALUES (62, 60.00, 56.50, 56.50, 0.00, 0.00, 3.50, 126, '2019-10-03 10:26:15', '2019-10-03 10:26:15', NULL);
INSERT INTO public.pagos VALUES (63, 20.00, 19.50, 19.50, 0.00, 0.00, 0.50, 127, '2019-10-03 10:30:27', '2019-10-03 10:30:27', NULL);
INSERT INTO public.pagos VALUES (64, 5.00, 4.00, 4.00, 0.00, 0.00, 1.00, 128, '2019-10-03 10:31:07', '2019-10-03 10:31:07', NULL);
INSERT INTO public.pagos VALUES (65, 115.00, 113.00, 113.00, 0.00, 0.00, 2.00, 129, '2019-10-03 10:34:03', '2019-10-03 10:34:03', NULL);
INSERT INTO public.pagos VALUES (66, 60.00, 57.50, 57.50, 0.00, 0.00, 2.50, 131, '2019-10-03 10:58:49', '2019-10-03 10:58:49', NULL);
INSERT INTO public.pagos VALUES (67, 150.00, 131.50, 131.50, 0.00, 0.00, 18.50, 132, '2019-10-03 12:25:49', '2019-10-03 12:25:49', NULL);
INSERT INTO public.pagos VALUES (68, 20.00, 18.00, 18.00, 0.00, 0.00, 2.00, 130, '2019-10-03 12:29:36', '2019-10-03 12:29:36', NULL);
INSERT INTO public.pagos VALUES (69, 150.00, 134.50, 134.50, 0.00, 0.00, 15.50, 134, '2019-10-03 12:33:26', '2019-10-03 12:33:26', NULL);
INSERT INTO public.pagos VALUES (70, 10.00, 7.50, 7.50, 0.00, 0.00, 2.50, 133, '2019-10-03 12:35:18', '2019-10-03 12:35:18', NULL);
INSERT INTO public.pagos VALUES (71, 50.00, 33.00, 33.00, 0.00, 0.00, 17.00, 136, '2019-10-03 17:26:44', '2019-10-03 17:26:44', NULL);
INSERT INTO public.pagos VALUES (72, 48.00, 48.00, 48.00, 0.00, 0.00, 0.00, 135, '2019-10-03 17:36:42', '2019-10-03 17:36:42', NULL);
INSERT INTO public.pagos VALUES (73, 30.00, 26.50, 26.50, 0.00, 0.00, 3.50, 138, '2019-10-03 18:00:40', '2019-10-03 18:00:40', NULL);
INSERT INTO public.pagos VALUES (74, 10.00, 8.00, 8.00, 0.00, 0.00, 2.00, 137, '2019-10-03 18:04:27', '2019-10-03 18:04:27', NULL);
INSERT INTO public.pagos VALUES (75, 200.00, 161.80, 161.80, 0.00, 0.00, 38.20, 141, '2019-10-03 18:07:19', '2019-10-03 18:07:19', NULL);
INSERT INTO public.pagos VALUES (76, 20.00, 20.00, 20.00, 0.00, 0.00, 0.00, 139, '2019-10-03 18:48:33', '2019-10-03 18:48:33', NULL);
INSERT INTO public.pagos VALUES (77, 150.00, 118.10, 118.10, 0.00, 0.00, 31.90, 140, '2019-10-03 18:48:50', '2019-10-03 18:48:50', NULL);
INSERT INTO public.pagos VALUES (78, 150.00, 149.00, 149.00, 0.00, 0.00, 1.00, 142, '2019-10-03 18:49:03', '2019-10-03 18:49:03', NULL);
INSERT INTO public.pagos VALUES (79, 100.00, 70.00, 70.00, 0.00, 0.00, 30.00, 143, '2019-10-03 18:52:33', '2019-10-03 18:52:33', NULL);
INSERT INTO public.pagos VALUES (80, 60.00, 51.00, 51.00, 0.00, 0.00, 9.00, 144, '2019-10-04 09:51:59', '2019-10-04 09:51:59', NULL);
INSERT INTO public.pagos VALUES (81, 50.00, 47.60, 47.60, 0.00, 0.00, 2.40, 145, '2019-10-04 09:53:43', '2019-10-04 09:53:43', NULL);
INSERT INTO public.pagos VALUES (82, 700.00, 617.30, 617.30, 0.00, 0.00, 82.70, 148, '2019-10-04 16:04:19', '2019-10-04 16:04:19', NULL);
INSERT INTO public.pagos VALUES (83, 70.00, 68.00, 68.00, 0.00, 0.00, 2.00, 149, '2019-10-04 16:08:10', '2019-10-04 16:08:10', NULL);
INSERT INTO public.pagos VALUES (84, 15.00, 13.00, 13.00, 0.00, 0.00, 2.00, 146, '2019-10-04 16:08:30', '2019-10-04 16:08:30', NULL);
INSERT INTO public.pagos VALUES (85, 70.00, 66.50, 66.50, 0.00, 0.00, 3.50, 147, '2019-10-04 16:08:41', '2019-10-04 16:08:41', NULL);
INSERT INTO public.pagos VALUES (86, 150.00, 121.00, 121.00, 0.00, 0.00, 29.00, 150, '2019-10-04 16:12:41', '2019-10-04 16:12:41', NULL);
INSERT INTO public.pagos VALUES (87, 109.00, 109.00, 109.00, 0.00, 0.00, 0.00, 151, '2019-10-04 16:14:57', '2019-10-04 16:14:57', NULL);
INSERT INTO public.pagos VALUES (88, 20.00, 15.00, 15.00, 0.00, 0.00, 5.00, 153, '2019-10-04 16:35:15', '2019-10-04 16:35:15', NULL);
INSERT INTO public.pagos VALUES (89, 30.00, 24.00, 24.00, 0.00, 0.00, 6.00, 152, '2019-10-04 16:35:28', '2019-10-04 16:35:28', NULL);
INSERT INTO public.pagos VALUES (90, 100.00, 97.80, 97.80, 0.00, 0.00, 2.20, 154, '2019-10-05 06:38:40', '2019-10-05 06:38:40', NULL);
INSERT INTO public.pagos VALUES (91, 100.00, 75.00, 75.00, 0.00, 0.00, 25.00, 158, '2019-10-05 06:44:46', '2019-10-05 06:44:46', NULL);
INSERT INTO public.pagos VALUES (92, 200.00, 183.50, 183.50, 0.00, 0.00, 16.50, 159, '2019-10-05 06:45:24', '2019-10-05 06:45:24', NULL);
INSERT INTO public.pagos VALUES (93, 100.00, 75.00, 75.00, 0.00, 0.00, 25.00, 169, '2019-10-05 09:34:43', '2019-10-05 09:34:43', NULL);
INSERT INTO public.pagos VALUES (94, 30.00, 29.00, 29.00, 0.00, 0.00, 1.00, 171, '2019-10-05 09:36:35', '2019-10-05 09:36:35', NULL);
INSERT INTO public.pagos VALUES (95, 60.50, 60.50, 60.50, 0.00, 0.00, 0.00, 172, '2019-10-05 12:23:18', '2019-10-05 12:23:18', NULL);
INSERT INTO public.pagos VALUES (96, 70.00, 64.00, 64.00, 0.00, 0.00, 6.00, 170, '2019-10-05 12:23:35', '2019-10-05 12:23:35', NULL);
INSERT INTO public.pagos VALUES (97, 30.00, 25.50, 25.50, 0.00, 0.00, 4.50, 168, '2019-10-05 12:23:45', '2019-10-05 12:23:45', NULL);
INSERT INTO public.pagos VALUES (98, 59.00, 59.00, 59.00, 0.00, 0.00, 0.00, 167, '2019-10-05 12:23:58', '2019-10-05 12:23:58', NULL);
INSERT INTO public.pagos VALUES (99, 64.00, 64.00, 64.00, 0.00, 0.00, 0.00, 166, '2019-10-05 12:24:08', '2019-10-05 12:24:08', NULL);
INSERT INTO public.pagos VALUES (100, 100.00, 75.00, 75.00, 0.00, 0.00, 25.00, 165, '2019-10-05 12:24:17', '2019-10-05 12:24:17', NULL);
INSERT INTO public.pagos VALUES (101, 80.00, 78.00, 78.00, 0.00, 0.00, 2.00, 164, '2019-10-05 12:24:29', '2019-10-05 12:24:29', NULL);
INSERT INTO public.pagos VALUES (102, 60.00, 57.50, 57.50, 0.00, 0.00, 2.50, 163, '2019-10-05 12:24:41', '2019-10-05 12:24:41', NULL);
INSERT INTO public.pagos VALUES (103, 60.00, 57.50, 57.50, 0.00, 0.00, 2.50, 162, '2019-10-05 12:24:51', '2019-10-05 12:24:51', NULL);
INSERT INTO public.pagos VALUES (104, 20.00, 18.50, 18.50, 0.00, 0.00, 1.50, 161, '2019-10-05 12:25:03', '2019-10-05 12:25:03', NULL);
INSERT INTO public.pagos VALUES (105, 2.50, 2.50, 2.50, 0.00, 0.00, 0.00, 160, '2019-10-05 12:25:14', '2019-10-05 12:25:14', NULL);
INSERT INTO public.pagos VALUES (106, 100.00, 75.00, 75.00, 0.00, 0.00, 25.00, 157, '2019-10-05 12:25:30', '2019-10-05 12:25:30', NULL);
INSERT INTO public.pagos VALUES (107, 100.00, 62.80, 62.80, 0.00, 0.00, 37.20, 156, '2019-10-05 12:25:41', '2019-10-05 12:25:41', NULL);
INSERT INTO public.pagos VALUES (108, 100.00, 86.50, 86.50, 0.00, 0.00, 13.50, 155, '2019-10-05 12:25:53', '2019-10-05 12:25:53', NULL);
INSERT INTO public.pagos VALUES (109, 150.00, 121.00, 121.00, 0.00, 0.00, 29.00, 176, '2019-10-05 12:34:29', '2019-10-05 12:34:29', NULL);
INSERT INTO public.pagos VALUES (110, 60.00, 56.50, 56.50, 0.00, 0.00, 3.50, 173, '2019-10-05 13:01:19', '2019-10-05 13:01:19', NULL);
INSERT INTO public.pagos VALUES (111, 50.00, 36.00, 36.00, 0.00, 0.00, 14.00, 179, '2019-10-05 19:59:25', '2019-10-05 19:59:25', NULL);
INSERT INTO public.pagos VALUES (112, 100.00, 90.00, 90.00, 0.00, 0.00, 10.00, 181, '2019-10-05 20:01:27', '2019-10-05 20:01:27', NULL);
INSERT INTO public.pagos VALUES (113, 50.00, 36.00, 36.00, 0.00, 0.00, 14.00, 182, '2019-10-05 20:02:26', '2019-10-05 20:02:26', NULL);
INSERT INTO public.pagos VALUES (114, 20.00, 18.00, 18.00, 0.00, 0.00, 2.00, 180, '2019-10-05 20:03:21', '2019-10-05 20:03:21', NULL);
INSERT INTO public.pagos VALUES (115, 80.00, 74.00, 74.00, 0.00, 0.00, 6.00, 185, '2019-10-05 20:36:01', '2019-10-05 20:36:01', NULL);
INSERT INTO public.pagos VALUES (116, 50.00, 36.00, 36.00, 0.00, 0.00, 14.00, 183, '2019-10-05 20:37:51', '2019-10-05 20:37:51', NULL);
INSERT INTO public.pagos VALUES (117, 10.00, 10.00, 10.00, 0.00, 0.00, 0.00, 184, '2019-10-05 20:38:18', '2019-10-05 20:38:18', NULL);
INSERT INTO public.pagos VALUES (118, 30.00, 21.50, 21.50, 0.00, 0.00, 8.50, 187, '2019-10-07 10:03:08', '2019-10-07 10:03:08', NULL);
INSERT INTO public.pagos VALUES (119, 50.00, 32.50, 32.50, 0.00, 0.00, 17.50, 188, '2019-10-07 10:04:28', '2019-10-07 10:04:28', NULL);
INSERT INTO public.pagos VALUES (120, 15.00, 14.00, 14.00, 0.00, 0.00, 1.00, 189, '2019-10-07 16:26:42', '2019-10-07 16:26:42', NULL);
INSERT INTO public.pagos VALUES (121, 150.00, 112.00, 112.00, 0.00, 0.00, 38.00, 192, '2019-10-09 10:28:18', '2019-10-09 10:28:18', NULL);
INSERT INTO public.pagos VALUES (122, 110.00, 107.50, 107.50, 0.00, 0.00, 2.50, 190, '2019-10-09 10:28:42', '2019-10-09 10:28:42', NULL);
INSERT INTO public.pagos VALUES (123, 30.00, 30.00, 30.00, 0.00, 0.00, 0.00, 178, '2019-10-09 10:29:37', '2019-10-09 10:29:37', NULL);
INSERT INTO public.pagos VALUES (124, 20.00, 15.50, 15.50, 0.00, 0.00, 4.50, 175, '2019-10-09 10:29:47', '2019-10-09 10:29:47', NULL);
INSERT INTO public.pagos VALUES (125, 3.00, 3.00, 3.00, 0.00, 0.00, 0.00, 174, '2019-10-09 10:29:57', '2019-10-09 10:29:57', NULL);
INSERT INTO public.pagos VALUES (126, 15.00, 14.50, 14.50, 0.00, 0.00, 0.50, 193, '2019-10-09 10:35:55', '2019-10-09 10:35:55', NULL);
INSERT INTO public.pagos VALUES (127, 105.00, 104.50, 104.50, 0.00, 0.00, 0.50, 194, '2019-10-09 10:38:27', '2019-10-09 10:38:27', NULL);
INSERT INTO public.pagos VALUES (128, 50.00, 40.50, 40.50, 0.00, 0.00, 9.50, 195, '2019-10-09 10:51:39', '2019-10-09 10:51:39', NULL);
INSERT INTO public.pagos VALUES (129, 100.00, 70.00, 70.00, 0.00, 0.00, 30.00, 177, '2019-10-09 11:32:52', '2019-10-09 11:32:52', NULL);
INSERT INTO public.pagos VALUES (130, 120.00, 117.00, 117.00, 0.00, 0.00, 3.00, 191, '2019-10-09 11:33:05', '2019-10-09 11:33:05', NULL);
INSERT INTO public.pagos VALUES (131, 60.00, 59.00, 59.00, 0.00, 0.00, 1.00, 197, '2019-10-09 11:39:38', '2019-10-09 11:39:38', NULL);
INSERT INTO public.pagos VALUES (132, 1000.00, 724.30, 724.30, 0.00, 0.00, 275.70, 199, '2019-10-09 12:21:31', '2019-10-09 12:21:31', NULL);
INSERT INTO public.pagos VALUES (133, 30.00, 26.00, 26.00, 0.00, 0.00, 4.00, 198, '2019-10-09 12:25:36', '2019-10-09 12:25:36', NULL);
INSERT INTO public.pagos VALUES (134, 120.00, 118.00, 118.00, 0.00, 0.00, 2.00, 200, '2019-10-09 12:57:57', '2019-10-09 12:57:57', NULL);
INSERT INTO public.pagos VALUES (135, 200.00, 177.00, 177.00, 0.00, 0.00, 23.00, 202, '2019-10-09 13:47:25', '2019-10-09 13:47:25', NULL);
INSERT INTO public.pagos VALUES (136, 3.00, 2.50, 2.50, 0.00, 0.00, 0.50, 201, '2019-10-09 13:47:53', '2019-10-09 13:47:53', NULL);
INSERT INTO public.pagos VALUES (137, 20.00, 15.00, 15.00, 0.00, 0.00, 5.00, 205, '2019-10-12 10:34:58', '2019-10-12 10:34:58', NULL);
INSERT INTO public.pagos VALUES (138, 100.00, 75.50, 75.50, 0.00, 0.00, 24.50, 208, '2019-10-12 15:12:51', '2019-10-12 15:12:51', NULL);
INSERT INTO public.pagos VALUES (139, 100.00, 86.50, 86.50, 0.00, 0.00, 13.50, 210, '2019-10-12 21:36:11', '2019-10-12 21:36:11', NULL);
INSERT INTO public.pagos VALUES (140, 60.00, 57.50, 57.50, 0.00, 0.00, 2.50, 209, '2019-10-12 21:47:52', '2019-10-12 21:47:52', NULL);
INSERT INTO public.pagos VALUES (141, 70.00, 67.00, 67.00, 0.00, 0.00, 3.00, 211, '2019-10-12 21:48:03', '2019-10-12 21:48:03', NULL);
INSERT INTO public.pagos VALUES (142, 23.00, 23.00, 23.00, 0.00, 0.00, 0.00, 207, '2019-10-12 21:48:14', '2019-10-12 21:48:14', NULL);
INSERT INTO public.pagos VALUES (143, 211.00, 210.50, 210.50, 0.00, 0.00, 0.50, 204, '2019-10-12 21:48:30', '2019-10-12 21:48:30', NULL);
INSERT INTO public.pagos VALUES (144, 60.00, 57.50, 57.50, 0.00, 0.00, 2.50, 196, '2019-10-12 21:48:40', '2019-10-12 21:48:40', NULL);
INSERT INTO public.pagos VALUES (145, 20.00, 16.00, 16.00, 0.00, 0.00, 4.00, 212, '2019-10-13 09:36:02', '2019-10-13 09:36:02', NULL);
INSERT INTO public.pagos VALUES (146, 100.00, 72.50, 72.50, 0.00, 0.00, 27.50, 215, '2019-10-13 18:19:29', '2019-10-13 18:19:29', NULL);
INSERT INTO public.pagos VALUES (147, 100.00, 75.50, 75.50, 0.00, 0.00, 24.50, 216, '2019-10-13 18:24:26', '2019-10-13 18:24:26', NULL);
INSERT INTO public.pagos VALUES (148, 100.00, 72.80, 72.80, 0.00, 0.00, 27.20, 226, '2019-10-14 12:56:51', '2019-10-14 12:56:51', NULL);
INSERT INTO public.pagos VALUES (149, 20.00, 15.00, 15.00, 0.00, 0.00, 5.00, 227, '2019-10-14 12:59:43', '2019-10-14 12:59:43', NULL);
INSERT INTO public.pagos VALUES (150, 600.00, 593.30, 593.30, 0.00, 0.00, 6.70, 228, '2019-10-14 13:03:07', '2019-10-14 13:03:07', NULL);
INSERT INTO public.pagos VALUES (151, 50.00, 32.50, 32.50, 0.00, 0.00, 17.50, 225, '2019-10-14 13:05:21', '2019-10-14 13:05:21', NULL);
INSERT INTO public.pagos VALUES (152, 70.00, 68.00, 68.00, 0.00, 0.00, 2.00, 224, '2019-10-14 13:05:31', '2019-10-14 13:05:31', NULL);
INSERT INTO public.pagos VALUES (153, 100.00, 80.50, 80.50, 0.00, 0.00, 19.50, 223, '2019-10-14 13:05:42', '2019-10-14 13:05:42', NULL);
INSERT INTO public.pagos VALUES (154, 200.00, 173.00, 173.00, 0.00, 0.00, 27.00, 229, '2019-10-14 17:21:23', '2019-10-14 17:21:23', NULL);
INSERT INTO public.pagos VALUES (155, 120.00, 116.00, 116.00, 0.00, 0.00, 4.00, 230, '2019-10-14 18:44:20', '2019-10-14 18:44:20', NULL);
INSERT INTO public.pagos VALUES (156, 100.00, 78.00, 78.00, 0.00, 0.00, 22.00, 235, '2019-10-15 09:57:41', '2019-10-15 09:57:41', NULL);
INSERT INTO public.pagos VALUES (157, 30.00, 24.00, 24.00, 0.00, 0.00, 6.00, 236, '2019-10-15 10:26:18', '2019-10-15 10:26:18', NULL);
INSERT INTO public.pagos VALUES (158, 50.00, 33.50, 33.50, 0.00, 0.00, 16.50, 237, '2019-10-15 10:26:30', '2019-10-15 10:26:30', NULL);
INSERT INTO public.pagos VALUES (159, 100.00, 71.00, 71.00, 0.00, 0.00, 29.00, 238, '2019-10-15 10:28:33', '2019-10-15 10:28:33', NULL);
INSERT INTO public.pagos VALUES (160, 15.00, 12.00, 12.00, 0.00, 0.00, 3.00, 234, '2019-10-15 10:53:33', '2019-10-15 10:53:33', NULL);
INSERT INTO public.pagos VALUES (161, 70.00, 68.50, 68.50, 0.00, 0.00, 1.50, 233, '2019-10-15 10:53:47', '2019-10-15 10:53:47', NULL);
INSERT INTO public.pagos VALUES (162, 60.00, 59.00, 59.00, 0.00, 0.00, 1.00, 232, '2019-10-15 10:53:58', '2019-10-15 10:53:58', NULL);
INSERT INTO public.pagos VALUES (163, 60.00, 57.50, 57.50, 0.00, 0.00, 2.50, 231, '2019-10-15 10:54:16', '2019-10-15 10:54:16', NULL);
INSERT INTO public.pagos VALUES (164, 20.00, 16.50, 16.50, 0.00, 0.00, 3.50, 239, '2019-10-15 11:07:01', '2019-10-15 11:07:01', NULL);
INSERT INTO public.pagos VALUES (165, 100.00, 78.80, 78.80, 0.00, 0.00, 21.20, 240, '2019-10-15 11:09:06', '2019-10-15 11:09:06', NULL);
INSERT INTO public.pagos VALUES (166, 30.00, 25.50, 25.50, 0.00, 0.00, 4.50, 286, '2019-10-16 10:45:00', '2019-10-16 10:45:00', NULL);
INSERT INTO public.pagos VALUES (167, 150.00, 122.00, 122.00, 0.00, 0.00, 28.00, 285, '2019-10-16 10:45:11', '2019-10-16 10:45:11', NULL);
INSERT INTO public.pagos VALUES (168, 150.00, 120.50, 120.50, 0.00, 0.00, 29.50, 284, '2019-10-16 10:45:23', '2019-10-16 10:45:23', NULL);
INSERT INTO public.pagos VALUES (169, 70.00, 68.00, 68.00, 0.00, 0.00, 2.00, 241, '2019-10-16 10:46:02', '2019-10-16 10:46:02', NULL);
INSERT INTO public.pagos VALUES (170, 20.00, 15.00, 15.00, 0.00, 0.00, 5.00, 242, '2019-10-16 10:46:09', '2019-10-16 10:46:09', NULL);
INSERT INTO public.pagos VALUES (171, 100.00, 70.00, 70.00, 0.00, 0.00, 30.00, 243, '2019-10-16 10:46:16', '2019-10-16 10:46:16', NULL);
INSERT INTO public.pagos VALUES (172, 70.00, 64.00, 64.00, 0.00, 0.00, 6.00, 244, '2019-10-16 10:46:25', '2019-10-16 10:46:25', NULL);
INSERT INTO public.pagos VALUES (173, 60.00, 57.50, 57.50, 0.00, 0.00, 2.50, 245, '2019-10-16 10:46:36', '2019-10-16 10:46:36', NULL);
INSERT INTO public.pagos VALUES (174, 60.00, 57.50, 57.50, 0.00, 0.00, 2.50, 246, '2019-10-16 10:46:47', '2019-10-16 10:46:47', NULL);
INSERT INTO public.pagos VALUES (175, 70.00, 65.50, 65.50, 0.00, 0.00, 4.50, 247, '2019-10-16 10:46:57', '2019-10-16 10:46:57', NULL);
INSERT INTO public.pagos VALUES (176, 60.00, 57.50, 57.50, 0.00, 0.00, 2.50, 248, '2019-10-16 10:47:06', '2019-10-16 10:47:06', NULL);
INSERT INTO public.pagos VALUES (177, 60.00, 57.50, 57.50, 0.00, 0.00, 2.50, 249, '2019-10-16 10:47:15', '2019-10-16 10:47:15', NULL);
INSERT INTO public.pagos VALUES (178, 60.00, 57.50, 57.50, 0.00, 0.00, 2.50, 250, '2019-10-16 10:47:23', '2019-10-16 10:47:23', NULL);
INSERT INTO public.pagos VALUES (179, 60.00, 57.50, 57.50, 0.00, 0.00, 2.50, 251, '2019-10-16 10:47:31', '2019-10-16 10:47:31', NULL);
INSERT INTO public.pagos VALUES (180, 100.00, 70.00, 70.00, 0.00, 0.00, 30.00, 252, '2019-10-16 10:47:39', '2019-10-16 10:47:39', NULL);
INSERT INTO public.pagos VALUES (181, 60.00, 57.50, 57.50, 0.00, 0.00, 2.50, 253, '2019-10-16 10:47:48', '2019-10-16 10:47:48', NULL);
INSERT INTO public.pagos VALUES (182, 100.00, 57.50, 57.50, 0.00, 0.00, 42.50, 254, '2019-10-16 10:47:58', '2019-10-16 10:47:58', NULL);
INSERT INTO public.pagos VALUES (183, 150.00, 130.80, 130.80, 0.00, 0.00, 19.20, 304, '2019-10-16 17:17:34', '2019-10-16 17:17:34', NULL);
INSERT INTO public.pagos VALUES (184, 20.00, 15.00, 15.00, 0.00, 0.00, 5.00, 305, '2019-10-16 17:24:06', '2019-10-16 17:24:06', NULL);
INSERT INTO public.pagos VALUES (185, 70.00, 68.50, 68.50, 0.00, 0.00, 1.50, 306, '2019-10-16 17:27:09', '2019-10-16 17:27:09', NULL);
INSERT INTO public.pagos VALUES (186, 30.00, 27.00, 27.00, 0.00, 0.00, 3.00, 307, '2019-10-16 17:46:36', '2019-10-16 17:46:36', NULL);
INSERT INTO public.pagos VALUES (187, 100.00, 79.00, 79.00, 0.00, 0.00, 21.00, 308, '2019-10-16 17:48:36', '2019-10-16 17:48:36', NULL);
INSERT INTO public.pagos VALUES (188, 100.00, 49.50, 49.50, 0.00, 0.00, 50.50, 309, '2019-10-16 18:21:17', '2019-10-16 18:21:17', NULL);
INSERT INTO public.pagos VALUES (189, 100.00, 24.00, 24.00, 0.00, 0.00, 76.00, 310, '2019-10-16 18:44:08', '2019-10-16 18:44:08', NULL);
INSERT INTO public.pagos VALUES (190, 100.00, 72.50, 72.50, 0.00, 0.00, 27.50, 311, '2019-10-16 18:45:58', '2019-10-16 18:45:58', NULL);
INSERT INTO public.pagos VALUES (191, 150.00, 107.50, 107.50, 0.00, 0.00, 42.50, 312, '2019-10-16 18:48:38', '2019-10-16 18:48:38', NULL);
INSERT INTO public.pagos VALUES (192, 100.00, 80.50, 80.50, 0.00, 0.00, 19.50, 313, '2019-10-16 18:53:49', '2019-10-16 18:53:49', NULL);
INSERT INTO public.pagos VALUES (193, 30.00, 29.50, 29.50, 0.00, 0.00, 0.50, 314, '2019-10-16 18:55:35', '2019-10-16 18:55:35', NULL);
INSERT INTO public.pagos VALUES (194, 100.00, 72.00, 72.00, 0.00, 0.00, 28.00, 315, '2019-10-16 18:57:43', '2019-10-16 18:57:43', NULL);
INSERT INTO public.pagos VALUES (195, 70.00, 69.50, 69.50, 0.00, 0.00, 0.50, 316, '2019-10-16 19:00:34', '2019-10-16 19:00:34', NULL);
INSERT INTO public.pagos VALUES (196, 20.50, 20.50, 20.50, 0.00, 0.00, 0.00, 317, '2019-10-16 22:41:13', '2019-10-16 22:41:13', NULL);
INSERT INTO public.pagos VALUES (197, 20.00, 13.00, 13.00, 0.00, 0.00, 7.00, 318, '2019-10-16 22:45:29', '2019-10-16 22:45:29', NULL);
INSERT INTO public.pagos VALUES (198, 100.00, 83.00, 83.00, 0.00, 0.00, 17.00, 319, '2019-10-16 22:48:01', '2019-10-16 22:48:01', NULL);
INSERT INTO public.pagos VALUES (199, 100.00, 70.00, 70.00, 0.00, 0.00, 30.00, 320, '2019-10-17 07:34:18', '2019-10-17 07:34:18', NULL);
INSERT INTO public.pagos VALUES (200, 70.00, 68.00, 68.00, 0.00, 0.00, 2.00, 323, '2019-10-17 07:41:33', '2019-10-17 07:41:33', NULL);
INSERT INTO public.pagos VALUES (201, 100.00, 70.00, 70.00, 0.00, 0.00, 30.00, 326, '2019-10-17 15:09:03', '2019-10-17 15:09:03', NULL);
INSERT INTO public.pagos VALUES (202, 20.00, 16.00, 16.00, 0.00, 0.00, 4.00, 322, '2019-10-17 15:37:00', '2019-10-17 15:37:00', NULL);
INSERT INTO public.pagos VALUES (203, 20.00, 16.00, 16.00, 0.00, 0.00, 4.00, 321, '2019-10-17 15:37:47', '2019-10-17 15:37:47', NULL);
INSERT INTO public.pagos VALUES (204, 100.00, 94.00, 94.00, 0.00, 0.00, 6.00, 300, '2019-10-17 15:39:05', '2019-10-17 15:39:05', NULL);
INSERT INTO public.pagos VALUES (205, 170.00, 166.00, 166.00, 0.00, 0.00, 4.00, 325, '2019-10-17 15:41:51', '2019-10-17 15:41:51', NULL);
INSERT INTO public.pagos VALUES (206, 224.00, 224.00, 224.00, 0.00, 0.00, 0.00, 324, '2019-10-17 15:42:48', '2019-10-17 15:42:48', NULL);
INSERT INTO public.pagos VALUES (207, 20.00, 20.00, 20.00, 0.00, 0.00, 0.00, 303, '2019-10-17 15:45:44', '2019-10-17 15:45:44', NULL);
INSERT INTO public.pagos VALUES (208, 150.00, 131.00, 131.00, 0.00, 0.00, 19.00, 302, '2019-10-17 15:57:10', '2019-10-17 15:57:10', NULL);
INSERT INTO public.pagos VALUES (209, 100.00, 94.80, 94.80, 0.00, 0.00, 5.20, 301, '2019-10-17 15:58:04', '2019-10-17 15:58:04', NULL);
INSERT INTO public.pagos VALUES (210, 18.50, 18.50, 18.50, 0.00, 0.00, 0.00, 299, '2019-10-17 16:00:59', '2019-10-17 16:00:59', NULL);
INSERT INTO public.pagos VALUES (211, 60.00, 57.50, 57.50, 0.00, 0.00, 2.50, 255, '2019-10-17 16:06:51', '2019-10-17 16:06:51', NULL);
INSERT INTO public.pagos VALUES (212, 60.00, 57.50, 57.50, 0.00, 0.00, 2.50, 256, '2019-10-17 16:08:17', '2019-10-17 16:08:17', NULL);
INSERT INTO public.pagos VALUES (213, 100.00, 70.00, 70.00, 0.00, 0.00, 30.00, 257, '2019-10-17 16:10:02', '2019-10-17 16:10:02', NULL);
INSERT INTO public.pagos VALUES (214, 70.00, 63.00, 63.00, 0.00, 0.00, 7.00, 258, '2019-10-17 16:10:20', '2019-10-17 16:10:20', NULL);
INSERT INTO public.pagos VALUES (215, 60.00, 57.50, 57.50, 0.00, 0.00, 2.50, 287, '2019-10-17 16:10:43', '2019-10-17 16:10:43', NULL);
INSERT INTO public.pagos VALUES (216, 5.00, 4.00, 4.00, 0.00, 0.00, 1.00, 288, '2019-10-17 16:10:53', '2019-10-17 16:10:53', NULL);
INSERT INTO public.pagos VALUES (217, 100.00, 67.50, 67.50, 0.00, 0.00, 32.50, 289, '2019-10-17 16:11:14', '2019-10-17 16:11:14', NULL);
INSERT INTO public.pagos VALUES (218, 100.00, 69.50, 69.50, 0.00, 0.00, 30.50, 290, '2019-10-17 16:11:23', '2019-10-17 16:11:23', NULL);
INSERT INTO public.pagos VALUES (219, 60.00, 57.50, 57.50, 0.00, 0.00, 2.50, 291, '2019-10-17 16:11:31', '2019-10-17 16:11:31', NULL);
INSERT INTO public.pagos VALUES (220, 100.00, 67.50, 67.50, 0.00, 0.00, 32.50, 292, '2019-10-17 16:11:42', '2019-10-17 16:11:42', NULL);
INSERT INTO public.pagos VALUES (221, 67.50, 67.50, 67.50, 0.00, 0.00, 0.00, 293, '2019-10-17 16:11:53', '2019-10-17 16:11:53', NULL);
INSERT INTO public.pagos VALUES (222, 15.00, 13.50, 13.50, 0.00, 0.00, 1.50, 294, '2019-10-17 16:12:20', '2019-10-17 16:12:20', NULL);
INSERT INTO public.pagos VALUES (223, 15.00, 15.00, 15.00, 0.00, 0.00, 0.00, 295, '2019-10-17 16:12:34', '2019-10-17 16:12:34', NULL);
INSERT INTO public.pagos VALUES (224, 100.00, 68.50, 68.50, 0.00, 0.00, 31.50, 296, '2019-10-17 16:13:10', '2019-10-17 16:13:10', NULL);
INSERT INTO public.pagos VALUES (225, 120.00, 118.50, 118.50, 0.00, 0.00, 1.50, 297, '2019-10-17 16:13:23', '2019-10-17 16:13:23', NULL);
INSERT INTO public.pagos VALUES (226, 200.00, 191.50, 191.50, 0.00, 0.00, 8.50, 298, '2019-10-17 16:14:49', '2019-10-17 16:14:49', NULL);
INSERT INTO public.pagos VALUES (227, 11.00, 10.50, 10.50, 0.00, 0.00, 0.50, 259, '2019-10-17 16:15:20', '2019-10-17 16:15:20', NULL);
INSERT INTO public.pagos VALUES (228, 100.00, 64.00, 64.00, 0.00, 0.00, 36.00, 260, '2019-10-17 16:15:27', '2019-10-17 16:15:27', NULL);
INSERT INTO public.pagos VALUES (229, 20.00, 14.50, 14.50, 0.00, 0.00, 5.50, 261, '2019-10-17 16:15:39', '2019-10-17 16:15:39', NULL);
INSERT INTO public.pagos VALUES (230, 30.00, 25.50, 25.50, 0.00, 0.00, 4.50, 262, '2019-10-17 16:16:40', '2019-10-17 16:16:40', NULL);
INSERT INTO public.pagos VALUES (231, 70.00, 69.50, 69.50, 0.00, 0.00, 0.50, 263, '2019-10-17 16:19:48', '2019-10-17 16:19:48', NULL);
INSERT INTO public.pagos VALUES (232, 150.00, 123.00, 123.00, 0.00, 0.00, 27.00, 328, '2019-10-17 16:42:52', '2019-10-17 16:42:52', NULL);
INSERT INTO public.pagos VALUES (233, 70.00, 63.00, 63.00, 0.00, 0.00, 7.00, 331, '2019-10-17 17:11:17', '2019-10-17 17:11:17', NULL);
INSERT INTO public.pagos VALUES (234, 120.00, 114.00, 114.00, 0.00, 0.00, 6.00, 332, '2019-10-17 17:13:06', '2019-10-17 17:13:06', NULL);
INSERT INTO public.pagos VALUES (235, 100.00, 78.00, 78.00, 0.00, 0.00, 22.00, 330, '2019-10-17 17:22:43', '2019-10-17 17:22:43', NULL);
INSERT INTO public.pagos VALUES (236, 120.00, 115.00, 115.00, 0.00, 0.00, 5.00, 335, '2019-10-17 17:28:47', '2019-10-17 17:28:47', NULL);
INSERT INTO public.pagos VALUES (237, 100.00, 72.50, 72.50, 0.00, 0.00, 27.50, 334, '2019-10-17 17:32:13', '2019-10-17 17:32:13', NULL);
INSERT INTO public.pagos VALUES (238, 30.00, 24.50, 24.50, 0.00, 0.00, 5.50, 333, '2019-10-17 17:32:22', '2019-10-17 17:32:22', NULL);
INSERT INTO public.pagos VALUES (239, 200.00, 163.50, 163.50, 0.00, 0.00, 36.50, 337, '2019-10-17 17:34:47', '2019-10-17 17:34:47', NULL);
INSERT INTO public.pagos VALUES (240, 100.00, 75.50, 75.50, 0.00, 0.00, 24.50, 329, '2019-10-17 17:38:13', '2019-10-17 17:38:13', NULL);
INSERT INTO public.pagos VALUES (241, 20.00, 15.00, 15.00, 0.00, 0.00, 5.00, 340, '2019-10-17 18:07:20', '2019-10-17 18:07:20', NULL);
INSERT INTO public.pagos VALUES (242, 40.00, 35.00, 35.00, 0.00, 0.00, 5.00, 339, '2019-10-17 18:07:41', '2019-10-17 18:07:41', NULL);
INSERT INTO public.pagos VALUES (243, 15.00, 13.00, 13.00, 0.00, 0.00, 2.00, 342, '2019-10-18 09:12:40', '2019-10-18 09:12:40', NULL);
INSERT INTO public.pagos VALUES (244, 50.00, 35.00, 35.00, 0.00, 0.00, 15.00, 343, '2019-10-18 09:36:33', '2019-10-18 09:36:33', NULL);
INSERT INTO public.pagos VALUES (245, 50.00, 35.00, 35.00, 0.00, 0.00, 15.00, 344, '2019-10-18 10:01:33', '2019-10-18 10:01:33', NULL);
INSERT INTO public.pagos VALUES (246, 60.00, 57.50, 57.50, 0.00, 0.00, 2.50, 341, '2019-10-18 10:47:01', '2019-10-18 10:47:01', NULL);
INSERT INTO public.pagos VALUES (247, 100.00, 80.50, 80.50, 0.00, 0.00, 19.50, 355, '2019-10-18 12:43:04', '2019-10-18 12:43:04', NULL);
INSERT INTO public.pagos VALUES (248, 100.00, 72.50, 72.50, 0.00, 0.00, 27.50, 360, '2019-10-18 16:06:41', '2019-10-18 16:06:41', NULL);
INSERT INTO public.pagos VALUES (249, 50.00, 35.00, 35.00, 0.00, 0.00, 15.00, 345, '2019-10-18 17:02:09', '2019-10-18 17:02:09', NULL);
INSERT INTO public.pagos VALUES (250, 50.00, 33.00, 33.00, 0.00, 0.00, 17.00, 346, '2019-10-18 17:02:16', '2019-10-18 17:02:16', NULL);
INSERT INTO public.pagos VALUES (251, 4.50, 4.50, 4.50, 0.00, 0.00, 0.00, 347, '2019-10-18 17:05:07', '2019-10-18 17:05:07', NULL);
INSERT INTO public.pagos VALUES (252, 20.00, 16.00, 16.00, 0.00, 0.00, 4.00, 348, '2019-10-18 17:05:15', '2019-10-18 17:05:15', NULL);
INSERT INTO public.pagos VALUES (253, 20.00, 19.00, 19.00, 0.00, 0.00, 1.00, 349, '2019-10-18 17:05:24', '2019-10-18 17:05:24', NULL);
INSERT INTO public.pagos VALUES (254, 20.00, 19.00, 19.00, 0.00, 0.00, 1.00, 350, '2019-10-18 17:05:34', '2019-10-18 17:05:34', NULL);
INSERT INTO public.pagos VALUES (255, 50.00, 35.00, 35.00, 0.00, 0.00, 15.00, 366, '2019-10-18 17:10:03', '2019-10-18 17:10:03', NULL);
INSERT INTO public.pagos VALUES (256, 50.00, 33.00, 33.00, 0.00, 0.00, 17.00, 367, '2019-10-18 17:11:07', '2019-10-18 17:11:07', NULL);
INSERT INTO public.pagos VALUES (257, 50.00, 35.00, 35.00, 0.00, 0.00, 15.00, 372, '2019-10-18 17:12:49', '2019-10-18 17:12:49', NULL);
INSERT INTO public.pagos VALUES (258, 60.00, 50.50, 50.50, 0.00, 0.00, 9.50, 374, '2019-10-18 17:48:40', '2019-10-18 17:48:40', NULL);
INSERT INTO public.pagos VALUES (259, 40.00, 33.00, 33.00, 0.00, 0.00, 7.00, 378, '2019-10-18 17:51:23', '2019-10-18 17:51:23', NULL);
INSERT INTO public.pagos VALUES (260, 100.00, 77.00, 77.00, 0.00, 0.00, 23.00, 379, '2019-10-18 17:52:31', '2019-10-18 17:52:31', NULL);
INSERT INTO public.pagos VALUES (261, 100.00, 91.00, 91.00, 0.00, 0.00, 9.00, 384, '2019-10-18 18:19:05', '2019-10-18 18:19:05', NULL);
INSERT INTO public.pagos VALUES (262, 60.00, 52.00, 52.00, 0.00, 0.00, 8.00, 386, '2019-10-18 18:20:37', '2019-10-18 18:20:37', NULL);
INSERT INTO public.pagos VALUES (263, 100.00, 98.00, 98.00, 0.00, 0.00, 2.00, 388, '2019-10-18 18:36:58', '2019-10-18 18:36:58', NULL);
INSERT INTO public.pagos VALUES (264, 100.00, 89.00, 89.00, 0.00, 0.00, 11.00, 389, '2019-10-18 18:40:28', '2019-10-18 18:40:28', NULL);
INSERT INTO public.pagos VALUES (265, 200.00, 190.00, 190.00, 0.00, 0.00, 10.00, 387, '2019-10-18 18:40:38', '2019-10-18 18:40:38', NULL);
INSERT INTO public.pagos VALUES (266, 60.00, 52.00, 52.00, 0.00, 0.00, 8.00, 385, '2019-10-18 18:40:48', '2019-10-18 18:40:48', NULL);
INSERT INTO public.pagos VALUES (267, 150.00, 142.00, 142.00, 0.00, 0.00, 8.00, 383, '2019-10-18 18:41:14', '2019-10-18 18:41:14', NULL);
INSERT INTO public.pagos VALUES (268, 60.00, 57.50, 57.50, 0.00, 0.00, 2.50, 365, '2019-10-19 23:09:40', '2019-10-19 23:09:40', NULL);
INSERT INTO public.pagos VALUES (269, 30.00, 23.50, 23.50, 0.00, 0.00, 6.50, 391, '2019-10-19 23:12:36', '2019-10-19 23:12:36', NULL);
INSERT INTO public.pagos VALUES (270, 50.00, 48.00, 48.00, 0.00, 0.00, 2.00, 392, '2019-10-19 23:13:50', '2019-10-19 23:13:50', NULL);
INSERT INTO public.pagos VALUES (271, 120.00, 115.00, 115.00, 0.00, 0.00, 5.00, 390, '2019-10-19 23:15:28', '2019-10-19 23:15:28', NULL);
INSERT INTO public.pagos VALUES (272, 200.00, 182.00, 182.00, 0.00, 0.00, 18.00, 393, '2019-10-22 12:23:17', '2019-10-22 12:23:17', NULL);
INSERT INTO public.pagos VALUES (273, 50.00, 44.00, 44.00, 0.00, 0.00, 6.00, 395, '2019-10-22 12:25:44', '2019-10-22 12:25:44', NULL);
INSERT INTO public.pagos VALUES (274, 100.00, 88.00, 88.00, 0.00, 0.00, 12.00, 396, '2019-10-22 12:26:43', '2019-10-22 12:26:43', NULL);
INSERT INTO public.pagos VALUES (275, 100.00, 91.00, 91.00, 0.00, 0.00, 9.00, 412, '2019-10-23 14:52:32', '2019-10-23 14:52:32', NULL);
INSERT INTO public.pagos VALUES (276, 100.00, 88.00, 88.00, 0.00, 0.00, 12.00, 413, '2019-10-23 14:54:37', '2019-10-23 14:54:37', NULL);
INSERT INTO public.pagos VALUES (277, 52.00, 52.00, 52.00, 0.00, 0.00, 0.00, 414, '2019-10-23 14:55:58', '2019-10-23 14:55:58', NULL);
INSERT INTO public.pagos VALUES (278, 60.00, 52.00, 52.00, 0.00, 0.00, 8.00, 415, '2019-10-23 14:56:56', '2019-10-23 14:56:56', NULL);
INSERT INTO public.pagos VALUES (279, 100.00, 88.00, 88.00, 0.00, 0.00, 12.00, 416, '2019-10-23 14:58:14', '2019-10-23 14:58:14', NULL);
INSERT INTO public.pagos VALUES (280, 100.00, 91.00, 91.00, 0.00, 0.00, 9.00, 411, '2019-10-23 17:05:55', '2019-10-23 17:05:55', NULL);
INSERT INTO public.pagos VALUES (281, 100.00, 91.00, 91.00, 0.00, 0.00, 9.00, 410, '2019-10-23 17:06:19', '2019-10-23 17:06:19', NULL);
INSERT INTO public.pagos VALUES (282, 100.00, 91.00, 91.00, 0.00, 0.00, 9.00, 409, '2019-10-23 17:06:30', '2019-10-23 17:06:30', NULL);
INSERT INTO public.pagos VALUES (283, 150.00, 137.00, 137.00, 0.00, 0.00, 13.00, 408, '2019-10-23 17:06:56', '2019-10-23 17:06:56', NULL);
INSERT INTO public.pagos VALUES (284, 150.00, 141.00, 141.00, 0.00, 0.00, 9.00, 417, '2019-10-23 17:09:22', '2019-10-23 17:09:22', NULL);
INSERT INTO public.pagos VALUES (285, 100.00, 91.00, 91.00, 0.00, 0.00, 9.00, 418, '2019-10-23 17:13:11', '2019-10-23 17:13:11', NULL);
INSERT INTO public.pagos VALUES (286, 200.00, 182.00, 182.00, 0.00, 0.00, 18.00, 425, '2019-10-23 17:58:45', '2019-10-23 17:58:45', NULL);
INSERT INTO public.pagos VALUES (287, 140.00, 138.00, 138.00, 0.00, 0.00, 2.00, 419, '2019-10-23 18:09:49', '2019-10-23 18:09:49', NULL);
INSERT INTO public.pagos VALUES (288, 5.00, 4.00, 4.00, 0.00, 0.00, 1.00, 420, '2019-10-23 18:10:10', '2019-10-23 18:10:10', NULL);
INSERT INTO public.pagos VALUES (289, 200.00, 182.00, 182.00, 0.00, 0.00, 18.00, 421, '2019-10-23 18:10:20', '2019-10-23 18:10:20', NULL);
INSERT INTO public.pagos VALUES (290, 60.00, 54.00, 54.00, 0.00, 0.00, 6.00, 422, '2019-10-23 18:10:50', '2019-10-23 18:10:50', NULL);
INSERT INTO public.pagos VALUES (291, 200.00, 187.00, 187.00, 0.00, 0.00, 13.00, 423, '2019-10-23 18:10:59', '2019-10-23 18:10:59', NULL);
INSERT INTO public.pagos VALUES (292, 150.00, 141.00, 141.00, 0.00, 0.00, 9.00, 424, '2019-10-23 18:11:13', '2019-10-23 18:11:13', NULL);
INSERT INTO public.pagos VALUES (293, 100.00, 87.00, 87.00, 0.00, 0.00, 13.00, 426, '2019-10-23 18:11:27', '2019-10-23 18:11:27', NULL);
INSERT INTO public.pagos VALUES (294, 5.00, 4.00, 4.00, 0.00, 0.00, 1.00, 427, '2019-10-23 18:11:46', '2019-10-23 18:11:46', NULL);
INSERT INTO public.pagos VALUES (295, 100.00, 94.00, 94.00, 0.00, 0.00, 6.00, 428, '2019-10-23 18:15:04', '2019-10-23 18:15:04', NULL);
INSERT INTO public.pagos VALUES (296, 100.00, 88.00, 88.00, 0.00, 0.00, 12.00, 429, '2019-10-23 18:19:14', '2019-10-23 18:19:14', NULL);
INSERT INTO public.pagos VALUES (297, 100.00, 89.00, 89.00, 0.00, 0.00, 11.00, 430, '2019-10-23 18:22:57', '2019-10-23 18:22:57', NULL);
INSERT INTO public.pagos VALUES (298, 150.00, 141.00, 141.00, 0.00, 0.00, 9.00, 432, '2019-10-23 18:33:21', '2019-10-23 18:33:21', NULL);
INSERT INTO public.pagos VALUES (299, 150.00, 141.00, 141.00, 0.00, 0.00, 9.00, 431, '2019-10-24 09:31:08', '2019-10-24 09:31:08', NULL);
INSERT INTO public.pagos VALUES (300, 50.00, 44.00, 44.00, 0.00, 0.00, 6.00, 433, '2019-10-24 18:27:05', '2019-10-24 18:27:05', NULL);
INSERT INTO public.pagos VALUES (301, 50.00, 47.00, 47.00, 0.00, 0.00, 3.00, 434, '2019-10-25 00:30:17', '2019-10-25 00:30:17', NULL);
INSERT INTO public.pagos VALUES (302, 50.00, 44.00, 44.00, 0.00, 0.00, 6.00, 435, '2019-10-25 00:58:05', '2019-10-25 00:58:05', NULL);
INSERT INTO public.pagos VALUES (303, 150.00, 104.00, 104.00, 0.00, 0.00, 46.00, 437, '2019-10-25 01:04:04', '2019-10-25 01:04:04', NULL);
INSERT INTO public.pagos VALUES (304, 100.00, 70.00, 70.00, 0.00, 0.00, 30.00, 438, '2019-10-25 09:22:00', '2019-10-25 09:22:00', NULL);
INSERT INTO public.pagos VALUES (305, 100.00, 70.00, 70.00, 0.00, 0.00, 30.00, 439, '2019-10-25 09:30:09', '2019-10-25 09:30:09', NULL);
INSERT INTO public.pagos VALUES (306, 20.00, 15.00, 15.00, 0.00, 0.00, 5.00, 440, '2019-10-25 09:49:01', '2019-10-25 09:49:01', NULL);
INSERT INTO public.pagos VALUES (307, 1000.00, 917.80, 917.80, 0.00, 0.00, 82.20, 441, '2019-10-25 10:06:37', '2019-10-25 10:06:37', NULL);
INSERT INTO public.pagos VALUES (308, 100.00, 91.00, 91.00, 0.00, 0.00, 9.00, 436, '2019-10-25 10:27:14', '2019-10-25 10:27:14', NULL);
INSERT INTO public.pagos VALUES (309, 5.00, 4.00, 4.00, 0.00, 0.00, 1.00, 443, '2019-10-25 12:53:57', '2019-10-25 12:53:57', NULL);
INSERT INTO public.pagos VALUES (310, 100.00, 91.00, 91.00, 0.00, 0.00, 9.00, 444, '2019-10-25 13:01:49', '2019-10-25 13:01:49', NULL);
INSERT INTO public.pagos VALUES (311, 150.00, 143.00, 143.00, 0.00, 0.00, 7.00, 442, '2019-10-25 13:01:59', '2019-10-25 13:01:59', NULL);
INSERT INTO public.pagos VALUES (312, 30.00, 24.00, 24.00, 0.00, 0.00, 6.00, 445, '2019-11-05 09:56:25', '2019-11-05 09:56:25', NULL);
INSERT INTO public.pagos VALUES (313, 50.00, 37.00, 37.00, 0.00, 0.00, 13.00, 446, '2019-11-05 10:13:20', '2019-11-05 10:13:20', NULL);
INSERT INTO public.pagos VALUES (314, 70.00, 67.50, 67.50, 0.00, 0.00, 2.50, 448, '2019-11-05 14:43:51', '2019-11-05 14:43:51', NULL);
INSERT INTO public.pagos VALUES (315, 70.00, 67.50, 67.50, 0.00, 0.00, 2.50, 449, '2019-11-05 14:44:49', '2019-11-05 14:44:49', NULL);
INSERT INTO public.pagos VALUES (316, 80.00, 76.00, 76.00, 0.00, 0.00, 4.00, 451, '2019-11-05 14:45:58', '2019-11-05 14:45:58', NULL);
INSERT INTO public.pagos VALUES (317, 30.00, 21.50, 21.50, 0.00, 0.00, 8.50, 452, '2019-11-05 14:47:07', '2019-11-05 14:47:07', NULL);
INSERT INTO public.pagos VALUES (318, 60.00, 57.50, 57.50, 0.00, 0.00, 2.50, 447, '2019-11-05 16:55:31', '2019-11-05 16:55:31', NULL);
INSERT INTO public.pagos VALUES (319, 80.00, 78.50, 78.50, 0.00, 0.00, 1.50, 450, '2019-11-05 16:55:42', '2019-11-05 16:55:42', NULL);
INSERT INTO public.pagos VALUES (320, 100.00, 89.00, 89.00, 0.00, 0.00, 11.00, 453, '2019-11-05 17:20:53', '2019-11-05 17:20:53', NULL);
INSERT INTO public.pagos VALUES (321, 100.00, 87.00, 87.00, 0.00, 0.00, 13.00, 454, '2019-11-05 17:22:39', '2019-11-05 17:22:39', NULL);
INSERT INTO public.pagos VALUES (322, 100.00, 54.00, 54.00, 0.00, 0.00, 46.00, 455, '2019-11-05 18:18:02', '2019-11-05 18:18:02', NULL);
INSERT INTO public.pagos VALUES (323, 100.00, 91.00, 91.00, 0.00, 0.00, 9.00, 457, '2019-11-06 15:55:36', '2019-11-06 15:55:36', NULL);
INSERT INTO public.pagos VALUES (324, 150.00, 137.00, 137.00, 0.00, 0.00, 13.00, 458, '2019-11-06 15:55:54', '2019-11-06 15:55:54', NULL);
INSERT INTO public.pagos VALUES (325, 50.00, 44.00, 44.00, 0.00, 0.00, 6.00, 456, '2019-11-06 15:59:38', '2019-11-06 15:59:38', NULL);
INSERT INTO public.pagos VALUES (326, 104.00, 104.00, 104.00, 0.00, 0.00, 0.00, 460, '2019-11-06 16:02:04', '2019-11-06 16:02:04', NULL);
INSERT INTO public.pagos VALUES (327, 150.00, 138.00, 138.00, 0.00, 0.00, 12.00, 461, '2019-11-06 16:05:56', '2019-11-06 16:05:56', NULL);
INSERT INTO public.pagos VALUES (328, 100.00, 89.00, 89.00, 0.00, 0.00, 11.00, 459, '2019-11-06 16:07:24', '2019-11-06 16:07:24', NULL);
INSERT INTO public.pagos VALUES (329, 100.00, 91.00, 91.00, 0.00, 0.00, 9.00, 462, '2019-11-06 17:48:58', '2019-11-06 17:48:58', NULL);
INSERT INTO public.pagos VALUES (330, 200.00, 178.00, 178.00, 0.00, 0.00, 22.00, 463, '2019-11-16 13:15:39', '2019-11-16 13:15:39', NULL);
INSERT INTO public.pagos VALUES (331, 20.00, 16.00, 16.00, 0.00, 0.00, 4.00, 464, '2019-11-17 23:50:53', '2019-11-17 23:50:53', NULL);
INSERT INTO public.pagos VALUES (332, 150.00, 107.00, 107.00, 0.00, 0.00, 43.00, 466, '2019-11-29 23:52:12', '2019-11-29 23:52:12', NULL);
INSERT INTO public.pagos VALUES (333, 100.00, 72.00, 72.00, 0.00, 0.00, 28.00, 465, '2019-11-29 23:53:38', '2019-11-29 23:53:38', NULL);
INSERT INTO public.pagos VALUES (334, 20.00, 16.00, 16.00, 0.00, 0.00, 4.00, 468, '2019-12-02 13:57:57', '2019-12-02 13:57:57', NULL);
INSERT INTO public.pagos VALUES (335, 150.00, 134.00, 134.00, 0.00, 0.00, 16.00, 470, '2019-12-08 21:42:21', '2019-12-08 21:42:21', NULL);
INSERT INTO public.pagos VALUES (336, 100.00, 8.00, 8.00, 0.00, 0.00, 92.00, 471, '2019-12-08 21:47:20', '2019-12-08 21:47:20', NULL);
INSERT INTO public.pagos VALUES (337, 150.00, 140.00, 140.00, 0.00, 0.00, 10.00, 473, '2019-12-08 21:55:08', '2019-12-08 21:55:08', NULL);
INSERT INTO public.pagos VALUES (338, 15.00, 12.00, 12.00, 0.00, 0.00, 3.00, 475, '2019-12-09 21:06:39', '2019-12-09 21:06:39', NULL);
INSERT INTO public.pagos VALUES (339, 15.00, 12.00, 12.00, 0.00, 0.00, 3.00, 488, '2019-12-11 17:51:47', '2019-12-11 17:51:47', NULL);
INSERT INTO public.pagos VALUES (340, 70.00, 62.00, 62.00, 0.00, 0.00, 8.00, 489, '2019-12-11 17:55:14', '2019-12-11 17:55:14', NULL);
INSERT INTO public.pagos VALUES (341, 50.00, 35.00, 35.00, 0.00, 0.00, 15.00, 490, '2019-12-17 13:37:54', '2019-12-17 13:37:54', 19);
INSERT INTO public.pagos VALUES (342, 50.00, 43.00, 43.00, 0.00, 0.00, 7.00, 491, '2019-12-17 13:41:14', '2019-12-17 13:41:14', NULL);
INSERT INTO public.pagos VALUES (343, 60.00, 52.00, 52.00, 0.00, 0.00, 8.00, 492, '2019-12-17 17:49:24', '2019-12-17 17:49:24', 19);
INSERT INTO public.pagos VALUES (344, 10.00, 8.00, 8.00, 0.00, 0.00, 2.00, 493, '2019-12-17 18:24:03', '2019-12-17 18:24:03', 19);
INSERT INTO public.pagos VALUES (345, 50.00, 44.00, 44.00, 0.00, 0.00, 6.00, 494, '2019-12-17 18:25:22', '2019-12-17 18:25:22', 19);
INSERT INTO public.pagos VALUES (346, 100.00, 87.00, 87.00, 0.00, 0.00, 13.00, 495, '2019-12-17 18:27:42', '2019-12-17 18:27:42', 19);
INSERT INTO public.pagos VALUES (347, 100.00, 86.50, 86.50, 0.00, 0.00, 13.50, 496, '2020-01-13 10:43:40', '2020-01-13 10:43:40', 13);
INSERT INTO public.pagos VALUES (348, 100.00, 80.50, 80.50, 0.00, 0.00, 19.50, 497, '2020-01-14 16:44:00', '2020-01-14 16:44:00', 13);
INSERT INTO public.pagos VALUES (349, 120.00, 116.30, 116.30, 0.00, 0.00, 3.70, 499, '2020-01-14 16:56:24', '2020-01-14 16:56:24', 13);
INSERT INTO public.pagos VALUES (350, 100.00, 94.00, 94.00, 0.00, 0.00, 6.00, 500, '2020-01-24 11:04:08', '2020-01-24 11:04:08', 19);
INSERT INTO public.pagos VALUES (351, 50.00, 40.00, 40.00, 0.00, 0.00, 10.00, 501, '2020-01-24 11:06:32', '2020-01-24 11:06:32', 19);
INSERT INTO public.pagos VALUES (352, 100.00, 94.00, 94.00, 0.00, 0.00, 6.00, 503, '2020-01-24 15:16:09', '2020-01-24 15:16:09', 19);
INSERT INTO public.pagos VALUES (353, 100.00, 94.00, 94.00, 0.00, 0.00, 6.00, 504, '2020-01-24 15:35:27', '2020-01-24 15:35:27', 19);
INSERT INTO public.pagos VALUES (354, 100.00, 60.00, 64.00, 0.00, 0.00, 36.00, 505, '2020-01-24 15:36:40', '2020-01-24 15:36:40', 19);
INSERT INTO public.pagos VALUES (355, 110.00, 101.00, 101.00, 0.00, 0.00, 9.00, 506, '2020-01-24 15:49:33', '2020-01-24 15:49:33', 19);
INSERT INTO public.pagos VALUES (356, 50.00, 47.00, 47.00, 0.00, 0.00, 3.00, 507, '2020-01-24 15:52:07', '2020-01-24 15:52:07', 19);
INSERT INTO public.pagos VALUES (357, 100.00, 92.00, 92.00, 0.00, 0.00, 8.00, 509, '2020-01-24 18:38:48', '2020-01-24 18:38:48', 25);
INSERT INTO public.pagos VALUES (358, 100.00, 98.00, 98.00, 0.00, 0.00, 2.00, 508, '2020-01-24 18:41:43', '2020-01-24 18:41:43', 25);
INSERT INTO public.pagos VALUES (359, 200.00, 182.00, 182.00, 0.00, 0.00, 18.00, 510, '2020-01-28 22:17:30', '2020-01-28 22:17:30', 19);
INSERT INTO public.pagos VALUES (360, 100.00, 94.00, 94.00, 0.00, 0.00, 6.00, 511, '2020-01-28 22:21:04', '2020-01-28 22:21:04', 19);
INSERT INTO public.pagos VALUES (361, 250.00, 248.50, 248.50, 0.00, 0.00, 1.50, 513, '2020-01-29 12:22:17', '2020-01-29 12:22:17', 19);
INSERT INTO public.pagos VALUES (362, 150.00, 123.50, 123.50, 0.00, 0.00, 26.50, 514, '2020-01-29 12:24:58', '2020-01-29 12:24:58', 19);


--
-- TOC entry 5008 (class 0 OID 33104)
-- Dependencies: 234
-- Data for Name: perfilimagens; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.perfilimagens VALUES (38, 'ZrH1gxPzvP7jgpkzyp0WDhsiqP8Y8CAgP4uzAjmJ.jpeg', 55, NULL, NULL, '2019-08-06 22:36:58', '2019-08-06 22:37:02');
INSERT INTO public.perfilimagens VALUES (41, 'NwpWQDkvxshb5MiCM0zgIbx1AnfdLVNA758hTQOW.jpeg', 56, NULL, NULL, '2019-08-07 08:21:32', '2019-08-07 08:21:36');
INSERT INTO public.perfilimagens VALUES (42, 'GGlB4wYEsnDQYp7zAwGsjAcnXLrafgRLrPMDrEfd.jpeg', 56, NULL, NULL, '2019-08-07 08:23:23', '2019-08-07 08:23:26');
INSERT INTO public.perfilimagens VALUES (43, '6F0EBKaIr4xrNBERa9CZujVTc57pxZX6ylwsntcv.jpeg', 57, NULL, NULL, '2019-08-07 08:32:53', '2019-08-07 08:32:56');
INSERT INTO public.perfilimagens VALUES (44, '92MeGDwDnXlZ9GNdcdSl0MMdMDKNAYS0fNuF7jIB.jpeg', 54, NULL, NULL, '2019-08-07 08:33:16', '2019-08-07 08:33:19');
INSERT INTO public.perfilimagens VALUES (45, 'dV930hspAlPvyAAYWCvJCMtSDQbPpdwBsTpsKxfC.jpeg', 58, NULL, NULL, '2019-08-07 08:48:47', '2019-08-07 08:48:50');
INSERT INTO public.perfilimagens VALUES (46, 'k8WArWa2CQOxdtcSOIO5BWXSV7E6N3PA6OhizLK6.jpeg', 59, NULL, NULL, '2019-08-14 23:59:01', '2019-08-14 23:59:10');
INSERT INTO public.perfilimagens VALUES (48, 'rkXyqgs8iGauty0LsfF4qRoh60bv6V2pzXNFAdRf.jpeg', 60, NULL, NULL, '2019-08-15 15:08:26', '2019-08-15 15:09:37');
INSERT INTO public.perfilimagens VALUES (49, 'HmreeUYv1iMcqvilE8i9zLuXvy0tSgwyP4ebcWgG.jpeg', 61, NULL, NULL, '2019-08-25 21:14:09', '2019-08-25 21:14:16');
INSERT INTO public.perfilimagens VALUES (50, 'ROXlDUsVLlLPh9sFhUNLdFNCqmoxanuRhWQsubjp.jpeg', NULL, NULL, NULL, '2019-08-27 18:10:47', '2019-08-27 18:10:47');
INSERT INTO public.perfilimagens VALUES (53, '0WbDrp1xfYLgSSuc0rO0G3LUls194cIfTHetryGt.jpeg', 62, NULL, NULL, '2019-08-27 18:17:32', '2019-08-27 18:17:35');
INSERT INTO public.perfilimagens VALUES (54, 'TtEQLXfbG9NjRiTzpBh1AghU1S6Ys8XQB4DxPzDn.jpeg', 63, NULL, NULL, '2019-09-02 18:09:14', '2019-09-02 18:09:24');
INSERT INTO public.perfilimagens VALUES (55, 'JA7zWnERpDFhxJMvQF6wy0ttO1Y2QUvz2TeBDn3u.jpeg', NULL, NULL, NULL, '2019-09-07 15:47:33', '2019-09-07 15:47:33');
INSERT INTO public.perfilimagens VALUES (56, 'vJnnf8rOb0yxxP859y2jqBOAfvt9iBZF3eIdw7LD.jpeg', NULL, NULL, NULL, '2019-09-07 15:49:31', '2019-09-07 15:49:31');
INSERT INTO public.perfilimagens VALUES (57, 'js9FQR0izOfowoPbMsUndFo5GnHUWLmsTWg4G74y.jpeg', NULL, NULL, NULL, '2019-09-07 16:15:44', '2019-09-07 16:15:44');
INSERT INTO public.perfilimagens VALUES (60, '4q4bMYV4BgtuTKW8xBtLAxeFLWFH7hIENVHoaBgR.jpeg', NULL, NULL, NULL, '2019-09-08 21:31:54', '2019-09-08 21:31:54');
INSERT INTO public.perfilimagens VALUES (61, 'a1Si07cQQydcmINixSbde6FrDEiX9XCPo9pC4ZCe.jpeg', NULL, NULL, NULL, '2019-09-08 21:35:12', '2019-09-08 21:35:12');
INSERT INTO public.perfilimagens VALUES (62, 'P0e9XgjIsuecNhuFzHwpopbWsmugYlzi5H93zcdK.jpeg', NULL, NULL, NULL, '2019-09-08 21:45:07', '2019-09-08 21:45:07');


--
-- TOC entry 5010 (class 0 OID 33108)
-- Dependencies: 236
-- Data for Name: plan_de_pagos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.plan_de_pagos VALUES (1, 50, 2, 1, 1, '2019-10-17 18:53:09', '2019-10-17 18:53:09', 1, 1);
INSERT INTO public.plan_de_pagos VALUES (3, -1, 50, 1, 10, '2019-10-17 18:56:10', '2019-10-17 18:56:10', 3, 1);
INSERT INTO public.plan_de_pagos VALUES (2, 100, 2, 1, 4, '2019-10-17 18:54:29', '2019-10-17 18:54:29', 2, 1);


--
-- TOC entry 5012 (class 0 OID 33112)
-- Dependencies: 238
-- Data for Name: producto_vendidos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.producto_vendidos VALUES (21, 1, 22.30, 67, 35, '', 22.30, NULL);
INSERT INTO public.producto_vendidos VALUES (22, 1, 32.00, 64, 35, '', 32.00, NULL);
INSERT INTO public.producto_vendidos VALUES (23, 1, 22.40, 66, 35, '', 22.40, NULL);
INSERT INTO public.producto_vendidos VALUES (24, 1, 55.60, 65, 35, '', 55.60, NULL);
INSERT INTO public.producto_vendidos VALUES (25, 1, 22.00, 63, 35, '', 22.00, NULL);
INSERT INTO public.producto_vendidos VALUES (26, 1, 22.30, 60, 35, '', 22.30, NULL);
INSERT INTO public.producto_vendidos VALUES (27, 1, 22.00, 63, 36, '', 22.00, NULL);
INSERT INTO public.producto_vendidos VALUES (28, 1, 55.60, 65, 36, '', 55.60, NULL);
INSERT INTO public.producto_vendidos VALUES (29, 2, 44.60, 62, 36, '', 22.30, NULL);
INSERT INTO public.producto_vendidos VALUES (30, 1, 22.30, 60, 36, '', 22.30, NULL);
INSERT INTO public.producto_vendidos VALUES (31, 4, 89.60, 66, 36, 'asdfasd', 22.40, NULL);
INSERT INTO public.producto_vendidos VALUES (32, 1, 32.00, 64, 36, '', 32.00, NULL);
INSERT INTO public.producto_vendidos VALUES (33, 1, 22.30, 67, 36, '', 22.30, NULL);
INSERT INTO public.producto_vendidos VALUES (34, 2, 11.00, 59, 36, '1 de pollo, 1 de carne', 5.50, NULL);
INSERT INTO public.producto_vendidos VALUES (35, 2, 111.20, 65, 37, '', 55.60, '2019-09-26 16:26:06.106098');
INSERT INTO public.producto_vendidos VALUES (36, 1, 32.00, 64, 37, '', 32.00, '2019-09-26 16:26:06.106098');
INSERT INTO public.producto_vendidos VALUES (37, 3, 16.50, 59, 37, '2 de pollo 1 de carne', 5.50, '2019-09-26 16:26:06.106098');
INSERT INTO public.producto_vendidos VALUES (38, 2, 44.00, 63, 37, '1 pierna y 1 ala', 22.00, '2019-09-26 16:26:06.106098');
INSERT INTO public.producto_vendidos VALUES (39, 1, 22.30, 67, 39, '', 22.30, '2019-09-26 16:45:52.097751');
INSERT INTO public.producto_vendidos VALUES (40, 1, 32.00, 64, 39, '', 32.00, '2019-09-26 16:45:52.097751');
INSERT INTO public.producto_vendidos VALUES (41, 1, 22.40, 66, 39, '', 22.40, '2019-09-26 16:45:52.097751');
INSERT INTO public.producto_vendidos VALUES (42, 1, 22.00, 63, 39, '', 22.00, '2019-09-26 16:45:52.097751');
INSERT INTO public.producto_vendidos VALUES (43, 1, 55.60, 65, 39, '', 55.60, '2019-09-26 16:45:52.097751');
INSERT INTO public.producto_vendidos VALUES (44, 1, 22.30, 67, 40, '', 22.30, '2019-09-26 17:20:50.686598');
INSERT INTO public.producto_vendidos VALUES (45, 1, 32.00, 64, 40, '', 32.00, '2019-09-26 17:20:50.686598');
INSERT INTO public.producto_vendidos VALUES (46, 1, 22.40, 66, 40, '', 22.40, '2019-09-26 17:20:50.686598');
INSERT INTO public.producto_vendidos VALUES (47, 1, 22.00, 63, 40, '', 22.00, '2019-09-26 17:20:50.686598');
INSERT INTO public.producto_vendidos VALUES (48, 1, 55.60, 65, 40, '', 55.60, '2019-09-26 17:20:50.686598');
INSERT INTO public.producto_vendidos VALUES (49, 1, 22.30, 67, 41, '', 22.30, '2019-09-26 17:21:37.410513');
INSERT INTO public.producto_vendidos VALUES (50, 1, 32.00, 64, 41, '', 32.00, '2019-09-26 17:21:37.410513');
INSERT INTO public.producto_vendidos VALUES (51, 1, 22.40, 66, 41, '', 22.40, '2019-09-26 17:21:37.410513');
INSERT INTO public.producto_vendidos VALUES (52, 1, 22.00, 63, 41, '', 22.00, '2019-09-26 17:21:37.410513');
INSERT INTO public.producto_vendidos VALUES (53, 1, 55.60, 65, 41, '', 55.60, '2019-09-26 17:21:37.410513');
INSERT INTO public.producto_vendidos VALUES (54, 1, 22.30, 67, 42, '', 22.30, '2019-09-26 17:22:05.960366');
INSERT INTO public.producto_vendidos VALUES (55, 1, 32.00, 64, 42, '', 32.00, '2019-09-26 17:22:05.960366');
INSERT INTO public.producto_vendidos VALUES (56, 1, 22.40, 66, 42, '', 22.40, '2019-09-26 17:22:05.960366');
INSERT INTO public.producto_vendidos VALUES (57, 1, 22.00, 63, 42, '', 22.00, '2019-09-26 17:22:05.960366');
INSERT INTO public.producto_vendidos VALUES (58, 1, 55.60, 65, 42, '', 55.60, '2019-09-26 17:22:05.960366');
INSERT INTO public.producto_vendidos VALUES (59, 1, 22.30, 67, 43, '', 22.30, '2019-09-26 17:22:52.484071');
INSERT INTO public.producto_vendidos VALUES (60, 1, 32.00, 64, 43, '', 32.00, '2019-09-26 17:22:52.484071');
INSERT INTO public.producto_vendidos VALUES (61, 1, 22.40, 66, 43, '', 22.40, '2019-09-26 17:22:52.484071');
INSERT INTO public.producto_vendidos VALUES (62, 1, 22.00, 63, 43, '', 22.00, '2019-09-26 17:22:52.484071');
INSERT INTO public.producto_vendidos VALUES (63, 1, 55.60, 65, 43, '', 55.60, '2019-09-26 17:22:52.484071');
INSERT INTO public.producto_vendidos VALUES (64, 1, 22.30, 67, 44, '', 22.30, '2019-09-26 17:23:28.613945');
INSERT INTO public.producto_vendidos VALUES (65, 1, 32.00, 64, 44, '', 32.00, '2019-09-26 17:23:28.613945');
INSERT INTO public.producto_vendidos VALUES (66, 1, 22.40, 66, 44, '', 22.40, '2019-09-26 17:23:28.613945');
INSERT INTO public.producto_vendidos VALUES (67, 1, 22.00, 63, 44, '', 22.00, '2019-09-26 17:23:28.613945');
INSERT INTO public.producto_vendidos VALUES (68, 1, 55.60, 65, 44, '', 55.60, '2019-09-26 17:23:28.613945');
INSERT INTO public.producto_vendidos VALUES (69, 1, 22.30, 67, 45, '', 22.30, '2019-09-26 17:23:50.176066');
INSERT INTO public.producto_vendidos VALUES (70, 1, 32.00, 64, 45, '', 32.00, '2019-09-26 17:23:50.176066');
INSERT INTO public.producto_vendidos VALUES (71, 1, 22.40, 66, 45, '', 22.40, '2019-09-26 17:23:50.176066');
INSERT INTO public.producto_vendidos VALUES (72, 1, 22.00, 63, 45, '', 22.00, '2019-09-26 17:23:50.176066');
INSERT INTO public.producto_vendidos VALUES (73, 1, 55.60, 65, 45, '', 55.60, '2019-09-26 17:23:50.176066');
INSERT INTO public.producto_vendidos VALUES (74, 1, 22.30, 67, 46, '', 22.30, '2019-09-26 17:29:11.148123');
INSERT INTO public.producto_vendidos VALUES (75, 1, 22.40, 66, 46, '', 22.40, '2019-09-26 17:29:11.148123');
INSERT INTO public.producto_vendidos VALUES (76, 1, 55.60, 65, 46, '', 55.60, '2019-09-26 17:29:11.148123');
INSERT INTO public.producto_vendidos VALUES (77, 1, 22.30, 60, 46, '', 22.30, '2019-09-26 17:29:11.148123');
INSERT INTO public.producto_vendidos VALUES (78, 1, 22.30, 67, 47, '', 22.30, '2019-09-26 17:32:17.173386');
INSERT INTO public.producto_vendidos VALUES (79, 1, 32.00, 64, 47, '', 32.00, '2019-09-26 17:32:17.173386');
INSERT INTO public.producto_vendidos VALUES (80, 1, 22.30, 60, 47, '', 22.30, '2019-09-26 17:32:17.173386');
INSERT INTO public.producto_vendidos VALUES (81, 1, 22.00, 63, 47, '', 22.00, '2019-09-26 17:32:17.173386');
INSERT INTO public.producto_vendidos VALUES (82, 1, 55.60, 65, 47, '', 55.60, '2019-09-26 17:32:17.173386');
INSERT INTO public.producto_vendidos VALUES (83, 1, 22.30, 67, 48, '', 22.30, '2019-09-26 17:34:28.560298');
INSERT INTO public.producto_vendidos VALUES (84, 1, 32.00, 64, 48, '', 32.00, '2019-09-26 17:34:28.560298');
INSERT INTO public.producto_vendidos VALUES (85, 1, 22.40, 66, 48, '', 22.40, '2019-09-26 17:34:28.560298');
INSERT INTO public.producto_vendidos VALUES (86, 1, 22.30, 67, 49, '', 22.30, '2019-09-26 17:40:17.736451');
INSERT INTO public.producto_vendidos VALUES (87, 1, 22.40, 66, 49, '', 22.40, '2019-09-26 17:40:17.736451');
INSERT INTO public.producto_vendidos VALUES (88, 2, 44.60, 60, 49, '', 22.30, '2019-09-26 17:40:17.736451');
INSERT INTO public.producto_vendidos VALUES (89, 1, 22.30, 67, 50, '', 22.30, '2019-09-26 18:00:30.325488');
INSERT INTO public.producto_vendidos VALUES (90, 1, 32.00, 64, 50, '', 32.00, '2019-09-26 18:00:30.325488');
INSERT INTO public.producto_vendidos VALUES (91, 1, 22.00, 63, 50, '', 22.00, '2019-09-26 18:00:30.325488');
INSERT INTO public.producto_vendidos VALUES (92, 1, 22.30, 67, 51, '', 22.30, '2019-09-26 18:08:07.225959');
INSERT INTO public.producto_vendidos VALUES (93, 1, 32.00, 64, 51, '', 32.00, '2019-09-26 18:08:07.225959');
INSERT INTO public.producto_vendidos VALUES (94, 1, 22.40, 66, 51, '', 22.40, '2019-09-26 18:08:07.225959');
INSERT INTO public.producto_vendidos VALUES (95, 1, 22.00, 63, 51, '', 22.00, '2019-09-26 18:08:07.225959');
INSERT INTO public.producto_vendidos VALUES (96, 1, 32.00, 64, 52, '', 32.00, '2019-09-26 18:14:00.857912');
INSERT INTO public.producto_vendidos VALUES (97, 1, 55.60, 65, 52, 'con llajua bastante', 55.60, '2019-09-26 18:14:00.857912');
INSERT INTO public.producto_vendidos VALUES (98, 1, 22.40, 66, 52, '', 22.40, '2019-09-26 18:14:00.857912');
INSERT INTO public.producto_vendidos VALUES (99, 1, 22.00, 63, 52, '1/2 presa pierna 1/2 presa ala', 22.00, '2019-09-26 18:14:00.857912');
INSERT INTO public.producto_vendidos VALUES (100, 1, 22.30, 60, 52, '', 22.30, '2019-09-26 18:14:00.857912');
INSERT INTO public.producto_vendidos VALUES (101, 1, 22.30, 67, 54, '', 22.30, '2019-09-26 18:18:57.869116');
INSERT INTO public.producto_vendidos VALUES (102, 1, 22.30, 67, 55, '', 22.30, '2019-09-26 18:30:04.838314');
INSERT INTO public.producto_vendidos VALUES (103, 1, 22.00, 63, 55, '', 22.00, '2019-09-26 18:30:04.838314');
INSERT INTO public.producto_vendidos VALUES (104, 1, 22.30, 61, 55, '', 22.30, '2019-09-26 18:30:04.838314');
INSERT INTO public.producto_vendidos VALUES (105, 1, 22.30, 60, 55, '', 22.30, '2019-09-26 18:30:04.838314');
INSERT INTO public.producto_vendidos VALUES (106, 1, 22.30, 67, 57, '', 22.30, '2019-09-26 22:21:54.192066');
INSERT INTO public.producto_vendidos VALUES (107, 1, 32.00, 64, 57, '', 32.00, '2019-09-26 22:21:54.192066');
INSERT INTO public.producto_vendidos VALUES (108, 1, 22.30, 67, 58, '', 22.30, '2019-09-26 22:23:47.010464');
INSERT INTO public.producto_vendidos VALUES (109, 1, 32.00, 64, 58, 'alkjsdfladsf', 32.00, '2019-09-26 22:23:47.010464');
INSERT INTO public.producto_vendidos VALUES (110, 1, 22.00, 63, 58, '', 22.00, '2019-09-26 22:23:47.010464');
INSERT INTO public.producto_vendidos VALUES (111, 3, 166.80, 65, 58, '', 55.60, '2019-09-26 22:23:47.010464');
INSERT INTO public.producto_vendidos VALUES (112, 1, 22.30, 67, 59, '', 22.30, '2019-09-26 22:35:13.561662');
INSERT INTO public.producto_vendidos VALUES (113, 1, 32.00, 64, 59, '', 32.00, '2019-09-26 22:35:13.561662');
INSERT INTO public.producto_vendidos VALUES (114, 1, 22.40, 66, 59, '', 22.40, '2019-09-26 22:35:13.561662');
INSERT INTO public.producto_vendidos VALUES (115, 1, 22.00, 63, 59, '', 22.00, '2019-09-26 22:35:13.561662');
INSERT INTO public.producto_vendidos VALUES (116, 1, 55.60, 65, 59, '', 55.60, '2019-09-26 22:35:13.561662');
INSERT INTO public.producto_vendidos VALUES (117, 1, 22.30, 67, 60, '', 22.30, '2019-09-26 22:38:20.988069');
INSERT INTO public.producto_vendidos VALUES (118, 4, 128.00, 64, 60, '1/4 de coccion', 32.00, '2019-09-26 22:38:20.988069');
INSERT INTO public.producto_vendidos VALUES (119, 1, 22.40, 66, 60, '', 22.40, '2019-09-26 22:38:20.988069');
INSERT INTO public.producto_vendidos VALUES (120, 1, 22.30, 60, 60, 'asdfadsfa', 22.30, '2019-09-26 22:38:20.988069');
INSERT INTO public.producto_vendidos VALUES (121, 1, 22.00, 63, 60, '', 22.00, '2019-09-26 22:38:20.988069');
INSERT INTO public.producto_vendidos VALUES (122, 1, 55.60, 65, 60, '', 55.60, '2019-09-26 22:38:20.988069');
INSERT INTO public.producto_vendidos VALUES (123, 1, 22.30, 67, 61, '', 22.30, '2019-09-26 22:43:13.674803');
INSERT INTO public.producto_vendidos VALUES (124, 3, 96.00, 64, 61, '1 sin mayonesa', 32.00, '2019-09-26 22:43:13.674803');
INSERT INTO public.producto_vendidos VALUES (125, 1, 22.40, 66, 61, 'con harta llajua', 22.40, '2019-09-26 22:43:13.674803');
INSERT INTO public.producto_vendidos VALUES (126, 1, 22.00, 63, 61, '', 22.00, '2019-09-26 22:43:13.674803');
INSERT INTO public.producto_vendidos VALUES (127, 2, 64.00, 64, 62, 'con arta mayonesa', 32.00, '2019-09-26 22:48:21.882153');
INSERT INTO public.producto_vendidos VALUES (128, 2, 44.00, 63, 62, '1 pierna 1 ala', 22.00, '2019-09-26 22:48:21.882153');
INSERT INTO public.producto_vendidos VALUES (129, 1, 22.30, 62, 62, '', 22.30, '2019-09-26 22:48:21.882153');
INSERT INTO public.producto_vendidos VALUES (130, 1, 22.30, 60, 63, '', 22.30, '2019-09-26 22:57:36.947387');
INSERT INTO public.producto_vendidos VALUES (131, 1, 22.00, 63, 63, '', 22.00, '2019-09-26 22:57:36.947387');
INSERT INTO public.producto_vendidos VALUES (132, 1, 22.30, 61, 63, '', 22.30, '2019-09-26 22:57:36.947387');
INSERT INTO public.producto_vendidos VALUES (133, 1, 22.30, 67, 63, '', 22.30, '2019-09-26 22:57:36.947387');
INSERT INTO public.producto_vendidos VALUES (134, 1, 22.30, 62, 63, '', 22.30, '2019-09-26 22:57:36.947387');
INSERT INTO public.producto_vendidos VALUES (135, 2, 44.60, 67, 64, '', 22.30, '2019-09-26 23:02:54.760724');
INSERT INTO public.producto_vendidos VALUES (136, 2, 44.00, 63, 64, '', 22.00, '2019-09-26 23:02:54.760724');
INSERT INTO public.producto_vendidos VALUES (137, 2, 44.60, 61, 64, '', 22.30, '2019-09-26 23:02:54.760724');
INSERT INTO public.producto_vendidos VALUES (138, 2, 44.60, 62, 64, '', 22.30, '2019-09-26 23:02:54.760724');
INSERT INTO public.producto_vendidos VALUES (139, 2, 44.60, 60, 64, '', 22.30, '2019-09-26 23:02:54.760724');
INSERT INTO public.producto_vendidos VALUES (140, 1, 55.60, 65, 64, '', 55.60, '2019-09-26 23:02:54.760724');
INSERT INTO public.producto_vendidos VALUES (141, 1, 5.50, 59, 64, '', 5.50, '2019-09-26 23:02:54.760724');
INSERT INTO public.producto_vendidos VALUES (142, 1, 22.40, 66, 64, '', 22.40, '2019-09-26 23:02:54.760724');
INSERT INTO public.producto_vendidos VALUES (143, 1, 32.00, 64, 64, '', 32.00, '2019-09-26 23:02:54.760724');
INSERT INTO public.producto_vendidos VALUES (144, 1, 22.30, 67, 65, '', 22.30, '2019-09-27 10:15:54.167028');
INSERT INTO public.producto_vendidos VALUES (145, 1, 32.00, 64, 65, '', 32.00, '2019-09-27 10:15:54.167028');
INSERT INTO public.producto_vendidos VALUES (146, 1, 22.00, 63, 65, '', 22.00, '2019-09-27 10:15:54.167028');
INSERT INTO public.producto_vendidos VALUES (147, 1, 55.60, 65, 65, '', 55.60, '2019-09-27 10:15:54.167028');
INSERT INTO public.producto_vendidos VALUES (148, 1, 22.30, 60, 65, '', 22.30, '2019-09-27 10:15:54.167028');
INSERT INTO public.producto_vendidos VALUES (149, 3, 16.50, 59, 66, '', 5.50, '2019-09-27 11:37:30.172222');
INSERT INTO public.producto_vendidos VALUES (150, 2, 44.60, 60, 66, 'sin salsa', 22.30, '2019-09-27 11:37:30.172222');
INSERT INTO public.producto_vendidos VALUES (151, 3, 66.00, 63, 66, '2 piernas, 1 ala', 22.00, '2019-09-27 11:37:30.172222');
INSERT INTO public.producto_vendidos VALUES (152, 1, 22.30, 67, 66, 'sin tostar', 22.30, '2019-09-27 11:37:30.172222');
INSERT INTO public.producto_vendidos VALUES (153, 3, 66.90, 67, 67, '', 22.30, '2019-09-27 18:47:23.637706');
INSERT INTO public.producto_vendidos VALUES (154, 3, 66.00, 63, 67, '', 22.00, '2019-09-27 18:47:23.637706');
INSERT INTO public.producto_vendidos VALUES (155, 3, 66.90, 60, 67, '', 22.30, '2019-09-27 18:47:23.637706');
INSERT INTO public.producto_vendidos VALUES (156, 1, 22.30, 61, 67, '', 22.30, '2019-09-27 18:47:23.637706');
INSERT INTO public.producto_vendidos VALUES (157, 1, 22.30, 62, 67, '', 22.30, '2019-09-27 18:47:23.637706');
INSERT INTO public.producto_vendidos VALUES (158, 2, 11.00, 59, 67, '', 5.50, '2019-09-27 18:47:23.637706');
INSERT INTO public.producto_vendidos VALUES (159, 1, 5.50, 59, 68, '', 5.50, '2019-09-29 21:04:49.449386');
INSERT INTO public.producto_vendidos VALUES (160, 1, 22.30, 67, 69, '', 22.30, '2019-09-30 17:52:05.62887');
INSERT INTO public.producto_vendidos VALUES (161, 1, 32.00, 64, 69, '', 32.00, '2019-09-30 17:52:05.62887');
INSERT INTO public.producto_vendidos VALUES (162, 1, 22.30, 60, 69, '', 22.30, '2019-09-30 17:52:05.62887');
INSERT INTO public.producto_vendidos VALUES (163, 1, 22.30, 67, 70, '', 22.30, '2019-09-30 18:25:11.337237');
INSERT INTO public.producto_vendidos VALUES (164, 1, 22.00, 63, 70, '', 22.00, '2019-09-30 18:25:11.337237');
INSERT INTO public.producto_vendidos VALUES (165, 1, 22.30, 60, 70, '', 22.30, '2019-09-30 18:25:11.337237');
INSERT INTO public.producto_vendidos VALUES (166, 1, 22.30, 62, 70, '', 22.30, '2019-09-30 18:25:11.337237');
INSERT INTO public.producto_vendidos VALUES (167, 1, 22.30, 67, 71, '', 22.30, '2019-09-30 18:42:30.966223');
INSERT INTO public.producto_vendidos VALUES (168, 1, 32.00, 64, 71, '', 32.00, '2019-09-30 18:42:30.966223');
INSERT INTO public.producto_vendidos VALUES (169, 1, 22.40, 66, 71, '', 22.40, '2019-09-30 18:42:30.966223');
INSERT INTO public.producto_vendidos VALUES (170, 1, 22.30, 60, 71, '', 22.30, '2019-09-30 18:42:30.966223');
INSERT INTO public.producto_vendidos VALUES (171, 1, 22.00, 63, 71, '', 22.00, '2019-09-30 18:42:30.966223');
INSERT INTO public.producto_vendidos VALUES (172, 1, 55.60, 65, 71, '', 55.60, '2019-09-30 18:42:30.966223');
INSERT INTO public.producto_vendidos VALUES (173, 1, 22.30, 67, 72, '', 22.30, '2019-09-30 21:48:24.882346');
INSERT INTO public.producto_vendidos VALUES (174, 1, 32.00, 64, 72, '', 32.00, '2019-09-30 21:48:24.882346');
INSERT INTO public.producto_vendidos VALUES (175, 1, 5.50, 59, 72, '', 5.50, '2019-09-30 21:48:24.882346');
INSERT INTO public.producto_vendidos VALUES (176, 2, 44.60, 61, 72, '', 22.30, '2019-09-30 21:48:24.882346');
INSERT INTO public.producto_vendidos VALUES (177, 1, 22.00, 63, 73, '', 22.00, '2019-10-01 07:19:04.39463');
INSERT INTO public.producto_vendidos VALUES (178, 3, 166.80, 65, 73, '', 55.60, '2019-10-01 07:19:04.39463');
INSERT INTO public.producto_vendidos VALUES (179, 2, 44.60, 67, 73, '', 22.30, '2019-10-01 07:19:04.39463');
INSERT INTO public.producto_vendidos VALUES (180, 2, 44.60, 62, 73, '', 22.30, '2019-10-01 07:19:04.39463');
INSERT INTO public.producto_vendidos VALUES (181, 1, 22.30, 67, 74, '', 22.30, '2019-10-01 09:27:12.035788');
INSERT INTO public.producto_vendidos VALUES (182, 1, 32.00, 64, 74, '', 32.00, '2019-10-01 09:27:12.035788');
INSERT INTO public.producto_vendidos VALUES (183, 1, 55.60, 65, 74, '', 55.60, '2019-10-01 09:27:12.035788');
INSERT INTO public.producto_vendidos VALUES (184, 1, 22.40, 66, 74, '', 22.40, '2019-10-01 09:27:12.035788');
INSERT INTO public.producto_vendidos VALUES (185, 1, 22.30, 61, 74, '', 22.30, '2019-10-01 09:27:12.035788');
INSERT INTO public.producto_vendidos VALUES (186, 1, 22.30, 67, 75, '', 22.30, '2019-10-01 11:23:59.970169');
INSERT INTO public.producto_vendidos VALUES (187, 1, 32.00, 64, 75, '', 32.00, '2019-10-01 11:23:59.970169');
INSERT INTO public.producto_vendidos VALUES (188, 1, 22.00, 63, 75, '', 22.00, '2019-10-01 11:23:59.970169');
INSERT INTO public.producto_vendidos VALUES (189, 1, 5.50, 59, 76, '', 5.50, '2019-10-01 11:24:15.270736');
INSERT INTO public.producto_vendidos VALUES (190, 1, 55.60, 65, 76, '', 55.60, '2019-10-01 11:24:15.270736');
INSERT INTO public.producto_vendidos VALUES (191, 1, 32.00, 64, 76, '', 32.00, '2019-10-01 11:24:15.270736');
INSERT INTO public.producto_vendidos VALUES (192, 1, 55.60, 65, 77, '', 55.60, '2019-10-01 11:24:42.529657');
INSERT INTO public.producto_vendidos VALUES (193, 1, 22.00, 63, 77, '', 22.00, '2019-10-01 11:24:42.529657');
INSERT INTO public.producto_vendidos VALUES (194, 1, 22.30, 62, 77, '', 22.30, '2019-10-01 11:24:42.529657');
INSERT INTO public.producto_vendidos VALUES (195, 1, 22.30, 61, 77, '', 22.30, '2019-10-01 11:24:42.529657');
INSERT INTO public.producto_vendidos VALUES (196, 1, 22.40, 66, 78, '', 22.40, '2019-10-01 11:24:56.898089');
INSERT INTO public.producto_vendidos VALUES (197, 1, 32.00, 64, 78, '', 32.00, '2019-10-01 11:24:56.898089');
INSERT INTO public.producto_vendidos VALUES (198, 1, 22.30, 67, 78, '', 22.30, '2019-10-01 11:24:56.898089');
INSERT INTO public.producto_vendidos VALUES (199, 1, 22.30, 67, 79, '', 22.30, '2019-10-01 12:52:36.461853');
INSERT INTO public.producto_vendidos VALUES (200, 1, 32.00, 64, 79, '', 32.00, '2019-10-01 12:52:36.461853');
INSERT INTO public.producto_vendidos VALUES (201, 1, 22.40, 66, 79, '', 22.40, '2019-10-01 12:52:36.461853');
INSERT INTO public.producto_vendidos VALUES (202, 1, 22.30, 67, 80, '', 22.30, '2019-10-01 12:55:32.122676');
INSERT INTO public.producto_vendidos VALUES (203, 1, 32.00, 64, 80, '', 32.00, '2019-10-01 12:55:32.122676');
INSERT INTO public.producto_vendidos VALUES (204, 1, 22.00, 63, 80, '', 22.00, '2019-10-01 12:55:32.122676');
INSERT INTO public.producto_vendidos VALUES (205, 1, 55.60, 65, 80, '', 55.60, '2019-10-01 12:55:32.122676');
INSERT INTO public.producto_vendidos VALUES (206, 1, 22.30, 67, 81, '', 22.30, '2019-10-01 12:57:52.546242');
INSERT INTO public.producto_vendidos VALUES (207, 1, 22.00, 63, 81, '', 22.00, '2019-10-01 12:57:52.546242');
INSERT INTO public.producto_vendidos VALUES (208, 1, 22.30, 60, 81, '', 22.30, '2019-10-01 12:57:52.546242');
INSERT INTO public.producto_vendidos VALUES (209, 1, 22.30, 61, 81, '', 22.30, '2019-10-01 12:57:52.546242');
INSERT INTO public.producto_vendidos VALUES (210, 1, 22.00, 63, 82, '', 22.00, '2019-10-01 18:25:16.536811');
INSERT INTO public.producto_vendidos VALUES (211, 1, 55.60, 65, 82, '', 55.60, '2019-10-01 18:25:16.536811');
INSERT INTO public.producto_vendidos VALUES (212, 1, 22.30, 67, 82, '', 22.30, '2019-10-01 18:25:16.536811');
INSERT INTO public.producto_vendidos VALUES (213, 1, 32.00, 64, 82, '', 32.00, '2019-10-01 18:25:16.536811');
INSERT INTO public.producto_vendidos VALUES (214, 1, 22.40, 66, 82, '', 22.40, '2019-10-01 18:25:16.536811');
INSERT INTO public.producto_vendidos VALUES (215, 1, 22.30, 60, 82, '', 22.30, '2019-10-01 18:25:16.536811');
INSERT INTO public.producto_vendidos VALUES (216, 1, 22.30, 67, 83, '', 22.30, '2019-10-01 18:27:30.973578');
INSERT INTO public.producto_vendidos VALUES (217, 1, 22.00, 63, 83, '', 22.00, '2019-10-01 18:27:30.973578');
INSERT INTO public.producto_vendidos VALUES (218, 1, 22.30, 67, 84, '', 22.30, '2019-10-01 18:30:35.247694');
INSERT INTO public.producto_vendidos VALUES (219, 1, 32.00, 64, 84, '', 32.00, '2019-10-01 18:30:35.247694');
INSERT INTO public.producto_vendidos VALUES (220, 1, 55.60, 65, 84, '', 55.60, '2019-10-01 18:30:35.247694');
INSERT INTO public.producto_vendidos VALUES (221, 1, 22.30, 62, 84, '', 22.30, '2019-10-01 18:30:35.247694');
INSERT INTO public.producto_vendidos VALUES (222, 1, 22.30, 67, 85, '', 22.30, '2019-10-01 18:32:29.820095');
INSERT INTO public.producto_vendidos VALUES (223, 1, 32.00, 64, 85, '', 32.00, '2019-10-01 18:32:29.820095');
INSERT INTO public.producto_vendidos VALUES (224, 1, 22.40, 66, 85, '', 22.40, '2019-10-01 18:32:29.820095');
INSERT INTO public.producto_vendidos VALUES (225, 1, 22.30, 60, 85, '', 22.30, '2019-10-01 18:32:29.820095');
INSERT INTO public.producto_vendidos VALUES (226, 1, 22.00, 63, 85, '', 22.00, '2019-10-01 18:32:29.820095');
INSERT INTO public.producto_vendidos VALUES (227, 1, 55.60, 65, 85, '', 55.60, '2019-10-01 18:32:29.820095');
INSERT INTO public.producto_vendidos VALUES (228, 1, 22.30, 67, 86, '', 22.30, '2019-10-01 18:35:58.504628');
INSERT INTO public.producto_vendidos VALUES (229, 1, 32.00, 64, 86, '', 32.00, '2019-10-01 18:35:58.504628');
INSERT INTO public.producto_vendidos VALUES (230, 1, 22.40, 66, 86, '', 22.40, '2019-10-01 18:35:58.504628');
INSERT INTO public.producto_vendidos VALUES (231, 1, 22.00, 63, 86, '', 22.00, '2019-10-01 18:35:58.504628');
INSERT INTO public.producto_vendidos VALUES (232, 2, 44.60, 67, 87, '1 con arta mayonesa, 1 sin llajua', 22.30, '2019-10-01 18:40:05.238907');
INSERT INTO public.producto_vendidos VALUES (233, 2, 11.00, 59, 87, '', 5.50, '2019-10-01 18:40:05.238907');
INSERT INTO public.producto_vendidos VALUES (234, 1, 22.30, 67, 88, '', 22.30, '2019-10-01 18:48:27.618131');
INSERT INTO public.producto_vendidos VALUES (235, 1, 32.00, 64, 88, '', 32.00, '2019-10-01 18:48:27.618131');
INSERT INTO public.producto_vendidos VALUES (236, 1, 22.00, 63, 88, '', 22.00, '2019-10-01 18:48:27.618131');
INSERT INTO public.producto_vendidos VALUES (237, 1, 55.60, 65, 88, '', 55.60, '2019-10-01 18:48:27.618131');
INSERT INTO public.producto_vendidos VALUES (238, 1, 22.30, 62, 88, '', 22.30, '2019-10-01 18:48:27.618131');
INSERT INTO public.producto_vendidos VALUES (239, 1, 22.30, 61, 88, '', 22.30, '2019-10-01 18:48:27.618131');
INSERT INTO public.producto_vendidos VALUES (240, 2, 44.60, 67, 89, '', 22.30, '2019-10-01 18:50:25.714134');
INSERT INTO public.producto_vendidos VALUES (241, 2, 44.60, 60, 89, '1 pierna, 1 ala', 22.30, '2019-10-01 18:50:25.714134');
INSERT INTO public.producto_vendidos VALUES (242, 2, 44.60, 67, 90, '', 22.30, '2019-10-01 18:56:55.011187');
INSERT INTO public.producto_vendidos VALUES (243, 2, 44.00, 63, 90, '', 22.00, '2019-10-01 18:56:55.011187');
INSERT INTO public.producto_vendidos VALUES (244, 1, 22.30, 60, 90, '', 22.30, '2019-10-01 18:56:55.011187');
INSERT INTO public.producto_vendidos VALUES (245, 1, 22.30, 62, 90, '', 22.30, '2019-10-01 18:56:55.011187');
INSERT INTO public.producto_vendidos VALUES (246, 1, 22.30, 67, 91, '', 22.30, '2019-10-01 18:58:16.125897');
INSERT INTO public.producto_vendidos VALUES (247, 1, 55.60, 65, 91, '', 55.60, '2019-10-01 18:58:16.125897');
INSERT INTO public.producto_vendidos VALUES (248, 1, 22.00, 63, 91, '', 22.00, '2019-10-01 18:58:16.125897');
INSERT INTO public.producto_vendidos VALUES (249, 1, 22.30, 62, 91, '', 22.30, '2019-10-01 18:58:16.125897');
INSERT INTO public.producto_vendidos VALUES (250, 1, 22.30, 67, 92, '', 22.30, '2019-10-01 23:24:40.272299');
INSERT INTO public.producto_vendidos VALUES (251, 1, 22.00, 63, 92, '', 22.00, '2019-10-01 23:24:40.272299');
INSERT INTO public.producto_vendidos VALUES (252, 1, 22.30, 60, 92, '', 22.30, '2019-10-01 23:24:40.272299');
INSERT INTO public.producto_vendidos VALUES (253, 1, 5.50, 59, 92, '', 5.50, '2019-10-01 23:24:40.272299');
INSERT INTO public.producto_vendidos VALUES (254, 1, 22.30, 62, 92, '', 22.30, '2019-10-01 23:24:40.272299');
INSERT INTO public.producto_vendidos VALUES (255, 1, 22.30, 61, 92, '', 22.30, '2019-10-01 23:24:40.272299');
INSERT INTO public.producto_vendidos VALUES (256, 2, 11.00, 59, 93, '1 pollo, 1 carne', 5.50, '2019-10-01 23:26:59.625485');
INSERT INTO public.producto_vendidos VALUES (257, 1, 22.30, 62, 94, 'con arta mayonesa', 22.30, '2019-10-01 23:31:54.758957');
INSERT INTO public.producto_vendidos VALUES (258, 1, 55.60, 65, 95, '', 55.60, '2019-10-01 23:34:29.729336');
INSERT INTO public.producto_vendidos VALUES (259, 2, 11.00, 59, 95, '', 5.50, '2019-10-01 23:34:29.729336');
INSERT INTO public.producto_vendidos VALUES (260, 1, 22.40, 66, 96, '', 22.40, '2019-10-01 23:37:31.261262');
INSERT INTO public.producto_vendidos VALUES (261, 1, 55.60, 65, 96, '', 55.60, '2019-10-01 23:37:31.261262');
INSERT INTO public.producto_vendidos VALUES (262, 1, 22.30, 60, 96, '', 22.30, '2019-10-01 23:37:31.261262');
INSERT INTO public.producto_vendidos VALUES (263, 1, 22.00, 63, 96, '', 22.00, '2019-10-01 23:37:31.261262');
INSERT INTO public.producto_vendidos VALUES (264, 3, 16.50, 59, 96, '', 5.50, '2019-10-01 23:37:31.261262');
INSERT INTO public.producto_vendidos VALUES (265, 2, 44.00, 63, 97, '', 22.00, '2019-10-02 08:46:53.364911');
INSERT INTO public.producto_vendidos VALUES (266, 1, 55.60, 65, 97, '', 55.60, '2019-10-02 08:46:53.364911');
INSERT INTO public.producto_vendidos VALUES (267, 1, 22.30, 67, 97, '', 22.30, '2019-10-02 08:46:53.364911');
INSERT INTO public.producto_vendidos VALUES (268, 1, 32.00, 64, 97, '', 32.00, '2019-10-02 08:46:53.364911');
INSERT INTO public.producto_vendidos VALUES (269, 1, 22.40, 66, 97, '', 22.40, '2019-10-02 08:46:53.364911');
INSERT INTO public.producto_vendidos VALUES (270, 1, 22.30, 60, 97, '', 22.30, '2019-10-02 08:46:53.364911');
INSERT INTO public.producto_vendidos VALUES (271, 1, 22.30, 62, 97, '', 22.30, '2019-10-02 08:46:53.364911');
INSERT INTO public.producto_vendidos VALUES (272, 1, 22.30, 67, 98, '', 22.30, '2019-10-02 08:54:37.531683');
INSERT INTO public.producto_vendidos VALUES (273, 1, 22.00, 63, 98, '', 22.00, '2019-10-02 08:54:37.531683');
INSERT INTO public.producto_vendidos VALUES (274, 1, 5.50, 59, 98, '', 5.50, '2019-10-02 08:54:37.531683');
INSERT INTO public.producto_vendidos VALUES (275, 4, 89.20, 62, 98, 'no tiene', 22.30, '2019-10-02 08:54:37.531683');
INSERT INTO public.producto_vendidos VALUES (276, 1, 22.30, 67, 99, '', 22.30, '2019-10-02 09:16:46.546895');
INSERT INTO public.producto_vendidos VALUES (277, 1, 22.00, 63, 99, '', 22.00, '2019-10-02 09:16:46.546895');
INSERT INTO public.producto_vendidos VALUES (278, 1, 22.30, 62, 99, '', 22.30, '2019-10-02 09:16:46.546895');
INSERT INTO public.producto_vendidos VALUES (279, 3, 66.90, 60, 99, '', 22.30, '2019-10-02 09:16:46.546895');
INSERT INTO public.producto_vendidos VALUES (280, 3, 67.20, 66, 99, '', 22.40, '2019-10-02 09:16:46.546895');
INSERT INTO public.producto_vendidos VALUES (281, 1, 22.30, 67, 100, '', 22.30, '2019-10-02 09:20:17.690337');
INSERT INTO public.producto_vendidos VALUES (282, 1, 32.00, 64, 100, '', 32.00, '2019-10-02 09:20:17.690337');
INSERT INTO public.producto_vendidos VALUES (283, 1, 22.00, 63, 100, '', 22.00, '2019-10-02 09:20:17.690337');
INSERT INTO public.producto_vendidos VALUES (284, 1, 22.30, 60, 100, '', 22.30, '2019-10-02 09:20:17.690337');
INSERT INTO public.producto_vendidos VALUES (285, 1, 22.30, 62, 100, '', 22.30, '2019-10-02 09:20:17.690337');
INSERT INTO public.producto_vendidos VALUES (286, 1, 22.30, 67, 101, '', 22.30, '2019-10-02 09:22:08.009652');
INSERT INTO public.producto_vendidos VALUES (287, 1, 22.00, 63, 101, '', 22.00, '2019-10-02 09:22:08.009652');
INSERT INTO public.producto_vendidos VALUES (288, 1, 22.30, 60, 101, '', 22.30, '2019-10-02 09:22:08.009652');
INSERT INTO public.producto_vendidos VALUES (289, 1, 5.50, 59, 101, '', 5.50, '2019-10-02 09:22:08.009652');
INSERT INTO public.producto_vendidos VALUES (290, 1, 22.30, 62, 101, '', 22.30, '2019-10-02 09:22:08.009652');
INSERT INTO public.producto_vendidos VALUES (291, 1, 22.30, 67, 102, '', 22.30, '2019-10-02 09:30:51.493918');
INSERT INTO public.producto_vendidos VALUES (292, 1, 32.00, 64, 102, '', 32.00, '2019-10-02 09:30:51.493918');
INSERT INTO public.producto_vendidos VALUES (293, 1, 22.00, 63, 102, '', 22.00, '2019-10-02 09:30:51.493918');
INSERT INTO public.producto_vendidos VALUES (294, 1, 55.60, 65, 102, '', 55.60, '2019-10-02 09:30:51.493918');
INSERT INTO public.producto_vendidos VALUES (295, 1, 22.30, 60, 102, '', 22.30, '2019-10-02 09:30:51.493918');
INSERT INTO public.producto_vendidos VALUES (296, 1, 32.00, 64, 103, '', 32.00, '2019-10-02 09:57:09.400517');
INSERT INTO public.producto_vendidos VALUES (297, 1, 22.00, 63, 103, '', 22.00, '2019-10-02 09:57:09.400517');
INSERT INTO public.producto_vendidos VALUES (298, 1, 55.60, 65, 103, '', 55.60, '2019-10-02 09:57:09.400517');
INSERT INTO public.producto_vendidos VALUES (299, 1, 22.30, 61, 103, '', 22.30, '2019-10-02 09:57:09.400517');
INSERT INTO public.producto_vendidos VALUES (300, 1, 22.30, 62, 103, '', 22.30, '2019-10-02 09:57:09.400517');
INSERT INTO public.producto_vendidos VALUES (301, 1, 22.30, 60, 103, '', 22.30, '2019-10-02 09:57:09.400517');
INSERT INTO public.producto_vendidos VALUES (302, 1, 5.50, 59, 104, '', 5.50, '2019-10-02 09:59:11.550771');
INSERT INTO public.producto_vendidos VALUES (303, 1, 22.30, 67, 105, '', 22.30, '2019-10-02 10:01:27.928529');
INSERT INTO public.producto_vendidos VALUES (304, 1, 22.00, 63, 105, '', 22.00, '2019-10-02 10:01:27.928529');
INSERT INTO public.producto_vendidos VALUES (305, 1, 55.60, 65, 105, '', 55.60, '2019-10-02 10:01:27.928529');
INSERT INTO public.producto_vendidos VALUES (306, 1, 22.30, 62, 105, '', 22.30, '2019-10-02 10:01:27.928529');
INSERT INTO public.producto_vendidos VALUES (307, 1, 22.30, 61, 105, '', 22.30, '2019-10-02 10:01:27.928529');
INSERT INTO public.producto_vendidos VALUES (308, 1, 5.50, 59, 105, '', 5.50, '2019-10-02 10:01:27.928529');
INSERT INTO public.producto_vendidos VALUES (309, 1, 55.60, 65, 106, '', 55.60, '2019-10-02 10:06:20.01755');
INSERT INTO public.producto_vendidos VALUES (310, 1, 32.00, 64, 106, '', 32.00, '2019-10-02 10:06:20.01755');
INSERT INTO public.producto_vendidos VALUES (311, 3, 66.90, 60, 106, '', 22.30, '2019-10-02 10:06:20.01755');
INSERT INTO public.producto_vendidos VALUES (312, 1, 22.00, 63, 106, '', 22.00, '2019-10-02 10:06:20.01755');
INSERT INTO public.producto_vendidos VALUES (313, 2, 44.60, 62, 106, '', 22.30, '2019-10-02 10:06:20.01755');
INSERT INTO public.producto_vendidos VALUES (314, 1, 22.30, 67, 107, '', 22.30, '2019-10-02 10:09:49.74494');
INSERT INTO public.producto_vendidos VALUES (315, 1, 22.00, 63, 107, '', 22.00, '2019-10-02 10:09:49.74494');
INSERT INTO public.producto_vendidos VALUES (316, 1, 22.30, 60, 107, '', 22.30, '2019-10-02 10:09:49.74494');
INSERT INTO public.producto_vendidos VALUES (317, 1, 22.40, 66, 107, '', 22.40, '2019-10-02 10:09:49.74494');
INSERT INTO public.producto_vendidos VALUES (318, 1, 22.30, 62, 107, '', 22.30, '2019-10-02 10:09:49.74494');
INSERT INTO public.producto_vendidos VALUES (319, 1, 22.30, 67, 108, '', 22.30, '2019-10-02 10:13:40.015487');
INSERT INTO public.producto_vendidos VALUES (320, 1, 22.00, 63, 108, '', 22.00, '2019-10-02 10:13:40.015487');
INSERT INTO public.producto_vendidos VALUES (321, 1, 5.50, 59, 108, '', 5.50, '2019-10-02 10:13:40.015487');
INSERT INTO public.producto_vendidos VALUES (322, 1, 22.30, 62, 108, '', 22.30, '2019-10-02 10:13:40.015487');
INSERT INTO public.producto_vendidos VALUES (323, 1, 22.30, 61, 108, '', 22.30, '2019-10-02 10:13:40.015487');
INSERT INTO public.producto_vendidos VALUES (324, 1, 22.30, 60, 108, '', 22.30, '2019-10-02 10:13:40.015487');
INSERT INTO public.producto_vendidos VALUES (325, 1, 5.50, 59, 109, '', 5.50, '2019-10-02 10:18:15.383024');
INSERT INTO public.producto_vendidos VALUES (326, 1, 22.40, 66, 109, '', 22.40, '2019-10-02 10:18:15.383024');
INSERT INTO public.producto_vendidos VALUES (327, 1, 55.60, 65, 109, '', 55.60, '2019-10-02 10:18:15.383024');
INSERT INTO public.producto_vendidos VALUES (328, 1, 52.50, 69, 110, '', 52.50, '2019-10-02 11:51:14.826714');
INSERT INTO public.producto_vendidos VALUES (329, 1, 22.30, 67, 110, '', 22.30, '2019-10-02 11:51:14.826714');
INSERT INTO public.producto_vendidos VALUES (330, 1, 22.40, 66, 110, '', 22.40, '2019-10-02 11:51:14.826714');
INSERT INTO public.producto_vendidos VALUES (331, 1, 22.30, 62, 110, '', 22.30, '2019-10-02 11:51:14.826714');
INSERT INTO public.producto_vendidos VALUES (332, 1, 16.50, 68, 110, '', 16.50, '2019-10-02 11:51:14.826714');
INSERT INTO public.producto_vendidos VALUES (333, 1, 55.60, 65, 110, '', 55.60, '2019-10-02 11:51:14.826714');
INSERT INTO public.producto_vendidos VALUES (334, 1, 1.50, 71, 111, '', 1.50, '2019-10-02 11:57:15.142334');
INSERT INTO public.producto_vendidos VALUES (335, 1, 16.50, 68, 111, '', 16.50, '2019-10-02 11:57:15.142334');
INSERT INTO public.producto_vendidos VALUES (336, 1, 10.50, 80, 112, '', 10.50, '2019-10-02 12:13:54.501143');
INSERT INTO public.producto_vendidos VALUES (337, 1, 15.00, 75, 112, '', 15.00, '2019-10-02 12:13:54.501143');
INSERT INTO public.producto_vendidos VALUES (338, 1, 52.50, 69, 112, '', 52.50, '2019-10-02 12:13:54.501143');
INSERT INTO public.producto_vendidos VALUES (339, 1, 22.30, 67, 112, '', 22.30, '2019-10-02 12:13:54.501143');
INSERT INTO public.producto_vendidos VALUES (340, 1, 2.00, 73, 112, '', 2.00, '2019-10-02 12:13:54.501143');
INSERT INTO public.producto_vendidos VALUES (341, 1, 2.50, 78, 112, '', 2.50, '2019-10-02 12:13:54.501143');
INSERT INTO public.producto_vendidos VALUES (342, 1, 2.50, 76, 113, '1 cucharilla de azucar', 2.50, '2019-10-02 12:19:57.041477');
INSERT INTO public.producto_vendidos VALUES (343, 1, 2.00, 73, 113, 'con crema', 2.00, '2019-10-02 12:19:57.041477');
INSERT INTO public.producto_vendidos VALUES (344, 1, 2.50, 78, 113, 'sin azucar', 2.50, '2019-10-02 12:19:57.041477');
INSERT INTO public.producto_vendidos VALUES (345, 1, 1.50, 72, 113, '', 1.50, '2019-10-02 12:19:57.041477');
INSERT INTO public.producto_vendidos VALUES (346, 1, 2.50, 76, 114, '', 2.50, '2019-10-02 18:18:40.236733');
INSERT INTO public.producto_vendidos VALUES (347, 1, 1.50, 79, 114, '', 1.50, '2019-10-02 18:18:40.236733');
INSERT INTO public.producto_vendidos VALUES (348, 2, 33.00, 68, 114, '', 16.50, '2019-10-02 18:18:40.236733');
INSERT INTO public.producto_vendidos VALUES (349, 2, 4.00, 85, 115, '', 2.00, '2019-10-02 19:01:59.587841');
INSERT INTO public.producto_vendidos VALUES (350, 1, 16.50, 68, 115, '', 16.50, '2019-10-02 19:01:59.587841');
INSERT INTO public.producto_vendidos VALUES (351, 1, 1.50, 71, 115, '', 1.50, '2019-10-02 19:01:59.587841');
INSERT INTO public.producto_vendidos VALUES (352, 1, 1.50, 72, 115, '', 1.50, '2019-10-02 19:01:59.587841');
INSERT INTO public.producto_vendidos VALUES (353, 1, 2.50, 76, 116, '', 2.50, '2019-10-03 07:13:10.574585');
INSERT INTO public.producto_vendidos VALUES (354, 1, 5.50, 74, 116, '', 5.50, '2019-10-03 07:13:10.574585');
INSERT INTO public.producto_vendidos VALUES (355, 1, 2.50, 76, 118, '', 2.50, '2019-10-03 09:18:18.309433');
INSERT INTO public.producto_vendidos VALUES (356, 1, 55.00, 77, 118, '', 55.00, '2019-10-03 09:18:18.309433');
INSERT INTO public.producto_vendidos VALUES (357, 1, 2.50, 76, 119, '', 2.50, '2019-10-03 09:27:11.194471');
INSERT INTO public.producto_vendidos VALUES (358, 1, 55.00, 77, 119, '', 55.00, '2019-10-03 09:27:11.194471');
INSERT INTO public.producto_vendidos VALUES (359, 1, 5.50, 74, 119, '', 5.50, '2019-10-03 09:27:11.194471');
INSERT INTO public.producto_vendidos VALUES (360, 1, 8.50, 70, 119, '', 8.50, '2019-10-03 09:27:11.194471');
INSERT INTO public.producto_vendidos VALUES (361, 1, 1.50, 72, 119, '', 1.50, '2019-10-03 09:27:11.194471');
INSERT INTO public.producto_vendidos VALUES (362, 1, 8.50, 70, 120, '', 8.50, '2019-10-03 09:35:08.835419');
INSERT INTO public.producto_vendidos VALUES (363, 1, 5.50, 74, 120, '', 5.50, '2019-10-03 09:35:08.835419');
INSERT INTO public.producto_vendidos VALUES (364, 1, 55.00, 77, 120, '', 55.00, '2019-10-03 09:35:08.835419');
INSERT INTO public.producto_vendidos VALUES (365, 1, 1.50, 71, 120, '', 1.50, '2019-10-03 09:35:08.835419');
INSERT INTO public.producto_vendidos VALUES (366, 1, 2.50, 76, 121, '', 2.50, '2019-10-03 10:01:41.069172');
INSERT INTO public.producto_vendidos VALUES (367, 1, 55.00, 77, 121, '', 55.00, '2019-10-03 10:01:41.069172');
INSERT INTO public.producto_vendidos VALUES (368, 1, 5.50, 74, 121, '', 5.50, '2019-10-03 10:01:41.069172');
INSERT INTO public.producto_vendidos VALUES (369, 1, 52.00, 87, 121, '', 52.00, '2019-10-03 10:01:41.069172');
INSERT INTO public.producto_vendidos VALUES (370, 1, 2.50, 76, 122, '', 2.50, '2019-10-03 10:16:04.301381');
INSERT INTO public.producto_vendidos VALUES (371, 1, 55.00, 77, 122, '', 55.00, '2019-10-03 10:16:04.301381');
INSERT INTO public.producto_vendidos VALUES (372, 1, 1.50, 71, 122, '', 1.50, '2019-10-03 10:16:04.301381');
INSERT INTO public.producto_vendidos VALUES (373, 1, 2.50, 76, 123, '', 2.50, '2019-10-03 10:21:55.630776');
INSERT INTO public.producto_vendidos VALUES (374, 1, 55.00, 77, 123, '', 55.00, '2019-10-03 10:21:55.630776');
INSERT INTO public.producto_vendidos VALUES (375, 1, 1.50, 72, 124, '', 1.50, '2019-10-03 10:22:48.932032');
INSERT INTO public.producto_vendidos VALUES (376, 1, 5.50, 74, 124, '', 5.50, '2019-10-03 10:22:48.932032');
INSERT INTO public.producto_vendidos VALUES (377, 1, 2.50, 76, 125, '', 2.50, '2019-10-03 10:24:45.189713');
INSERT INTO public.producto_vendidos VALUES (378, 1, 1.50, 71, 125, '', 1.50, '2019-10-03 10:24:45.189713');
INSERT INTO public.producto_vendidos VALUES (379, 1, 55.00, 77, 126, '', 55.00, '2019-10-03 10:26:15.088165');
INSERT INTO public.producto_vendidos VALUES (380, 1, 1.50, 71, 126, '', 1.50, '2019-10-03 10:26:15.088165');
INSERT INTO public.producto_vendidos VALUES (381, 1, 2.50, 76, 127, '', 2.50, '2019-10-03 10:30:27.752504');
INSERT INTO public.producto_vendidos VALUES (382, 1, 8.50, 70, 127, '', 8.50, '2019-10-03 10:30:27.752504');
INSERT INTO public.producto_vendidos VALUES (383, 1, 5.50, 74, 127, '', 5.50, '2019-10-03 10:30:27.752504');
INSERT INTO public.producto_vendidos VALUES (384, 1, 1.50, 72, 127, '', 1.50, '2019-10-03 10:30:27.752504');
INSERT INTO public.producto_vendidos VALUES (385, 1, 1.50, 71, 127, '', 1.50, '2019-10-03 10:30:27.752504');
INSERT INTO public.producto_vendidos VALUES (386, 1, 2.50, 78, 128, '', 2.50, '2019-10-03 10:31:07.942361');
INSERT INTO public.producto_vendidos VALUES (387, 1, 1.50, 72, 128, '', 1.50, '2019-10-03 10:31:07.942361');
INSERT INTO public.producto_vendidos VALUES (388, 1, 80.00, 86, 129, '', 80.00, '2019-10-03 10:34:03.113291');
INSERT INTO public.producto_vendidos VALUES (389, 2, 33.00, 68, 129, '', 16.50, '2019-10-03 10:34:03.113291');
INSERT INTO public.producto_vendidos VALUES (390, 1, 2.50, 76, 130, '', 2.50, '2019-10-03 10:38:22.435175');
INSERT INTO public.producto_vendidos VALUES (391, 1, 8.50, 70, 130, '', 8.50, '2019-10-03 10:38:22.435175');
INSERT INTO public.producto_vendidos VALUES (392, 1, 5.50, 74, 130, '', 5.50, '2019-10-03 10:38:22.435175');
INSERT INTO public.producto_vendidos VALUES (393, 1, 1.50, 72, 130, '', 1.50, '2019-10-03 10:38:22.435175');
INSERT INTO public.producto_vendidos VALUES (394, 1, 2.50, 76, 131, '', 2.50, '2019-10-03 10:58:49.816225');
INSERT INTO public.producto_vendidos VALUES (395, 1, 55.00, 77, 131, '', 55.00, '2019-10-03 10:58:49.816225');
INSERT INTO public.producto_vendidos VALUES (396, 1, 12.50, 93, 132, '', 12.50, '2019-10-03 12:25:49.427008');
INSERT INTO public.producto_vendidos VALUES (397, 2, 104.00, 87, 132, '', 52.00, '2019-10-03 12:25:49.427008');
INSERT INTO public.producto_vendidos VALUES (398, 1, 15.00, 94, 132, '', 15.00, '2019-10-03 12:25:49.427008');
INSERT INTO public.producto_vendidos VALUES (399, 1, 2.50, 76, 133, '', 2.50, '2019-10-03 12:27:59.356013');
INSERT INTO public.producto_vendidos VALUES (400, 1, 5.00, 95, 133, '', 5.00, '2019-10-03 12:27:59.356013');
INSERT INTO public.producto_vendidos VALUES (401, 1, 15.00, 94, 134, '', 15.00, '2019-10-03 12:33:26.413468');
INSERT INTO public.producto_vendidos VALUES (402, 1, 12.50, 93, 134, '', 12.50, '2019-10-03 12:33:26.413468');
INSERT INTO public.producto_vendidos VALUES (403, 1, 55.00, 77, 134, '', 55.00, '2019-10-03 12:33:26.413468');
INSERT INTO public.producto_vendidos VALUES (404, 1, 52.00, 87, 134, '', 52.00, '2019-10-03 12:33:26.413468');
INSERT INTO public.producto_vendidos VALUES (405, 1, 5.00, 95, 135, '', 5.00, '2019-10-03 17:09:10.210256');
INSERT INTO public.producto_vendidos VALUES (406, 2, 30.00, 75, 135, '', 15.00, '2019-10-03 17:09:10.210256');
INSERT INTO public.producto_vendidos VALUES (407, 1, 2.00, 73, 135, '', 2.00, '2019-10-03 17:09:10.210256');
INSERT INTO public.producto_vendidos VALUES (408, 2, 11.00, 74, 135, '', 5.50, '2019-10-03 17:09:10.210256');
INSERT INTO public.producto_vendidos VALUES (409, 2, 30.00, 75, 136, '', 15.00, '2019-10-03 17:26:44.389332');
INSERT INTO public.producto_vendidos VALUES (410, 1, 1.50, 71, 136, '', 1.50, '2019-10-03 17:26:44.389332');
INSERT INTO public.producto_vendidos VALUES (411, 1, 1.50, 72, 136, '', 1.50, '2019-10-03 17:26:44.389332');
INSERT INTO public.producto_vendidos VALUES (412, 1, 2.50, 76, 137, '', 2.50, '2019-10-03 17:58:45.922909');
INSERT INTO public.producto_vendidos VALUES (413, 1, 5.50, 74, 137, '', 5.50, '2019-10-03 17:58:45.922909');
INSERT INTO public.producto_vendidos VALUES (414, 1, 1.50, 72, 138, '', 1.50, '2019-10-03 18:00:40.475292');
INSERT INTO public.producto_vendidos VALUES (415, 2, 10.00, 95, 138, 'sin azucar molida', 5.00, '2019-10-03 18:00:40.475292');
INSERT INTO public.producto_vendidos VALUES (416, 1, 15.00, 94, 138, '', 15.00, '2019-10-03 18:00:40.475292');
INSERT INTO public.producto_vendidos VALUES (417, 1, 2.50, 76, 139, '', 2.50, '2019-10-03 18:05:22.370627');
INSERT INTO public.producto_vendidos VALUES (418, 1, 5.50, 74, 139, '', 5.50, '2019-10-03 18:05:22.370627');
INSERT INTO public.producto_vendidos VALUES (419, 1, 5.00, 95, 139, '', 5.00, '2019-10-03 18:05:22.370627');
INSERT INTO public.producto_vendidos VALUES (420, 1, 1.50, 72, 139, '', 1.50, '2019-10-03 18:05:22.370627');
INSERT INTO public.producto_vendidos VALUES (421, 1, 5.50, 67, 139, '', 5.50, '2019-10-03 18:05:22.370627');
INSERT INTO public.producto_vendidos VALUES (422, 1, 5.50, 67, 140, '', 5.50, '2019-10-03 18:06:30.144631');
INSERT INTO public.producto_vendidos VALUES (423, 2, 112.60, 92, 140, '', 56.30, '2019-10-03 18:06:30.144631');
INSERT INTO public.producto_vendidos VALUES (424, 1, 55.00, 77, 141, '', 55.00, '2019-10-03 18:07:19.536802');
INSERT INTO public.producto_vendidos VALUES (425, 1, 22.50, 81, 141, '', 22.50, '2019-10-03 18:07:19.536802');
INSERT INTO public.producto_vendidos VALUES (426, 1, 22.30, 62, 141, '', 22.30, '2019-10-03 18:07:19.536802');
INSERT INTO public.producto_vendidos VALUES (427, 1, 62.00, 89, 141, '', 62.00, '2019-10-03 18:07:19.536802');
INSERT INTO public.producto_vendidos VALUES (428, 2, 124.00, 89, 142, '', 62.00, '2019-10-03 18:08:49.071791');
INSERT INTO public.producto_vendidos VALUES (429, 2, 25.00, 93, 142, '', 12.50, '2019-10-03 18:08:49.071791');
INSERT INTO public.producto_vendidos VALUES (430, 1, 35.00, 84, 143, '', 35.00, '2019-10-03 18:52:33.935693');
INSERT INTO public.producto_vendidos VALUES (431, 1, 22.50, 83, 143, '', 22.50, '2019-10-03 18:52:33.935693');
INSERT INTO public.producto_vendidos VALUES (432, 1, 5.50, 74, 143, '', 5.50, '2019-10-03 18:52:33.935693');
INSERT INTO public.producto_vendidos VALUES (433, 1, 5.00, 95, 143, '', 5.00, '2019-10-03 18:52:33.935693');
INSERT INTO public.producto_vendidos VALUES (434, 1, 2.00, 73, 143, '', 2.00, '2019-10-03 18:52:33.935693');
INSERT INTO public.producto_vendidos VALUES (435, 2, 3.00, 79, 144, '', 1.50, '2019-10-04 09:50:29.427639');
INSERT INTO public.producto_vendidos VALUES (436, 1, 6.50, 91, 144, '', 6.50, '2019-10-04 09:50:29.427639');
INSERT INTO public.producto_vendidos VALUES (437, 2, 30.00, 94, 144, '', 15.00, '2019-10-04 09:50:29.427639');
INSERT INTO public.producto_vendidos VALUES (438, 1, 1.50, 72, 144, '', 1.50, '2019-10-04 09:50:29.427639');
INSERT INTO public.producto_vendidos VALUES (439, 2, 10.00, 95, 144, '', 5.00, '2019-10-04 09:50:29.427639');
INSERT INTO public.producto_vendidos VALUES (440, 2, 44.60, 62, 145, '1 pechuga, 1 ala', 22.30, '2019-10-04 09:53:43.631135');
INSERT INTO public.producto_vendidos VALUES (441, 1, 1.50, 72, 145, '', 1.50, '2019-10-04 09:53:43.631135');
INSERT INTO public.producto_vendidos VALUES (442, 1, 1.50, 71, 145, '', 1.50, '2019-10-04 09:53:43.631135');
INSERT INTO public.producto_vendidos VALUES (443, 1, 2.50, 76, 146, '', 2.50, '2019-10-04 15:22:04.772672');
INSERT INTO public.producto_vendidos VALUES (444, 1, 5.50, 74, 146, '', 5.50, '2019-10-04 15:22:04.772672');
INSERT INTO public.producto_vendidos VALUES (445, 1, 5.00, 95, 146, '', 5.00, '2019-10-04 15:22:04.772672');
INSERT INTO public.producto_vendidos VALUES (446, 1, 2.50, 76, 147, '', 2.50, '2019-10-04 15:55:06.825904');
INSERT INTO public.producto_vendidos VALUES (447, 1, 5.50, 74, 147, '', 5.50, '2019-10-04 15:55:06.825904');
INSERT INTO public.producto_vendidos VALUES (448, 1, 5.00, 95, 147, '', 5.00, '2019-10-04 15:55:06.825904');
INSERT INTO public.producto_vendidos VALUES (449, 1, 52.00, 87, 147, '', 52.00, '2019-10-04 15:55:06.825904');
INSERT INTO public.producto_vendidos VALUES (450, 1, 1.50, 72, 147, '', 1.50, '2019-10-04 15:55:06.825904');
INSERT INTO public.producto_vendidos VALUES (451, 2, 110.00, 77, 148, '', 55.00, '2019-10-04 16:04:19.710285');
INSERT INTO public.producto_vendidos VALUES (452, 2, 3.00, 71, 148, '', 1.50, '2019-10-04 16:04:19.710285');
INSERT INTO public.producto_vendidos VALUES (453, 2, 10.00, 95, 148, '', 5.00, '2019-10-04 16:04:19.710285');
INSERT INTO public.producto_vendidos VALUES (454, 1, 2.50, 76, 148, '', 2.50, '2019-10-04 16:04:19.710285');
INSERT INTO public.producto_vendidos VALUES (455, 1, 11.00, 97, 148, '', 11.00, '2019-10-04 16:04:19.710285');
INSERT INTO public.producto_vendidos VALUES (456, 1, 5.50, 74, 148, '', 5.50, '2019-10-04 16:04:19.710285');
INSERT INTO public.producto_vendidos VALUES (457, 1, 1.50, 72, 148, '', 1.50, '2019-10-04 16:04:19.710285');
INSERT INTO public.producto_vendidos VALUES (458, 1, 52.00, 87, 148, '', 52.00, '2019-10-04 16:04:19.710285');
INSERT INTO public.producto_vendidos VALUES (459, 1, 5.50, 67, 148, '', 5.50, '2019-10-04 16:04:19.710285');
INSERT INTO public.producto_vendidos VALUES (460, 1, 2.00, 73, 148, '', 2.00, '2019-10-04 16:04:19.710285');
INSERT INTO public.producto_vendidos VALUES (461, 1, 15.00, 94, 148, '', 15.00, '2019-10-04 16:04:19.710285');
INSERT INTO public.producto_vendidos VALUES (462, 1, 56.30, 92, 148, '', 56.30, '2019-10-04 16:04:19.710285');
INSERT INTO public.producto_vendidos VALUES (463, 1, 6.50, 91, 148, '', 6.50, '2019-10-04 16:04:19.710285');
INSERT INTO public.producto_vendidos VALUES (464, 2, 7.00, 78, 148, '', 3.50, '2019-10-04 16:04:19.710285');
INSERT INTO public.producto_vendidos VALUES (465, 1, 1.50, 79, 148, '', 1.50, '2019-10-04 16:04:19.710285');
INSERT INTO public.producto_vendidos VALUES (466, 1, 22.50, 83, 148, '', 22.50, '2019-10-04 16:04:19.710285');
INSERT INTO public.producto_vendidos VALUES (467, 1, 12.50, 93, 148, '', 12.50, '2019-10-04 16:04:19.710285');
INSERT INTO public.producto_vendidos VALUES (468, 1, 35.00, 84, 148, '', 35.00, '2019-10-04 16:04:19.710285');
INSERT INTO public.producto_vendidos VALUES (469, 1, 5.00, 90, 148, '', 5.00, '2019-10-04 16:04:19.710285');
INSERT INTO public.producto_vendidos VALUES (470, 1, 22.50, 81, 148, '', 22.50, '2019-10-04 16:04:19.710285');
INSERT INTO public.producto_vendidos VALUES (471, 1, 16.00, 82, 148, '', 16.00, '2019-10-04 16:04:19.710285');
INSERT INTO public.producto_vendidos VALUES (472, 1, 80.00, 86, 148, '', 80.00, '2019-10-04 16:04:19.710285');
INSERT INTO public.producto_vendidos VALUES (473, 1, 25.00, 96, 148, '', 25.00, '2019-10-04 16:04:19.710285');
INSERT INTO public.producto_vendidos VALUES (474, 1, 16.50, 68, 148, '', 16.50, '2019-10-04 16:04:19.710285');
INSERT INTO public.producto_vendidos VALUES (475, 1, 5.50, 85, 148, '', 5.50, '2019-10-04 16:04:19.710285');
INSERT INTO public.producto_vendidos VALUES (476, 1, 15.00, 75, 148, '', 15.00, '2019-10-04 16:04:19.710285');
INSERT INTO public.producto_vendidos VALUES (477, 1, 62.00, 89, 148, '', 62.00, '2019-10-04 16:04:19.710285');
INSERT INTO public.producto_vendidos VALUES (478, 1, 10.50, 80, 148, '', 10.50, '2019-10-04 16:04:19.710285');
INSERT INTO public.producto_vendidos VALUES (479, 1, 2.50, 76, 149, '', 2.50, '2019-10-04 16:05:31.116501');
INSERT INTO public.producto_vendidos VALUES (480, 1, 55.00, 77, 149, '', 55.00, '2019-10-04 16:05:31.116501');
INSERT INTO public.producto_vendidos VALUES (481, 1, 5.00, 95, 149, '', 5.00, '2019-10-04 16:05:31.116501');
INSERT INTO public.producto_vendidos VALUES (482, 1, 5.50, 74, 149, '', 5.50, '2019-10-04 16:05:31.116501');
INSERT INTO public.producto_vendidos VALUES (483, 2, 110.00, 77, 150, '', 55.00, '2019-10-04 16:12:41.46674');
INSERT INTO public.producto_vendidos VALUES (484, 1, 11.00, 97, 150, '', 11.00, '2019-10-04 16:12:41.46674');
INSERT INTO public.producto_vendidos VALUES (485, 1, 1.50, 71, 151, '', 1.50, '2019-10-04 16:14:57.801956');
INSERT INTO public.producto_vendidos VALUES (486, 1, 15.00, 94, 151, '', 15.00, '2019-10-04 16:14:57.801956');
INSERT INTO public.producto_vendidos VALUES (487, 1, 12.50, 93, 151, '', 12.50, '2019-10-04 16:14:57.801956');
INSERT INTO public.producto_vendidos VALUES (488, 1, 80.00, 86, 151, '', 80.00, '2019-10-04 16:14:57.801956');
INSERT INTO public.producto_vendidos VALUES (489, 1, 2.50, 76, 152, '', 2.50, '2019-10-04 16:21:36.408709');
INSERT INTO public.producto_vendidos VALUES (490, 1, 5.50, 74, 152, '', 5.50, '2019-10-04 16:21:36.408709');
INSERT INTO public.producto_vendidos VALUES (491, 1, 11.00, 97, 152, '', 11.00, '2019-10-04 16:21:36.408709');
INSERT INTO public.producto_vendidos VALUES (492, 1, 5.00, 95, 152, '', 5.00, '2019-10-04 16:21:36.408709');
INSERT INTO public.producto_vendidos VALUES (493, 2, 5.00, 76, 153, '', 2.50, '2019-10-04 16:22:06.026986');
INSERT INTO public.producto_vendidos VALUES (494, 2, 10.00, 95, 153, '', 5.00, '2019-10-04 16:22:06.026986');
INSERT INTO public.producto_vendidos VALUES (495, 2, 5.00, 76, 154, '', 2.50, '2019-10-05 06:38:40.858466');
INSERT INTO public.producto_vendidos VALUES (496, 2, 3.00, 71, 154, '', 1.50, '2019-10-05 06:38:40.858466');
INSERT INTO public.producto_vendidos VALUES (497, 2, 3.00, 72, 154, '', 1.50, '2019-10-05 06:38:40.858466');
INSERT INTO public.producto_vendidos VALUES (498, 1, 5.50, 67, 154, '', 5.50, '2019-10-05 06:38:40.858466');
INSERT INTO public.producto_vendidos VALUES (499, 1, 16.50, 88, 154, '', 16.50, '2019-10-05 06:38:40.858466');
INSERT INTO public.producto_vendidos VALUES (500, 1, 2.00, 73, 154, '', 2.00, '2019-10-05 06:38:40.858466');
INSERT INTO public.producto_vendidos VALUES (501, 1, 6.50, 91, 154, '', 6.50, '2019-10-05 06:38:40.858466');
INSERT INTO public.producto_vendidos VALUES (502, 1, 56.30, 92, 154, '', 56.30, '2019-10-05 06:38:40.858466');
INSERT INTO public.producto_vendidos VALUES (503, 1, 2.50, 76, 155, '', 2.50, '2019-10-05 06:43:02.237806');
INSERT INTO public.producto_vendidos VALUES (504, 1, 5.50, 74, 155, '', 5.50, '2019-10-05 06:43:02.237806');
INSERT INTO public.producto_vendidos VALUES (505, 1, 52.00, 87, 155, '', 52.00, '2019-10-05 06:43:02.237806');
INSERT INTO public.producto_vendidos VALUES (506, 1, 16.50, 88, 155, '', 16.50, '2019-10-05 06:43:02.237806');
INSERT INTO public.producto_vendidos VALUES (507, 1, 6.50, 91, 155, '', 6.50, '2019-10-05 06:43:02.237806');
INSERT INTO public.producto_vendidos VALUES (508, 1, 3.50, 78, 155, '', 3.50, '2019-10-05 06:43:02.237806');
INSERT INTO public.producto_vendidos VALUES (509, 1, 6.50, 91, 156, '', 6.50, '2019-10-05 06:43:22.26472');
INSERT INTO public.producto_vendidos VALUES (510, 1, 56.30, 92, 156, '', 56.30, '2019-10-05 06:43:22.26472');
INSERT INTO public.producto_vendidos VALUES (511, 1, 12.50, 93, 157, '', 12.50, '2019-10-05 06:44:10.624348');
INSERT INTO public.producto_vendidos VALUES (512, 1, 22.50, 81, 157, '', 22.50, '2019-10-05 06:44:10.624348');
INSERT INTO public.producto_vendidos VALUES (513, 1, 5.00, 90, 157, '', 5.00, '2019-10-05 06:44:10.624348');
INSERT INTO public.producto_vendidos VALUES (514, 1, 35.00, 84, 157, '', 35.00, '2019-10-05 06:44:10.624348');
INSERT INTO public.producto_vendidos VALUES (515, 1, 12.50, 93, 158, '', 12.50, '2019-10-05 06:44:46.702068');
INSERT INTO public.producto_vendidos VALUES (516, 1, 22.50, 81, 158, '', 22.50, '2019-10-05 06:44:46.702068');
INSERT INTO public.producto_vendidos VALUES (517, 1, 5.00, 90, 158, '', 5.00, '2019-10-05 06:44:46.702068');
INSERT INTO public.producto_vendidos VALUES (518, 1, 35.00, 84, 158, '', 35.00, '2019-10-05 06:44:46.702068');
INSERT INTO public.producto_vendidos VALUES (519, 1, 35.00, 84, 159, '', 35.00, '2019-10-05 06:45:24.994151');
INSERT INTO public.producto_vendidos VALUES (520, 1, 5.00, 90, 159, '', 5.00, '2019-10-05 06:45:24.994151');
INSERT INTO public.producto_vendidos VALUES (521, 1, 22.50, 81, 159, '', 22.50, '2019-10-05 06:45:24.994151');
INSERT INTO public.producto_vendidos VALUES (522, 1, 25.00, 96, 159, '', 25.00, '2019-10-05 06:45:24.994151');
INSERT INTO public.producto_vendidos VALUES (523, 1, 80.00, 86, 159, '', 80.00, '2019-10-05 06:45:24.994151');
INSERT INTO public.producto_vendidos VALUES (524, 1, 16.00, 82, 159, '', 16.00, '2019-10-05 06:45:24.994151');
INSERT INTO public.producto_vendidos VALUES (525, 1, 2.50, 76, 160, '', 2.50, '2019-10-05 08:36:25.352753');
INSERT INTO public.producto_vendidos VALUES (526, 1, 2.50, 76, 161, '', 2.50, '2019-10-05 08:37:36.306953');
INSERT INTO public.producto_vendidos VALUES (527, 1, 11.00, 97, 161, '', 11.00, '2019-10-05 08:37:36.306953');
INSERT INTO public.producto_vendidos VALUES (528, 1, 5.00, 95, 161, '', 5.00, '2019-10-05 08:37:36.306953');
INSERT INTO public.producto_vendidos VALUES (529, 1, 2.50, 76, 162, '', 2.50, '2019-10-05 08:39:14.778008');
INSERT INTO public.producto_vendidos VALUES (530, 1, 55.00, 77, 162, '', 55.00, '2019-10-05 08:39:14.778008');
INSERT INTO public.producto_vendidos VALUES (531, 1, 2.50, 76, 163, '', 2.50, '2019-10-05 08:41:15.151201');
INSERT INTO public.producto_vendidos VALUES (532, 1, 55.00, 77, 163, '', 55.00, '2019-10-05 08:41:15.151201');
INSERT INTO public.producto_vendidos VALUES (533, 1, 55.00, 77, 164, '', 55.00, '2019-10-05 08:42:09.900888');
INSERT INTO public.producto_vendidos VALUES (534, 1, 1.50, 71, 164, '', 1.50, '2019-10-05 08:42:09.900888');
INSERT INTO public.producto_vendidos VALUES (535, 1, 11.00, 97, 164, '', 11.00, '2019-10-05 08:42:09.900888');
INSERT INTO public.producto_vendidos VALUES (536, 1, 5.00, 95, 164, '', 5.00, '2019-10-05 08:42:09.900888');
INSERT INTO public.producto_vendidos VALUES (537, 1, 5.50, 74, 164, '', 5.50, '2019-10-05 08:42:09.900888');
INSERT INTO public.producto_vendidos VALUES (538, 1, 11.00, 97, 165, '', 11.00, '2019-10-05 09:13:27.382051');
INSERT INTO public.producto_vendidos VALUES (539, 1, 5.50, 74, 165, '', 5.50, '2019-10-05 09:13:27.382051');
INSERT INTO public.producto_vendidos VALUES (540, 1, 5.00, 95, 165, '', 5.00, '2019-10-05 09:13:27.382051');
INSERT INTO public.producto_vendidos VALUES (541, 1, 52.00, 87, 165, '', 52.00, '2019-10-05 09:13:27.382051');
INSERT INTO public.producto_vendidos VALUES (542, 1, 1.50, 72, 165, '', 1.50, '2019-10-05 09:13:27.382051');
INSERT INTO public.producto_vendidos VALUES (543, 1, 2.50, 76, 166, '', 2.50, '2019-10-05 09:16:29.659379');
INSERT INTO public.producto_vendidos VALUES (544, 1, 55.00, 77, 166, '', 55.00, '2019-10-05 09:16:29.659379');
INSERT INTO public.producto_vendidos VALUES (545, 1, 5.00, 95, 166, '', 5.00, '2019-10-05 09:16:29.659379');
INSERT INTO public.producto_vendidos VALUES (546, 1, 1.50, 71, 166, '', 1.50, '2019-10-05 09:16:29.659379');
INSERT INTO public.producto_vendidos VALUES (547, 1, 2.50, 76, 167, '', 2.50, '2019-10-05 09:20:07.472279');
INSERT INTO public.producto_vendidos VALUES (548, 1, 55.00, 77, 167, '', 55.00, '2019-10-05 09:20:07.472279');
INSERT INTO public.producto_vendidos VALUES (549, 1, 1.50, 71, 167, '', 1.50, '2019-10-05 09:20:07.472279');
INSERT INTO public.producto_vendidos VALUES (550, 1, 2.50, 76, 168, '', 2.50, '2019-10-05 09:32:45.061967');
INSERT INTO public.producto_vendidos VALUES (551, 1, 11.00, 97, 168, '', 11.00, '2019-10-05 09:32:45.061967');
INSERT INTO public.producto_vendidos VALUES (552, 1, 5.50, 74, 168, '', 5.50, '2019-10-05 09:32:45.061967');
INSERT INTO public.producto_vendidos VALUES (553, 1, 5.00, 95, 168, '', 5.00, '2019-10-05 09:32:45.061967');
INSERT INTO public.producto_vendidos VALUES (554, 1, 1.50, 71, 168, '', 1.50, '2019-10-05 09:32:45.061967');
INSERT INTO public.producto_vendidos VALUES (555, 1, 11.00, 97, 169, '', 11.00, '2019-10-05 09:34:43.964492');
INSERT INTO public.producto_vendidos VALUES (556, 1, 5.50, 74, 169, '', 5.50, '2019-10-05 09:34:43.964492');
INSERT INTO public.producto_vendidos VALUES (557, 1, 52.00, 87, 169, '', 52.00, '2019-10-05 09:34:43.964492');
INSERT INTO public.producto_vendidos VALUES (558, 1, 5.00, 95, 169, '', 5.00, '2019-10-05 09:34:43.964492');
INSERT INTO public.producto_vendidos VALUES (559, 1, 1.50, 71, 169, '', 1.50, '2019-10-05 09:34:43.964492');
INSERT INTO public.producto_vendidos VALUES (560, 1, 5.00, 95, 170, '', 5.00, '2019-10-05 09:35:40.117375');
INSERT INTO public.producto_vendidos VALUES (561, 1, 5.50, 67, 170, '', 5.50, '2019-10-05 09:35:40.117375');
INSERT INTO public.producto_vendidos VALUES (562, 1, 52.00, 87, 170, '', 52.00, '2019-10-05 09:35:40.117375');
INSERT INTO public.producto_vendidos VALUES (563, 1, 1.50, 72, 170, '', 1.50, '2019-10-05 09:35:40.117375');
INSERT INTO public.producto_vendidos VALUES (564, 1, 2.50, 76, 171, '', 2.50, '2019-10-05 09:36:35.385649');
INSERT INTO public.producto_vendidos VALUES (565, 1, 11.00, 97, 171, '', 11.00, '2019-10-05 09:36:35.385649');
INSERT INTO public.producto_vendidos VALUES (566, 1, 5.50, 74, 171, '', 5.50, '2019-10-05 09:36:35.385649');
INSERT INTO public.producto_vendidos VALUES (567, 2, 10.00, 95, 171, '', 5.00, '2019-10-05 09:36:35.385649');
INSERT INTO public.producto_vendidos VALUES (568, 1, 1.50, 71, 172, '', 1.50, '2019-10-05 09:37:30.320263');
INSERT INTO public.producto_vendidos VALUES (569, 1, 5.50, 74, 172, '', 5.50, '2019-10-05 09:37:30.320263');
INSERT INTO public.producto_vendidos VALUES (570, 1, 52.00, 87, 172, '', 52.00, '2019-10-05 09:37:30.320263');
INSERT INTO public.producto_vendidos VALUES (571, 1, 1.50, 72, 172, '', 1.50, '2019-10-05 09:37:30.320263');
INSERT INTO public.producto_vendidos VALUES (572, 1, 55.00, 77, 173, 'ala', 55.00, '2019-10-05 12:31:46.699239');
INSERT INTO public.producto_vendidos VALUES (573, 1, 1.50, 71, 173, '', 1.50, '2019-10-05 12:31:46.699239');
INSERT INTO public.producto_vendidos VALUES (574, 2, 3.00, 71, 174, '', 1.50, '2019-10-05 12:32:42.630956');
INSERT INTO public.producto_vendidos VALUES (575, 1, 5.50, 74, 175, '', 5.50, '2019-10-05 12:33:22.288577');
INSERT INTO public.producto_vendidos VALUES (576, 1, 5.00, 95, 175, '', 5.00, '2019-10-05 12:33:22.288577');
INSERT INTO public.producto_vendidos VALUES (577, 2, 5.00, 76, 175, '', 2.50, '2019-10-05 12:33:22.288577');
INSERT INTO public.producto_vendidos VALUES (578, 2, 110.00, 77, 176, '', 55.00, '2019-10-05 12:34:29.874978');
INSERT INTO public.producto_vendidos VALUES (579, 1, 11.00, 97, 176, '', 11.00, '2019-10-05 12:34:29.874978');
INSERT INTO public.producto_vendidos VALUES (580, 2, 25.00, 93, 177, '', 12.50, '2019-10-05 13:02:18.242513');
INSERT INTO public.producto_vendidos VALUES (581, 2, 45.00, 83, 177, '', 22.50, '2019-10-05 13:02:18.242513');
INSERT INTO public.producto_vendidos VALUES (582, 1, 2.50, 76, 178, '', 2.50, '2019-10-05 14:35:21.96063');
INSERT INTO public.producto_vendidos VALUES (583, 1, 11.00, 97, 178, '', 11.00, '2019-10-05 14:35:21.96063');
INSERT INTO public.producto_vendidos VALUES (584, 1, 5.50, 74, 178, '', 5.50, '2019-10-05 14:35:21.96063');
INSERT INTO public.producto_vendidos VALUES (585, 1, 5.00, 95, 178, '', 5.00, '2019-10-05 14:35:21.96063');
INSERT INTO public.producto_vendidos VALUES (586, 3, 6.00, 73, 178, '', 2.00, '2019-10-05 14:35:21.96063');
INSERT INTO public.producto_vendidos VALUES (587, 2, 32.00, 98, 179, '', 16.00, '2019-10-05 19:57:42.201294');
INSERT INTO public.producto_vendidos VALUES (588, 2, 4.00, 99, 179, '', 2.00, '2019-10-05 19:57:42.201294');
INSERT INTO public.producto_vendidos VALUES (589, 1, 16.00, 101, 180, '', 16.00, '2019-10-05 19:58:50.133618');
INSERT INTO public.producto_vendidos VALUES (590, 1, 2.00, 99, 180, '', 2.00, '2019-10-05 19:58:50.133618');
INSERT INTO public.producto_vendidos VALUES (591, 1, 10.00, 100, 181, '', 10.00, '2019-10-05 20:00:23.661874');
INSERT INTO public.producto_vendidos VALUES (592, 5, 80.00, 98, 181, '', 16.00, '2019-10-05 20:00:23.661874');
INSERT INTO public.producto_vendidos VALUES (593, 1, 16.00, 101, 182, '', 16.00, '2019-10-05 20:02:26.804451');
INSERT INTO public.producto_vendidos VALUES (594, 2, 4.00, 99, 182, '', 2.00, '2019-10-05 20:02:26.804451');
INSERT INTO public.producto_vendidos VALUES (595, 1, 16.00, 98, 182, '', 16.00, '2019-10-05 20:02:26.804451');
INSERT INTO public.producto_vendidos VALUES (596, 2, 32.00, 101, 183, '', 16.00, '2019-10-05 20:18:07.343106');
INSERT INTO public.producto_vendidos VALUES (597, 2, 4.00, 99, 183, '', 2.00, '2019-10-05 20:18:07.343106');
INSERT INTO public.producto_vendidos VALUES (598, 1, 10.00, 100, 184, '', 10.00, '2019-10-05 20:18:51.711392');
INSERT INTO public.producto_vendidos VALUES (599, 2, 32.00, 101, 185, '', 16.00, '2019-10-05 20:36:01.207414');
INSERT INTO public.producto_vendidos VALUES (600, 2, 32.00, 98, 185, '', 16.00, '2019-10-05 20:36:01.207414');
INSERT INTO public.producto_vendidos VALUES (601, 1, 10.00, 100, 185, '', 10.00, '2019-10-05 20:36:01.207414');
INSERT INTO public.producto_vendidos VALUES (609, 2, 5.00, 76, 187, 'asdfa ""#$"#$"', 2.50, '2019-10-07 10:03:08.487612');
INSERT INTO public.producto_vendidos VALUES (610, 1, 11.00, 97, 187, 'asdfsadf', 11.00, '2019-10-07 10:03:08.487612');
INSERT INTO public.producto_vendidos VALUES (611, 1, 5.50, 74, 187, 'adfasdfa', 5.50, '2019-10-07 10:03:08.487612');
INSERT INTO public.producto_vendidos VALUES (612, 1, 11.00, 97, 188, '', 11.00, '2019-10-07 10:04:28.591782');
INSERT INTO public.producto_vendidos VALUES (613, 3, 16.50, 74, 188, '', 5.50, '2019-10-07 10:04:28.591782');
INSERT INTO public.producto_vendidos VALUES (614, 1, 5.00, 95, 188, 'con arto queso', 5.00, '2019-10-07 10:04:28.591782');
INSERT INTO public.producto_vendidos VALUES (615, 2, 11.00, 74, 189, '1 chocolate, 1 frutilla', 5.50, '2019-10-07 16:26:43.067743');
INSERT INTO public.producto_vendidos VALUES (616, 1, 1.50, 72, 189, '', 1.50, '2019-10-07 16:26:43.067743');
INSERT INTO public.producto_vendidos VALUES (617, 1, 1.50, 71, 189, '', 1.50, '2019-10-07 16:26:43.067743');
INSERT INTO public.producto_vendidos VALUES (618, 1, 15.00, 94, 190, '', 15.00, '2019-10-07 18:07:44.551967');
INSERT INTO public.producto_vendidos VALUES (619, 1, 12.50, 93, 190, '', 12.50, '2019-10-07 18:07:44.551967');
INSERT INTO public.producto_vendidos VALUES (620, 1, 80.00, 86, 190, '', 80.00, '2019-10-07 18:07:44.551967');
INSERT INTO public.producto_vendidos VALUES (621, 1, 5.50, 74, 191, '', 5.50, '2019-10-07 18:41:53.344012');
INSERT INTO public.producto_vendidos VALUES (622, 2, 110.00, 77, 191, '', 55.00, '2019-10-07 18:41:53.344012');
INSERT INTO public.producto_vendidos VALUES (623, 1, 1.50, 71, 191, '', 1.50, '2019-10-07 18:41:53.344012');
INSERT INTO public.producto_vendidos VALUES (624, 1, 55.00, 77, 192, '', 55.00, '2019-10-09 10:28:18.528159');
INSERT INTO public.producto_vendidos VALUES (625, 1, 5.50, 74, 192, '', 5.50, '2019-10-09 10:28:18.528159');
INSERT INTO public.producto_vendidos VALUES (626, 1, 11.00, 97, 192, '', 11.00, '2019-10-09 10:28:18.528159');
INSERT INTO public.producto_vendidos VALUES (627, 1, 2.50, 76, 192, '', 2.50, '2019-10-09 10:28:18.528159');
INSERT INTO public.producto_vendidos VALUES (628, 1, 1.50, 71, 192, '', 1.50, '2019-10-09 10:28:18.528159');
INSERT INTO public.producto_vendidos VALUES (629, 1, 5.00, 95, 192, '', 5.00, '2019-10-09 10:28:18.528159');
INSERT INTO public.producto_vendidos VALUES (630, 1, 15.00, 94, 192, '', 15.00, '2019-10-09 10:28:18.528159');
INSERT INTO public.producto_vendidos VALUES (631, 1, 16.50, 88, 192, '', 16.50, '2019-10-09 10:28:18.528159');
INSERT INTO public.producto_vendidos VALUES (632, 1, 2.50, 76, 193, '', 2.50, '2019-10-09 10:35:55.951462');
INSERT INTO public.producto_vendidos VALUES (633, 1, 5.50, 74, 193, '', 5.50, '2019-10-09 10:35:55.951462');
INSERT INTO public.producto_vendidos VALUES (634, 1, 5.00, 95, 193, '', 5.00, '2019-10-09 10:35:55.951462');
INSERT INTO public.producto_vendidos VALUES (635, 1, 1.50, 71, 193, '', 1.50, '2019-10-09 10:35:55.951462');
INSERT INTO public.producto_vendidos VALUES (636, 2, 45.00, 81, 194, 'pecho', 22.50, '2019-10-09 10:38:27.165643');
INSERT INTO public.producto_vendidos VALUES (637, 2, 32.00, 82, 194, 'ala', 16.00, '2019-10-09 10:38:27.165643');
INSERT INTO public.producto_vendidos VALUES (638, 1, 16.50, 68, 194, '', 16.50, '2019-10-09 10:38:27.165643');
INSERT INTO public.producto_vendidos VALUES (639, 1, 11.00, 97, 194, '', 11.00, '2019-10-09 10:38:27.165643');
INSERT INTO public.producto_vendidos VALUES (640, 1, 2.50, 76, 195, '', 2.50, '2019-10-09 10:51:39.762331');
INSERT INTO public.producto_vendidos VALUES (641, 2, 22.00, 97, 195, '', 11.00, '2019-10-09 10:51:39.762331');
INSERT INTO public.producto_vendidos VALUES (642, 2, 11.00, 74, 195, '', 5.50, '2019-10-09 10:51:39.762331');
INSERT INTO public.producto_vendidos VALUES (643, 1, 5.00, 95, 195, '', 5.00, '2019-10-09 10:51:39.762331');
INSERT INTO public.producto_vendidos VALUES (644, 1, 2.50, 76, 196, '', 2.50, '2019-10-09 10:53:31.556402');
INSERT INTO public.producto_vendidos VALUES (645, 1, 55.00, 77, 196, '', 55.00, '2019-10-09 10:53:31.556402');
INSERT INTO public.producto_vendidos VALUES (646, 1, 2.50, 76, 197, '', 2.50, '2019-10-09 11:39:00.092297');
INSERT INTO public.producto_vendidos VALUES (647, 1, 55.00, 77, 197, '', 55.00, '2019-10-09 11:39:00.092297');
INSERT INTO public.producto_vendidos VALUES (648, 1, 1.50, 71, 197, '', 1.50, '2019-10-09 11:39:00.092297');
INSERT INTO public.producto_vendidos VALUES (649, 2, 21.00, 80, 198, '', 10.50, '2019-10-09 11:43:47.339063');
INSERT INTO public.producto_vendidos VALUES (650, 1, 3.50, 78, 198, '', 3.50, '2019-10-09 11:43:47.339063');
INSERT INTO public.producto_vendidos VALUES (651, 1, 1.50, 79, 198, '', 1.50, '2019-10-09 11:43:47.339063');
INSERT INTO public.producto_vendidos VALUES (652, 3, 16.50, 67, 199, '', 5.50, '2019-10-09 12:21:31.494394');
INSERT INTO public.producto_vendidos VALUES (653, 3, 105.00, 84, 199, 'sabalo, pejerrey y surubi', 35.00, '2019-10-09 12:21:31.494394');
INSERT INTO public.producto_vendidos VALUES (654, 4, 90.00, 83, 199, '', 22.50, '2019-10-09 12:21:31.494394');
INSERT INTO public.producto_vendidos VALUES (655, 2, 3.00, 72, 199, '', 1.50, '2019-10-09 12:21:31.494394');
INSERT INTO public.producto_vendidos VALUES (656, 1, 1.50, 71, 199, '', 1.50, '2019-10-09 12:21:31.494394');
INSERT INTO public.producto_vendidos VALUES (657, 1, 11.00, 97, 199, 'coca cola light', 11.00, '2019-10-09 12:21:31.494394');
INSERT INTO public.producto_vendidos VALUES (658, 2, 33.00, 68, 199, '', 16.50, '2019-10-09 12:21:31.494394');
INSERT INTO public.producto_vendidos VALUES (659, 2, 33.00, 88, 199, 'sin papas', 16.50, '2019-10-09 12:21:31.494394');
INSERT INTO public.producto_vendidos VALUES (660, 1, 15.00, 94, 199, '', 15.00, '2019-10-09 12:21:31.494394');
INSERT INTO public.producto_vendidos VALUES (661, 1, 2.00, 73, 199, '', 2.00, '2019-10-09 12:21:31.494394');
INSERT INTO public.producto_vendidos VALUES (662, 1, 52.00, 87, 199, '', 52.00, '2019-10-09 12:21:31.494394');
INSERT INTO public.producto_vendidos VALUES (663, 1, 3.50, 78, 199, '', 3.50, '2019-10-09 12:21:31.494394');
INSERT INTO public.producto_vendidos VALUES (664, 1, 6.50, 91, 199, '', 6.50, '2019-10-09 12:21:31.494394');
INSERT INTO public.producto_vendidos VALUES (665, 1, 56.30, 92, 199, '', 56.30, '2019-10-09 12:21:31.494394');
INSERT INTO public.producto_vendidos VALUES (666, 1, 1.50, 79, 199, '', 1.50, '2019-10-09 12:21:31.494394');
INSERT INTO public.producto_vendidos VALUES (667, 1, 12.50, 93, 199, '', 12.50, '2019-10-09 12:21:31.494394');
INSERT INTO public.producto_vendidos VALUES (668, 1, 5.00, 90, 199, '', 5.00, '2019-10-09 12:21:31.494394');
INSERT INTO public.producto_vendidos VALUES (669, 1, 22.50, 81, 199, '', 22.50, '2019-10-09 12:21:31.494394');
INSERT INTO public.producto_vendidos VALUES (670, 1, 16.00, 82, 199, '', 16.00, '2019-10-09 12:21:31.494394');
INSERT INTO public.producto_vendidos VALUES (671, 1, 80.00, 86, 199, '', 80.00, '2019-10-09 12:21:31.494394');
INSERT INTO public.producto_vendidos VALUES (672, 1, 25.00, 96, 199, '', 25.00, '2019-10-09 12:21:31.494394');
INSERT INTO public.producto_vendidos VALUES (673, 1, 5.50, 85, 199, '', 5.50, '2019-10-09 12:21:31.494394');
INSERT INTO public.producto_vendidos VALUES (674, 3, 45.00, 75, 199, '', 15.00, '2019-10-09 12:21:31.494394');
INSERT INTO public.producto_vendidos VALUES (675, 2, 21.00, 80, 199, '1 con mate', 10.50, '2019-10-09 12:21:31.494394');
INSERT INTO public.producto_vendidos VALUES (676, 1, 62.00, 89, 199, 'con queso mosarella', 62.00, '2019-10-09 12:21:31.494394');
INSERT INTO public.producto_vendidos VALUES (677, 1, 55.00, 77, 200, '', 55.00, '2019-10-09 12:57:35.822068');
INSERT INTO public.producto_vendidos VALUES (678, 1, 11.00, 97, 200, '', 11.00, '2019-10-09 12:57:35.822068');
INSERT INTO public.producto_vendidos VALUES (679, 1, 52.00, 87, 200, '', 52.00, '2019-10-09 12:57:35.822068');
INSERT INTO public.producto_vendidos VALUES (680, 1, 2.50, 76, 201, '', 2.50, '2019-10-09 13:02:58.200758');
INSERT INTO public.producto_vendidos VALUES (681, 1, 2.50, 76, 202, '1 cucharilla de azucar', 2.50, '2019-10-09 13:47:25.688531');
INSERT INTO public.producto_vendidos VALUES (682, 3, 4.50, 71, 202, '', 1.50, '2019-10-09 13:47:25.688531');
INSERT INTO public.producto_vendidos VALUES (683, 1, 11.00, 97, 202, '', 11.00, '2019-10-09 13:47:25.688531');
INSERT INTO public.producto_vendidos VALUES (684, 3, 156.00, 87, 202, '', 52.00, '2019-10-09 13:47:25.688531');
INSERT INTO public.producto_vendidos VALUES (685, 2, 3.00, 72, 202, '', 1.50, '2019-10-09 13:47:25.688531');
INSERT INTO public.producto_vendidos VALUES (686, 1, 2.50, 76, 203, '', 2.50, '2019-10-09 13:49:27.064208');
INSERT INTO public.producto_vendidos VALUES (687, 2, 11.00, 74, 203, '', 5.50, '2019-10-09 13:49:27.064208');
INSERT INTO public.producto_vendidos VALUES (688, 1, 5.00, 95, 203, '', 5.00, '2019-10-09 13:49:27.064208');
INSERT INTO public.producto_vendidos VALUES (689, 1, 2.50, 76, 204, 'tinto con 2 cucharillas de azucar', 2.50, '2019-10-09 18:44:39.193415');
INSERT INTO public.producto_vendidos VALUES (690, 1, 55.00, 77, 204, '', 55.00, '2019-10-09 18:44:39.193415');
INSERT INTO public.producto_vendidos VALUES (691, 1, 1.50, 71, 204, '', 1.50, '2019-10-09 18:44:39.193415');
INSERT INTO public.producto_vendidos VALUES (692, 1, 5.00, 95, 204, '', 5.00, '2019-10-09 18:44:39.193415');
INSERT INTO public.producto_vendidos VALUES (693, 1, 5.50, 74, 204, 'de chocolate', 5.50, '2019-10-09 18:44:39.193415');
INSERT INTO public.producto_vendidos VALUES (694, 2, 104.00, 87, 204, '1 pollo 1 chancho', 52.00, '2019-10-09 18:44:39.193415');
INSERT INTO public.producto_vendidos VALUES (695, 2, 4.00, 73, 204, '1 uva 1 normal', 2.00, '2019-10-09 18:44:39.193415');
INSERT INTO public.producto_vendidos VALUES (696, 2, 33.00, 88, 204, '1 con papa 1 sin papa', 16.50, '2019-10-09 18:44:39.193415');
INSERT INTO public.producto_vendidos VALUES (697, 1, 2.50, 76, 205, '', 2.50, '2019-10-12 10:34:58.947752');
INSERT INTO public.producto_vendidos VALUES (698, 1, 11.00, 97, 205, '', 11.00, '2019-10-12 10:34:58.947752');
INSERT INTO public.producto_vendidos VALUES (699, 1, 1.50, 71, 205, '', 1.50, '2019-10-12 10:34:58.947752');
INSERT INTO public.producto_vendidos VALUES (700, 1, 2.50, 76, 206, 'sin azucar', 2.50, '2019-10-12 10:39:23.887475');
INSERT INTO public.producto_vendidos VALUES (701, 1, 55.00, 77, 206, '', 55.00, '2019-10-12 10:39:23.887475');
INSERT INTO public.producto_vendidos VALUES (702, 1, 5.50, 74, 206, '', 5.50, '2019-10-12 10:39:23.887475');
INSERT INTO public.producto_vendidos VALUES (703, 1, 5.00, 95, 207, '', 5.00, '2019-10-12 10:41:45.435965');
INSERT INTO public.producto_vendidos VALUES (704, 1, 5.50, 74, 207, '', 5.50, '2019-10-12 10:41:45.435965');
INSERT INTO public.producto_vendidos VALUES (705, 1, 11.00, 97, 207, '', 11.00, '2019-10-12 10:41:45.435965');
INSERT INTO public.producto_vendidos VALUES (706, 1, 1.50, 71, 207, '', 1.50, '2019-10-12 10:41:45.435965');
INSERT INTO public.producto_vendidos VALUES (707, 1, 55.00, 77, 208, '', 55.00, '2019-10-12 15:12:52.14119');
INSERT INTO public.producto_vendidos VALUES (708, 1, 2.50, 76, 208, '', 2.50, '2019-10-12 15:12:52.14119');
INSERT INTO public.producto_vendidos VALUES (709, 1, 11.00, 97, 208, '', 11.00, '2019-10-12 15:12:52.14119');
INSERT INTO public.producto_vendidos VALUES (710, 1, 1.50, 71, 208, '', 1.50, '2019-10-12 15:12:52.14119');
INSERT INTO public.producto_vendidos VALUES (711, 1, 5.50, 74, 208, '', 5.50, '2019-10-12 15:12:52.14119');
INSERT INTO public.producto_vendidos VALUES (712, 1, 55.00, 77, 209, '', 55.00, '2019-10-12 15:14:02.587016');
INSERT INTO public.producto_vendidos VALUES (713, 1, 2.50, 76, 209, '', 2.50, '2019-10-12 15:14:02.587016');
INSERT INTO public.producto_vendidos VALUES (714, 1, 22.50, 83, 210, '', 22.50, '2019-10-12 21:36:11.947206');
INSERT INTO public.producto_vendidos VALUES (715, 1, 1.50, 79, 210, '', 1.50, '2019-10-12 21:36:11.947206');
INSERT INTO public.producto_vendidos VALUES (716, 1, 35.00, 84, 210, '', 35.00, '2019-10-12 21:36:11.947206');
INSERT INTO public.producto_vendidos VALUES (717, 1, 5.00, 90, 210, '', 5.00, '2019-10-12 21:36:11.947206');
INSERT INTO public.producto_vendidos VALUES (718, 1, 22.50, 81, 210, '', 22.50, '2019-10-12 21:36:11.947206');
INSERT INTO public.producto_vendidos VALUES (719, 1, 5.50, 74, 211, '', 5.50, '2019-10-12 21:47:37.495424');
INSERT INTO public.producto_vendidos VALUES (720, 1, 5.00, 95, 211, '', 5.00, '2019-10-12 21:47:37.495424');
INSERT INTO public.producto_vendidos VALUES (721, 1, 1.50, 71, 211, '', 1.50, '2019-10-12 21:47:37.495424');
INSERT INTO public.producto_vendidos VALUES (722, 1, 55.00, 77, 211, '', 55.00, '2019-10-12 21:47:37.495424');
INSERT INTO public.producto_vendidos VALUES (723, 1, 11.00, 97, 212, '', 11.00, '2019-10-13 09:36:03.25425');
INSERT INTO public.producto_vendidos VALUES (724, 1, 3.50, 78, 212, '', 3.50, '2019-10-13 09:36:03.25425');
INSERT INTO public.producto_vendidos VALUES (725, 1, 1.50, 79, 212, '', 1.50, '2019-10-13 09:36:03.25425');
INSERT INTO public.producto_vendidos VALUES (726, 1, 55.00, 77, 213, '', 55.00, '2019-10-13 11:47:30.681702');
INSERT INTO public.producto_vendidos VALUES (727, 1, 2.50, 76, 213, '', 2.50, '2019-10-13 11:47:30.681702');
INSERT INTO public.producto_vendidos VALUES (728, 1, 1.50, 71, 213, '', 1.50, '2019-10-13 11:47:30.681702');
INSERT INTO public.producto_vendidos VALUES (729, 1, 5.00, 95, 213, '', 5.00, '2019-10-13 11:47:30.681702');
INSERT INTO public.producto_vendidos VALUES (730, 1, 5.50, 74, 213, '', 5.50, '2019-10-13 11:47:30.681702');
INSERT INTO public.producto_vendidos VALUES (731, 1, 2.50, 76, 214, '', 2.50, '2019-10-13 18:18:06.709574');
INSERT INTO public.producto_vendidos VALUES (732, 1, 5.50, 74, 214, '', 5.50, '2019-10-13 18:18:06.709574');
INSERT INTO public.producto_vendidos VALUES (733, 1, 5.00, 95, 214, '', 5.00, '2019-10-13 18:18:06.709574');
INSERT INTO public.producto_vendidos VALUES (734, 1, 52.00, 87, 214, '', 52.00, '2019-10-13 18:18:06.709574');
INSERT INTO public.producto_vendidos VALUES (735, 1, 1.50, 72, 214, '', 1.50, '2019-10-13 18:18:06.709574');
INSERT INTO public.producto_vendidos VALUES (736, 1, 55.00, 77, 215, '', 55.00, '2019-10-13 18:19:29.242734');
INSERT INTO public.producto_vendidos VALUES (737, 1, 1.50, 71, 215, '', 1.50, '2019-10-13 18:19:29.242734');
INSERT INTO public.producto_vendidos VALUES (738, 1, 11.00, 97, 215, '', 11.00, '2019-10-13 18:19:29.242734');
INSERT INTO public.producto_vendidos VALUES (739, 2, 5.00, 76, 215, '', 2.50, '2019-10-13 18:19:29.242734');
INSERT INTO public.producto_vendidos VALUES (740, 1, 55.00, 77, 216, '', 55.00, '2019-10-13 18:24:26.674336');
INSERT INTO public.producto_vendidos VALUES (741, 1, 2.50, 76, 216, '', 2.50, '2019-10-13 18:24:26.674336');
INSERT INTO public.producto_vendidos VALUES (742, 1, 1.50, 71, 216, '', 1.50, '2019-10-13 18:24:26.674336');
INSERT INTO public.producto_vendidos VALUES (743, 1, 11.00, 97, 216, '', 11.00, '2019-10-13 18:24:26.674336');
INSERT INTO public.producto_vendidos VALUES (744, 1, 5.50, 74, 216, '', 5.50, '2019-10-13 18:24:26.674336');
INSERT INTO public.producto_vendidos VALUES (745, 1, 1.50, 71, 217, '', 1.50, '2019-10-13 18:24:56.929426');
INSERT INTO public.producto_vendidos VALUES (746, 1, 11.00, 97, 217, '', 11.00, '2019-10-13 18:24:56.929426');
INSERT INTO public.producto_vendidos VALUES (747, 1, 5.00, 95, 217, '', 5.00, '2019-10-13 18:24:56.929426');
INSERT INTO public.producto_vendidos VALUES (748, 1, 5.50, 74, 217, '', 5.50, '2019-10-13 18:24:56.929426');
INSERT INTO public.producto_vendidos VALUES (749, 1, 5.50, 74, 218, '', 5.50, '2019-10-13 18:33:37.172412');
INSERT INTO public.producto_vendidos VALUES (750, 1, 2.50, 76, 218, '', 2.50, '2019-10-13 18:33:37.172412');
INSERT INTO public.producto_vendidos VALUES (751, 1, 11.00, 97, 218, '', 11.00, '2019-10-13 18:33:37.172412');
INSERT INTO public.producto_vendidos VALUES (752, 1, 5.00, 95, 218, '', 5.00, '2019-10-13 18:33:37.172412');
INSERT INTO public.producto_vendidos VALUES (753, 1, 55.00, 77, 219, '', 55.00, '2019-10-13 18:34:48.650648');
INSERT INTO public.producto_vendidos VALUES (754, 1, 1.50, 71, 219, '', 1.50, '2019-10-13 18:34:48.650648');
INSERT INTO public.producto_vendidos VALUES (755, 1, 5.00, 95, 219, '', 5.00, '2019-10-13 18:34:48.650648');
INSERT INTO public.producto_vendidos VALUES (756, 1, 5.50, 74, 219, '', 5.50, '2019-10-13 18:34:48.650648');
INSERT INTO public.producto_vendidos VALUES (757, 1, 2.50, 76, 220, '', 2.50, '2019-10-13 18:44:44.104476');
INSERT INTO public.producto_vendidos VALUES (758, 1, 55.00, 77, 220, '', 55.00, '2019-10-13 18:44:44.104476');
INSERT INTO public.producto_vendidos VALUES (759, 1, 5.50, 74, 220, '', 5.50, '2019-10-13 18:44:44.104476');
INSERT INTO public.producto_vendidos VALUES (760, 1, 11.00, 97, 220, '', 11.00, '2019-10-13 18:44:44.104476');
INSERT INTO public.producto_vendidos VALUES (761, 1, 2.50, 76, 221, '', 2.50, '2019-10-13 19:08:19.074208');
INSERT INTO public.producto_vendidos VALUES (762, 1, 55.00, 77, 221, '', 55.00, '2019-10-13 19:08:19.074208');
INSERT INTO public.producto_vendidos VALUES (763, 1, 1.50, 71, 221, '', 1.50, '2019-10-13 19:08:19.074208');
INSERT INTO public.producto_vendidos VALUES (764, 1, 2.50, 76, 222, '', 2.50, '2019-10-13 19:11:42.441114');
INSERT INTO public.producto_vendidos VALUES (765, 1, 11.00, 97, 222, '', 11.00, '2019-10-13 19:11:42.441114');
INSERT INTO public.producto_vendidos VALUES (766, 1, 5.50, 74, 222, '', 5.50, '2019-10-13 19:11:42.441114');
INSERT INTO public.producto_vendidos VALUES (767, 1, 1.50, 71, 222, '', 1.50, '2019-10-13 19:11:42.441114');
INSERT INTO public.producto_vendidos VALUES (768, 1, 55.00, 77, 222, '', 55.00, '2019-10-13 19:11:42.441114');
INSERT INTO public.producto_vendidos VALUES (769, 1, 2.50, 76, 223, '', 2.50, '2019-10-14 09:44:31.610123');
INSERT INTO public.producto_vendidos VALUES (770, 1, 11.00, 97, 223, '', 11.00, '2019-10-14 09:44:31.610123');
INSERT INTO public.producto_vendidos VALUES (771, 1, 5.50, 74, 223, '', 5.50, '2019-10-14 09:44:31.610123');
INSERT INTO public.producto_vendidos VALUES (772, 1, 5.00, 95, 223, '', 5.00, '2019-10-14 09:44:31.610123');
INSERT INTO public.producto_vendidos VALUES (773, 1, 1.50, 71, 223, '', 1.50, '2019-10-14 09:44:31.610123');
INSERT INTO public.producto_vendidos VALUES (774, 1, 55.00, 77, 223, '', 55.00, '2019-10-14 09:44:31.610123');
INSERT INTO public.producto_vendidos VALUES (775, 1, 2.50, 76, 224, '', 2.50, '2019-10-14 10:56:32.356562');
INSERT INTO public.producto_vendidos VALUES (776, 1, 55.00, 77, 224, '', 55.00, '2019-10-14 10:56:32.356562');
INSERT INTO public.producto_vendidos VALUES (777, 1, 5.00, 95, 224, '', 5.00, '2019-10-14 10:56:32.356562');
INSERT INTO public.producto_vendidos VALUES (778, 1, 5.50, 74, 224, '', 5.50, '2019-10-14 10:56:32.356562');
INSERT INTO public.producto_vendidos VALUES (779, 1, 11.00, 97, 225, '', 11.00, '2019-10-14 12:55:59.55335');
INSERT INTO public.producto_vendidos VALUES (780, 3, 16.50, 74, 225, '', 5.50, '2019-10-14 12:55:59.55335');
INSERT INTO public.producto_vendidos VALUES (781, 1, 5.00, 95, 225, '', 5.00, '2019-10-14 12:55:59.55335');
INSERT INTO public.producto_vendidos VALUES (782, 1, 3.50, 78, 226, '', 3.50, '2019-10-14 12:56:51.930164');
INSERT INTO public.producto_vendidos VALUES (783, 2, 13.00, 91, 226, '', 6.50, '2019-10-14 12:56:51.930164');
INSERT INTO public.producto_vendidos VALUES (784, 1, 56.30, 92, 226, '', 56.30, '2019-10-14 12:56:51.930164');
INSERT INTO public.producto_vendidos VALUES (785, 2, 4.00, 73, 227, '', 2.00, '2019-10-14 12:59:43.516121');
INSERT INTO public.producto_vendidos VALUES (786, 2, 11.00, 74, 227, '', 5.50, '2019-10-14 12:59:43.516121');
INSERT INTO public.producto_vendidos VALUES (787, 2, 110.00, 77, 228, '', 55.00, '2019-10-14 13:03:07.998658');
INSERT INTO public.producto_vendidos VALUES (788, 3, 48.00, 82, 228, '', 16.00, '2019-10-14 13:03:07.998658');
INSERT INTO public.producto_vendidos VALUES (789, 2, 33.00, 68, 228, '', 16.50, '2019-10-14 13:03:07.998658');
INSERT INTO public.producto_vendidos VALUES (790, 1, 62.00, 89, 228, '', 62.00, '2019-10-14 13:03:07.998658');
INSERT INTO public.producto_vendidos VALUES (791, 7, 73.50, 80, 228, '', 10.50, '2019-10-14 13:03:07.998658');
INSERT INTO public.producto_vendidos VALUES (792, 1, 22.50, 81, 228, '', 22.50, '2019-10-14 13:03:07.998658');
INSERT INTO public.producto_vendidos VALUES (793, 1, 35.00, 84, 228, '', 35.00, '2019-10-14 13:03:07.998658');
INSERT INTO public.producto_vendidos VALUES (794, 1, 1.50, 79, 228, '', 1.50, '2019-10-14 13:03:07.998658');
INSERT INTO public.producto_vendidos VALUES (795, 1, 22.50, 83, 228, '', 22.50, '2019-10-14 13:03:07.998658');
INSERT INTO public.producto_vendidos VALUES (796, 1, 12.50, 93, 228, '', 12.50, '2019-10-14 13:03:07.998658');
INSERT INTO public.producto_vendidos VALUES (797, 1, 3.50, 78, 228, '', 3.50, '2019-10-14 13:03:07.998658');
INSERT INTO public.producto_vendidos VALUES (798, 1, 6.50, 91, 228, '', 6.50, '2019-10-14 13:03:07.998658');
INSERT INTO public.producto_vendidos VALUES (799, 1, 56.30, 92, 228, '', 56.30, '2019-10-14 13:03:07.998658');
INSERT INTO public.producto_vendidos VALUES (800, 1, 2.00, 73, 228, '', 2.00, '2019-10-14 13:03:07.998658');
INSERT INTO public.producto_vendidos VALUES (801, 1, 16.50, 88, 228, '', 16.50, '2019-10-14 13:03:07.998658');
INSERT INTO public.producto_vendidos VALUES (802, 1, 15.00, 94, 228, '', 15.00, '2019-10-14 13:03:07.998658');
INSERT INTO public.producto_vendidos VALUES (803, 1, 5.50, 67, 228, '', 5.50, '2019-10-14 13:03:07.998658');
INSERT INTO public.producto_vendidos VALUES (804, 1, 52.00, 87, 228, '', 52.00, '2019-10-14 13:03:07.998658');
INSERT INTO public.producto_vendidos VALUES (805, 2, 3.00, 72, 228, '', 1.50, '2019-10-14 13:03:07.998658');
INSERT INTO public.producto_vendidos VALUES (806, 1, 1.50, 71, 228, '', 1.50, '2019-10-14 13:03:07.998658');
INSERT INTO public.producto_vendidos VALUES (807, 1, 11.00, 97, 228, '', 11.00, '2019-10-14 13:03:07.998658');
INSERT INTO public.producto_vendidos VALUES (808, 2, 21.00, 80, 229, '', 10.50, '2019-10-14 17:20:42.033456');
INSERT INTO public.producto_vendidos VALUES (809, 1, 55.00, 77, 229, '', 55.00, '2019-10-14 17:20:42.033456');
INSERT INTO public.producto_vendidos VALUES (810, 2, 45.00, 81, 229, '', 22.50, '2019-10-14 17:20:42.033456');
INSERT INTO public.producto_vendidos VALUES (811, 1, 52.00, 87, 229, '', 52.00, '2019-10-14 17:20:42.033456');
INSERT INTO public.producto_vendidos VALUES (812, 1, 55.00, 77, 230, '', 55.00, '2019-10-14 18:43:54.081796');
INSERT INTO public.producto_vendidos VALUES (813, 1, 2.50, 76, 230, '', 2.50, '2019-10-14 18:43:54.081796');
INSERT INTO public.producto_vendidos VALUES (814, 1, 5.00, 95, 230, '', 5.00, '2019-10-14 18:43:54.081796');
INSERT INTO public.producto_vendidos VALUES (815, 1, 1.50, 72, 230, '', 1.50, '2019-10-14 18:43:54.081796');
INSERT INTO public.producto_vendidos VALUES (816, 1, 52.00, 87, 230, '', 52.00, '2019-10-14 18:43:54.081796');
INSERT INTO public.producto_vendidos VALUES (817, 1, 2.50, 76, 231, '', 2.50, '2019-10-15 07:59:39.82538');
INSERT INTO public.producto_vendidos VALUES (818, 1, 55.00, 77, 231, '', 55.00, '2019-10-15 07:59:39.82538');
INSERT INTO public.producto_vendidos VALUES (819, 1, 2.50, 76, 232, '', 2.50, '2019-10-15 09:14:58.662745');
INSERT INTO public.producto_vendidos VALUES (820, 1, 55.00, 77, 232, '', 55.00, '2019-10-15 09:14:58.662745');
INSERT INTO public.producto_vendidos VALUES (821, 1, 1.50, 71, 232, '', 1.50, '2019-10-15 09:14:58.662745');
INSERT INTO public.producto_vendidos VALUES (822, 1, 2.50, 76, 233, '', 2.50, '2019-10-15 09:53:00.077957');
INSERT INTO public.producto_vendidos VALUES (823, 1, 55.00, 77, 233, '', 55.00, '2019-10-15 09:53:00.077957');
INSERT INTO public.producto_vendidos VALUES (824, 1, 11.00, 97, 233, '', 11.00, '2019-10-15 09:53:00.077957');
INSERT INTO public.producto_vendidos VALUES (825, 1, 1.50, 71, 234, '', 1.50, '2019-10-15 09:53:59.466096');
INSERT INTO public.producto_vendidos VALUES (826, 1, 5.00, 95, 234, 'sin azucar y con api', 5.00, '2019-10-15 09:53:59.466096');
INSERT INTO public.producto_vendidos VALUES (827, 1, 5.50, 74, 234, '', 5.50, '2019-10-15 09:53:59.466096');
INSERT INTO public.producto_vendidos VALUES (828, 1, 5.00, 95, 235, '', 5.00, '2019-10-15 09:57:41.316694');
INSERT INTO public.producto_vendidos VALUES (829, 3, 16.50, 74, 235, '', 5.50, '2019-10-15 09:57:41.316694');
INSERT INTO public.producto_vendidos VALUES (830, 1, 52.00, 87, 235, 'Fricaso mixto con pollo', 52.00, '2019-10-15 09:57:41.316694');
INSERT INTO public.producto_vendidos VALUES (831, 3, 4.50, 72, 235, '', 1.50, '2019-10-15 09:57:41.316694');
INSERT INTO public.producto_vendidos VALUES (832, 1, 2.50, 76, 236, '', 2.50, '2019-10-15 09:58:46.369695');
INSERT INTO public.producto_vendidos VALUES (833, 1, 11.00, 97, 236, '', 11.00, '2019-10-15 09:58:46.369695');
INSERT INTO public.producto_vendidos VALUES (834, 1, 5.50, 74, 236, '', 5.50, '2019-10-15 09:58:46.369695');
INSERT INTO public.producto_vendidos VALUES (835, 1, 5.00, 95, 236, '', 5.00, '2019-10-15 09:58:46.369695');
INSERT INTO public.producto_vendidos VALUES (836, 1, 16.50, 88, 237, '', 16.50, '2019-10-15 10:25:49.980597');
INSERT INTO public.producto_vendidos VALUES (837, 1, 15.00, 94, 237, '', 15.00, '2019-10-15 10:25:49.980597');
INSERT INTO public.producto_vendidos VALUES (838, 1, 2.00, 73, 237, '', 2.00, '2019-10-15 10:25:49.980597');
INSERT INTO public.producto_vendidos VALUES (839, 1, 1.50, 71, 238, '', 1.50, '2019-10-15 10:28:33.28276');
INSERT INTO public.producto_vendidos VALUES (840, 1, 11.00, 97, 238, '', 11.00, '2019-10-15 10:28:33.28276');
INSERT INTO public.producto_vendidos VALUES (841, 1, 5.00, 95, 238, 'con azucar molido', 5.00, '2019-10-15 10:28:33.28276');
INSERT INTO public.producto_vendidos VALUES (842, 1, 1.50, 72, 238, '', 1.50, '2019-10-15 10:28:33.28276');
INSERT INTO public.producto_vendidos VALUES (843, 1, 52.00, 87, 238, '', 52.00, '2019-10-15 10:28:33.28276');
INSERT INTO public.producto_vendidos VALUES (844, 1, 5.50, 74, 239, '', 5.50, '2019-10-15 11:07:01.215549');
INSERT INTO public.producto_vendidos VALUES (845, 2, 11.00, 67, 239, '', 5.50, '2019-10-15 11:07:01.215549');
INSERT INTO public.producto_vendidos VALUES (846, 1, 5.50, 74, 240, '', 5.50, '2019-10-15 11:09:06.797115');
INSERT INTO public.producto_vendidos VALUES (847, 1, 5.00, 95, 240, '', 5.00, '2019-10-15 11:09:06.797115');
INSERT INTO public.producto_vendidos VALUES (848, 1, 5.50, 67, 240, '', 5.50, '2019-10-15 11:09:06.797115');
INSERT INTO public.producto_vendidos VALUES (849, 1, 56.30, 92, 240, '', 56.30, '2019-10-15 11:09:06.797115');
INSERT INTO public.producto_vendidos VALUES (850, 1, 6.50, 91, 240, '', 6.50, '2019-10-15 11:09:06.797115');
INSERT INTO public.producto_vendidos VALUES (851, 1, 2.50, 76, 241, '', 2.50, '2019-10-15 12:40:22.639535');
INSERT INTO public.producto_vendidos VALUES (852, 1, 55.00, 77, 241, '', 55.00, '2019-10-15 12:40:22.639535');
INSERT INTO public.producto_vendidos VALUES (853, 1, 5.50, 74, 241, '', 5.50, '2019-10-15 12:40:22.639535');
INSERT INTO public.producto_vendidos VALUES (854, 1, 5.00, 95, 241, '', 5.00, '2019-10-15 12:40:22.639535');
INSERT INTO public.producto_vendidos VALUES (855, 1, 2.50, 76, 242, '', 2.50, '2019-10-15 12:45:18.941795');
INSERT INTO public.producto_vendidos VALUES (856, 1, 1.50, 71, 242, '', 1.50, '2019-10-15 12:45:18.941795');
INSERT INTO public.producto_vendidos VALUES (857, 1, 11.00, 97, 242, '', 11.00, '2019-10-15 12:45:18.941795');
INSERT INTO public.producto_vendidos VALUES (858, 1, 2.50, 76, 243, '', 2.50, '2019-10-15 12:50:39.117037');
INSERT INTO public.producto_vendidos VALUES (859, 1, 55.00, 77, 243, '', 55.00, '2019-10-15 12:50:39.117037');
INSERT INTO public.producto_vendidos VALUES (860, 1, 11.00, 97, 243, '', 11.00, '2019-10-15 12:50:39.117037');
INSERT INTO public.producto_vendidos VALUES (861, 1, 1.50, 71, 243, '', 1.50, '2019-10-15 12:50:39.117037');
INSERT INTO public.producto_vendidos VALUES (862, 1, 2.50, 76, 244, '', 2.50, '2019-10-15 12:57:08.446011');
INSERT INTO public.producto_vendidos VALUES (863, 1, 55.00, 77, 244, '', 55.00, '2019-10-15 12:57:08.446011');
INSERT INTO public.producto_vendidos VALUES (864, 1, 1.50, 71, 244, '', 1.50, '2019-10-15 12:57:08.446011');
INSERT INTO public.producto_vendidos VALUES (865, 1, 5.00, 95, 244, '', 5.00, '2019-10-15 12:57:08.446011');
INSERT INTO public.producto_vendidos VALUES (866, 1, 2.50, 76, 245, '', 2.50, '2019-10-15 12:58:06.872359');
INSERT INTO public.producto_vendidos VALUES (867, 1, 55.00, 77, 245, '', 55.00, '2019-10-15 12:58:06.872359');
INSERT INTO public.producto_vendidos VALUES (868, 1, 2.50, 76, 246, '', 2.50, '2019-10-15 12:59:24.726433');
INSERT INTO public.producto_vendidos VALUES (869, 1, 55.00, 77, 246, '', 55.00, '2019-10-15 12:59:24.726433');
INSERT INTO public.producto_vendidos VALUES (870, 1, 55.00, 77, 247, '', 55.00, '2019-10-15 13:01:30.35057');
INSERT INTO public.producto_vendidos VALUES (871, 1, 5.50, 74, 247, '', 5.50, '2019-10-15 13:01:30.35057');
INSERT INTO public.producto_vendidos VALUES (872, 1, 5.00, 95, 247, '', 5.00, '2019-10-15 13:01:30.35057');
INSERT INTO public.producto_vendidos VALUES (873, 1, 2.50, 76, 248, '', 2.50, '2019-10-15 13:03:28.137075');
INSERT INTO public.producto_vendidos VALUES (874, 1, 55.00, 77, 248, '', 55.00, '2019-10-15 13:03:28.137075');
INSERT INTO public.producto_vendidos VALUES (875, 1, 2.50, 76, 249, '', 2.50, '2019-10-15 13:05:07.64372');
INSERT INTO public.producto_vendidos VALUES (876, 1, 55.00, 77, 249, '', 55.00, '2019-10-15 13:05:07.64372');
INSERT INTO public.producto_vendidos VALUES (877, 1, 2.50, 76, 250, '', 2.50, '2019-10-15 13:07:25.499059');
INSERT INTO public.producto_vendidos VALUES (878, 1, 55.00, 77, 250, '', 55.00, '2019-10-15 13:07:25.499059');
INSERT INTO public.producto_vendidos VALUES (879, 1, 2.50, 76, 251, '', 2.50, '2019-10-15 13:09:14.24655');
INSERT INTO public.producto_vendidos VALUES (880, 1, 55.00, 77, 251, '', 55.00, '2019-10-15 13:09:14.24655');
INSERT INTO public.producto_vendidos VALUES (881, 1, 2.50, 76, 252, '', 2.50, '2019-10-15 13:12:04.534861');
INSERT INTO public.producto_vendidos VALUES (882, 1, 55.00, 77, 252, '', 55.00, '2019-10-15 13:12:04.534861');
INSERT INTO public.producto_vendidos VALUES (883, 1, 11.00, 97, 252, '', 11.00, '2019-10-15 13:12:04.534861');
INSERT INTO public.producto_vendidos VALUES (884, 1, 1.50, 71, 252, '', 1.50, '2019-10-15 13:12:04.534861');
INSERT INTO public.producto_vendidos VALUES (885, 1, 2.50, 76, 253, '', 2.50, '2019-10-15 13:17:41.804145');
INSERT INTO public.producto_vendidos VALUES (886, 1, 55.00, 77, 253, '', 55.00, '2019-10-15 13:17:41.804145');
INSERT INTO public.producto_vendidos VALUES (887, 1, 2.50, 76, 254, '', 2.50, '2019-10-15 14:07:01.678744');
INSERT INTO public.producto_vendidos VALUES (888, 1, 55.00, 77, 254, '', 55.00, '2019-10-15 14:07:01.678744');
INSERT INTO public.producto_vendidos VALUES (889, 1, 2.50, 76, 255, '', 2.50, '2019-10-15 14:08:56.90774');
INSERT INTO public.producto_vendidos VALUES (890, 1, 55.00, 77, 255, '', 55.00, '2019-10-15 14:08:56.90774');
INSERT INTO public.producto_vendidos VALUES (891, 1, 2.50, 76, 256, '', 2.50, '2019-10-15 14:13:06.903589');
INSERT INTO public.producto_vendidos VALUES (892, 1, 55.00, 77, 256, '', 55.00, '2019-10-15 14:13:06.903589');
INSERT INTO public.producto_vendidos VALUES (893, 1, 2.50, 76, 257, '', 2.50, '2019-10-15 14:15:16.346076');
INSERT INTO public.producto_vendidos VALUES (894, 1, 55.00, 77, 257, '', 55.00, '2019-10-15 14:15:16.346076');
INSERT INTO public.producto_vendidos VALUES (895, 1, 11.00, 97, 257, '', 11.00, '2019-10-15 14:15:16.346076');
INSERT INTO public.producto_vendidos VALUES (896, 1, 1.50, 71, 257, '', 1.50, '2019-10-15 14:15:16.346076');
INSERT INTO public.producto_vendidos VALUES (897, 1, 2.50, 76, 258, '', 2.50, '2019-10-15 14:17:18.362407');
INSERT INTO public.producto_vendidos VALUES (898, 1, 55.00, 77, 258, '', 55.00, '2019-10-15 14:17:18.362407');
INSERT INTO public.producto_vendidos VALUES (899, 1, 5.50, 74, 258, '', 5.50, '2019-10-15 14:17:18.362407');
INSERT INTO public.producto_vendidos VALUES (900, 1, 5.50, 74, 259, '', 5.50, '2019-10-15 14:18:32.714062');
INSERT INTO public.producto_vendidos VALUES (901, 1, 5.00, 95, 259, '', 5.00, '2019-10-15 14:18:32.714062');
INSERT INTO public.producto_vendidos VALUES (902, 1, 2.50, 76, 260, '', 2.50, '2019-10-15 17:32:01.275354');
INSERT INTO public.producto_vendidos VALUES (903, 1, 55.00, 77, 260, '', 55.00, '2019-10-15 17:32:01.275354');
INSERT INTO public.producto_vendidos VALUES (904, 1, 1.50, 71, 260, '', 1.50, '2019-10-15 17:32:01.275354');
INSERT INTO public.producto_vendidos VALUES (905, 1, 5.00, 95, 260, '', 5.00, '2019-10-15 17:32:01.275354');
INSERT INTO public.producto_vendidos VALUES (906, 1, 2.50, 76, 261, '', 2.50, '2019-10-15 17:37:56.279787');
INSERT INTO public.producto_vendidos VALUES (907, 1, 5.50, 74, 261, '', 5.50, '2019-10-15 17:37:56.279787');
INSERT INTO public.producto_vendidos VALUES (908, 1, 5.00, 95, 261, '', 5.00, '2019-10-15 17:37:56.279787');
INSERT INTO public.producto_vendidos VALUES (909, 1, 1.50, 71, 261, '', 1.50, '2019-10-15 17:37:56.279787');
INSERT INTO public.producto_vendidos VALUES (910, 1, 2.50, 76, 262, '', 2.50, '2019-10-15 17:42:00.30424');
INSERT INTO public.producto_vendidos VALUES (911, 1, 11.00, 97, 262, '', 11.00, '2019-10-15 17:42:00.30424');
INSERT INTO public.producto_vendidos VALUES (912, 1, 5.50, 74, 262, '', 5.50, '2019-10-15 17:42:00.30424');
INSERT INTO public.producto_vendidos VALUES (913, 1, 5.00, 95, 262, '', 5.00, '2019-10-15 17:42:00.30424');
INSERT INTO public.producto_vendidos VALUES (914, 1, 1.50, 71, 262, '', 1.50, '2019-10-15 17:42:00.30424');
INSERT INTO public.producto_vendidos VALUES (915, 1, 2.50, 76, 263, '', 2.50, '2019-10-15 17:58:24.782415');
INSERT INTO public.producto_vendidos VALUES (916, 1, 5.50, 74, 263, '', 5.50, '2019-10-15 17:58:24.782415');
INSERT INTO public.producto_vendidos VALUES (917, 1, 5.00, 95, 263, '', 5.00, '2019-10-15 17:58:24.782415');
INSERT INTO public.producto_vendidos VALUES (918, 1, 1.50, 71, 263, '', 1.50, '2019-10-15 17:58:24.782415');
INSERT INTO public.producto_vendidos VALUES (919, 1, 55.00, 77, 263, '', 55.00, '2019-10-15 17:58:24.782415');
INSERT INTO public.producto_vendidos VALUES (920, 1, 2.50, 76, 264, '', 2.50, '2019-10-15 18:26:45.191809');
INSERT INTO public.producto_vendidos VALUES (921, 1, 55.00, 77, 264, '', 55.00, '2019-10-15 18:26:45.191809');
INSERT INTO public.producto_vendidos VALUES (922, 1, 2.50, 76, 265, '', 2.50, '2019-10-15 18:27:33.496487');
INSERT INTO public.producto_vendidos VALUES (923, 1, 55.00, 77, 265, '', 55.00, '2019-10-15 18:27:33.496487');
INSERT INTO public.producto_vendidos VALUES (924, 1, 2.50, 76, 266, '', 2.50, '2019-10-15 18:28:43.545828');
INSERT INTO public.producto_vendidos VALUES (925, 1, 55.00, 77, 266, '', 55.00, '2019-10-15 18:28:43.545828');
INSERT INTO public.producto_vendidos VALUES (926, 1, 2.50, 76, 267, '', 2.50, '2019-10-15 21:33:37.214747');
INSERT INTO public.producto_vendidos VALUES (927, 1, 55.00, 77, 267, '', 55.00, '2019-10-15 21:33:37.214747');
INSERT INTO public.producto_vendidos VALUES (928, 1, 2.50, 76, 268, '', 2.50, '2019-10-16 07:27:24.535258');
INSERT INTO public.producto_vendidos VALUES (929, 1, 55.00, 77, 268, '', 55.00, '2019-10-16 07:27:24.535258');
INSERT INTO public.producto_vendidos VALUES (930, 1, 1.50, 71, 268, '', 1.50, '2019-10-16 07:27:24.535258');
INSERT INTO public.producto_vendidos VALUES (931, 1, 5.00, 95, 268, '', 5.00, '2019-10-16 07:27:24.535258');
INSERT INTO public.producto_vendidos VALUES (932, 1, 2.50, 76, 269, '', 2.50, '2019-10-16 07:34:04.983003');
INSERT INTO public.producto_vendidos VALUES (933, 1, 55.00, 77, 269, '', 55.00, '2019-10-16 07:34:04.983003');
INSERT INTO public.producto_vendidos VALUES (934, 1, 1.50, 71, 269, '', 1.50, '2019-10-16 07:34:04.983003');
INSERT INTO public.producto_vendidos VALUES (935, 1, 11.00, 97, 269, '', 11.00, '2019-10-16 07:34:04.983003');
INSERT INTO public.producto_vendidos VALUES (936, 1, 2.50, 76, 270, '', 2.50, '2019-10-16 07:40:01.511625');
INSERT INTO public.producto_vendidos VALUES (937, 1, 55.00, 77, 270, '', 55.00, '2019-10-16 07:40:01.511625');
INSERT INTO public.producto_vendidos VALUES (938, 1, 2.50, 76, 271, '', 2.50, '2019-10-16 07:44:59.274081');
INSERT INTO public.producto_vendidos VALUES (939, 1, 5.50, 74, 271, '', 5.50, '2019-10-16 07:44:59.274081');
INSERT INTO public.producto_vendidos VALUES (940, 1, 1.50, 71, 271, '', 1.50, '2019-10-16 07:44:59.274081');
INSERT INTO public.producto_vendidos VALUES (941, 1, 22.50, 81, 272, '', 22.50, '2019-10-16 07:46:41.363738');
INSERT INTO public.producto_vendidos VALUES (942, 1, 35.00, 84, 272, '', 35.00, '2019-10-16 07:46:41.363738');
INSERT INTO public.producto_vendidos VALUES (943, 1, 5.50, 85, 272, '', 5.50, '2019-10-16 07:46:41.363738');
INSERT INTO public.producto_vendidos VALUES (944, 1, 15.00, 75, 272, '', 15.00, '2019-10-16 07:46:41.363738');
INSERT INTO public.producto_vendidos VALUES (945, 1, 2.50, 76, 273, '', 2.50, '2019-10-16 07:48:33.084304');
INSERT INTO public.producto_vendidos VALUES (946, 1, 5.50, 74, 273, '', 5.50, '2019-10-16 07:48:33.084304');
INSERT INTO public.producto_vendidos VALUES (947, 1, 1.50, 71, 273, '', 1.50, '2019-10-16 07:48:33.084304');
INSERT INTO public.producto_vendidos VALUES (948, 1, 5.00, 95, 273, '', 5.00, '2019-10-16 07:48:33.084304');
INSERT INTO public.producto_vendidos VALUES (949, 1, 2.50, 76, 274, '', 2.50, '2019-10-16 08:16:50.593508');
INSERT INTO public.producto_vendidos VALUES (950, 1, 55.00, 77, 274, '', 55.00, '2019-10-16 08:16:50.593508');
INSERT INTO public.producto_vendidos VALUES (951, 1, 1.50, 71, 274, '', 1.50, '2019-10-16 08:16:50.593508');
INSERT INTO public.producto_vendidos VALUES (952, 1, 5.50, 74, 274, '', 5.50, '2019-10-16 08:16:50.593508');
INSERT INTO public.producto_vendidos VALUES (953, 1, 2.50, 76, 275, 'descremado', 2.50, '2019-10-16 08:18:31.218199');
INSERT INTO public.producto_vendidos VALUES (954, 1, 55.00, 77, 275, '', 55.00, '2019-10-16 08:18:31.218199');
INSERT INTO public.producto_vendidos VALUES (955, 1, 1.50, 71, 275, '', 1.50, '2019-10-16 08:18:31.218199');
INSERT INTO public.producto_vendidos VALUES (956, 1, 5.50, 74, 275, '', 5.50, '2019-10-16 08:18:31.218199');
INSERT INTO public.producto_vendidos VALUES (957, 1, 2.50, 76, 276, '', 2.50, '2019-10-16 08:30:04.547039');
INSERT INTO public.producto_vendidos VALUES (958, 1, 55.00, 77, 276, '', 55.00, '2019-10-16 08:30:04.547039');
INSERT INTO public.producto_vendidos VALUES (959, 1, 1.50, 71, 276, '', 1.50, '2019-10-16 08:30:04.547039');
INSERT INTO public.producto_vendidos VALUES (960, 1, 5.00, 95, 276, '', 5.00, '2019-10-16 08:30:04.547039');
INSERT INTO public.producto_vendidos VALUES (961, 1, 5.50, 74, 276, '', 5.50, '2019-10-16 08:30:04.547039');
INSERT INTO public.producto_vendidos VALUES (962, 1, 11.00, 97, 276, '', 11.00, '2019-10-16 08:30:04.547039');
INSERT INTO public.producto_vendidos VALUES (963, 2, 5.00, 76, 277, '1 con 2 cucharillas de azucar, 1 1 cuacharilla de azucar', 2.50, '2019-10-16 08:34:13.019756');
INSERT INTO public.producto_vendidos VALUES (964, 1, 11.00, 97, 277, 'light', 11.00, '2019-10-16 08:34:13.019756');
INSERT INTO public.producto_vendidos VALUES (965, 1, 5.50, 74, 277, 'chocolate', 5.50, '2019-10-16 08:34:13.019756');
INSERT INTO public.producto_vendidos VALUES (966, 1, 5.00, 95, 277, 'sin azucar molida', 5.00, '2019-10-16 08:34:13.019756');
INSERT INTO public.producto_vendidos VALUES (967, 1, 1.50, 71, 277, '', 1.50, '2019-10-16 08:34:13.019756');
INSERT INTO public.producto_vendidos VALUES (968, 1, 55.00, 77, 277, '', 55.00, '2019-10-16 08:34:13.019756');
INSERT INTO public.producto_vendidos VALUES (969, 1, 16.50, 88, 277, '', 16.50, '2019-10-16 08:34:13.019756');
INSERT INTO public.producto_vendidos VALUES (970, 1, 2.00, 73, 277, '', 2.00, '2019-10-16 08:34:13.019756');
INSERT INTO public.producto_vendidos VALUES (971, 1, 5.50, 74, 278, '', 5.50, '2019-10-16 08:55:05.936637');
INSERT INTO public.producto_vendidos VALUES (972, 2, 22.00, 97, 278, 'coca cola light', 11.00, '2019-10-16 08:55:05.936637');
INSERT INTO public.producto_vendidos VALUES (973, 1, 5.00, 95, 278, '', 5.00, '2019-10-16 08:55:05.936637');
INSERT INTO public.producto_vendidos VALUES (974, 1, 1.50, 71, 278, '', 1.50, '2019-10-16 08:55:05.936637');
INSERT INTO public.producto_vendidos VALUES (975, 1, 2.50, 76, 279, '', 2.50, '2019-10-16 09:37:25.192717');
INSERT INTO public.producto_vendidos VALUES (976, 1, 5.50, 74, 279, '', 5.50, '2019-10-16 09:37:25.192717');
INSERT INTO public.producto_vendidos VALUES (977, 1, 5.00, 95, 279, '', 5.00, '2019-10-16 09:37:25.192717');
INSERT INTO public.producto_vendidos VALUES (978, 1, 1.50, 71, 279, '', 1.50, '2019-10-16 09:37:25.192717');
INSERT INTO public.producto_vendidos VALUES (979, 1, 1.50, 72, 279, '', 1.50, '2019-10-16 09:37:25.192717');
INSERT INTO public.producto_vendidos VALUES (980, 1, 52.00, 87, 279, '', 52.00, '2019-10-16 09:37:25.192717');
INSERT INTO public.producto_vendidos VALUES (981, 1, 2.50, 76, 280, '', 2.50, '2019-10-16 09:39:21.86323');
INSERT INTO public.producto_vendidos VALUES (982, 1, 55.00, 77, 280, '', 55.00, '2019-10-16 09:39:21.86323');
INSERT INTO public.producto_vendidos VALUES (983, 1, 5.50, 74, 280, '', 5.50, '2019-10-16 09:39:21.86323');
INSERT INTO public.producto_vendidos VALUES (984, 1, 1.50, 71, 280, '', 1.50, '2019-10-16 09:39:21.86323');
INSERT INTO public.producto_vendidos VALUES (985, 1, 2.50, 76, 281, '', 2.50, '2019-10-16 09:41:47.252447');
INSERT INTO public.producto_vendidos VALUES (986, 1, 11.00, 97, 281, '', 11.00, '2019-10-16 09:41:47.252447');
INSERT INTO public.producto_vendidos VALUES (987, 1, 5.50, 74, 281, '', 5.50, '2019-10-16 09:41:47.252447');
INSERT INTO public.producto_vendidos VALUES (988, 1, 5.00, 95, 281, '', 5.00, '2019-10-16 09:41:47.252447');
INSERT INTO public.producto_vendidos VALUES (989, 1, 1.50, 71, 281, '', 1.50, '2019-10-16 09:41:47.252447');
INSERT INTO public.producto_vendidos VALUES (990, 1, 5.50, 74, 282, '', 5.50, '2019-10-16 09:42:48.171765');
INSERT INTO public.producto_vendidos VALUES (991, 1, 1.50, 71, 282, '', 1.50, '2019-10-16 09:42:48.171765');
INSERT INTO public.producto_vendidos VALUES (992, 1, 11.00, 97, 282, '', 11.00, '2019-10-16 09:42:48.171765');
INSERT INTO public.producto_vendidos VALUES (993, 1, 2.50, 76, 282, '', 2.50, '2019-10-16 09:42:48.171765');
INSERT INTO public.producto_vendidos VALUES (994, 1, 2.50, 76, 283, '', 2.50, '2019-10-16 09:44:29.292495');
INSERT INTO public.producto_vendidos VALUES (995, 1, 11.00, 97, 283, '', 11.00, '2019-10-16 09:44:29.292495');
INSERT INTO public.producto_vendidos VALUES (996, 1, 5.50, 74, 283, '', 5.50, '2019-10-16 09:44:29.292495');
INSERT INTO public.producto_vendidos VALUES (997, 1, 1.50, 71, 283, '', 1.50, '2019-10-16 09:44:29.292495');
INSERT INTO public.producto_vendidos VALUES (998, 1, 1.50, 71, 284, '', 1.50, '2019-10-16 09:45:47.931714');
INSERT INTO public.producto_vendidos VALUES (999, 1, 55.00, 77, 284, '', 55.00, '2019-10-16 09:45:47.931714');
INSERT INTO public.producto_vendidos VALUES (1000, 1, 5.50, 74, 284, '', 5.50, '2019-10-16 09:45:47.931714');
INSERT INTO public.producto_vendidos VALUES (1001, 1, 5.00, 95, 284, '', 5.00, '2019-10-16 09:45:47.931714');
INSERT INTO public.producto_vendidos VALUES (1002, 1, 52.00, 87, 284, '', 52.00, '2019-10-16 09:45:47.931714');
INSERT INTO public.producto_vendidos VALUES (1003, 1, 1.50, 72, 284, '', 1.50, '2019-10-16 09:45:47.931714');
INSERT INTO public.producto_vendidos VALUES (1004, 1, 55.00, 77, 285, '', 55.00, '2019-10-16 10:43:10.34583');
INSERT INTO public.producto_vendidos VALUES (1005, 1, 1.50, 71, 285, '', 1.50, '2019-10-16 10:43:10.34583');
INSERT INTO public.producto_vendidos VALUES (1006, 1, 5.00, 95, 285, '', 5.00, '2019-10-16 10:43:10.34583');
INSERT INTO public.producto_vendidos VALUES (1007, 1, 5.50, 74, 285, '', 5.50, '2019-10-16 10:43:10.34583');
INSERT INTO public.producto_vendidos VALUES (1008, 2, 3.00, 72, 285, '1 lt de 2 lt', 1.50, '2019-10-16 10:43:10.34583');
INSERT INTO public.producto_vendidos VALUES (1009, 1, 52.00, 87, 285, '', 52.00, '2019-10-16 10:43:10.34583');
INSERT INTO public.producto_vendidos VALUES (1010, 1, 2.50, 76, 286, '', 2.50, '2019-10-16 10:43:57.677798');
INSERT INTO public.producto_vendidos VALUES (1011, 1, 5.50, 74, 286, '', 5.50, '2019-10-16 10:43:57.677798');
INSERT INTO public.producto_vendidos VALUES (1012, 1, 5.00, 95, 286, '', 5.00, '2019-10-16 10:43:57.677798');
INSERT INTO public.producto_vendidos VALUES (1013, 1, 1.50, 71, 286, '', 1.50, '2019-10-16 10:43:57.677798');
INSERT INTO public.producto_vendidos VALUES (1014, 1, 11.00, 97, 286, '', 11.00, '2019-10-16 10:43:57.677798');
INSERT INTO public.producto_vendidos VALUES (1015, 1, 55.00, 77, 287, '', 55.00, '2019-10-16 15:17:19.011071');
INSERT INTO public.producto_vendidos VALUES (1016, 1, 2.50, 76, 287, '', 2.50, '2019-10-16 15:17:19.011071');
INSERT INTO public.producto_vendidos VALUES (1017, 1, 2.50, 76, 288, '', 2.50, '2019-10-16 15:20:14.195753');
INSERT INTO public.producto_vendidos VALUES (1018, 1, 1.50, 71, 288, '', 1.50, '2019-10-16 15:20:14.195753');
INSERT INTO public.producto_vendidos VALUES (1019, 1, 1.50, 71, 289, '', 1.50, '2019-10-16 15:31:19.246261');
INSERT INTO public.producto_vendidos VALUES (1020, 1, 11.00, 97, 289, '', 11.00, '2019-10-16 15:31:19.246261');
INSERT INTO public.producto_vendidos VALUES (1021, 1, 55.00, 77, 289, '', 55.00, '2019-10-16 15:31:19.246261');
INSERT INTO public.producto_vendidos VALUES (1022, 1, 55.00, 77, 290, '', 55.00, '2019-10-16 15:41:37.765948');
INSERT INTO public.producto_vendidos VALUES (1023, 1, 2.50, 76, 290, '', 2.50, '2019-10-16 15:41:37.765948');
INSERT INTO public.producto_vendidos VALUES (1024, 1, 1.50, 71, 290, '', 1.50, '2019-10-16 15:41:37.765948');
INSERT INTO public.producto_vendidos VALUES (1025, 1, 5.00, 95, 290, '', 5.00, '2019-10-16 15:41:37.765948');
INSERT INTO public.producto_vendidos VALUES (1026, 1, 5.50, 74, 290, '', 5.50, '2019-10-16 15:41:37.765948');
INSERT INTO public.producto_vendidos VALUES (1027, 1, 55.00, 77, 291, '', 55.00, '2019-10-16 15:42:41.139459');
INSERT INTO public.producto_vendidos VALUES (1028, 1, 2.50, 76, 291, '', 2.50, '2019-10-16 15:42:41.139459');
INSERT INTO public.producto_vendidos VALUES (1029, 1, 1.50, 71, 292, '', 1.50, '2019-10-16 15:43:30.040757');
INSERT INTO public.producto_vendidos VALUES (1030, 1, 11.00, 97, 292, '', 11.00, '2019-10-16 15:43:30.040757');
INSERT INTO public.producto_vendidos VALUES (1031, 1, 55.00, 77, 292, '', 55.00, '2019-10-16 15:43:30.040757');
INSERT INTO public.producto_vendidos VALUES (1032, 1, 55.00, 77, 293, '', 55.00, '2019-10-16 15:44:52.909128');
INSERT INTO public.producto_vendidos VALUES (1033, 1, 1.50, 71, 293, '', 1.50, '2019-10-16 15:44:52.909128');
INSERT INTO public.producto_vendidos VALUES (1034, 1, 11.00, 97, 293, '', 11.00, '2019-10-16 15:44:52.909128');
INSERT INTO public.producto_vendidos VALUES (1035, 1, 2.50, 76, 294, '', 2.50, '2019-10-16 15:47:11.469361');
INSERT INTO public.producto_vendidos VALUES (1036, 1, 11.00, 97, 294, '', 11.00, '2019-10-16 15:47:11.469361');
INSERT INTO public.producto_vendidos VALUES (1037, 1, 2.50, 76, 295, '', 2.50, '2019-10-16 15:47:53.968718');
INSERT INTO public.producto_vendidos VALUES (1038, 1, 11.00, 97, 295, '', 11.00, '2019-10-16 15:47:53.968718');
INSERT INTO public.producto_vendidos VALUES (1039, 1, 1.50, 71, 295, '', 1.50, '2019-10-16 15:47:53.968718');
INSERT INTO public.producto_vendidos VALUES (1040, 1, 2.50, 76, 296, '', 2.50, '2019-10-16 15:50:38.049593');
INSERT INTO public.producto_vendidos VALUES (1041, 1, 55.00, 77, 296, '', 55.00, '2019-10-16 15:50:38.049593');
INSERT INTO public.producto_vendidos VALUES (1042, 1, 11.00, 97, 296, '', 11.00, '2019-10-16 15:50:38.049593');
INSERT INTO public.producto_vendidos VALUES (1043, 1, 1.50, 71, 297, '', 1.50, '2019-10-16 15:55:29.242908');
INSERT INTO public.producto_vendidos VALUES (1044, 1, 11.00, 97, 297, '', 11.00, '2019-10-16 15:55:29.242908');
INSERT INTO public.producto_vendidos VALUES (1045, 1, 5.00, 95, 297, '', 5.00, '2019-10-16 15:55:29.242908');
INSERT INTO public.producto_vendidos VALUES (1046, 2, 11.00, 74, 297, 'de chocolate, y de naranja', 5.50, '2019-10-16 15:55:29.242908');
INSERT INTO public.producto_vendidos VALUES (1047, 1, 1.50, 72, 297, '', 1.50, '2019-10-16 15:55:29.242908');
INSERT INTO public.producto_vendidos VALUES (1048, 1, 52.00, 87, 297, '', 52.00, '2019-10-16 15:55:29.242908');
INSERT INTO public.producto_vendidos VALUES (1049, 1, 15.00, 94, 297, 'en barril', 15.00, '2019-10-16 15:55:29.242908');
INSERT INTO public.producto_vendidos VALUES (1050, 1, 16.50, 88, 297, '', 16.50, '2019-10-16 15:55:29.242908');
INSERT INTO public.producto_vendidos VALUES (1051, 1, 3.50, 78, 297, '', 3.50, '2019-10-16 15:55:29.242908');
INSERT INTO public.producto_vendidos VALUES (1052, 1, 1.50, 79, 297, 'de anis 2 cucharadas de azucar', 1.50, '2019-10-16 15:55:29.242908');
INSERT INTO public.producto_vendidos VALUES (1053, 1, 1.50, 72, 298, 'asdfsda  asdfas asdfasdf', 1.50, '2019-10-16 16:13:59.320802');
INSERT INTO public.producto_vendidos VALUES (1054, 1, 52.00, 87, 298, '', 52.00, '2019-10-16 16:13:59.320802');
INSERT INTO public.producto_vendidos VALUES (1055, 1, 5.50, 67, 298, '', 5.50, '2019-10-16 16:13:59.320802');
INSERT INTO public.producto_vendidos VALUES (1056, 1, 15.00, 94, 298, 'asdfsdasdf', 15.00, '2019-10-16 16:13:59.320802');
INSERT INTO public.producto_vendidos VALUES (1057, 1, 16.50, 88, 298, '', 16.50, '2019-10-16 16:13:59.320802');
INSERT INTO public.producto_vendidos VALUES (1058, 1, 2.00, 73, 298, '', 2.00, '2019-10-16 16:13:59.320802');
INSERT INTO public.producto_vendidos VALUES (1059, 1, 55.00, 77, 298, '', 55.00, '2019-10-16 16:13:59.320802');
INSERT INTO public.producto_vendidos VALUES (1060, 1, 2.50, 76, 298, ' asdfasdf asdf asf asfasdfasdf', 2.50, '2019-10-16 16:13:59.320802');
INSERT INTO public.producto_vendidos VALUES (1061, 1, 1.50, 71, 298, 'asdfasf asdfa afasd a asdfsdfadf', 1.50, '2019-10-16 16:13:59.320802');
INSERT INTO public.producto_vendidos VALUES (1062, 1, 25.00, 96, 298, 'asdfasf ', 25.00, '2019-10-16 16:13:59.320802');
INSERT INTO public.producto_vendidos VALUES (1063, 1, 15.00, 75, 298, '', 15.00, '2019-10-16 16:13:59.320802');
INSERT INTO public.producto_vendidos VALUES (1064, 1, 2.00, 73, 299, '', 2.00, '2019-10-16 16:14:46.377324');
INSERT INTO public.producto_vendidos VALUES (1065, 1, 16.50, 88, 299, '', 16.50, '2019-10-16 16:14:46.377324');
INSERT INTO public.producto_vendidos VALUES (1066, 1, 2.50, 76, 300, '', 2.50, '2019-10-16 16:21:42.024529');
INSERT INTO public.producto_vendidos VALUES (1067, 1, 11.00, 97, 300, '', 11.00, '2019-10-16 16:21:42.024529');
INSERT INTO public.producto_vendidos VALUES (1068, 1, 5.50, 74, 300, '', 5.50, '2019-10-16 16:21:42.024529');
INSERT INTO public.producto_vendidos VALUES (1069, 1, 1.50, 71, 300, '', 1.50, '2019-10-16 16:21:42.024529');
INSERT INTO public.producto_vendidos VALUES (1070, 1, 55.00, 77, 300, '', 55.00, '2019-10-16 16:21:42.024529');
INSERT INTO public.producto_vendidos VALUES (1071, 1, 16.50, 88, 300, '', 16.50, '2019-10-16 16:21:42.024529');
INSERT INTO public.producto_vendidos VALUES (1072, 1, 2.00, 73, 300, '', 2.00, '2019-10-16 16:21:42.024529');
INSERT INTO public.producto_vendidos VALUES (1073, 1, 5.50, 74, 301, '', 5.50, '2019-10-16 16:28:21.797565');
INSERT INTO public.producto_vendidos VALUES (1074, 1, 5.00, 95, 301, '', 5.00, '2019-10-16 16:28:21.797565');
INSERT INTO public.producto_vendidos VALUES (1075, 1, 11.00, 97, 301, '', 11.00, '2019-10-16 16:28:21.797565');
INSERT INTO public.producto_vendidos VALUES (1076, 1, 1.50, 72, 301, '', 1.50, '2019-10-16 16:28:21.797565');
INSERT INTO public.producto_vendidos VALUES (1077, 1, 5.50, 67, 301, 'juego', 5.50, '2019-10-16 16:28:21.797565');
INSERT INTO public.producto_vendidos VALUES (1078, 1, 3.50, 78, 301, '', 3.50, '2019-10-16 16:28:21.797565');
INSERT INTO public.producto_vendidos VALUES (1079, 1, 6.50, 91, 301, '', 6.50, '2019-10-16 16:28:21.797565');
INSERT INTO public.producto_vendidos VALUES (1080, 1, 56.30, 92, 301, '', 56.30, '2019-10-16 16:28:21.797565');
INSERT INTO public.producto_vendidos VALUES (1081, 2, 25.00, 93, 302, '', 12.50, '2019-10-16 16:32:23.109999');
INSERT INTO public.producto_vendidos VALUES (1082, 1, 80.00, 86, 302, '', 80.00, '2019-10-16 16:32:23.109999');
INSERT INTO public.producto_vendidos VALUES (1083, 1, 15.00, 94, 302, '', 15.00, '2019-10-16 16:32:23.109999');
INSERT INTO public.producto_vendidos VALUES (1084, 2, 11.00, 74, 302, '', 5.50, '2019-10-16 16:32:23.109999');
INSERT INTO public.producto_vendidos VALUES (1085, 1, 1.50, 71, 303, '', 1.50, '2019-10-16 16:49:10.561666');
INSERT INTO public.producto_vendidos VALUES (1086, 1, 11.00, 97, 303, '', 11.00, '2019-10-16 16:49:10.561666');
INSERT INTO public.producto_vendidos VALUES (1087, 1, 5.50, 67, 303, '', 5.50, '2019-10-16 16:49:10.561666');
INSERT INTO public.producto_vendidos VALUES (1088, 1, 2.00, 73, 303, '', 2.00, '2019-10-16 16:49:10.561666');
INSERT INTO public.producto_vendidos VALUES (1089, 1, 2.50, 76, 304, '', 2.50, '2019-10-16 17:17:34.203332');
INSERT INTO public.producto_vendidos VALUES (1090, 1, 5.50, 74, 304, '', 5.50, '2019-10-16 17:17:34.203332');
INSERT INTO public.producto_vendidos VALUES (1091, 1, 5.00, 95, 304, '', 5.00, '2019-10-16 17:17:34.203332');
INSERT INTO public.producto_vendidos VALUES (1092, 1, 1.50, 71, 304, '', 1.50, '2019-10-16 17:17:34.203332');
INSERT INTO public.producto_vendidos VALUES (1093, 3, 6.00, 73, 304, '', 2.00, '2019-10-16 17:17:34.203332');
INSERT INTO public.producto_vendidos VALUES (1094, 1, 16.50, 88, 304, '', 16.50, '2019-10-16 17:17:34.203332');
INSERT INTO public.producto_vendidos VALUES (1095, 1, 15.00, 94, 304, '', 15.00, '2019-10-16 17:17:34.203332');
INSERT INTO public.producto_vendidos VALUES (1096, 1, 56.30, 92, 304, '', 56.30, '2019-10-16 17:17:34.203332');
INSERT INTO public.producto_vendidos VALUES (1097, 1, 22.50, 83, 304, '', 22.50, '2019-10-16 17:17:34.203332');
INSERT INTO public.producto_vendidos VALUES (1098, 1, 2.50, 76, 305, '', 2.50, '2019-10-16 17:24:07.039328');
INSERT INTO public.producto_vendidos VALUES (1099, 1, 1.50, 71, 305, '', 1.50, '2019-10-16 17:24:07.039328');
INSERT INTO public.producto_vendidos VALUES (1100, 1, 11.00, 97, 305, '', 11.00, '2019-10-16 17:24:07.039328');
INSERT INTO public.producto_vendidos VALUES (1101, 1, 2.50, 76, 306, '', 2.50, '2019-10-16 17:27:09.088323');
INSERT INTO public.producto_vendidos VALUES (1102, 1, 55.00, 77, 306, '', 55.00, '2019-10-16 17:27:09.088323');
INSERT INTO public.producto_vendidos VALUES (1103, 1, 11.00, 97, 306, '', 11.00, '2019-10-16 17:27:09.088323');
INSERT INTO public.producto_vendidos VALUES (1104, 1, 11.00, 97, 307, '', 11.00, '2019-10-16 17:46:36.890324');
INSERT INTO public.producto_vendidos VALUES (1105, 1, 5.50, 74, 307, '', 5.50, '2019-10-16 17:46:36.890324');
INSERT INTO public.producto_vendidos VALUES (1106, 1, 5.00, 95, 307, '', 5.00, '2019-10-16 17:46:36.890324');
INSERT INTO public.producto_vendidos VALUES (1107, 1, 5.50, 67, 307, '', 5.50, '2019-10-16 17:46:36.890324');
INSERT INTO public.producto_vendidos VALUES (1108, 1, 11.00, 97, 308, '', 11.00, '2019-10-16 17:48:36.861556');
INSERT INTO public.producto_vendidos VALUES (1109, 1, 5.50, 74, 308, '', 5.50, '2019-10-16 17:48:36.861556');
INSERT INTO public.producto_vendidos VALUES (1110, 1, 5.00, 95, 308, '', 5.00, '2019-10-16 17:48:36.861556');
INSERT INTO public.producto_vendidos VALUES (1111, 1, 52.00, 87, 308, '', 52.00, '2019-10-16 17:48:36.861556');
INSERT INTO public.producto_vendidos VALUES (1112, 1, 5.50, 67, 308, '', 5.50, '2019-10-16 17:48:36.861556');
INSERT INTO public.producto_vendidos VALUES (1113, 1, 2.50, 76, 309, '', 2.50, '2019-10-16 18:21:17.704952');
INSERT INTO public.producto_vendidos VALUES (1114, 1, 5.50, 74, 309, '', 5.50, '2019-10-16 18:21:17.704952');
INSERT INTO public.producto_vendidos VALUES (1115, 1, 5.00, 95, 309, '', 5.00, '2019-10-16 18:21:17.704952');
INSERT INTO public.producto_vendidos VALUES (1116, 1, 1.50, 71, 309, '', 1.50, '2019-10-16 18:21:17.704952');
INSERT INTO public.producto_vendidos VALUES (1117, 1, 11.00, 97, 309, '', 11.00, '2019-10-16 18:21:17.704952');
INSERT INTO public.producto_vendidos VALUES (1118, 1, 2.00, 73, 309, '', 2.00, '2019-10-16 18:21:17.704952');
INSERT INTO public.producto_vendidos VALUES (1119, 1, 16.50, 88, 309, '', 16.50, '2019-10-16 18:21:17.704952');
INSERT INTO public.producto_vendidos VALUES (1120, 1, 5.50, 67, 309, '', 5.50, '2019-10-16 18:21:17.704952');
INSERT INTO public.producto_vendidos VALUES (1121, 1, 2.50, 76, 310, '', 2.50, '2019-10-16 18:44:08.208746');
INSERT INTO public.producto_vendidos VALUES (1122, 1, 5.50, 74, 310, '', 5.50, '2019-10-16 18:44:08.208746');
INSERT INTO public.producto_vendidos VALUES (1123, 1, 5.00, 95, 310, '', 5.00, '2019-10-16 18:44:08.208746');
INSERT INTO public.producto_vendidos VALUES (1124, 1, 11.00, 97, 310, '', 11.00, '2019-10-16 18:44:08.208746');
INSERT INTO public.producto_vendidos VALUES (1125, 1, 11.00, 97, 311, '', 11.00, '2019-10-16 18:45:58.546641');
INSERT INTO public.producto_vendidos VALUES (1126, 1, 5.00, 95, 311, 'asdfasf', 5.00, '2019-10-16 18:45:58.546641');
INSERT INTO public.producto_vendidos VALUES (1127, 1, 1.50, 71, 311, '', 1.50, '2019-10-16 18:45:58.546641');
INSERT INTO public.producto_vendidos VALUES (1128, 1, 55.00, 77, 311, 'asdfaf', 55.00, '2019-10-16 18:45:58.546641');
INSERT INTO public.producto_vendidos VALUES (1129, 1, 15.00, 94, 312, '', 15.00, '2019-10-16 18:48:38.082443');
INSERT INTO public.producto_vendidos VALUES (1130, 1, 12.50, 93, 312, '', 12.50, '2019-10-16 18:48:38.082443');
INSERT INTO public.producto_vendidos VALUES (1131, 1, 80.00, 86, 312, '', 80.00, '2019-10-16 18:48:38.082443');
INSERT INTO public.producto_vendidos VALUES (1132, 1, 2.50, 76, 313, '', 2.50, '2019-10-16 18:53:49.61583');
INSERT INTO public.producto_vendidos VALUES (1133, 1, 55.00, 77, 313, '', 55.00, '2019-10-16 18:53:49.61583');
INSERT INTO public.producto_vendidos VALUES (1134, 1, 1.50, 71, 313, '', 1.50, '2019-10-16 18:53:49.61583');
INSERT INTO public.producto_vendidos VALUES (1135, 1, 5.00, 95, 313, '', 5.00, '2019-10-16 18:53:49.61583');
INSERT INTO public.producto_vendidos VALUES (1136, 1, 5.50, 74, 313, '', 5.50, '2019-10-16 18:53:49.61583');
INSERT INTO public.producto_vendidos VALUES (1137, 1, 11.00, 97, 313, '', 11.00, '2019-10-16 18:53:49.61583');
INSERT INTO public.producto_vendidos VALUES (1138, 1, 2.50, 76, 314, '', 2.50, '2019-10-16 18:55:35.519183');
INSERT INTO public.producto_vendidos VALUES (1139, 1, 11.00, 97, 314, '', 11.00, '2019-10-16 18:55:35.519183');
INSERT INTO public.producto_vendidos VALUES (1140, 2, 11.00, 74, 314, 'chocolate, naranja', 5.50, '2019-10-16 18:55:35.519183');
INSERT INTO public.producto_vendidos VALUES (1141, 1, 5.00, 95, 314, '', 5.00, '2019-10-16 18:55:35.519183');
INSERT INTO public.producto_vendidos VALUES (1142, 2, 45.00, 81, 315, 'ala y pecho', 22.50, '2019-10-16 18:57:43.450427');
INSERT INTO public.producto_vendidos VALUES (1143, 1, 16.00, 82, 315, 'pierna', 16.00, '2019-10-16 18:57:43.450427');
INSERT INTO public.producto_vendidos VALUES (1144, 1, 11.00, 97, 315, 'light', 11.00, '2019-10-16 18:57:43.450427');
INSERT INTO public.producto_vendidos VALUES (1145, 1, 2.50, 76, 316, 'asdfasdf', 2.50, '2019-10-16 19:00:34.147837');
INSERT INTO public.producto_vendidos VALUES (1146, 1, 55.00, 77, 316, '', 55.00, '2019-10-16 19:00:34.147837');
INSERT INTO public.producto_vendidos VALUES (1147, 1, 1.50, 71, 316, 'asdfasdf', 1.50, '2019-10-16 19:00:34.147837');
INSERT INTO public.producto_vendidos VALUES (1148, 1, 5.00, 95, 316, '', 5.00, '2019-10-16 19:00:34.147837');
INSERT INTO public.producto_vendidos VALUES (1149, 1, 5.50, 74, 316, '', 5.50, '2019-10-16 19:00:34.147837');
INSERT INTO public.producto_vendidos VALUES (1150, 1, 2.50, 76, 317, '', 2.50, '2019-10-16 22:41:13.52325');
INSERT INTO public.producto_vendidos VALUES (1151, 1, 1.50, 71, 317, '', 1.50, '2019-10-16 22:41:13.52325');
INSERT INTO public.producto_vendidos VALUES (1152, 1, 11.00, 97, 317, '', 11.00, '2019-10-16 22:41:13.52325');
INSERT INTO public.producto_vendidos VALUES (1153, 1, 5.50, 74, 317, '', 5.50, '2019-10-16 22:41:13.52325');
INSERT INTO public.producto_vendidos VALUES (1154, 1, 2.50, 76, 318, '', 2.50, '2019-10-16 22:45:29.361673');
INSERT INTO public.producto_vendidos VALUES (1155, 1, 5.50, 74, 318, '', 5.50, '2019-10-16 22:45:29.361673');
INSERT INTO public.producto_vendidos VALUES (1156, 1, 5.00, 95, 318, '', 5.00, '2019-10-16 22:45:29.361673');
INSERT INTO public.producto_vendidos VALUES (1157, 1, 2.50, 76, 319, '', 2.50, '2019-10-16 22:48:01.11525');
INSERT INTO public.producto_vendidos VALUES (1158, 1, 11.00, 97, 319, '', 11.00, '2019-10-16 22:48:01.11525');
INSERT INTO public.producto_vendidos VALUES (1159, 1, 5.50, 74, 319, '', 5.50, '2019-10-16 22:48:01.11525');
INSERT INTO public.producto_vendidos VALUES (1160, 1, 5.00, 95, 319, '', 5.00, '2019-10-16 22:48:01.11525');
INSERT INTO public.producto_vendidos VALUES (1161, 1, 5.50, 67, 319, '', 5.50, '2019-10-16 22:48:01.11525');
INSERT INTO public.producto_vendidos VALUES (1162, 1, 52.00, 87, 319, '', 52.00, '2019-10-16 22:48:01.11525');
INSERT INTO public.producto_vendidos VALUES (1163, 1, 1.50, 72, 319, '', 1.50, '2019-10-16 22:48:01.11525');
INSERT INTO public.producto_vendidos VALUES (1164, 1, 55.00, 77, 320, '', 55.00, '2019-10-17 07:34:18.299913');
INSERT INTO public.producto_vendidos VALUES (1165, 1, 1.50, 71, 320, '', 1.50, '2019-10-17 07:34:18.299913');
INSERT INTO public.producto_vendidos VALUES (1166, 1, 11.00, 97, 320, '', 11.00, '2019-10-17 07:34:18.299913');
INSERT INTO public.producto_vendidos VALUES (1167, 1, 2.50, 76, 320, '', 2.50, '2019-10-17 07:34:18.299913');
INSERT INTO public.producto_vendidos VALUES (1168, 2, 5.00, 76, 321, '', 2.50, '2019-10-17 07:38:44.846834');
INSERT INTO public.producto_vendidos VALUES (1169, 2, 11.00, 74, 321, '', 5.50, '2019-10-17 07:38:44.846834');
INSERT INTO public.producto_vendidos VALUES (1170, 2, 5.00, 76, 322, '1 sin azucar, 1 miel', 2.50, '2019-10-17 07:40:27.341575');
INSERT INTO public.producto_vendidos VALUES (1171, 2, 11.00, 74, 322, '', 5.50, '2019-10-17 07:40:27.341575');
INSERT INTO public.producto_vendidos VALUES (1172, 1, 5.50, 74, 323, '', 5.50, '2019-10-17 07:41:33.63668');
INSERT INTO public.producto_vendidos VALUES (1173, 1, 5.00, 95, 323, '', 5.00, '2019-10-17 07:41:33.63668');
INSERT INTO public.producto_vendidos VALUES (1174, 1, 52.00, 87, 323, 'de pollo', 52.00, '2019-10-17 07:41:33.63668');
INSERT INTO public.producto_vendidos VALUES (1175, 1, 5.50, 67, 323, '', 5.50, '2019-10-17 07:41:33.63668');
INSERT INTO public.producto_vendidos VALUES (1176, 1, 2.50, 76, 325, 'asdfadsf', 2.50, '2019-10-17 11:39:29.183062');
INSERT INTO public.producto_vendidos VALUES (1177, 2, 22.00, 97, 325, 'asdfadfasf', 11.00, '2019-10-17 11:39:29.183062');
INSERT INTO public.producto_vendidos VALUES (1178, 4, 22.00, 74, 325, 'asdfasdf', 5.50, '2019-10-17 11:39:29.183062');
INSERT INTO public.producto_vendidos VALUES (1179, 3, 4.50, 71, 325, 'asdfasdfsaf', 1.50, '2019-10-17 11:39:29.183062');
INSERT INTO public.producto_vendidos VALUES (1180, 1, 5.00, 95, 325, 'asdfasdfasdf', 5.00, '2019-10-17 11:39:29.183062');
INSERT INTO public.producto_vendidos VALUES (1181, 2, 110.00, 77, 325, '', 55.00, '2019-10-17 11:39:29.183062');
INSERT INTO public.producto_vendidos VALUES (1182, 1, 2.50, 76, 326, '', 2.50, '2019-10-17 15:09:03.555634');
INSERT INTO public.producto_vendidos VALUES (1183, 1, 55.00, 77, 326, '', 55.00, '2019-10-17 15:09:03.555634');
INSERT INTO public.producto_vendidos VALUES (1184, 1, 1.50, 71, 326, '', 1.50, '2019-10-17 15:09:03.555634');
INSERT INTO public.producto_vendidos VALUES (1185, 1, 11.00, 97, 326, '', 11.00, '2019-10-17 15:09:03.555634');
INSERT INTO public.producto_vendidos VALUES (1186, 1, 2.50, 76, 327, '', 2.50, '2019-10-17 16:42:04.917588');
INSERT INTO public.producto_vendidos VALUES (1187, 1, 11.00, 97, 327, '', 11.00, '2019-10-17 16:42:04.917588');
INSERT INTO public.producto_vendidos VALUES (1188, 1, 5.50, 74, 327, '', 5.50, '2019-10-17 16:42:04.917588');
INSERT INTO public.producto_vendidos VALUES (1189, 1, 5.00, 95, 327, '', 5.00, '2019-10-17 16:42:04.917588');
INSERT INTO public.producto_vendidos VALUES (1190, 1, 5.50, 74, 328, '', 5.50, '2019-10-17 16:42:52.79991');
INSERT INTO public.producto_vendidos VALUES (1191, 1, 5.00, 95, 328, '', 5.00, '2019-10-17 16:42:52.79991');
INSERT INTO public.producto_vendidos VALUES (1192, 1, 1.50, 71, 328, '', 1.50, '2019-10-17 16:42:52.79991');
INSERT INTO public.producto_vendidos VALUES (1193, 1, 55.00, 77, 328, '', 55.00, '2019-10-17 16:42:52.79991');
INSERT INTO public.producto_vendidos VALUES (1194, 1, 2.50, 76, 328, '', 2.50, '2019-10-17 16:42:52.79991');
INSERT INTO public.producto_vendidos VALUES (1195, 1, 1.50, 72, 328, '', 1.50, '2019-10-17 16:42:52.79991');
INSERT INTO public.producto_vendidos VALUES (1196, 1, 52.00, 87, 328, '', 52.00, '2019-10-17 16:42:52.79991');
INSERT INTO public.producto_vendidos VALUES (1197, 1, 2.50, 76, 329, '', 2.50, '2019-10-17 16:55:08.85536');
INSERT INTO public.producto_vendidos VALUES (1198, 1, 55.00, 77, 329, '', 55.00, '2019-10-17 16:55:08.85536');
INSERT INTO public.producto_vendidos VALUES (1199, 1, 1.50, 71, 329, '', 1.50, '2019-10-17 16:55:08.85536');
INSERT INTO public.producto_vendidos VALUES (1200, 1, 5.50, 74, 329, '', 5.50, '2019-10-17 16:55:08.85536');
INSERT INTO public.producto_vendidos VALUES (1201, 1, 11.00, 97, 329, '', 11.00, '2019-10-17 16:55:08.85536');
INSERT INTO public.producto_vendidos VALUES (1202, 1, 11.00, 97, 330, '', 11.00, '2019-10-17 17:05:25.880989');
INSERT INTO public.producto_vendidos VALUES (1203, 1, 5.50, 74, 330, '', 5.50, '2019-10-17 17:05:25.880989');
INSERT INTO public.producto_vendidos VALUES (1204, 1, 5.00, 95, 330, '', 5.00, '2019-10-17 17:05:25.880989');
INSERT INTO public.producto_vendidos VALUES (1205, 1, 1.50, 71, 330, '', 1.50, '2019-10-17 17:05:25.880989');
INSERT INTO public.producto_vendidos VALUES (1206, 1, 55.00, 77, 330, '', 55.00, '2019-10-17 17:05:25.880989');
INSERT INTO public.producto_vendidos VALUES (1207, 1, 2.50, 76, 331, '', 2.50, '2019-10-17 17:10:10.758576');
INSERT INTO public.producto_vendidos VALUES (1208, 1, 55.00, 77, 331, '', 55.00, '2019-10-17 17:10:10.758576');
INSERT INTO public.producto_vendidos VALUES (1209, 1, 5.50, 74, 331, '', 5.50, '2019-10-17 17:10:10.758576');
INSERT INTO public.producto_vendidos VALUES (1210, 1, 55.00, 77, 332, '', 55.00, '2019-10-17 17:13:06.666455');
INSERT INTO public.producto_vendidos VALUES (1211, 1, 1.50, 72, 332, '', 1.50, '2019-10-17 17:13:06.666455');
INSERT INTO public.producto_vendidos VALUES (1212, 1, 52.00, 87, 332, '', 52.00, '2019-10-17 17:13:06.666455');
INSERT INTO public.producto_vendidos VALUES (1213, 1, 5.50, 67, 332, '', 5.50, '2019-10-17 17:13:06.666455');
INSERT INTO public.producto_vendidos VALUES (1214, 1, 2.50, 76, 333, '', 2.50, '2019-10-17 17:25:52.755389');
INSERT INTO public.producto_vendidos VALUES (1215, 1, 11.00, 97, 333, '', 11.00, '2019-10-17 17:25:52.755389');
INSERT INTO public.producto_vendidos VALUES (1216, 2, 11.00, 74, 333, 'choco naranja', 5.50, '2019-10-17 17:25:52.755389');
INSERT INTO public.producto_vendidos VALUES (1217, 1, 2.50, 76, 334, '', 2.50, '2019-10-17 17:26:48.132234');
INSERT INTO public.producto_vendidos VALUES (1218, 1, 11.00, 97, 334, '', 11.00, '2019-10-17 17:26:48.132234');
INSERT INTO public.producto_vendidos VALUES (1219, 1, 5.50, 74, 334, '', 5.50, '2019-10-17 17:26:48.132234');
INSERT INTO public.producto_vendidos VALUES (1220, 1, 1.50, 71, 334, '', 1.50, '2019-10-17 17:26:48.132234');
INSERT INTO public.producto_vendidos VALUES (1221, 1, 52.00, 87, 334, '', 52.00, '2019-10-17 17:26:48.132234');
INSERT INTO public.producto_vendidos VALUES (1222, 1, 11.00, 97, 335, 'entrega inmediata', 11.00, '2019-10-17 17:27:30.605436');
INSERT INTO public.producto_vendidos VALUES (1223, 2, 104.00, 87, 335, '', 52.00, '2019-10-17 17:27:30.605436');
INSERT INTO public.producto_vendidos VALUES (1224, 1, 3.50, 78, 336, '', 3.50, '2019-10-17 17:30:03.667136');
INSERT INTO public.producto_vendidos VALUES (1225, 1, 1.50, 79, 336, '', 1.50, '2019-10-17 17:30:03.667136');
INSERT INTO public.producto_vendidos VALUES (1226, 2, 104.00, 87, 337, '', 52.00, '2019-10-17 17:34:11.064187');
INSERT INTO public.producto_vendidos VALUES (1227, 2, 3.00, 72, 337, '', 1.50, '2019-10-17 17:34:11.064187');
INSERT INTO public.producto_vendidos VALUES (1228, 1, 55.00, 77, 337, '', 55.00, '2019-10-17 17:34:11.064187');
INSERT INTO public.producto_vendidos VALUES (1229, 1, 1.50, 71, 337, '', 1.50, '2019-10-17 17:34:11.064187');
INSERT INTO public.producto_vendidos VALUES (1230, 2, 110.00, 77, 338, 'pecho y ala', 55.00, '2019-10-17 17:44:45.166236');
INSERT INTO public.producto_vendidos VALUES (1231, 2, 22.00, 97, 338, '', 11.00, '2019-10-17 17:44:45.166236');
INSERT INTO public.producto_vendidos VALUES (1232, 2, 32.00, 82, 339, '', 16.00, '2019-10-17 18:03:53.980078');
INSERT INTO public.producto_vendidos VALUES (1233, 2, 3.00, 71, 339, '', 1.50, '2019-10-17 18:03:53.980078');
INSERT INTO public.producto_vendidos VALUES (1234, 1, 2.50, 76, 340, 'tinto', 2.50, '2019-10-17 18:05:40.435769');
INSERT INTO public.producto_vendidos VALUES (1235, 1, 1.50, 71, 340, '', 1.50, '2019-10-17 18:05:40.435769');
INSERT INTO public.producto_vendidos VALUES (1236, 1, 11.00, 97, 340, '', 11.00, '2019-10-17 18:05:40.435769');
INSERT INTO public.producto_vendidos VALUES (1237, 1, 2.50, 76, 341, '', 2.50, '2019-10-18 09:10:04.416539');
INSERT INTO public.producto_vendidos VALUES (1238, 1, 55.00, 77, 341, '', 55.00, '2019-10-18 09:10:04.416539');
INSERT INTO public.producto_vendidos VALUES (1239, 1, 2.50, 76, 342, '', 2.50, '2019-10-18 09:12:40.351633');
INSERT INTO public.producto_vendidos VALUES (1240, 1, 5.50, 74, 342, '', 5.50, '2019-10-18 09:12:40.351633');
INSERT INTO public.producto_vendidos VALUES (1241, 1, 5.00, 95, 342, '', 5.00, '2019-10-18 09:12:40.351633');
INSERT INTO public.producto_vendidos VALUES (1242, 2, 32.00, 104, 343, '', 16.00, '2019-10-18 09:36:33.187978');
INSERT INTO public.producto_vendidos VALUES (1243, 2, 3.00, 103, 343, '', 1.50, '2019-10-18 09:36:33.187978');
INSERT INTO public.producto_vendidos VALUES (1244, 2, 32.00, 104, 344, '', 16.00, '2019-10-18 10:00:30.70852');
INSERT INTO public.producto_vendidos VALUES (1245, 1, 1.50, 103, 344, '', 1.50, '2019-10-18 10:00:30.70852');
INSERT INTO public.producto_vendidos VALUES (1246, 1, 1.50, 102, 344, '', 1.50, '2019-10-18 10:00:30.70852');
INSERT INTO public.producto_vendidos VALUES (1247, 2, 32.00, 104, 345, '', 16.00, '2019-10-18 11:00:03.632822');
INSERT INTO public.producto_vendidos VALUES (1248, 2, 3.00, 102, 345, '', 1.50, '2019-10-18 11:00:03.632822');
INSERT INTO public.producto_vendidos VALUES (1249, 2, 3.00, 103, 346, '', 1.50, '2019-10-18 11:17:20.767165');
INSERT INTO public.producto_vendidos VALUES (1250, 2, 30.00, 105, 346, '', 15.00, '2019-10-18 11:17:20.767165');
INSERT INTO public.producto_vendidos VALUES (1251, 3, 4.50, 103, 347, '', 1.50, '2019-10-18 11:17:54.413854');
INSERT INTO public.producto_vendidos VALUES (1252, 1, 16.00, 104, 348, 'ala', 16.00, '2019-10-18 11:35:06.847697');
INSERT INTO public.producto_vendidos VALUES (1253, 1, 16.00, 104, 349, '', 16.00, '2019-10-18 11:47:45.755558');
INSERT INTO public.producto_vendidos VALUES (1254, 1, 1.50, 103, 349, '', 1.50, '2019-10-18 11:47:45.755558');
INSERT INTO public.producto_vendidos VALUES (1255, 1, 1.50, 102, 349, '', 1.50, '2019-10-18 11:47:45.755558');
INSERT INTO public.producto_vendidos VALUES (1256, 1, 16.00, 104, 350, '', 16.00, '2019-10-18 12:04:23.560149');
INSERT INTO public.producto_vendidos VALUES (1257, 1, 1.50, 103, 350, '', 1.50, '2019-10-18 12:04:23.560149');
INSERT INTO public.producto_vendidos VALUES (1258, 1, 1.50, 102, 350, '', 1.50, '2019-10-18 12:04:23.560149');
INSERT INTO public.producto_vendidos VALUES (1259, 1, 16.00, 104, 351, '', 16.00, '2019-10-18 12:05:09.286283');
INSERT INTO public.producto_vendidos VALUES (1260, 1, 1.50, 103, 351, '', 1.50, '2019-10-18 12:05:09.286283');
INSERT INTO public.producto_vendidos VALUES (1261, 1, 1.50, 102, 351, '', 1.50, '2019-10-18 12:05:09.286283');
INSERT INTO public.producto_vendidos VALUES (1262, 1, 15.00, 105, 351, '', 15.00, '2019-10-18 12:05:09.286283');
INSERT INTO public.producto_vendidos VALUES (1263, 1, 2.50, 76, 352, '', 2.50, '2019-10-18 12:16:37.802517');
INSERT INTO public.producto_vendidos VALUES (1264, 1, 55.00, 77, 352, '', 55.00, '2019-10-18 12:16:37.802517');
INSERT INTO public.producto_vendidos VALUES (1265, 1, 1.50, 71, 352, '', 1.50, '2019-10-18 12:16:37.802517');
INSERT INTO public.producto_vendidos VALUES (1266, 1, 5.00, 95, 352, '', 5.00, '2019-10-18 12:16:37.802517');
INSERT INTO public.producto_vendidos VALUES (1267, 1, 5.50, 74, 352, '', 5.50, '2019-10-18 12:16:37.802517');
INSERT INTO public.producto_vendidos VALUES (1268, 2, 5.00, 76, 353, '', 2.50, '2019-10-18 12:35:16.422929');
INSERT INTO public.producto_vendidos VALUES (1269, 2, 10.00, 95, 353, '', 5.00, '2019-10-18 12:35:16.422929');
INSERT INTO public.producto_vendidos VALUES (1270, 2, 10.00, 95, 354, '', 5.00, '2019-10-18 12:37:52.183263');
INSERT INTO public.producto_vendidos VALUES (1271, 2, 3.00, 71, 354, '', 1.50, '2019-10-18 12:37:52.183263');
INSERT INTO public.producto_vendidos VALUES (1272, 1, 2.50, 76, 355, '', 2.50, '2019-10-18 12:43:04.375045');
INSERT INTO public.producto_vendidos VALUES (1273, 1, 55.00, 77, 355, '', 55.00, '2019-10-18 12:43:04.375045');
INSERT INTO public.producto_vendidos VALUES (1274, 1, 1.50, 71, 355, '', 1.50, '2019-10-18 12:43:04.375045');
INSERT INTO public.producto_vendidos VALUES (1275, 1, 5.00, 95, 355, '', 5.00, '2019-10-18 12:43:04.375045');
INSERT INTO public.producto_vendidos VALUES (1276, 1, 5.50, 74, 355, '', 5.50, '2019-10-18 12:43:04.375045');
INSERT INTO public.producto_vendidos VALUES (1277, 1, 11.00, 97, 355, '', 11.00, '2019-10-18 12:43:04.375045');
INSERT INTO public.producto_vendidos VALUES (1278, 1, 11.00, 97, 356, '', 11.00, '2019-10-18 15:59:27.023015');
INSERT INTO public.producto_vendidos VALUES (1279, 1, 5.50, 74, 356, '', 5.50, '2019-10-18 15:59:27.023015');
INSERT INTO public.producto_vendidos VALUES (1280, 1, 5.00, 95, 356, '', 5.00, '2019-10-18 15:59:27.023015');
INSERT INTO public.producto_vendidos VALUES (1281, 1, 5.00, 95, 357, '', 5.00, '2019-10-18 15:59:46.312789');
INSERT INTO public.producto_vendidos VALUES (1282, 1, 5.50, 74, 357, '', 5.50, '2019-10-18 15:59:46.312789');
INSERT INTO public.producto_vendidos VALUES (1283, 1, 6.50, 91, 358, '', 6.50, '2019-10-18 16:00:03.497322');
INSERT INTO public.producto_vendidos VALUES (1284, 1, 56.30, 92, 358, '', 56.30, '2019-10-18 16:00:03.497322');
INSERT INTO public.producto_vendidos VALUES (1285, 1, 3.50, 78, 358, '', 3.50, '2019-10-18 16:00:03.497322');
INSERT INTO public.producto_vendidos VALUES (1286, 1, 5.00, 90, 359, '', 5.00, '2019-10-18 16:00:20.797395');
INSERT INTO public.producto_vendidos VALUES (1287, 1, 22.50, 81, 359, '', 22.50, '2019-10-18 16:00:20.797395');
INSERT INTO public.producto_vendidos VALUES (1288, 1, 10.50, 80, 360, '', 10.50, '2019-10-18 16:00:31.62814');
INSERT INTO public.producto_vendidos VALUES (1289, 1, 62.00, 89, 360, '', 62.00, '2019-10-18 16:00:31.62814');
INSERT INTO public.producto_vendidos VALUES (1290, 1, 1.50, 71, 361, '', 1.50, '2019-10-18 16:29:42.87541');
INSERT INTO public.producto_vendidos VALUES (1291, 2, 22.00, 97, 361, '', 11.00, '2019-10-18 16:29:42.87541');
INSERT INTO public.producto_vendidos VALUES (1292, 2, 5.00, 76, 362, '', 2.50, '2019-10-18 16:36:52.359024');
INSERT INTO public.producto_vendidos VALUES (1293, 2, 5.00, 76, 363, '', 2.50, '2019-10-18 16:58:52.194337');
INSERT INTO public.producto_vendidos VALUES (1294, 2, 10.00, 95, 363, '', 5.00, '2019-10-18 16:58:52.194337');
INSERT INTO public.producto_vendidos VALUES (1295, 2, 5.00, 76, 364, '', 2.50, '2019-10-18 16:59:13.539684');
INSERT INTO public.producto_vendidos VALUES (1296, 2, 11.00, 74, 364, '', 5.50, '2019-10-18 16:59:13.539684');
INSERT INTO public.producto_vendidos VALUES (1297, 1, 2.50, 76, 365, '', 2.50, '2019-10-18 17:01:02.064745');
INSERT INTO public.producto_vendidos VALUES (1298, 1, 55.00, 77, 365, '', 55.00, '2019-10-18 17:01:02.064745');
INSERT INTO public.producto_vendidos VALUES (1299, 2, 32.00, 104, 366, '', 16.00, '2019-10-18 17:10:03.675581');
INSERT INTO public.producto_vendidos VALUES (1300, 2, 3.00, 103, 366, '', 1.50, '2019-10-18 17:10:03.675581');
INSERT INTO public.producto_vendidos VALUES (1301, 2, 30.00, 105, 367, '', 15.00, '2019-10-18 17:11:07.226991');
INSERT INTO public.producto_vendidos VALUES (1302, 1, 1.50, 102, 367, '', 1.50, '2019-10-18 17:11:07.226991');
INSERT INTO public.producto_vendidos VALUES (1303, 1, 1.50, 103, 367, '', 1.50, '2019-10-18 17:11:07.226991');
INSERT INTO public.producto_vendidos VALUES (1304, 2, 32.00, 104, 368, '', 16.00, '2019-10-18 17:11:44.26026');
INSERT INTO public.producto_vendidos VALUES (1305, 1, 15.00, 105, 368, '', 15.00, '2019-10-18 17:11:44.26026');
INSERT INTO public.producto_vendidos VALUES (1306, 2, 3.00, 102, 369, '', 1.50, '2019-10-18 17:12:01.958049');
INSERT INTO public.producto_vendidos VALUES (1307, 2, 32.00, 104, 369, '', 16.00, '2019-10-18 17:12:01.958049');
INSERT INTO public.producto_vendidos VALUES (1308, 2, 30.00, 105, 370, '', 15.00, '2019-10-18 17:12:15.313788');
INSERT INTO public.producto_vendidos VALUES (1309, 2, 3.00, 103, 370, '', 1.50, '2019-10-18 17:12:15.313788');
INSERT INTO public.producto_vendidos VALUES (1310, 2, 30.00, 105, 371, '', 15.00, '2019-10-18 17:12:31.062055');
INSERT INTO public.producto_vendidos VALUES (1311, 2, 3.00, 102, 371, '', 1.50, '2019-10-18 17:12:31.062055');
INSERT INTO public.producto_vendidos VALUES (1312, 2, 32.00, 104, 372, '', 16.00, '2019-10-18 17:12:49.038888');
INSERT INTO public.producto_vendidos VALUES (1313, 2, 3.00, 103, 372, '', 1.50, '2019-10-18 17:12:49.038888');
INSERT INTO public.producto_vendidos VALUES (1314, 2, 30.00, 105, 373, '', 15.00, '2019-10-18 17:47:26.491911');
INSERT INTO public.producto_vendidos VALUES (1315, 2, 3.00, 103, 373, '', 1.50, '2019-10-18 17:47:26.491911');
INSERT INTO public.producto_vendidos VALUES (1316, 2, 3.00, 103, 374, '', 1.50, '2019-10-18 17:48:40.991812');
INSERT INTO public.producto_vendidos VALUES (1317, 1, 1.50, 102, 374, '', 1.50, '2019-10-18 17:48:40.991812');
INSERT INTO public.producto_vendidos VALUES (1318, 2, 30.00, 105, 374, '', 15.00, '2019-10-18 17:48:40.991812');
INSERT INTO public.producto_vendidos VALUES (1319, 1, 16.00, 104, 374, '', 16.00, '2019-10-18 17:48:40.991812');
INSERT INTO public.producto_vendidos VALUES (1320, 1, 15.00, 105, 375, '', 15.00, '2019-10-18 17:49:07.617979');
INSERT INTO public.producto_vendidos VALUES (1321, 1, 1.50, 103, 375, '', 1.50, '2019-10-18 17:49:07.617979');
INSERT INTO public.producto_vendidos VALUES (1322, 1, 15.00, 105, 376, '', 15.00, '2019-10-18 17:49:32.145027');
INSERT INTO public.producto_vendidos VALUES (1323, 1, 1.50, 102, 376, '', 1.50, '2019-10-18 17:49:32.145027');
INSERT INTO public.producto_vendidos VALUES (1324, 1, 16.00, 104, 377, '', 16.00, '2019-10-18 17:50:18.44107');
INSERT INTO public.producto_vendidos VALUES (1325, 1, 15.00, 105, 377, '', 15.00, '2019-10-18 17:50:18.44107');
INSERT INTO public.producto_vendidos VALUES (1326, 2, 3.00, 103, 377, '', 1.50, '2019-10-18 17:50:18.44107');
INSERT INTO public.producto_vendidos VALUES (1327, 2, 30.00, 105, 378, '', 15.00, '2019-10-18 17:51:23.419528');
INSERT INTO public.producto_vendidos VALUES (1328, 2, 3.00, 102, 378, '', 1.50, '2019-10-18 17:51:23.419528');
INSERT INTO public.producto_vendidos VALUES (1329, 3, 45.00, 105, 379, 'sin mostaza', 15.00, '2019-10-18 17:52:31.870256');
INSERT INTO public.producto_vendidos VALUES (1330, 2, 32.00, 104, 379, 'ala y pecho', 16.00, '2019-10-18 17:52:31.870256');
INSERT INTO public.producto_vendidos VALUES (1331, 2, 32.00, 104, 380, '', 16.00, '2019-10-18 17:53:22.077091');
INSERT INTO public.producto_vendidos VALUES (1332, 2, 3.00, 103, 380, '', 1.50, '2019-10-18 17:53:22.077091');
INSERT INTO public.producto_vendidos VALUES (1333, 1, 16.00, 104, 381, '', 16.00, '2019-10-18 17:57:45.115385');
INSERT INTO public.producto_vendidos VALUES (1334, 1, 16.00, 104, 382, '', 16.00, '2019-10-18 17:58:12.876429');
INSERT INTO public.producto_vendidos VALUES (1335, 1, 1.50, 103, 382, '', 1.50, '2019-10-18 17:58:12.876429');
INSERT INTO public.producto_vendidos VALUES (1336, 1, 50.00, 108, 383, '', 50.00, '2019-10-18 18:16:08.008972');
INSERT INTO public.producto_vendidos VALUES (1337, 2, 84.00, 106, 383, '', 42.00, '2019-10-18 18:16:08.008972');
INSERT INTO public.producto_vendidos VALUES (1338, 3, 6.00, 109, 383, 'light', 2.00, '2019-10-18 18:16:08.008972');
INSERT INTO public.producto_vendidos VALUES (1339, 1, 2.00, 110, 383, '', 2.00, '2019-10-18 18:16:08.008972');
INSERT INTO public.producto_vendidos VALUES (1340, 1, 45.00, 107, 384, '', 45.00, '2019-10-18 18:19:05.627777');
INSERT INTO public.producto_vendidos VALUES (1341, 1, 42.00, 106, 384, '', 42.00, '2019-10-18 18:19:05.627777');
INSERT INTO public.producto_vendidos VALUES (1342, 2, 4.00, 109, 384, '', 2.00, '2019-10-18 18:19:05.627777');
INSERT INTO public.producto_vendidos VALUES (1343, 1, 50.00, 108, 385, '', 50.00, '2019-10-18 18:19:48.747585');
INSERT INTO public.producto_vendidos VALUES (1344, 1, 2.00, 109, 385, '', 2.00, '2019-10-18 18:19:48.747585');
INSERT INTO public.producto_vendidos VALUES (1345, 1, 2.00, 110, 386, '', 2.00, '2019-10-18 18:20:37.271986');
INSERT INTO public.producto_vendidos VALUES (1346, 1, 50.00, 108, 386, '', 50.00, '2019-10-18 18:20:37.271986');
INSERT INTO public.producto_vendidos VALUES (1347, 2, 100.00, 108, 387, '', 50.00, '2019-10-18 18:36:06.587206');
INSERT INTO public.producto_vendidos VALUES (1348, 2, 90.00, 107, 387, '', 45.00, '2019-10-18 18:36:06.587206');
INSERT INTO public.producto_vendidos VALUES (1349, 2, 4.00, 110, 388, '', 2.00, '2019-10-18 18:36:58.986153');
INSERT INTO public.producto_vendidos VALUES (1350, 2, 90.00, 107, 388, '', 45.00, '2019-10-18 18:36:58.986153');
INSERT INTO public.producto_vendidos VALUES (1351, 2, 4.00, 109, 388, '', 2.00, '2019-10-18 18:36:58.986153');
INSERT INTO public.producto_vendidos VALUES (1352, 1, 42.00, 106, 389, '', 42.00, '2019-10-18 18:39:07.987104');
INSERT INTO public.producto_vendidos VALUES (1353, 1, 2.00, 109, 389, '', 2.00, '2019-10-18 18:39:07.987104');
INSERT INTO public.producto_vendidos VALUES (1354, 1, 45.00, 107, 389, '', 45.00, '2019-10-18 18:39:07.987104');
INSERT INTO public.producto_vendidos VALUES (1355, 2, 11.00, 74, 390, '', 5.50, '2019-10-19 23:11:30.849139');
INSERT INTO public.producto_vendidos VALUES (1356, 2, 104.00, 87, 390, '', 52.00, '2019-10-19 23:11:30.849139');
INSERT INTO public.producto_vendidos VALUES (1357, 2, 11.00, 74, 391, 'chocolate', 5.50, '2019-10-19 23:12:07.320693');
INSERT INTO public.producto_vendidos VALUES (1358, 1, 5.00, 95, 391, '', 5.00, '2019-10-19 23:12:07.320693');
INSERT INTO public.producto_vendidos VALUES (1359, 3, 7.50, 76, 391, '', 2.50, '2019-10-19 23:12:07.320693');
INSERT INTO public.producto_vendidos VALUES (1360, 2, 45.00, 81, 392, 'pierna, ala', 22.50, '2019-10-19 23:13:50.248124');
INSERT INTO public.producto_vendidos VALUES (1361, 1, 1.50, 71, 392, '', 1.50, '2019-10-19 23:13:50.248124');
INSERT INTO public.producto_vendidos VALUES (1362, 1, 1.50, 72, 392, '', 1.50, '2019-10-19 23:13:50.248124');
INSERT INTO public.producto_vendidos VALUES (1363, 2, 84.00, 106, 393, '', 42.00, '2019-10-22 12:23:17.300924');
INSERT INTO public.producto_vendidos VALUES (1364, 2, 90.00, 107, 393, '', 45.00, '2019-10-22 12:23:17.300924');
INSERT INTO public.producto_vendidos VALUES (1365, 4, 8.00, 109, 393, '', 2.00, '2019-10-22 12:23:17.300924');
INSERT INTO public.producto_vendidos VALUES (1366, 1, 50.00, 108, 394, '', 50.00, '2019-10-22 12:25:04.003177');
INSERT INTO public.producto_vendidos VALUES (1367, 2, 4.00, 109, 394, '', 2.00, '2019-10-22 12:25:04.003177');
INSERT INTO public.producto_vendidos VALUES (1368, 1, 42.00, 106, 395, '', 42.00, '2019-10-22 12:25:44.409818');
INSERT INTO public.producto_vendidos VALUES (1369, 1, 2.00, 109, 395, '', 2.00, '2019-10-22 12:25:44.409818');
INSERT INTO public.producto_vendidos VALUES (1370, 2, 84.00, 106, 396, '1 chicharron de pollo', 42.00, '2019-10-22 12:26:29.25847');
INSERT INTO public.producto_vendidos VALUES (1371, 2, 4.00, 109, 396, '', 2.00, '2019-10-22 12:26:29.25847');
INSERT INTO public.producto_vendidos VALUES (1372, 1, 45.00, 107, 397, '', 45.00, '2019-10-22 17:54:27.457841');
INSERT INTO public.producto_vendidos VALUES (1373, 1, 42.00, 106, 397, '', 42.00, '2019-10-22 17:54:27.457841');
INSERT INTO public.producto_vendidos VALUES (1374, 2, 4.00, 109, 397, '', 2.00, '2019-10-22 17:54:27.457841');
INSERT INTO public.producto_vendidos VALUES (1375, 2, 4.00, 110, 397, '', 2.00, '2019-10-22 17:54:27.457841');
INSERT INTO public.producto_vendidos VALUES (1376, 2, 90.00, 107, 398, '', 45.00, '2019-10-22 18:19:32.805536');
INSERT INTO public.producto_vendidos VALUES (1377, 2, 4.00, 109, 398, '', 2.00, '2019-10-22 18:19:32.805536');
INSERT INTO public.producto_vendidos VALUES (1378, 1, 45.00, 107, 399, '', 45.00, '2019-10-22 18:55:04.404205');
INSERT INTO public.producto_vendidos VALUES (1379, 1, 42.00, 106, 399, '', 42.00, '2019-10-22 18:55:04.404205');
INSERT INTO public.producto_vendidos VALUES (1380, 1, 2.00, 109, 399, '', 2.00, '2019-10-22 18:55:04.404205');
INSERT INTO public.producto_vendidos VALUES (1381, 1, 2.00, 110, 399, '', 2.00, '2019-10-22 18:55:04.404205');
INSERT INTO public.producto_vendidos VALUES (1382, 1, 42.00, 106, 400, '', 42.00, '2019-10-23 12:24:02.782058');
INSERT INTO public.producto_vendidos VALUES (1383, 1, 2.00, 109, 400, '', 2.00, '2019-10-23 12:24:02.782058');
INSERT INTO public.producto_vendidos VALUES (1384, 1, 45.00, 107, 400, '', 45.00, '2019-10-23 12:24:02.782058');
INSERT INTO public.producto_vendidos VALUES (1385, 2, 84.00, 106, 401, '', 42.00, '2019-10-23 13:47:31.644515');
INSERT INTO public.producto_vendidos VALUES (1386, 1, 45.00, 107, 401, '', 45.00, '2019-10-23 13:47:31.644515');
INSERT INTO public.producto_vendidos VALUES (1387, 1, 2.00, 109, 401, '', 2.00, '2019-10-23 13:47:31.644515');
INSERT INTO public.producto_vendidos VALUES (1388, 1, 2.00, 110, 401, '', 2.00, '2019-10-23 13:47:31.644515');
INSERT INTO public.producto_vendidos VALUES (1389, 1, 2.00, 110, 402, '', 2.00, '2019-10-23 13:49:36.613532');
INSERT INTO public.producto_vendidos VALUES (1390, 1, 45.00, 107, 402, '', 45.00, '2019-10-23 13:49:36.613532');
INSERT INTO public.producto_vendidos VALUES (1391, 1, 2.00, 109, 402, '', 2.00, '2019-10-23 13:49:36.613532');
INSERT INTO public.producto_vendidos VALUES (1392, 1, 42.00, 106, 402, '', 42.00, '2019-10-23 13:49:36.613532');
INSERT INTO public.producto_vendidos VALUES (1393, 1, 42.00, 106, 403, '', 42.00, '2019-10-23 13:53:19.01371');
INSERT INTO public.producto_vendidos VALUES (1394, 1, 2.00, 109, 403, '', 2.00, '2019-10-23 13:53:19.01371');
INSERT INTO public.producto_vendidos VALUES (1395, 1, 45.00, 107, 403, '', 45.00, '2019-10-23 13:53:19.01371');
INSERT INTO public.producto_vendidos VALUES (1396, 1, 2.00, 110, 403, '', 2.00, '2019-10-23 13:53:19.01371');
INSERT INTO public.producto_vendidos VALUES (1397, 1, 42.00, 106, 404, '', 42.00, '2019-10-23 14:00:42.725113');
INSERT INTO public.producto_vendidos VALUES (1398, 1, 2.00, 110, 404, '', 2.00, '2019-10-23 14:00:42.725113');
INSERT INTO public.producto_vendidos VALUES (1399, 1, 42.00, 106, 405, '', 42.00, '2019-10-23 14:03:25.65957');
INSERT INTO public.producto_vendidos VALUES (1400, 1, 2.00, 109, 405, '', 2.00, '2019-10-23 14:03:25.65957');
INSERT INTO public.producto_vendidos VALUES (1401, 1, 45.00, 107, 405, '', 45.00, '2019-10-23 14:03:25.65957');
INSERT INTO public.producto_vendidos VALUES (1402, 1, 42.00, 106, 406, '', 42.00, '2019-10-23 14:04:05.893639');
INSERT INTO public.producto_vendidos VALUES (1403, 1, 2.00, 110, 406, '', 2.00, '2019-10-23 14:04:05.893639');
INSERT INTO public.producto_vendidos VALUES (1404, 1, 45.00, 107, 406, '', 45.00, '2019-10-23 14:04:05.893639');
INSERT INTO public.producto_vendidos VALUES (1405, 1, 42.00, 106, 407, '', 42.00, '2019-10-23 14:27:36.973188');
INSERT INTO public.producto_vendidos VALUES (1406, 1, 2.00, 109, 407, '', 2.00, '2019-10-23 14:27:36.973188');
INSERT INTO public.producto_vendidos VALUES (1407, 1, 2.00, 110, 407, '', 2.00, '2019-10-23 14:27:36.973188');
INSERT INTO public.producto_vendidos VALUES (1408, 1, 50.00, 108, 407, '', 50.00, '2019-10-23 14:27:36.973188');
INSERT INTO public.producto_vendidos VALUES (1409, 1, 45.00, 107, 407, '', 45.00, '2019-10-23 14:27:36.973188');
INSERT INTO public.producto_vendidos VALUES (1410, 1, 42.00, 106, 408, '', 42.00, '2019-10-23 14:30:47.417699');
INSERT INTO public.producto_vendidos VALUES (1411, 1, 45.00, 107, 408, '', 45.00, '2019-10-23 14:30:47.417699');
INSERT INTO public.producto_vendidos VALUES (1412, 1, 50.00, 108, 408, 'sin aji', 50.00, '2019-10-23 14:30:47.417699');
INSERT INTO public.producto_vendidos VALUES (1413, 1, 42.00, 106, 409, '', 42.00, '2019-10-23 14:44:39.624459');
INSERT INTO public.producto_vendidos VALUES (1414, 1, 45.00, 107, 409, '', 45.00, '2019-10-23 14:44:39.624459');
INSERT INTO public.producto_vendidos VALUES (1415, 1, 2.00, 109, 409, '', 2.00, '2019-10-23 14:44:39.624459');
INSERT INTO public.producto_vendidos VALUES (1416, 1, 2.00, 110, 409, '', 2.00, '2019-10-23 14:44:39.624459');
INSERT INTO public.producto_vendidos VALUES (1417, 1, 42.00, 106, 410, '', 42.00, '2019-10-23 14:45:54.852213');
INSERT INTO public.producto_vendidos VALUES (1418, 1, 45.00, 107, 410, '', 45.00, '2019-10-23 14:45:54.852213');
INSERT INTO public.producto_vendidos VALUES (1419, 1, 2.00, 109, 410, '', 2.00, '2019-10-23 14:45:54.852213');
INSERT INTO public.producto_vendidos VALUES (1420, 1, 2.00, 110, 410, '', 2.00, '2019-10-23 14:45:54.852213');
INSERT INTO public.producto_vendidos VALUES (1421, 1, 45.00, 107, 411, '', 45.00, '2019-10-23 14:46:41.137952');
INSERT INTO public.producto_vendidos VALUES (1422, 1, 2.00, 110, 411, '', 2.00, '2019-10-23 14:46:41.137952');
INSERT INTO public.producto_vendidos VALUES (1423, 1, 2.00, 109, 411, '', 2.00, '2019-10-23 14:46:41.137952');
INSERT INTO public.producto_vendidos VALUES (1424, 1, 42.00, 106, 411, '', 42.00, '2019-10-23 14:46:41.137952');
INSERT INTO public.producto_vendidos VALUES (1425, 1, 42.00, 106, 412, '', 42.00, '2019-10-23 14:52:33.004506');
INSERT INTO public.producto_vendidos VALUES (1426, 1, 2.00, 109, 412, '', 2.00, '2019-10-23 14:52:33.004506');
INSERT INTO public.producto_vendidos VALUES (1427, 1, 2.00, 110, 412, '', 2.00, '2019-10-23 14:52:33.004506');
INSERT INTO public.producto_vendidos VALUES (1428, 1, 45.00, 107, 412, '', 45.00, '2019-10-23 14:52:33.004506');
INSERT INTO public.producto_vendidos VALUES (1429, 2, 84.00, 106, 413, '', 42.00, '2019-10-23 14:54:37.663572');
INSERT INTO public.producto_vendidos VALUES (1430, 2, 4.00, 109, 413, '', 2.00, '2019-10-23 14:54:37.663572');
INSERT INTO public.producto_vendidos VALUES (1431, 1, 50.00, 108, 414, '', 50.00, '2019-10-23 14:55:58.078889');
INSERT INTO public.producto_vendidos VALUES (1432, 1, 2.00, 109, 414, '', 2.00, '2019-10-23 14:55:58.078889');
INSERT INTO public.producto_vendidos VALUES (1433, 1, 50.00, 108, 415, '', 50.00, '2019-10-23 14:56:56.032124');
INSERT INTO public.producto_vendidos VALUES (1434, 1, 2.00, 110, 415, '', 2.00, '2019-10-23 14:56:56.032124');
INSERT INTO public.producto_vendidos VALUES (1435, 1, 2.00, 110, 416, 'Fria', 2.00, '2019-10-23 14:58:14.953423');
INSERT INTO public.producto_vendidos VALUES (1436, 1, 2.00, 109, 416, 'Natural', 2.00, '2019-10-23 14:58:14.953423');
INSERT INTO public.producto_vendidos VALUES (1437, 2, 84.00, 106, 416, '', 42.00, '2019-10-23 14:58:14.953423');
INSERT INTO public.producto_vendidos VALUES (1438, 1, 2.00, 110, 417, '', 2.00, '2019-10-23 17:08:34.901382');
INSERT INTO public.producto_vendidos VALUES (1439, 1, 2.00, 109, 417, '', 2.00, '2019-10-23 17:08:34.901382');
INSERT INTO public.producto_vendidos VALUES (1440, 1, 42.00, 106, 417, '', 42.00, '2019-10-23 17:08:34.901382');
INSERT INTO public.producto_vendidos VALUES (1441, 1, 45.00, 107, 417, '', 45.00, '2019-10-23 17:08:34.901382');
INSERT INTO public.producto_vendidos VALUES (1442, 1, 50.00, 108, 417, '', 50.00, '2019-10-23 17:08:34.901382');
INSERT INTO public.producto_vendidos VALUES (1443, 1, 42.00, 106, 418, '', 42.00, '2019-10-23 17:13:11.983638');
INSERT INTO public.producto_vendidos VALUES (1444, 1, 45.00, 107, 418, 'sin postre', 45.00, '2019-10-23 17:13:11.983638');
INSERT INTO public.producto_vendidos VALUES (1445, 2, 4.00, 109, 418, '', 2.00, '2019-10-23 17:13:11.983638');
INSERT INTO public.producto_vendidos VALUES (1446, 1, 42.00, 106, 419, '', 42.00, '2019-10-23 17:16:56.097522');
INSERT INTO public.producto_vendidos VALUES (1447, 2, 90.00, 107, 419, '', 45.00, '2019-10-23 17:16:56.097522');
INSERT INTO public.producto_vendidos VALUES (1448, 3, 6.00, 109, 419, '', 2.00, '2019-10-23 17:16:56.097522');
INSERT INTO public.producto_vendidos VALUES (1449, 1, 2.00, 109, 420, '', 2.00, '2019-10-23 17:22:05.33171');
INSERT INTO public.producto_vendidos VALUES (1450, 1, 2.00, 110, 420, '', 2.00, '2019-10-23 17:22:05.33171');
INSERT INTO public.producto_vendidos VALUES (1451, 2, 84.00, 106, 421, 'sin cueros', 42.00, '2019-10-23 17:29:45.628719');
INSERT INTO public.producto_vendidos VALUES (1452, 2, 4.00, 109, 421, '', 2.00, '2019-10-23 17:29:45.628719');
INSERT INTO public.producto_vendidos VALUES (1453, 2, 90.00, 107, 421, '', 45.00, '2019-10-23 17:29:45.628719');
INSERT INTO public.producto_vendidos VALUES (1454, 2, 4.00, 110, 421, '', 2.00, '2019-10-23 17:29:45.628719');
INSERT INTO public.producto_vendidos VALUES (1455, 1, 50.00, 108, 422, '', 50.00, '2019-10-23 17:30:28.013952');
INSERT INTO public.producto_vendidos VALUES (1456, 2, 4.00, 109, 422, '', 2.00, '2019-10-23 17:30:28.013952');
INSERT INTO public.producto_vendidos VALUES (1457, 2, 4.00, 109, 423, '', 2.00, '2019-10-23 17:49:20.576533');
INSERT INTO public.producto_vendidos VALUES (1458, 2, 4.00, 110, 423, '', 2.00, '2019-10-23 17:49:20.576533');
INSERT INTO public.producto_vendidos VALUES (1459, 2, 84.00, 106, 423, '', 42.00, '2019-10-23 17:49:20.576533');
INSERT INTO public.producto_vendidos VALUES (1460, 1, 50.00, 108, 423, '', 50.00, '2019-10-23 17:49:20.576533');
INSERT INTO public.producto_vendidos VALUES (1461, 1, 45.00, 107, 423, '', 45.00, '2019-10-23 17:49:20.576533');
INSERT INTO public.producto_vendidos VALUES (1462, 1, 42.00, 106, 424, '', 42.00, '2019-10-23 17:55:53.901279');
INSERT INTO public.producto_vendidos VALUES (1463, 1, 2.00, 109, 424, '', 2.00, '2019-10-23 17:55:53.901279');
INSERT INTO public.producto_vendidos VALUES (1464, 1, 2.00, 110, 424, '', 2.00, '2019-10-23 17:55:53.901279');
INSERT INTO public.producto_vendidos VALUES (1465, 1, 50.00, 108, 424, '', 50.00, '2019-10-23 17:55:53.901279');
INSERT INTO public.producto_vendidos VALUES (1466, 1, 45.00, 107, 424, '', 45.00, '2019-10-23 17:55:53.901279');
INSERT INTO public.producto_vendidos VALUES (1467, 2, 90.00, 107, 425, '', 45.00, '2019-10-23 17:58:45.513865');
INSERT INTO public.producto_vendidos VALUES (1468, 2, 84.00, 106, 425, '', 42.00, '2019-10-23 17:58:45.513865');
INSERT INTO public.producto_vendidos VALUES (1469, 4, 8.00, 109, 425, '', 2.00, '2019-10-23 17:58:45.513865');
INSERT INTO public.producto_vendidos VALUES (1470, 1, 45.00, 107, 426, '', 45.00, '2019-10-23 17:59:59.712416');
INSERT INTO public.producto_vendidos VALUES (1471, 1, 42.00, 106, 426, '', 42.00, '2019-10-23 17:59:59.712416');
INSERT INTO public.producto_vendidos VALUES (1472, 1, 2.00, 109, 427, '', 2.00, '2019-10-23 18:00:44.026216');
INSERT INTO public.producto_vendidos VALUES (1473, 1, 2.00, 110, 427, '', 2.00, '2019-10-23 18:00:44.026216');
INSERT INTO public.producto_vendidos VALUES (1474, 2, 90.00, 107, 428, '', 45.00, '2019-10-23 18:12:34.558676');
INSERT INTO public.producto_vendidos VALUES (1475, 2, 4.00, 110, 428, '', 2.00, '2019-10-23 18:12:34.558676');
INSERT INTO public.producto_vendidos VALUES (1476, 2, 84.00, 106, 429, '', 42.00, '2019-10-23 18:15:34.643354');
INSERT INTO public.producto_vendidos VALUES (1477, 2, 4.00, 109, 429, '', 2.00, '2019-10-23 18:15:34.643354');
INSERT INTO public.producto_vendidos VALUES (1478, 1, 42.00, 106, 430, '', 42.00, '2019-10-23 18:17:06.043353');
INSERT INTO public.producto_vendidos VALUES (1479, 1, 2.00, 109, 430, '', 2.00, '2019-10-23 18:17:06.043353');
INSERT INTO public.producto_vendidos VALUES (1480, 1, 45.00, 107, 430, '', 45.00, '2019-10-23 18:17:06.043353');
INSERT INTO public.producto_vendidos VALUES (1481, 1, 42.00, 106, 431, '', 42.00, '2019-10-23 18:32:03.168428');
INSERT INTO public.producto_vendidos VALUES (1482, 1, 2.00, 109, 431, '', 2.00, '2019-10-23 18:32:03.168428');
INSERT INTO public.producto_vendidos VALUES (1483, 1, 2.00, 110, 431, '', 2.00, '2019-10-23 18:32:03.168428');
INSERT INTO public.producto_vendidos VALUES (1484, 1, 45.00, 107, 431, '', 45.00, '2019-10-23 18:32:03.168428');
INSERT INTO public.producto_vendidos VALUES (1485, 1, 50.00, 108, 431, '', 50.00, '2019-10-23 18:32:03.168428');
INSERT INTO public.producto_vendidos VALUES (1486, 1, 50.00, 108, 432, '', 50.00, '2019-10-23 18:33:21.433597');
INSERT INTO public.producto_vendidos VALUES (1487, 1, 45.00, 107, 432, '', 45.00, '2019-10-23 18:33:21.433597');
INSERT INTO public.producto_vendidos VALUES (1488, 1, 42.00, 106, 432, '', 42.00, '2019-10-23 18:33:21.433597');
INSERT INTO public.producto_vendidos VALUES (1489, 1, 2.00, 109, 432, '', 2.00, '2019-10-23 18:33:21.433597');
INSERT INTO public.producto_vendidos VALUES (1490, 1, 2.00, 110, 432, '', 2.00, '2019-10-23 18:33:21.433597');
INSERT INTO public.producto_vendidos VALUES (1491, 1, 42.00, 106, 433, '', 42.00, '2019-10-24 18:26:04.057421');
INSERT INTO public.producto_vendidos VALUES (1492, 1, 2.00, 109, 433, '', 2.00, '2019-10-24 18:26:04.057421');
INSERT INTO public.producto_vendidos VALUES (1493, 1, 45.00, 107, 434, '', 45.00, '2019-10-24 18:26:15.383921');
INSERT INTO public.producto_vendidos VALUES (1494, 1, 2.00, 110, 434, '', 2.00, '2019-10-24 18:26:15.383921');
INSERT INTO public.producto_vendidos VALUES (1495, 1, 42.00, 106, 435, '', 42.00, '2019-10-25 00:57:38.896696');
INSERT INTO public.producto_vendidos VALUES (1496, 1, 2.00, 109, 435, '', 2.00, '2019-10-25 00:57:38.896696');
INSERT INTO public.producto_vendidos VALUES (1497, 1, 42.00, 106, 436, 'pechuga', 42.00, '2019-10-25 01:03:11.362576');
INSERT INTO public.producto_vendidos VALUES (1498, 1, 2.00, 110, 436, '', 2.00, '2019-10-25 01:03:11.362576');
INSERT INTO public.producto_vendidos VALUES (1499, 1, 45.00, 107, 436, '', 45.00, '2019-10-25 01:03:11.362576');
INSERT INTO public.producto_vendidos VALUES (1500, 1, 2.00, 109, 436, 'light', 2.00, '2019-10-25 01:03:11.362576');
INSERT INTO public.producto_vendidos VALUES (1501, 2, 100.00, 108, 437, '', 50.00, '2019-10-25 01:04:04.505124');
INSERT INTO public.producto_vendidos VALUES (1502, 2, 4.00, 109, 437, '1 ligtht, 1 normal', 2.00, '2019-10-25 01:04:04.505124');
INSERT INTO public.producto_vendidos VALUES (1503, 1, 2.50, 76, 438, '', 2.50, '2019-10-25 09:19:42.269039');
INSERT INTO public.producto_vendidos VALUES (1504, 1, 55.00, 77, 438, '', 55.00, '2019-10-25 09:19:42.269039');
INSERT INTO public.producto_vendidos VALUES (1505, 1, 1.50, 71, 438, '', 1.50, '2019-10-25 09:19:42.269039');
INSERT INTO public.producto_vendidos VALUES (1506, 1, 11.00, 97, 438, '', 11.00, '2019-10-25 09:19:42.269039');
INSERT INTO public.producto_vendidos VALUES (1507, 1, 55.00, 77, 439, '', 55.00, '2019-10-25 09:30:09.143296');
INSERT INTO public.producto_vendidos VALUES (1508, 1, 2.50, 76, 439, '', 2.50, '2019-10-25 09:30:09.143296');
INSERT INTO public.producto_vendidos VALUES (1509, 1, 1.50, 71, 439, '', 1.50, '2019-10-25 09:30:09.143296');
INSERT INTO public.producto_vendidos VALUES (1510, 1, 11.00, 97, 439, '', 11.00, '2019-10-25 09:30:09.143296');
INSERT INTO public.producto_vendidos VALUES (1511, 2, 5.00, 76, 440, '', 2.50, '2019-10-25 09:49:01.852456');
INSERT INTO public.producto_vendidos VALUES (1512, 2, 10.00, 95, 440, '', 5.00, '2019-10-25 09:49:01.852456');
INSERT INTO public.producto_vendidos VALUES (1513, 1, 2.50, 76, 441, 'sin azucar', 2.50, '2019-10-25 10:06:37.300055');
INSERT INTO public.producto_vendidos VALUES (1514, 2, 110.00, 77, 441, '', 55.00, '2019-10-25 10:06:37.300055');
INSERT INTO public.producto_vendidos VALUES (1515, 1, 1.50, 71, 441, '', 1.50, '2019-10-25 10:06:37.300055');
INSERT INTO public.producto_vendidos VALUES (1516, 1, 11.00, 97, 441, '', 11.00, '2019-10-25 10:06:37.300055');
INSERT INTO public.producto_vendidos VALUES (1517, 1, 5.50, 74, 441, '', 5.50, '2019-10-25 10:06:37.300055');
INSERT INTO public.producto_vendidos VALUES (1518, 1, 5.00, 95, 441, '', 5.00, '2019-10-25 10:06:37.300055');
INSERT INTO public.producto_vendidos VALUES (1519, 1, 1.50, 72, 441, '', 1.50, '2019-10-25 10:06:37.300055');
INSERT INTO public.producto_vendidos VALUES (1520, 1, 52.00, 87, 441, '', 52.00, '2019-10-25 10:06:37.300055');
INSERT INTO public.producto_vendidos VALUES (1521, 5, 27.50, 67, 441, '', 5.50, '2019-10-25 10:06:37.300055');
INSERT INTO public.producto_vendidos VALUES (1522, 5, 10.00, 73, 441, '', 2.00, '2019-10-25 10:06:37.300055');
INSERT INTO public.producto_vendidos VALUES (1523, 1, 16.50, 88, 441, '', 16.50, '2019-10-25 10:06:37.300055');
INSERT INTO public.producto_vendidos VALUES (1524, 1, 15.00, 94, 441, '', 15.00, '2019-10-25 10:06:37.300055');
INSERT INTO public.producto_vendidos VALUES (1525, 1, 56.30, 92, 441, '', 56.30, '2019-10-25 10:06:37.300055');
INSERT INTO public.producto_vendidos VALUES (1526, 1, 6.50, 91, 441, '', 6.50, '2019-10-25 10:06:37.300055');
INSERT INTO public.producto_vendidos VALUES (1527, 1, 3.50, 78, 441, '', 3.50, '2019-10-25 10:06:37.300055');
INSERT INTO public.producto_vendidos VALUES (1528, 1, 1.50, 79, 441, '', 1.50, '2019-10-25 10:06:37.300055');
INSERT INTO public.producto_vendidos VALUES (1529, 1, 22.50, 83, 441, '', 22.50, '2019-10-25 10:06:37.300055');
INSERT INTO public.producto_vendidos VALUES (1530, 1, 12.50, 93, 441, '', 12.50, '2019-10-25 10:06:37.300055');
INSERT INTO public.producto_vendidos VALUES (1531, 3, 105.00, 84, 441, '3/4 de coccion', 35.00, '2019-10-25 10:06:37.300055');
INSERT INTO public.producto_vendidos VALUES (1532, 1, 5.00, 90, 441, '', 5.00, '2019-10-25 10:06:37.300055');
INSERT INTO public.producto_vendidos VALUES (1533, 3, 67.50, 81, 441, '', 22.50, '2019-10-25 10:06:37.300055');
INSERT INTO public.producto_vendidos VALUES (1534, 1, 16.00, 82, 441, '', 16.00, '2019-10-25 10:06:37.300055');
INSERT INTO public.producto_vendidos VALUES (1535, 1, 80.00, 86, 441, '', 80.00, '2019-10-25 10:06:37.300055');
INSERT INTO public.producto_vendidos VALUES (1536, 2, 50.00, 96, 441, '', 25.00, '2019-10-25 10:06:37.300055');
INSERT INTO public.producto_vendidos VALUES (1537, 1, 16.50, 68, 441, '', 16.50, '2019-10-25 10:06:37.300055');
INSERT INTO public.producto_vendidos VALUES (1538, 1, 5.50, 85, 441, '', 5.50, '2019-10-25 10:06:37.300055');
INSERT INTO public.producto_vendidos VALUES (1539, 1, 15.00, 75, 441, '', 15.00, '2019-10-25 10:06:37.300055');
INSERT INTO public.producto_vendidos VALUES (1540, 3, 186.00, 89, 441, '', 62.00, '2019-10-25 10:06:37.300055');
INSERT INTO public.producto_vendidos VALUES (1541, 1, 10.50, 80, 441, '', 10.50, '2019-10-25 10:06:37.300055');
INSERT INTO public.producto_vendidos VALUES (1542, 1, 42.00, 106, 442, '', 42.00, '2019-10-25 10:20:08.461392');
INSERT INTO public.producto_vendidos VALUES (1543, 1, 45.00, 107, 442, '', 45.00, '2019-10-25 10:20:08.461392');
INSERT INTO public.producto_vendidos VALUES (1544, 1, 50.00, 108, 442, '', 50.00, '2019-10-25 10:20:08.461392');
INSERT INTO public.producto_vendidos VALUES (1545, 3, 6.00, 109, 442, '', 2.00, '2019-10-25 10:20:08.461392');
INSERT INTO public.producto_vendidos VALUES (1546, 1, 2.00, 109, 443, '', 2.00, '2019-10-25 10:22:30.485744');
INSERT INTO public.producto_vendidos VALUES (1547, 1, 2.00, 110, 443, '', 2.00, '2019-10-25 10:22:30.485744');
INSERT INTO public.producto_vendidos VALUES (1548, 1, 42.00, 106, 444, '', 42.00, '2019-10-25 13:01:22.897794');
INSERT INTO public.producto_vendidos VALUES (1549, 1, 45.00, 107, 444, '', 45.00, '2019-10-25 13:01:22.897794');
INSERT INTO public.producto_vendidos VALUES (1550, 1, 2.00, 109, 444, '', 2.00, '2019-10-25 13:01:22.897794');
INSERT INTO public.producto_vendidos VALUES (1551, 1, 2.00, 110, 444, '', 2.00, '2019-10-25 13:01:22.897794');
INSERT INTO public.producto_vendidos VALUES (1552, 1, 2.50, 76, 445, '', 2.50, '2019-11-05 09:56:25.345996');
INSERT INTO public.producto_vendidos VALUES (1553, 1, 11.00, 97, 445, '', 11.00, '2019-11-05 09:56:25.345996');
INSERT INTO public.producto_vendidos VALUES (1554, 1, 5.50, 74, 445, '', 5.50, '2019-11-05 09:56:25.345996');
INSERT INTO public.producto_vendidos VALUES (1555, 1, 5.00, 95, 445, '', 5.00, '2019-11-05 09:56:25.345996');
INSERT INTO public.producto_vendidos VALUES (1556, 1, 16.50, 68, 446, '', 16.50, '2019-11-05 10:13:20.656567');
INSERT INTO public.producto_vendidos VALUES (1557, 1, 5.50, 85, 446, '', 5.50, '2019-11-05 10:13:20.656567');
INSERT INTO public.producto_vendidos VALUES (1558, 1, 15.00, 75, 446, '', 15.00, '2019-11-05 10:13:20.656567');
INSERT INTO public.producto_vendidos VALUES (1559, 1, 2.50, 76, 447, '', 2.50, '2019-11-05 14:43:22.09395');
INSERT INTO public.producto_vendidos VALUES (1560, 1, 55.00, 77, 447, '', 55.00, '2019-11-05 14:43:22.09395');
INSERT INTO public.producto_vendidos VALUES (1561, 1, 55.00, 77, 448, '', 55.00, '2019-11-05 14:43:51.758591');
INSERT INTO public.producto_vendidos VALUES (1562, 1, 1.50, 71, 448, '', 1.50, '2019-11-05 14:43:51.758591');
INSERT INTO public.producto_vendidos VALUES (1563, 1, 11.00, 97, 448, '', 11.00, '2019-11-05 14:43:51.758591');
INSERT INTO public.producto_vendidos VALUES (1564, 1, 55.00, 77, 449, '', 55.00, '2019-11-05 14:44:49.865814');
INSERT INTO public.producto_vendidos VALUES (1565, 1, 1.50, 71, 449, '', 1.50, '2019-11-05 14:44:49.865814');
INSERT INTO public.producto_vendidos VALUES (1566, 1, 11.00, 97, 449, '', 11.00, '2019-11-05 14:44:49.865814');
INSERT INTO public.producto_vendidos VALUES (1567, 1, 1.50, 71, 450, '', 1.50, '2019-11-05 14:45:28.210395');
INSERT INTO public.producto_vendidos VALUES (1568, 2, 22.00, 97, 450, '', 11.00, '2019-11-05 14:45:28.210395');
INSERT INTO public.producto_vendidos VALUES (1569, 1, 55.00, 77, 450, '', 55.00, '2019-11-05 14:45:28.210395');
INSERT INTO public.producto_vendidos VALUES (1570, 1, 2.50, 76, 451, '', 2.50, '2019-11-05 14:45:58.427889');
INSERT INTO public.producto_vendidos VALUES (1571, 1, 11.00, 97, 451, '', 11.00, '2019-11-05 14:45:58.427889');
INSERT INTO public.producto_vendidos VALUES (1572, 1, 5.50, 74, 451, '', 5.50, '2019-11-05 14:45:58.427889');
INSERT INTO public.producto_vendidos VALUES (1573, 1, 5.00, 95, 451, '', 5.00, '2019-11-05 14:45:58.427889');
INSERT INTO public.producto_vendidos VALUES (1574, 1, 52.00, 87, 451, '', 52.00, '2019-11-05 14:45:58.427889');
INSERT INTO public.producto_vendidos VALUES (1575, 1, 11.00, 97, 452, '', 11.00, '2019-11-05 14:47:07.973753');
INSERT INTO public.producto_vendidos VALUES (1576, 1, 5.50, 74, 452, '', 5.50, '2019-11-05 14:47:07.973753');
INSERT INTO public.producto_vendidos VALUES (1577, 1, 5.00, 95, 452, '', 5.00, '2019-11-05 14:47:07.973753');
INSERT INTO public.producto_vendidos VALUES (1578, 1, 42.00, 106, 453, '', 42.00, '2019-11-05 17:20:53.669653');
INSERT INTO public.producto_vendidos VALUES (1579, 1, 45.00, 107, 453, '', 45.00, '2019-11-05 17:20:53.669653');
INSERT INTO public.producto_vendidos VALUES (1580, 1, 2.00, 109, 453, '', 2.00, '2019-11-05 17:20:53.669653');
INSERT INTO public.producto_vendidos VALUES (1581, 1, 42.00, 106, 454, '', 42.00, '2019-11-05 17:22:06.223666');
INSERT INTO public.producto_vendidos VALUES (1582, 1, 45.00, 107, 454, '', 45.00, '2019-11-05 17:22:06.223666');
INSERT INTO public.producto_vendidos VALUES (1583, 1, 50.00, 108, 455, '', 50.00, '2019-11-05 18:18:02.855856');
INSERT INTO public.producto_vendidos VALUES (1584, 1, 2.00, 110, 455, '', 2.00, '2019-11-05 18:18:02.855856');
INSERT INTO public.producto_vendidos VALUES (1585, 1, 2.00, 109, 455, '', 2.00, '2019-11-05 18:18:02.855856');
INSERT INTO public.producto_vendidos VALUES (1586, 1, 42.00, 106, 456, '', 42.00, '2019-11-06 10:30:35.437777');
INSERT INTO public.producto_vendidos VALUES (1587, 1, 2.00, 109, 456, '', 2.00, '2019-11-06 10:30:35.437777');
INSERT INTO public.producto_vendidos VALUES (1588, 1, 42.00, 106, 457, '', 42.00, '2019-11-06 11:02:38.513201');
INSERT INTO public.producto_vendidos VALUES (1589, 1, 2.00, 110, 457, '', 2.00, '2019-11-06 11:02:38.513201');
INSERT INTO public.producto_vendidos VALUES (1590, 1, 45.00, 107, 457, '', 45.00, '2019-11-06 11:02:38.513201');
INSERT INTO public.producto_vendidos VALUES (1591, 1, 2.00, 109, 457, '', 2.00, '2019-11-06 11:02:38.513201');
INSERT INTO public.producto_vendidos VALUES (1592, 1, 42.00, 106, 458, '', 42.00, '2019-11-06 15:53:19.631228');
INSERT INTO public.producto_vendidos VALUES (1593, 1, 45.00, 107, 458, '', 45.00, '2019-11-06 15:53:19.631228');
INSERT INTO public.producto_vendidos VALUES (1594, 1, 50.00, 108, 458, '', 50.00, '2019-11-06 15:53:19.631228');
INSERT INTO public.producto_vendidos VALUES (1595, 1, 42.00, 106, 459, '', 42.00, '2019-11-06 16:01:13.664454');
INSERT INTO public.producto_vendidos VALUES (1596, 1, 45.00, 107, 459, '', 45.00, '2019-11-06 16:01:13.664454');
INSERT INTO public.producto_vendidos VALUES (1597, 1, 2.00, 109, 459, '', 2.00, '2019-11-06 16:01:13.664454');
INSERT INTO public.producto_vendidos VALUES (1598, 2, 4.00, 109, 460, '', 2.00, '2019-11-06 16:02:04.934784');
INSERT INTO public.producto_vendidos VALUES (1599, 2, 100.00, 108, 460, '', 50.00, '2019-11-06 16:02:04.934784');
INSERT INTO public.producto_vendidos VALUES (1600, 2, 84.00, 106, 461, '', 42.00, '2019-11-06 16:05:56.951094');
INSERT INTO public.producto_vendidos VALUES (1601, 1, 2.00, 109, 461, '', 2.00, '2019-11-06 16:05:56.951094');
INSERT INTO public.producto_vendidos VALUES (1602, 1, 2.00, 110, 461, '', 2.00, '2019-11-06 16:05:56.951094');
INSERT INTO public.producto_vendidos VALUES (1603, 1, 50.00, 108, 461, '', 50.00, '2019-11-06 16:05:56.951094');
INSERT INTO public.producto_vendidos VALUES (1604, 1, 42.00, 106, 462, '', 42.00, '2019-11-06 17:42:18.270025');
INSERT INTO public.producto_vendidos VALUES (1605, 1, 45.00, 107, 462, '', 45.00, '2019-11-06 17:42:18.270025');
INSERT INTO public.producto_vendidos VALUES (1606, 2, 4.00, 109, 462, '', 2.00, '2019-11-06 17:42:18.270025');
INSERT INTO public.producto_vendidos VALUES (1607, 2, 84.00, 106, 463, '', 42.00, '2019-11-08 17:21:12.833929');
INSERT INTO public.producto_vendidos VALUES (1608, 2, 90.00, 107, 463, '', 45.00, '2019-11-08 17:21:12.833929');
INSERT INTO public.producto_vendidos VALUES (1609, 1, 2.00, 109, 463, '', 2.00, '2019-11-08 17:21:12.833929');
INSERT INTO public.producto_vendidos VALUES (1610, 1, 2.00, 110, 463, '', 2.00, '2019-11-08 17:21:12.833929');
INSERT INTO public.producto_vendidos VALUES (1611, 1, 6.00, 112, 464, '', 6.00, '2019-11-17 23:50:53.097572');
INSERT INTO public.producto_vendidos VALUES (1612, 1, 6.00, 111, 464, '', 6.00, '2019-11-17 23:50:53.097572');
INSERT INTO public.producto_vendidos VALUES (1613, 2, 4.00, 110, 464, '', 2.00, '2019-11-17 23:50:53.097572');
INSERT INTO public.producto_vendidos VALUES (1614, 2, 12.00, 111, 465, '1 Con sipancho, 1 con huevo', 6.00, '2019-11-22 09:26:23.606431');
INSERT INTO public.producto_vendidos VALUES (1615, 1, 6.00, 112, 465, '', 6.00, '2019-11-22 09:26:23.606431');
INSERT INTO public.producto_vendidos VALUES (1616, 2, 4.00, 110, 465, '', 2.00, '2019-11-22 09:26:23.606431');
INSERT INTO public.producto_vendidos VALUES (1617, 1, 50.00, 108, 465, '', 50.00, '2019-11-22 09:26:23.606431');
INSERT INTO public.producto_vendidos VALUES (1618, 1, 22.00, 119, 466, '', 22.00, '2019-11-30 04:51:40.928841');
INSERT INTO public.producto_vendidos VALUES (1619, 1, 23.00, 120, 466, '', 23.00, '2019-11-30 04:51:40.928841');
INSERT INTO public.producto_vendidos VALUES (1620, 1, 16.00, 117, 466, '', 16.00, '2019-11-30 04:51:40.928841');
INSERT INTO public.producto_vendidos VALUES (1621, 1, 2.00, 110, 466, '', 2.00, '2019-11-30 04:51:40.928841');
INSERT INTO public.producto_vendidos VALUES (1622, 1, 2.00, 109, 466, '', 2.00, '2019-11-30 04:51:40.928841');
INSERT INTO public.producto_vendidos VALUES (1623, 1, 42.00, 106, 466, '', 42.00, '2019-11-30 04:51:40.928841');
INSERT INTO public.producto_vendidos VALUES (1624, 1, 6.00, 111, 467, '', 6.00, '2019-12-02 16:36:49.855771');
INSERT INTO public.producto_vendidos VALUES (1625, 1, 6.00, 112, 467, '', 6.00, '2019-12-02 16:36:49.855771');
INSERT INTO public.producto_vendidos VALUES (1626, 2, 12.00, 111, 468, '', 6.00, '2019-12-02 16:42:55.98974');
INSERT INTO public.producto_vendidos VALUES (1627, 2, 4.00, 109, 468, '', 2.00, '2019-12-02 16:42:55.98974');
INSERT INTO public.producto_vendidos VALUES (1628, 2, 12.00, 111, 469, '', 6.00, '2019-12-06 23:12:09.498863');
INSERT INTO public.producto_vendidos VALUES (1629, 2, 84.00, 106, 469, '', 42.00, '2019-12-06 23:12:09.498863');
INSERT INTO public.producto_vendidos VALUES (1630, 2, 84.00, 106, 470, '1 pollo, 1 de chancho', 42.00, '2019-12-09 02:42:21.41261');
INSERT INTO public.producto_vendidos VALUES (1631, 2, 50.00, 121, 470, '', 25.00, '2019-12-09 02:42:21.41261');
INSERT INTO public.producto_vendidos VALUES (1632, 1, 6.00, 111, 471, '', 6.00, '2019-12-09 02:45:08.929449');
INSERT INTO public.producto_vendidos VALUES (1633, 1, 2.00, 109, 471, '', 2.00, '2019-12-09 02:45:08.929449');
INSERT INTO public.producto_vendidos VALUES (1634, 1, 45.00, 107, 472, 'pechuga', 45.00, '2019-12-09 02:51:02.188298');
INSERT INTO public.producto_vendidos VALUES (1635, 1, 25.00, 121, 472, '', 25.00, '2019-12-09 02:51:02.188298');
INSERT INTO public.producto_vendidos VALUES (1636, 1, 50.00, 108, 473, '', 50.00, '2019-12-09 02:53:33.850982');
INSERT INTO public.producto_vendidos VALUES (1637, 1, 90.00, 122, 473, '', 90.00, '2019-12-09 02:53:33.850982');
INSERT INTO public.producto_vendidos VALUES (1638, 1, 6.00, 111, 474, '', 6.00, '2019-12-09 19:16:37.882353');
INSERT INTO public.producto_vendidos VALUES (1639, 1, 6.00, 112, 474, '', 6.00, '2019-12-09 19:16:37.882353');
INSERT INTO public.producto_vendidos VALUES (1640, 1, 8.00, 115, 474, '', 8.00, '2019-12-09 19:16:37.882353');
INSERT INTO public.producto_vendidos VALUES (1641, 1, 23.00, 120, 474, '', 23.00, '2019-12-09 19:16:37.882353');
INSERT INTO public.producto_vendidos VALUES (1642, 1, 6.00, 111, 475, '', 6.00, '2019-12-09 23:38:25.341755');
INSERT INTO public.producto_vendidos VALUES (1643, 1, 6.00, 112, 475, '', 6.00, '2019-12-09 23:38:25.341755');
INSERT INTO public.producto_vendidos VALUES (1644, 2, 12.00, 111, 476, '', 6.00, '2019-12-10 15:13:28.558007');
INSERT INTO public.producto_vendidos VALUES (1645, 2, 4.00, 109, 476, '', 2.00, '2019-12-10 15:13:28.558007');
INSERT INTO public.producto_vendidos VALUES (1646, 1, 6.00, 111, 477, '', 6.00, '2019-12-10 23:35:13.640035');
INSERT INTO public.producto_vendidos VALUES (1647, 1, 6.00, 112, 477, '', 6.00, '2019-12-10 23:35:13.640035');
INSERT INTO public.producto_vendidos VALUES (1648, 1, 8.00, 115, 477, '', 8.00, '2019-12-10 23:35:13.640035');
INSERT INTO public.producto_vendidos VALUES (1649, 1, 16.00, 117, 477, '', 16.00, '2019-12-10 23:35:13.640035');
INSERT INTO public.producto_vendidos VALUES (1650, 1, 23.00, 120, 477, '', 23.00, '2019-12-10 23:35:13.640035');
INSERT INTO public.producto_vendidos VALUES (1651, 1, 45.00, 107, 477, '', 45.00, '2019-12-10 23:35:13.640035');
INSERT INTO public.producto_vendidos VALUES (1652, 2, 12.00, 111, 478, '', 6.00, '2019-12-11 17:30:01.973269');
INSERT INTO public.producto_vendidos VALUES (1653, 2, 46.00, 120, 478, '', 23.00, '2019-12-11 17:30:01.973269');
INSERT INTO public.producto_vendidos VALUES (1654, 2, 12.00, 111, 479, '', 6.00, '2019-12-11 21:42:25.450046');
INSERT INTO public.producto_vendidos VALUES (1655, 2, 46.00, 120, 479, '', 23.00, '2019-12-11 21:42:25.450046');
INSERT INTO public.producto_vendidos VALUES (1656, 1, 6.00, 111, 480, '', 6.00, '2019-12-11 21:47:28.364139');
INSERT INTO public.producto_vendidos VALUES (1657, 1, 6.00, 112, 480, '', 6.00, '2019-12-11 21:47:28.364139');
INSERT INTO public.producto_vendidos VALUES (1658, 2, 4.00, 109, 481, '', 2.00, '2019-12-11 21:49:55.18188');
INSERT INTO public.producto_vendidos VALUES (1659, 2, 12.00, 111, 482, '', 6.00, '2019-12-11 21:55:58.461618');
INSERT INTO public.producto_vendidos VALUES (1660, 2, 12.00, 112, 482, '', 6.00, '2019-12-11 21:55:58.461618');
INSERT INTO public.producto_vendidos VALUES (1661, 1, 23.00, 120, 483, '', 23.00, '2019-12-11 21:57:23.369443');
INSERT INTO public.producto_vendidos VALUES (1662, 1, 6.00, 111, 483, '', 6.00, '2019-12-11 21:57:23.369443');
INSERT INTO public.producto_vendidos VALUES (1663, 2, 12.00, 111, 484, '', 6.00, '2019-12-11 21:58:15.465574');
INSERT INTO public.producto_vendidos VALUES (1664, 2, 12.00, 111, 485, '', 6.00, '2019-12-11 22:43:18.027753');
INSERT INTO public.producto_vendidos VALUES (1665, 1, 6.00, 111, 486, '', 6.00, '2019-12-11 22:44:42.134571');
INSERT INTO public.producto_vendidos VALUES (1666, 1, 6.00, 112, 486, '', 6.00, '2019-12-11 22:44:42.134571');
INSERT INTO public.producto_vendidos VALUES (1667, 2, 12.00, 112, 487, '', 6.00, '2019-12-11 22:47:51.506374');
INSERT INTO public.producto_vendidos VALUES (1668, 1, 6.00, 111, 488, '', 6.00, '2019-12-11 22:51:47.889059');
INSERT INTO public.producto_vendidos VALUES (1669, 1, 6.00, 112, 488, '', 6.00, '2019-12-11 22:51:47.889059');
INSERT INTO public.producto_vendidos VALUES (1670, 2, 12.00, 111, 489, '', 6.00, '2019-12-11 22:55:14.335066');
INSERT INTO public.producto_vendidos VALUES (1671, 2, 50.00, 121, 489, '', 25.00, '2019-12-11 22:55:14.335066');
INSERT INTO public.producto_vendidos VALUES (1672, 1, 6.00, 111, 490, '', 6.00, '2019-12-17 18:37:54.49631');
INSERT INTO public.producto_vendidos VALUES (1673, 1, 23.00, 120, 490, '', 23.00, '2019-12-17 18:37:54.49631');
INSERT INTO public.producto_vendidos VALUES (1674, 1, 6.00, 112, 490, '', 6.00, '2019-12-17 18:37:54.49631');
INSERT INTO public.producto_vendidos VALUES (1675, 1, 6.00, 112, 491, '', 6.00, '2019-12-17 18:38:27.700059');
INSERT INTO public.producto_vendidos VALUES (1676, 1, 23.00, 120, 491, '', 23.00, '2019-12-17 18:38:27.700059');
INSERT INTO public.producto_vendidos VALUES (1677, 1, 8.00, 115, 491, '', 8.00, '2019-12-17 18:38:27.700059');
INSERT INTO public.producto_vendidos VALUES (1678, 1, 6.00, 111, 491, '', 6.00, '2019-12-17 18:38:27.700059');
INSERT INTO public.producto_vendidos VALUES (1679, 1, 6.00, 111, 492, '', 6.00, '2019-12-17 22:49:11.48297');
INSERT INTO public.producto_vendidos VALUES (1680, 1, 42.00, 106, 492, '', 42.00, '2019-12-17 22:49:11.48297');
INSERT INTO public.producto_vendidos VALUES (1681, 1, 2.00, 109, 492, '', 2.00, '2019-12-17 22:49:11.48297');
INSERT INTO public.producto_vendidos VALUES (1682, 1, 2.00, 110, 492, '', 2.00, '2019-12-17 22:49:11.48297');
INSERT INTO public.producto_vendidos VALUES (1683, 1, 6.00, 111, 493, '', 6.00, '2019-12-17 23:24:03.9931');
INSERT INTO public.producto_vendidos VALUES (1684, 1, 2.00, 109, 493, '', 2.00, '2019-12-17 23:24:03.9931');
INSERT INTO public.producto_vendidos VALUES (1685, 1, 42.00, 106, 494, '', 42.00, '2019-12-17 23:25:22.39211');
INSERT INTO public.producto_vendidos VALUES (1686, 1, 2.00, 109, 494, '', 2.00, '2019-12-17 23:25:22.39211');
INSERT INTO public.producto_vendidos VALUES (1687, 1, 42.00, 106, 495, '', 42.00, '2019-12-17 23:27:29.173147');
INSERT INTO public.producto_vendidos VALUES (1688, 1, 45.00, 107, 495, '', 45.00, '2019-12-17 23:27:29.173147');
INSERT INTO public.producto_vendidos VALUES (1689, 1, 1.50, 79, 496, '', 1.50, '2020-01-13 15:42:46.28742');
INSERT INTO public.producto_vendidos VALUES (1690, 1, 22.50, 83, 496, '', 22.50, '2020-01-13 15:42:46.28742');
INSERT INTO public.producto_vendidos VALUES (1691, 1, 5.00, 90, 496, '', 5.00, '2020-01-13 15:42:46.28742');
INSERT INTO public.producto_vendidos VALUES (1692, 1, 35.00, 84, 496, '', 35.00, '2020-01-13 15:42:46.28742');
INSERT INTO public.producto_vendidos VALUES (1693, 1, 22.50, 81, 496, '', 22.50, '2020-01-13 15:42:46.28742');
INSERT INTO public.producto_vendidos VALUES (1694, 1, 2.50, 76, 497, '', 2.50, '2020-01-14 21:43:25.857837');
INSERT INTO public.producto_vendidos VALUES (1695, 1, 55.00, 77, 497, '', 55.00, '2020-01-14 21:43:25.857837');
INSERT INTO public.producto_vendidos VALUES (1696, 1, 1.50, 71, 497, '', 1.50, '2020-01-14 21:43:25.857837');
INSERT INTO public.producto_vendidos VALUES (1697, 1, 5.00, 95, 497, '', 5.00, '2020-01-14 21:43:25.857837');
INSERT INTO public.producto_vendidos VALUES (1698, 1, 5.50, 74, 497, '', 5.50, '2020-01-14 21:43:25.857837');
INSERT INTO public.producto_vendidos VALUES (1699, 1, 11.00, 97, 497, '', 11.00, '2020-01-14 21:43:25.857837');
INSERT INTO public.producto_vendidos VALUES (1700, 1, 2.50, 76, 498, '', 2.50, '2020-01-14 21:46:00.435148');
INSERT INTO public.producto_vendidos VALUES (1701, 1, 5.50, 74, 498, '', 5.50, '2020-01-14 21:46:00.435148');
INSERT INTO public.producto_vendidos VALUES (1702, 1, 11.00, 97, 498, '', 11.00, '2020-01-14 21:46:00.435148');
INSERT INTO public.producto_vendidos VALUES (1703, 1, 5.00, 95, 498, '', 5.00, '2020-01-14 21:46:00.435148');
INSERT INTO public.producto_vendidos VALUES (1704, 1, 5.50, 67, 498, '', 5.50, '2020-01-14 21:46:00.435148');
INSERT INTO public.producto_vendidos VALUES (1705, 1, 1.50, 72, 499, '', 1.50, '2020-01-14 21:56:24.653393');
INSERT INTO public.producto_vendidos VALUES (1706, 1, 52.00, 87, 499, '', 52.00, '2020-01-14 21:56:24.653393');
INSERT INTO public.producto_vendidos VALUES (1707, 1, 6.50, 91, 499, '', 6.50, '2020-01-14 21:56:24.653393');
INSERT INTO public.producto_vendidos VALUES (1708, 1, 56.30, 92, 499, '', 56.30, '2020-01-14 21:56:24.653393');
INSERT INTO public.producto_vendidos VALUES (1709, 2, 90.00, 107, 500, '', 45.00, '2020-01-24 16:04:08.293054');
INSERT INTO public.producto_vendidos VALUES (1710, 2, 4.00, 109, 500, 'coca cola light', 2.00, '2020-01-24 16:04:08.293054');
INSERT INTO public.producto_vendidos VALUES (1711, 2, 20.00, 123, 501, '', 10.00, '2020-01-24 16:05:30.789216');
INSERT INTO public.producto_vendidos VALUES (1712, 2, 20.00, 124, 501, '', 10.00, '2020-01-24 16:05:30.789216');
INSERT INTO public.producto_vendidos VALUES (1713, 1, 42.00, 106, 502, '', 42.00, '2020-01-24 16:08:30.746765');
INSERT INTO public.producto_vendidos VALUES (1714, 1, 50.00, 108, 502, '', 50.00, '2020-01-24 16:08:30.746765');
INSERT INTO public.producto_vendidos VALUES (1715, 2, 90.00, 107, 503, '', 45.00, '2020-01-24 20:16:09.822746');
INSERT INTO public.producto_vendidos VALUES (1716, 2, 4.00, 109, 503, '', 2.00, '2020-01-24 20:16:09.822746');
INSERT INTO public.producto_vendidos VALUES (1717, 2, 90.00, 107, 504, '', 45.00, '2020-01-24 20:35:27.513156');
INSERT INTO public.producto_vendidos VALUES (1718, 2, 4.00, 109, 504, '1 coca cola light', 2.00, '2020-01-24 20:35:27.513156');
INSERT INTO public.producto_vendidos VALUES (1719, 1, 50.00, 108, 505, '', 50.00, '2020-01-24 20:36:40.361377');
INSERT INTO public.producto_vendidos VALUES (1720, 1, 10.00, 123, 505, '', 10.00, '2020-01-24 20:36:40.361377');
INSERT INTO public.producto_vendidos VALUES (1721, 1, 45.00, 107, 506, '', 45.00, '2020-01-24 20:49:33.525227');
INSERT INTO public.producto_vendidos VALUES (1722, 1, 50.00, 108, 506, '', 50.00, '2020-01-24 20:49:33.525227');
INSERT INTO public.producto_vendidos VALUES (1723, 1, 2.00, 109, 506, 'coca cola light', 2.00, '2020-01-24 20:49:33.525227');
INSERT INTO public.producto_vendidos VALUES (1724, 2, 4.00, 110, 506, '', 2.00, '2020-01-24 20:49:33.525227');
INSERT INTO public.producto_vendidos VALUES (1725, 1, 45.00, 107, 507, '', 45.00, '2020-01-24 20:50:42.549083');
INSERT INTO public.producto_vendidos VALUES (1726, 1, 2.00, 109, 507, '', 2.00, '2020-01-24 20:50:42.549083');
INSERT INTO public.producto_vendidos VALUES (1727, 2, 84.00, 106, 508, '', 42.00, '2020-01-24 23:32:20.651063');
INSERT INTO public.producto_vendidos VALUES (1728, 2, 4.00, 109, 508, '1 coca cola light', 2.00, '2020-01-24 23:32:20.651063');
INSERT INTO public.producto_vendidos VALUES (1729, 1, 10.00, 123, 508, '', 10.00, '2020-01-24 23:32:20.651063');
INSERT INTO public.producto_vendidos VALUES (1730, 1, 42.00, 106, 509, '', 42.00, '2020-01-24 23:38:48.219348');
INSERT INTO public.producto_vendidos VALUES (1731, 1, 50.00, 108, 509, '', 50.00, '2020-01-24 23:38:48.219348');
INSERT INTO public.producto_vendidos VALUES (1732, 2, 84.00, 106, 510, '', 42.00, '2020-01-29 03:17:30.145442');
INSERT INTO public.producto_vendidos VALUES (1733, 2, 90.00, 107, 510, '', 45.00, '2020-01-29 03:17:30.145442');
INSERT INTO public.producto_vendidos VALUES (1734, 2, 4.00, 109, 510, '1 coca cola light', 2.00, '2020-01-29 03:17:30.145442');
INSERT INTO public.producto_vendidos VALUES (1735, 2, 4.00, 110, 510, '', 2.00, '2020-01-29 03:17:30.145442');
INSERT INTO public.producto_vendidos VALUES (1736, 2, 90.00, 107, 511, '', 45.00, '2020-01-29 03:19:10.370197');
INSERT INTO public.producto_vendidos VALUES (1737, 2, 4.00, 109, 511, '', 2.00, '2020-01-29 03:19:10.370197');
INSERT INTO public.producto_vendidos VALUES (1738, 2, 90.00, 107, 512, '', 45.00, '2020-01-29 03:50:14.414742');
INSERT INTO public.producto_vendidos VALUES (1739, 2, 4.00, 109, 512, '', 2.00, '2020-01-29 03:50:14.414742');
INSERT INTO public.producto_vendidos VALUES (1740, 1, 45.00, 107, 513, '', 45.00, '2020-01-29 17:21:44.990752');
INSERT INTO public.producto_vendidos VALUES (1741, 1, 50.00, 108, 513, '', 50.00, '2020-01-29 17:21:44.990752');
INSERT INTO public.producto_vendidos VALUES (1742, 1, 3.50, 127, 513, '', 3.50, '2020-01-29 17:21:44.990752');
INSERT INTO public.producto_vendidos VALUES (1743, 2, 60.00, 126, 513, '', 30.00, '2020-01-29 17:21:44.990752');
INSERT INTO public.producto_vendidos VALUES (1744, 1, 90.00, 122, 513, '', 90.00, '2020-01-29 17:21:44.990752');
INSERT INTO public.producto_vendidos VALUES (1745, 1, 45.00, 107, 514, '', 45.00, '2020-01-29 17:24:47.917036');
INSERT INTO public.producto_vendidos VALUES (1746, 1, 50.00, 108, 514, '', 50.00, '2020-01-29 17:24:47.917036');
INSERT INTO public.producto_vendidos VALUES (1747, 1, 3.50, 127, 514, '', 3.50, '2020-01-29 17:24:47.917036');
INSERT INTO public.producto_vendidos VALUES (1748, 1, 25.00, 121, 514, '', 25.00, '2020-01-29 17:24:47.917036');


--
-- TOC entry 5014 (class 0 OID 33118)
-- Dependencies: 240
-- Data for Name: productos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.productos VALUES (41, 'asdfasdf', 'asdfasdf', 9, 58, '2019-09-11 09:04:58', '2019-09-11 16:11:59', 22.30, '2019-09-11 16:11:59', NULL);
INSERT INTO public.productos VALUES (40, 'adssdfasdf', NULL, 9, 58, '2019-09-11 09:03:10', '2019-09-11 16:12:03', 2.50, '2019-09-11 16:12:03', NULL);
INSERT INTO public.productos VALUES (39, 'asdfasf', 'asdfasdf', 8, 58, '2019-09-11 08:59:27', '2019-09-11 16:12:07', 22.50, '2019-09-11 16:12:07', NULL);
INSERT INTO public.productos VALUES (38, 'asdfasdf', 'asdfasdf', 9, 58, '2019-09-11 08:58:39', '2019-09-11 16:12:10', 23.00, '2019-09-11 16:12:10', NULL);
INSERT INTO public.productos VALUES (37, 'asdfadsf', 'asdfasf', 9, 58, '2019-09-11 08:57:17', '2019-09-11 16:12:14', 33.00, '2019-09-11 16:12:14', NULL);
INSERT INTO public.productos VALUES (36, 'fasdfasd', 'asdfsd', 7, 58, '2019-09-11 08:53:52', '2019-09-11 16:12:17', 99.00, '2019-09-11 16:12:17', NULL);
INSERT INTO public.productos VALUES (35, 'asdfasdf', 'asfasdf', 10, 58, '2019-09-11 08:51:41', '2019-09-11 16:12:21', 22.00, '2019-09-11 16:12:21', NULL);
INSERT INTO public.productos VALUES (34, 'ASDFASDF', 'ASDFASDF', 7, 58, '2019-09-11 08:46:38', '2019-09-11 16:12:24', 22.00, '2019-09-11 16:12:24', NULL);
INSERT INTO public.productos VALUES (33, 'asdfasdf', 'adadsfadsf', 8, 58, '2019-09-11 08:42:53', '2019-09-11 16:12:28', 22.50, '2019-09-11 16:12:28', NULL);
INSERT INTO public.productos VALUES (32, 'Jamon', 'no tiene', 9, 58, '2019-09-09 18:30:14', '2019-09-11 16:12:30', 23.00, '2019-09-11 16:12:30', NULL);
INSERT INTO public.productos VALUES (28, 'Salteña', 'no tiene', 10, 58, '2019-09-09 17:14:50', '2019-09-11 16:12:42', 5.50, '2019-09-11 16:12:42', NULL);
INSERT INTO public.productos VALUES (54, 'salteñas', 'saasdfasdfsdf', 8, 58, '2019-09-11 23:46:51', '2019-09-13 12:55:07', 22.30, '2019-09-13 12:55:07', NULL);
INSERT INTO public.productos VALUES (52, 'sadfasfas', 'asdfasdf', 8, 58, '2019-09-11 23:44:41', '2019-09-13 12:55:25', 22.30, '2019-09-13 12:55:25', 'ZuL0ZhSNWr3KDl8nOkfZiuspTk1NywJZ5IlDKsvZ.jpeg');
INSERT INTO public.productos VALUES (31, 'Helado de vainilla', 'No tiene', 9, 58, '2019-09-09 17:31:10', '2019-09-11 16:18:16', 22.50, '2019-09-11 16:18:16', NULL);
INSERT INTO public.productos VALUES (30, 'Arroz a la valenciana', 'No tiene', 7, 58, '2019-09-09 17:28:54', '2019-09-11 16:18:19', 22.50, '2019-09-11 16:18:19', NULL);
INSERT INTO public.productos VALUES (29, 'Sacta de Pollo', 'No tiene', 10, 58, '2019-09-09 17:27:32', '2019-09-11 16:18:22', 5.50, '2019-09-11 16:18:22', NULL);
INSERT INTO public.productos VALUES (43, 'sacta de pollo', 'no tiene', 10, 58, '2019-09-11 16:21:16', '2019-09-13 12:57:28', 22.56, '2019-09-13 12:57:28', NULL);
INSERT INTO public.productos VALUES (53, 'asdfasdfasd', 'asdfasfasdfasd', 7, 58, '2019-09-11 23:45:37', '2019-09-13 12:57:53', 22.30, '2019-09-13 12:57:53', 'ioyKzeBBYCeRiFGL9eTbHgMBkm7CEg0dSAv9FCFp.jpeg');
INSERT INTO public.productos VALUES (51, 'Jugo de durazno', 'se sirve todos los dias', 11, 58, '2019-09-11 23:01:37', '2019-09-13 12:57:59', 5.00, '2019-09-13 12:57:59', 'BvT3KCcwCILNEe85qz9mLrAEHw7Z1kaLzxSRrAZM.jpeg');
INSERT INTO public.productos VALUES (71, 'Coca cola', '150 ml', 17, 58, '2019-10-02 11:56:06', '2019-10-02 11:56:06', 1.50, NULL, 'GKxexRzPqdlhgBj63gL5EWhAo22MD9T3cM2mIoB4.jpeg');
INSERT INTO public.productos VALUES (60, 'Sacta de Pollo', NULL, 10, 58, '2019-09-20 12:24:06', '2019-10-02 10:30:20', 22.30, '2019-10-02 10:30:20', 'OgGqYMExc51ous4Iwowixdrto0zg2bu4CYrwa1Zy.jpeg');
INSERT INTO public.productos VALUES (61, 'Sacta de Pollo', NULL, 10, 58, '2019-09-20 12:24:06', '2019-10-02 10:30:33', 22.30, '2019-10-02 10:30:33', 'LugSKLCLmWTUw2xej95SCIDP9k4sQY9LWP4rFqw0.jpeg');
INSERT INTO public.productos VALUES (50, 'asdasdfasdf', 'asdfasdfasdf', 7, 58, '2019-09-11 22:59:30', '2019-09-13 12:58:03', 22.50, '2019-09-13 12:58:03', NULL);
INSERT INTO public.productos VALUES (49, 'asdfasd', 'asdfasdf', 7, 58, '2019-09-11 22:33:48', '2019-09-13 12:58:08', 22.00, '2019-09-13 12:58:08', NULL);
INSERT INTO public.productos VALUES (48, 'asdfasfas', 'asdfsdf', 8, 58, '2019-09-11 22:25:08', '2019-09-13 12:58:17', 5.50, '2019-09-13 12:58:17', NULL);
INSERT INTO public.productos VALUES (47, 'Licor', 'ADFASDF', 8, 58, '2019-09-11 17:16:53', '2019-09-13 12:58:23', 22.50, '2019-09-13 12:58:23', 'T97XnUwJKiyr2QeOAdFnWQwseqJ4mgmzXoTQ6sT2.jpeg');
INSERT INTO public.productos VALUES (46, 'Coca Cola', 'asdfaf', 7, 58, '2019-09-11 17:07:46', '2019-09-13 12:58:35', 22.00, '2019-09-13 12:58:35', 'LZBr4chaCdMlgdDCVxzAEOhHrbAE3vOlsjUssdlN.jpeg');
INSERT INTO public.productos VALUES (45, 'plato paceño', 'no tiene', 10, 58, '2019-09-11 16:25:43', '2019-09-13 12:58:40', 22.30, '2019-09-13 12:58:40', NULL);
INSERT INTO public.productos VALUES (59, 'Salteña', 'null', 8, 58, '2019-09-14 20:16:21', '2019-10-02 10:35:26', 5.50, '2019-10-02 10:35:26', '32Z8iCkL0FY6anY1J9CjUycYCwFrXAmGXv0mYkAv.jpeg');
INSERT INTO public.productos VALUES (63, 'Pollo a la broaster', NULL, 10, 58, '2019-09-20 12:26:40', '2019-10-02 10:57:24', 22.00, '2019-10-02 10:57:24', 'NiO2ojLhvfumxp1ftcb7yQS5gLLHwsXKhBQJjvYt.jpeg');
INSERT INTO public.productos VALUES (64, 'Pechuga de pollo', NULL, 9, 58, '2019-09-20 12:29:50', '2019-10-02 11:01:56', 32.00, '2019-10-02 11:01:56', 'eDHz9bp2QVQwGCZjoCRyIRkMpoIJtU5h3c0EsHLC.jpeg');
INSERT INTO public.productos VALUES (44, 'salteña', 'no tiene', 10, 58, '2019-09-11 16:24:19', '2019-09-13 12:58:45', 5.50, '2019-09-13 12:58:45', NULL);
INSERT INTO public.productos VALUES (42, 'Salteñas', 'Ricas salteñas promocio, solo viernes', 10, 58, '2019-09-11 16:18:52', '2019-09-13 12:58:49', 5.50, '2019-09-13 12:58:49', 'tRlGEiP9C7glCMbliStBjf7SOPEQ85NCbAZdezPe.jpeg');
INSERT INTO public.productos VALUES (72, 'Fanta', 'personal', 17, 58, '2019-10-02 12:00:00', '2019-10-02 12:00:00', 1.50, NULL, 'c8sHkarOQGUNq0BlswOngVhWjfD2BPjXBx73dKwH.jpeg');
INSERT INTO public.productos VALUES (65, 'Piernas la jugo', 'null', 16, 58, '2019-09-20 13:10:33', '2019-10-02 12:00:58', 55.60, '2019-10-02 12:00:58', 'D5ppaBoR30yMZN1ck5jPciUy5mUPAAGIF0X0Hfbp.jpeg');
INSERT INTO public.productos VALUES (58, 'Sactita de pollo', 'No tiene', 10, 58, '2019-09-13 10:24:07', '2019-09-13 12:54:22', 22.50, '2019-09-13 12:54:22', 'FCDKsoByDgLtFie51qBaxZaSrU4mSP2RnLVS9AWP.jpeg');
INSERT INTO public.productos VALUES (57, 'asdfadfaf', 'asdfadfasdfasd', 8, 58, '2019-09-12 00:32:22', '2019-09-13 12:54:40', 22.30, '2019-09-13 12:54:40', 'ypZDgL1e1CEBeYbHN77uMsJUJU56MIZLjorrVxIi.jpeg');
INSERT INTO public.productos VALUES (56, 'asdfasdfasd', 'asdfasdfasdf', 11, 58, '2019-09-12 00:30:31', '2019-09-13 12:54:48', 22.00, '2019-09-13 12:54:48', 'K7gwCDrMmNKYXQqfvYJodAlQ6QrNEDoTKgsd0DIJ.jpeg');
INSERT INTO public.productos VALUES (55, 'asdfasdfasdfasdfasdf', 'asdfasdfasdfasdf', 7, 58, '2019-09-12 00:28:39', '2019-09-13 12:55:00', 22.50, '2019-09-13 12:55:00', 'ffjpF2k6zSI73NRr2yFjkrk8cgtA56D0WpmYhiJE.jpeg');
INSERT INTO public.productos VALUES (66, 'Pierna a la brasa', NULL, 16, 58, '2019-09-20 13:12:31', '2019-10-02 12:01:02', 22.40, '2019-10-02 12:01:02', 'GzE00sJPJKMSkwjUv6RL1iVYwtoBx9KS1OajxQRb.jpeg');
INSERT INTO public.productos VALUES (73, 'Gelatina', NULL, 9, 58, '2019-10-02 12:02:51', '2019-10-02 12:02:51', 2.00, NULL, 'qLKlBOvPTCOIKzXqvphQ15dm5iDTY86m8WwztWdL.jpeg');
INSERT INTO public.productos VALUES (74, 'Dona', 'de chocolate', 9, 58, '2019-10-02 12:03:18', '2019-10-02 12:03:18', 5.50, NULL, 'k8AndINgG2pLDQ7k6DJ2lJBLHkd5p4kbwcUX7mJX.jpeg');
INSERT INTO public.productos VALUES (75, 'Torta helada', NULL, 9, 58, '2019-10-02 12:05:14', '2019-10-02 12:05:14', 15.00, NULL, 'oD2PZQbbvzk8fs6Q6gwKYDKRcMVvDpAAOXFYzcGY.jpeg');
INSERT INTO public.productos VALUES (77, 'Chicharron chancho', 'null', 18, 58, '2019-10-02 12:07:16', '2019-10-02 12:08:13', 55.00, NULL, 'FUtoZgqK51VkSLv5vCNlYsNLtPfpRwymEx6CRkij.jpeg');
INSERT INTO public.productos VALUES (76, 'Café', 'null', 19, 58, '2019-10-02 12:06:03', '2019-10-02 12:08:49', 2.50, NULL, 'weZNSLD3j0Sn9lcS9s3FBN7EEpMgSzSR05IdP3Dq.jpeg');
INSERT INTO public.productos VALUES (79, 'Mate de caja', NULL, 19, 58, '2019-10-02 12:11:39', '2019-10-02 12:11:39', 1.50, NULL, 'V0oGcUVYPgFRF3ZqVmKTZoTzZw8vD4QEooiurWIY.jpeg');
INSERT INTO public.productos VALUES (80, 'Yungueño', NULL, 13, 58, '2019-10-02 12:12:54', '2019-10-02 12:12:54', 10.50, NULL, 'm86CZFxLyvM8Qi39a6FABMZOsRT42LtftfrilRZ7.jpeg');
INSERT INTO public.productos VALUES (83, 'Mondongo', NULL, 14, 58, '2019-10-02 12:48:02', '2019-10-02 12:48:02', 22.50, NULL, '4VoALkRguOnCyycSPFIhuX2ivdtUYPCwHC22KLsJ.jpeg');
INSERT INTO public.productos VALUES (84, 'Pes parrilla', NULL, 14, 58, '2019-10-02 12:48:37', '2019-10-02 12:48:37', 35.00, NULL, 'JGOTdaPp6VaWtfux8IsWf7wFkM0EwEOrnSk7OB0F.jpeg');
INSERT INTO public.productos VALUES (70, 'Desayuno Yungueño', NULL, 13, 58, '2019-10-02 11:53:39', '2019-10-03 12:07:03', 8.50, '2019-10-03 12:07:03', NULL);
INSERT INTO public.productos VALUES (67, 'Frutilla', NULL, 11, 58, '2019-09-20 13:13:27', '2019-10-03 12:07:42', 5.50, NULL, 'HWc9TK5qWtD5OdgWMuk1MYzgiV96zcOVOrU2UpfK.jpeg');
INSERT INTO public.productos VALUES (68, 'Salchipapa', 'solo se sirve en las tardes', 21, 58, '2019-10-02 11:26:17', '2019-10-03 12:09:25', 16.50, NULL, '4v9hfd5g9OHKZcuDsYFFQzi1UO97D48TWM4l44Mc.jpeg');
INSERT INTO public.productos VALUES (78, 'Mate de anis', 'se sirve en las mañanas y en las tardes', 19, 58, '2019-10-02 12:10:59', '2019-10-04 14:56:35', 3.50, NULL, 'di8LZDQ1G5wwwuNqch8pQKdTCRLNfjTYi7S3URIk.jpeg');
INSERT INTO public.productos VALUES (69, 'pollo a la brasa', 'Solo sirve de miercoles y viernes', 10, 58, '2019-10-02 11:32:25', '2019-10-03 12:10:12', 52.50, '2019-10-03 12:10:12', NULL);
INSERT INTO public.productos VALUES (82, 'Pollo Broaster', 'null', 18, 58, '2019-10-02 12:45:41', '2019-10-03 12:17:14', 16.00, NULL, 'teJZiwo5bV7IPeXICtKb9waySDg7gioO3T5WvHpp.jpeg');
INSERT INTO public.productos VALUES (87, 'Fricase', NULL, 18, 58, '2019-10-02 18:57:36', '2019-10-02 18:57:36', 52.00, NULL, 'mwf8CsMIRz7iYNa52xR1OBr5T1Bt5ElOeN91Skj6.jpeg');
INSERT INTO public.productos VALUES (86, 'Ron Abuelo', 'null', 20, 58, '2019-10-02 18:41:27', '2019-10-03 10:50:54', 80.00, NULL, 'cx1b2DVf4OXs7zOzMalZyllzuqnVkwX3OgAAMuvl.jpeg');
INSERT INTO public.productos VALUES (85, 'Salteña', 'null', 9, 58, '2019-10-02 18:38:41', '2019-10-03 12:01:20', 5.50, NULL, '3KC0qCbSplimaojyuGIb5DtMcOzOXkyAWEW4yctd.jpeg');
INSERT INTO public.productos VALUES (81, 'Pollo Brasa', 'null', 18, 58, '2019-10-02 12:17:29', '2019-10-03 12:05:26', 22.50, NULL, 'DzsIEYwFVMCl519vDRfTZgUeX6Ph9G6ktOs7J44T.jpeg');
INSERT INTO public.productos VALUES (89, 'Vacio', NULL, 18, 58, '2019-10-03 12:15:01', '2019-10-03 12:15:01', 62.00, NULL, 'wYIhg7QL0Z1TYwQQKfUMTPOImq1Y021Jyt2PoTx6.jpeg');
INSERT INTO public.productos VALUES (90, 'Platano', NULL, 11, 58, '2019-10-03 12:16:33', '2019-10-03 12:16:33', 5.00, NULL, 'VQYdQVucej1et1T4pkBbRGPUoUc0aq61nxIs0eaM.jpeg');
INSERT INTO public.productos VALUES (91, 'Manzana', NULL, 11, 58, '2019-10-03 12:18:26', '2019-10-03 12:18:26', 6.50, NULL, 'fGfBHOGfnjBi1qvCRVKDambJSf8IOO8qZThGv6dT.jpeg');
INSERT INTO public.productos VALUES (92, 'Kiwi', NULL, 11, 58, '2019-10-03 12:19:25', '2019-10-03 12:19:25', 56.30, NULL, 'e9YSdMX4nsEiGKksH6tPQk2KIVfahEH2Kix2ABN7.jpeg');
INSERT INTO public.productos VALUES (93, 'Paceña', NULL, 20, 58, '2019-10-03 12:20:43', '2019-10-03 12:20:43', 12.50, NULL, 'rgT1dJ3i3uTwbasNV0sPKaNdDOvIYNbL6KTG9FS2.jpeg');
INSERT INTO public.productos VALUES (94, 'Heineken', NULL, 20, 58, '2019-10-03 12:23:04', '2019-10-03 12:23:04', 15.00, NULL, '0AonU8QQk70YSNVumQK9HvaSXH9cyQeQ1WePnTvx.jpeg');
INSERT INTO public.productos VALUES (95, 'Empanada queso', NULL, 9, 58, '2019-10-03 12:27:22', '2019-10-03 12:27:22', 5.00, NULL, 'CII2xF0oGqdG0eUaY2les0SMrwlhzRbzFhWCPbqP.jpeg');
INSERT INTO public.productos VALUES (62, 'Sacta de Pollo', 'null', 18, 58, '2019-09-20 12:24:08', '2019-10-04 14:40:37', 22.30, '2019-10-04 14:40:37', 'bCRB4Fhx6a7Ft47lkPeQ4k38zxEtEnyTGT2R0wBO.jpeg');
INSERT INTO public.productos VALUES (96, 'Sacta de pollo', NULL, 18, 58, '2019-10-04 14:46:26', '2019-10-04 14:46:26', 25.00, NULL, 'hjR1qpULRlxsD76HkKeH9YfhPc1KyPYGXTsHai9m.jpeg');
INSERT INTO public.productos VALUES (97, 'Coca cola 2 lt', NULL, 17, 58, '2019-10-04 14:48:07', '2019-10-04 14:48:07', 11.00, NULL, '76vcam6mztK8apFfGo2VkZvvRAkWMpQyoJtGTirD.jpeg');
INSERT INTO public.productos VALUES (88, 'Hamburguesa', 'solo se sirve por las noches', 21, 58, '2019-10-03 12:13:30', '2019-10-04 14:54:55', 16.50, NULL, 'Lqshpe5t93NlNqG4FdoxonQS72yg3eiWWy9Riqg9.jpeg');
INSERT INTO public.productos VALUES (98, 'Broaster', NULL, 24, 64, '2019-10-05 19:53:12', '2019-10-05 19:53:12', 16.00, NULL, 'ms3KlEPUO2lzfAndX9xyYRLp0LKBxeYez3TQrpT2.jpeg');
INSERT INTO public.productos VALUES (99, 'Coca cola personal', NULL, 25, 64, '2019-10-05 19:53:43', '2019-10-05 19:53:43', 2.00, NULL, 'ByyjrChFDdFqLq6JXsgPfuje4GfrmB00FaXynUEj.jpeg');
INSERT INTO public.productos VALUES (100, 'Litrera', NULL, 25, 64, '2019-10-05 19:54:08', '2019-10-05 19:54:08', 10.00, NULL, 'ypitI7lJKxu8jJSTbkbqkFs086JYjEJ5cL5XQELf.jpeg');
INSERT INTO public.productos VALUES (101, 'Espiedo', NULL, 24, 64, '2019-10-05 19:56:13', '2019-10-05 19:56:13', 16.00, NULL, '6R8qhkROg0wi9VQRUH5wC0Oiv5KsfyeACgo156il.jpeg');
INSERT INTO public.productos VALUES (102, 'Fanta', NULL, 26, 66, '2019-10-18 09:31:00', '2019-10-18 09:31:00', 1.50, NULL, 'IaypbNhD0Q85NoNoE9A1TDPekMKHE3FqUiA5RLah.jpeg');
INSERT INTO public.productos VALUES (103, 'Coca Cola', NULL, 26, 66, '2019-10-18 09:31:27', '2019-10-18 09:31:27', 1.50, NULL, '2gwtTTjsJR3JBK2N2pmCmwHQ46eKqeM1jKym11VE.jpeg');
INSERT INTO public.productos VALUES (104, 'Broaster', NULL, 27, 66, '2019-10-18 09:32:31', '2019-10-18 09:32:31', 16.00, NULL, 'RiDFkrTAnHOpF3YNuIH4sRtwXyo24SLQgbfSoGMF.jpeg');
INSERT INTO public.productos VALUES (105, 'Salchipapa', NULL, 27, 66, '2019-10-18 09:33:19', '2019-10-18 09:33:19', 15.00, NULL, 'LeRA1o7aiIXx06gIdH1AYFdUJxu7Ak6OiZhWTl7j.jpeg');
INSERT INTO public.productos VALUES (106, 'Chicharron', NULL, 28, 67, '2019-10-18 18:12:38', '2019-10-18 18:12:38', 42.00, NULL, '0DT2YVLSHU6xUvpDk8NmcBEcBwNOh3iExQK7RHM0.jpeg');
INSERT INTO public.productos VALUES (107, 'Fricase', NULL, 28, 67, '2019-10-18 18:13:10', '2019-10-18 18:13:10', 45.00, NULL, '19qKMkPdPPgiANeOqTBOjRUDjzGCd1OAmM6x7vjs.jpeg');
INSERT INTO public.productos VALUES (109, 'Coca Cola', NULL, 29, 67, '2019-10-18 18:13:52', '2019-10-18 18:13:52', 2.00, NULL, 'NxYCIyW8sGJKIQhKu7hBuaoMh4YQxioiXVC2pN4t.jpeg');
INSERT INTO public.productos VALUES (110, 'Fanta', NULL, 29, 67, '2019-10-18 18:14:11', '2019-10-18 18:14:11', 2.00, NULL, 'Nuh4Y6pJmQLyQ0ub4xPV0zsbdy8osuaKgOv59bm2.jpeg');
INSERT INTO public.productos VALUES (115, 'Arroz con huevo', 'null', 38, 67, '2019-11-29 13:00:25', '2020-01-24 10:03:02', 8.00, '2020-01-24 10:03:02', NULL);
INSERT INTO public.productos VALUES (127, 'Gelatina', NULL, 43, 67, '2020-01-28 20:01:27', '2020-01-28 20:01:39', 3.50, NULL, 'AtWW1CXQ9qZd39OXOfdLbLu9YivRj1k1c0m3zNOR.jpeg');
INSERT INTO public.productos VALUES (114, 'Plato Cubano', NULL, 38, 67, '2019-11-29 12:41:42', '2020-01-24 10:03:05', 12.00, '2020-01-24 10:03:05', NULL);
INSERT INTO public.productos VALUES (113, 'Silpancho', 'null', 38, 67, '2019-11-29 12:33:42', '2020-01-24 10:03:07', 16.00, '2020-01-24 10:03:07', NULL);
INSERT INTO public.productos VALUES (112, 'Aji panca', NULL, 31, 67, '2019-11-17 23:48:34', '2020-01-24 10:05:27', 6.00, '2020-01-24 10:05:27', '3g40mwgy48ayUIpDAGa8on039yh50d4DHqO6LO0A.jpeg');
INSERT INTO public.productos VALUES (111, 'Aji de fideo', 'null', 31, 67, '2019-11-17 23:48:03', '2020-01-24 10:05:30', 6.00, '2020-01-24 10:05:30', 'V8Nc2LRp4d3oaSWdQnHJzU5AeO5PzS3gSkuKAeON.jpeg');
INSERT INTO public.productos VALUES (124, 'Jugo de naranja', NULL, 41, 67, '2020-01-24 10:56:05', '2020-01-24 10:56:05', 10.00, NULL, '4g96weaWZXVsQr7NNMlJzv0BZp0ePFnJiu80gOvd.jpeg');
INSERT INTO public.productos VALUES (121, 'Paceña', NULL, 40, 67, '2019-12-08 21:27:09', '2019-12-08 21:27:36', 25.00, NULL, 'ZhQUceaJkWNR3TJ1cUTUZooLIb87ibaE8pnn8FLg.jpeg');
INSERT INTO public.productos VALUES (122, 'Ron Abuelo', NULL, 40, 67, '2019-12-08 21:28:52', '2019-12-08 21:28:52', 90.00, NULL, 'uDfkhEDoZNpUalkeDhOcGrX4td7H9NOeMsKn9cYX.jpeg');
INSERT INTO public.productos VALUES (108, 'Fricharron', NULL, 28, 67, '2019-10-18 18:13:26', '2020-01-24 10:02:08', 50.00, NULL, '1f88tuSY58IZtYgHp4Rz98OQeClLXvyCgzeFu3gR.jpeg');
INSERT INTO public.productos VALUES (118, 'Queso', 'null', 31, 67, '2019-11-29 17:13:48', '2020-01-24 10:02:26', 3.00, '2020-01-24 10:02:26', NULL);
INSERT INTO public.productos VALUES (117, 'Broaster', 'null', 31, 67, '2019-11-29 17:12:50', '2020-01-24 10:02:56', 16.00, '2020-01-24 10:02:56', NULL);
INSERT INTO public.productos VALUES (116, 'Fritanga', 'null', 38, 67, '2019-11-29 16:01:20', '2020-01-24 10:03:00', 25.00, '2020-01-24 10:03:00', NULL);
INSERT INTO public.productos VALUES (123, 'Zumo zanahoria', NULL, 41, 67, '2020-01-24 10:55:44', '2020-01-24 10:56:18', 10.00, NULL, 'SdhmxEAU8DoKJ7nD7oSs0VBm723AcnuxhpYU6z1f.jpeg');
INSERT INTO public.productos VALUES (125, 'pepsi en lata', NULL, 29, 67, '2020-01-24 18:22:54', '2020-01-24 18:22:54', 6.00, NULL, 'GTvSE7r6yfFRBwO4OgyE0l22UE9uSULdz7nHCeGl.jpeg');
INSERT INTO public.productos VALUES (120, 'Aji de lengua', NULL, 28, 67, '2019-11-29 17:15:40', '2020-01-24 10:02:29', 23.00, '2020-01-24 10:02:29', '76bEKqcbBc7t2VMlEytTStCZAU7cxa7QTOvuH3s3.jpeg');
INSERT INTO public.productos VALUES (119, 'Sopa de quinoa', NULL, 38, 67, '2019-11-29 17:14:53', '2020-01-24 10:02:18', 22.00, '2020-01-24 10:02:18', NULL);
INSERT INTO public.productos VALUES (126, 'Jugo de zanahoria', NULL, 41, 67, '2020-01-28 17:50:17', '2020-01-28 17:51:01', 30.00, NULL, '1HSV4iblqyp4CaBLG3YwK4CNawlkDr2XewDJZ4jc.jpeg');


--
-- TOC entry 5016 (class 0 OID 33124)
-- Dependencies: 242
-- Data for Name: restaurants; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.restaurants VALUES (32, 'La Comoda', true, 'No tiene', '2019-07-10 03:26:27', '2019-07-10 03:50:30', 1, 'El usuario recien ingreso', 1, '$', 'DNI');
INSERT INTO public.restaurants VALUES (8, 'Rocachan', true, 'Especialidad en fricachos', '2019-07-01 19:58:19', '2019-07-01 19:58:19', 1, NULL, NULL, '$', 'DNI');
INSERT INTO public.restaurants VALUES (11, 'Juan Valdez', true, 'asdfasdfa', '2019-07-01 20:12:13', '2019-07-01 20:12:13', 1, NULL, NULL, '$', 'DNI');
INSERT INTO public.restaurants VALUES (12, 'San Pedro', true, 'Empanadas con queso', '2019-07-01 20:15:47', '2019-07-01 20:15:47', 1, NULL, NULL, '$', 'DNI');
INSERT INTO public.restaurants VALUES (33, 'La Cabana', true, 'a', '2019-07-10 03:52:04', '2019-07-10 03:52:04', 1, 'nuevo restaurante', 2, '$', 'DNI');
INSERT INTO public.restaurants VALUES (16, 'La Casa del Camba', true, 'Restaurante de comida típica', '2019-07-01 21:14:32', '2019-07-01 21:14:32', 1, NULL, NULL, '$', 'DNI');
INSERT INTO public.restaurants VALUES (19, 'El Puente', true, 'Donde se sirve charquecan', '2019-07-01 21:37:51', '2019-07-01 21:37:51', 1, NULL, NULL, '$', 'DNI');
INSERT INTO public.restaurants VALUES (20, 'Salamanca', true, 'Peces a la parrilla', '2019-07-01 22:40:40', '2019-07-01 22:40:40', 1, NULL, NULL, '$', 'DNI');
INSERT INTO public.restaurants VALUES (22, 'Las Almejas', true, 'Se sirven platos a la gurmet', '2019-07-01 23:05:19', '2019-07-01 23:05:19', 1, NULL, NULL, '$', 'DNI');
INSERT INTO public.restaurants VALUES (10, 'Ramiro II', false, 'adsfadfas', '2019-07-01 20:01:38', '2019-07-02 19:23:43', 1, NULL, NULL, '$', 'DNI');
INSERT INTO public.restaurants VALUES (40, 'La cumbre', true, 'no tiene', '2019-10-11 11:23:02', '2019-10-11 11:23:02', 2, 'no tiene', 3, '$', 'DNI');
INSERT INTO public.restaurants VALUES (26, 'El Campesino', true, 'Comidas típicas de Tarija y Chuquisaca', '2019-07-01 23:32:31', '2019-07-10 03:53:50', 1, 'No tiene', 2, '$', 'DNI');
INSERT INTO public.restaurants VALUES (14, 'El callejon', true, 'restaurante de comida fria', '2019-07-01 20:21:01', '2019-07-10 03:54:53', 1, 'No', 3, '$', 'DNI');
INSERT INTO public.restaurants VALUES (18, 'Mc Donald', true, 'Solo hamburguesas', '2019-07-01 21:16:47', '2019-07-14 15:16:53', 1, 'Solo por un mes', 1, '$', 'DNI');
INSERT INTO public.restaurants VALUES (34, 'Pandora I', true, 'No tiene', '2019-07-14 17:24:55', '2019-07-14 17:24:55', 1, 'asdfasdf', 1, '$', 'DNI');
INSERT INTO public.restaurants VALUES (35, 'Pandora II', true, 'No tiene', '2019-07-14 17:31:06', '2019-08-15 15:11:01', 1, 'No tiene', 3, '$', 'DNI');
INSERT INTO public.restaurants VALUES (1, 'COROICO IN 2', true, 'Restaurante de comida típica nacional de Bolivia, donde se sirve variedad de comidas', '2019-06-11 15:24:48', '2019-08-22 07:50:37', 1, 'Dado de alta en fecha 10/07/2019', 2, '$', 'DNI');
INSERT INTO public.restaurants VALUES (37, 'La Colonia de San Cristobal', true, 'No tiene', '2019-08-25 21:25:18', '2019-08-25 21:25:18', 2, 'No tiene', 3, '$', 'DNI');
INSERT INTO public.restaurants VALUES (36, 'La Caverna de Moe', true, 'Bar exclusivo de bebidas', '2019-08-21 15:46:20', '2019-08-25 21:25:47', 2, 'No tiene', 3, '$', 'DNI');
INSERT INTO public.restaurants VALUES (7, 'Rafael 1234', false, 'peces a la parrilla', '2019-07-01 19:53:59', '2019-08-27 09:31:52', 1, 'No tiene', 1, '$', 'DNI');
INSERT INTO public.restaurants VALUES (30, 'La Pipa del Diablo', true, 'Bar de bebidas alcoholicas', '2019-07-07 04:23:35', '2019-09-02 18:10:22', 2, 'No tiene', 3, '$', 'DNI');
INSERT INTO public.restaurants VALUES (38, 'La Casa del Camba 2', true, 'situada en Santa Cruz de la Sierra', '2019-10-05 19:40:22', '2019-10-05 19:40:22', 2, 'prueba gratis', 1, '$', 'DNI');
INSERT INTO public.restaurants VALUES (27, 'Pedro Picapiedra', false, 'Comida vegetariana y vegana', '2019-07-04 02:48:23', '2019-07-06 12:46:53', 1, NULL, NULL, '$', 'DNI');
INSERT INTO public.restaurants VALUES (17, 'El pirata Segundo', false, 'No pago cuota del mes de 09/20', '2019-07-01 21:15:05', '2019-07-06 12:53:45', 1, NULL, NULL, '$', 'DNI');
INSERT INTO public.restaurants VALUES (29, 'La Corona 2', false, 'asdfasdf', '2019-07-06 13:55:47', '2019-07-06 17:57:20', 1, NULL, NULL, '$', 'DNI');
INSERT INTO public.restaurants VALUES (13, 'Pedro Vargas', true, 'Restaurante de comida rapída', '2019-07-01 20:17:11', '2019-07-04 02:21:15', 1, NULL, NULL, '$', 'DNI');
INSERT INTO public.restaurants VALUES (15, 'El Fogón', false, 'Restaurante de comida a la parrilla', '2019-07-01 20:42:25', '2019-07-04 02:36:20', 1, NULL, NULL, '$', 'DNI');
INSERT INTO public.restaurants VALUES (25, 'La Corona', false, 'Tipo tipo de alimentos y bebidas de todo tipo', '2019-07-01 23:28:24', '2019-07-06 17:57:43', 1, NULL, NULL, '$', 'DNI');
INSERT INTO public.restaurants VALUES (24, 'El caballito', false, 'Solo bebidas alcoholicas', '2019-07-01 23:26:19', '2019-07-06 17:57:50', 1, NULL, NULL, '$', 'DNI');
INSERT INTO public.restaurants VALUES (23, 'El Cochala', false, 'Comida típica de cochabamba', '2019-07-01 23:11:01', '2019-07-06 17:58:00', 1, NULL, NULL, '$', 'DNI');
INSERT INTO public.restaurants VALUES (3, 'La cola del diablo', false, 'Comida Caliente y al vapor', '2019-07-01 19:27:12', '2019-07-07 04:26:50', 1, NULL, NULL, '$', 'DNI');
INSERT INTO public.restaurants VALUES (28, 'Juan Valdez III', true, 'juan valdez con mayusculas', '2019-07-04 15:17:43', '2019-07-07 04:31:51', 1, NULL, NULL, '$', 'DNI');
INSERT INTO public.restaurants VALUES (21, 'La curva Segunda', true, 'Otro restaurante', '2019-07-01 23:03:45', '2019-07-07 14:29:54', 1, NULL, NULL, '$', 'DNI');
INSERT INTO public.restaurants VALUES (39, 'El Coral', true, 'No tiene', '2019-10-07 18:11:45', '2019-10-07 18:11:45', 2, 'no tiene', 1, '$', 'DNI');
INSERT INTO public.restaurants VALUES (41, 'MachuPichu', true, 'restaurante del perú', '2019-10-18 09:16:39', '2019-10-18 09:29:38', 2, 'no tiene', 2, 'Bs.', 'DNI');
INSERT INTO public.restaurants VALUES (43, 'La Alfombra Roja', true, 'Sin observacion', '2019-10-24 10:00:10', '2019-10-24 10:01:02', 2, NULL, 1, '$', 'DNI');
INSERT INTO public.restaurants VALUES (44, 'Game of Thrones', true, NULL, '2019-11-26 09:01:54', '2019-12-05 18:07:31', 2, NULL, 2, '$', 'DNI');
INSERT INTO public.restaurants VALUES (31, 'La casa del Puma', true, 'Restaurante de comida tipida de Tihuanaku', '2019-07-07 04:31:14', '2020-01-19 00:13:16', 2, 'No tiene', 2, 'Bs.', 'CI.');
INSERT INTO public.restaurants VALUES (42, 'Camargo', true, NULL, '2019-10-18 18:01:06', '2020-01-28 12:29:14', 2, NULL, 2, '$', 'DNI');


--
-- TOC entry 5018 (class 0 OID 33130)
-- Dependencies: 244
-- Data for Name: sucursals; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sucursals VALUES (3, 'El Portal', 'Av. Mario Mercado Nro 100 Z/B Llojeta', 'Ubicacion en Huatajata', 31, 1, '2019-07-08 16:00:48', '2019-07-08 16:00:48', 'La Paz', 'Bolivia', '71245623', NULL);
INSERT INTO public.sucursals VALUES (5, 'El Hincha', 'Av. Mario Mercado Nro 100 Z/B Llojeta', 'solo abiertos los dias de partido', 8, 1, '2019-07-08 20:31:11', '2019-07-09 14:23:52', 'La Paz', 'Bolivia', '71245623', NULL);
INSERT INTO public.sucursals VALUES (4, 'aaaa', 'Av. Mario Mercado Nro 100 Z/B Llojeta', 'Sucursal secundaria del Callejon', 14, 1, '2019-07-08 20:28:49', '2019-07-09 15:12:49', 'La Paz', 'Bolivia', '71245623', NULL);
INSERT INTO public.sucursals VALUES (7, 'asdadsfasdfasd', 'Av. Mario Mercado Nro 100 Z/B Llojeta', 'asdfasdfasf', 28, 1, '2019-07-09 22:59:04', '2019-07-09 22:59:04', 'La Paz', 'Bolivia', '71245623', NULL);
INSERT INTO public.sucursals VALUES (6, 'La Comarca', 'Av. Mario Mercado Nro 100 Z/B Llojeta', 'Solo comida vegetariana', 28, 1, '2019-07-09 14:45:11', '2019-07-09 23:01:04', 'La Paz', 'Bolivia', '71245623', NULL);
INSERT INTO public.sucursals VALUES (8, 'Sucursal Central', 'Av. Mario Mercado Nro 100 Z/B Llojeta', 'No tiene', 20, 1, '2019-07-10 01:41:38', '2019-07-10 01:41:38', 'La Paz', 'Bolivia', '71245623', NULL);
INSERT INTO public.sucursals VALUES (1, 'Sucursal 2', 'Av. Mario Mercado Nro 100 Z/B Llojeta', 'Sucursal principal', 1, 1, '2019-07-05 03:22:01', '2019-07-10 01:46:11', 'La Paz', 'Bolivia', '71245623', NULL);
INSERT INTO public.sucursals VALUES (2, 'La cola del diablo', 'Av. Mario Mercado Nro 100 Z/B Llojeta', 'ahora tiene', 1, 1, '2019-07-08 03:22:01', '2019-08-15 15:11:35', 'La Paz', 'Bolivia', '71245623', NULL);
INSERT INTO public.sucursals VALUES (9, 'El Patio Trasero', 'Av. Mario Mercado Nro 100 Z/B Llojeta', 'Comida rica en nutrientes, sodas, etc', 31, 1, '2019-08-17 10:59:46', '2019-08-17 10:59:46', 'La Paz', 'Bolivia', '71245623', NULL);
INSERT INTO public.sucursals VALUES (11, 'Sucursal Central 1', 'Av. Mario Mercado Nro 100 Z/B Llojeta', 'No tiene', 1, 2, '2019-08-25 21:34:51', '2019-08-25 21:34:51', 'La Paz', 'Bolivia', '71245623', NULL);
INSERT INTO public.sucursals VALUES (12, 'Sucursal San Pedro', 'Av. Mario Mercado Nro 100 Z/B Llojeta', NULL, 31, 1, '2019-08-27 12:38:46', '2019-08-27 12:38:46', 'La Paz', 'Bolivia', '71245623', NULL);
INSERT INTO public.sucursals VALUES (13, 'Sucursal Centro', 'Av. Mario Mercado Nro 100 Z/B Llojeta', NULL, 31, 1, '2019-08-27 12:40:19', '2019-08-27 12:40:19', 'La Paz', 'Bolivia', '71245623', NULL);
INSERT INTO public.sucursals VALUES (14, 'Sucursal Tihuanaku', 'Av. Mario Mercado Nro 100 Z/B Llojeta', 'No tiene', 31, 2, '2019-08-27 15:46:20', '2019-08-27 15:46:20', 'La Paz', 'Bolivia', '71245623', NULL);
INSERT INTO public.sucursals VALUES (15, 'Sucursal Principal', 'Av. Mario Mercado Nro 100 Z/B Llojeta', 'No tiene', 38, 2, '2019-10-05 19:41:10', '2019-10-05 19:41:10', 'La Paz', 'Bolivia', '71245623', NULL);
INSERT INTO public.sucursals VALUES (16, 'Principal', 'Av. Mario Mercado Nro 100 Z/B Llojeta', 'sucursal principal', 41, 2, '2019-10-18 09:17:40', '2019-10-18 09:17:40', 'La Paz', 'Bolivia', '71245623', NULL);
INSERT INTO public.sucursals VALUES (18, 'Sucursal Dos', 'Av. Mario Mercado Nro 100 Z/B Llojeta', NULL, 42, 2, '2019-10-24 17:22:15', '2019-10-24 17:22:15', 'La Paz', 'Bolivia', '71245623', NULL);
INSERT INTO public.sucursals VALUES (20, 'Principal', 'Av. Mario Mercado Nro 100 Z/B Llojeta', NULL, 32, 2, '2019-10-24 17:41:31', '2019-10-24 18:05:00', 'La Paz', 'Bolivia', '71245623', NULL);
INSERT INTO public.sucursals VALUES (10, 'Muela del Diablo', 'Av. Mario Mercado Nro 100 Z/B Llojeta', 'Pago anticipado', 19, 2, '2019-08-22 08:28:39', '2019-10-24 18:07:34', 'La Paz', 'Bolivia', '71245623', NULL);
INSERT INTO public.sucursals VALUES (21, 'Sucursal Principal', 'Pza. Avaroa, frente a Dominos Pitza', NULL, 44, 2, '2019-11-26 09:03:13', '2019-11-26 09:03:13', 'La Paz', 'Bolivia', '2487856', '71245623');
INSERT INTO public.sucursals VALUES (22, 'Sucursal Stadium', 'Estadium Hernando Siles # 45', NULL, 44, 2, '2019-11-26 09:04:53', '2019-11-26 09:04:53', 'La Paz', 'Boliva', '2224589', '71245689');
INSERT INTO public.sucursals VALUES (17, 'Sucursal Uno', 'Av. Bush, esq Vasquez # 599', NULL, 42, 2, '2019-10-18 18:02:05', '2020-01-28 12:23:07', 'La Paz', 'Bolivia', '2456878', '71245625');


--
-- TOC entry 5020 (class 0 OID 33136)
-- Dependencies: 246
-- Data for Name: superadministradors; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.superadministradors VALUES (1, 'rafael', '12345', '2019-06-04 00:00:00', '2019-06-04 00:00:00');
INSERT INTO public.superadministradors VALUES (2, 'Jonathan', '$2y$10$4lNb9Ub8XfEN2tzxBlVIOuhOzplT0tMip7LUl.cpYLaC/OpTLilLe', '2019-06-28 22:23:22', '2019-06-28 22:23:22');


--
-- TOC entry 5022 (class 0 OID 33142)
-- Dependencies: 248
-- Data for Name: suscripcions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.suscripcions VALUES (2, 'Estandar', 'Tiene todas las caracteristicas excepto los reportes del últimos año', NULL, 150.00, '2019-07-10 02:22:55', '2019-07-10 02:22:55', 1);
INSERT INTO public.suscripcions VALUES (3, 'Pro', 'Tiene todas las caracteristicas', NULL, 200.00, '2019-07-10 02:25:30', '2019-07-10 02:25:30', 1);
INSERT INTO public.suscripcions VALUES (1, 'Basico', 'Un mes de prueba gratis', NULL, 100.00, '2019-07-10 02:20:23', '2019-07-10 02:20:23', 1);


--
-- TOC entry 4989 (class 0 OID 33051)
-- Dependencies: 215
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.users VALUES (1, 'Rafael Freddy', 'Ortiz', 'Rocha', '4792527', 'Calle Monje #25', 'Infoman', 'infoman.rafael@gmail.com', '$2y$10$wbYsnOFrbmJDLRMlryUC3.gbfFITplgO6HI2/QZOThtPsHWb7su8G', '1986-08-18', true, NULL, '2019-06-05 12:26:57', '2019-06-05 12:26:57', NULL, NULL, NULL, NULL, NULL, NULL, true);


--
-- TOC entry 5025 (class 0 OID 33149)
-- Dependencies: 251
-- Data for Name: venta_productos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.venta_productos VALUES (464, 4, 16.00, 0, 'P', 126, 19, '2019-11-17 23:50:52', '2019-11-23 09:12:45', 17, NULL, 16.00, 34, true, NULL);
INSERT INTO public.venta_productos VALUES (456, 9, 44.00, 0, 'P', NULL, NULL, '2019-11-06 10:30:35', '2019-11-06 15:59:38', 17, 11, 44.00, 31, false, NULL);
INSERT INTO public.venta_productos VALUES (354, 13, 13.00, 0, 'A', 4, 13, '2019-10-18 12:37:52', '2019-10-18 12:37:52', 3, NULL, 13.00, 24, false, NULL);
INSERT INTO public.venta_productos VALUES (355, 14, 80.50, 0, 'P', 4, 13, '2019-10-18 12:43:04', '2019-10-18 12:43:04', 3, NULL, 80.50, 24, false, NULL);
INSERT INTO public.venta_productos VALUES (356, 15, 21.50, 0, 'A', 2, 13, '2019-10-18 15:59:26', '2019-10-18 15:59:27', 3, NULL, 21.50, 24, false, NULL);
INSERT INTO public.venta_productos VALUES (357, 16, 10.50, 0, 'A', 24, 13, '2019-10-18 15:59:46', '2019-10-18 15:59:46', 3, NULL, 10.50, 24, false, NULL);
INSERT INTO public.venta_productos VALUES (358, 17, 66.30, 0, 'A', 10, 13, '2019-10-18 16:00:03', '2019-10-18 16:00:03', 3, NULL, 66.30, 24, false, NULL);
INSERT INTO public.venta_productos VALUES (359, 18, 27.50, 0, 'A', 10, 13, '2019-10-18 16:00:20', '2019-10-18 16:00:20', 3, NULL, 27.50, 24, false, NULL);
INSERT INTO public.venta_productos VALUES (360, 19, 72.50, 0, 'P', 30, 13, '2019-10-18 16:00:31', '2019-10-18 16:06:41', 3, NULL, 72.50, 24, false, NULL);
INSERT INTO public.venta_productos VALUES (361, 20, 23.50, 0, 'A', 3, 13, '2019-10-18 16:29:42', '2019-10-18 16:29:42', 3, NULL, 23.50, 24, false, NULL);
INSERT INTO public.venta_productos VALUES (362, 21, 5.00, 0, 'A', 6, 13, '2019-10-18 16:36:52', '2019-10-18 16:36:52', 3, NULL, 5.00, 24, false, NULL);
INSERT INTO public.venta_productos VALUES (363, 22, 15.00, 0, 'A', 6, 13, '2019-10-18 16:58:52', '2019-10-18 16:58:52', 3, NULL, 15.00, 24, false, NULL);
INSERT INTO public.venta_productos VALUES (364, 23, 16.00, 0, 'A', 37, 13, '2019-10-18 16:59:13', '2019-10-18 16:59:13', 3, NULL, 16.00, 24, false, NULL);
INSERT INTO public.venta_productos VALUES (345, 3, 35.00, 0, 'P', 104, NULL, '2019-10-18 11:00:03', '2019-10-18 17:02:09', 16, 10, 35.00, 26, false, NULL);
INSERT INTO public.venta_productos VALUES (346, 4, 33.00, 0, 'P', 105, NULL, '2019-10-18 11:17:20', '2019-10-18 17:02:16', 16, 10, 33.00, 26, false, NULL);
INSERT INTO public.venta_productos VALUES (347, 5, 4.50, 0, 'P', 105, NULL, '2019-10-18 11:17:54', '2019-10-18 17:05:07', 16, 10, 4.50, 26, false, NULL);
INSERT INTO public.venta_productos VALUES (348, 6, 16.00, 0, 'P', 104, 18, '2019-10-18 11:35:06', '2019-10-18 17:05:15', 16, NULL, 16.00, 26, false, NULL);
INSERT INTO public.venta_productos VALUES (349, 7, 19.00, 0, 'P', 104, 18, '2019-10-18 11:47:45', '2019-10-18 17:05:24', 16, NULL, 19.00, 26, false, NULL);
INSERT INTO public.venta_productos VALUES (350, 8, 19.00, 0, 'P', 104, 18, '2019-10-18 12:04:23', '2019-10-18 17:05:34', 16, NULL, 19.00, 26, false, NULL);
INSERT INTO public.venta_productos VALUES (366, 10, 35.00, 0, 'P', 105, 18, '2019-10-18 17:10:03', '2019-10-18 17:10:03', 16, NULL, 35.00, 26, false, NULL);
INSERT INTO public.venta_productos VALUES (367, 11, 33.00, 0, 'P', 105, 18, '2019-10-18 17:11:07', '2019-10-18 17:11:07', 16, NULL, 33.00, 26, false, NULL);
INSERT INTO public.venta_productos VALUES (368, 12, 47.00, 0, 'A', 104, 18, '2019-10-18 17:11:44', '2019-10-18 17:11:44', 16, NULL, 47.00, 26, false, NULL);
INSERT INTO public.venta_productos VALUES (369, 13, 35.00, 0, 'A', 105, 18, '2019-10-18 17:12:01', '2019-10-18 17:12:01', 16, NULL, 35.00, 26, false, NULL);
INSERT INTO public.venta_productos VALUES (370, 14, 33.00, 0, 'A', 104, 18, '2019-10-18 17:12:15', '2019-10-18 17:12:15', 16, NULL, 33.00, 26, false, NULL);
INSERT INTO public.venta_productos VALUES (374, 2, 50.50, 0, 'P', 107, 18, '2019-10-18 17:48:40', '2019-10-18 17:48:41', 16, NULL, 50.50, 28, false, NULL);
INSERT INTO public.venta_productos VALUES (375, 3, 16.50, 0, 'A', 107, 18, '2019-10-18 17:49:07', '2019-10-18 17:49:07', 16, NULL, 16.50, 28, false, NULL);
INSERT INTO public.venta_productos VALUES (376, 4, 16.50, 0, 'A', 108, 18, '2019-10-18 17:49:32', '2019-10-18 17:49:32', 16, NULL, 16.50, 28, false, NULL);
INSERT INTO public.venta_productos VALUES (377, 5, 34.00, 0, 'A', 108, 18, '2019-10-18 17:50:18', '2019-10-18 17:50:18', 16, NULL, 34.00, 28, false, NULL);
INSERT INTO public.venta_productos VALUES (378, 6, 33.00, 0, 'P', 107, 18, '2019-10-18 17:51:23', '2019-10-18 17:51:23', 16, NULL, 33.00, 28, false, NULL);
INSERT INTO public.venta_productos VALUES (379, 7, 77.00, 0, 'P', 109, 18, '2019-10-18 17:52:31', '2019-10-18 17:52:31', 16, NULL, 77.00, 28, false, NULL);
INSERT INTO public.venta_productos VALUES (380, 8, 35.00, 0, 'A', 106, NULL, '2019-10-18 17:53:22', '2019-10-18 17:53:22', 16, 10, 35.00, 28, false, NULL);
INSERT INTO public.venta_productos VALUES (381, 9, 16.00, 0, 'A', 104, NULL, '2019-10-18 17:57:44', '2019-10-18 17:57:45', 16, 10, 16.00, 28, false, NULL);
INSERT INTO public.venta_productos VALUES (382, 10, 17.50, 0, 'A', 105, NULL, '2019-10-18 17:58:12', '2019-10-18 17:58:12', 16, 10, 17.50, 28, false, NULL);
INSERT INTO public.venta_productos VALUES (392, 4, 48.00, 0, 'P', 60, 13, '2019-10-19 23:13:50', '2019-10-19 23:13:50', 3, NULL, 48.00, 27, false, NULL);
INSERT INTO public.venta_productos VALUES (384, 2, 91.00, 0, 'P', 111, 19, '2019-10-18 18:19:05', '2019-10-18 18:19:05', 17, NULL, 91.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (390, 2, 115.00, 0, 'P', 7, 13, '2019-10-19 23:11:30', '2019-10-19 23:15:28', 3, NULL, 115.00, 27, false, NULL);
INSERT INTO public.venta_productos VALUES (386, 4, 52.00, 0, 'P', 112, 19, '2019-10-18 18:20:37', '2019-10-18 18:20:37', 17, NULL, 52.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (388, 6, 98.00, 0, 'P', 112, 19, '2019-10-18 18:36:58', '2019-10-18 18:36:59', 17, NULL, 98.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (393, 8, 182.00, 0, 'P', 111, 19, '2019-10-22 12:23:16', '2019-10-22 12:23:17', 17, NULL, 182.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (389, 7, 89.00, 0, 'P', 111, NULL, '2019-10-18 18:39:07', '2019-10-18 18:40:28', 17, 11, 89.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (387, 5, 190.00, 0, 'P', 111, 19, '2019-10-18 18:36:06', '2019-10-18 18:40:38', 17, NULL, 190.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (385, 3, 52.00, 0, 'P', 110, 19, '2019-10-18 18:19:48', '2019-10-18 18:40:48', 17, NULL, 52.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (383, 1, 142.00, 0, 'P', 110, 19, '2019-10-18 18:16:07', '2019-10-18 18:41:14', 17, NULL, 142.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (365, 1, 57.50, 0, 'P', 4, 13, '2019-10-18 17:01:02', '2019-10-19 23:09:40', 3, NULL, 57.50, 27, false, NULL);
INSERT INTO public.venta_productos VALUES (396, 11, 88.00, 0, 'P', 114, 19, '2019-10-22 12:26:29', '2019-10-22 12:26:43', 17, NULL, 88.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (391, 3, 23.50, 0, 'P', 6, 13, '2019-10-19 23:12:07', '2019-10-19 23:12:36', 3, NULL, 23.50, 27, false, NULL);
INSERT INTO public.venta_productos VALUES (394, 9, 54.00, 0, 'A', 113, 19, '2019-10-22 12:25:03', '2019-10-22 12:25:04', 17, NULL, 54.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (395, 10, 44.00, 0, 'P', 114, 19, '2019-10-22 12:25:44', '2019-10-22 12:25:44', 17, NULL, 44.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (397, 12, 95.00, 0, 'A', 111, 19, '2019-10-22 17:54:27', '2019-10-22 17:54:30', 17, NULL, 95.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (398, 13, 94.00, 0, 'A', 115, 19, '2019-10-22 18:19:32', '2019-10-22 18:19:34', 17, NULL, 94.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (399, 14, 91.00, 0, 'A', 116, 19, '2019-10-22 18:55:04', '2019-10-22 18:55:04', 17, NULL, 91.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (400, 15, 89.00, 0, 'A', 111, 19, '2019-10-23 12:24:02', '2019-10-23 12:24:04', 17, NULL, 89.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (457, 4, 91.00, 0, 'P', 121, NULL, '2019-11-06 11:02:38', '2019-11-06 15:55:36', 18, 11, 91.00, 33, false, NULL);
INSERT INTO public.venta_productos VALUES (65, NULL, 115.65, 25, 'P', 26, 13, '2019-09-27 10:15:53', '2019-09-30 10:48:01', 3, NULL, 154.20, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (3, NULL, 0.00, 25, 'A', 17, 13, '2019-09-24 12:32:47', '2019-09-24 12:32:47', 3, NULL, 0.00, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (4, NULL, 249.45, 25, 'A', 18, 13, '2019-09-24 12:34:35', '2019-09-24 12:34:35', 3, NULL, 332.60, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (5, NULL, 98.25, 25, 'A', 19, 13, '2019-09-24 16:34:45', '2019-09-24 16:34:45', 3, NULL, 131.00, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (6, NULL, 98.25, 25, 'A', 20, 13, '2019-09-24 16:37:57', '2019-09-24 16:37:57', 3, NULL, 131.00, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (7, NULL, 98.25, 25, 'A', 21, 13, '2019-09-24 16:40:35', '2019-09-24 16:40:35', 3, NULL, 131.00, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (8, NULL, 90.97, 25, 'A', 22, 13, '2019-09-24 16:41:11', '2019-09-24 16:41:11', 3, NULL, 121.30, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (9, NULL, 149.18, 25, 'A', 23, 13, '2019-09-24 16:53:04', '2019-09-24 16:53:04', 3, NULL, 198.90, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (10, NULL, 115.73, 25, 'A', 24, 13, '2019-09-24 16:55:04', '2019-09-24 16:55:04', 3, NULL, 154.30, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (11, NULL, 115.95, 25, 'A', 25, 13, '2019-09-24 17:14:17', '2019-09-24 17:14:17', 3, NULL, 154.60, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (12, NULL, 182.63, 25, 'A', 26, 13, '2019-09-24 17:22:35', '2019-09-24 17:22:35', 3, NULL, 243.50, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (13, NULL, 66.75, 25, 'A', 27, 13, '2019-09-24 17:27:02', '2019-09-24 17:27:02', 3, NULL, 89.00, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (14, NULL, 99.00, 25, 'A', 28, 13, '2019-09-24 17:28:44', '2019-09-24 17:28:44', 3, NULL, 132.00, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (15, NULL, 111.52, 25, 'A', 29, 13, '2019-09-24 21:16:46', '2019-09-24 21:16:46', 3, NULL, 148.70, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (16, NULL, 57.53, 25, 'A', 30, 13, '2019-09-24 21:21:19', '2019-09-24 21:21:19', 3, NULL, 76.70, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (17, NULL, 57.53, 25, 'A', 31, 13, '2019-09-24 21:23:37', '2019-09-24 21:23:37', 3, NULL, 76.70, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (18, NULL, 132.45, 25, 'A', 32, 13, '2019-09-24 21:29:26', '2019-09-24 21:29:26', 3, NULL, 176.60, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (19, NULL, 122.93, 25, 'A', 33, 13, '2019-09-24 21:42:34', '2019-09-24 21:42:34', 3, NULL, 163.90, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (20, NULL, 207.60, 25, 'A', 34, 13, '2019-09-24 21:52:15', '2019-09-24 21:52:15', 3, NULL, 276.80, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (21, NULL, 246.15, 25, 'A', 35, 13, '2019-09-24 21:57:04', '2019-09-24 21:57:04', 3, NULL, 328.20, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (22, NULL, 123.98, 25, 'A', 36, 13, '2019-09-25 13:20:00', '2019-09-25 13:20:00', 3, NULL, 165.30, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (23, NULL, 40.72, 25, 'A', 37, 13, '2019-09-25 18:08:53', '2019-09-25 18:08:53', 3, NULL, 54.30, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (24, NULL, 136.57, 25, 'A', 38, 13, '2019-09-25 18:25:46', '2019-09-25 18:25:46', 3, NULL, 182.10, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (25, NULL, 165.45, 25, 'A', 39, 13, '2019-09-25 18:33:21', '2019-09-25 18:33:21', 3, NULL, 220.60, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (26, NULL, 57.53, 25, 'A', 40, 13, '2019-09-26 09:08:08', '2019-09-26 09:08:08', 3, NULL, 76.70, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (27, NULL, 149.18, 25, 'A', 41, 13, '2019-09-26 09:41:40', '2019-09-26 09:41:40', 3, NULL, 198.90, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (28, NULL, 115.73, 25, 'A', 51, 13, '2019-09-26 13:20:13', '2019-09-26 13:20:13', 3, NULL, 154.30, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (29, NULL, 115.73, 25, 'A', 52, 13, '2019-09-26 13:21:16', '2019-09-26 13:21:16', 3, NULL, 154.30, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (30, NULL, 115.73, 25, 'A', 53, 13, '2019-09-26 13:23:03', '2019-09-26 13:23:03', 3, NULL, 154.30, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (31, NULL, 115.73, 25, 'A', 54, 13, '2019-09-26 13:24:15', '2019-09-26 13:24:15', 3, NULL, 154.30, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (32, NULL, 149.18, 25, 'A', 55, 13, '2019-09-26 15:36:58', '2019-09-26 15:36:58', 3, NULL, 198.90, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (33, NULL, 149.18, 25, 'A', 56, 13, '2019-09-26 15:38:52', '2019-09-26 15:38:52', 3, NULL, 198.90, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (34, NULL, 99.23, 25, 'A', 57, 13, '2019-09-26 15:40:18', '2019-09-26 15:40:18', 3, NULL, 132.30, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (35, NULL, 132.45, 25, 'A', 58, 13, '2019-09-26 15:43:33', '2019-09-26 15:43:33', 3, NULL, 176.60, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (37, NULL, 152.77, 25, 'A', 60, 13, '2019-09-26 16:26:06', '2019-09-26 16:26:06', 3, NULL, 203.70, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (38, NULL, 0.00, 25, 'A', 61, 13, '2019-09-26 16:45:11', '2019-09-26 16:45:11', 3, NULL, 0.00, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (39, NULL, 115.73, 25, 'A', 62, 13, '2019-09-26 16:45:52', '2019-09-26 16:45:52', 3, NULL, 154.30, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (40, NULL, 115.73, 25, 'A', 63, 13, '2019-09-26 17:20:50', '2019-09-26 17:20:50', 3, NULL, 154.30, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (41, NULL, 115.73, 25, 'A', 64, 13, '2019-09-26 17:21:37', '2019-09-26 17:21:37', 3, NULL, 154.30, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (42, NULL, 115.73, 25, 'A', 65, 13, '2019-09-26 17:22:05', '2019-09-26 17:22:05', 3, NULL, 154.30, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (43, NULL, 115.73, 25, 'A', 66, 13, '2019-09-26 17:22:52', '2019-09-26 17:22:52', 3, NULL, 154.30, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (44, NULL, 115.73, 25, 'A', 67, 13, '2019-09-26 17:23:28', '2019-09-26 17:23:28', 3, NULL, 154.30, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (45, NULL, 115.73, 25, 'A', 68, 13, '2019-09-26 17:23:50', '2019-09-26 17:23:50', 3, NULL, 154.30, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (46, NULL, 91.95, 25, 'A', 69, 13, '2019-09-26 17:29:11', '2019-09-26 17:29:11', 3, NULL, 122.60, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (47, NULL, 115.65, 25, 'A', 70, 13, '2019-09-26 17:32:17', '2019-09-26 17:32:17', 3, NULL, 154.20, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (48, NULL, 57.53, 25, 'A', 71, 13, '2019-09-26 17:34:28', '2019-09-26 17:34:28', 3, NULL, 76.70, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (49, NULL, 66.97, 25, 'A', 72, 13, '2019-09-26 17:40:17', '2019-09-26 17:40:17', 3, NULL, 89.30, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (50, NULL, 57.22, 25, 'A', 3, 13, '2019-09-26 18:00:30', '2019-09-26 18:00:30', 3, NULL, 76.30, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (52, NULL, 115.73, 25, 'A', 73, 13, '2019-09-26 18:14:00', '2019-09-26 18:14:00', 3, NULL, 154.30, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (54, NULL, 16.73, 25, 'A', 75, 13, '2019-09-26 18:18:57', '2019-09-26 18:18:57', 3, NULL, 22.30, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (57, NULL, 40.72, 25, 'A', 76, 13, '2019-09-26 22:21:54', '2019-09-26 22:21:54', 3, NULL, 54.30, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (67, NULL, 191.55, 25, 'A', 6, 13, '2019-09-27 18:47:23', '2019-09-27 18:47:23', 3, NULL, 255.40, NULL, false, NULL);
INSERT INTO public.venta_productos VALUES (66, NULL, 112.05, 25, 'P', 4, 13, '2019-09-27 11:37:29', '2019-09-27 11:37:29', 3, NULL, 149.40, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (60, NULL, 204.45, 25, 'P', 78, 13, '2019-09-26 22:38:20', '2019-09-30 10:53:05', 3, NULL, 272.60, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (63, NULL, 83.40, 25, 'P', 59, 13, '2019-09-26 22:57:36', '2019-09-30 10:53:39', 3, NULL, 111.20, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (64, NULL, 253.42, 25, 'P', 80, NULL, '2019-09-26 23:02:54', '2019-09-26 23:02:54', 3, 2, 337.90, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (68, NULL, 4.13, 25, 'A', 8, 13, '2019-09-29 21:04:49', '2019-09-29 21:04:49', 3, NULL, 5.50, NULL, false, NULL);
INSERT INTO public.venta_productos VALUES (51, NULL, 74.03, 25, 'P', 3, 13, '2019-09-26 18:08:07', '2019-09-30 10:54:25', 3, NULL, 98.70, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (62, NULL, 97.73, 25, 'P', 7, 13, '2019-09-26 22:48:21', '2019-09-30 11:34:42', 3, NULL, 130.30, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (458, 5, 137.00, 0, 'P', 122, NULL, '2019-11-06 15:53:19', '2019-11-06 15:55:54', 18, 11, 137.00, 33, false, NULL);
INSERT INTO public.venta_productos VALUES (61, NULL, 122.02, 25, 'P', 79, 13, '2019-09-26 22:43:13', '2019-09-30 15:07:33', 3, NULL, 162.70, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (36, NULL, 224.55, 25, 'P', 59, 13, '2019-09-26 16:10:27', '2019-09-30 15:33:28', 3, NULL, 299.40, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (59, NULL, 115.73, 25, 'P', 4, 13, '2019-09-26 22:35:13', '2019-09-30 15:41:07', 3, NULL, 154.30, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (53, NULL, 0.00, 25, 'P', 74, 13, '2019-09-26 18:18:02', '2019-09-30 15:55:49', 3, NULL, 0.00, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (58, NULL, 182.32, 25, 'P', 77, 13, '2019-09-26 22:23:47', '2019-09-30 17:14:40', 3, NULL, 243.10, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (55, NULL, 66.68, 25, 'P', 1, 13, '2019-09-26 18:30:04', '2019-09-30 17:29:10', 3, NULL, 88.90, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (69, NULL, 57.45, 25, 'A', 1, 13, '2019-09-30 17:52:05', '2019-09-30 17:52:05', 3, NULL, 76.60, NULL, false, NULL);
INSERT INTO public.venta_productos VALUES (70, NULL, 66.68, 25, 'A', 1, 13, '2019-09-30 18:25:11', '2019-09-30 18:25:11', 3, NULL, 88.90, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (71, NULL, 132.45, 25, 'P', 81, 13, '2019-09-30 18:42:30', '2019-09-30 18:47:24', 3, NULL, 176.60, 13, false, NULL);
INSERT INTO public.venta_productos VALUES (72, NULL, 78.30, 25, 'P', 82, 13, '2019-09-30 21:48:24', '2019-10-01 06:58:26', 3, NULL, 104.40, 13, false, NULL);
INSERT INTO public.venta_productos VALUES (73, NULL, 208.50, 25, 'P', 15, 13, '2019-10-01 07:19:04', '2019-10-01 07:52:01', 3, NULL, 278.00, 13, false, NULL);
INSERT INTO public.venta_productos VALUES (74, NULL, 115.95, 25, 'P', 6, 13, '2019-10-01 09:27:11', '2019-10-01 11:25:38', 3, NULL, 154.60, 13, false, NULL);
INSERT INTO public.venta_productos VALUES (77, NULL, 91.65, 25, 'P', 39, 13, '2019-10-01 11:24:42', '2019-10-01 11:28:12', 3, NULL, 122.20, 13, false, NULL);
INSERT INTO public.venta_productos VALUES (78, NULL, 57.53, 25, 'P', 26, 13, '2019-10-01 11:24:56', '2019-10-01 12:03:20', 3, NULL, 76.70, 13, false, NULL);
INSERT INTO public.venta_productos VALUES (76, NULL, 69.82, 25, 'P', 17, 13, '2019-10-01 11:24:15', '2019-10-01 22:01:22', 3, NULL, 93.10, 13, false, NULL);
INSERT INTO public.venta_productos VALUES (86, NULL, 74.03, 25, 'P', 1, 13, '2019-10-01 18:35:57', '2019-10-01 18:38:14', 3, NULL, 98.70, 13, false, NULL);
INSERT INTO public.venta_productos VALUES (87, NULL, 41.70, 25, 'P', 6, 13, '2019-10-01 18:40:05', '2019-10-01 18:40:59', 3, NULL, 55.60, 13, false, NULL);
INSERT INTO public.venta_productos VALUES (88, NULL, 132.38, 25, 'P', 11, 13, '2019-10-01 18:48:27', '2019-10-01 18:49:36', 3, NULL, 176.50, 13, false, NULL);
INSERT INTO public.venta_productos VALUES (89, NULL, 66.90, 25, 'P', 83, 13, '2019-10-01 18:50:25', '2019-10-01 18:52:18', 3, NULL, 89.20, 13, false, NULL);
INSERT INTO public.venta_productos VALUES (90, NULL, 99.90, 25, 'P', 2, 13, '2019-10-01 18:56:54', '2019-10-01 18:57:18', 3, NULL, 133.20, 13, false, NULL);
INSERT INTO public.venta_productos VALUES (91, NULL, 91.65, 25, 'P', 82, 13, '2019-10-01 18:58:16', '2019-10-01 18:58:30', 3, NULL, 122.20, 13, false, NULL);
INSERT INTO public.venta_productos VALUES (80, NULL, 98.93, 25, 'P', 4, 13, '2019-10-01 12:55:32', '2019-10-01 18:59:27', 3, NULL, 131.90, 13, false, NULL);
INSERT INTO public.venta_productos VALUES (79, NULL, 57.53, 25, 'P', 4, 13, '2019-10-01 12:52:35', '2019-10-01 22:00:51', 3, NULL, 76.70, 13, false, NULL);
INSERT INTO public.venta_productos VALUES (81, NULL, 66.68, 25, 'P', 1, 13, '2019-10-01 12:57:52', '2019-10-01 22:01:37', 3, NULL, 88.90, 13, false, NULL);
INSERT INTO public.venta_productos VALUES (82, NULL, 132.45, 25, 'P', 6, 13, '2019-10-01 18:25:16', '2019-10-01 22:01:51', 3, NULL, 176.60, 13, false, NULL);
INSERT INTO public.venta_productos VALUES (83, NULL, 33.22, 25, 'P', 10, 13, '2019-10-01 18:27:30', '2019-10-01 22:02:19', 3, NULL, 44.30, 13, false, NULL);
INSERT INTO public.venta_productos VALUES (84, NULL, 99.15, 25, 'P', 9, 13, '2019-10-01 18:30:34', '2019-10-01 22:02:28', 3, NULL, 132.20, 13, false, NULL);
INSERT INTO public.venta_productos VALUES (85, NULL, 132.45, 25, 'P', 1, 13, '2019-10-01 18:32:28', '2019-10-01 22:02:41', 3, NULL, 176.60, 13, false, NULL);
INSERT INTO public.venta_productos VALUES (92, NULL, 87.53, 25, 'P', 4, 13, '2019-10-01 23:24:39', '2019-10-01 23:25:02', 3, NULL, 116.70, 13, false, NULL);
INSERT INTO public.venta_productos VALUES (94, NULL, 16.73, 25, 'P', 7, 13, '2019-10-01 23:31:54', '2019-10-01 23:32:32', 3, NULL, 22.30, 13, false, NULL);
INSERT INTO public.venta_productos VALUES (96, NULL, 104.10, 25, 'P', 3, 13, '2019-10-01 23:37:31', '2019-10-01 23:38:04', 3, NULL, 138.80, 13, false, NULL);
INSERT INTO public.venta_productos VALUES (98, NULL, 104.25, 25, 'P', 21, 13, '2019-10-02 08:54:37', '2019-10-02 08:55:18', 3, NULL, 139.00, 14, false, NULL);
INSERT INTO public.venta_productos VALUES (100, NULL, 90.68, 25, 'A', 6, 13, '2019-10-02 09:20:17', '2019-10-02 09:20:17', 3, NULL, 120.90, 14, false, NULL);
INSERT INTO public.venta_productos VALUES (102, NULL, 115.65, 25, 'A', 11, 13, '2019-10-02 09:30:51', '2019-10-02 09:30:51', 3, NULL, 154.20, 14, false, NULL);
INSERT INTO public.venta_productos VALUES (104, NULL, 4.13, 25, 'A', 84, 13, '2019-10-02 09:59:11', '2019-10-02 09:59:11', 3, NULL, 5.50, 14, false, NULL);
INSERT INTO public.venta_productos VALUES (106, NULL, 165.82, 25, 'A', 6, 13, '2019-10-02 10:06:19', '2019-10-02 10:06:19', 3, NULL, 221.10, 14, false, NULL);
INSERT INTO public.venta_productos VALUES (108, NULL, 87.53, 25, 'P', 7, 13, '2019-10-02 10:13:39', '2019-10-02 10:15:42', 3, NULL, 116.70, 14, false, NULL);
INSERT INTO public.venta_productos VALUES (110, NULL, 143.70, 25, 'P', 11, 13, '2019-10-02 11:51:14', '2019-10-02 11:51:33', 3, NULL, 191.60, 14, false, NULL);
INSERT INTO public.venta_productos VALUES (112, NULL, 78.60, 25, 'P', 8, 13, '2019-10-02 12:13:54', '2019-10-02 12:14:08', 3, NULL, 104.80, 14, false, NULL);
INSERT INTO public.venta_productos VALUES (114, NULL, 27.75, 25, 'P', 9, 13, '2019-10-02 18:18:40', '2019-10-02 18:19:02', 3, NULL, 37.00, 14, false, NULL);
INSERT INTO public.venta_productos VALUES (115, NULL, 17.63, 25, 'P', 6, 13, '2019-10-02 19:01:59', '2019-10-02 19:02:17', 3, NULL, 23.50, 14, false, NULL);
INSERT INTO public.venta_productos VALUES (116, NULL, 8.00, 0, 'P', 11, 13, '2019-10-03 07:13:10', '2019-10-03 07:13:34', 3, NULL, 8.00, 14, false, NULL);
INSERT INTO public.venta_productos VALUES (117, NULL, 57.50, 0, 'P', 6, 13, '2019-10-03 09:17:26', '2019-10-03 09:17:26', 3, NULL, 57.50, 14, false, NULL);
INSERT INTO public.venta_productos VALUES (118, NULL, 57.50, 0, 'P', 6, 13, '2019-10-03 09:18:18', '2019-10-03 09:18:18', 3, NULL, 57.50, 14, false, NULL);
INSERT INTO public.venta_productos VALUES (119, NULL, 73.00, 0, 'P', 6, 13, '2019-10-03 09:27:11', '2019-10-03 09:27:11', 3, NULL, 73.00, 14, false, NULL);
INSERT INTO public.venta_productos VALUES (120, NULL, 70.50, 0, 'P', 8, 13, '2019-10-03 09:35:08', '2019-10-03 09:35:08', 3, NULL, 70.50, 14, false, NULL);
INSERT INTO public.venta_productos VALUES (121, NULL, 115.00, 0, 'P', 85, 13, '2019-10-03 10:01:40', '2019-10-03 10:01:40', 3, NULL, 115.00, 15, false, NULL);
INSERT INTO public.venta_productos VALUES (122, NULL, 59.00, 0, 'P', 1, 13, '2019-10-03 10:16:04', '2019-10-03 10:16:04', 3, NULL, 59.00, 15, false, NULL);
INSERT INTO public.venta_productos VALUES (123, NULL, 57.50, 0, 'P', 3, 13, '2019-10-03 10:21:55', '2019-10-03 10:21:55', 3, NULL, 57.50, 15, false, NULL);
INSERT INTO public.venta_productos VALUES (124, NULL, 7.00, 0, 'P', 4, 13, '2019-10-03 10:22:48', '2019-10-03 10:22:48', 3, NULL, 7.00, 15, false, NULL);
INSERT INTO public.venta_productos VALUES (125, NULL, 4.00, 0, 'P', 7, 13, '2019-10-03 10:24:45', '2019-10-03 10:24:45', 3, NULL, 4.00, 15, false, NULL);
INSERT INTO public.venta_productos VALUES (126, NULL, 56.50, 0, 'P', 22, 13, '2019-10-03 10:26:15', '2019-10-03 10:26:15', 3, NULL, 56.50, 15, false, NULL);
INSERT INTO public.venta_productos VALUES (127, NULL, 19.50, 0, 'P', 7, 13, '2019-10-03 10:30:27', '2019-10-03 10:30:27', 3, NULL, 19.50, 15, false, NULL);
INSERT INTO public.venta_productos VALUES (128, NULL, 4.00, 0, 'P', 86, 13, '2019-10-03 10:31:07', '2019-10-03 10:31:07', 3, NULL, 4.00, 15, false, NULL);
INSERT INTO public.venta_productos VALUES (129, NULL, 113.00, 0, 'P', 10, 13, '2019-10-03 10:34:02', '2019-10-03 10:34:02', 3, NULL, 113.00, 15, false, NULL);
INSERT INTO public.venta_productos VALUES (131, NULL, 57.50, 0, 'P', 6, 13, '2019-10-03 10:58:49', '2019-10-03 10:58:49', 3, NULL, 57.50, 15, false, NULL);
INSERT INTO public.venta_productos VALUES (132, NULL, 131.50, 0, 'P', 87, 13, '2019-10-03 12:25:49', '2019-10-03 12:25:49', 3, NULL, 131.50, 15, false, NULL);
INSERT INTO public.venta_productos VALUES (130, NULL, 18.00, 0, 'P', 7, 13, '2019-10-03 10:38:22', '2019-10-03 12:29:36', 3, NULL, 18.00, 15, false, NULL);
INSERT INTO public.venta_productos VALUES (134, NULL, 134.50, 0, 'P', 89, 13, '2019-10-03 12:33:26', '2019-10-03 12:33:26', 3, NULL, 134.50, 15, false, NULL);
INSERT INTO public.venta_productos VALUES (133, NULL, 7.50, 0, 'P', 88, 13, '2019-10-03 12:27:59', '2019-10-03 12:35:18', 3, NULL, 7.50, 15, false, NULL);
INSERT INTO public.venta_productos VALUES (209, NULL, 57.50, 0, 'P', 33, NULL, '2019-10-12 15:14:02', '2019-10-12 21:47:52', 3, 8, 57.50, 21, false, NULL);
INSERT INTO public.venta_productos VALUES (136, NULL, 33.00, 0, 'P', 90, 13, '2019-10-03 17:26:44', '2019-10-03 17:26:44', 3, NULL, 33.00, 15, false, NULL);
INSERT INTO public.venta_productos VALUES (135, NULL, 48.00, 0, 'P', 22, 13, '2019-10-03 17:09:09', '2019-10-03 17:36:42', 3, NULL, 48.00, 15, false, NULL);
INSERT INTO public.venta_productos VALUES (138, NULL, 26.50, 0, 'P', 2, 13, '2019-10-03 18:00:40', '2019-10-03 18:00:40', 3, NULL, 26.50, 15, false, NULL);
INSERT INTO public.venta_productos VALUES (137, NULL, 8.00, 0, 'P', 3, 13, '2019-10-03 17:58:45', '2019-10-03 18:04:27', 3, NULL, 8.00, 15, false, NULL);
INSERT INTO public.venta_productos VALUES (141, NULL, 161.80, 0, 'P', 10, 13, '2019-10-03 18:07:19', '2019-10-03 18:07:19', 3, NULL, 161.80, 15, false, NULL);
INSERT INTO public.venta_productos VALUES (140, NULL, 118.10, 0, 'P', 91, 13, '2019-10-03 18:06:30', '2019-10-03 18:48:50', 3, NULL, 118.10, 15, false, NULL);
INSERT INTO public.venta_productos VALUES (139, NULL, 20.00, 0, 'P', 7, 13, '2019-10-03 18:05:22', '2019-10-03 18:48:33', 3, NULL, 20.00, 15, false, NULL);
INSERT INTO public.venta_productos VALUES (142, NULL, 149.00, 0, 'P', 92, 13, '2019-10-03 18:08:49', '2019-10-03 18:49:03', 3, NULL, 149.00, 15, false, NULL);
INSERT INTO public.venta_productos VALUES (143, NULL, 70.00, 0, 'P', 5, 13, '2019-10-03 18:52:33', '2019-10-03 18:52:33', 3, NULL, 70.00, 15, false, NULL);
INSERT INTO public.venta_productos VALUES (144, NULL, 51.00, 0, 'P', 23, 13, '2019-10-04 09:50:29', '2019-10-04 09:51:59', 3, NULL, 51.00, 16, false, NULL);
INSERT INTO public.venta_productos VALUES (145, NULL, 47.60, 0, 'P', 93, 13, '2019-10-04 09:53:43', '2019-10-04 09:53:43', 3, NULL, 47.60, 16, false, NULL);
INSERT INTO public.venta_productos VALUES (148, NULL, 617.30, 0, 'P', 4, 13, '2019-10-04 16:04:19', '2019-10-04 16:04:19', 3, NULL, 617.30, 17, false, NULL);
INSERT INTO public.venta_productos VALUES (149, NULL, 68.00, 0, 'P', 4, 13, '2019-10-04 16:05:31', '2019-10-04 16:08:10', 3, NULL, 68.00, 17, false, NULL);
INSERT INTO public.venta_productos VALUES (146, NULL, 13.00, 0, 'P', 31, 13, '2019-10-04 15:22:04', '2019-10-04 16:08:30', 3, NULL, 13.00, 17, false, NULL);
INSERT INTO public.venta_productos VALUES (147, NULL, 66.50, 0, 'P', 6, 13, '2019-10-04 15:55:06', '2019-10-04 16:08:41', 3, NULL, 66.50, 17, false, NULL);
INSERT INTO public.venta_productos VALUES (150, NULL, 121.00, 0, 'P', 11, 13, '2019-10-04 16:12:41', '2019-10-04 16:12:41', 3, NULL, 121.00, 17, false, NULL);
INSERT INTO public.venta_productos VALUES (151, NULL, 109.00, 0, 'P', 6, 13, '2019-10-04 16:14:57', '2019-10-04 16:14:57', 3, NULL, 109.00, 17, false, NULL);
INSERT INTO public.venta_productos VALUES (153, NULL, 15.00, 0, 'P', 7, 13, '2019-10-04 16:22:06', '2019-10-04 16:35:15', 3, NULL, 15.00, 17, false, NULL);
INSERT INTO public.venta_productos VALUES (152, NULL, 24.00, 0, 'P', 6, 13, '2019-10-04 16:21:36', '2019-10-04 16:35:28', 3, NULL, 24.00, 17, false, NULL);
INSERT INTO public.venta_productos VALUES (154, NULL, 97.80, 0, 'P', 1, 13, '2019-10-05 06:38:40', '2019-10-05 06:38:40', 3, NULL, 97.80, 17, false, NULL);
INSERT INTO public.venta_productos VALUES (158, NULL, 75.00, 0, 'P', 7, 13, '2019-10-05 06:44:46', '2019-10-05 06:44:46', 3, NULL, 75.00, 17, false, NULL);
INSERT INTO public.venta_productos VALUES (159, NULL, 183.50, 0, 'P', 4, 13, '2019-10-05 06:45:24', '2019-10-05 06:45:24', 3, NULL, 183.50, 17, false, NULL);
INSERT INTO public.venta_productos VALUES (169, NULL, 75.00, 0, 'P', 6, 13, '2019-10-05 09:34:43', '2019-10-05 09:34:43', 3, NULL, 75.00, 17, false, NULL);
INSERT INTO public.venta_productos VALUES (171, NULL, 29.00, 0, 'P', 95, 13, '2019-10-05 09:36:35', '2019-10-05 09:36:35', 3, NULL, 29.00, 17, false, NULL);
INSERT INTO public.venta_productos VALUES (179, NULL, 36.00, 0, 'P', 97, 17, '2019-10-05 19:57:42', '2019-10-05 19:59:25', 15, NULL, 36.00, 20, false, NULL);
INSERT INTO public.venta_productos VALUES (172, NULL, 60.50, 0, 'P', 96, NULL, '2019-10-05 09:37:30', '2019-10-05 12:23:18', 3, 8, 60.50, 17, false, NULL);
INSERT INTO public.venta_productos VALUES (170, NULL, 64.00, 0, 'P', 9, 13, '2019-10-05 09:35:40', '2019-10-05 12:23:35', 3, NULL, 64.00, 17, false, NULL);
INSERT INTO public.venta_productos VALUES (168, NULL, 25.50, 0, 'P', 6, NULL, '2019-10-05 09:32:45', '2019-10-05 12:23:45', 3, 8, 25.50, 17, false, NULL);
INSERT INTO public.venta_productos VALUES (167, NULL, 59.00, 0, 'P', 6, NULL, '2019-10-05 09:20:07', '2019-10-05 12:23:58', 3, 8, 59.00, 17, false, NULL);
INSERT INTO public.venta_productos VALUES (166, NULL, 64.00, 0, 'P', 6, NULL, '2019-10-05 09:16:29', '2019-10-05 12:24:08', 3, 8, 64.00, 17, false, NULL);
INSERT INTO public.venta_productos VALUES (165, NULL, 75.00, 0, 'P', 1, NULL, '2019-10-05 09:13:27', '2019-10-05 12:24:17', 3, 8, 75.00, 17, false, NULL);
INSERT INTO public.venta_productos VALUES (164, NULL, 78.00, 0, 'P', 94, NULL, '2019-10-05 08:42:09', '2019-10-05 12:24:29', 3, 8, 78.00, 17, false, NULL);
INSERT INTO public.venta_productos VALUES (163, NULL, 57.50, 0, 'P', 3, NULL, '2019-10-05 08:41:15', '2019-10-05 12:24:41', 3, 8, 57.50, 17, false, NULL);
INSERT INTO public.venta_productos VALUES (162, NULL, 57.50, 0, 'P', 3, NULL, '2019-10-05 08:39:14', '2019-10-05 12:24:51', 3, 8, 57.50, 17, false, NULL);
INSERT INTO public.venta_productos VALUES (161, NULL, 18.50, 0, 'P', 6, NULL, '2019-10-05 08:37:36', '2019-10-05 12:25:03', 3, 8, 18.50, 17, false, NULL);
INSERT INTO public.venta_productos VALUES (160, NULL, 2.50, 0, 'P', 2, NULL, '2019-10-05 08:36:25', '2019-10-05 12:25:14', 3, 8, 2.50, 17, false, NULL);
INSERT INTO public.venta_productos VALUES (157, NULL, 75.00, 0, 'P', 7, 13, '2019-10-05 06:44:10', '2019-10-05 12:25:30', 3, NULL, 75.00, 17, false, NULL);
INSERT INTO public.venta_productos VALUES (156, NULL, 62.80, 0, 'P', 7, 13, '2019-10-05 06:43:22', '2019-10-05 12:25:41', 3, NULL, 62.80, 17, false, NULL);
INSERT INTO public.venta_productos VALUES (155, NULL, 86.50, 0, 'P', 26, 13, '2019-10-05 06:43:02', '2019-10-05 12:25:53', 3, NULL, 86.50, 17, false, NULL);
INSERT INTO public.venta_productos VALUES (176, NULL, 121.00, 0, 'P', 8, 16, '2019-10-05 12:34:29', '2019-10-05 12:34:29', 3, NULL, 121.00, 19, false, NULL);
INSERT INTO public.venta_productos VALUES (173, NULL, 56.50, 0, 'P', 2, NULL, '2019-10-05 12:31:46', '2019-10-05 13:01:19', 3, 8, 56.50, 19, false, NULL);
INSERT INTO public.venta_productos VALUES (181, NULL, 90.00, 0, 'P', 98, NULL, '2019-10-05 20:00:23', '2019-10-05 20:01:27', 15, 9, 90.00, 20, false, NULL);
INSERT INTO public.venta_productos VALUES (182, NULL, 36.00, 0, 'P', 99, 17, '2019-10-05 20:02:26', '2019-10-05 20:02:26', 15, NULL, 36.00, 20, false, NULL);
INSERT INTO public.venta_productos VALUES (180, NULL, 18.00, 0, 'P', 98, NULL, '2019-10-05 19:58:50', '2019-10-05 20:03:21', 15, 9, 18.00, 20, false, NULL);
INSERT INTO public.venta_productos VALUES (185, NULL, 74.00, 0, 'P', 98, 17, '2019-10-05 20:36:00', '2019-10-05 20:36:00', 15, NULL, 74.00, 20, false, NULL);
INSERT INTO public.venta_productos VALUES (183, NULL, 36.00, 0, 'P', 100, NULL, '2019-10-05 20:18:07', '2019-10-05 20:37:51', 15, 9, 36.00, 20, false, NULL);
INSERT INTO public.venta_productos VALUES (184, NULL, 10.00, 0, 'P', 98, NULL, '2019-10-05 20:18:51', '2019-10-05 20:38:18', 15, 9, 10.00, 20, false, NULL);
INSERT INTO public.venta_productos VALUES (187, NULL, 21.50, 0, 'P', 6, 13, '2019-10-07 10:03:07', '2019-10-07 10:03:07', 3, NULL, 21.50, 18, false, NULL);
INSERT INTO public.venta_productos VALUES (188, NULL, 32.50, 0, 'P', 5, 13, '2019-10-07 10:04:28', '2019-10-07 10:04:28', 3, NULL, 32.50, 18, false, NULL);
INSERT INTO public.venta_productos VALUES (189, NULL, 14.00, 0, 'P', 7, 13, '2019-10-07 16:26:42', '2019-10-07 16:26:42', 3, NULL, 14.00, 18, false, NULL);
INSERT INTO public.venta_productos VALUES (192, NULL, 112.00, 0, 'P', 6, 13, '2019-10-09 10:28:17', '2019-10-09 10:28:17', 3, NULL, 112.00, 18, false, NULL);
INSERT INTO public.venta_productos VALUES (190, NULL, 107.50, 0, 'P', 4, NULL, '2019-10-07 18:07:44', '2019-10-09 10:28:42', 3, 8, 107.50, 18, false, NULL);
INSERT INTO public.venta_productos VALUES (178, NULL, 30.00, 0, 'P', 4, NULL, '2019-10-05 14:35:21', '2019-10-09 10:29:37', 3, 8, 30.00, 18, false, NULL);
INSERT INTO public.venta_productos VALUES (175, NULL, 15.50, 0, 'P', 22, 13, '2019-10-05 12:33:22', '2019-10-09 10:29:47', 3, NULL, 15.50, 18, false, NULL);
INSERT INTO public.venta_productos VALUES (174, NULL, 3.00, 0, 'P', 7, NULL, '2019-10-05 12:32:42', '2019-10-09 10:29:57', 3, 8, 3.00, 18, false, NULL);
INSERT INTO public.venta_productos VALUES (193, NULL, 14.50, 0, 'P', 3, 13, '2019-10-09 10:35:55', '2019-10-09 10:35:55', 3, NULL, 14.50, 21, false, NULL);
INSERT INTO public.venta_productos VALUES (194, NULL, 104.50, 0, 'P', 85, 13, '2019-10-09 10:38:27', '2019-10-09 10:38:27', 3, NULL, 104.50, 21, false, NULL);
INSERT INTO public.venta_productos VALUES (280, NULL, 64.50, 0, 'A', 6, 13, '2019-10-16 09:39:21', '2019-10-16 09:39:21', 3, NULL, 64.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (195, NULL, 40.50, 0, 'P', 52, 13, '2019-10-09 10:51:39', '2019-10-09 10:51:39', 3, NULL, 40.50, 21, false, NULL);
INSERT INTO public.venta_productos VALUES (177, NULL, 70.00, 0, 'P', 69, NULL, '2019-10-05 13:02:18', '2019-10-09 11:32:52', 3, 8, 70.00, 19, false, NULL);
INSERT INTO public.venta_productos VALUES (191, NULL, 117.00, 0, 'P', 7, NULL, '2019-10-07 18:41:53', '2019-10-09 11:33:05', 3, 8, 117.00, 19, false, NULL);
INSERT INTO public.venta_productos VALUES (197, NULL, 59.00, 0, 'P', 4, NULL, '2019-10-09 11:39:00', '2019-10-09 11:39:38', 3, 8, 59.00, 22, false, NULL);
INSERT INTO public.venta_productos VALUES (199, NULL, 724.30, 0, 'P', 7, 16, '2019-10-09 12:21:31', '2019-10-09 12:21:31', 3, NULL, 724.30, 22, false, NULL);
INSERT INTO public.venta_productos VALUES (198, NULL, 26.00, 0, 'P', 4, NULL, '2019-10-09 11:43:47', '2019-10-09 12:25:36', 3, 8, 26.00, 22, false, NULL);
INSERT INTO public.venta_productos VALUES (200, NULL, 118.00, 0, 'P', 96, 16, '2019-10-09 12:57:35', '2019-10-09 12:57:56', 3, NULL, 118.00, 22, false, NULL);
INSERT INTO public.venta_productos VALUES (202, NULL, 177.00, 0, 'P', 1, 16, '2019-10-09 13:47:25', '2019-10-09 13:47:25', 3, NULL, 177.00, 22, false, NULL);
INSERT INTO public.venta_productos VALUES (201, NULL, 2.50, 0, 'P', 4, NULL, '2019-10-09 13:02:58', '2019-10-09 13:47:53', 3, 8, 2.50, 22, false, NULL);
INSERT INTO public.venta_productos VALUES (203, NULL, 18.50, 0, 'A', 6, 16, '2019-10-09 13:49:26', '2019-10-09 13:49:26', 3, NULL, 18.50, 22, false, NULL);
INSERT INTO public.venta_productos VALUES (205, NULL, 15.00, 0, 'P', 1, 13, '2019-10-12 10:34:57', '2019-10-12 10:34:57', 3, NULL, 15.00, 21, false, NULL);
INSERT INTO public.venta_productos VALUES (206, NULL, 63.00, 0, 'A', 4, NULL, '2019-10-12 10:39:23', '2019-10-12 10:39:23', 3, 8, 63.00, 22, false, NULL);
INSERT INTO public.venta_productos VALUES (208, NULL, 75.50, 0, 'P', 3, 13, '2019-10-12 15:12:51', '2019-10-12 15:12:51', 3, NULL, 75.50, 21, false, NULL);
INSERT INTO public.venta_productos VALUES (210, NULL, 86.50, 0, 'P', 4, 13, '2019-10-12 21:36:11', '2019-10-12 21:36:11', 3, NULL, 86.50, 21, false, NULL);
INSERT INTO public.venta_productos VALUES (207, NULL, 23.00, 0, 'P', 101, NULL, '2019-10-12 10:41:45', '2019-10-12 21:48:14', 3, 8, 23.00, 21, false, NULL);
INSERT INTO public.venta_productos VALUES (204, NULL, 210.50, 0, 'P', 7, 13, '2019-10-09 18:44:38', '2019-10-12 21:48:30', 3, NULL, 210.50, 21, false, NULL);
INSERT INTO public.venta_productos VALUES (196, NULL, 57.50, 0, 'P', 4, NULL, '2019-10-09 10:53:31', '2019-10-12 21:48:40', 3, 8, 57.50, 21, false, NULL);
INSERT INTO public.venta_productos VALUES (211, NULL, 67.00, 0, 'P', 1, 13, '2019-10-12 21:47:37', '2019-10-12 21:48:03', 3, NULL, 67.00, 21, false, NULL);
INSERT INTO public.venta_productos VALUES (212, NULL, 16.00, 0, 'P', 6, 13, '2019-10-13 09:36:02', '2019-10-13 09:36:02', 3, NULL, 16.00, 21, false, NULL);
INSERT INTO public.venta_productos VALUES (213, NULL, 69.50, 0, 'A', 3, 13, '2019-10-13 11:47:30', '2019-10-13 11:47:30', 3, NULL, 69.50, 21, false, NULL);
INSERT INTO public.venta_productos VALUES (214, NULL, 66.50, 0, 'A', 6, 13, '2019-10-13 18:18:06', '2019-10-13 18:18:06', 3, NULL, 66.50, 21, false, NULL);
INSERT INTO public.venta_productos VALUES (215, NULL, 72.50, 0, 'P', 4, 13, '2019-10-13 18:19:29', '2019-10-13 18:19:29', 3, NULL, 72.50, 21, false, NULL);
INSERT INTO public.venta_productos VALUES (216, NULL, 75.50, 0, 'P', 3, 13, '2019-10-13 18:24:26', '2019-10-13 18:24:26', 3, NULL, 75.50, 21, false, NULL);
INSERT INTO public.venta_productos VALUES (217, NULL, 23.00, 0, 'A', 2, 13, '2019-10-13 18:24:56', '2019-10-13 18:24:56', 3, NULL, 23.00, 21, false, NULL);
INSERT INTO public.venta_productos VALUES (218, NULL, 24.00, 0, 'A', 1, 13, '2019-10-13 18:33:37', '2019-10-13 18:33:37', 3, NULL, 24.00, 21, false, NULL);
INSERT INTO public.venta_productos VALUES (219, NULL, 67.00, 0, 'A', 6, 13, '2019-10-13 18:34:48', '2019-10-13 18:34:48', 3, NULL, 67.00, 21, false, NULL);
INSERT INTO public.venta_productos VALUES (220, NULL, 74.00, 0, 'A', 4, 13, '2019-10-13 18:44:44', '2019-10-13 18:44:44', 3, NULL, 74.00, 21, false, NULL);
INSERT INTO public.venta_productos VALUES (221, NULL, 59.00, 0, 'A', 1, 13, '2019-10-13 19:08:18', '2019-10-13 19:08:18', 3, NULL, 59.00, 21, false, NULL);
INSERT INTO public.venta_productos VALUES (222, NULL, 75.50, 0, 'A', 4, 13, '2019-10-13 19:11:42', '2019-10-13 19:11:42', 3, NULL, 75.50, 21, false, NULL);
INSERT INTO public.venta_productos VALUES (226, NULL, 72.80, 0, 'P', 8, 13, '2019-10-14 12:56:51', '2019-10-14 12:56:51', 3, NULL, 72.80, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (227, NULL, 15.00, 0, 'P', 4, 13, '2019-10-14 12:59:43', '2019-10-14 12:59:43', 3, NULL, 15.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (228, NULL, 593.30, 0, 'P', 103, 13, '2019-10-14 13:03:07', '2019-10-14 13:03:07', 3, NULL, 593.30, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (225, NULL, 32.50, 0, 'P', 60, 13, '2019-10-14 12:55:59', '2019-10-14 13:05:21', 3, NULL, 32.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (224, NULL, 68.00, 0, 'P', 6, 13, '2019-10-14 10:56:32', '2019-10-14 13:05:31', 3, NULL, 68.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (223, NULL, 80.50, 0, 'P', 102, 13, '2019-10-14 09:44:31', '2019-10-14 13:05:42', 3, NULL, 80.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (229, NULL, 173.00, 0, 'P', 24, 13, '2019-10-14 17:20:41', '2019-10-14 17:21:23', 3, NULL, 173.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (230, NULL, 116.00, 0, 'P', 101, 13, '2019-10-14 18:43:53', '2019-10-14 18:44:20', 3, NULL, 116.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (235, NULL, 78.00, 0, 'P', 10, 13, '2019-10-15 09:57:40', '2019-10-15 09:57:40', 3, NULL, 78.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (236, NULL, 24.00, 0, 'P', 8, 13, '2019-10-15 09:58:46', '2019-10-15 10:26:18', 3, NULL, 24.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (237, NULL, 33.50, 0, 'P', 6, 13, '2019-10-15 10:25:49', '2019-10-15 10:26:30', 3, NULL, 33.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (238, NULL, 71.00, 0, 'P', 18, 13, '2019-10-15 10:28:33', '2019-10-15 10:28:33', 3, NULL, 71.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (234, NULL, 12.00, 0, 'P', 6, 13, '2019-10-15 09:53:59', '2019-10-15 10:53:33', 3, NULL, 12.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (233, NULL, 68.50, 0, 'P', 25, 13, '2019-10-15 09:52:59', '2019-10-15 10:53:47', 3, NULL, 68.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (232, NULL, 59.00, 0, 'P', 4, 13, '2019-10-15 09:14:58', '2019-10-15 10:53:58', 3, NULL, 59.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (231, NULL, 57.50, 0, 'P', 16, 13, '2019-10-15 07:59:39', '2019-10-15 10:54:16', 3, NULL, 57.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (239, NULL, 16.50, 0, 'P', 37, 13, '2019-10-15 11:07:01', '2019-10-15 11:07:01', 3, NULL, 16.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (240, NULL, 78.80, 0, 'P', 5, 13, '2019-10-15 11:09:06', '2019-10-15 11:09:06', 3, NULL, 78.80, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (264, NULL, 57.50, 0, 'A', 1, 13, '2019-10-15 18:26:45', '2019-10-15 18:26:45', 3, NULL, 57.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (265, NULL, 57.50, 0, 'A', 4, 13, '2019-10-15 18:27:33', '2019-10-15 18:27:33', 3, NULL, 57.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (266, NULL, 57.50, 0, 'A', 1, 13, '2019-10-15 18:28:43', '2019-10-15 18:28:43', 3, NULL, 57.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (267, NULL, 57.50, 0, 'A', 1, 13, '2019-10-15 21:33:36', '2019-10-15 21:33:36', 3, NULL, 57.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (268, NULL, 64.00, 0, 'A', 4, 13, '2019-10-16 07:27:24', '2019-10-16 07:27:24', 3, NULL, 64.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (269, NULL, 70.00, 0, 'A', 2, 13, '2019-10-16 07:34:04', '2019-10-16 07:34:04', 3, NULL, 70.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (270, NULL, 57.50, 0, 'A', 3, 13, '2019-10-16 07:40:01', '2019-10-16 07:40:01', 3, NULL, 57.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (271, NULL, 9.50, 0, 'A', 6, 13, '2019-10-16 07:44:59', '2019-10-16 07:44:59', 3, NULL, 9.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (272, NULL, 78.00, 0, 'A', 24, 13, '2019-10-16 07:46:41', '2019-10-16 07:46:41', 3, NULL, 78.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (273, NULL, 14.50, 0, 'A', 36, 13, '2019-10-16 07:48:33', '2019-10-16 07:48:33', 3, NULL, 14.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (274, NULL, 64.50, 0, 'A', 1, 13, '2019-10-16 08:16:50', '2019-10-16 08:16:50', 3, NULL, 64.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (461, 3, 138.00, 0, 'P', NULL, 19, '2019-11-06 16:05:56', '2019-11-22 19:48:58', 17, NULL, 138.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (403, 18, 91.00, 0, 'A', NULL, 19, '2019-10-23 13:53:18', '2019-10-23 13:53:19', 17, NULL, 91.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (275, NULL, 64.50, 0, 'A', 1, 13, '2019-10-16 08:18:31', '2019-10-16 08:18:31', 3, NULL, 64.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (276, NULL, 80.50, 0, 'A', 4, 13, '2019-10-16 08:30:04', '2019-10-16 08:30:04', 3, NULL, 80.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (277, NULL, 101.50, 0, 'A', 76, 13, '2019-10-16 08:34:12', '2019-10-16 08:34:12', 3, NULL, 101.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (278, NULL, 34.00, 0, 'A', 4, 13, '2019-10-16 08:55:05', '2019-10-16 08:55:05', 3, NULL, 34.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (279, NULL, 68.00, 0, 'A', 28, 13, '2019-10-16 09:37:24', '2019-10-16 09:37:24', 3, NULL, 68.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (243, NULL, 70.00, 0, 'P', 6, 13, '2019-10-15 12:50:38', '2019-10-16 10:46:16', 3, NULL, 70.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (244, NULL, 64.00, 0, 'P', 4, 13, '2019-10-15 12:57:08', '2019-10-16 10:46:25', 3, NULL, 64.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (245, NULL, 57.50, 0, 'P', 2, 13, '2019-10-15 12:58:06', '2019-10-16 10:46:36', 3, NULL, 57.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (246, NULL, 57.50, 0, 'P', 1, 13, '2019-10-15 12:59:24', '2019-10-16 10:46:47', 3, NULL, 57.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (247, NULL, 65.50, 0, 'P', 2, 13, '2019-10-15 13:01:30', '2019-10-16 10:46:57', 3, NULL, 65.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (248, NULL, 57.50, 0, 'P', 4, 13, '2019-10-15 13:03:28', '2019-10-16 10:47:06', 3, NULL, 57.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (249, NULL, 57.50, 0, 'P', 6, 13, '2019-10-15 13:05:07', '2019-10-16 10:47:15', 3, NULL, 57.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (250, NULL, 57.50, 0, 'P', 4, 13, '2019-10-15 13:07:25', '2019-10-16 10:47:23', 3, NULL, 57.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (251, NULL, 57.50, 0, 'P', 4, 13, '2019-10-15 13:09:14', '2019-10-16 10:47:31', 3, NULL, 57.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (252, NULL, 70.00, 0, 'P', 4, 13, '2019-10-15 13:12:04', '2019-10-16 10:47:39', 3, NULL, 70.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (253, NULL, 57.50, 0, 'P', 2, 13, '2019-10-15 13:17:41', '2019-10-16 10:47:48', 3, NULL, 57.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (254, NULL, 57.50, 0, 'P', 1, 13, '2019-10-15 14:06:58', '2019-10-16 10:47:58', 3, NULL, 57.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (255, NULL, 57.50, 0, 'P', 4, 13, '2019-10-15 14:08:56', '2019-10-17 16:06:51', 3, NULL, 57.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (256, NULL, 57.50, 0, 'P', 3, 13, '2019-10-15 14:13:06', '2019-10-17 16:08:17', 3, NULL, 57.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (257, NULL, 70.00, 0, 'P', 1, 13, '2019-10-15 14:15:16', '2019-10-17 16:10:02', 3, NULL, 70.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (258, NULL, 63.00, 0, 'P', 4, 13, '2019-10-15 14:17:18', '2019-10-17 16:10:20', 3, NULL, 63.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (259, NULL, 10.50, 0, 'P', 1, 13, '2019-10-15 14:18:32', '2019-10-17 16:15:20', 3, NULL, 10.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (260, NULL, 64.00, 0, 'P', 3, 13, '2019-10-15 17:32:00', '2019-10-17 16:15:27', 3, NULL, 64.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (261, NULL, 14.50, 0, 'P', 6, 13, '2019-10-15 17:37:56', '2019-10-17 16:15:39', 3, NULL, 14.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (262, NULL, 25.50, 0, 'P', 7, 13, '2019-10-15 17:42:00', '2019-10-17 16:16:40', 3, NULL, 25.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (263, NULL, 69.50, 0, 'P', 5, 13, '2019-10-15 17:58:24', '2019-10-17 16:19:48', 3, NULL, 69.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (281, NULL, 25.50, 0, 'A', 5, 13, '2019-10-16 09:41:47', '2019-10-16 09:41:47', 3, NULL, 25.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (282, NULL, 20.50, 0, 'A', 34, 13, '2019-10-16 09:42:48', '2019-10-16 09:42:48', 3, NULL, 20.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (283, NULL, 20.50, 0, 'A', 4, 13, '2019-10-16 09:44:29', '2019-10-16 09:44:29', 3, NULL, 20.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (286, NULL, 25.50, 0, 'P', 9, 13, '2019-10-16 10:43:57', '2019-10-16 10:45:00', 3, NULL, 25.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (285, NULL, 122.00, 0, 'P', 59, 13, '2019-10-16 10:43:09', '2019-10-16 10:45:11', 3, NULL, 122.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (284, NULL, 120.50, 0, 'P', 4, 13, '2019-10-16 09:45:47', '2019-10-16 10:45:23', 3, NULL, 120.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (241, NULL, 68.00, 0, 'P', 3, 13, '2019-10-15 12:40:22', '2019-10-16 10:46:02', 3, NULL, 68.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (242, NULL, 15.00, 0, 'P', 4, 13, '2019-10-15 12:45:18', '2019-10-16 10:46:09', 3, NULL, 15.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (304, NULL, 130.80, 0, 'P', 1, 13, '2019-10-16 17:17:34', '2019-10-16 17:17:34', 3, NULL, 130.80, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (305, NULL, 15.00, 0, 'P', 4, 13, '2019-10-16 17:24:06', '2019-10-16 17:24:06', 3, NULL, 15.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (306, NULL, 68.50, 0, 'P', 3, 13, '2019-10-16 17:27:08', '2019-10-16 17:27:08', 3, NULL, 68.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (307, NULL, 27.00, 0, 'P', 4, 13, '2019-10-16 17:46:36', '2019-10-16 17:46:36', 3, NULL, 27.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (308, NULL, 79.00, 0, 'P', 1, 13, '2019-10-16 17:48:36', '2019-10-16 17:48:36', 3, NULL, 79.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (309, NULL, 49.50, 0, 'P', 4, 13, '2019-10-16 18:21:17', '2019-10-16 18:21:17', 3, NULL, 49.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (310, NULL, 24.00, 0, 'P', 4, 13, '2019-10-16 18:44:07', '2019-10-16 18:44:07', 3, NULL, 24.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (311, NULL, 72.50, 0, 'P', 4, 13, '2019-10-16 18:45:58', '2019-10-16 18:45:58', 3, NULL, 72.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (312, NULL, 107.50, 0, 'P', 3, 13, '2019-10-16 18:48:38', '2019-10-16 18:48:38', 3, NULL, 107.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (313, NULL, 80.50, 0, 'P', 4, 13, '2019-10-16 18:53:49', '2019-10-16 18:53:49', 3, NULL, 80.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (314, NULL, 29.50, 0, 'P', 1, 13, '2019-10-16 18:55:35', '2019-10-16 18:55:35', 3, NULL, 29.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (315, NULL, 72.00, 0, 'P', 71, 13, '2019-10-16 18:57:43', '2019-10-16 18:57:43', 3, NULL, 72.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (316, NULL, 69.50, 0, 'P', 1, 13, '2019-10-16 19:00:33', '2019-10-16 19:00:33', 3, NULL, 69.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (317, NULL, 20.50, 0, 'P', 11, 13, '2019-10-16 22:41:13', '2019-10-16 22:41:13', 3, NULL, 20.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (318, NULL, 13.00, 0, 'P', 3, 13, '2019-10-16 22:45:29', '2019-10-16 22:45:29', 3, NULL, 13.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (319, NULL, 83.00, 0, 'P', 4, 13, '2019-10-16 22:48:01', '2019-10-16 22:48:01', 3, NULL, 83.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (320, NULL, 70.00, 0, 'P', 7, 13, '2019-10-17 07:34:17', '2019-10-17 07:34:17', 3, NULL, 70.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (323, NULL, 68.00, 0, 'P', 7, 13, '2019-10-17 07:41:33', '2019-10-17 07:41:33', 3, NULL, 68.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (326, NULL, 70.00, 0, 'P', 94, 13, '2019-10-17 15:09:03', '2019-10-17 15:09:03', 3, NULL, 70.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (322, NULL, 16.00, 0, 'P', 7, 13, '2019-10-17 07:40:27', '2019-10-17 15:37:00', 3, NULL, 16.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (321, NULL, 16.00, 0, 'P', 4, 13, '2019-10-17 07:38:44', '2019-10-17 15:37:47', 3, NULL, 16.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (300, NULL, 94.00, 0, 'P', 6, 13, '2019-10-16 16:21:41', '2019-10-17 15:39:05', 3, NULL, 94.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (325, NULL, 166.00, 0, 'P', 7, 13, '2019-10-17 11:39:29', '2019-10-17 15:41:51', 3, NULL, 166.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (462, 6, 91.00, 0, 'P', 125, 25, '2019-11-06 17:42:17', '2019-11-06 17:48:58', 18, NULL, 91.00, 33, false, NULL);
INSERT INTO public.venta_productos VALUES (407, 22, 141.00, 0, 'A', NULL, 19, '2019-10-23 14:27:35', '2019-10-23 14:27:38', 17, NULL, 141.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (75, NULL, 57.22, 25, 'P', 4, 13, '2019-10-01 11:23:59', '2019-10-01 22:01:08', 3, NULL, 76.30, 13, false, NULL);
INSERT INTO public.venta_productos VALUES (93, NULL, 8.25, 25, 'P', 7, 13, '2019-10-01 23:26:59', '2019-10-01 23:27:58', 3, NULL, 11.00, 13, false, NULL);
INSERT INTO public.venta_productos VALUES (95, NULL, 49.95, 25, 'P', 27, 13, '2019-10-01 23:34:29', '2019-10-01 23:35:09', 3, NULL, 66.60, 13, false, NULL);
INSERT INTO public.venta_productos VALUES (97, NULL, 165.68, 25, 'P', 7, 13, '2019-10-02 08:46:53', '2019-10-02 08:47:43', 3, NULL, 220.90, 14, false, NULL);
INSERT INTO public.venta_productos VALUES (99, NULL, 150.52, 25, 'A', 8, 13, '2019-10-02 09:16:46', '2019-10-02 09:16:46', 3, NULL, 200.70, 14, false, NULL);
INSERT INTO public.venta_productos VALUES (101, NULL, 70.80, 25, 'P', 6, 13, '2019-10-02 09:22:07', '2019-10-02 09:22:18', 3, NULL, 94.40, 14, false, NULL);
INSERT INTO public.venta_productos VALUES (103, NULL, 132.38, 25, 'P', 7, 13, '2019-10-02 09:57:09', '2019-10-02 09:57:28', 3, NULL, 176.50, 14, false, NULL);
INSERT INTO public.venta_productos VALUES (105, NULL, 112.50, 25, 'P', 9, 13, '2019-10-02 10:01:27', '2019-10-02 10:01:44', 3, NULL, 150.00, 14, false, NULL);
INSERT INTO public.venta_productos VALUES (107, NULL, 83.47, 25, 'P', 7, 13, '2019-10-02 10:09:49', '2019-10-02 10:10:00', 3, NULL, 111.30, 14, false, NULL);
INSERT INTO public.venta_productos VALUES (109, NULL, 62.63, 25, 'A', 6, 13, '2019-10-02 10:18:15', '2019-10-02 10:18:15', 3, NULL, 83.50, 14, false, NULL);
INSERT INTO public.venta_productos VALUES (111, NULL, 13.50, 25, 'P', 7, 13, '2019-10-02 11:57:15', '2019-10-02 11:57:32', 3, NULL, 18.00, 14, false, NULL);
INSERT INTO public.venta_productos VALUES (113, NULL, 6.38, 25, 'P', 33, 13, '2019-10-02 12:19:57', '2019-10-02 12:20:19', 3, NULL, 8.50, 14, false, NULL);
INSERT INTO public.venta_productos VALUES (1, NULL, 0.00, 25, 'A', 15, 13, '2019-09-24 12:20:29', '2019-09-24 12:20:29', 3, NULL, 0.00, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (2, NULL, 0.00, 25, 'A', 16, 13, '2019-09-24 12:23:44', '2019-09-24 12:23:44', 3, NULL, 0.00, 9, false, NULL);
INSERT INTO public.venta_productos VALUES (445, 5, 24.00, 0, 'P', NULL, 13, '2019-11-05 09:56:24', '2019-11-05 09:56:26', 3, NULL, 24.00, 32, false, NULL);
INSERT INTO public.venta_productos VALUES (324, NULL, 224.00, 0, 'P', 3, 13, '2019-10-17 11:12:26', '2019-10-17 15:42:48', 3, NULL, 224.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (303, NULL, 20.00, 0, 'P', 4, 13, '2019-10-16 16:49:10', '2019-10-17 15:45:44', 3, NULL, 20.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (302, NULL, 131.00, 0, 'P', 7, 13, '2019-10-16 16:32:23', '2019-10-17 15:57:10', 3, NULL, 131.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (301, NULL, 94.80, 0, 'P', 4, 13, '2019-10-16 16:28:21', '2019-10-17 15:58:04', 3, NULL, 94.80, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (299, NULL, 18.50, 0, 'P', 67, 13, '2019-10-16 16:14:46', '2019-10-17 16:00:59', 3, NULL, 18.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (287, NULL, 57.50, 0, 'P', 3, 13, '2019-10-16 15:17:18', '2019-10-17 16:10:43', 3, NULL, 57.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (288, NULL, 4.00, 0, 'P', 1, 13, '2019-10-16 15:20:14', '2019-10-17 16:10:53', 3, NULL, 4.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (289, NULL, 67.50, 0, 'P', 3, 13, '2019-10-16 15:31:19', '2019-10-17 16:11:14', 3, NULL, 67.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (290, NULL, 69.50, 0, 'P', 3, 13, '2019-10-16 15:41:37', '2019-10-17 16:11:23', 3, NULL, 69.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (291, NULL, 57.50, 0, 'P', 3, 13, '2019-10-16 15:42:41', '2019-10-17 16:11:31', 3, NULL, 57.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (292, NULL, 67.50, 0, 'P', 1, 13, '2019-10-16 15:43:30', '2019-10-17 16:11:42', 3, NULL, 67.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (293, NULL, 67.50, 0, 'P', 3, 13, '2019-10-16 15:44:52', '2019-10-17 16:11:53', 3, NULL, 67.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (294, NULL, 13.50, 0, 'P', 4, 13, '2019-10-16 15:47:11', '2019-10-17 16:12:20', 3, NULL, 13.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (295, NULL, 15.00, 0, 'P', 4, 13, '2019-10-16 15:47:53', '2019-10-17 16:12:34', 3, NULL, 15.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (296, NULL, 68.50, 0, 'P', 4, 13, '2019-10-16 15:50:38', '2019-10-17 16:13:10', 3, NULL, 68.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (297, NULL, 118.50, 0, 'P', 4, 13, '2019-10-16 15:55:29', '2019-10-17 16:13:23', 3, NULL, 118.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (298, NULL, 191.50, 0, 'P', 6, 13, '2019-10-16 16:13:59', '2019-10-17 16:14:49', 3, NULL, 191.50, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (327, 105, 24.00, 0, 'A', 4, 13, '2019-10-17 16:42:04', '2019-10-17 16:42:04', 3, NULL, 24.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (328, 106, 123.00, 0, 'P', 31, 13, '2019-10-17 16:42:52', '2019-10-17 16:42:52', 3, NULL, 123.00, 23, false, NULL);
INSERT INTO public.venta_productos VALUES (331, 1, 63.00, 0, 'P', 9, NULL, '2019-10-17 17:10:10', '2019-10-17 17:11:17', 3, 8, 63.00, 25, false, NULL);
INSERT INTO public.venta_productos VALUES (332, 2, 114.00, 0, 'P', 22, 16, '2019-10-17 17:13:06', '2019-10-17 17:13:06', 3, NULL, 114.00, 25, false, NULL);
INSERT INTO public.venta_productos VALUES (330, 2, 78.00, 0, 'P', 18, NULL, '2019-10-17 17:05:25', '2019-10-17 17:22:43', 3, 8, 78.00, 24, false, NULL);
INSERT INTO public.venta_productos VALUES (338, 4, 132.00, 0, 'A', 7, NULL, '2019-10-17 17:44:45', '2019-10-17 17:44:45', 3, 8, 132.00, 25, false, NULL);
INSERT INTO public.venta_productos VALUES (335, 5, 115.00, 0, 'P', 16, NULL, '2019-10-17 17:27:30', '2019-10-17 17:28:47', 3, 8, 115.00, 24, false, NULL);
INSERT INTO public.venta_productos VALUES (336, 3, 5.00, 0, 'A', 101, NULL, '2019-10-17 17:30:03', '2019-10-17 17:30:03', 3, 8, 5.00, 25, false, NULL);
INSERT INTO public.venta_productos VALUES (334, 4, 72.50, 0, 'P', 6, NULL, '2019-10-17 17:26:48', '2019-10-17 17:32:13', 3, 8, 72.50, 24, false, NULL);
INSERT INTO public.venta_productos VALUES (333, 3, 24.50, 0, 'P', 2, 13, '2019-10-17 17:25:52', '2019-10-17 17:32:22', 3, NULL, 24.50, 24, false, NULL);
INSERT INTO public.venta_productos VALUES (412, 27, 91.00, 0, 'P', NULL, 19, '2019-10-23 14:52:32', '2019-10-23 14:52:33', 17, NULL, 91.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (337, 6, 163.50, 0, 'P', 34, 13, '2019-10-17 17:34:11', '2019-10-17 17:34:47', 3, NULL, 163.50, 24, false, NULL);
INSERT INTO public.venta_productos VALUES (329, 1, 75.50, 0, 'P', 7, 13, '2019-10-17 16:55:08', '2019-10-17 17:38:12', 3, NULL, 75.50, 24, false, NULL);
INSERT INTO public.venta_productos VALUES (339, 7, 35.00, 0, 'P', 12, 16, '2019-10-17 18:03:53', '2019-10-17 18:07:41', 3, NULL, 35.00, 24, false, NULL);
INSERT INTO public.venta_productos VALUES (340, 8, 15.00, 0, 'P', 1, 13, '2019-10-17 18:05:40', '2019-10-17 18:07:20', 3, NULL, 15.00, 24, false, NULL);
INSERT INTO public.venta_productos VALUES (342, 10, 13.00, 0, 'P', 4, 13, '2019-10-18 09:12:40', '2019-10-18 09:12:40', 3, NULL, 13.00, 24, false, NULL);
INSERT INTO public.venta_productos VALUES (343, 1, 35.00, 0, 'P', 104, 18, '2019-10-18 09:36:33', '2019-10-18 09:36:33', 16, NULL, 35.00, 26, false, NULL);
INSERT INTO public.venta_productos VALUES (341, 9, 57.50, 0, 'P', 4, 13, '2019-10-18 09:10:04', '2019-10-18 10:47:01', 3, NULL, 57.50, 24, false, NULL);
INSERT INTO public.venta_productos VALUES (344, 2, 35.00, 0, 'P', 105, NULL, '2019-10-18 10:00:30', '2019-10-18 10:01:33', 16, 10, 35.00, 26, false, NULL);
INSERT INTO public.venta_productos VALUES (371, 15, 33.00, 0, 'A', 104, 18, '2019-10-18 17:12:31', '2019-10-18 17:12:31', 16, NULL, 33.00, 26, false, NULL);
INSERT INTO public.venta_productos VALUES (372, 16, 35.00, 0, 'P', 104, 18, '2019-10-18 17:12:48', '2019-10-18 17:12:49', 16, NULL, 35.00, 26, false, NULL);
INSERT INTO public.venta_productos VALUES (373, 1, 33.00, 0, 'A', 106, 18, '2019-10-18 17:47:26', '2019-10-18 17:47:26', 16, NULL, 33.00, 28, false, NULL);
INSERT INTO public.venta_productos VALUES (351, 9, 34.00, 0, 'A', 104, 18, '2019-10-18 12:05:09', '2019-10-18 12:05:09', 16, NULL, 34.00, 26, false, NULL);
INSERT INTO public.venta_productos VALUES (352, 11, 69.50, 0, 'A', 1, 13, '2019-10-18 12:16:37', '2019-10-18 12:16:37', 3, NULL, 69.50, 24, false, NULL);
INSERT INTO public.venta_productos VALUES (353, 12, 15.00, 0, 'A', 24, 13, '2019-10-18 12:35:16', '2019-10-18 12:35:16', 3, NULL, 15.00, 24, false, NULL);
INSERT INTO public.venta_productos VALUES (413, 28, 88.00, 0, 'P', 115, 19, '2019-10-23 14:54:37', '2019-10-23 14:54:37', 17, NULL, 88.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (401, 16, 133.00, 0, 'A', 111, 19, '2019-10-23 13:47:31', '2019-10-23 13:47:33', 17, NULL, 133.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (402, 17, 91.00, 0, 'A', 117, 19, '2019-10-23 13:49:36', '2019-10-23 13:49:36', 17, NULL, 91.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (404, 19, 44.00, 0, 'A', NULL, 19, '2019-10-23 14:00:42', '2019-10-23 14:00:44', 17, NULL, 44.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (405, 20, 89.00, 0, 'A', NULL, 19, '2019-10-23 14:03:25', '2019-10-23 14:03:25', 17, NULL, 89.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (406, 21, 89.00, 0, 'A', 121, 19, '2019-10-23 14:04:05', '2019-10-23 14:04:05', 17, NULL, 89.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (432, 15, 141.00, 0, 'P', 112, 19, '2019-10-23 18:33:21', '2019-10-23 18:33:21', 17, NULL, 141.00, 30, false, NULL);
INSERT INTO public.venta_productos VALUES (414, 29, 52.00, 0, 'P', 123, 19, '2019-10-23 14:55:58', '2019-10-23 14:55:58', 17, NULL, 52.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (415, 30, 52.00, 0, 'P', 112, 19, '2019-10-23 14:56:55', '2019-10-23 14:56:56', 17, NULL, 52.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (416, 31, 88.00, 0, 'P', NULL, 19, '2019-10-23 14:58:14', '2019-10-23 14:58:15', 17, NULL, 88.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (411, 26, 91.00, 0, 'P', 122, 19, '2019-10-23 14:46:41', '2019-10-23 17:05:54', 17, NULL, 91.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (410, 25, 91.00, 0, 'P', NULL, 19, '2019-10-23 14:45:54', '2019-10-23 17:06:19', 17, NULL, 91.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (409, 24, 91.00, 0, 'P', NULL, 19, '2019-10-23 14:44:39', '2019-10-23 17:06:30', 17, NULL, 91.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (408, 23, 137.00, 0, 'P', NULL, 19, '2019-10-23 14:30:47', '2019-10-23 17:06:56', 17, NULL, 137.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (431, 14, 141.00, 0, 'P', NULL, NULL, '2019-10-23 18:32:03', '2019-10-24 09:31:08', 17, 11, 141.00, 30, false, NULL);
INSERT INTO public.venta_productos VALUES (417, 32, 141.00, 0, 'P', NULL, 19, '2019-10-23 17:08:34', '2019-10-23 17:09:22', 17, NULL, 141.00, 29, false, NULL);
INSERT INTO public.venta_productos VALUES (418, 1, 91.00, 0, 'P', NULL, 19, '2019-10-23 17:13:11', '2019-10-23 17:13:11', 17, NULL, 91.00, 30, false, NULL);
INSERT INTO public.venta_productos VALUES (446, 6, 37.00, 0, 'P', 9, 13, '2019-11-05 10:13:20', '2019-11-05 10:13:21', 3, NULL, 37.00, 32, false, NULL);
INSERT INTO public.venta_productos VALUES (433, 1, 44.00, 0, 'P', NULL, 19, '2019-10-24 18:26:03', '2019-10-24 18:27:05', 17, NULL, 44.00, 31, false, NULL);
INSERT INTO public.venta_productos VALUES (434, 2, 47.00, 0, 'P', NULL, 19, '2019-10-24 18:26:15', '2019-10-25 00:30:17', 17, NULL, 47.00, 31, false, NULL);
INSERT INTO public.venta_productos VALUES (425, 8, 182.00, 0, 'P', 126, 19, '2019-10-23 17:58:45', '2019-10-23 17:58:45', 17, NULL, 182.00, 30, false, NULL);
INSERT INTO public.venta_productos VALUES (419, 2, 138.00, 0, 'P', NULL, 19, '2019-10-23 17:16:56', '2019-10-23 18:09:49', 17, NULL, 138.00, 30, false, NULL);
INSERT INTO public.venta_productos VALUES (420, 3, 4.00, 0, 'P', 115, 19, '2019-10-23 17:22:05', '2019-10-23 18:10:10', 17, NULL, 4.00, 30, false, NULL);
INSERT INTO public.venta_productos VALUES (421, 4, 182.00, 0, 'P', NULL, NULL, '2019-10-23 17:29:45', '2019-10-23 18:10:20', 17, 11, 182.00, 30, false, NULL);
INSERT INTO public.venta_productos VALUES (422, 5, 54.00, 0, 'P', 114, NULL, '2019-10-23 17:30:27', '2019-10-23 18:10:50', 17, 11, 54.00, 30, false, NULL);
INSERT INTO public.venta_productos VALUES (423, 6, 187.00, 0, 'P', 124, 19, '2019-10-23 17:49:20', '2019-10-23 18:10:59', 17, NULL, 187.00, 30, false, NULL);
INSERT INTO public.venta_productos VALUES (424, 7, 141.00, 0, 'P', 125, 19, '2019-10-23 17:55:53', '2019-10-23 18:11:12', 17, NULL, 141.00, 30, false, NULL);
INSERT INTO public.venta_productos VALUES (426, 9, 87.00, 0, 'P', 127, 19, '2019-10-23 17:59:59', '2019-10-23 18:11:27', 17, NULL, 87.00, 30, false, NULL);
INSERT INTO public.venta_productos VALUES (427, 10, 4.00, 0, 'P', NULL, 19, '2019-10-23 18:00:43', '2019-10-23 18:11:46', 17, NULL, 4.00, 30, false, NULL);
INSERT INTO public.venta_productos VALUES (435, 3, 44.00, 0, 'P', 115, 19, '2019-10-25 00:57:38', '2019-10-25 00:58:05', 17, NULL, 44.00, 31, false, NULL);
INSERT INTO public.venta_productos VALUES (428, 11, 94.00, 0, 'P', 112, 19, '2019-10-23 18:12:34', '2019-10-23 18:15:04', 17, NULL, 94.00, 30, false, NULL);
INSERT INTO public.venta_productos VALUES (454, 2, 87.00, 0, 'P', NULL, 25, '2019-11-05 17:22:06', '2019-11-05 17:22:39', 18, NULL, 87.00, 33, false, NULL);
INSERT INTO public.venta_productos VALUES (429, 12, 88.00, 0, 'P', NULL, 19, '2019-10-23 18:15:34', '2019-10-23 18:19:13', 17, NULL, 88.00, 30, false, NULL);
INSERT INTO public.venta_productos VALUES (430, 13, 89.00, 0, 'P', NULL, NULL, '2019-10-23 18:17:05', '2019-10-23 18:22:57', 17, 11, 89.00, 30, false, NULL);
INSERT INTO public.venta_productos VALUES (437, 5, 104.00, 0, 'P', 125, 19, '2019-10-25 01:04:04', '2019-10-25 01:04:04', 17, NULL, 104.00, 31, false, NULL);
INSERT INTO public.venta_productos VALUES (438, 1, 70.00, 0, 'P', 22, 13, '2019-10-25 09:19:42', '2019-10-25 09:22:00', 3, NULL, 70.00, 32, false, NULL);
INSERT INTO public.venta_productos VALUES (439, 2, 70.00, 0, 'P', NULL, 13, '2019-10-25 09:30:09', '2019-10-25 09:30:09', 3, NULL, 70.00, 32, false, NULL);
INSERT INTO public.venta_productos VALUES (440, 3, 15.00, 0, 'P', NULL, 13, '2019-10-25 09:49:01', '2019-10-25 09:49:01', 3, NULL, 15.00, 32, false, NULL);
INSERT INTO public.venta_productos VALUES (441, 4, 917.80, 0, 'P', 128, 13, '2019-10-25 10:06:37', '2019-10-25 10:06:37', 3, NULL, 917.80, 32, false, NULL);
INSERT INTO public.venta_productos VALUES (448, 8, 67.50, 0, 'P', NULL, 13, '2019-11-05 14:43:51', '2019-11-05 14:43:51', 3, NULL, 67.50, 32, false, NULL);
INSERT INTO public.venta_productos VALUES (436, 4, 91.00, 0, 'P', 116, 19, '2019-10-25 01:03:11', '2019-10-25 10:27:14', 17, NULL, 91.00, 31, false, NULL);
INSERT INTO public.venta_productos VALUES (443, 7, 4.00, 0, 'P', 116, NULL, '2019-10-25 10:22:30', '2019-10-25 12:53:57', 17, 11, 4.00, 31, false, NULL);
INSERT INTO public.venta_productos VALUES (449, 9, 67.50, 0, 'P', 4, 13, '2019-11-05 14:44:49', '2019-11-05 14:44:49', 3, NULL, 67.50, 32, false, NULL);
INSERT INTO public.venta_productos VALUES (444, 8, 91.00, 0, 'P', NULL, 19, '2019-10-25 13:01:22', '2019-10-25 13:01:49', 17, NULL, 91.00, 31, false, NULL);
INSERT INTO public.venta_productos VALUES (442, 6, 143.00, 0, 'P', NULL, NULL, '2019-10-25 10:20:08', '2019-10-25 13:01:59', 17, 11, 143.00, 31, false, NULL);
INSERT INTO public.venta_productos VALUES (451, 11, 76.00, 0, 'P', NULL, 13, '2019-11-05 14:45:58', '2019-11-05 14:45:58', 3, NULL, 76.00, 32, false, NULL);
INSERT INTO public.venta_productos VALUES (452, 12, 21.50, 0, 'P', NULL, 13, '2019-11-05 14:47:07', '2019-11-05 14:47:08', 3, NULL, 21.50, 32, false, NULL);
INSERT INTO public.venta_productos VALUES (447, 7, 57.50, 0, 'P', NULL, 13, '2019-11-05 14:43:21', '2019-11-05 16:55:31', 3, NULL, 57.50, 32, false, NULL);
INSERT INTO public.venta_productos VALUES (450, 10, 78.50, 0, 'P', NULL, 13, '2019-11-05 14:45:28', '2019-11-05 16:55:42', 3, NULL, 78.50, 32, false, NULL);
INSERT INTO public.venta_productos VALUES (453, 1, 89.00, 0, 'P', 114, 25, '2019-11-05 17:20:53', '2019-11-05 17:20:53', 18, NULL, 89.00, 33, false, NULL);
INSERT INTO public.venta_productos VALUES (455, 3, 54.00, 0, 'P', NULL, 25, '2019-11-05 18:18:02', '2019-11-05 18:18:03', 18, NULL, 54.00, 33, false, NULL);
INSERT INTO public.venta_productos VALUES (463, 7, 178.00, 0, 'P', 122, NULL, '2019-11-08 17:21:12', '2019-11-16 13:15:39', 18, 14, 178.00, 33, false, NULL);
INSERT INTO public.venta_productos VALUES (460, 2, 104.00, 0, 'P', NULL, 19, '2019-11-06 16:02:04', '2019-11-27 09:50:08', 17, NULL, 104.00, 34, true, NULL);
INSERT INTO public.venta_productos VALUES (459, 1, 89.00, 0, 'P', 112, 19, '2019-11-06 16:01:13', '2019-11-27 09:50:19', 17, NULL, 89.00, 34, true, NULL);
INSERT INTO public.venta_productos VALUES (466, 6, 107.00, 0, 'P', 116, 19, '2019-11-29 23:51:40', '2019-11-29 23:52:12', 17, NULL, 107.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (465, 5, 72.00, 0, 'P', 122, 19, '2019-11-22 09:26:23', '2019-11-29 23:53:38', 17, NULL, 72.00, 34, true, NULL);
INSERT INTO public.venta_productos VALUES (467, 8, 12.00, 0, 'A', 121, NULL, '2019-12-02 11:36:49', '2019-12-02 11:36:49', 18, 11, 12.00, 33, false, NULL);
INSERT INTO public.venta_productos VALUES (484, 20, 12.00, 0, 'A', 142, 19, '2019-12-11 16:58:15', '2019-12-11 16:58:15', 17, NULL, 12.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (468, 7, 16.00, 0, 'P', 117, NULL, '2019-12-02 11:42:55', '2019-12-02 13:57:57', 17, 11, 16.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (469, 8, 96.00, 0, 'A', 134, 19, '2019-12-06 18:12:09', '2019-12-06 18:12:09', 17, NULL, 96.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (485, 21, 12.00, 0, 'A', 143, 19, '2019-12-11 17:43:18', '2019-12-11 17:43:18', 17, NULL, 12.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (472, 9, 70.00, 0, 'A', NULL, NULL, '2019-12-08 21:51:02', '2019-12-08 21:51:02', 17, 11, 70.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (486, 22, 12.00, 0, 'A', 144, 19, '2019-12-11 17:44:42', '2019-12-11 17:44:42', 17, NULL, 12.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (503, 34, 94.00, 0, 'P', 152, 19, '2020-01-24 15:16:09', '2020-01-24 15:16:09', 17, NULL, 94.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (470, 1, 134.00, 0, 'P', 122, 25, '2019-12-08 21:42:21', '2019-12-08 21:58:10', 18, NULL, 134.00, 35, true, NULL);
INSERT INTO public.venta_productos VALUES (471, 2, 8.00, 0, 'P', 136, 25, '2019-12-08 21:45:08', '2019-12-08 21:58:25', 18, NULL, 8.00, 35, true, NULL);
INSERT INTO public.venta_productos VALUES (474, 10, 43.00, 0, 'A', NULL, 19, '2019-12-09 14:16:37', '2019-12-09 14:16:37', 17, NULL, 43.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (475, 11, 12.00, 0, 'P', 125, 19, '2019-12-09 18:38:25', '2019-12-09 21:06:39', 17, NULL, 12.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (476, 12, 16.00, 0, 'A', NULL, 19, '2019-12-10 10:13:28', '2019-12-10 10:13:28', 17, NULL, 16.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (477, 13, 104.00, 0, 'A', 137, 19, '2019-12-10 18:35:13', '2019-12-10 18:35:13', 17, NULL, 104.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (478, 14, 58.00, 0, 'A', 134, 19, '2019-12-11 12:30:01', '2019-12-11 12:30:02', 17, NULL, 58.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (479, 15, 58.00, 0, 'A', 138, 19, '2019-12-11 16:42:25', '2019-12-11 16:42:25', 17, NULL, 58.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (480, 16, 12.00, 0, 'A', 139, 19, '2019-12-11 16:47:28', '2019-12-11 16:47:28', 17, NULL, 12.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (481, 17, 4.00, 0, 'A', NULL, 19, '2019-12-11 16:49:55', '2019-12-11 16:49:55', 17, NULL, 4.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (482, 18, 24.00, 0, 'A', 140, 19, '2019-12-11 16:55:58', '2019-12-11 16:55:58', 17, NULL, 24.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (483, 19, 29.00, 0, 'A', 141, 19, '2019-12-11 16:57:23', '2019-12-11 16:57:23', 17, NULL, 29.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (487, 23, 12.00, 0, 'A', 145, 19, '2019-12-11 17:47:51', '2019-12-11 17:47:51', 17, NULL, 12.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (488, 24, 12.00, 0, 'P', 146, 19, '2019-12-11 17:51:47', '2019-12-11 17:51:47', 17, NULL, 12.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (489, 25, 62.00, 0, 'P', 148, 19, '2019-12-11 17:55:14', '2019-12-11 17:55:14', 17, NULL, 62.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (490, 26, 35.00, 0, 'P', 144, 19, '2019-12-17 13:37:54', '2019-12-17 13:37:54', 17, NULL, 35.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (491, 27, 43.00, 0, 'P', NULL, 19, '2019-12-17 13:38:27', '2019-12-17 13:41:14', 17, NULL, 43.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (499, 16, 116.30, 0, 'P', 151, 13, '2020-01-14 16:56:24', '2020-01-14 16:56:24', 3, NULL, 116.30, 32, false, NULL);
INSERT INTO public.venta_productos VALUES (492, 28, 52.00, 0, 'P', NULL, 19, '2019-12-17 17:49:11', '2019-12-17 17:49:24', 17, NULL, 52.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (493, 29, 8.00, 0, 'P', 125, 19, '2019-12-17 18:24:03', '2019-12-17 18:24:04', 17, NULL, 8.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (494, 30, 44.00, 0, 'P', 149, 19, '2019-12-17 18:25:22', '2019-12-17 18:25:22', 17, NULL, 44.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (495, 31, 87.00, 0, 'P', 149, 19, '2019-12-17 18:27:29', '2019-12-17 18:27:42', 17, NULL, 87.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (496, 13, 86.50, 0, 'P', 150, 13, '2020-01-13 10:42:46', '2020-01-13 10:43:40', 3, NULL, 86.50, 32, false, NULL);
INSERT INTO public.venta_productos VALUES (500, 32, 94.00, 0, 'P', NULL, 19, '2020-01-24 11:04:08', '2020-01-24 11:04:08', 17, NULL, 94.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (497, 14, 80.50, 0, 'P', 34, 13, '2020-01-14 16:43:25', '2020-01-14 16:43:59', 3, NULL, 80.50, 32, false, NULL);
INSERT INTO public.venta_productos VALUES (498, 15, 29.50, 0, 'A', 151, 13, '2020-01-14 16:46:00', '2020-01-14 16:46:00', 3, NULL, 29.50, 32, false, NULL);
INSERT INTO public.venta_productos VALUES (501, 33, 40.00, 0, 'P', 145, 19, '2020-01-24 11:05:30', '2020-01-24 11:06:32', 17, NULL, 40.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (502, 4, 92.00, 0, 'A', NULL, NULL, '2020-01-24 11:08:30', '2020-01-24 11:10:15', 18, 11, 92.00, 35, true, NULL);
INSERT INTO public.venta_productos VALUES (473, 3, 140.00, 0, 'P', NULL, NULL, '2019-12-08 21:53:33', '2020-01-24 11:10:24', 18, 11, 140.00, 35, true, NULL);
INSERT INTO public.venta_productos VALUES (504, 35, 94.00, 0, 'P', 153, 19, '2020-01-24 15:35:27', '2020-01-24 15:35:27', 17, NULL, 94.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (505, 36, 60.00, 0, 'P', NULL, 19, '2020-01-24 15:36:40', '2020-01-24 15:36:40', 17, NULL, 60.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (506, 37, 101.00, 0, 'P', 154, 19, '2020-01-24 15:49:33', '2020-01-24 15:49:33', 17, NULL, 101.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (507, 38, 47.00, 0, 'P', NULL, 19, '2020-01-24 15:50:42', '2020-01-24 15:52:07', 17, NULL, 47.00, 34, false, NULL);
INSERT INTO public.venta_productos VALUES (508, 5, 98.00, 0, 'P', 155, NULL, '2020-01-24 18:32:20', '2020-01-24 18:43:55', 18, 11, 98.00, 35, true, NULL);
INSERT INTO public.venta_productos VALUES (509, 6, 92.00, 0, 'P', NULL, 25, '2020-01-24 18:38:48', '2020-01-24 18:44:11', 18, NULL, 92.00, 35, true, NULL);
INSERT INTO public.venta_productos VALUES (510, 1, 182.00, 0, 'P', 156, 19, '2020-01-28 22:17:30', '2020-01-28 22:17:30', 17, NULL, 182.00, 36, false, NULL);
INSERT INTO public.venta_productos VALUES (511, 2, 94.00, 0, 'P', NULL, 19, '2020-01-28 22:19:10', '2020-01-28 22:21:04', 17, NULL, 94.00, 36, false, NULL);
INSERT INTO public.venta_productos VALUES (512, 1, 94.00, 0, 'A', 157, NULL, '2020-01-28 22:50:14', '2020-01-28 22:58:19', 17, 11, 94.00, 37, true, NULL);
INSERT INTO public.venta_productos VALUES (513, 2, 248.50, 0, 'P', 139, 19, '2020-01-29 12:21:44', '2020-01-29 12:22:17', 17, NULL, 248.50, 37, false, NULL);
INSERT INTO public.venta_productos VALUES (514, 3, 123.50, 0, 'P', 138, 19, '2020-01-29 12:24:47', '2020-01-29 12:24:58', 17, NULL, 123.50, 37, false, NULL);


--
-- TOC entry 5051 (class 0 OID 0)
-- Dependencies: 217
-- Name: administradors_id_administrador_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.administradors_id_administrador_seq', 69, true);


--
-- TOC entry 5052 (class 0 OID 0)
-- Dependencies: 219
-- Name: cajas_id_caja_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cajas_id_caja_seq', 39, true);


--
-- TOC entry 5053 (class 0 OID 0)
-- Dependencies: 222
-- Name: categoria_productos_id_categoria_producto_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categoria_productos_id_categoria_producto_seq', 43, true);


--
-- TOC entry 5054 (class 0 OID 0)
-- Dependencies: 224
-- Name: clientes_id_cliente_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.clientes_id_cliente_seq', 157, true);


--
-- TOC entry 5055 (class 0 OID 0)
-- Dependencies: 226
-- Name: cocineros_id_cocinero_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cocineros_id_cocinero_seq', 4, true);


--
-- TOC entry 5056 (class 0 OID 0)
-- Dependencies: 227
-- Name: empleados_id_empleado_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.empleados_id_empleado_seq', 29, true);


--
-- TOC entry 5057 (class 0 OID 0)
-- Dependencies: 229
-- Name: historial_caja_id_historial_caja_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.historial_caja_id_historial_caja_seq', 37, true);


--
-- TOC entry 5058 (class 0 OID 0)
-- Dependencies: 231
-- Name: mozos_id_mozo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mozos_id_mozo_seq', 15, true);


--
-- TOC entry 5059 (class 0 OID 0)
-- Dependencies: 233
-- Name: pagos_id_pago_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pagos_id_pago_seq', 362, true);


--
-- TOC entry 5060 (class 0 OID 0)
-- Dependencies: 235
-- Name: perfilimagens_id_perfilimagen_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.perfilimagens_id_perfilimagen_seq', 63, true);


--
-- TOC entry 5061 (class 0 OID 0)
-- Dependencies: 237
-- Name: plan_de_pagos_id_planpago_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.plan_de_pagos_id_planpago_seq', 3, true);


--
-- TOC entry 5062 (class 0 OID 0)
-- Dependencies: 239
-- Name: producto_vendidos_id_producto_vendido_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.producto_vendidos_id_producto_vendido_seq', 1748, true);


--
-- TOC entry 5063 (class 0 OID 0)
-- Dependencies: 241
-- Name: productos_id_producto_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.productos_id_producto_seq', 127, true);


--
-- TOC entry 5064 (class 0 OID 0)
-- Dependencies: 243
-- Name: restaurants_id_restaurant_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.restaurants_id_restaurant_seq', 44, true);


--
-- TOC entry 5065 (class 0 OID 0)
-- Dependencies: 245
-- Name: sucursals_id_sucursal_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sucursals_id_sucursal_seq', 22, true);


--
-- TOC entry 5066 (class 0 OID 0)
-- Dependencies: 247
-- Name: superadministradors_id_superadministrador_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.superadministradors_id_superadministrador_seq', 2, true);


--
-- TOC entry 5067 (class 0 OID 0)
-- Dependencies: 249
-- Name: suscripcions_id_suscripcion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.suscripcions_id_suscripcion_seq', 3, true);


--
-- TOC entry 5068 (class 0 OID 0)
-- Dependencies: 250
-- Name: users_id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_usuario_seq', 118, true);


--
-- TOC entry 5069 (class 0 OID 0)
-- Dependencies: 252
-- Name: venta_productos_id_venta_producto_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.venta_productos_id_venta_producto_seq', 514, true);


--
-- TOC entry 4763 (class 2606 OID 33177)
-- Name: administradors administradors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.administradors
    ADD CONSTRAINT administradors_pkey PRIMARY KEY (id_administrador);


--
-- TOC entry 4765 (class 2606 OID 33179)
-- Name: cajas cajas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cajas
    ADD CONSTRAINT cajas_pkey PRIMARY KEY (id_caja);


--
-- TOC entry 4769 (class 2606 OID 33181)
-- Name: categoria_productos categoria_productos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria_productos
    ADD CONSTRAINT categoria_productos_pkey PRIMARY KEY (id_categoria_producto);


--
-- TOC entry 4771 (class 2606 OID 33183)
-- Name: clientes clientes_dni_id_restaurant_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_dni_id_restaurant_key UNIQUE (dni, id_restaurant);


--
-- TOC entry 4773 (class 2606 OID 33185)
-- Name: clientes clientes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_pkey PRIMARY KEY (id_cliente);


--
-- TOC entry 4775 (class 2606 OID 33187)
-- Name: cocineros cocineros_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cocineros
    ADD CONSTRAINT cocineros_pkey PRIMARY KEY (id_cocinero);


--
-- TOC entry 4767 (class 2606 OID 33189)
-- Name: cajeros empleados_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cajeros
    ADD CONSTRAINT empleados_pkey PRIMARY KEY (id_cajero);


--
-- TOC entry 4777 (class 2606 OID 33191)
-- Name: historial_caja historial_caja_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_caja
    ADD CONSTRAINT historial_caja_pkey PRIMARY KEY (id_historial_caja);


--
-- TOC entry 4779 (class 2606 OID 33193)
-- Name: mozos mozos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mozos
    ADD CONSTRAINT mozos_pkey PRIMARY KEY (id_mozo);


--
-- TOC entry 4781 (class 2606 OID 33195)
-- Name: pagos pagos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pagos
    ADD CONSTRAINT pagos_pkey PRIMARY KEY (id_pago);


--
-- TOC entry 4783 (class 2606 OID 33197)
-- Name: perfilimagens perfilimagens_nombre_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.perfilimagens
    ADD CONSTRAINT perfilimagens_nombre_key UNIQUE (nombre);


--
-- TOC entry 4785 (class 2606 OID 33199)
-- Name: perfilimagens perfilimagens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.perfilimagens
    ADD CONSTRAINT perfilimagens_pkey PRIMARY KEY (id_perfilimagen);


--
-- TOC entry 4787 (class 2606 OID 33201)
-- Name: plan_de_pagos plan_de_pagos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plan_de_pagos
    ADD CONSTRAINT plan_de_pagos_pkey PRIMARY KEY (id_planpago);


--
-- TOC entry 4789 (class 2606 OID 33203)
-- Name: producto_vendidos producto_vendidos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.producto_vendidos
    ADD CONSTRAINT producto_vendidos_pkey PRIMARY KEY (id_producto_vendido);


--
-- TOC entry 4791 (class 2606 OID 33205)
-- Name: productos productos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_pkey PRIMARY KEY (id_producto);


--
-- TOC entry 4793 (class 2606 OID 33207)
-- Name: restaurants restaurants_nombre_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT restaurants_nombre_unique UNIQUE (nombre);


--
-- TOC entry 4795 (class 2606 OID 33209)
-- Name: restaurants restaurants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT restaurants_pkey PRIMARY KEY (id_restaurant);


--
-- TOC entry 4797 (class 2606 OID 33211)
-- Name: sucursals sucursals_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sucursals
    ADD CONSTRAINT sucursals_pkey PRIMARY KEY (id_sucursal);


--
-- TOC entry 4799 (class 2606 OID 33213)
-- Name: superadministradors superadministradors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.superadministradors
    ADD CONSTRAINT superadministradors_pkey PRIMARY KEY (id_superadministrador);


--
-- TOC entry 4801 (class 2606 OID 33215)
-- Name: superadministradors superadministradors_usuario_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.superadministradors
    ADD CONSTRAINT superadministradors_usuario_unique UNIQUE (nombre_usuario);


--
-- TOC entry 4803 (class 2606 OID 33217)
-- Name: suscripcions suscripcions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suscripcions
    ADD CONSTRAINT suscripcions_pkey PRIMARY KEY (id_suscripcion);


--
-- TOC entry 4755 (class 2606 OID 33219)
-- Name: users users_dni_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_dni_unique UNIQUE (dni);


--
-- TOC entry 4757 (class 2606 OID 33221)
-- Name: users users_email_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--
-- TOC entry 4759 (class 2606 OID 33223)
-- Name: users users_nombre_usuario_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_nombre_usuario_unique UNIQUE (nombre_usuario);


--
-- TOC entry 4761 (class 2606 OID 33225)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id_usuario);


--
-- TOC entry 4805 (class 2606 OID 33227)
-- Name: venta_productos venta_productos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venta_productos
    ADD CONSTRAINT venta_productos_pkey PRIMARY KEY (id_venta_producto);


--
-- TOC entry 4806 (class 2606 OID 33228)
-- Name: administradors administradors_id_restaurant_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.administradors
    ADD CONSTRAINT administradors_id_restaurant_fkey FOREIGN KEY (id_restaurant) REFERENCES public.restaurants(id_restaurant);


--
-- TOC entry 4807 (class 2606 OID 33233)
-- Name: administradors administradors_id_superadministrador_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.administradors
    ADD CONSTRAINT administradors_id_superadministrador_fkey FOREIGN KEY (id_superadministrador) REFERENCES public.superadministradors(id_superadministrador);


--
-- TOC entry 4808 (class 2606 OID 33238)
-- Name: cajas cajas_id_administrador_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cajas
    ADD CONSTRAINT cajas_id_administrador_fkey FOREIGN KEY (id_administrador) REFERENCES public.administradors(id_administrador);


--
-- TOC entry 4809 (class 2606 OID 33243)
-- Name: cajas cajas_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cajas
    ADD CONSTRAINT cajas_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursals(id_sucursal);


--
-- TOC entry 4810 (class 2606 OID 33248)
-- Name: cajeros cajeros_id_caja_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cajeros
    ADD CONSTRAINT cajeros_id_caja_fkey FOREIGN KEY (id_caja) REFERENCES public.cajas(id_caja);


--
-- TOC entry 4813 (class 2606 OID 33253)
-- Name: categoria_productos categoria_productos_id_administrador_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria_productos
    ADD CONSTRAINT categoria_productos_id_administrador_fkey FOREIGN KEY (id_administrador) REFERENCES public.administradors(id_administrador);


--
-- TOC entry 4814 (class 2606 OID 33258)
-- Name: categoria_productos categoria_productos_id_restaurant_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria_productos
    ADD CONSTRAINT categoria_productos_id_restaurant_fkey FOREIGN KEY (id_restaurant) REFERENCES public.restaurants(id_restaurant);


--
-- TOC entry 4815 (class 2606 OID 33263)
-- Name: clientes clientes_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_id_empleado_fkey FOREIGN KEY (id_cajero) REFERENCES public.cajeros(id_cajero);


--
-- TOC entry 4816 (class 2606 OID 33268)
-- Name: clientes clientes_id_mozo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_id_mozo_fkey FOREIGN KEY (id_mozo) REFERENCES public.mozos(id_mozo);


--
-- TOC entry 4817 (class 2606 OID 33273)
-- Name: clientes clientes_id_restaurant_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_id_restaurant_fkey FOREIGN KEY (id_restaurant) REFERENCES public.restaurants(id_restaurant);


--
-- TOC entry 4818 (class 2606 OID 33278)
-- Name: cocineros cocineros_id_administrador_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cocineros
    ADD CONSTRAINT cocineros_id_administrador_fkey FOREIGN KEY (id_administrador) REFERENCES public.administradors(id_administrador);


--
-- TOC entry 4819 (class 2606 OID 33283)
-- Name: cocineros cocineros_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cocineros
    ADD CONSTRAINT cocineros_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursals(id_sucursal);


--
-- TOC entry 4811 (class 2606 OID 33288)
-- Name: cajeros empleados_id_administrador_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cajeros
    ADD CONSTRAINT empleados_id_administrador_fkey FOREIGN KEY (id_administrador) REFERENCES public.administradors(id_administrador);


--
-- TOC entry 4812 (class 2606 OID 33293)
-- Name: cajeros empleados_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cajeros
    ADD CONSTRAINT empleados_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursals(id_sucursal);


--
-- TOC entry 4820 (class 2606 OID 33298)
-- Name: historial_caja historial_caja_id_administrador_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_caja
    ADD CONSTRAINT historial_caja_id_administrador_fkey FOREIGN KEY (id_administrador) REFERENCES public.administradors(id_administrador);


--
-- TOC entry 4821 (class 2606 OID 33303)
-- Name: historial_caja historial_caja_id_caja_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_caja
    ADD CONSTRAINT historial_caja_id_caja_fkey FOREIGN KEY (id_caja) REFERENCES public.cajas(id_caja);


--
-- TOC entry 4822 (class 2606 OID 33308)
-- Name: historial_caja historial_caja_id_cajero_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_caja
    ADD CONSTRAINT historial_caja_id_cajero_fkey FOREIGN KEY (id_cajero) REFERENCES public.cajeros(id_cajero);


--
-- TOC entry 4823 (class 2606 OID 33313)
-- Name: mozos mozos_id_administrador_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mozos
    ADD CONSTRAINT mozos_id_administrador_fkey FOREIGN KEY (id_administrador) REFERENCES public.administradors(id_administrador);


--
-- TOC entry 4824 (class 2606 OID 33318)
-- Name: mozos mozos_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mozos
    ADD CONSTRAINT mozos_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursals(id_sucursal);


--
-- TOC entry 4825 (class 2606 OID 33323)
-- Name: pagos pagos_id_cajero_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pagos
    ADD CONSTRAINT pagos_id_cajero_fkey FOREIGN KEY (id_cajero) REFERENCES public.cajeros(id_cajero);


--
-- TOC entry 4826 (class 2606 OID 33328)
-- Name: pagos pagos_id_venta_producto_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pagos
    ADD CONSTRAINT pagos_id_venta_producto_fkey FOREIGN KEY (id_venta_producto) REFERENCES public.venta_productos(id_venta_producto);


--
-- TOC entry 4827 (class 2606 OID 33333)
-- Name: perfilimagens perfilimagens_id_administrador_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.perfilimagens
    ADD CONSTRAINT perfilimagens_id_administrador_fkey FOREIGN KEY (id_administrador) REFERENCES public.administradors(id_administrador);


--
-- TOC entry 4828 (class 2606 OID 33338)
-- Name: perfilimagens perfilimagens_id_cajero_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.perfilimagens
    ADD CONSTRAINT perfilimagens_id_cajero_fkey FOREIGN KEY (id_cajero) REFERENCES public.cajeros(id_cajero);


--
-- TOC entry 4829 (class 2606 OID 33343)
-- Name: perfilimagens perfilimagens_id_mozo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.perfilimagens
    ADD CONSTRAINT perfilimagens_id_mozo_fkey FOREIGN KEY (id_mozo) REFERENCES public.mozos(id_mozo);


--
-- TOC entry 4830 (class 2606 OID 33348)
-- Name: plan_de_pagos plan_de_pagos_id_suscripcion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plan_de_pagos
    ADD CONSTRAINT plan_de_pagos_id_suscripcion_fkey FOREIGN KEY (id_suscripcion) REFERENCES public.suscripcions(id_suscripcion);


--
-- TOC entry 4831 (class 2606 OID 33353)
-- Name: producto_vendidos producto_vendidos_id_producto_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.producto_vendidos
    ADD CONSTRAINT producto_vendidos_id_producto_fkey FOREIGN KEY (id_producto) REFERENCES public.productos(id_producto);


--
-- TOC entry 4832 (class 2606 OID 33358)
-- Name: producto_vendidos producto_vendidos_id_venta_producto_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.producto_vendidos
    ADD CONSTRAINT producto_vendidos_id_venta_producto_fkey FOREIGN KEY (id_venta_producto) REFERENCES public.venta_productos(id_venta_producto);


--
-- TOC entry 4833 (class 2606 OID 33363)
-- Name: productos productos_id_administrador_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_id_administrador_fkey FOREIGN KEY (id_administrador) REFERENCES public.administradors(id_administrador);


--
-- TOC entry 4834 (class 2606 OID 33368)
-- Name: productos productos_id_categoria_producto_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_id_categoria_producto_fkey FOREIGN KEY (id_categoria_producto) REFERENCES public.categoria_productos(id_categoria_producto);


--
-- TOC entry 4835 (class 2606 OID 33373)
-- Name: restaurants restaurants_id_superadministrador_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT restaurants_id_superadministrador_fkey FOREIGN KEY (id_superadministrador) REFERENCES public.superadministradors(id_superadministrador);


--
-- TOC entry 4836 (class 2606 OID 33378)
-- Name: restaurants restaurants_id_suscripcion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT restaurants_id_suscripcion_fkey FOREIGN KEY (id_suscripcion) REFERENCES public.suscripcions(id_suscripcion);


--
-- TOC entry 4837 (class 2606 OID 33383)
-- Name: sucursals sucursals_id_restaurant_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sucursals
    ADD CONSTRAINT sucursals_id_restaurant_fkey FOREIGN KEY (id_restaurant) REFERENCES public.restaurants(id_restaurant);


--
-- TOC entry 4838 (class 2606 OID 33388)
-- Name: sucursals sucursals_id_superadministrador_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sucursals
    ADD CONSTRAINT sucursals_id_superadministrador_fkey FOREIGN KEY (id_superadministrador) REFERENCES public.superadministradors(id_superadministrador);


--
-- TOC entry 4839 (class 2606 OID 33393)
-- Name: suscripcions suscripcions_id_superadministrador_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suscripcions
    ADD CONSTRAINT suscripcions_id_superadministrador_fkey FOREIGN KEY (id_superadministrador) REFERENCES public.superadministradors(id_superadministrador);


--
-- TOC entry 4840 (class 2606 OID 33398)
-- Name: venta_productos venta_productos_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venta_productos
    ADD CONSTRAINT venta_productos_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.clientes(id_cliente);


--
-- TOC entry 4841 (class 2606 OID 33403)
-- Name: venta_productos venta_productos_id_cocinero_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venta_productos
    ADD CONSTRAINT venta_productos_id_cocinero_fkey FOREIGN KEY (id_cocinero) REFERENCES public.cocineros(id_cocinero);


--
-- TOC entry 4842 (class 2606 OID 33408)
-- Name: venta_productos venta_productos_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venta_productos
    ADD CONSTRAINT venta_productos_id_empleado_fkey FOREIGN KEY (id_cajero) REFERENCES public.cajeros(id_cajero);


--
-- TOC entry 4843 (class 2606 OID 33413)
-- Name: venta_productos venta_productos_id_historial_caja_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venta_productos
    ADD CONSTRAINT venta_productos_id_historial_caja_fkey FOREIGN KEY (id_historial_caja) REFERENCES public.historial_caja(id_historial_caja);


--
-- TOC entry 4844 (class 2606 OID 33418)
-- Name: venta_productos venta_productos_id_mozo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venta_productos
    ADD CONSTRAINT venta_productos_id_mozo_fkey FOREIGN KEY (id_mozo) REFERENCES public.mozos(id_mozo);


--
-- TOC entry 4845 (class 2606 OID 33423)
-- Name: venta_productos venta_productos_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venta_productos
    ADD CONSTRAINT venta_productos_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursals(id_sucursal);


-- Completed on 2025-05-22 17:43:17

--
-- PostgreSQL database dump complete
--

