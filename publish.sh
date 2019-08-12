set -e

docker build --tag treppo/cloudflare-ddns .
docker push treppo/cloudflare-ddns
