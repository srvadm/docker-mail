#!/bin/sh

mkdir -p /var/www/html/public /var/www/logs/nginx /var/www/configs/nginx

if ! [ -f "/var/www/configs/nginx/host.conf" ]; then
  touch /var/www/configs/nginx/host.conf
fi
chown 1000:1000 -R /var/www/configs/nginx/ /var/www/logs/nginx/

if [ -z ${DOMAIN-} ]; then
  echo you need to define a domain
  exit 1
fi

"$@"