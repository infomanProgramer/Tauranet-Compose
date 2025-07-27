# Base de datos

## Dockerizacion de bd
~~~
docker run -d  --name postgres-db-tauranet -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=pgadmin1325 -e POSTGRES_DB=tauranet_db -p 25432:5432 -v volumen-tauranet-db:/var/lib/postgresql/data -v "$(pwd)/tauranet_db.sql:/docker-entrypoint-initdb.d/tauranet_db.sql" postgres:16
~~~

## Verificar si la base de datos esta funcionando

~~~
docker exec -it postgres-db-tauranet psql -U postgres -d tauranet_db
~~~

Para verificar que las tablas 
~~~
\dt
~~~

o

~~~
\dt *.*
~~~

# Backend

## Dockerizar backend

### Construir la imagen (esto ya no es neceasio con Docker compose)

~~~
docker build -t tauranet-backend-image-dos .
~~~

### Contruir al contenedor (esto ya no es neceasio con Docker compose)

~~~
docker run -p 8080:80 -it --name=tauranet-backend-container tauranet-backend-image-dos
~~~

### Ejecutar el contenedor (esto ya no es neceasio con Docker compose)

~~~
docker exec -it tauranet-backend-container bash
~~~

# Frontend

## Ejecución normal

```
npm install
```

### Compiles and hot-reloads for development
```
npm run serve
```

### Compiles and minifies for production
```
npm run build
```

### Run your tests
```
npm run test
```

### Lints and fixes files

```
npm run lint
```

## Dockerización

### Contruir imagén

~~~
docker build -t tauranet-frontend-image .
~~~

### Construir contenedor

~~~
docker run -p 8085:8080 -it --name=tauranet-frontend-container tauranet-frontend-image-dos
~~~

# Ejecutar con docker compose

~~~
docker-compose up --build
~~~

### Reiniciar un servicio en especifico

~~~
docker-compose restart backend
~~~

### Ejecutar un servicio que ya iniciado

~~~
docker-compose exec backend bash
~~~

### Para ver logs con cat

~~~
cat laravel.log
~~~

### Instalar el editor de texto Nano en el contenedor

~~~
apt-get update && apt-get install nano
~~~

## Modificaciones que se hicieron para cambiar codigo en tiempo real Backend (esto no es necesario para el cliente)
1. Para ver cambios en el codigo en tiempo real añadir volumen

~~~
volumes:
  - ./tauranet-backend:/var/www
~~~

2. Dentro del archivo **php.ini** que se encuentra en **/usr/local/etc/php/php.ini** añadir la configuración ***opcache.enable=0***

3. Para editar el texto instalar **nano** con el comando:

~~~
apt-get update && apt-get install nano
~~~

2. Añadido el volumen hay que instalar las dependencias manualmente

~~~
docker-compose exec backend composer install
~~~

## Backup de la base de datos

Exporta en formato plano en el directorio de donde se encuentra la terminal

~~~
docker-compose exec -t db pg_dump -U postgres -F c tauranet_db > tauranet_db_backup
~~~

Esportar en formato directo, útil para backups grandes

~~~
pg_dump -F d -f /ruta/directorio_backup -U postgres -d midb
~~~

## Aclaraciones Base de datos

La tabla **venta_productos** tiene el detalle del grupo de productos vendidos en una sola venta y la tabla **producto_vendidos** tiene detalle por producto como cantidad, precio, etc

## Diccionario de datos - BD

Tabla: pagos
Campo: tipo_pago 0 -> efectivo, 1 -> tarjeta, 2 -> qr









