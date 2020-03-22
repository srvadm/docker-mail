FROM alpine:3.11
LABEL maintainer="Tino Naumann <mail@ti-no.de>"

RUN apk add --no-cache --update-cache \
  tzdata                              \
  dovecot                             \
  dovecot-mysql                       \
  dovecot-pop3d                       \
  dovecot-lmtpd                       \
  dovecot-pigeonhole-plugin

COPY rootfs /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["sh"]