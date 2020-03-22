#!/bin/sh

if [ -z ${MYSQL_USER-} ]; then
  echo you need to define a mysql user
  exit 1
fi
if [ -z ${MYSQL_PWD-} ]; then
  echo you need to define a mysql user password
  exit 1
fi
if [ -z ${MYSQL_DB-} ]; then
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

cat << "EOF" | php --
<?php
$connected = false;
while(!$connected) {
  try{
    $dbh = new pdo( 
      'mysql:host=mysql:3306;dbname=$_SERVER["MYSQL_DB"]', '$_SERVER["MYSQL_USER"]', '$_SERVER["MYSQL_PWD]',
      array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
    );
    $connected = true;
  }
  catch(PDOException $ex){
    error_log("Could not connect to MySQL");
    error_log($ex->getMessage());
    error_log("Waiting for MySQL Connection.);
    sleep(5);
  }
}
EOF

"$@"
