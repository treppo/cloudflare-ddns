FROM arm32v7/alpine:3.10.1

COPY crontab /var/spool/cron/crontabs/root

COPY cloudflare.sh /app/dynamic-dns/cloudflare.sh

ENV API_KEY= \
    AUTH_EMAIL= \
    ZONE_NAME= \
    RECORD_NAME=

RUN apk add --update --no-cache jq curl

WORKDIR /app/dynamic-dns

CMD ./cloudflare.sh
