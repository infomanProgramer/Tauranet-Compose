#!/usr/bin/env bash
set -euo pipefail

# Ensure correct permissions for storage and cache
mkdir -p /var/www/bootstrap/cache
chmod -R 777 /var/www/storage /var/www/bootstrap/cache || true
chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache || true

# Generate APP_KEY if missing
if [ -f .env ]; then
  if ! grep -q "^APP_KEY=\S\+" .env; then
    php artisan key:generate --force
  fi
fi

# Production caches
php artisan config:clear || true
php artisan route:clear || true
php artisan view:clear || true
php artisan config:cache || true
php artisan route:cache || true

# Storage link (ignore if exists)
php artisan storage:link || true

# Start Apache in foreground
apache2-foreground
