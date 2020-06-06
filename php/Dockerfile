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

# to fix "session_start(): open(/tmp/sess_mjveer0ajfv2fb5n1qiag9an6s, O_RDWR) failed: Permission denied (13)"
RUN chmod o+w /tmp
###

RUN mv                                                \
    /usr/local/etc/php/php.ini-production             \
    /usr/local/etc/php/php.ini                        \
  && rm                                               \
    /usr/local/etc/php/php.ini-development            \
  && mkdir -p                                         \
    /tmp/init/var/www/html/public/                    \
    /tmp/init/var/www/logs/php/                       \
    /tmp/init/var/www/configs/php/                    \
  && curl -sL                                         \
    ${ROUNDCUBE_URL}                                  \
    | tar xzf -                                       \
    -C /tmp/init/var/www/html/public                  \
    --strip-components 1                              \
  && rm -r                                            \
    /tmp/init/var/www/html/public/CHANGELOG           \
    /tmp/init/var/www/html/public/INSTALL             \
    /tmp/init/var/www/html/public/LICENSE             \
    /tmp/init/var/www/html/public/README.md           \
    /tmp/init/var/www/html/public/UPGRADING           \
    /tmp/init/var/www/html/public/composer.json-dist  \
    /tmp/init/var/www/html/public/installer           \
  && curl -sL                                         \
    https://www.adminer.org/latest-mysql.php          \
    -o /tmp/init/var/www/html/public/db.php           \
  && curl -sL                                         \
    https://raw.githubusercontent.com/vrana/adminer/master/designs/pepa-linha/adminer.css \
    -o /tmp/init/var/www/html/public/adminer.css      \
  && chown -R www-data:www-data                       \
    /tmp/init/var/www/html/public/                    \
    /tmp/init/var/www/logs/php/                       \
    /tmp/init/var/www/configs/php/

VOLUME ["/var/www"]
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["php-fpm"]
