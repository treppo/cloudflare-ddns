set -e

docker buildx build --platform linux/arm/v7 --tag treppo/nginx-cloudflare-ddns:latest-armhf .
docker push treppo/nginx-cloudflare-ddns:latest-armhf
