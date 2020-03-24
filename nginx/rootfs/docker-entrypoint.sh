#!/bin/sh

set -o errexit
set -o pipefail
set -o nounset

if [ -z ${DOMAIN-} ]; then
  echo you need to define a domain
  exit 1
fi

"$@"