FROM ubuntu:14.04
MAINTAINER Emerson Estrella <emerson.estrella@gmail.com>

# Update apt-get local index
RUN DEBIAN_FRONTEND=noninteractive apt-get -qq update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y upgrade

# Install nginx
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install nginx

# Install MySQL
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server mysql-client

# Install Redis
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install redis-server

# Install PHP
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php5-fpm php5-mysql php-apc php5-curl php5-intl php5-mcrypt php5-memcache

# Install other requirements
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install curl git unzip

# mysql config
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

# nginx config
RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
RUN sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# nginx site configuration
RUN update-rc.d nginx defaults

# PHP-FPM configuration
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php5/fpm/pool.d/www.conf
RUN find /etc/php5/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

# # PHP configuration
# ENV PHP_INI_DIR /usr/local/etc/php
# RUN mkdir -p $PHP_INI_DIR/conf.d

# COPY docker-php-ext-* /usr/local/bin/
# WORKDIR /var/www/html
# COPY php-fpm.conf /usr/local/etc/

# Start nginx
# RUN service nginx start

# Start MySQL
# RUN service mysql start

# Start Redis
# RUN redis-server start

# Expose ports
EXPOSE 3000
EXPOSE 3306
EXPOSE 80

CMD ["/bin/bash", "service mysql start", "redis-server start", "service nginx start"]
