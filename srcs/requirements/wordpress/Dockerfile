FROM alpine:3.23.3

RUN apk update && apk upgrade && apk add --no-cache \
    php83 \
    php83-fpm \
    php83-mysqli \
    php83-curl \
    php83-gd \
    php83-mbstring \
    php83-xml \
    php83-zip \
    php83-phar \
    php83-openssl \
    php83-dom \
    php83-simplexml \
    php83-exif \
    php83-fileinfo \
    php83-iconv \
    php83-session \
    php83-tokenizer \
    php83-pecl-imagick \
    mariadb-client \
    curl

RUN ln -sf /usr/bin/php83 /usr/bin/php

RUN curl -fsSL -o /usr/local/bin/wp \
    https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

RUN mkdir -p /var/www/html

RUN echo "memory_limit = 256M" >> /etc/php83/php.ini

COPY conf/www.conf /etc/php83/php-fpm.d/www.conf

COPY tools/init_wp.sh /init_wp.sh
RUN chmod +x /init_wp.sh

# php-fpm が待ち受けるポート
# Dockerネットワーク内部のみ
EXPOSE 9000

ENTRYPOINT ["/init_wp.sh"]
