#!/bin/sh

set -o errexit
set -o pipefail
set -o nounset

if ! [ -z ${PHP_SERVER-} ]; then
  while ! ping -c 1 -n $PHP_SERVER &> /dev/null
  do
    sleep 2
  done
fi

mkdir -p                            \
  /var/www/html/public/             \
  /var/www/logs/nginx/              \
  /var/www/configs/nginx/           \
&& touch                            \
  /var/www/configs/nginx/host.conf  \
&& chown 1000:1000                  \
  /var/www/html/public/             \
  /var/www/logs/nginx/              \
  /var/www/configs/nginx/           \
  /var/www/configs/nginx/host.conf

if [ -z ${DOMAIN-} ]; then
  echo you need to define a domain
  exit 1
fi

"$@"