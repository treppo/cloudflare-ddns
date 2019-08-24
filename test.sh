#!/usr/bin/env sh

set -e

sed -i '' 's/FROM arm32v7\/alpine/FROM alpine/' Dockerfile
docker build --tag treppo/cloudflare-ddns .
docker run \
  --env-file ddns.env \
  -v "$PWD"/log:/app/dynamic-dns/log \
  treppo/cloudflare-ddns
sed -i '' 's/FROM alpine/FROM arm32v7\/alpine/' Dockerfile
