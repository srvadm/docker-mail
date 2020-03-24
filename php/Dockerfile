FROM php:7.4-fpm-alpine
LABEL maintainer="Tino Naumann <mail@ti-no.de>"

RUN apk add --no-cache --update-cache \
  tzdata                              \
  curl                                \
  shadow                              \
  && usermod -u 1000 www-data         \
  && groupmod -g 1000 www-data
RUN apk add --no-cache --update-cache libzip-dev libpng-dev \
  && docker-php-ext-install mysqli                          \
  && docker-php-ext-install pdo_mysql                       \
  && rm -rf /var/cache/apk/*

COPY rootfs /
RUN mv                                      \
    /usr/local/etc/php/php.ini-production   \
    /usr/local/etc/php/php.ini              \
  && rm                                     \
    /usr/local/etc/php/php.ini-development

VOLUME ["/var/www"]
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["php-fpm"]