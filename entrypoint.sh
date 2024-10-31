#!/bin/bash
cd /var/www/backend && composer install
cd /var/www/backend && php artisan key:generate
cd /var/www/backend && php artisan migrate:refresh
cd /var/www/backend && php artisan passport:install --force


# Esegui il comando principale (es. php-fpm o altro)
exec "$@"
