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

postconf maillog_file=/dev/stdout
postconf virtual_mailbox_domains=mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf
postconf virtual_mailbox_maps=mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf
postconf virtual_alias_maps=mysql:/etc/postfix/mysql-virtual-alias-maps.cf,mysql:/etc/postfix/mysql-email2email.cf
postconf smtpd_sasl_path=inet:$DOVECOT_SERVER:26
postconf smtpd_sasl_type=dovecot
postconf virtual_transport=lmtp:inet:$DOVECOT_SERVER:24
postconf "smtpd_recipient_restrictions = \
     reject_unauth_destination \
     check_policy_service inet:$DOVECOT_SERVER:27"



#cat << EOF >> /etc/postfix/main.cf
#virtual_mailbox_domains = mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf
#virtual_mailbox_maps = mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf
#virtual_alias_maps = mysql:/etc/postfix/mysql-virtual-alias-maps.cf,mysql:/etc/postfix/mysql-email2email.cf
#smtpd_sasl_path = inet:dovecot:26
#smtpd_sasl_type = dovecot
#virtual_transport = lmtp:inet:dovecot:24
#EOF

#mutt -f imaps://dev@m02.srvadm.de@m02.srvadm.de

"$@"