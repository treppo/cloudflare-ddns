FROM alpine:3.10.1

COPY crontab /var/spool/cron/crontabs/root

ENV API_KEY=

RUN apk add --update --no-cache jq curl

WORKDIR /app/dynamic-dns

CMD ./cloudflare.sh
