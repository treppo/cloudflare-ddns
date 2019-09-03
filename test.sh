#!/usr/bin/env sh

set -e

cp nginx/conf.d/treppo.org.conf nginx/conf.d/localhost.conf
sed -i '' 's/server_name cloud.treppo.org;/server_name localhost;/' nginx/conf.d/localhost.conf

docker build \
  --build-arg image=alpine:3.10 \
  --tag treppo/cloudflare-ddns \
  "$PWD"
docker run \
  --read-only \
  --env-file ddns.env \
  --volume "$PWD"/cache/nginx:/var/tmp/nginx \
  --volume "$PWD"/cache:/var/cache/dynamic-dns \
  --volume "$PWD"/cache:/var/cache/nginx \
  --volume "$PWD"/html:/var/www/html/:ro \
  --publish 8080:8080 \
  treppo/cloudflare-ddns
