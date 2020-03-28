FROM alpine:3.11
LABEL maintainer="Tino Naumann <mail@ti-no.de>"

RUN apk add --no-cache --update-cache \
    tzdata                            \
    rspamd                            \
    rspamd-proxy                      \
  && mkdir /var/lib/rspamd/dkim

COPY rootfs /

VOLUME ["/var/lib/rspamd"]
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["rspamd", "-f", "-u", "rspamd", "-g", "rspamd"]
