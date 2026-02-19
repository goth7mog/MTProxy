#!/bin/sh
set -e

# Configure ngrok if authtoken is provided
if [ -n "$NGROK_AUTHTOKEN" ]; then
    ngrok config add-authtoken "$NGROK_AUTHTOKEN"
    ngrok http 8388 --log stdout &
fi

# Start dnscrypt-proxy
dnscrypt-proxy -config /etc/dnscrypt-proxy.toml &

# Give dnscrypt-proxy time to start
sleep 2

# Replace UUID placeholder with environment variable
sed "s/__VLESS_UUID__/${VLESS_UUID}/g" /etc/xray-config.json > /tmp/xray-config.json

# Start Xray with the updated config
exec xray run -c /tmp/xray-config.json
