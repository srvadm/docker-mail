FROM alpine:3.11
LABEL maintainer="Tino Naumann <mail@ti-no.de>"

RUN apk add --no-cache --update-cache     \
    tzdata                                \
    rspamd                                \
    rspamd-proxy

COPY rootfs /

VOLUME ["/etc/rspamd"]
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["rspamd", "-f", "-u", "rspamd", "-g", "rspamd"]
