@echo off
setlocal
title Starting Tauranet...

:: CONFIGURATION
set SITE_URL=http://localhost:8080
set WAIT_SECONDS=10
set COMPOSE_FILE=docker-compose.prod.yml
set PROJECT_NAME=prod

:: Check if Docker is running
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo Docker Desktop is not running. Attempting to start it...
    start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    timeout /t %WAIT_SECONDS% /nobreak >nul
)

:: Start existing containers for the "prod" project
docker compose -p %PROJECT_NAME% -f %COMPOSE_FILE% start

echo Containers started successfully.
timeout /t 2 >nul

:: Open the browser
start "" "C:\Program Files\Google\Chrome\Application\chrome.exe" --incognito "%SITE_URL%"

echo System ready.
timeout /t 2 >nul
exit /b 0
