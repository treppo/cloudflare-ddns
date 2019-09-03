#!/usr/bin/env sh

set -e

cp nginx/conf.d/treppo.org.conf nginx/conf.d/localhost.conf
sed -i '' 's/server_name cloud.treppo.org;/server_name localhost;/' nginx/conf.d/localhost.conf

docker build \
  --build-arg image=alpine:3.10 \
  --tag treppo/cloudflare-ddns \
  "$PWD"
docker run \
  --env-file ddns.env \
  --volume "$PWD"/log:/var/cache/dynamic-dns \
  --volume "$PWD"/html:/var/www/html/:ro \
  --publish 8080:8080 \
  treppo/cloudflare-ddns
