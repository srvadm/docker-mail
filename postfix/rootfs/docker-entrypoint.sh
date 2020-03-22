#!/bin/sh

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
#postconf virtual_mailbox_domains=mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf
#postconf virtual_mailbox_maps=mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf
#postconf virtual_alias_maps=mysql:/etc/postfix/mysql-virtual-alias-maps.cf,mysql:/etc/postfix/mysql-email2email.cf

cat << EOF >> /etc/postfix/main.cf
virtual_mailbox_domains = mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf
virtual_mailbox_maps = mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf
virtual_alias_maps = mysql:/etc/postfix/mysql-virtual-alias-maps.cf,mysql:/etc/postfix/mysql-email2email.cf
EOF


"$@"