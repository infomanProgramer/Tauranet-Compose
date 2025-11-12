FROM php:7.2-apache

# Instalar dependencias del sistema necesarias para extensiones
RUN sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list \
 && sed -i '/security.debian.org/d' /etc/apt/sources.list \
 && apt-get update \
 && apt-get install -y \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libzip-dev \
    libpq-dev \
    ca-certificates \
    zip \
    unzip \
    git \
    curl

# Instalar extensiones de PHP
RUN docker-php-ext-configure gd \
        --with-freetype-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install \
        pdo \
        pdo_pgsql \
        pgsql \
        mbstring \
        exif \
        bcmath \
        zip \
        gd

# Habilitar mod_rewrite de Apache
RUN a2enmod rewrite
RUN sed -ri 's/AllowOverride\s+None/AllowOverride All/i' /etc/apache2/apache2.conf
# Cambiar DocumentRoot a /var/www/public
RUN sed -i 's|/var/www/html|/var/www/public|g' /etc/apache2/sites-available/000-default.conf

# Instalar Composer 1.8.6
RUN curl -sS https://getcomposer.org/download/1.8.6/composer.phar -o /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer

WORKDIR /var/www

COPY composer.json ./

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_MEMORY_LIMIT=-1
RUN composer --version \
 && composer config -g repos.packagist composer https://repo.packagist.org \
 && composer clear-cache || true \
 && composer diagnose || true \
 && composer install --no-interaction --prefer-dist --no-dev --optimize-autoloader --no-scripts -vvv

COPY . .

RUN printf '#!/usr/bin/env bash\n' > /usr/local/bin/start.sh \
 && printf 'set -euo pipefail\n\n' >> /usr/local/bin/start.sh \
 && printf 'mkdir -p /var/www/bootstrap/cache\n' >> /usr/local/bin/start.sh \
 && printf 'chmod -R 777 /var/www/storage /var/www/bootstrap/cache || true\n' >> /usr/local/bin/start.sh \
 && printf 'chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache || true\n\n' >> /usr/local/bin/start.sh \
 && printf 'if [ -f .env ]; then\n' >> /usr/local/bin/start.sh \
 && printf '  if ! grep -q "^APP_KEY=\\S\\+" .env; then\n' >> /usr/local/bin/start.sh \
 && printf '    php artisan key:generate --force\n' >> /usr/local/bin/start.sh \
 && printf '  fi\n' >> /usr/local/bin/start.sh \
 && printf 'fi\n\n' >> /usr/local/bin/start.sh \
 && printf 'php artisan config:clear || true\n' >> /usr/local/bin/start.sh \
 && printf 'php artisan route:clear || true\n' >> /usr/local/bin/start.sh \
 && printf 'php artisan view:clear || true\n' >> /usr/local/bin/start.sh \
 && printf 'php artisan package:discover --ansi || true\n' >> /usr/local/bin/start.sh \
 && printf 'php artisan config:cache || true\n' >> /usr/local/bin/start.sh \
 && printf 'php artisan route:cache || true\n\n' >> /usr/local/bin/start.sh \
 && printf 'php artisan storage:link || true\n\n' >> /usr/local/bin/start.sh \
 && printf 'apache2-foreground\n' >> /usr/local/bin/start.sh \
 && chmod +x /usr/local/bin/start.sh \
 && sed -i 's/\r$//' /usr/local/bin/start.sh

RUN printf "; custom php.ini for Laravel + PostgreSQL\n" \
    > /usr/local/etc/php/conf.d/zzz-custom.ini \
 && printf "memory_limit = 512M\n" \
    >> /usr/local/etc/php/conf.d/zzz-custom.ini \
 && printf "upload_max_filesize = 100M\n" \
    >> /usr/local/etc/php/conf.d/zzz-custom.ini \
 && printf "post_max_size = 100M\n" \
    >> /usr/local/etc/php/conf.d/zzz-custom.ini

RUN mkdir -p /var/www/bootstrap/cache \
    && chmod -R 777 /var/www/storage /var/www/bootstrap/cache \
    && chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Exponer el puerto de PHP-FPM
EXPOSE 80

CMD ["start.sh"]
