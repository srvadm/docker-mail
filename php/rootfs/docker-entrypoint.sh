#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

mkdir -p                    \
  /var/www/html/public/     \
  /var/www/logs/php/        \
  /var/www/configs/php/     \
&& chown www-data:www-data  \
  /var/www/html/public/     \
  /var/www/logs/php/        \
  /var/www/configs/php/

if [ -z ${MYSQL_USER-} ]; then
  echo you need to define a mysql user
  exit 1
fi
if [ -z ${MYSQL_PASSWORD-} ]; then
  echo you need to define a mysql user password
  exit 1
fi
if [ -z ${MYSQL_DATABASE-} ]; then
  echo you need to define a mysql database
  exit 1
fi
if [ -z ${DOMAIN-} ]; then
  # check for correct domain format
  echo you need to define a processwire domain
  exit 1
fi
if [ -z ${TZ-} ]; then
  # check for correct timezone format
  echo you need to define a timezone
  exit 1
fi

cat << EOF | php --
<?php
\$connected = false;
while(!\$connected) {
  try{
    \$dbh = new pdo(
      'mysql:host=mysql:3306;dbname=$MYSQL_DATABASE', '$MYSQL_USER', '$MYSQL_PASSWORD',
      array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
    );
    \$connected = true;
  }
  catch(PDOException \$ex){
    error_log("Could not connect to MySQL");
    error_log(\$ex->getMessage());
    error_log("Waiting for MySQL Connection.");
    sleep(5);
  }
}
EOF

"$@"
