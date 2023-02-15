FROM php:fpm-alpine

RUN apk add --no-cache \
    bash \
    git

# Install PHP module
RUN docker-php-ext-install pdo_mysql

# Install PHP GD module
RUN apk add --update --no-cache \
  libjpeg-turbo-dev \
  libwebp-dev \
  libpng-dev
RUN docker-php-ext-configure gd --with-jpeg
RUN docker-php-ext-install -j$(nproc) gd

# Set time zone
RUN apk --no-cache add tzdata && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    apk del tzdata

# Install LEMP middleware
RUN apk add -U --no-cache \
    supervisor \
    nginx \
    mariadb \
    mariadb-client

# nginx config
COPY --chmod=644 nginx/nginx.conf /etc/nginx/nginx.conf
COPY --chmod=644 nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

# MariaDB configration
COPY --chmod=644 mysql/server.cnf /etc/my.cnf.d/

# PHP sample program
COPY \
    php/sample/index.php \
    php/sample/index2.php \
    /var/www/html/

# supervisor config
COPY --chmod=644 \
    mysql/mysql.ini \
    nginx/nginx.ini \
    php/php-fpm.ini \
    /etc/supervisor.d/

# entrypoint
COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh

# ports
EXPOSE 80

# commands
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["supervisord", "-n", "-j", "/supervisord.pid"]
