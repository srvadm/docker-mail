#!/bin/sh

if [ -z ${DOMAIN-} ]; then
  echo you need to define a domain
  exit 1
fi
if [ -z ${MYSQL_SERVER-} ]; then
  MYSQL_SERVER=mysql
fi

postconf myhostname=$DOMAIN
cat << EOF > /etc/postfix/mysql-virtual-mailbox-domains.cf
user = $MYSQL_USER
password = $MYSQL_PASSWORD
hosts = $MYSQL_SERVER
dbname = $MYSQL_DATABASE
query = SELECT 1 FROM virtual_domains WHERE name='%s'
EOF
cat << EOF > /etc/postfix/mysql-virtual-mailbox-maps.cf
user = $MYSQL_USER
password = $MYSQL_PASSWORD
hosts = $MYSQL_SERVER
dbname = $MYSQL_DATABASE
query = SELECT 1 FROM virtual_users WHERE email='%s'
EOF
cat << EOF > /etc/postfix/mysql-virtual-alias-maps.cf
user = $MYSQL_USER
password = $MYSQL_PASSWORD
hosts = $MYSQL_SERVER
dbname = $MYSQL_DATABASE
query = SELECT destination FROM virtual_aliases WHERE source='%s'
EOF
cat << EOF > /etc/postfix/mysql-email2email.cf
user = $MYSQL_USER
password = $MYSQL_PASSWORD
hosts = $MYSQL_SERVER
dbname = $MYSQL_DATABASE
query = SELECT email FROM virtual_users WHERE email='%s'
EOF
chown root:postfix /etc/postfix/mysql-*.cf
chmod u=rw,g=r,o= /etc/postfix/mysql-*.cf

"$@"
