FROM alpine:3.11
LABEL maintainer="Tino Naumann <mail@ti-no.de>"

RUN apk add --no-cache --update-cache \
  tzdata                              \
  postfix                             \
  postfix-mysql

COPY rootfs /
EXPOSE 25 465
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["postfix", "start-fg"]