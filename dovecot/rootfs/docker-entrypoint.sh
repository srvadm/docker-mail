#!/bin/sh

cat << EOF > /etc/dovecot/conf.d/10-auth.conf
auth_mechanisms = plain login

#!include auth-system.conf.ext
!include auth-sql.conf.ext
#!include auth-ldap.conf.ext
#!include auth-passwdfile.conf.ext
#!include auth-checkpassword.conf.ext
#!include auth-vpopmail.conf.ext
#!include auth-static.conf.ext
EOF
cat << EOF > /etc/dovecot/conf.d/10-mail.conf
mail_location = maildir:~/Maildir

namespace inbox {
  separator = /
}

mail_plugins = quota
EOF
cat << EOF > /etc/dovecot/conf.d/10-master.conf
service imap-login {
   inet_listener imap {
    port = 143
  }
  inet_listener imaps {
    port = 993
    ssl = yes
  }
}
service pop3-login {
  inet_listener pop3 {
    port = 110
  }
  inet_listener pop3s {
    port = 995
    ssl = yes
  }
}
#service submission-login {
#  inet_listener submission {
#    port = 587
#  }
#}
service lmtp {
  inet_listener lmtp {
#    address = 127.0.0.1
    port = 24
  }
}
service auth {
  # Postfix smtp-auth
  inet_listener {
    port = 26
  }
}
service imap {
  # Most of the memory goes to mmap()ing files. You may need to increase this
  # limit if you have huge mailboxes.
  #vsz_limit = $default_vsz_limit

  # Max. number of IMAP processes (connections)
  #process_limit = 1024
}

service pop3 {
  # Max. number of POP3 processes (connections)
  #process_limit = 1024
}

#service submission {
#  # Max. number of SMTP Submission processes (connections)
#  #process_limit = 1024
#}
EOF
cat << EOF > /etc/dovecot/conf.d/10-ssl.conf
ssl = required
ssl_cert = </etc/ssl/dovecot/certificate.crt
ssl_key = </etc/ssl/dovecot/privatekey.key
EOF
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

"$@"