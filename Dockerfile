FROM php:8.3-apache

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl unzip libzip-dev libjpeg-dev libpng-dev \
    libfreetype6-dev libicu-dev libxml2-dev libxslt-dev \
    libldap2-dev libpq-dev zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Install required PHP extensions for Moodle
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        mysqli pdo pdo_mysql zip gd intl soap exif xsl ldap

# Enable opcache separately
RUN docker-php-ext-enable opcache

# Set recommended PHP settings for Moodle
RUN echo "max_input_vars = 5000" >> /usr/local/etc/php/conf.d/moodle.ini \
    && echo "upload_max_filesize = 512M" >> /usr/local/etc/php/conf.d/moodle.ini \
    && echo "post_max_size = 512M" >> /usr/local/etc/php/conf.d/moodle.ini \
    && echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/moodle.ini \
    && echo "max_execution_time = 300" >> /usr/local/etc/php/conf.d/moodle.ini \
    && echo "opcache.enable = 1" >> /usr/local/etc/php/conf.d/moodle.ini \
    && echo "opcache.memory_consumption = 128" >> /usr/local/etc/php/conf.d/moodle.ini
RUN echo "display_errors = Off" >> /usr/local/etc/php/conf.d/moodle.ini

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Download Moodle (change MOODLE_405_STABLE to your desired version)
RUN git clone --depth=1 -b MOODLE_501_STABLE git://git.moodle.org/moodle.git /var/www/html \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Create moodledata directory
RUN mkdir -p /var/moodledata \
    && chown -R www-data:www-data /var/moodledata \
    && chmod -R 777 /var/moodledata

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]