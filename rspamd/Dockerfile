FROM alpine:3.11
LABEL maintainer="Tino Naumann <mail@ti-no.de>"

RUN apk add --no-cache --update-cache \
  tzdata                              \
  rspamd

COPY rootfs /
VOLUME ["/etc/rspamd"]
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["sleep", "1000000d"]