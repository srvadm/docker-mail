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

RUN mv                                      \
    /usr/local/etc/php/php.ini-production   \
    /usr/local/etc/php/php.ini              \
  && rm                                     \
    /usr/local/etc/php/php.ini-development
RUN curl -s -L \
  https://api.github.com/repos/roundcube/roundcubemail/tarball \
  | tar xzvf - --one-top-level="roundcube" --strip-components \
  && mv                                     \
    roundcube/*                       \
    /var/www/html/public/                   \
  && rm -r                                  \
    roundcube                               \
  && chown -R www-data:www-data             \
    /var/www/html

VOLUME ["/var/www"]
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["php-fpm"]
