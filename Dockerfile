ARG image=arm32v7/alpine:3.10

FROM $image

RUN mkdir /etc/periodic/5min && \
    echo "*/5	*	*	*	*	run-parts /etc/periodic/5min" >> /etc/crontabs/root && \
    cat /etc/crontabs/root

COPY cloudflare.sh /etc/periodic/5min/dynamic-dns

ENV API_KEY= \
    AUTH_EMAIL= \
    ZONE_NAME= \
    RECORD_NAME=

RUN apk add --update --no-cache jq curl

CMD /etc/periodic/5min/dynamic-dns \
    && crond -f
