#!/bin/sh

set -o errexit
set -o pipefail
set -o nounset

if [ -z ${DOMAIN-} ]; then
  echo you need to define a domain
  exit 1
fi

while ! [ $(nc -z php 9000; echo $?) -eq 0 ]
do
  echo "Waiting for PHP Connection."
  sleep 5
done

mkdir -p                            \
  /var/www/html/public/             \
  /var/www/logs/nginx/              \
  /var/www/configs/nginx/           \
&& touch                            \
  /var/www/configs/nginx/host.conf  \
  /var/www/configs/nginx/mail.conf  \
&& chown 1000:1000                  \
  /var/www/html/public/             \
  /var/www/logs/nginx/              \
  /var/www/configs/nginx/           \
  /var/www/configs/nginx/host.conf

"$@"
