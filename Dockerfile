ARG image=arm32v7/alpine:3.10

FROM $image

# run ip update every 5 minutes
RUN mkdir /etc/periodic/5min && \
    echo "*/5	*	*	*	*	run-parts /etc/periodic/5min" >> /etc/crontabs/root && \
    cat /etc/crontabs/root

# define environment variables needed for ip update script
ENV API_KEY= \
    AUTH_EMAIL= \
    ZONE_NAME= \
    RECORD_NAME=

# add unprivileged user and install packages
RUN addgroup --system --gid 666 web \
    && adduser --system --disabled-password --no-create-home --uid 666 --home /var/cache/web --shell /sbin/nologin --ingroup web --gecos web web \
    && apk add --update --no-cache jq curl nginx

COPY cloudflare.sh /etc/periodic/5min/dynamic-dns
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/conf.d/*.conf /etc/nginx/conf.d/

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 8080

USER 666

CMD /etc/periodic/5min/dynamic-dns \
    && nginx \
    && crond -f
