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
RUN mkdir /var/cache/nginx \
    && addgroup --gid 101 --system nginx \
    && adduser --system --disabled-password --no-create-home --uid 101 --home /var/cache/nginx --shell /sbin/nologin --ingroup nginx --gecos nginx nginx \
    && apk add --update --no-cache jq curl nginx

COPY cloudflare.sh /etc/periodic/5min/dynamic-dns
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/conf.d/*.conf /etc/nginx/conf.d/

# nginx user must own the cache directory to write cache
RUN chown -R 101:0 /var/cache/nginx \
	&& chmod -R g+w /var/cache/nginx

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 8080

USER 101

CMD /etc/periodic/5min/dynamic-dns \
    && nginx \
    && crond -f
