FROM alpine:3.22

RUN apk add --no-cache \
    mariadb-client \
    postgresql17-client \
    redis \
    sqlite
