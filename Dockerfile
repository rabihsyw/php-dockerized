################################################################################
# Base image
################################################################################

FROM nginx

################################################################################
# Build instructions
################################################################################

# Remove default nginx configs.
RUN rm -f /etc/nginx/conf.d/*

# Install packages
RUN apt-get update && apt-get install -my \
  supervisor \
  curl \
  librabbitmq-dev \
  librabbitmq1 \
  wget \
  php5-curl \
  php5-dev \
  php5-fpm \
  php5-gd \
  php5-memcached \
  php5-mysql \
  php5-mcrypt \
  php5-mongo \
  php-pear \
  php5-sqlite \
  php5-xdebug \
  php-apc \
  php5-redis \
  vim

# Ensure that PHP5 FPM is run as root.
RUN sed -i "s/user = www-data/user = root/" /etc/php5/fpm/pool.d/www.conf
RUN sed -i "s/group = www-data/group = root/" /etc/php5/fpm/pool.d/www.conf

# Pass all docker environment
RUN sed -i '/^;clear_env = no/s/^;//' /etc/php5/fpm/pool.d/www.conf

# Get access to FPM-ping page /ping
RUN sed -i '/^;ping\.path/s/^;//' /etc/php5/fpm/pool.d/www.conf
# Get access to FPM_Status page /status
RUN sed -i '/^;pm\.status_path/s/^;//' /etc/php5/fpm/pool.d/www.conf

# Prevent PHP Warning: 'xdebug' already loaded.
# XDebug loaded with the core
RUN sed -i '/.*xdebug.so$/s/^/;/' /etc/php5/mods-available/xdebug.ini

# Install AMQP extension for php
RUN pecl install amqp && \
	echo "extension=amqp.so" > /etc/php5/mods-available/amqp.ini && \
	php5enmod amqp

# Add configuration files
COPY conf/nginx.conf /etc/nginx/
COPY conf/supervisord.conf /etc/supervisor/conf.d/
COPY conf/php.ini /etc/php5/fpm/conf.d/40-custom.ini

################################################################################
# Volumes
################################################################################

VOLUME ["/var/www", "/etc/nginx/conf.d"]

################################################################################
# Ports
################################################################################

EXPOSE 80 443 9000

################################################################################
# Entrypoint
################################################################################

ENTRYPOINT ["/usr/bin/supervisord"]
