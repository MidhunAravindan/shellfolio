# Use a base image with Apache and PHP
FROM php:7.4-apache

# Install SSL dependencies
RUN apt-get update && apt-get install -y \
    ssl-cert \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache SSL module
RUN a2enmod ssl
RUN a2enmod rewrite

# Create SSL directory
RUN mkdir -p /etc/apache2/ssl
RUN chmod 755 /etc/apache2/ssl

# Copy website files
COPY . /var/www/html/

# Copy SSL certificates
COPY ssl/certificate.crt /etc/apache2/ssl/
COPY ssl/private.key /etc/apache2/ssl/
COPY ssl/ca_bundle.crt /etc/apache2/ssl/

# Set proper permissions for SSL certificates
RUN chmod 644 /etc/apache2/ssl/certificate.crt \
    && chmod 644 /etc/apache2/ssl/ca_bundle.crt \
    && chmod 640 /etc/apache2/ssl/private.key

# Copy Apache configuration
COPY apache-ssl.conf /etc/apache2/sites-available/000-default.conf

# Enable the site
RUN a2ensite 000-default.conf

# Expose ports
EXPOSE 80
EXPOSE 443

# Start Apache
CMD ["apache2-foreground"]