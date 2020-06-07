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

if ! [ -f /var/www/configs/nginx/.init.done ]; then
  cp -a /tmp/init/* / && touch /var/www/configs/nginx/.init.done
fi

"$@"
