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

if ! [ -f '/var/www/configs/php/init.sql' ]; then
cat << EOF | php --
<?php
\$filename = '/var/www/configs/php/init.sql';
\$mysql_host = 'mysql';
\$mysql_username = '$MYSQL_USER';
\$mysql_password = '$MYSQL_PASSWORD';
\$mysql_database = '$MYSQL_DATABASE';

// Connect to MySQL server
\$con = @new mysqli(\$mysql_host,\$mysql_username,\$mysql_password,\$mysql_database);

// Check connection
if (\$con->connect_errno) {
  echo "Failed to connect to MySQL: " . \$con->connect_errno;
  echo "<br/>Error: " . \$con->connect_error;
}

// Temporary variable, used to store current query
\$templine = '';
// Read in entire file
\$lines = file(\$filename);
// Loop through each line
foreach (\$lines as \$line) {
// Skip it if it's a comment
  if (substr(\$line, 0, 2) == '--' || \$line == '')
    continue;

// Add this line to the current segment
  \$templine .= \$line;
// If it has a semicolon at the end, it's the end of the query
  if (substr(trim(\$line), -1, 1) == ';') {
      // Perform the query
      \$con->query(\$templine) or print('Error performing query \'<strong>' . \$templine . '\': ' . \$con->error() . '<br /><br />');
      // Reset temp variable to empty
      \$templine = '';
  }
}
echo "Tables imported successfully";
\$con->close();
EOF
  rm /var/www/configs/php/init.sql
fi
if ! [ -f '/var/www/html/public/config/config.inc.php' ]; then
  cat << EOF > /var/www/html/public/config/config.inc.php
<?php
\$config = array();
\$config['db_dsnw'] = 'mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@mysql/${MYSQL_DATABASE}';
\$config['db_prefix'] = 'rc_';
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
\$config['plugins'] = array(
  'password',
  'managesieve'
);
EOF
chown www-data: /var/www/html/public/config/config.inc.php
fi
if ! [ -f '/var/www/html/public/plugins/password/config.inc.php' ]; then
  cat << EOF > /var/www/html/public/plugins/password/config.inc.php
<?php
\$rcmail_config['password_force_save'] = true;
\$rcmail_config['password_query'] = "UPDATE virtual_users SET password = %D WHERE email = %u";
\$rcmail_config['password_dovecotpw'] = '/usr/bin/doveadm pw';
\$rcmail_config['password_dovecotpw_method'] = 'BLF-CRYPT';
\$rcmail_config['password_dovecotpw_with_method'] = true;
EOF
chown www-data: /var/www/html/public/plugins/managesieve/config.inc.php
fi
if ! [ -f '/var/www/html/public/plugins/password/config.inc.php' ]; then
  cat << EOF > /var/www/html/public/plugins/password/config.inc.php
<?php
\$config['managesieve_port'] = 4190;
\$rcmail_config['password_query'] = "UPDATE virtual_users SET password = %D WHERE email = %u";
\$config['managesieve_host'] = '%h';
\$config['managesieve_usetls'] = true;
EOF
chown www-data: /var/www/html/public/plugins/managesieve/config.inc.php
fi

"$@"
