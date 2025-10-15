# Si la instalación es con docker

## Antes de nada cargar las variables de entorno

~~~
$env:DB_HOST="host.docker.internal"
$env:DB_PORT="25432"
$env:DB_DATABASE="tauranet_db"
$env:DB_USERNAME="postgres"
$env:DB_PASSWORD="pgadmin1325"

$env:POSTGRES_USER="postgres"
$env:POSTGRES_PASSWORD="pgadmin1325"
$env:POSTGRES_DB="tauranet_db"
~~~

## Primero ejecutar docker compose de produccion

~~~
docker compose -p prod -f docker-compose.prod.yml up -d --build
~~~

## Luego ejecutar docker compose de desarrollo

~~~
docker compose -p dev -f docker-compose.dev.yml up -d --build
~~~

## Para ingresar a la terminal en modo terminal interactivo

~~~
docker exec -it tauranet-backend-dev bash
~~~

# Si la instalación es sin docker

## Windows Shell (solo sesión actual)

~~~
$env:DB_HOST="localhost"
$env:DB_PORT="5432"
$env:DB_DATABASE="tauranet_db"
$env:DB_USERNAME="postgres"
$env:DB_PASSWORD="tu_password"
~~~

## Winwos Variables persistentes

~~~
setx DB_HOST "localhost"
setx DB_PORT "5432"
setx DB_DATABASE "tauranet_db"
setx DB_USERNAME "postgres"
setx DB_PASSWORD "tu_password"
~~~

Cierra y reabre la terminal para que apliquen.

## Linux/macOS (solo sesión actual)

~~~
export DB_HOST="localhost"
export DB_PORT="5432"
export DB_DATABASE="tauranet_db"
export DB_USERNAME="postgres"
export DB_PASSWORD="tu_password"

php artisan serve
~~~

## Producción sin docker

- Apache: usa PassEnv o SetEnv en www.conf o FPM o fastcgi_param adecuado

Tras cambiar varialbes, limpia cache de config si aplicaste config:cache

~~~
php artisan config:clear
php artisan config:cache
~~~


