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
postconf smtpd_sender_login_maps=mysql:/etc/postfix/mysql-email2email.cf
postconf smtpd_sasl_path=inet:$DOVECOT_SERVER:26
postconf smtpd_sasl_type=dovecot
postconf smtpd_sasl_auth_enable=yes
postconf virtual_transport=lmtp:inet:$DOVECOT_SERVER:24
postconf "smtpd_recipient_restrictions = \
  reject_unauth_destination \
  check_policy_service inet:$DOVECOT_SERVER:27"
postconf smtpd_tls_security_level=may
postconf smtpd_tls_auth_only=yes
postconf smtpd_tls_cert_file=/etc/ssl/postfix/certificate.crt
postconf smtpd_tls_key_file=/etc/ssl/postfix/privatekey.key
postconf smtp_tls_security_level=may
postconf "smtpd_relay_restrictions = \
  permit_mynetworks \
  permit_sasl_authenticated \
  defer_unauth_destination"
postconf smtpd_milters=inet:$RSPAMD_SERVER:11332
postconf non_smtpd_milters=inet:$RSPAMD_SERVER:11332
postconf milter_mail_macros="i {mail_addr} {client_addr} {client_name} {auth_authen}"
cat << EOF >> /etc/postfix/master.cf
submission inet n       -       n       -       -       smtpd
  -o syslog_name=postfix/submission
  -o smtpd_tls_security_level=encrypt
  -o smtpd_sasl_auth_enable=yes
  -o smtpd_tls_auth_only=yes
  -o smtpd_reject_unlisted_recipient=no
  -o smtpd_relay_restrictions=permit_sasl_authenticated,reject
  -o milter_macro_daemon_name=ORIGINATING
EOF

"$@"
