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


