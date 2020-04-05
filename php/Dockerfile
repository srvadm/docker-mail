FROM php:7.4-fpm-alpine
LABEL maintainer="Tino Naumann <mail@ti-no.de>"

RUN apk add --no-cache --update-cache \
  tzdata                              \
  curl                                \
  pwgen                               \
  shadow                              \
  && usermod -u 1000 www-data         \
  && groupmod -g 1000 www-data

RUN apk add --no-cache --update-cache \
    libzip-dev                        \
    libpng-dev                        \
    icu-dev                           \
  && docker-php-ext-install mysqli    \
  && docker-php-ext-install pdo_mysql \
  && docker-php-ext-install intl      \
  && docker-php-ext-install exif      \
  && docker-php-ext-install gd        \
  && docker-php-ext-install zip       \
  && rm -rf /var/cache/apk/*

COPY rootfs /

ENV ROUNDCUBE_URL https://github.com/roundcube/roundcubemail/releases/download/1.4.3/roundcubemail-1.4.3-complete.tar.gz
                  
RUN mv                                        \
    /usr/local/etc/php/php.ini-production     \
    /usr/local/etc/php/php.ini                \
  && rm                                       \
    /usr/local/etc/php/php.ini-development    \
  && mkdir -p                                 \
    /var/www/html/public/                     \
    /var/www/logs/php/                        \
    /var/www/configs/php/                     \
  && curl -sL v                               \
    ${ROUNDCUBE_URL}                          \
    | tar xzf -                               \
    -C /var/www/html/public                   \
    --strip-components 1                      \
  && rm -rootfs                               \
    CHANGELOG                                 \
    INSTALL                                   \
    LICENSE                                   \
    README.md                                 \
    UPGRADING                                 \
    composer.json-dist                        \
    installer                                 \
  && curl -sL                                 \
    https://www.adminer.org/latest-mysql.php  \
    -o /var/www/html/public/db.php            \
  && curl -sL                                 \
    https://raw.githubusercontent.com/vrana/adminer/master/designs/pepa-linha/adminer.css \
    -o /var/www/html/public/adminer.css       \
  && chown www-data:www-data                  \
    /var/www/html/public/                     \
    /var/www/logs/php/                        \
    /var/www/configs/php/

VOLUME ["/var/www"]
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["php-fpm"]
