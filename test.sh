#!/usr/bin/env sh

set -e

docker build \
  --build-arg image=alpine:3.10 \
  --tag treppo/cloudflare-ddns \
  "$PWD"
docker run \
  --env-file ddns.env \
  --volume "$PWD"/log:/var/cache/dynamic-dns \
  treppo/cloudflare-ddns
