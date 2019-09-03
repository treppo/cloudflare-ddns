set -e

docker build --tag treppo/nginx-cloudflare-ddns .
docker push treppo/nginx-cloudflare-ddns
