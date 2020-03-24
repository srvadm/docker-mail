FROM nginx:1.17-alpine
LABEL maintainer="Tino Naumann <mail@ti-no.de>"

RUN apk add --no-cache --update-cache \
  tzdata                              \
  shadow                              \
  && usermod -u 1000 www-data         \
  && groupmod -g 1000 www-data

COPY rootfs /
RUN mkdir -p /var/www/html/public/ /var/www/logs/nginx/ /var/www/configs/nginx/                 \
  && chown www-data:www-data /var/www/html/public/ /var/www/logs/nginx/ /var/www/configs/nginx/

USER www-data:www-data
VOLUME ["/var/www"]
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]