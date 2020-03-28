#!/bin/sh

cat << EOF > /etc/rspamd/dkim_selectors.map
m02.srvadm.de 2020032701
EOF
chown rspamd:rspamd /etc/rspamd/dkim_selectors.map

"$@"
