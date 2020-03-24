#!/bin/sh

if ! [ -f "/var/www/configs/nginx/host.conf" ]; then
  touch /var/www/configs/nginx/host.conf
  chown 1000:1000 /var/www/configs/nginx/host.conf
fi

if [ -z ${DOMAIN-} ]; then
  echo you need to define a domain
  exit 1
fi

"$@"