@echo off
setlocal
title Arrancando Tauranet (producción)...

:: CONFIGURACION
set SITE_URL=http://localhost:8080
set WAIT_SECONDS=10
set COMPOSE_FILE=docker-compose.prod.yml
set PROJECT_NAME=prod

:: Verificar si Docker está corriendo
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo Docker Desktop no esta corriendo. Intentando iniciarlo...
    start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    timeout /t %WAIT_SECONDS% /nobreak >nul
)

:: Arrancar contenedores existentes del proyecto "prod"
docker compose -p %PROJECT_NAME% -f %COMPOSE_FILE% start

echo Contenedores iniciados correctamente.
timeout /t 2 >nul

:: Abrir el navegador
start "" "C:\Program Files\Google\Chrome\Application\chrome.exe" --incognito "%SITE_URL%"

echo Sistema Tauranet listo.
timeout /t 2 >nul
exit /b 0
