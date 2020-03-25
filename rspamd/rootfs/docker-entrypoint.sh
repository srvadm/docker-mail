#!/bin/sh


cat << EOF > /etc/rspamd/override.d/worker-proxy.inc
bind_socket = "*:11332";
milter = yes;
timeout = 120s;
upstream "local" {
  default = yes;
  self_scan = yes;
}
EOF


"$@"
