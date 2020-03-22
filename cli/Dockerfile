FROM php:7.4-fpm-alpine
LABEL maintainer="Tino Naumann <mail@ti-no.de>"

RUN apk add --no-cache --update-cache tzdata shadow \
  && usermod -u 1000 www-data                       \
  && groupmod -g 1000 www-data

COPY rootfs /
RUN mv /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
  && rm /usr/local/etc/php/php.ini-development

RUN mkdir -p /var/www/html/public/ /var/www/logs/php/ /var/www/configs/php/ /var/www/bin/                 \
  && chown www-data:www-data /var/www/html/public/ /var/www/logs/php/ /var/www/configs/php/ /var/www/bin/
USER www-data:www-data

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["php-fpm"]