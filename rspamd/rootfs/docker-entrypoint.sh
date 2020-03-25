#!/bin/sh

cat << EOF > /etc/rspamd/override.d/milter_headers.conf
extended_spam_headers = true;
EOF
cat << EOF > /etc/rspamd/override.d/classifier-bayes.conf
autolearn = true;
users_enabled = true;
EOF
cat << EOF > /etc/rspamd/override.d/redis.conf
servers = "$REDIS_SERVER";
EOF
cat << EOF > /etc/rspamd/override.d/statistic.conf
classifier "bayes" {
   users_enabled = true;
   backend = "redis";
}
EOF
cat << EOF > /etc/rspamd/local.d/worker-proxy.inc
upstream "local" {
  self_scan = yes;
}
bind_socket = *:11332;
EOF

"$@"
