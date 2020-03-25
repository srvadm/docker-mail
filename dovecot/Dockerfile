FROM alpine:3.11
LABEL maintainer="Tino Naumann <mail@ti-no.de>"

RUN apk add --no-cache --update-cache                 \
    tzdata                                            \
    shadow                                            \
    dovecot                                           \
    dovecot-mysql                                     \
    dovecot-pop3d                                     \
    dovecot-lmtpd                                     \
    dovecot-pigeonhole-plugin                         \
  && groupadd -g 5000 vmail                           \
  && useradd -g vmail -u 5000 vmail -d /var/vmail -m

COPY rootfs /

VOLUME ["/var/vmail"]
EXPOSE 143 993 110 995
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["dovecot", "-F"]