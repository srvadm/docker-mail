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

RUN sievec                                        \
    /etc/dovecot/sieve-after/spam-to-folder.sieve \
  && sievec                                       \
    /etc/dovecot/sieve/learn-spam.sieve           \
  && sievec                                       \
    /etc/dovecot/sieve/learn-ham.sieve            \
  && chmod u=rw,go=                               \
    /etc/dovecot/sieve-after/*                    \
    /etc/dovecot/sieve/*                          \
  && chown vmail.vmail                            \
    /etc/dovecot/sieve-after/*                    \
    /etc/dovecot/sieve/*                          \
  && chmod u=rwx,go=                              \
    /etc/dovecot/sieve/rspamd-learn-spam.sh       \
    /etc/dovecot/sieve/rspamd-learn-spam.sh

VOLUME ["/var/vmail"]
EXPOSE 143 993 110 995
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["dovecot", "-F", "-c", "/etc/dovecot/dovecot.conf"]
HEALTHCHECK --start-period=350s CMD echo QUIT | nc localhost 110 | grep "+OK Dovecot ready."