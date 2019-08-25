#!/usr/bin/env sh

set -e

# Cloudflare as Dynamic DNS
# Original non-RPi article: https://phillymesh.net/2016/02/23/setting-up-dynamic-dns-for-your-registered-domain-through-cloudflare/

ip=$(curl -s http://ipv4.icanhazip.com)
ip_file="/var/cache/dynamic-dns/ip.txt"
id_file="/var/cache/dynamic-dns/cloudflare-ids.txt"

# Keep files in the same folder when run from cron
cd "$(dirname "$(readlink -f "$0")")"

log() {
    if [ "$1" ]; then
	    printf "%b\n" "$(date) $1"
    fi
}

log "Checking for IP address change"

if [ -f $ip_file ]; then
    old_ip=$(cat $ip_file)
    if [ "$ip" = "$old_ip" ]; then
        log "IP has not changed."
        exit 0
    fi
fi

if [ -f $id_file ] && [ "$(wc -l $id_file | cut -d " " -f 1)" = 2 ]; then
    zone_identifier=$(head -1 $id_file)
    record_identifier=$(tail -1 $id_file)
else
    zone_response=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$ZONE_NAME" \
	    -H "X-Auth-Email: $AUTH_EMAIL" \
	    -H "X-Auth-Key: $API_KEY" \
	    -H "Content-Type: application/json")
    # If not successful, errors out
    if [ "$(echo "$zone_response" | jq -r '.success')" != "true" ]; then
        messages=$(echo "$zone_response" | jq -r '[.errors[] | .message] |join(" - ")')
        echo >&2 "Error: $messages"
        exit 1
    fi

    # Selects the zone id
    zone_identifier=$(echo "$zone_response" | jq -r ".result[0].id")

    # Tries to fetch the record of the host
    dns_record_response=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?name=$RECORD_NAME" \
        -H "X-Auth-Email: $AUTH_EMAIL" \
        -H "X-Auth-Key: $API_KEY" \
        -H "Content-Type: application/json")

    if [ "$(echo "$dns_record_response" | jq -r '.success')" != "true" ]; then
        messages=$(echo "$dns_record_response" | jq -r '[.errors[] | .message] |join(" - ")')
        echo >&2 "Error: $messages"
        exit 1
    fi

    record_identifier=$(echo "$dns_record_response" | jq -r ".result[] | select(.type ==\"A\") |.id")

    echo "$zone_identifier" > $id_file
    echo "$record_identifier" >> $id_file
fi

update=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier" \
	-H "X-Auth-Email: $AUTH_EMAIL" \
	-H "X-Auth-Key: $API_KEY" \
	-H "Content-Type: application/json" \
	--data "{\"id\":\"$zone_identifier\",\"type\":\"A\",\"name\":\"$RECORD_NAME\",\"content\":\"$ip\"}")

if [ "$(echo "$update" | jq -r '.success')" != "true" ]; then
    message="API UPDATE FAILED. DUMPING RESULTS:\n$update"
    log "$message"
    exit 1 
else
    message="IP changed to $ip"
    echo "$ip" > $ip_file
    log "$message"
fi

