# Use official PHP-Apache image
FROM php:8.2-apache

# Enable mysqli
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli

# Copy your PHP app into the container
COPY . /var/www/html/

# Apache runs on port 80 by default
EXPOSE 80
