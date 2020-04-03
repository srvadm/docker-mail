FROM php:7.4-fpm-alpine
LABEL maintainer="Tino Naumann <mail@ti-no.de>"

RUN apk add --no-cache --update-cache \
  tzdata                              \
  curl                                \
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

RUN mv                                        \
    /usr/local/etc/php/php.ini-production     \
    /usr/local/etc/php/php.ini                \
  && rm                                       \
    /usr/local/etc/php/php.ini-development    \
  && curl -sL v                               \
    https://api.github.com/repos/roundcube/roundcubemail/tarball \
    | tar xzf -                               \
    -C /var/www/html                          \
    --one-top-level="public"                  \
    --strip-components 1                      \
  && curl -sL                                 \
    https://getcomposer.org/installer         \
    | php --                                  \
    --install-dir=/var/www/html/public        \
    --filename=composer                       \
  && mv                                       \
    /var/www/html/public/composer.json-dist   \
    /var/www/html/public/composer.json        \
  && php                                      \
    /var/www/html/public/composer install     \
    --no-dev                                  \
    -d /var/www/html/public                   \
  && ls -la /var/www/html/public/             \
  && curl -sL                                 \
    https://www.adminer.org/latest-mysql.php  \
    -o /var/www/html/public/db.php            \
  && curl -sL                                 \
    https://raw.githubusercontent.com/vrana/adminer/master/designs/pepa-linha/adminer.css \
    -o /var/www/html/public/adminer.css       \
  && chown -R www-data:www-data               \
    /var/www/html

VOLUME ["/var/www/"]
RUN ls -la /var/www/html/public/
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["php-fpm"]
