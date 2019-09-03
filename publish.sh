set -e

docker build --tag treppo/nginx-cloudflare-ddns:latest-armhf .
docker build --build-arg image=alpine:3.10 --tag treppo/nginx-cloudflare-ddns:latest .
docker push treppo/nginx-cloudflare-ddns:latest-armhf
docker push treppo/nginx-cloudflare-ddns:latest
