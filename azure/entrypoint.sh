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

# Start shadowsocks server
exec ss-server \
    -s 0.0.0.0 \
    -p 8388 \
    -m "${SHADOWSOCKS_METHOD}" \
    -k "${SHADOWSOCKS_PASSWORD}" \
    --plugin v2ray-plugin \
    --plugin-opts "server;mode=websocket" \
    -d 127.0.0.1:5053
