FROM alpine:3.11
LABEL maintainer="Tino Naumann <mail@ti-no.de>"

RUN apk add --no-cache --update-cache \
    tzdata                            \
    postfix                           \
    postfix-mysql                     \
  && newaliases

COPY rootfs /

EXPOSE 25 587
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["postfix", "start-fg"]
HEALTHCHECK --start-period=350s CMD echo QUIT | nc localhost 25 | grep "220 .* ESMTP Postfix"