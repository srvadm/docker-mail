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

if [ -d "/tmp/init" ]; then
  cp -a /tmp/init/* / && rm -r /tmp/init/
fi

"$@"
