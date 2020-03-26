#!/bin/sh

cat << EOF > /etc/dovecot/dovecot-sql.conf.ext
driver = mysql
connect = host=$MYSQL_SERVER dbname=$MYSQL_DATABASE user=$MYSQL_USER password=$MYSQL_PASSWORD
user_query = SELECT email as user, \
  concat('*:bytes=', quota) AS quota_rule, \
  '/var/vmail/%d/%n' AS home, \
  5000 AS uid, 5000 AS gid \
  FROM virtual_users WHERE email='%u'
password_query = SELECT password FROM virtual_users WHERE email='%u'
iterate_query = SELECT email AS user FROM virtual_users
EOF
chown root:root /etc/dovecot/dovecot-sql.conf.ext
chmod go= /etc/dovecot/dovecot-sql.conf.ext
cat << EOF > /usr/local/bin/quota-warning.sh
#!/bin/sh
PERCENT=\$1
USER=\$2
cat << _EOF | /usr/lib/dovecot/dovecot-lda -d \$USER -o "plugin/quota=maildir:User quota:noenforcing"
From: postmaster@$DOMAIN
Subject: Quota warning - \$PERCENT% reached

Your mailbox can only store a limited amount of emails.
Currently it is \$PERCENT% full. If you reach 100% then
new emails cannot be stored. Thanks for your understanding.
_EOF
EOF
chmod +x /usr/local/bin/quota-warning.sh

#cat << EOF > /etc/dovecot/conf.d/20-managesieve.conf
#protocols = \$protocols sieve

#service managesieve-login {
# inet_listener sieve {
#    port = 4190
#  }
#}
#protocol sieve {
#}
#EOF

"$@"