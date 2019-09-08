ARG image=arm32v7/alpine:3.10

FROM golang:alpine AS build
ARG TARGETPLATFORM
ARG BUILDPLATFORM
COPY ./go-crond /go/src/go-crond
WORKDIR /go/src/go-crond

RUN apk --no-cache add git \
    && go get \
    && go build \
    && chmod +x go-crond \
    && ./go-crond --version


FROM $image

# define environment variables needed for ip update script
ENV API_KEY= \
    AUTH_EMAIL= \
    ZONE_NAME= \
    RECORD_NAME=

# add unprivileged user and install packages
RUN addgroup --system --gid 666 web \
    && adduser --system --disabled-password --no-create-home --uid 666 --home /var/cache/web --shell /sbin/nologin --ingroup web --gecos web web \
    && apk add --update --no-cache jq curl nginx

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/conf.d/*.conf /etc/nginx/conf.d/

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# run ip update every minute
COPY --from=build /go/src/go-crond/go-crond /usr/local/bin
COPY cloudflare.sh /usr/local/bin
COPY crontab /etc/crontabs/web
RUN rm /etc/crontabs/root

EXPOSE 8080

USER 666

CMD nginx \
    && go-crond --default-user=web --allow-unprivileged
