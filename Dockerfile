FROM ubuntu:14.04
MAINTAINER Emerson Estrella <emerson.estrella@gmail.com>

RUN DEBIAN_FRONTEND=noninteractive

# Update apt-get local index
RUN apt-get -qq update

# Install nginx
RUN apt-get -y --force-yes --force-yes install nginx

# Install MySQL
RUN DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes install mysql-server mysql-client

# Install Redis
RUN DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes install redis-server

# Install PHP
RUN DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes install php5-cli php5-fpm php5-mysql php-apc php5-curl php5-intl php5-mcrypt php5-memcache php5-imap php5-tidy

# Install other requirements
RUN DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes install curl git unzip

# mysql config
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

# PHP configuration
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/fpm/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/cli/php.ini

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini

RUN mkdir -p        /var/www
ADD files/default   /etc/nginx/sites-available/default
RUN mkdir -p        /etc/service/nginx
ADD files/nginx.sh  /etc/service/nginx/run
RUN chmod +x        /etc/service/nginx/run
RUN mkdir -p        /etc/service/phpfpm
ADD files/phpfpm.sh /etc/service/phpfpm/run
RUN chmod +x        /etc/service/phpfpm/run

VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"]

# Start MySQL
CMD service mysql start

# Start Redis
CMD redis-server start

# Start php
CMD service nginx start

# Start nginx
CMD service nginx start

# Expose ports
EXPOSE 80
EXPOSE 443

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
