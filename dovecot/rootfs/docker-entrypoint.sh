#!/bin/sh

cat << EOF > /etc/dovecot/conf.d/10-logging.conf
log_path = /dev/stdout
info_log_path = /dev/stdout
EOF
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
  inbox = yes
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
  #vsz_limit = \$default_vsz_limit

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
chmod go= /etc/dovecot/conf.d/20-lmtp.conf
cat << EOF > /etc/dovecot/conf.d/20-lmtp.conf
protocol lmtp {
  mail_plugins = \$mail_plugins sieve
}
EOF
cat << EOF > /etc/dovecot/conf.d/90-quota.conf
plugin {
  quota = maildir:User quota

  quota_status_success = DUNNO
  quota_status_nouser = DUNNO
  quota_status_overquota = "452 4.2.2 Mailbox is full and cannot receive any more emails"
}
service quota-status {
  executable = /usr/libexec/dovecot/quota-status -p postfix
  inet_listener {
    port = 27
  }
}
plugin {
   quota_warning = storage=95%% quota-warning 95 %u
   quota_warning2 = storage=80%% quota-warning 80 %u
   quota_warning3 = -storage=100%% quota-warning below %u
}
service quota-warning {
   executable = script /usr/local/bin/quota-warning.sh
   unix_listener quota-warning {
     group = dovecot
     mode = 0660
   }
 }
EOF
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
mkdir /etc/dovecot/sieve /etc/dovecot/sieve-after
cat << EOF > /etc/dovecot/conf.d/90-sieve.conf
plugin {
  sieve = file:~/sieve;active=~/.dovecot.sieve
  sieve_after = /etc/dovecot/sieve-after

  # From elsewhere to Junk folder
  imapsieve_mailbox1_name = Junk
  imapsieve_mailbox1_causes = COPY
  imapsieve_mailbox1_before = file:/etc/dovecot/sieve/learn-spam.sieve

  # From Junk folder to elsewhere
  imapsieve_mailbox2_name = *
  imapsieve_mailbox2_from = Junk
  imapsieve_mailbox2_causes = COPY
  imapsieve_mailbox2_before = file:/etc/dovecot/sieve/learn-ham.sieve

  sieve_pipe_bin_dir = /etc/dovecot/sieve
  sieve_global_extensions = +vnd.dovecot.pipe
  sieve_plugins = sieve_imapsieve sieve_extprograms
}
EOF
cat << EOF > /etc/dovecot/sieve-after/spam-to-folder.sieve
require ["fileinto","mailbox"];

if header :contains "X-Spam" "Yes" {
 fileinto :create "Junk";
 stop;
}
EOF
cat << EOF > /etc/dovecot/sieve/learn-spam.sieve
require ["vnd.dovecot.pipe", "copy", "imapsieve"];
pipe :copy "rspamd-learn-spam.sh";
EOF
cat << EOF > /etc/dovecot/sieve/learn-ham.sieve
require ["vnd.dovecot.pipe", "copy", "imapsieve", "variables"];
if string "${mailbox}" "Trash" {
  stop;
}
pipe :copy "rspamd-learn-ham.sh";
EOF
sievec /etc/dovecot/sieve-after/spam-to-folder.sieve
sievec /etc/dovecot/sieve/learn-spam.sieve
sievec /etc/dovecot/sieve/learn-ham.sieve
chmod u=rw,go= /etc/dovecot/sieve/{learn-{spam,ham},spam-to-folder}.{sieve,svbin}
chown vmail.vmail /etc/dovecot/sieve/{learn-{spam,ham},spam-to-folder}.{sieve,svbin}
cat << EOF > /etc/dovecot/sieve/rspamd-learn-spam.sh
#!/bin/sh
exec /usr/bin/rspamc learn_spam
EOF
cat << EOF > /etc/dovecot/sieve/rspamd-learn-ham.sh
#!/bin/sh
exec /usr/bin/rspamc learn_ham
EOF
chmod u=rwx,go= /etc/dovecot/sieve/rspamd-learn-{spam,ham}.sh
chown vmail.vmail /etc/dovecot/sieve/rspamd-learn-{spam,ham}.sh
cat << EOF > /etc/dovecot/conf.d/20-imap.conf
protocol imap {
  mail_plugins = \$mail_plugins imap_sieve
}
EOF

cat << EOF > /etc/dovecot/conf.d/15-mailboxes.conf
namespace inbox {
  mailbox Drafts {
    special_use = \Drafts
  }
  mailbox Junk {
    special_use = \Junk
    auto = subscribe
    autoexpunge = 30d
  }
  mailbox Trash {
    special_use = \Trash
    auto = subscribe
    autoexpunge = 30d
  }
  mailbox Sent {
    special_use = \Sent
  }
  mailbox "Sent Messages" {
    special_use = \Sent
  }
}
EOF

"$@"