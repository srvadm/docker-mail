FROM nginx:1.17-alpine
LABEL maintainer="Tino Naumann <mail@ti-no.de>"

COPY rootfs /
RUN mkdir -p /var/www/html/public/ /var/www/logs/nginx/ /var/www/configs/nginx/                 \
  && chown 1000:1000 /var/www/html/public/ /var/www/logs/nginx/ /var/www/configs/nginx/

VOLUME ["/var/www"]
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]