#!/bin/sh

if [ -z ${DOMAIN-} ]; then
  echo you need to define a domain
  exit 1
fi

"$@"