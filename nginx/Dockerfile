FROM nginx:1.17-alpine
LABEL maintainer="Tino Naumann <mail@ti-no.de>"

COPY rootfs /

RUN mkdir -p                                 \
  /tmp/init/var/www/html/public/             \
  /tmp/init/var/www/logs/nginx/              \
  /tmp/init/var/www/configs/nginx/           \
&& touch                                     \
  /tmp/init/var/www/configs/nginx/host.conf  \
  /tmp/init/var/www/configs/nginx/mail.conf  \
&& chown 1000:1000                           \
  /tmp/init/var/www/html/public/             \
  /tmp/init/var/www/logs/nginx/              \
  /tmp/init/var/www/configs/nginx/           \
  /tmp/init/var/www/configs/nginx/host.conf

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
