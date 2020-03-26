#!/bin/sh

cat << EOF > /etc/rspamd/override.d/redis.conf
servers = "$REDIS_SERVER";
EOF

"$@"
