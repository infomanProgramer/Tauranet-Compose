## Comandos Docker

**Importante!!!** Cualquier de estos comando ejecutar desde el directorio raiz del proyecto

### Ingresar al terminal del backend

~~~
docker-compose exec backend bash
~~~

### Ver lista de rutas laravel (backend)

~~~
docker-compose run backend php artisan route:list
~~~

### Error de limite de memoria en composer:

~~~
php -d memory_limit=-1 /usr/local/bin/composer require maatwebsite/excel
~~~

### Instalar librerias NPM (frontend)

**Opcion 1**

Ingresar al contenedor del frontend con el comando

~~~
docker-compose exec frontend bash
~~~

o

~~~
docker-compose exec frontend sh
~~~

**Opción 2**

Ejecutar directamente desde la linea de comandos

~~~
docker-compose exec frontend npm install xlsx file-saver
~~~

