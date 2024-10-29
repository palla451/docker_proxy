# Stage 1: Costruzione del frontend con Node.js
FROM node:16 AS frontend_build

# Directory di lavoro per il frontend
WORKDIR /var/www/frontend

# Copia solo la cartella del frontend
COPY ./www/frontend ./

# Installa le dipendenze e crea il build del frontend
RUN npm install
RUN npm run build  # Questo genera la cartella dist

############################################

# Stage 2: PHP-FPM per il backend con tutti i file necessari
FROM php:8.2-fpm

# Setta la directory di lavoro per PHP-FPM
WORKDIR /var/www

# Installa le dipendenze per PHP
RUN apt-get update && apt-get install -y \
    build-essential \
    nano \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    libonig-dev \
    libzip-dev \
    libgd-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Installa le estensioni PHP
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl && \
    docker-php-ext-configure gd --with-external-gd && \
    docker-php-ext-install gd

# Installa Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Aggiungi un utente per l'applicazione
RUN groupadd -g 1000 www && \
    useradd -u 1000 -ms /bin/bash -g www www

# Copia i file del backend nella nuova directory di lavoro
COPY --chown=www:www ./www /var/www

# Copia i file del frontend generati nel primo stage
COPY --from=frontend_build /var/www/frontend/dist /var/www/frontend/dist

# Imposta l'utente per eseguire i comandi successivi
USER www

# Espone la porta 9000 e avvia PHP-FPM
EXPOSE 9000
CMD ["php-fpm"]
