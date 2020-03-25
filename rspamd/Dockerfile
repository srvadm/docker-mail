FROM alpine:3.11
LABEL maintainer="Tino Naumann <mail@ti-no.de>"

RUN apk add --no-cache --update-cache     \
    tzdata                                \
    rspamd                                \
  && echo -e 'filename = "/dev/stdout";'  \
    > /etc/rspamd/local.d/logging.inc

COPY rootfs /

USER rspamd
VOLUME ["/etc/rspamd"]
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["rspamd", "-f"]