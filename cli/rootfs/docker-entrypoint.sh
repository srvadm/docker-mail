#!/bin/sh

if [ -z ${TZ-} ]; then
  # check for correct timezone format
  echo you need to define a timezone
  exit 1
fi

"$@"
