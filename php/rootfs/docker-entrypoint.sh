#!/bin/sh

set -o errexit
set -o pipefail
set -o nounset

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

if ! [ -f '/var/www/html/public/config/config.inc.php' ]; then
  cat << EOF > /var/www/html/public/config/config.inc.php
<?php
\$config = array();
\$config['db_dsnw'] = 'mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@mysql/${MYSQL_DATABASE}';
\$config['db_prefix'] = '$(pwgen -s -A -0 -1 2)_';
\$ssl_no_check = array(
 'ssl' => array(
     'verify_peer' => false,
     'verify_peer_name' => false,
  ),
);
\$config['imap_conn_options'] = \$ssl_no_check;
\$config['smtp_conn_options'] = \$ssl_no_check;
\$config['managesieve_conn_options'] = \$ssl_no_check;
\$config['default_host'] = 'tls://dovecot';
\$config['smtp_server'] = 'tls://postfix';
\$config['des_key'] = '$(pwgen -s -c -n -1 24)';
\$config['plugins'] = array();
EOF
chown www-data: /var/www/html/public/config/config.inc.php
fi

"$@"
